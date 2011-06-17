# SDC file for POWERLINK design

# ----------------------------------------------------------------------------------
# constrain JTAG
create_clock -period 10MHz {altera_reserved_tck}
set_clock_groups -asynchronous -group {altera_reserved_tck}
set_input_delay -clock {altera_reserved_tck} 20 [get_ports altera_reserved_tdi]
set_input_delay -clock {altera_reserved_tck} 20 [get_ports altera_reserved_tms]
set_output_delay -clock {altera_reserved_tck} 20 [get_ports altera_reserved_tdo]
# ----------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------
# derive pll clocks (generated + input)
derive_pll_clocks -create_base_clocks
derive_clock_uncertainty
# ----------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------
# generated clocks (out of pll in SOPC) stored as variable
set ext_clk		EXT_CLK
set clk50 		inst|the_altpll_0|sd1|pll7|clk[0]
set clkPCP		inst|the_altpll_0|sd1|pll7|clk[1]
set clk25		inst|the_altpll_0|sd1|pll7|clk[2]
set clk50_270deg	inst|the_altpll_0|sd1|pll7|clk[3]
set p0TxClk		PHY0_TXCLK
set p0RxClk		PHY0_RXCLK
set p1TxClk		PHY1_TXCLK
set p1RxClk		PHY1_RXCLK
# ----------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------
# sram (IS61WV102416BLL-10TLI)
## SRAM is driven by 100 MHz fsm.
## Note: The SOPC inserts 1 write and 2 read cycles, thus, the SRAM "sees" 50 MHz!
set sram_clk		50.0
set sram_tper		[expr 1000.0 / $sram_clk]
## delay Address Access Time (tAA) = 10.0 ns
set sram_ddel		10.0
## pcb delay
set sram_tpcb		0.1
## fpga settings...
set sram_tco		5.5
set sram_tsu		[expr $sram_tper - $sram_ddel - $sram_tco - 2*$sram_tpcb]
set sram_th			0.0
set sram_tcom		0.0

set sram_in_max	[expr $sram_tper - $sram_tsu]
set sram_in_min	$sram_th
set sram_out_max	[expr $sram_tper - $sram_tco]
set sram_out_min	$sram_tcom

## sram virtual clock
create_clock -period $sram_tper -name sram_vclk

## TSU / TH
set_input_delay -clock sram_vclk -max $sram_in_max [get_ports SRAM_DQ[*]]
set_input_delay -clock sram_vclk -min $sram_in_min [get_ports SRAM_DQ[*]]
## TCO
set_output_delay -clock sram_vclk -max $sram_out_max [get_ports SRAM_DQ[*]]
set_output_delay -clock sram_vclk -min $sram_out_min [get_ports SRAM_DQ[*]]
## TCO
set_output_delay -clock sram_vclk -max $sram_out_max [get_ports SRAM_ADDR[*]]
set_output_delay -clock sram_vclk -min $sram_out_min [get_ports SRAM_ADDR[*]]
## TCO
set_output_delay -clock sram_vclk -max $sram_out_max [get_ports SRAM_BE_n[*]]
set_output_delay -clock sram_vclk -min $sram_out_min [get_ports SRAM_BE_n[*]]
## TCO
set_output_delay -clock sram_vclk -max $sram_out_max [get_ports SRAM_OE_n]
set_output_delay -clock sram_vclk -min $sram_out_min [get_ports SRAM_OE_n]
## TCO
set_output_delay -clock sram_vclk -max $sram_out_max [get_ports SRAM_WE_n]
set_output_delay -clock sram_vclk -min $sram_out_min [get_ports SRAM_WE_n]
## TCO
set_output_delay -clock sram_vclk -max $sram_out_max [get_ports SRAM_CE_n]
set_output_delay -clock sram_vclk -min $sram_out_min [get_ports SRAM_CE_n]

## relax timing...
## Note: Nios II is running with 100 MHz, but Tri-State-bridge reads with 50 MHz.
### from FPGA to SRAM
set_multicycle_path -from [get_clocks $clkPCP] -to [get_clocks sram_vclk] -setup -start 2
set_multicycle_path -from [get_clocks $clkPCP] -to [get_clocks sram_vclk] -hold -start 1
### from SRAM to FPGA
set_multicycle_path -from [get_clocks sram_vclk] -to [get_clocks $clkPCP] -setup -end 2
set_multicycle_path -from [get_clocks sram_vclk] -to [get_clocks $clkPCP] -hold -end 1
# ----------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------
# IOs
## cut paths
###IOs
####Outputs
set_false_path -from [get_registers *] -to [get_ports LEDR[*]]
set_false_path -from [get_registers *] -to [get_ports LEDG[*]]
set_false_path -from [get_registers *] -to [get_ports HEX0[*]]
set_false_path -from [get_registers *] -to [get_ports HEX1[*]]
set_false_path -from [get_registers *] -to [get_ports SW_BENCHMARK_OUT[*]]
####Inputs
set_false_path -from [get_ports SW[*]] -to [get_registers *] 
set_false_path -from [get_ports KEY[*]] -to [get_registers *]
set_false_path -from [get_ports NODE_SWITCH[*]] -to [get_registers *]
###EPCS
set_false_path -from [get_registers *] -to [get_ports EPCS_DCLK]
set_false_path -from [get_registers *] -to [get_ports EPCS_SCE]
set_false_path -from [get_registers *] -to [get_ports EPCS_SDO]
set_false_path -from [get_ports EPCS_DATA0] -to [get_registers *]
# ----------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------
# LCD
## TCO
set_max_delay 10 -from [get_registers *] -to [get_ports {LCD_E}]
set_min_delay 0 -from [get_registers *] -to [get_ports {LCD_E}]
## TCO
set_max_delay 10 -from [get_registers *] -to [get_ports {LCD_RS}]
set_min_delay 0 -from [get_registers *] -to [get_ports {LCD_RS}]
## TCO
set_max_delay 10 -from [get_registers *] -to [get_ports {LCD_RW}]
set_min_delay 0 -from [get_registers *] -to [get_ports {LCD_RW}]
## TCO
set_max_delay 10 -from [get_registers *] -to [get_ports {LCD_DQ[*]}]
set_min_delay 0 -from [get_registers *] -to [get_ports {LCD_DQ[*]}]
## cut on signal (not critical)
set_false_path -from [get_registers *] -to [get_ports LCD_ON]
set_false_path -from [get_registers *] -to [get_ports LCD_BLON]
# ----------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------
# MII
# phy = MARVELL 88E1111
set phy_tper		40.0
set phy_tout2clk	10.0
set phy_tclk2out	10.0
set phy_tsu			10.0
set phy_th			0.0
# pcb delay
set phy_tpcb		0.1

set phy_in_max		[expr $phy_tper - ($phy_tout2clk - $phy_tpcb)]
set phy_in_min		[expr $phy_tclk2out - $phy_tpcb]
set phy_out_max	[expr $phy_tsu + $phy_tpcb]
set phy_out_min	[expr $phy_tclk2out - $phy_tpcb]

##PHY0
## real clock
create_clock -period 25MHz -name phy0_rxclk [get_ports $p0RxClk]
create_clock -period 25MHz -name phy0_txclk [get_ports $p0TxClk]
## virtual clock
create_clock -period 25MHz -name phy0_vrxclk
create_clock -period 25MHz -name phy0_vtxclk
## input
set_input_delay -clock phy0_vrxclk -max $phy_in_max [get_ports {PHY0_RXDV PHY0_RXER PHY0_RXD[*]}]
set_input_delay -clock phy0_vrxclk -min $phy_in_min [get_ports {PHY0_RXDV PHY0_RXER PHY0_RXD[*]}]
## output
set_output_delay -clock phy0_vtxclk -max $phy_out_max [get_ports {PHY0_TXEN PHY0_TXER PHY0_TXD[*]}]
set_output_delay -clock phy0_vtxclk -min $phy_out_min [get_ports {PHY0_TXEN PHY0_TXER PHY0_TXD[*]}]
## cut path
set_false_path -from [get_registers *] -to [get_ports PHY0_GXCLK]
set_false_path -from [get_registers *] -to [get_ports PHY0_RESET_n]
set_false_path -from [get_registers *] -to [get_ports PHY0_MDC]
set_false_path -from [get_registers *] -to [get_ports PHY0_MDIO]
set_false_path -from [get_ports PHY0_MDIO] -to [get_registers *]
set_false_path -from [get_ports PHY0_LINK] -to [get_registers *]

##PHY1
## real clock
create_clock -period 25MHz -name phy1_rxclk [get_ports $p1RxClk]
create_clock -period 25MHz -name phy1_txclk [get_ports $p1TxClk]
## virtual clock
create_clock -period 25MHz -name phy1_vrxclk
create_clock -period 25MHz -name phy1_vtxclk
## input
set_input_delay -clock phy1_vrxclk -max $phy_in_max [get_ports {PHY1_RXDV PHY1_RXER PHY1_RXD[*]}]
set_input_delay -clock phy1_vrxclk -min $phy_in_min [get_ports {PHY1_RXDV PHY1_RXER PHY1_RXD[*]}]
## output
set_output_delay -clock phy1_vtxclk -max $phy_out_max [get_ports {PHY1_TXEN PHY1_TXER PHY1_TXD[*]}]
set_output_delay -clock phy1_vtxclk -min $phy_out_min [get_ports {PHY1_TXEN PHY1_TXER PHY1_TXD[*]}]
## cut path
set_false_path -from [get_registers *] -to [get_ports PHY1_GXCLK]
set_false_path -from [get_registers *] -to [get_ports PHY1_RESET_n]
set_false_path -from [get_registers *] -to [get_ports PHY1_MDC]
set_false_path -from [get_registers *] -to [get_ports PHY1_MDIO]
set_false_path -from [get_ports PHY1_MDIO] -to [get_registers *]
set_false_path -from [get_ports PHY1_LINK] -to [get_registers *]
# ----------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------
# set clock groups (is equal to false_path command between clock domains)
## note: only add clock domains which have no transfers or sync is done
set_clock_groups -asynchronous 	-group [get_clocks $clk50] \
											-group [get_clocks $clkPCP] \
											-group [get_clocks $clk25] \
											-group [get_clocks $clk50_270deg] \
											-group [get_clocks phy0_rxclk] \
											-group [get_clocks phy0_txclk] \
											-group [get_clocks phy1_rxclk] \
											-group [get_clocks phy1_txclk] \
											-group [get_clocks $ext_clk]
# ----------------------------------------------------------------------------------
