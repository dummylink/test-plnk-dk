#!/bin/bash
###############################################################################
# This script creates the application in the current directory.
# It invokes create-this-app.
###############################################################################

###############################################################################
#
#
. "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash"

### SET USER PATHS ###
PCP_BSP_DIR=../../powerlink/EBV_DBC3C40_DPRAM

# TODO: ideally the one saved in a file from the last build of PCP.
PCP_SOPC_DIR=../../fpga/altera/EBV_DBC3C40/nios2_openmac_SPI_multinios


### INPUT ARGUMENTS ###
INPUT_VARS=$@

echo --- This is rebuild.sh ---
echo input parameters: $INPUT_VARS

# process arguments
SKIP_MAKE=
REBUILD=
NO_OPT=
SOPC_DIR=
while [ $# -gt 0 ]
do
  case "$1" in
      # Don't run make if create-this-app script is called with --no-make arg
      --no-make)
          SKIP_MAKE=1
          ;;
      --rebuild)
          rm -f ./Makefile
          REBUILD=1
          ;;
      --debug)
          NO_OPT=1
          ;;
	  --sopcdir)
		 shift
		 #relative path!
		 SOPC_DIR=$1
		 echo SOPC_DIR set to \"$SOPC_DIR\"
		 echo -------------------------------
		 ;;		  
  esac
  shift
done

if [ -z "$SOPC_DIR" ]; then
echo "No SOPC directory specified !"
echo "Use parameter: --sopcdir <SOPC_directory>"
exit 1
fi

# user input - chose between debug and release
a=
while [ -z "$a" ]; do
	echo -n "Select between debug[1] or release[2]: "
	read a
	a=${a##*[^1-2]*} #eliminate other characters then 1 or 2
if [ -z "$a" ]; then
	echo Invalid input!
fi	
done

if [ "$a" == 1 ]; then
	DEBUG_FLAG="--debug"
else
	DEBUG_FLAG=
fi

#######################################
###        Rebuild the SW           ###

# first, rebuild BSP of PCP, because the CN API library needs pcp system.h - TODO: maybe use create-this-app instead in order to rebuild also the PCP.
#if [ -a "$PCP_BSP_DIR/create-this-app" ]; then
#    pushd $PCP_BSP_DIR >> /dev/null
#	echo -e "\ncreate-this-app of PCP (API library needs it) ...\n"	
#    ./do-not-create-this-app --rebuild --sopcdir $PCP_SOPC_DIR --cpu-name pcp_cpu  || {
#    	echo "create-this-app of PCP failed"
#    	exit 1
#    }
#    popd >> /dev/null
#	echo -e "\ncreate-this-app of PCP done!\n"
#else
#	echo "create-this-app of PCP doesn't exist at \"$PCP_BSP_DIR\" !"
#	exit 1
#fi

# rebuild library and application for AP
./create-this-app --sopcdir $SOPC_DIR --rebuild ${DEBUG_FLAG}

#######################################

exit 0