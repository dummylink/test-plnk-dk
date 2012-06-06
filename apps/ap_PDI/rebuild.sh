#!/bin/bash
###############################################################################
# This script creates the application in the current directory.
# It invokes create-this-app.
###############################################################################

###############################################################################
#
#
. "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash"

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
    echo    "Select between [1] debug"
    echo    "               [2] debug with reduced printouts"
    echo -n "               [3] or release :"    
	read a
	a=${a##*[^1-3]*} #eliminate other characters then [1 .. 3]
    
if [ -z "$a" ]; then
	echo Invalid input!
fi	
done

case "$a" in
  # Don't run make if create-this-app script is called with --no-make arg
  1)
	DEBUG_FLAG="--debug --debug_lvl 1"
      ;;
  2)
	DEBUG_FLAG="--debug --debug_lvl 2"
      ;;
  3)
	DEBUG_FLAG=
      ;; 
  *)
    exit 1
      ;;
esac  

#######################################
###        Rebuild the SW           ###

# rebuild library and application for AP
./create-this-app --sopcdir $SOPC_DIR --rebuild ${DEBUG_FLAG}

#######################################

exit 0