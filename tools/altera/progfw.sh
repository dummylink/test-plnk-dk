#!/bin/bash
################################################################################
# progfw  program a firmware file into INK board
#
# This script provides an interface to invoke the tools
#   - progimage.sh
#
################################################################################

################################################################################
# definitions and default values
# user settings

CNDK_DIR=/cygdrive/<your_path_to BR_POWERLINK-SLAVE_ALTERA_VX.X.X/02_Reference_Sources>
CNDK_DIR_DOS="<your_path_to BR_POWERLINK-SLAVE_ALTERA_VX.X.X\02_Reference_Sources>" 
                                                                
## Settings for INK Board (example) ##
FPGACFG_SOF=${CNDK_DIR}/fpga/altera/TERASIC_DE2-115/ink_pcp_DirectIO/nios_openMac.sof
FPGACFG_VERS=1
PCPSW_ELF=${CNDK_DIR}/powerlink/pcp_DirectIO/epl.elf
PCPSW_VERS=1
APSW_ELF= #e.g. AP SW *.bin file
APSW_VERS=

APPSW_DATE=1
APPSW_TIME=1
                       # INK Board has 8MByte EPCS memory
PCP_INSTANCE=0         # INK Board CPU number
IMG_OFFSET=0x00000000  # INK Board Factory Image - max size 2MByte
IIB_OFFSET=0x00400000  # INK Board Factory Image
#IMG_OFFSET=0x00200000  # INK Board User Image  - max size 2MByte
#IIB_OFFSET=0x00410000  # INK Board User Image


PROGIMG=${CNDK_DIR}/tools/altera/progimage.sh

################################################################################
CURPATH=`pwd`
cd ${CNDK_DIR}/tools/altera

if [[ "$APSW_ELF" == "" ]]; then
    ${PROGIMG} -f ${FPGACFG_SOF} --fpgavers ${FPGACFG_VERS} \
               -p ${PCPSW_ELF} --pcpvers ${PCPSW_VERS} \
               --appswdate ${APPSW_DATE} --appswtime ${APPSW_TIME} \
               --imageoff ${IMG_OFFSET} --iiboff ${IIB_OFFSET} \
               --instance ${PCP_INSTANCE}
else
    ${PROGIMG} -f ${FPGACFG_SOF} --fpgavers ${FPGACFG_VERS} \
               -p ${PCPSW_ELF} --pcpvers ${PCPSW_VERS} \
               -a ${APSW_ELF} --apvers ${APSW_VERS} \
               --appswdate ${APPSW_DATE} --appswtime ${APPSW_TIME} \
               --imageoff ${IMG_OFFSET} --iiboff ${IIB_OFFSET} \
               --instance ${PCP_INSTANCE}
fi

cd $CURPATH


