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

#SOF_DIR is not needed in this script - SOF programming is done with PCP "run.sh"
#if [ -z "$SOF_DIR" ]; then
#echo "No SOPC directory specified (needed for sof-file) !"
#echo "Use parameter: --sopcdir <SOF_directory>"
#exit 1
#fi



#######################################
### Run the SW 						###
nios2-download -C ${PCP_ELF_DIR} --device=1 --instance=0 --cpu_name=ap_cpu epl.elf --go


# Open Terminal
if [ -z "$TERMINAL" ]
	then
		echo	
	else
	nios2-terminal -c USB-Blaster[USB-0] --instance 0
fi
#######################################

exit 0