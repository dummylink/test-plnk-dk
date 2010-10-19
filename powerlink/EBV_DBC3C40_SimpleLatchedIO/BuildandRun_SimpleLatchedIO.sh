#!/bin/bash
###############################################################################
# This script creates the digital I/O application in this directory.
###############################################################################

###############################################################################
#
#
. "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash"

#SOPC_DIR = ../../fpga/altera/EBV_DBC3C40/nios2_openmac_SimpleLatchedIO/
SOPC_DIR=../../fpga/altera/TERASIC_DE2-115/nios2_openmac_SimpleLatchedIO

# 
./create-this-app --sopcdir $SOPC_DIR --rebuild 
nios2-configure-sof -C $SOPC_DIR
make download-elf
# nios2-download de2_115_audio.elf -c USB-Blaster[USB-0] -r -g
nios2-terminal -c USB-Blaster[USB-0]



exit 0