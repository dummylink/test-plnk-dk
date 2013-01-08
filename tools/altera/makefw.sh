#!/bin/bash
################################################################################
# makefw   create firmware file for INK board
#
# create-firmware.sh is used to create a openPOWERLINK Slave DevKit firmware
# file.
# This script provides an interface to invoke the tools
#   - fpgahdr.exe
#   - create-firmware.sh
#
################################################################################


################################################################################
# definitions and default values
# user settings

## Settings for INK Board (example) ##

CNDK_DIR=/cygdrive/<your_path_to BR_POWERLINK-SLAVE_ALTERA_VX.X.X/02_Reference_Sources>
CNDK_DIR_DOS="<your_path_to BR_POWERLINK-SLAVE_ALTERA_VX.X.X\02_Reference_Sources>" 
                                                                
FPGACFG_SOF=${CNDK_DIR}/fpga/altera/TERASIC_DE2-115/ink_pcp_DirectIO/nios_openMac.sof
FPGACFG_VERS=1      # PCP will only trigger a reconfiguration if this differs from the current loaded version !
PCPSW_ELF=${CNDK_DIR}/powerlink/pcp_DirectIO/epl.elf
PCPSW_VERS=1
APSW_ELF= #e.g. AP SW *.bin file
APSW_VERS=

DEVICE=00000        # has to match "ProductCode_U32" in xdd-file (and device)
HW_REVISION=1       # has to match "RevisionNo_U32" in xdd-file (and device) and will be used as last digit of *.fw filename.
                    # In addition, it has to match AS subfolder name where the *.fw file is stored
                    # Tool restriction "fpgahdr.exe": value range is [0..999]
SW_REVISION=1       # Optional; It should match the "FirmwareVersion" data object if it exists,
                    # but will not be automatically verified by Automation Studio.
                    # This is a user defined object at the POWERLINK CN device.

APPSW_DATE=3        # Firmware download will only start if one of those values differs from
APPSW_TIME=3        # the CNs information sent in the Ident-Response frame.

# XML header tool
FPGAHDR=/cygdrive/<your_path_to BR_POWERLINK-SLAVE_ALTERA_VX.X.X/02_Reference_Sources/tools/BR/firmware/FpgaHdr.exe>

################################################################################
# fixed settings
CREATEFW=./create-firmware.sh


################################################################################
CURPATH=`pwd`
cd ${CNDK_DIR}/tools/altera

if [[ "$APSW_ELF" == "" ]]; then
    echo "no AP software!"
    ${CREATEFW} -o ${CURPATH}/firmware.bin -f ${FPGACFG_SOF} --fpgavers ${FPGACFG_VERS} \
                             -p ${PCPSW_ELF} --pcpvers ${PCPSW_VERS} \
                             -d ${DEVICE} -r ${HW_REVISION} \
                             --appswdate ${APPSW_DATE} --appswtime ${APPSW_TIME}
else
    echo "APSW = ${APSW_ELF}"
    ${CREATEFW} -o ${CURPATH}/firmware.bin -f ${FPGACFG_SOF} --fpgavers ${FPGACFG_VERS} \
                             -p ${PCPSW_ELF} --pcpvers ${PCPSW_VERS} \
                             -a ${APSW_ELF} --apvers ${APSW_VERS} \
                             -d ${DEVICE} -r ${HW_REVISION} \
                             --appswdate ${APPSW_DATE} --appswtime ${APPSW_TIME}
fi


cd $CURPATH

${FPGAHDR} firmware.bin -n=${DEVICE} -v=${SW_REVISION} -u=fw -s=${HW_REVISION} \
           -m=0 -asd=${APPSW_DATE} -ast=${APPSW_TIME} -a=KeepXmlHeader,0 -i


