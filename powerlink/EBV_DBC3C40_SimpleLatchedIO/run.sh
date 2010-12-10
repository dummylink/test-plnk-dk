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
#

######## Fixed Parameters ############
#
PCP_ELF_DIR=./
READ_FILE=./bsp/makefile
#

echo --- This is rebuild_SimpleLatchedIO ---
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

###### READ SOPC PATH ###### 
PATTERN[0]="SOPC_FILE" 			# Search this pattern

if [ ! -f "$READ_FILE" ]
then   # Exit if no such file.
  echo "File $READ_FILE not found."
  exit $E_NOSUCHFILE
fi

# Get SOPC path from bsp makefile
PCP_SOPC_PATH=$(grep "${PATTERN[0]} " ${READ_FILE} | cut -d ' ' -f 3 | cut -d '/' -f 2- | sed 's/\/niosII_openMac.sopcinfo//')

if [ ! -d "$PCP_SOPC_PATH" ]
then   # Exit if no such directory
  echo "Directory doesn't exist: $PCP_SOPC_PATH"
  exit $E_NOSUCHFILE
else
SOF_DIR="$PCP_SOPC_PATH"
echo "SOPC path  (of bsp makefile): "$SOF_DIR""
fi
############################

#######################################
### Program the FPGA and run the SW ###
nios2-configure-sof -C $SOF_DIR
nios2-download -C ${PCP_ELF_DIR} --device=1 --instance=0 --cpu_name=pcp_cpu epl.elf --go


# Open Terminal
if [ -z "$TERMINAL" ]
	then
		echo	
	else
	nios2-terminal -c USB-Blaster[USB-0]
fi
#######################################

exit 0