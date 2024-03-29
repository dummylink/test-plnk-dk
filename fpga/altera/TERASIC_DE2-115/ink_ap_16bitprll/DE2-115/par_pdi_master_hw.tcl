# TCL File Generated by Component Editor 10.1sp1
# Tue Jun 26 10:47:29 CEST 2012
# DO NOT MODIFY


# +-----------------------------------
# | 
# | par_pdi_master "par_pdi_master" v1.0
# | Joerg Zelenka (B&R) 2012.06.26.10:47:29
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
# | module par_pdi_master
# | 
set_module_property NAME par_pdi_master
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR "Joerg Zelenka (B&R)"
set_module_property DISPLAY_NAME par_pdi_master
set_module_property INSTANTIATE_IN_SYSTEM_MODULE false
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
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
# | connection point avalon_tristate_slave
# | 
add_interface avalon_tristate_slave avalon_tristate end
set_interface_property avalon_tristate_slave activeCSThroughReadLatency false
set_interface_property avalon_tristate_slave associatedClock clock_sink
set_interface_property avalon_tristate_slave explicitAddressSpan 0
set_interface_property avalon_tristate_slave holdTime 40
set_interface_property avalon_tristate_slave isMemoryDevice false
set_interface_property avalon_tristate_slave isNonVolatileStorage false
set_interface_property avalon_tristate_slave maximumPendingReadTransactions 0
set_interface_property avalon_tristate_slave printableDevice false
set_interface_property avalon_tristate_slave readLatency 0
#set_interface_property avalon_tristate_slave readWaitTime 60
set_interface_property avalon_tristate_slave readWaitTime 120
set_interface_property avalon_tristate_slave setupTime 0
set_interface_property avalon_tristate_slave timingUnits Nanoseconds
#set_interface_property avalon_tristate_slave writeWaitTime 20
set_interface_property avalon_tristate_slave writeWaitTime 40

set_interface_property avalon_tristate_slave ENABLED true

add_interface_port avalon_tristate_slave csn chipselect_n Input 1
add_interface_port avalon_tristate_slave addr address Input 15
add_interface_port avalon_tristate_slave ben byteenable_n Input 2
add_interface_port avalon_tristate_slave data data Bidir 16
add_interface_port avalon_tristate_slave rdn read_n Input 1
add_interface_port avalon_tristate_slave wrn write_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_sink
# | 
add_interface clock_sink clock end
set_interface_property clock_sink clockRate 0

set_interface_property clock_sink ENABLED true
# | 
# +-----------------------------------
