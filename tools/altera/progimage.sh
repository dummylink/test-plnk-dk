#!/bin/sh
################################################################################
# progimage.sh
#
# progimage.sh is used to program an openPOWERLINK Slave DevKit image
# containing FPGA configuration, PCP software, AP software and Image
# Information block.
#
################################################################################
#
# License Agreement
#
# Copyright (C) 2011 BERNECKER + RAINER, AUSTRIA, 5142 EGGELSBERG, B&R STRASSE 1
# All rights reserved.
#
# Redistribution and use in source and binary forms,
# with or without modification,
# are permitted provided that the following conditions are met:
#
#  * Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer
#    in the documentation and/or other materials provided with the
#    distribution.
#  * Neither the name of the B&R nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
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
APSW_FILE=
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
"\nopenPOWERLINK Slave Development Toolkit: progimage.sh\n"\
"progimage.sh programs a factory image onto a SlaveDevKit hardware. It\n"\
"reads a FPGA configuration in .sof format and a PCP software in .elf format\n"\
"and optionally an AP software in binary format.\n"\
"It creates a valid Image Information Block (IIB) and programs all parts\n"\
"into the flash memory.\n\n"\
"Usage:\n"\
"progimage.sh      -f|--fpgacfg <fpgaconfig> --fpgavers <fpga_verssion>\n"\
"                   -p|--pcpsw <pcpsw> --pcpvers <pcpsw_version>\n"\
"                   [-a|--apsw <apsw> --apvers <apsw_version>]\n"\
"                   [--appswdate <appsw_date>] [--appswtime <appsw_time>]\n"\
"                   [--imageoff <image offset>] [--iiboff <IIB offset>]\n"\
"                   [--cable <cable name>] [--device <device index>]\n"\
"                   [--instance <instance>]\n"\
"progimage.sh      -h|--help\n\n"\
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
" --cable <cable name>         Specifies which download cable to use\n"\
"                            (see nios2-flash-programmer manual)\n"\
" --device <device index>     Specifies the FPGA's device number in JTAG chain\n"\
"                            (see nios2-flash-programmer manual)\n"\
" --instance <instance>         Specifies which Nios II JTAG debug module to look at\n"\
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
        -a|--apsw)          APSW_FILE="$2"; let "options|=16"; shift;;
        --apvers)           APSW_VERS="$2"; let "options|=32"; shift;;
        --appswdate)        APPSWDATE="$2"; shift;;
        --appswtime)        APPSWTIME="$2"; shift;;
        --imageoff)         IMAGE_REGION_START="$2"; shift;;
        --iiboff)           IIB_REGION_START="$2"; shift;;
        --cable)            CABLE="$2"; shift;;
        --device)           DEVICE="$2"; shift;;
        --instance)         INSTANCE="$2"; shift;;
        -v|--verbose)       VERBOSE="1";;
        --)                 shift; break;;
        -h|--help)          usage ;;
        -*|*)               echo -e "\nInvalid option: $1"; usage ;;
    esac
    shift
done

################################################################################
# check for valid file extensions
if [[ ! ${FPGACFG_SOF##*.} == "sof" ]]; then
    echo -e "\nPlease specifiy a .sof file for FPGA configuration!"
    exit
fi

if [[ ! "${PCPSW_ELF##*.}" == "elf" ]]; then
    echo -e "\nPlease specifiy a .elf file for PCP software!"
    exit
fi

if [[ ! "$APSW_FILE" == "" ]]; then
    if [[ ! "${APSW_FILE##*.}" == "bin" ]] && [[ ! "${APSW_FILE##*.}" == "elf" ]]; then
        echo -e "\nPlease specifiy a .bin/.elf file for AP software!"
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
FPGACFG_BASE=FPGA_`basename $FPGACFG_SOF .sof`
PCPSW_BASE=PCP_`basename $PCPSW_ELF .elf`
if [[ "${APSW_FILE##*.}" == "bin" ]] ; then
    APSW_BASE=AP_`basename $APSW_FILE .bin`
else
    APSW_BASE=AP_`basename $APSW_FILE .elf`
fi
IIB_BASE=IIB_`basename $IIB_BIN .bin`

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
echo -e "Programming firmware image ...\n"
echo -e "Using FPGA configuration: $FPGACFG_SOF"
echo -e "Using PCP software: $PCPSW_ELF"
if [[ "$options" -eq 63 ]]; then
    echo -e "Using AP software: $APSW_FILE\n"
fi

echo -e "FPGA configuration version $FPGACFG_VERS"
echo -e "PCP software version $PCPSW_VERS"
if [[ "$options" -eq 63 ]]; then
    echo -e "AP software version $APSW_VERS"
fi
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

if [[ "$options" -eq 63 ]]; then
    if [[ "${APSW_FILE##*.}" == "elf" ]] ; then
        $ELF2FLASH --epcs --input="${APSW_FILE}" --output="${APSW_BASE}.flash" --after="${PCPSW_BASE}.flash"
        $OBJCOPY -I srec -O binary "${APSW_BASE}.flash" "${APSW_BASE}.bin"
    else
        # AP software is already specified in binary format. We create an srecord to be
        # programmed into flash
        cp ${APSW_FILE} ${APSW_BASE}.bin
        APOFFSET=$[$FPGAFILESIZE + PCPFILESIZE]
        $BIN2FLASH --epcs --input="${APSW_BASE}.bin" --output="${APSW_BASE}.flash" --location=$APOFFSET
    fi
fi

# Now we create the IIB
if [[ "$options" -eq 15 ]]; then
    $MKIIB  -f ${TMPDIR}/${FPGACFG_BASE}.bin --fpgavers $FPGACFG_VERS \
            -p ${TMPDIR}/${PCPSW_BASE}.bin --pcpvers $PCPSW_VERS \
            --imageoff $IMAGE_REGION_START \
            ${APPSWOPT} -o ${IIB_BIN}
else
    $MKIIB  -f ${TMPDIR}/${FPGACFG_BASE}.bin --fpgavers $FPGACFG_VERS \
            -p ${TMPDIR}/${PCPSW_BASE}.bin --pcpvers $PCPSW_VERS \
            -a ${TMPDIR}/${APSW_BASE}.bin --apvers $APSW_VERS \
            --imageoff $IMAGE_REGION_START \
            ${APPSWOPT} -o ${IIB_BIN}
fi

$BIN2FLASH --epcs --input="${IIB_BIN}" --output="${IIB_BASE}.flash" --location=${IIB_REGION_START}

# program files into flash
$NIOS_PROG --epcs --base=0 ${FPGACFG_BASE}.flash ${CABOPT} ${DEVOPT} --instance ${INSTANCE}
$NIOS_PROG --epcs --base=0 ${PCPSW_BASE}.flash ${CABOPT} ${DEVOPT} --instance ${INSTANCE}
if [[ "$options" -eq 63 ]]; then
    $NIOS_PROG --epcs --base=0 ${APSW_BASE}.flash ${CABOPT} ${DEVOPT} --instance ${INSTANCE}
fi

# program IIB into flash
$NIOS_PROG --epcs --base=0 ${IIB_BASE}.flash ${CABOPT} ${DEVOPT} --instance ${INSTANCE}

################################################################################
# Delete temporary files
#
rm -f ${FPGACFG_BASE}.flash
rm -f ${PCPSW_BASE}.flash
rm -f ${APSW_BASE}.flash
rm -f ${FPGACFG_BASE}.bin
rm -f ${PCPSW_BASE}.bin
rm -f ${APSW_BASE}.bin
rm -f ${IIB_BIN}
rm -f ${IIB_BASE}.bin
rm -f ${IIB_BASE}.flash
