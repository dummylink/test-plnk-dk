#!/bin/bash
###############################################################################
# This script programs the ELF file of this directory and starts the terminal
###############################################################################

###############################################################################
#
#
. "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash"

######## Input Parameters ############
#
INPUT_VARS=$@

######## User settings
#
USB_CABLE=USB-Blaster[USB-0]

######## Fixed Parameters ############
#
ELF_DIR=./
READ_FILE=./bsp/makefile

#Error definitions
E_NOSUCHFILE=85

echo --- This is run.sh ---
echo input parameters: $INPUT_VARS

# process arguments
SOF_DIR=
TERMINAL=
while [ $# -gt 0 ]
do
  case "$1" in
      --terminal)
		 TERMINAL=1;; 
  esac
  shift
done

###### READ SOPC PATH ###### 
PATTERN[0]="SOPC_FILE" 			# Search this pattern

if [ ! -f "$READ_FILE" ]
then   # Exit if no such file.
  echo "File $READ_FILE not found."
  exit $E_NOSUCHFILE
fi

# Get SOPC path from bsp makefile
SOPC_PATH=$(grep "${PATTERN[0]} " ${READ_FILE} | cut -d ' ' -f 3 | cut -d '/' -f 2- | sed 's/\/niosII_openMac.sopcinfo//')

if [ ! -d "$SOPC_PATH" ]
then   # Exit if no such directory
  echo "Directory doesn't exist: $SOPC_PATH"
  exit $E_NOSUCHFILE
else
SOF_DIR="`pwd`/$SOPC_PATH"
echo "SOPC path  (from bsp makefile): "$SOF_DIR""
fi
############################

# get CPU instance number
UART_INSTANCE_ID=
#######################################
# read UART_INSTANCE_ID of CPU_NAME
# from JDI file
#######################################
CPU_NAME="pcp_cpu"
JDI_FILE=$SOF_DIR/nios_openMac.jdi
IN_FILE=$JDI_FILE

if [ ! -f "$IN_FILE" ]
then   # Exit if no such file.
  echo "File $IN_FILE not found."
  exit $E_NOSUCHFILE
fi

#check first if cpu name is present in file
pattern=$CPU_NAME 

match_count=$(grep -w -c "$pattern" ${IN_FILE})
if [ $match_count -eq 0 ]; then
    echo "match_count = ${match_count}"
	echo "ERROR: File ${IN_FILE} does not contain pattern '${pattern}'"
    exit 1
fi

# derive instance_id which corrensponds with CPU_NAME
UART_INSTANCE_ID=$(grep -w "hpath" ${IN_FILE} | grep ${CPU_NAME} | awk '{split($0,a,"instance_id="); print a[2]}' | awk '{split($0,a,""); print a[2]}')
echo "$CPU_NAME has INSTANCE: $UART_INSTANCE_ID"
echo
#######################################

#######################################
### Program the FPGA and run the SW ###
nios2-configure-sof -C ${SOF_DIR} --cable ${USB_CABLE}
nios2-download -C ${ELF_DIR} --cpu_name=${CPU_NAME} --instance ${UART_INSTANCE_ID} epl.elf --go --cable ${USB_CABLE}

# Open Terminal
if [ -z "$TERMINAL" ]
	then
		echo " "	
	else
	nios2-terminal --instance ${UART_INSTANCE_ID} --cable ${USB_CABLE}
fi	
#######################################

exit 0