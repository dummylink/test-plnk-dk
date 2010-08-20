#------------------------------------------------------------------------------------------------------------------------
#-- Simple I/O Process Data Interface
#--
#-- 	  Copyright (C) 2010 B&R
#--
#--    Redistribution and use in source and binary forms, with or without
#--    modification, are permitted provided that the following conditions
#--    are met:
#--
#--    1. Redistributions of source code must retain the above copyright
#--       notice, this list of conditions and the following disclaimer.
#--
#--    2. Redistributions in binary form must reproduce the above copyright
#--       notice, this list of conditions and the following disclaimer in the
#--       documentation and/or other materials provided with the distribution.
#--
#--    3. Neither the name of B&R nor the names of its
#--       contributors may be used to endorse or promote products derived
#--       from this software without prior written permission. For written
#--       permission, please contact office@br-automation.com
#--
#--    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#--    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#--    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#--    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#--    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#--    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#--    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#--    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#--    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#--    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#--    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#--    POSSIBILITY OF SUCH DAMAGE.
#--
#------------------------------------------------------------------------------------------------------------------------
#-- Version History
#------------------------------------------------------------------------------------------------------------------------
#-- 2010-08-20  V0.01	zelenkaj    First version
#------------------------------------------------------------------------------------------------------------------------


package require -exact sopc 10.0
set_module_property DESCRIPTION "32bit I/O Ports for POWERLINK Slave"
set_module_property NAME portio
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property GROUP POWERLINK/PDI
set_module_property AUTHOR "Joerg Zelenka (B&R 2010)"
set_module_property DISPLAY_NAME "Simple PDI I/O PORT"
set_module_property TOP_LEVEL_HDL_FILE portio/portio.vhd
set_module_property TOP_LEVEL_HDL_MODULE portio
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL AUTO
set_module_property ICON_PATH br.png

#files
add_file portio/portio.vhd {SYNTHESIS SIMULATION}

#display
add_display_item "Block Diagram" id0 icon portio/portio.png

#Avalon Memory Mapped Slave: s0
add_interface s0 avalon end
set_interface_property s0 addressAlignment DYNAMIC
set_interface_property s0 associatedClock clock
set_interface_property s0 burstOnBurstBoundariesOnly false
set_interface_property s0 explicitAddressSpan 0
set_interface_property s0 holdTime 0
set_interface_property s0 isMemoryDevice false
set_interface_property s0 isNonVolatileStorage false
set_interface_property s0 linewrapBursts false
set_interface_property s0 maximumPendingReadTransactions 0
set_interface_property s0 printableDevice false
set_interface_property s0 readLatency 0
set_interface_property s0 readWaitTime 1
set_interface_property s0 setupTime 0
set_interface_property s0 timingUnits Cycles
set_interface_property s0 writeWaitTime 0
set_interface_property s0 ASSOCIATED_CLOCK clock
set_interface_property s0 ENABLED true
add_interface_port s0 s0_address address Input 1
add_interface_port s0 s0_read read Input 1
add_interface_port s0 s0_readdata readdata Output 32
add_interface_port s0 s0_write write Input 1
add_interface_port s0 s0_writedata writedata Input 32
add_interface_port s0 s0_byteenable byteenable Input 4

#Clock Sink
add_interface clock clock end
set_interface_property clock ENABLED true
add_interface_port clock clk clk Input 1
add_interface_port clock reset reset Input 1

#export
add_interface portio conduit end
set_interface_property portio ENABLED true
add_interface_port portio x_pconfig export Input 4
add_interface_port portio x_portInLatch export Input 4
add_interface_port portio x_portOutValid export Output 4
add_interface_port portio x_portio export Bidir 32
