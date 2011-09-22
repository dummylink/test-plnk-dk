#!/bin/sh
################################################################################
# progfactory.sh
#
# progfactory.sh is used to program an openPOWERLINK Slave DevKit factory image
# containing FPGA configuration, PCP software, AP software and Image
# Information block.
#
# (C) BERNECKER + RAINER, AUSTRIA, A-5142 EGGELSBERG, B&R STRASSE 1
################################################################################

################################################################################
# First, check to see if $SOPC_KIT_NIOS2 environmental variable is set.
# This variable is required for the command line tools to execute correctly.
if [[ -z $SOPC_KIT_NIOS2 ]]
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
CABLE=
INSTANCE=0
DEVICE=
IIB_BIN=iib.bin
IMAGE_REGION_START=0
IIB_REGION_START=0x1D0000


################################################################################
# tools
SOF2FLASH=$SOPC_KIT_NIOS2/bin/sof2flash
ELF2FLASH=$SOPC_KIT_NIOS2/bin/elf2flash
BIN2FLASH=$SOPC_KIT_NIOS2/bin/bin2flash
OBJCOPY=nios2-elf-objcopy
NIOS_PROG=nios2-flash-programmer
MKIIB=./mkiib


################################################################################
# print usage information
################################################################################
usage()
{
echo -e >&2 \
"\nopenPOWERLINK Slave Development Toolkit: progFactory.sh\n"\
"progFactory.sh programs a factory image onto a SlaveDevKit hardware. It "\
"reads a FPGA configuration in .sof format and a PCP software in .elf format"\
"and optionally an AP software in binary format.\n"\
"It creates a valid Image Information Block (IIB) and programs all parts\n"\
"into the flash memory.\n\n"\
"Usage:\n"\
"progfactory.sh     -f|--fpgacfg <fpgaconfig> --fpgavers <fpga_verssion>\n"\
"                   -p|--pcpsw <pcpsw> --pcpvers <pcpsw_version>\n"\
"                   [-a|--apsw <apsw> --apvers <apsw_version>]\n"\
"                   [--appswdate <appsw_date>] [--appswtime <appsw_time>]\n"\
"                   [--imageoff <image offset>] [--iiboff <IIB offset>]\n"\
"                   [--cable <cable name>] [--device <device index>]\n"\
"                   [--instance <instance>]\n"\

"progfacroy.sh      -h|--help\n\n"\
"Available options:\n"\
" -h                         Print this help\n"\
" -f|--fpgacfg <fpgaconfig>  FPGA configuration file to program\n"\
" --fpgavers <fpga_version>  Version number of FPGA configuration\n"\
" -p|--pcpsw <pcpsw>         PCP software to program\n"\
" --pcpvers <pcpsw_version>  Version number of PCP software\n"\
" -a|--apsw <apsw>           AP software to program\n"\
" --apvers <apsw_version>    Version number of AP software\n"\
" --appswdate <appswdate>    Application software date (days since 01.01.1984)\n"\
" --appswtime <appswtime>    Application software time (milliseconds since midnight)\n"\
"                            and time fields. If no date is specified\n"\
"                            the current system date is used!\n"\
" --imageoff <image offset>  Offset of the image region in flash\n"\
" --iiboff <IIB offset>      Offset of the IIB in flash\n"\
" --cable <cable name>		 Specifies which download cable to use\n"\
"                            (see nios2-flash-programmer manual)\n"\
" --device <device index>	 Specifies the FPGA's device number in JTAG chain\n"\
"                            (see nios2-flash-programmer manual)\n"\
" --instance <instance>		 Specifies which Nios II JTAG debug module to look at\n"\
"                            (see nios2-flash-programmer manual)\n"
exit 1
}

################################################################################
# Read command line arguments
#
options=0
while [ $# -gt 0 ]
do
    case "$1" in
        -f|--fpgacfg)       FPGACFG_SOF="$2"; let "options|=1"; shift;;
        --fpgavers)         FPGACFG_VERS="$2"; let "options|=2"; shift;;
        -p|--pcpsw)         PCPSW_ELF="$2"; let "options|=4"; shift;;
        --pcpvers)          PCPSW_VERS="$2"; let "options|=8"; shift;;
        -a|--apsw)          APSW_BIN="$2"; let "options|=16"; shift;;
        --apvers)           APSW_VERS="$2"; let "options|=32"; shift;;
        --appswdate)        APPSWDATE="$2"; shift;;
        --appswtime)        APPSWTIME="$2"; shift;;
        --imageoff)			IMAGE_REGION_START="$2"; shift;;
        --iiboff)			IIB_REGION_START="$2"; shift;;
        --cable)			CABLE="$2"; shift;;
        --device)			DEVICE="$2"; shift;;
        --instance)			INSTANCE="$2"; shift;;
        -v|--verbose)       VERBOSE="1";;
        --)                 shift; break;;
        -h|--help)          usage ;;
        -*|*)   usage ;;
    esac
    shift
done

################################################################################
# check for valid file extensions
if [[ ! ${FPGACFG_SOF##*.} == "sof" ]]; then
    echo -e "\nPlease specifiy a .sof file for FPGA configuration!"
    exit
fi

if [[ ! ${PCPSW_ELF##*.} == "elf" ]]; then
    echo -e "\nPlease specifiy a .elf file for PCP software!"
    exit
fi

if [[ ! "$APSW_BIN" == "" ]]; then
	if [[ ! ${APSW_BIN##*.} == "bin" ]]; then
	    echo -e "\nPlease specifiy a .bin file for AP software!"
	    exit
	fi
fi

if ([[ "$APPSWDATE" == "" ]] && [[ ! "$APPSWTIME" == "" ]]) ||
   ([[ ! "$APPSWDATE" == "" ]] && [[ "$APPSWTIME" == "" ]])
then
    echo -e "\nYou must specify both application software date and time or none"
    echo -e "of them to use the system time for calculating application software"
    echo -e "date and time."
    exit 1
fi

# check for valid options
if [[ "$options" -ne 15 ]] && [[ "$options" -ne 63 ]]; then
    echo -e "Invalid options!"
    usage
    exit
fi

################################################################################
# get basenames
FPGACFG_BASE=`basename $FPGACFG_SOF .sof`
PCPSW_BASE=`basename $PCPSW_ELF .elf`
APSW_BASE=`basename $APSW_BIN .bin`
IIB_BASE=`basename $IIB_BIN .bin`

# set options for application date and time depending if they are specified
# on command line or not
if [[ "$APPSWDATE" == "" ]]; then
    APPSWOPT=""
else
    APPSWOPT="--appswdate ${APPSWDATE} --appswtime ${APPSWTIME} "
fi

#
# set parameters for nios programmer tool
#
if [[ "$CABLE" == "" ]]; then
	CABOPT=""
else
	CABOPT="--cable ${CABLE}"
fi

if [[ "$DEVICE" == "" ]]; then
	DEVOPT=""
else
	DEVOPT="--device ${DEVICE}"
fi

################################################################################
# Creating flash for FPGA and Nios configuration for bootloader
echo -e "\n-----------------------------------------"
echo -e "Programming factory image ...\n"
echo -e "Using FPGA configuration: $FPGACFG_SOF"
echo -e "Using PCP software: $PCPSW_ELF"
echo -e "Using AP software: $APSW_BIN\n"

echo -e "FPGA configuration version $FPGACFG_VERS"
echo -e "PCP software version $PCPSW_VERS"
echo -e "AP software version $APSW_VERS"
echo -e "Application software date: $APPSWDATE"
echo -e "Application software time: $APPSWTIME"
echo -e "-----------------------------------------"

# Convert fpga configuration into srecord and binary file
$SOF2FLASH --quiet --epcs --input="${FPGACFG_SOF}" --output="${FPGACFG_BASE}.flash"
$OBJCOPY -I srec -O binary ${FPGACFG_BASE}.flash ${FPGACFG_BASE}.bin
# change addresses of FPGA flash file because sof2flash always places at 0 for epcs
$OBJCOPY -I binary -O srec --change-addresses $IMAGE_REGION_START ${FPGACFG_BASE}.bin ${FPGACFG_BASE}.flash
FPGAFILESIZE=`ls -l ${FPGACFG_BASE}.bin | awk '{print $5}'`

# Convert PCP software into srecord and binary file
$ELF2FLASH --epcs --input="${PCPSW_ELF}" --output="${PCPSW_BASE}.flash" --after="${FPGACFG_BASE}.flash"
$OBJCOPY -I srec -O binary "${PCPSW_BASE}.flash" "${PCPSW_BASE}.bin"
PCPFILESIZE=`ls -l ${PCPSW_BASE}.bin | awk '{print $5}'`

# AP software is already specified in binary format. We create an srecord to be
# programmed into flash
APOFFSET=$[$FPGAFILESIZE + PCPFILESIZE]
$BIN2FLASH --epcs --input="${APSW_BIN}" --output="${APSW_BASE}.flash" --location=$APOFFSET


# Now we create the IIB
if [[ "$options" == 15 ]]; then
    $MKIIB 	-f ${TMPDIR}/${FPGACFG_BASE}.bin --fpgavers $FPGACFG_VERS \
        	-p ${TMPDIR}/${PCPSW_BASE}.bin --pcpvers $PCPSW_VERS \
			${APPSWOPT} -o ${IIB_BIN}
else
    $MKIIB 	-f ${TMPDIR}/${FPGACFG_BASE}.bin --fpgavers $FPGACFG_VERS \
        	-p ${TMPDIR}/${PCPSW_BASE}.bin --pcpvers $PCPSW_VERS \
        	-a ${TMPDIR}/${APSW_BIN} --apvers $APSW_VERS \
			${APPSWOPT} -o ${IIB_BIN}
fi

$BIN2FLASH --epcs --input="${IIB_BIN}" --output="${IIB_BASE}.flash" --location=${IIB_REGION_START}

# program files into flash
$NIOS_PROG --epcs --base=0 ${FPGACFG_BASE}.flash ${CABOPT} ${DEVOPT} --instance ${INSTANCE}
$NIOS_PROG --epcs --base=0 ${PCPSW_BASE}.flash ${CABOPT} ${DEVOPT} --instance ${INSTANCE}
$NIOS_PROG --epcs --base=0 ${APSW_BASE}.flash ${CABOPT} ${DEVOPT} --instance ${INSTANCE}

# program IIB into flash
$NIOS_PROG --epcs --base=0 ${IIB_BASE}.flash ${CABOPT} ${DEVOPT} --instance ${INSTANCE}

exit

################################################################################
# Delete temporary files
#
rm -f ${FPGACFG_BASE}.flash
rm -f ${PCPSW_BASE}.flash
rm -f ${APSW_BASE}.flash
rm -f ${FPGACFG_BASE}.bin
rm -f ${PCPSW_BASE}.bin
rm -f ${IIB_BIN}
