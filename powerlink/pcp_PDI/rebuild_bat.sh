#!/bin/sh
# SDK Shell Batch File for POWERLINK CNDK Build Targets
#--------------------------------------------------------
# - Invokes bash, recompiles the BSP and application
#

###############################################################################
# functions to set correct parameters

EBV_PCP_AP_avalon()
{
    export SOPC_DIR="../../fpga/altera/EBV_DBC3C40/ebv_ap_pcp_intavalon"
    export DUAL_NIOS="1"
}


EBV_PCP_AP_SPI()
{
    export SOPC_DIR="../../fpga/altera/EBV_DBC3C40/ebv_ap_pcp_SPI"
    export DUAL_NIOS="1"
}

EBV_PCP_SPI()
{
    export SOPC_DIR="../../fpga/altera/EBV_DBC3C40/ebv_pcp_SPI"
}


EBV_PCP_16bitparallel()
{
    export SOPC_DIR="../../fpga/altera/EBV_DBC3C40/ebv_pcp_16bitprll"
}

INK_PCP_AP_avalon()
{
    export SOPC_DIR="../../fpga/altera/TERASIC_DE2-115/ink_ap_pcp_intavalon"
    export DUAL_NIOS="1"
}

INK_PCP_AP_SPI()
{
    export SOPC_DIR="../../fpga/altera/TERASIC_DE2-115/ink_ap_pcp_SPI"
    export DUAL_NIOS="1"
}

INK_PCP_SPI()
{
    export SOPC_DIR="../../fpga/altera/TERASIC_DE2-115/ink_pcp_SPI"
}

INK_PCP_16bitparallel()
{
    export SOPC_DIR="../../fpga/altera/TERASIC_DE2-115/ink_pcp_16bitprll"
}

ECU_PCP_SPI()
{
    export SOPC_DIR="../../fpga/altera/SYSTEC_ECUcore-EP3C/systec_pcp_SPI"
}

###############################################################################
# functions to print errors
errorQ()
{
    echo
    echo "Cannot locate Quartus installation (QUARTUS_ROOTDIR) at:"
    echo "  $QUARTUS_ROOTDIR"
    echo
    echo " Please check your paths and try again (running Quartus from"
    echo " the Start Menu may update the paths and fix this problem)."
    echo " Your Quartus II installation may need to be repaired."
    echo 
}

errorN()
{
    echo 
    echo " Cannot locate Nios II Development Kit (SOPC_KIT_NIOS2) at:"
    echo "  $SOPC_KIT_NIOS2"
    echo "  (specifically, the nios2_sdk_shell_bashrc file within)"
    echo 
    echo " Your Nios II installation may need to be repaired."
    echo 
}

errorSOPC()
{
    echo
    echo " Cannot locate SOPC directory (SOPC_DIR) at:"
    echo "    $SOPC_DIR"
    echo "    (setting in rebuild_bat.sh)"
    echo
    echo " Switch to existing path where the sopcinfo-file resides!"
    echo
}


###############################################################################
#
#

echo  "===================================================="
echo  "Rebuild POWERLINK Communication Processor PDI Menu"
echo  "===================================================="
echo  "Choose your desired PCP interface demo:"
echo
echo  "PCP including an additional NIOS II as AP (in one FPGA)"
echo  "-----------------------------------------------"
echo  "  Mercury Board (EBV DBC3C40)"
echo  "    1: Avalon"
echo  "    2: SPI"
echo  "  INK Board (TERASIC DE2-115)"
echo  "    3: Avalon"
echo  "    4: SPI"
echo 
echo  "Stand alone PCP with FPGA external MCU interface"
echo  "-----------------------------------------------"
echo  "  Mercury Board (EBV DBC3C40)"
echo  "    5: SPI"
echo  "    6: 16 Bit parallel"
echo  "  INK Board (TERASIC DE2-115)"
echo  "    7: SPI"
echo  "    8: 16 Bit parallel"
echo
echo  "=================================================="

echo  "Enter design number [1-8] > "

read choice

if [ "$choice" = "1" ]; then
    EBV_PCP_AP_avalon
elif [ "$choice" = "2" ]; then
    EBV_PCP_AP_SPI
elif [ "$choice" = "3" ]; then
    INK_PCP_AP_avalon
elif [ "$choice" = "4" ]; then
    INK_PCP_AP_SPI
elif [ "$choice" = "5" ]; then
    EBV_PCP_SPI
elif [ "$choice" = "6" ]; then
    EBV_PCP_16bitparallel
elif [ "$choice" == "7" ]; then
    INK_PCP_SPI
elif [ "$choice" == "8" ]; then
    INK_PCP_16bitparallel
elif [ "$choice" == "9" ]; then
    ECU_PCP_SPI
else
    echo "Invalid Input"
    exit
fi

######################################
# set root quartus directory to
# QUARTUS_ROOTDIR_OVERRIDE if the
# env var is set
if [ ! "$QUARTUS_ROOTDIR_OVERRIDE" = "" ]; then
    export QUARTUS_ROOTDIR=$QUARTUS_ROOTDIR_OVERRIDE
fi

######################################
# Run qreg (if it exists) to setup
# cygwin and jtag services
if [ -f ${QUARTUS_ROOTDIR}/bin/qreg ]; then
    ${QUARTUS_ROOTDIR}/bin/qreg
    ${QUARTUS_ROOTDIR}/bin/qreg --jtag
else
    errorQ
    exit
fi

######################################
# Discover the root nios2eds directory
export SOPC_KIT_NIOS2=${QUARTUS_ROOTDIR}/../nios2eds
export SOPC_BUILDER_PATH_101=${SOPC_KIT_NIOS2}+${SOPC_BUILDER_PATH_101}

if [ ! -f ${SOPC_KIT_NIOS2}/nios2_sdk_shell_bashrc ]; then
    errorN
fi

echo "verifying path...: ${SOPC_DIR}"
if [ ! -d ${SOPC_DIR} ]; then
    errorSOPC
fi

echo "verifying path...OK"

# execute "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash" in every bash.exe call !
. ./rebuild.sh --sopcdir $SOPC_DIR



