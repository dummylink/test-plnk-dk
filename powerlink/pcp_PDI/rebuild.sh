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
	DEBUG_FLAG="--debug 1"
      ;;
  2)
	DEBUG_FLAG="--debug 2"
      ;;
  3)
	DEBUG_FLAG=
      ;; 
  *)
    exit 1
      ;;
esac   

echo "rebuild.sh: Started"

#######################################
###    Rebuild the FPGA config      ###
CURPATH=`pwd`
ENHANCED_EPCS_BOOTLOADER=${CURPATH}/../../fpga/altera/addons/epcs_flash_controller_ipcore/epcs_flash_controller_0_boot_rom_synth.hex

if [ -f ${ENHANCED_EPCS_BOOTLOADER} ]; then
  echo "rebuild.sh: Replace default epcs_bootloader with ${ENHANCED_EPCS_BOOTLOADER}"
else
  echo "Error: ${ENHANCED_EPCS_BOOTLOADER} not preset!"
  exit 1
fi

# Overwrite default altera epcs bootloader with enhanced boot loader which is 
# capable to load the NIOS II SW of a firmware image stored at a different
# offset then the epcs base offset (0).
# Note: The bootloader requires the remote-update core to be located at  a fixed
#       base address 0x800 because it reads the reset address from the remote
#       update core.
cp ${ENHANCED_EPCS_BOOTLOADER} ${SOPC_DIR}

# Recompile the Quartus generated sof file again with the enhanced epcs bootloader
cmd="quartus_cdb ${SOPC_DIR}/nios_openMac -c ${SOPC_DIR}/nios_openMac --update_mif"
$cmd || {
    echo -e "rebuild.sh: failed!"
    exit 1
}

cmd="quartus_asm --read_settings_files=on --write_settings_files=off ${SOPC_DIR}/nios_openMac -c ${SOPC_DIR}/nios_openMac"
$cmd || {
    echo -e "rebuild.sh: failed!"
    exit 1
}

#######################################
###        Rebuild the SW           ###

# add search path to modified altera drivers for BSP

# save path
CURPATH=$PWD
MOD_DRIVER_PATH=${CURPATH}/../../fpga/altera/driver

if [ ! -d ${MOD_DRIVER_PATH} ]; then
  echo "Error: ${MOD_DRIVER_PATH} not present!"
  exit 1
fi

# change path for execution of cmd
cd $SOPC_DIR

cmd="ip-make-ipx --source-directory=${MOD_DRIVER_PATH} --thorough-descent=true"
echo "rebuild.sh: Running \"$cmd\""
$cmd || {
    echo -e "rebuild.sh: failed!"
    exit 1
}

# restore path
cd $CURPATH

if [ -f ${SOPC_DIR}/components.ipx ]; then
  echo "rebuild.sh: $PWD/${SOPC_DIR}/components.ipx generated."
else
  echo "Error: $PWD/${SOPC_DIR}/components.ipx generation failed!"
  exit 1
fi

# rebuild sw
cmd="./create-this-app --sopcdir $SOPC_DIR --rebuild ${DEBUG_FLAG}"
echo "rebuild.sh: Running \"$cmd\""
$cmd || {
    echo -e "create-this-app failed!\nVerify openPOWERLINK stack path setting in 'project.config'!"
    exit 1
}

# Generate cnApiLib.h in order to inform the LIB about the PCP HW
./cfglib.sh

echo -e "You also need to rebuild the API Library and your application\nin order to apply changes!\nDo so by executing ../../apps/rebuild.bat!\n"

exit 0