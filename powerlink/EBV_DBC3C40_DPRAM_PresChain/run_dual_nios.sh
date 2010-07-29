#!/bin/bash
###############################################################################
# This script runs the CN_DK dual-nios design
###############################################################################
# TODO: copy this file to the PCP folder and adapt CN_DK_DIR
###############################################################################

CN_DK_DIR=../..

SOFDIR=${CN_DK_DIR}/fpga/altera/EBV_DBC3C40/nios2_openmac_dpram_multinios
PCPDIR=./
APDIR=${CN_DK_DIR}/apps/EBV_DBC3C40_DigitalIO

nios2-configure-sof -C ${SOFDIR} 	# Configure FPGA HW

# This sequence is mandatory! 1st PCP, then AP
make download-elf -C ${PCPDIR}  	# download the PCP software and start the PCP
make download-elf -C ${APDIR}	  	# download the AP software and start the AP

echo " "
echo "Dual NIOS-II design has been uploaded."
echo "FPGA HW and SW configured."
echo " "
echo "If you see 00 on the 7-Seg numbers and nothing happens,"
echo "try 'nios2-configure-sof' after power cycle manually several times!"

exit 0

#EOF