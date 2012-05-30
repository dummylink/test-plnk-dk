#!/bin/bash
###############################################################################
# This script creates the Simple Latched IO application in this directory.
###############################################################################

###############################################################################
#
#
. "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash"

INPUT_VARS=$@

echo --- This is rebuild_SimpleLatchedIO.sh ---
echo input parameters: $INPUT_VARS

# process arguments
#SOPC_DIR = ../../fpga/altera/EBV_DBC3C40/nios2_openmac_SimpleLatchedIO/
#SOPC_DIR=../../fpga/altera/TERASIC_DE2-115/nios2_openmac_SimpleLatchedIO
SOPC_DIR=
while [ $# -gt 0 ]
do
  case "$1" in
	  --sopcdir)
		 shift
		 #relative path!
		 SOPC_DIR=$1
		 echo SOPC_DIR set to \"$SOPC_DIR\"
		 echo ------------------------------------------
		 ;;		  
  esac
  shift
done

if [ -z "$SOPC_DIR" ]; then
echo "No SOPC directory specified !"
echo "Use parameter: --sopcdir <SOPC_directory>"
exit 1
fi


#######################################
###        Rebuild the SW           ###
./create-this-app --sopcdir $SOPC_DIR --rebuild 

exit 0