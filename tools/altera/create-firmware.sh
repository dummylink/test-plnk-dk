#!/bin/sh
################################################################################
# create-firmware.sh
#
# create-firmware.sh is used to create a openPOWERLINK Slave DevKit firmware
# file.
################################################################################
 
################################################################################
# First, check to see if $SOPC_KIT_NIOS2 environmental variable is set.
# This variable is required for the command line tools to execute correctly.
if [ -z $SOPC_KIT_NIOS2 ]
then
    echo Required \$SOPC_KIT_NIOS2 Environmental Variable is not set!
    exit 1
fi

################################################################################
# definitions and default values
VERBOSE=
TMPDIR=. 

# tools 
SOF2FLASH=$SOPC_KIT_NIOS2/bin/sof2flash
ELF2FLASH=$SOPC_KIT_NIOS2/bin/elf2flash
OBJCPY=
MKFW= 
 

################################################################################
# print usage information
################################################################################ 
usage()
{
    echo -e >&2 \
	  "usage: create-firmware.sh -f <fpga configuration> -p <PCP software>\n" \
      "                          -a <AP software>\n" \
	  " -h: print help\n" \
	  " -f <fpga configuration>: fpga configuration to insert in firmware file\n" \
	  "                          in altera .sof format\n" \
	  " -p <PCP software>:       PCP software to insert in firmware file\n" \
	  "                          in ELF format (.elf)\n" \
	  " -a <AP software>:        AP software to insert in firmware file\n" \
	  "                          in binary format\n" \
	  " -o <firmware>:           firmware file to generate\n"
	  exit 1
} 
 
################################################################################
# Read command line arguments
#
if [ $# -eq 0 ]; then
    usage
fi

while [ $# -gt 0 ]
do
    case "$1" in
        -v)     VERBOSE="1";;
        -r)     REPORT="1";;
        -f)     FPGACFG_SOF="$2"; shift;;
        -p)     PCPSW_ELF="$2"; shift;;
        -a)     APSW_BIN="$2"; shift;;
        -o)     FIRMWARE="$2"; shift;;
        --)  	shift; break;;
        -h)	    usage ;;
        -*|*)   usage ;;
    esac
    shift
done
 
################################################################################ 

FPGACFG_BASE=`basename $FPGACFG_SOF .sof`
PCPSW_BASE=`basename $PCPSW_ELF .elf` 
 
################################################################################ 
 
# Creating flash for FPGA and Nios configuration for bootloader
echo -e "Creating firmware file ${FIRMWARE}\n"
echo -e "Using FPGA configuration: $FPGACFG_SOF\n"
echo -e "Using PCP software: $PCPSW_ELF\n"
echo -e "Using AP software: $APSW_BIN\n" 

# Convert fpga configuration into binary file
$SOF2FLASH --epcs --input=${FPGACFG_SOF} --output=${TMPDIR}/${FPGACFG_BASE}.flash
nios2-elf-objcopy -I srec -O binary ${TMPDIR}/${FPGACFG_BASE}.flash ${TMPDIR}/${FPGACFG_BASE}.bin
  
# Convert PCP software into binary file
$ELF2FLASH --epcs --input=${PCPSW_ELF} --output=${TMPDIR}/${PCPSW_BASE}.flash" --after=${TMPDIR}/${FPGACFG_BASE}.flash"
nios2-elf-objcopy -I srec -O binary ${TMPDIR}/${PCPSW_BASE}.flash ${TMPDIR}/${PCPSW_BASE}.bin

# AP software is already specified in binary format. We don't care about the contents of the file!

# Create firmware file
#
# Now we create the firmware file by concatenating the three files and preced it
# by the firmware header.
MKFW -f ${TMPDIR}/fpgaCfg.bin -p ${TMPDIR}/pcpSw.bin -a ${TMPDIR}/pcpSw.bin -a ${FLASH_OFFSET} -o ${FIRMWARE_FILE} -v
 
################################################################################
# Delete temporary files
#
rm -f ${TMPDIR}/${FPGACFG_BASE}.flash
rm -f ${TMPDIR}/${FPGACFG_BASE}.flash
rm -f ${TMPDIR}/${FPGACFG_BASE}.bin
rm -f ${TMPDIR}/${FPGACFG_BASE}.bin