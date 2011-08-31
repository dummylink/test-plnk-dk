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
FPGACFG_SOF=
FPGACFG_VERS=
PCPSW_ELF=
PCPSW_VERS=
APSW_BIN=
APSW_VERS=
DEVICE=
HW_REVISION=
FIRMWARE=

# tools
SOF2FLASH=$SOPC_KIT_NIOS2/bin/sof2flash
ELF2FLASH=$SOPC_KIT_NIOS2/bin/elf2flash
OBJCOPY=nios2-elf-objcopy
MKFW=./mkfirmware


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
options=0
while [ $# -gt 0 ]
do
    case "$1" in
        -f|--fpgacfg)  		FPGACFG_SOF="$2"; let "options|=1"; shift;;
        --fpgavers)			FPGACFG_VERS="$2"; let "options|=2"; shift;;
        -p|--pcpsw)			PCPSW_ELF="$2"; let "options|=4"; shift;;
        --pcpvers)			PCPSW_VERS="$2"; let "options|=8"; shift;;
        -a|--apsw)			APSW_BIN="$2"; let "options|=256"; shift;;
        --apvers)			APSW_VERS="$2"; let "options|=512"; shift;;
        -o|--output)     	FIRMWARE="$2"; let "options|=16"; shift;;
        --appswdate)        APPSWDATE="$2"; shift;;
        --appswtime)        APPSWTIME="$2"; shift;;  
        --device)           DEVICE="$2"; let "options|=32"; shift;;
        --hwrev)            HW_REVISION="$2"; let "options|=64"; shift;;      
        -v|--verbose)     	VERBOSE="1";;
        --)  				shift; break;;
        -h|--help)	    	usage ;;
        -*|*)   usage ;;
    esac
    shift
done

# check for valid file extensions
if [ ! ${FPGACFG_SOF##*.} == "sof" ]; then
     echo -e "\nPlease specifiy a .sof file for FPGA configuration!"
     exit
fi

if [ ! ${PCPSW_ELF##*.} == "elf" ]; then
     echo -e "\nPlease specifiy a .elf file for PCP software!"
     exit
fi

if [ ! ${APSW_BIN##*.} == "bin" ]; then
     echo -e "\nPlease specifiy a .bin file for AP software!"
     exit
fi

# check for valid options
if [ "$options" -ne 127 -a "$options" -ne 895 ]; then
    echo -e "Invalid options!"
    exit
fi

################################################################################

# get basename
FPGACFG_BASE=`basename $FPGACFG_SOF .sof`
PCPSW_BASE=`basename $PCPSW_ELF .elf`
APSW_BASE=`basename $APSW_BIN .bin`

################################################################################

# Creating flash for FPGA and Nios configuration for bootloader
echo -e "\n-----------------------------------------"
echo -e "Creating firmware file: ${FIRMWARE}\n"
echo -e "Using FPGA configuration: $FPGACFG_SOF"
echo -e "Using PCP software: $PCPSW_ELF"
echo -e "Using AP software: $APSW_BIN\n"

echo -e "FPGA configuration version $FPGACFG_VERS"
echo -e "PCP software version $PCPSW_VERS"
echo -e "AP software version $APSW_VERS"
echo -e "Application software date: $APPSWDATE"
echo -e "Application software time: $APPSWTIME"
echo -e "Device ID: $DEVICE"
echo -e "Hardware revision: $HW_REVISION\n"
echo -e "-----------------------------------------"


# Convert fpga configuration into binary file
$SOF2FLASH --epcs --input="${FPGACFG_SOF}" --output="${FPGACFG_BASE}.flash"
$OBJCOPY -I srec -O binary ${FPGACFG_BASE}.flash ${FPGACFG_BASE}.bin

# Convert PCP software into binary file
$ELF2FLASH --epcs --input="${PCPSW_ELF}" --output="${PCPSW_BASE}.flash" --after="${FPGACFG_BASE}.flash"
$OBJCOPY -I srec -O binary "${PCPSW_BASE}.flash" "${PCPSW_BASE}.bin"

# AP software is already specified in binary format. We don't care about the contents of the file!

# Create firmware file
#
# Now we create the firmware file by concatenating the three files and preced it
# by the firmware header.
if [ "$options" == 127 ]; then
    $MKFW -f ${TMPDIR}/${FPGACFG_BASE}.bin --fpgavers $FPGACFG_VERS \
         -p ${TMPDIR}/${PCPSW_BASE}.bin --pcpvers $PCPSW_VERS \
         -o ${FIRMWARE} --device $DEVICE --hwrev $HW_REVISION
else
    $MKFW -f ${TMPDIR}/${FPGACFG_BASE}.bin --fpgavers $FPGACFG_VERS \
         -p ${TMPDIR}/${PCPSW_BASE}.bin --pcpvers $PCPSW_VERS \
         -a ${TMPDIR}/${APSW_BIN} --apvers $APSW_VERS \
         -o ${FIRMWARE} --device $DEVICE --hwrev $HW_REVISION
fi      

exit
################################################################################
# Delete temporary files
#
rm -f ${FPGACFG_BASE}.flash
rm -f ${PCPSW_BASE}.flash
rm -f ${FPGACFG_BASE}.bin
rm -f ${PCPSW_BASE}.bin