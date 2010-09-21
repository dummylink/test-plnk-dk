#!/bin/bash
###############################################################################
# This script runs the CN_DK dual-nios design
###############################################################################
# TODO: - copy this file to the PCP folder and adapt CN_DK_DIR
# TODO: - Power-Cycle the FPGA before using this script
###############################################################################

CN_DK_DIR=../..

SOFDIR=${CN_DK_DIR}/fpga/altera/EBV_DBC3C40/nios2_openmac_dpram_multinios
PCPDIR=./
APDIR=${CN_DK_DIR}/apps/EBV_DBC3C40_DigitalIO

#echo " "
#echo "Erase Serial Flash Memory..."
#echo " "
#nios2-flash-programmer --base=0x00 --epcs --erase-all --instance=1

echo " "
echo "Configure FPGA HW..."
echo " "

# Configure FPGA HW
nios2-configure-sof -C ${SOFDIR} 	

# download the AP software and start the AP
make -C ${APDIR}	  	
echo " "
echo "Download AP SW..."
echo " "
nios2-download -C ${APDIR} --device=1 --instance=0 --cpu_name=ap_cpu epl.elf --go

# download the PCP software and start the PCP
make -C ${PCPDIR}  		
echo " "
echo "Download PCP SW..."
echo " "
nios2-download -C ${PCPDIR} --device=1 --instance=1 --cpu_name=pcp_cpu epl.elf --go

echo " "
echo "Dual NIOS-II design has been uploaded."
echo "Power-Cycle the FPGA before next reprogramming!"
echo " "


exit 0

#EOF