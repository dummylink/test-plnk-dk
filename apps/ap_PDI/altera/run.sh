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
AP_ELF_DIR=./
READ_FILE_AP=./bsp/makefile
READ_FILE_PCP=../../powerlink/pcp_PDI/bsp/makefile

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

###### READ SOPC PATH of AP ###### 
PATTERN[0]="SOPC_FILE" 			# Search this pattern

if [ ! -f "$READ_FILE_AP" ]
then   # Exit if no such file.
  echo "File $READ_FILE_AP not found."
  exit $E_NOSUCHFILE
fi

# Get SOPC path from bsp makefile
AP_SOPC_PATH=$(grep "${PATTERN[0]} " ${READ_FILE_AP} | cut -d ' ' -f 3 | cut -d '/' -f 2- | sed 's/\/niosII_openMac.sopcinfo//')

if [ ! -d "$AP_SOPC_PATH" ]
then   # Exit if no such directory
  echo "Directory doesn't exist: $AP_SOPC_PATH"
  exit $E_NOSUCHFILE
else
SOF_DIR="$AP_SOPC_PATH"
echo "SOPC path (of AP bsp makefile): "$SOF_DIR""
fi
##################################

###### READ SOPC PATH of PCP ###### 
PATTERN[0]="SOPC_FILE" 			# Search this pattern

if [ ! -f "$READ_FILE_PCP" ]
then   # Exit if no such file.
  echo "INFO: File $READ_FILE_PCP not found. So AP HW will be downloaded to FPGA."
else
# Get SOPC path from bsp makefile
PCP_SOPC_PATH=$(grep "${PATTERN[0]} " ${READ_FILE_PCP} | cut -d ' ' -f 3 | cut -d '/' -f 2- | sed 's/\/niosII_openMac.sopcinfo//')
	if [ ! -d "$PCP_SOPC_PATH" ]
		then   # Exit if no such directory
		echo "Directory doesn't exist: $PCP_SOPC_PATH"
		exit $E_NOSUCHFILE
	else
	PCP_SOF_DIR="$PCP_SOPC_PATH"
	echo "SOPC path (of PCP bsp makefile): "$PCP_SOF_DIR""
	fi
fi
##################################

# get CPU instance number
UART_INSTANCE_ID=
#######################################
# read UART_INSTANCE_ID of CPU_NAME
# from JDI file
#######################################
CPU_NAME="ap_cpu"
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

###### CHECK if AP HW needs to be programmed ######
# check if PCP SOPC directory = AP SOPC directory => AP and PCP are in the same FPGA
if [ "$AP_SOPC_PATH" == "$PCP_SOPC_PATH" ]
then
	echo -e "\nINFO: FPGA HW should already be present (programmed with PCP 'run.bat').\nINFO: Only SW will be downloaded.\n"
else #program FPGA HW
	nios2-configure-sof -C $SOF_DIR --cable ${USB_CABLE}
fi	
##################################

#######################################
### Program the FPGA and run the SW ###
nios2-download -C ${AP_ELF_DIR} --cpu_name=${CPU_NAME} --instance ${UART_INSTANCE_ID} epl.elf --go --cable ${USB_CABLE}

# Open Terminal
if [ -z "$TERMINAL" ]
	then
		echo	
	else
    nios2-terminal --instance ${UART_INSTANCE_ID} --cable ${USB_CABLE}	
fi
#######################################

exit 0