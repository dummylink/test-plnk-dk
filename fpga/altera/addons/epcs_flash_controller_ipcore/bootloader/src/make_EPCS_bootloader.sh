#!/bin/bash
###############################################################################
# This script creates the modified epcs bootloader ready to replace the
# default altera bootloader in the *.sof file.
###############################################################################

###############################################################################
#
#
. "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash"

INPUT_VARS=$@

echo --- This is make_EPCS_bootloader.sh ---
echo input parameters: $INPUT_VARS

# process arguments
BSP_DIR=
while [ $# -gt 0 ]
do
  case "$1" in
	  --bspdir)
		 shift
		 #relative path!
		 BSP_DIR=$1
		 echo BSP_DIR set to \"$BSP_DIR\"
		 echo -------------------------------
		 ;;		  
  esac
  shift
done

if [ -z "$BSP_DIR" ]; then
echo "No BSP directory specified !"
echo "Use parameter: --bspdir <BSP_directory>"
exit 1
fi


# get address offsets from SOPC.info file

# User definitions
IN_FILE_SYSTEM_H=${BSP_DIR}/system.h
IN_FILE_EPLCFG_H=${BSP_DIR}/../EplCfg.h

#Error definitions
E_NOSUCHFILE=85

# verify input files
if [ ! -f "$IN_FILE_SYSTEM_H" ]
then   # Exit if no such file.
  echo -e "$IN_FILE_SYSTEM_H not found.\n"
  exit $E_NOSUCHFILE
fi

if [ ! -f "$IN_FILE_EPLCFG_H" ]
then   # Exit if no such file.
  echo -e "$IN_FILE_EPLCFG_H not found.\n"
  exit $E_NOSUCHFILE
fi

echo -e "\nReading addresses offsets for bootloader..."

# Search pattern in system.h
PATTERN[0]="EPCS_FLASH_CONTROLLER_0_BASE"
PATTERN[1]="REMOTE_UPDATE_CYCLONEIII_0_BASE"
PATTERN[2]="CONFIG_USER_IMAGE_FLASH_ADRS"

# Memory (defined in system.h) which should be flushed by bootloader.
# With uncommenting the next 2 lines this feature will activated.
#PATTERN[3]="SRAM_0_BASE" 
#PATTERN[4]="SRAM_0_SPAN"

###################################################################

# set number of counted pattern elements
cnt=0
if [ "${PATTERN[3]}" ] && [ "${PATTERN[4]}" ]; then
    # variables initialized
    LOOP_MAX_CNT=5
    echo "Activate EPCS-bootloader flushing of memory range."    
else
    # dont search for pattern 3 and 4
    LOOP_MAX_CNT=3
fi

while [ $cnt -lt $LOOP_MAX_CNT ] ; do

# set pattern
pattern=${PATTERN[$cnt]}

# set input file
if [ "$pattern" == "CONFIG_USER_IMAGE_FLASH_ADRS" ]; then
    IN_FILE=$IN_FILE_EPLCFG_H
else
    IN_FILE=$IN_FILE_SYSTEM_H
fi

#check if pattern can be found in the file
match_count=$(grep -w -c "$pattern" ${IN_FILE})

if [ "$match_count" != "1" ]; then
    echo "match_count = ${match_count}"
	echo "File ${IN_FILE} does not or to often contain pattern ${PATTERN[$cnt]}"	
    exit 1
fi

# get define value
DefineValue=$(grep -w "$pattern" ${IN_FILE} | grep \#define | grep -v //\# | awk '{split($0,a," "); print a[3]}')
echo "Pattern taken from ${IN_FILE}: $pattern= $DefineValue"

case  $cnt  in
    0)
		CODE_BASE=${DefineValue}
        EPCS_REGS_BASE=
        BOOTL_ADDR_HIGH=
        let "EPCS_REGS_BASE=$CODE_BASE + 0x0400"
        EPCS_REGS_BASE=$(printf "0x%x\n" $EPCS_REGS_BASE)
        let "BOOTL_ADDR_HIGH=$CODE_BASE + 0x03FF"
        BOOTL_ADDR_HIGH=$(printf "0x%x\n" $BOOTL_ADDR_HIGH)
	;;
    1)
        REMOTE_UPDATE_BASE=${DefineValue}
	;;
    2)
        USER_IMAGE_BOOT_BASE=${DefineValue}
	;;	
    3)
        MEM_SET_ZERO_BASE=${DefineValue}
	;;
    4)
        MEM_SET_ZERO_SPAN=${DefineValue}  
	;;
	5)
	;;
    *)echo Not a valid loop count!
	;;
esac
	
	cnt=$((cnt + 1))
	
done


echo "INFO: Input parameters for bootloader make file:
CODE_BASE            : ${CODE_BASE} 
EPCS_REGS_BASE       : ${EPCS_REGS_BASE}
REMOTE_UPDATE_BASE   : ${REMOTE_UPDATE_BASE}
USER_IMAGE_BOOT_BASE : ${USER_IMAGE_BOOT_BASE}
MEM_SET_ZERO_BASE    : ${MEM_SET_ZERO_BASE}
MEM_SET_ZERO_SPAN    : ${MEM_SET_ZERO_SPAN}"

# compile bootloader
# Note: If the remote update core "user mode" is observed, the image at USER_IMAGE_BOOT_BASE will be loaded.
#       Otherwise ("factory mode") the bootloader will load from address 0.
cmd="make CODE_BASE=${CODE_BASE} EPCS_REGS_BASE=${EPCS_REGS_BASE} \
REMOTE_UPDATE_BASE=${REMOTE_UPDATE_BASE} USER_IMAGE_BOOT_BASE=${USER_IMAGE_BOOT_BASE} \
MEM_SET_ZERO_BASE=${MEM_SET_ZERO_BASE} MEM_SET_ZERO_SPAN=${MEM_SET_ZERO_SPAN}  \
clean all"
echo "make_EPCS_bootloader.sh: Running \"$cmd\""
$cmd || {
    echo -e "make_EPCS_bootloader.sh: failed!"
    exit 1
}

# convert the srec- to hex-files
cmd="nios-convert -infile=boot_loader_epcs_sii_siii_ciii.srec -outfile=../epcs_flash_controller_0_boot_rom_synth.hex \
-width=32 -oformat=hex --address_low=${CODE_BASE} --address_high=${BOOTL_ADDR_HIGH}"
echo "make_EPCS_bootloader.sh: Running \"$cmd\""
$cmd || {
    echo -e "make_EPCS_bootloader.sh: failed!"
    exit 1
}

echo -e "Generating epcs_flash_controller_0_boot_rom_synth.hex done!\n" 

exit                      