# TCL File Generated by Component Editor 10.1sp1
# Wed May 25 17:56:21 CEST 2011
# DO NOT MODIFY


# +-----------------------------------
# | 
# | sram "CY7C1041DV33-10BVXIT" v1.0
# | Joerg Zelenka (B&R 2010) 2011.05.25.17:56:21
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 10.1
# | 
package require -exact sopc 10.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module sram
# | 
set_module_property NAME sram
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP custom/memory
set_module_property AUTHOR "Michael Hogger (B&R 2010)"
set_module_property DISPLAY_NAME CY7C1041DV33-10BVXIT
set_module_property INSTANTIATE_IN_SYSTEM_MODULE false
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point s0
# | 
add_interface s0 avalon_tristate end
set_interface_property s0 activeCSThroughReadLatency false
set_interface_property s0 associatedClock clock
set_interface_property s0 explicitAddressSpan 0
set_interface_property s0 holdTime 0
set_interface_property s0 isMemoryDevice true
set_interface_property s0 isNonVolatileStorage false
set_interface_property s0 maximumPendingReadTransactions 0
set_interface_property s0 printableDevice false
set_interface_property s0 readLatency 0
set_interface_property s0 readWaitTime 1
set_interface_property s0 setupTime 0
set_interface_property s0 timingUnits Cycles
set_interface_property s0 writeWaitStates 1
set_interface_property s0 writeWaitTime 1

set_interface_property s0 ENABLED true

add_interface_port s0 addr address Input 18
add_interface_port s0 oe_n outputenable_n Input 1
add_interface_port s0 data data Bidir 16
add_interface_port s0 we_n write_n Input 1
add_interface_port s0 be_n byteenable_n Input 2
add_interface_port s0 ce_n chipselect_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock
# | 
add_interface clock clock end
set_interface_property clock clockRate 0

set_interface_property clock ENABLED true

add_interface_port clock clk clk Input 1
# | 
# +-----------------------------------