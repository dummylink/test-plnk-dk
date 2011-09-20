#!/bin/bash
###############################################################################
# This script creates the application in the current directory.
# It invokes create-this-app.
###############################################################################

###############################################################################
#
#
. "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash"

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
cmd="./create-this-app --sopcdir $SOPC_DIR --rebuild ${DEBUG_FLAG}"
echo "rebuild.sh: Running \"$cmd\""
$cmd || {
    echo -e "\ncreate-this-app failed!\nVerify openPOWERLINK stack path setting in 'project.config'!\n"
    exit 1
}

# Generate cnApiLib.h in order to inform the LIB about the PCP HW
./cfglib.sh

echo -e "You also need to rebuild the API Library and your application\nin order to apply changes!\nDo so by executing ../../apps/rebuild.bat!\n"

exit 0