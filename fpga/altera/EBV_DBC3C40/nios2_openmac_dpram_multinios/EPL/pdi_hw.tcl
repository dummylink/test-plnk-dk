#------------------------------------------------------------------------------------------------------------------------
#-- Process Data Interface (PDI) for
#--	POWERLINK Communication Processor (PCP): Avalon
#--	Application Processor (AP): Avalon
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
#-- 2010-06-28  V0.01	zelenkaj    First version
#-- 2010-08-16  V0.10	zelenkaj	Added the possibility for more RPDOs and better configuration in SOPC
#------------------------------------------------------------------------------------------------------------------------

package require -exact sopc 10.0

set_module_property DESCRIPTION "Process Data Interface for AP using Avalon"
set_module_property NAME pdi
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property GROUP POWERLINK/PDI
set_module_property AUTHOR "Joerg Zelenka (B&R 2010)"
set_module_property DISPLAY_NAME "Process Data Interface (Avalon to Avalon)"
set_module_property TOP_LEVEL_HDL_FILE pdi.vhd
set_module_property TOP_LEVEL_HDL_MODULE pdi
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property ICON_PATH br.png

#files
add_file pdi/pdi.vhd {SYNTHESIS SIMULATION}
add_file pdi/pdi_dpr.vhd {SYNTHESIS SIMULATION}
add_file pdi/pdi_tripleVBufLogic.vhd {SYNTHESIS SIMULATION}

#validation callback
set_module_property VALIDATION_CALLBACK my_validation_callback

#parameters
add_parameter rpdoNum INTEGER 1
set_parameter_property rpdoNum ALLOWED_RANGES {1 2 3}
set_parameter_property rpdoNum DISPLAY_NAME "Number of Rpdo Buffers"

add_parameter rpdo0size INTEGER 100
set_parameter_property rpdo0size ALLOWED_RANGES 1:1498
set_parameter_property rpdo0size UNITS bytes
set_parameter_property rpdo0size DISPLAY_NAME "1st Rpdo Buffer Size"

add_parameter rpdo1size INTEGER 100
set_parameter_property rpdo1size ALLOWED_RANGES 1:1498
set_parameter_property rpdo1size UNITS bytes
set_parameter_property rpdo1size DISPLAY_NAME "2nd Rpdo Buffer Size"

add_parameter rpdo2size INTEGER 100
set_parameter_property rpdo2size ALLOWED_RANGES 1:1498
set_parameter_property rpdo2size UNITS bytes
set_parameter_property rpdo2size DISPLAY_NAME "3rd Rpdo Buffer Size"

add_parameter rpdoMemory INTEGER
set_parameter_property rpdoMemory DERIVED TRUE
set_parameter_property rpdoMemory UNITS bytes
set_parameter_property rpdoMemory DISPLAY_NAME "Total Memory Size used for Rpdos"

add_parameter tpdoMemory INTEGER
set_parameter_property tpdoMemory DERIVED TRUE
set_parameter_property tpdoMemory UNITS bytes
set_parameter_property tpdoMemory DISPLAY_NAME "Total Memory Size used for Tpdos"

add_parameter totalMemory INTEGER
set_parameter_property totalMemory DERIVED TRUE
set_parameter_property totalMemory UNITS bytes
set_parameter_property totalMemory DISPLAY_NAME "Total Memory Size"

add_parameter totalM9K INTEGER
set_parameter_property totalM9K DERIVED TRUE
set_parameter_property totalM9K DISPLAY_NAME "Required M9K blocks"

#parameters for HDL
add_parameter iRpdos_g INTEGER 1
set_parameter_property iRpdos_g HDL_PARAMETER true
set_parameter_property iRpdos_g ALLOWED_RANGES {1 2 3}
set_parameter_property iRpdos_g VISIBLE false
set_parameter_property iRpdos_g DERIVED TRUE

add_parameter iTpdos_g INTEGER 1
set_parameter_property iTpdos_g HDL_PARAMETER true
set_parameter_property iTpdos_g ALLOWED_RANGES 1
set_parameter_property iTpdos_g DISPLAY_NAME "Number of Tpdo Buffers"

add_parameter iTpdoBufSize_g INTEGER 100
set_parameter_property iTpdoBufSize_g HDL_PARAMETER true
set_parameter_property iTpdoBufSize_g UNITS bytes
set_parameter_property iTpdoBufSize_g ALLOWED_RANGES 1:1498
set_parameter_property iTpdoBufSize_g DISPLAY_NAME "Tpdo Buffer Size"

add_parameter iRpdo0BufSize_g INTEGER 100
set_parameter_property iRpdo0BufSize_g HDL_PARAMETER true
set_parameter_property iRpdo0BufSize_g DERIVED true
set_parameter_property iRpdo0BufSize_g VISIBLE false

add_parameter iRpdo1BufSize_g INTEGER 100
set_parameter_property iRpdo1BufSize_g HDL_PARAMETER true
set_parameter_property iRpdo1BufSize_g DERIVED true
set_parameter_property iRpdo1BufSize_g VISIBLE false

add_parameter iRpdo2BufSize_g INTEGER 100
set_parameter_property iRpdo2BufSize_g HDL_PARAMETER true
set_parameter_property iRpdo2BufSize_g DERIVED true
set_parameter_property iRpdo2BufSize_g VISIBLE false

add_parameter iTpdoObjNumber_g INTEGER 10
set_parameter_property iTpdoObjNumber_g HDL_PARAMETER true
set_parameter_property iTpdoObjNumber_g ALLOWED_RANGES 1:1498
set_parameter_property iTpdoObjNumber_g DISPLAY_NAME "Number of Tpdo Objects"

add_parameter iRpdoObjNumber_g INTEGER 10
set_parameter_property iRpdoObjNumber_g HDL_PARAMETER true
set_parameter_property iRpdoObjNumber_g ALLOWED_RANGES 1:1498
set_parameter_property iRpdoObjNumber_g DISPLAY_NAME "Number of Rpdo Objects"

add_parameter iAsyTxBufSize_g INTEGER 1500
set_parameter_property iAsyTxBufSize_g HDL_PARAMETER true
set_parameter_property iAsyTxBufSize_g UNITS bytes
set_parameter_property iAsyTxBufSize_g ALLOWED_RANGES 1:1500
set_parameter_property iAsyTxBufSize_g DISPLAY_NAME "Asynchronous Tx Buffer Size"

add_parameter iAsyRxBufSize_g INTEGER 1500
set_parameter_property iAsyRxBufSize_g HDL_PARAMETER true
set_parameter_property iAsyRxBufSize_g UNITS bytes
set_parameter_property iAsyRxBufSize_g ALLOWED_RANGES 1:1500
set_parameter_property iAsyRxBufSize_g DISPLAY_NAME "Asynchronous Rx Buffer Size"


proc my_validation_callback {} {
	#rpdo
	set rNum [get_parameter_value rpdoNum]
	set r0size [get_parameter_value rpdo0size]
	set r1size [get_parameter_value rpdo1size]
	set r2size [get_parameter_value rpdo2size]
	#tpdo
	set t0size [get_parameter_value iTpdoBufSize_g]
	#desc
	set rd [get_parameter_value iRpdoObjNumber_g]
	set td [get_parameter_value iTpdoObjNumber_g]
	#async
	set atx [get_parameter_value iAsyTxBufSize_g]
	set arx [get_parameter_value iAsyRxBufSize_g] 
	
	set memRpdo 0
	set memTpdo 0
	set memory 0
	set m9k 0
	
	#align
	set r0size [expr ($r0size + 3) & ~3]
	set r1size [expr ($r1size + 3) & ~3]
	set r2size [expr ($r2size + 3) & ~3]
	set t0size [expr ($t0size + 3) & ~3]
	set atx [expr ($atx + 3) & ~3]
	set arx [expr ($arx + 3) & ~3]
	
	if {$rNum == 1} {
		set r1size 0
		set r2size 0
		
		set memRpdo [expr ($r0size + 16)]
		set_parameter_property rpdo0size VISIBLE true
		set_parameter_property rpdo1size VISIBLE false
		set_parameter_property rpdo2size VISIBLE false
	}
	if {$rNum == 2} {
		set r2size 0
		
		set memRpdo [expr ($r0size + 16 + $r1size + 16)*3]
		set_parameter_property rpdo0size VISIBLE true
		set_parameter_property rpdo1size VISIBLE true
		set_parameter_property rpdo2size VISIBLE false
	}
	if {$rNum == 3} {
		
		
		set memRpdo [expr ($r0size + 16 + $r1size + 16 + $r2size + 16)*3]
		set_parameter_property rpdo0size VISIBLE true
		set_parameter_property rpdo1size VISIBLE true
		set_parameter_property rpdo2size VISIBLE true
	}
	
	set memTpdo [expr ($t0size + 0)*3]
	set memory [expr $memRpdo + $memTpdo + (4 + $atx) + (4 + $arx) + $rd * 8 + $td * 8 + 12]
	set m9k [expr (1 << int(ceil( log($memory)/log(2.) )))/1024]
	if {$m9k == 0} {
		set m9k 1
	}
	
	set_parameter_value iRpdos_g $rNum
	set_parameter_value iRpdo0BufSize_g $r0size
	set_parameter_value iRpdo1BufSize_g $r1size
	set_parameter_value iRpdo2BufSize_g $r2size
	set_parameter_value rpdoMemory $memRpdo
	set_parameter_value tpdoMemory $memTpdo
	set_parameter_value totalMemory $memory
	set_parameter_value totalM9K $m9k
	
	#forward parameters to system.h
	set_module_assignment embeddedsw.CMacro.RPDOS  		[get_parameter_value iRpdos_g]
	set_module_assignment embeddedsw.CMacro.TPDOS  		[get_parameter_value iTpdos_g]
	set_module_assignment embeddedsw.CMacro.RPDO0SIZE  	[get_parameter_value iRpdo0BufSize_g]
	set_module_assignment embeddedsw.CMacro.RPDO1SIZE  	[get_parameter_value iRpdo1BufSize_g]
	set_module_assignment embeddedsw.CMacro.RPDO2SIZE  	[get_parameter_value iRpdo2BufSize_g]
	set_module_assignment embeddedsw.CMacro.TPDO0IZE  	[get_parameter_value iTpdoBufSize_g]
	set_module_assignment embeddedsw.CMacro.ASYNTXSIZE  [get_parameter_value iAsyTxBufSize_g]
	set_module_assignment embeddedsw.CMacro.ASYNRXSIZE  [get_parameter_value iAsyRxBufSize_g]
}

#display
add_display_item "Block Diagram" id0 icon pdi/pdi.png
add_display_item "Receive Process Data" rpdoNum PARAMETER
add_display_item "Transmit Process Data" iTpdos_g PARAMETER
add_display_item "Transmit Process Data" iTpdoBufSize_g PARAMETER
add_display_item "Receive Process Data" rpdo0size PARAMETER
add_display_item "Receive Process Data" rpdo1size PARAMETER
add_display_item "Receive Process Data" rpdo2size PARAMETER
add_display_item "Transmit Process Data" iTpdoObjNumber_g PARAMETER
add_display_item "Receive Process Data" iRpdoObjNumber_g PARAMETER
add_display_item "Asynchronous Buffer" iAsyTxBufSize_g PARAMETER
add_display_item "Asynchronous Buffer" iAsyRxBufSize_g PARAMETER
add_display_item "Estimated Synthesizer Result" rpdoMemory PARAMETER
add_display_item "Estimated Synthesizer Result" tpdoMemory PARAMETER
add_display_item "Estimated Synthesizer Result" totalMemory PARAMETER
add_display_item "Estimated Synthesizer Result" totalM9K PARAMETER

#Avalon Memory Mapped Slave: PCP
add_interface pcp avalon end
set_interface_property pcp addressAlignment DYNAMIC
set_interface_property pcp associatedClock pcp_clk_sink
set_interface_property pcp burstOnBurstBoundariesOnly false
set_interface_property pcp explicitAddressSpan 0
set_interface_property pcp holdTime 0
set_interface_property pcp isMemoryDevice false
set_interface_property pcp isNonVolatileStorage false
set_interface_property pcp linewrapBursts false
set_interface_property pcp maximumPendingReadTransactions 0
set_interface_property pcp printableDevice false
set_interface_property pcp readLatency 0
set_interface_property pcp readWaitStates 2
set_interface_property pcp readWaitTime 2
set_interface_property pcp setupTime 0
set_interface_property pcp timingUnits Cycles
set_interface_property pcp writeWaitTime 0
set_interface_property pcp ASSOCIATED_CLOCK pcp_clk_sink
set_interface_property pcp ENABLED true
add_interface_port pcp pcp_chipselect chipselect Input 1
add_interface_port pcp pcp_read read Input 1
add_interface_port pcp pcp_write write Input 1
add_interface_port pcp pcp_byteenable byteenable Input 4
add_interface_port pcp pcp_address address Input 15
add_interface_port pcp pcp_writedata writedata Input 32
add_interface_port pcp pcp_readdata readdata Output 32

#Avalon Memory Mapped Slave: AP
add_interface ap avalon end
set_interface_property ap addressAlignment DYNAMIC
set_interface_property ap associatedClock ap_clk_sink
set_interface_property ap burstOnBurstBoundariesOnly false
set_interface_property ap explicitAddressSpan 0
set_interface_property ap holdTime 0
set_interface_property ap isMemoryDevice false
set_interface_property ap isNonVolatileStorage false
set_interface_property ap linewrapBursts false
set_interface_property ap maximumPendingReadTransactions 0
set_interface_property ap printableDevice false
set_interface_property ap readLatency 0
set_interface_property ap readWaitStates 2
set_interface_property ap readWaitTime 2
set_interface_property ap setupTime 0
set_interface_property ap timingUnits Cycles
set_interface_property ap writeWaitTime 0
set_interface_property ap ASSOCIATED_CLOCK ap_clk_sink
set_interface_property ap ENABLED true
add_interface_port ap ap_chipselect chipselect Input 1
add_interface_port ap ap_read read Input 1
add_interface_port ap ap_write write Input 1
add_interface_port ap ap_byteenable byteenable Input 4
add_interface_port ap ap_address address Input 15
add_interface_port ap ap_writedata writedata Input 32
add_interface_port ap ap_readdata readdata Output 32

#Clock Sink: PCP
add_interface pcp_clk_sink clock end
set_interface_property pcp_clk_sink ENABLED true
add_interface_port pcp_clk_sink pcp_clk clk Input 1
add_interface_port pcp_clk_sink pcp_reset reset Input 1

#Clock Sink: AP
add_interface ap_clk_sink clock end
set_interface_property ap_clk_sink ENABLED true
add_interface_port ap_clk_sink ap_clk clk Input 1
add_interface_port ap_clk_sink ap_reset reset Input 1
