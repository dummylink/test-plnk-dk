#!/bin/bash
################################################################################
# create-firmware.sh
#
# create-firmware.sh is used to create a openPOWERLINK Slave DevKit firmware
# file.
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
DEVICE=
HW_REVISION=
FIRMWARE=

################################################################################
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
"\nopenPOWERLINK Slave Development Toolkit: create-firmware.sh\n"\
"create-firmware.sh creates a valid firmware file. It converts a FPGA\n"\
"configuration in .sof format and a PCP software in .elf format into binary format.\n"\
"It concatenates the binary files with an optional AP software binary\n"\
"and prepends a valid firmware header.\n\n"\
"Usage:\n"\
"create-firmware.sh -o|--output <firmware>\n"\
"                   -f|--fpgacfg <fpgaconfig> --fpgavers <fpga_verssion>\n"\
"                   -p|--pcpsw <pcpsw> --pcpvers <pcpsw_version>\n"\
"                   -a|--apsw <apsw> --apvers <apsw_version>\n"\
"                   -d|--device <deviceId> -r|--hwrev <hwRevision>\n"\
"                   [--appswdate <appsw_date>] [--appswtime <appsw_time>]\n"\
"create-firmware.sh -h|--help\n\n"\
"Available options:\n"\
" -h                         Print this help\n"\
" -f|--fpgacfg <fpgaconfig>  FPGA configuration file to insert in firmware\n"\
" --fpgavers <fpga_version>  Version number of FPGA configuration\n"\
" -p|--pcpsw <pcpsw>         PCP software to insert in firmware\n"\
" --pcpvers <pcpsw_version>  Version number of PCP software\n"\
" -a|--apsw <apsw>           AP software to insert in firmware\n"\
" --apvers <apsw_version>    Version number of AP software\n"\
" -o|--output <firmware>     Firmware file to create\n"\
" -d|--device <deviceId>     Device Id of device this firmware is used for\n"\
"                            Specified as 5-digit decimal value\n"\
" -r|--hwrev <hwReveision>   Hardware revision of device this firmware is used for\n"\
"                            Specified as 2-digit decimal value\n"\
" --appswdate <appswdate>    Application software date (days since 01.01.1984)\n"\
" --appswtime <appswtime>    Application software time (milliseconds since midnight)\n"\
"                            and time fields. If no date is specified\n"\
"                            the current system date is used!\n"
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
        -a|--apsw)          APSW_FILE="$2"; let "options|=256"; shift;;
        --apvers)           APSW_VERS="$2"; let "options|=512"; shift;;
        -o|--output)        FIRMWARE="$2"; let "options|=16"; shift;;
        --appswdate)        APPSWDATE="$2"; shift;;
        --appswtime)        APPSWTIME="$2"; shift;;
        -d|--device)        DEVICE="$2"; let "options|=32"; shift;;
        -r|--hwrev)         HW_REVISION="$2"; let "options|=64"; shift;;
        -v|--verbose)       VERBOSE="1";;
        --)                 shift; break;;
        -h|--help)          usage ;;
        -*|*)               echo -e "\nInvalid option: $1\n"; usage ;;
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
if [[ "$options" -ne 127 ]] && [[ "$options" -ne 895 ]]; then
    echo -e "Invalid options!"
    usage
    exit
fi

################################################################################
# get basenames
FPGACFG_BASE=`basename $FPGACFG_SOF .sof`
PCPSW_BASE=`basename $PCPSW_ELF .elf`
if [[ "${APSW_FILE##*.}" == "bin" ]] ; then
    APSW_BASE=AP_`basename $APSW_FILE .bin`
else
    APSW_BASE=AP_`basename $APSW_FILE .elf`
fi


# set options for application date and time depending if they are specified
# on command line or not
if [[ "$APPSWDATE" == "" ]]; then
    APPSWOPT=""
else
    APPSWOPT="--appswdate ${APPSWDATE} --appswtime ${APPSWTIME} "
fi

################################################################################
# Creating flash for FPGA and Nios configuration for bootloader
echo -e "\n-----------------------------------------"
echo -e "Creating firmware file: ${FIRMWARE}\n"
echo -e "Using FPGA configuration: $FPGACFG_SOF"
echo -e "Using PCP software: $PCPSW_ELF"
if [[ "$options" -eq 895 ]]; then
    echo -e "Using AP software: $APSW_FILE\n"
fi

echo -e "FPGA configuration version $FPGACFG_VERS"
echo -e "PCP software version $PCPSW_VERS"
if [[ "$options" -eq 895 ]]; then
    echo -e "AP software version $APSW_VERS"
fi
echo -e "Application software date: $APPSWDATE"
echo -e "Application software time: $APPSWTIME"
echo -e "Device ID: $DEVICE"
echo -e "Hardware revision: $HW_REVISION\n"
echo -e "-----------------------------------------"

# Convert fpga configuration into binary file
$SOF2FLASH --quiet --epcs --input="${FPGACFG_SOF}" --output="${FPGACFG_BASE}.flash"
$OBJCOPY -I srec -O binary ${FPGACFG_BASE}.flash ${FPGACFG_BASE}.bin

# Convert PCP software into binary file
$ELF2FLASH --epcs --input="${PCPSW_ELF}" --output="${PCPSW_BASE}.flash" --after="${FPGACFG_BASE}.flash"
$OBJCOPY -I srec -O binary "${PCPSW_BASE}.flash" "${PCPSW_BASE}.bin"

# Convert PCP software into binary file if specified as elf file
if [[ "$options" -eq 895 ]]; then
    if [[ "${APSW_FILE##*.}" == "elf" ]] ; then
        $ELF2FLASH --epcs --input="${APSW_FILE}" --output="${APSW_BASE}.flash" --after="${PCPSW_BASE}.flash"
        $OBJCOPY -I srec -O binary "${APSW_BASE}.flash" "${APSW_BASE}.bin"
    else
        cp ${APSW_FILE} ${APSW_BASE}.bin
    fi
fi

# Create firmware file
#
# Now we create the firmware file by concatenating the three files and preced it
# by the firmware header.
if [[ "$options" == 127 ]]; then
    $MKFW -f ${TMPDIR}/${FPGACFG_BASE}.bin --fpgavers $FPGACFG_VERS \
          -p ${TMPDIR}/${PCPSW_BASE}.bin --pcpvers $PCPSW_VERS \
      -o ${FIRMWARE} ${APPSWOPT} --device $DEVICE --hwrev $HW_REVISION
else
    $MKFW -f ${TMPDIR}/${FPGACFG_BASE}.bin --fpgavers $FPGACFG_VERS \
          -p ${TMPDIR}/${PCPSW_BASE}.bin --pcpvers $PCPSW_VERS \
          -a ${TMPDIR}/${APSW_BASE}.bin --apvers $APSW_VERS \
          -o ${FIRMWARE} ${APPSWOPT} --device $DEVICE --hwrev $HW_REVISION
fi

################################################################################
# Delete temporary files
#
rm -f ${FPGACFG_BASE}.flash
rm -f ${PCPSW_BASE}.flash
rm -f ${APSW_BASE}.flash
rm -f ${FPGACFG_BASE}.bin
rm -f ${PCPSW_BASE}.bin
rm -f ${APSW_BASE}.bin

