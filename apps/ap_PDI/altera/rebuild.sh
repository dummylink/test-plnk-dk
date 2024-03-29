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

# check if FPGA design contains also PCP
UART_INSTANCE_ID=
ASK_FOR_QUARTUS_REBUILD=0
#######################################
# read UART_INSTANCE_ID of CPU_NAME
# from JDI file
#######################################
CPU_NAME="pcp_cpu"
JDI_FILE=$SOPC_DIR/nios_openMac.jdi
IN_FILE=$JDI_FILE

# check if *.sof was build
SOF_CNT=$(ls ${SOPC_DIR} | grep ".sof" -c)
if [ $SOF_CNT -eq 0 ]
then
   ASK_FOR_QUARTUS_REBUILD=1
fi

# check if cpu name is present in file
pattern=$CPU_NAME 

match_count=$(grep -w -c "$pattern" ${IN_FILE})
if [ $match_count -eq 0 ]; then
   ASK_FOR_QUARTUS_REBUILD=1
fi

if [ $ASK_FOR_QUARTUS_REBUILD -eq 1 ]; then
    # user input - Quartus rebuild option
    a=
    while [ -z "$a" ]; do
        echo  -n "Would you like to rebuild the Quartus project (y/n)? "
        read a
        a=${a##*[^'y' 'n']*} #eliminate other characters then y and n 
    if [ -z "$a" ]; then
        echo Invalid input!
    fi	
    done

    case "$a" in
      'y')
        pushd $SOPC_DIR >> /dev/null #change directory
        cmd="./make.sh"              # rebuild Quartus project
        $cmd || {
            echo -e "ERROR: Quartus rebuild failed!"
            exit 1
        }      
        popd >> /dev/null           # restore PWD
        ;;
      'n')
        ;;
      *)
        exit 1
        ;;
    esac 
fi

# user input - chose between debug and release
echo; echo    "Software rebuild options:"
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