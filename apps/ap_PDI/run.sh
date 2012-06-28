#!/bin/bash
###############################################################################
# This script makes and runs the digital I/O application of this directory.
###############################################################################

###############################################################################
#
#
. "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash"

######## Input Parameters ############
#
INPUT_VARS=$@

## Change this in case of a dual processor design and two fpga's
USB_CABLE=USB-Blaster[USB-0]
PROC_INSTANCE=0
#

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
	  --sopcdir)
		 shift
		 #relative path!
		 SOF_DIR=$1
		 echo SOF_DIR set to \"$SOF_DIR\"
		 echo -------------------------------;;
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
nios2-download -C ${AP_ELF_DIR} --device=1 --instance=${PROC_INSTANCE} --cpu_name=ap_cpu epl.elf --go --cable ${USB_CABLE}

# Open Terminal
if [ -z "$TERMINAL" ]
	then
		echo	
	else
	nios2-terminal -c ${USB_CABLE} --instance ${PROC_INSTANCE}
fi
#######################################

exit 0