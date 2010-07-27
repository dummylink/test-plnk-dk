# TCL File Generated by Component Editor 9.1sp2
# Mon May 03 18:17:01 CEST 2010
# DO NOT MODIFY


# +-----------------------------------
# | 
# | OpenMAC "OpenMAC" v1.1
# | null 2010.05.03.18:17:01
# | 
# | 
# | C:/vhdl/altera/DBC3C40/OptmizedV16/EPL/OpenMAC_AvalonIF.vhd
# | 
# |    ./OpenFILTER.vhd syn, sim
# |    ./OpenHUB.vhd syn, sim
# |    ./OpenMAC.vhd syn, sim
# |    ./OpenMAC_AvalonIF.vhd syn, sim
# |    ./OpenMAC_DPR_Altera.vhd syn, sim
# |    ./OpenMAC_PHYMI.vhd syn, sim
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module OpenMAC
# | 
set_module_property NAME OpenMAC
set_module_property VERSION 1.1
set_module_property INTERNAL false
set_module_property GROUP "POWERLINK/MAC"
set_module_property DISPLAY_NAME OpenMAC
set_module_property TOP_LEVEL_HDL_FILE OpenMAC_AvalonIF.vhd
set_module_property TOP_LEVEL_HDL_MODULE AlteraOpenMACIF
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file OpenFILTER.vhd {SYNTHESIS SIMULATION}
add_file OpenHUB.vhd {SYNTHESIS SIMULATION}
add_file OpenMAC.vhd {SYNTHESIS SIMULATION}
add_file OpenMAC_AvalonIF.vhd {SYNTHESIS SIMULATION}
add_file OpenMAC_DPR_Altera.vhd {SYNTHESIS SIMULATION}
add_file OpenMAC_PHYMI.vhd {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter Simulate BOOLEAN false
set_parameter_property Simulate DEFAULT_VALUE false
set_parameter_property Simulate DISPLAY_NAME Simulate
set_parameter_property Simulate UNITS None
set_parameter_property Simulate DISPLAY_HINT ""
set_parameter_property Simulate AFFECTS_GENERATION false
set_parameter_property Simulate HDL_PARAMETER true
add_parameter pBfSizeLOG2_g INTEGER 11
set_parameter_property pBfSizeLOG2_g DEFAULT_VALUE 11
set_parameter_property pBfSizeLOG2_g DISPLAY_NAME pBfSizeLOG2_g
set_parameter_property pBfSizeLOG2_g UNITS None
set_parameter_property pBfSizeLOG2_g ALLOWED_RANGES -2147483648:2147483647
set_parameter_property pBfSizeLOG2_g DISPLAY_HINT ""
set_parameter_property pBfSizeLOG2_g AFFECTS_GENERATION false
set_parameter_property pBfSizeLOG2_g HDL_PARAMETER true
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point CMP
# | 
add_interface CMP avalon end
set_interface_property CMP addressAlignment DYNAMIC
set_interface_property CMP associatedClock clock_sink
set_interface_property CMP burstOnBurstBoundariesOnly false
set_interface_property CMP explicitAddressSpan 0
set_interface_property CMP holdTime 0
set_interface_property CMP isMemoryDevice false
set_interface_property CMP isNonVolatileStorage false
set_interface_property CMP linewrapBursts false
set_interface_property CMP maximumPendingReadTransactions 0
set_interface_property CMP printableDevice false
set_interface_property CMP readLatency 0
set_interface_property CMP readWaitTime 1
set_interface_property CMP setupTime 0
set_interface_property CMP timingUnits Cycles
set_interface_property CMP writeWaitTime 0

set_interface_property CMP ASSOCIATED_CLOCK clock_sink
set_interface_property CMP ENABLED true

add_interface_port CMP t_read_n read_n Input 1
add_interface_port CMP t_write_n write_n Input 1
add_interface_port CMP t_byteenable_n byteenable_n Input 4
add_interface_port CMP t_address address Input 1
add_interface_port CMP t_writedata writedata Input 32
add_interface_port CMP t_readdata readdata Output 32
add_interface_port CMP t_chipselect chipselect Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point CMP_IRQ
# | 
add_interface CMP_IRQ interrupt end
set_interface_property CMP_IRQ associatedAddressablePoint CMP

set_interface_property CMP_IRQ ASSOCIATED_CLOCK clock_sink
set_interface_property CMP_IRQ ENABLED true

add_interface_port CMP_IRQ t_IRQ irq Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point REG
# | 
add_interface REG avalon end
set_interface_property REG addressAlignment DYNAMIC
set_interface_property REG associatedClock clock_sink
set_interface_property REG burstOnBurstBoundariesOnly false
set_interface_property REG explicitAddressSpan 0
set_interface_property REG holdTime 0
set_interface_property REG isMemoryDevice false
set_interface_property REG isNonVolatileStorage false
set_interface_property REG linewrapBursts false
set_interface_property REG maximumPendingReadTransactions 0
set_interface_property REG printableDevice false
set_interface_property REG readLatency 0
set_interface_property REG readWaitTime 1
set_interface_property REG setupTime 0
set_interface_property REG timingUnits Cycles
set_interface_property REG writeWaitTime 0

set_interface_property REG ASSOCIATED_CLOCK clock_sink
set_interface_property REG ENABLED true

add_interface_port REG s_chipselect chipselect Input 1
add_interface_port REG s_read_n read_n Input 1
add_interface_port REG s_write_n write_n Input 1
add_interface_port REG s_byteenable_n byteenable_n Input 2
add_interface_port REG s_address address Input 12
add_interface_port REG s_writedata writedata Input 16
add_interface_port REG s_readdata readdata Output 16
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_sink
# | 
add_interface clock_sink clock end

set_interface_property clock_sink ENABLED true

add_interface_port clock_sink Clk50 clk Input 1
add_interface_port clock_sink Reset_n reset_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point MAC_IRQ
# | 
add_interface MAC_IRQ interrupt end
set_interface_property MAC_IRQ associatedAddressablePoint REG

set_interface_property MAC_IRQ ASSOCIATED_CLOCK clock_sink
set_interface_property MAC_IRQ ENABLED true

add_interface_port MAC_IRQ s_IRQ irq Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point RMII0
# | 
add_interface RMII0 conduit end

set_interface_property RMII0 ENABLED true

add_interface_port RMII0 rRx_Dat_0 export Input 2
add_interface_port RMII0 rCrs_Dv_0 export Input 1
add_interface_port RMII0 rTx_Dat_0 export Output 2
add_interface_port RMII0 rTx_En_0 export Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point RMII1
# | 
add_interface RMII1 conduit end

set_interface_property RMII1 ENABLED true

add_interface_port RMII1 rRx_Dat_1 export Input 2
add_interface_port RMII1 rCrs_Dv_1 export Input 1
add_interface_port RMII1 rTx_Dat_1 export Output 2
add_interface_port RMII1 rTx_En_1 export Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point mii
# | 
add_interface mii conduit end

set_interface_property mii ENABLED true

add_interface_port mii mii_Clk export Output 1
add_interface_port mii mii_Di export Input 1
add_interface_port mii mii_Do export Output 1
add_interface_port mii mii_Doe export Output 1
add_interface_port mii mii_nResetOut export Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point iBuf
# | 
add_interface iBuf avalon end
set_interface_property iBuf addressAlignment DYNAMIC
set_interface_property iBuf associatedClock clock_sink_1
set_interface_property iBuf burstOnBurstBoundariesOnly false
set_interface_property iBuf explicitAddressSpan 0
set_interface_property iBuf holdTime 0
set_interface_property iBuf isMemoryDevice false
set_interface_property iBuf isNonVolatileStorage false
set_interface_property iBuf linewrapBursts false
set_interface_property iBuf maximumPendingReadTransactions 0
set_interface_property iBuf printableDevice false
set_interface_property iBuf readLatency 0
set_interface_property iBuf readWaitStates 2
set_interface_property iBuf readWaitTime 2
set_interface_property iBuf setupTime 0
set_interface_property iBuf timingUnits Cycles
set_interface_property iBuf writeWaitTime 0

set_interface_property iBuf ASSOCIATED_CLOCK clock_sink_1
set_interface_property iBuf ENABLED true

add_interface_port iBuf iBuf_chipselect chipselect Input 1
add_interface_port iBuf iBuf_read_n read_n Input 1
add_interface_port iBuf iBuf_write_n write_n Input 1
add_interface_port iBuf iBuf_byteenable byteenable Input 4
add_interface_port iBuf iBuf_address address Input "(pbfsizelog2_g-3) - (0) + 1"
add_interface_port iBuf iBuf_writedata writedata Input 32
add_interface_port iBuf iBuf_readdata readdata Output 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_sink_1
# | 
add_interface clock_sink_1 clock end

set_interface_property clock_sink_1 ENABLED true

add_interface_port clock_sink_1 ClkFaster clk Input 1
# | 
# +-----------------------------------
