#------------------------------------------------------------------------------------------------------------------------
#-- openMAC SOPC description file
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
#-- FIND THE HISTORY IN openMAC/OpenMAC_AvalonIF.vhd !
#------------------------------------------------------------------------------------------------------------------------

package require -exact sopc 10.0

set_module_property NAME openMAC
set_module_property VERSION 1.1
set_module_property INTERNAL false
set_module_property GROUP POWERLINK/MAC
set_module_property AUTHOR "Joerg Zelenka (B&R 2010)"
set_module_property DISPLAY_NAME "openMAC"
set_module_property TOP_LEVEL_HDL_FILE OpenMAC_AvalonIF.vhd
set_module_property TOP_LEVEL_HDL_MODULE AlteraOpenMACIF
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
set_module_property ICON_PATH br.png

#files
add_file openMAC/OpenFILTER.vhd {SYNTHESIS SIMULATION}
add_file openMAC/OpenHUB.vhd {SYNTHESIS SIMULATION}
add_file openMAC/OpenMAC.vhd {SYNTHESIS SIMULATION}
add_file openMAC/OpenMAC_AvalonIF.vhd {SYNTHESIS SIMULATION}
add_file openMAC/OpenMAC_DPR_Altera.vhd {SYNTHESIS SIMULATION}
add_file openMAC/OpenMAC_PHYMI.vhd {SYNTHESIS SIMULATION}

#validation callback
set_module_property VALIDATION_CALLBACK my_validation_callback

#parameters
add_parameter useCn BOOLEAN TRUE
set_parameter_property useCn DISPLAY_NAME "Configure openMAC for POWERLINK CN usage"

add_parameter RxBufNum INTEGER 16
set_parameter_property RxBufNum ALLOWED_RANGES 6:16
set_parameter_property RxBufNum DISPLAY_NAME "Number of Rx Buffers"
set_parameter_property RxBufNum VISIBLE true

add_parameter TpdoSize INTEGER 100
set_parameter_property TpdoSize ALLOWED_RANGES 1:1490
set_parameter_property TpdoSize UNITS bytes
set_parameter_property TpdoSize DISPLAY_NAME "Tpdo Size"
set_parameter_property TpdoSize VISIBLE true

add_parameter TxBufNum INTEGER 5
set_parameter_property TxBufNum ALLOWED_RANGES 1:1498
set_parameter_property TxBufNum DISPLAY_NAME "Number of Tx Buffers"
set_parameter_property TxBufNum VISIBLE false

#parameters for HDL
add_parameter Simulate BOOLEAN false
set_parameter_property Simulate DEFAULT_VALUE false
set_parameter_property Simulate DISPLAY_NAME "Configure openMAC for Simulation"
set_parameter_property Simulate UNITS None
set_parameter_property Simulate DISPLAY_HINT ""
set_parameter_property Simulate AFFECTS_GENERATION false
set_parameter_property Simulate HDL_PARAMETER true

add_parameter iBufSize_g INTEGER 1024
set_parameter_property iBufSize_g HDL_PARAMETER true
set_parameter_property iBufSize_g UNITS bytes
set_parameter_property iBufSize_g VISIBLE false
set_parameter_property iBufSize_g DERIVED TRUE

add_parameter iBufSizeLOG2_g INTEGER 10
set_parameter_property iBufSizeLOG2_g HDL_PARAMETER true
set_parameter_property iBufSizeLOG2_g UNITS bytes
set_parameter_property iBufSizeLOG2_g VISIBLE false
set_parameter_property iBufSizeLOG2_g DERIVED TRUE

proc my_validation_callback {} {
	#rpdo
	set rxBuffers 	[get_parameter_value RxBufNum]
	set txBuffers 	[get_parameter_value TxBufNum]
	set tpdoSize 	[get_parameter_value TpdoSize]
	set isCn 		[get_parameter_value useCn]
	
	set macTxHd	2
	set macRxHd 16
	set mtu 	1514
	set crc		4
	
	set IdRes 	[expr 176 				+ $crc + $macTxHd]
	set StRes 	[expr 72 				+ $crc + $macTxHd]
	set NmtReq 	[expr $mtu 				+ $crc + $macTxHd]
	set nonEpl	[expr $mtu 				+ $crc + $macTxHd]
	set PRes	[expr 24 + $tpdoSize 	+ $crc + $macTxHd]
	
	set txBufSize 0
	set rxBufSize 0
	
	if {$isCn} {
		#calculate CN configuration
		set txBufSize [expr $IdRes + $StRes + $NmtReq + $nonEpl + $PRes]
		set_parameter_property TpdoSize VISIBLE true
		set_parameter_property TxBufNum VISIBLE false
		set_parameter_property RxBufNum ALLOWED_RANGES 6:16
		
		#forward Tpdo Size if POWERLINK is used
		set_module_assignment embeddedsw.CMacro.TPDOSIZE  	$tpdoSize
		
		set msg1 "openMAC is configured for POWERLINK (Tpdo = $tpdoSize bytes)!"
		
	} else {
		#use amount of Tx buffers
		set txBufSize [expr $txBuffers * ($mtu + $crc + $macTxHd)]
		set_parameter_property TpdoSize VISIBLE false
		set_parameter_property TxBufNum VISIBLE true
		set_parameter_property RxBufNum ALLOWED_RANGES 1:16
		set $tpdoSize 0
		
		set msg1 "openMAC is configured for general purpose!"
	}
	
	set rxBufSize [expr $rxBuffers * ($mtu + $crc + $macRxHd)]
	
	set memory [expr $rxBufSize + $txBufSize]
	
	#align
	set memory [expr ($memory + 3) & ~3]
	
	#set HDL parameters
	set_parameter_value iBufSize_g $memory
	set_parameter_value iBufSizeLOG2_g [expr int(ceil( log($memory) / log(2.) ))]
	
	#forward parameters to system.h
	set_module_assignment embeddedsw.CMacro.POWERLINK	$isCn
	set_module_assignment embeddedsw.CMacro.RXBUFFERS  	$rxBuffers
	set_module_assignment embeddedsw.CMacro.RXBUFSIZE  	$rxBufSize
	set_module_assignment embeddedsw.CMacro.TXBUFSIZE  	$txBufSize
	
	send_message info "$msg1 MAC Buffer (Rx and Tx) Size = $memory bytes"
}

#display
add_display_item "Block Diagram" id0 icon openMAC/openMAC.png
add_display_item "General Settings" Simulate PARAMETER
add_display_item "General Settings" useCn PARAMETER
add_display_item "POWERLINK Settings" TpdoSize PARAMETER
add_display_item "MAC Settings" TxBufNum PARAMETER
add_display_item "MAC Settings" RxBufNum PARAMETER

#Avalon Memory Mapped Slave: Compare Unit 
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
add_interface_port CMP t_address address Input 2
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
add_interface_port iBuf iBuf_address address Input "(iBufSizeLOG2_g-3) - (0) + 1"
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

# +-----------------------------------
# | connection point clock_sink_2
# | 
add_interface clock_sink_2 clock end

set_interface_property clock_sink_2 ENABLED true

add_interface_port clock_sink_2 clk100 clk Input 1
# | 
# +-----------------------------------
