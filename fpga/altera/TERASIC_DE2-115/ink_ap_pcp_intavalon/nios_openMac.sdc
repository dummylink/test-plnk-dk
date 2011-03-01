# SDC file for POWERLINK Slave reference design

# constrain JTAG
create_clock -period 10MHz {altera_reserved_tck}
set_clock_groups -asynchronous -group {altera_reserved_tck}
set_input_delay -clock {altera_reserved_tck} 20 [get_ports altera_reserved_tdi]
set_input_delay -clock {altera_reserved_tck} 20 [get_ports altera_reserved_tms]
set_output_delay -clock {altera_reserved_tck} 20 [get_ports altera_reserved_tdo]

# derive pll clocks (generated + input)
derive_pll_clocks -create_base_clocks
derive_clock_uncertainty

# generated clocks (out of pll in SOPC) stored as variable
set ext_clk		EXT_CLK

set clk50 		inst|the_altpll_0|sd1|pll7|clk[0]
set clk100		inst|the_altpll_0|sd1|pll7|clk[1]
set pcp_clk 	inst|the_altpll_0|sd1|pll7|clk[2]
set ap_clk		inst|the_altpll_0|sd1|pll7|clk[3]
set remote_clk	inst|the_altpll_0|sd1|pll7|clk[4]
set p0TxClk		PHY0_TXCLK
set p0RxClk		PHY0_RXCLK
set p1TxClk		PHY1_TXCLK
set p1RxClk		PHY1_RXCLK

# mii phy
create_clock -period 25MHz $p0RxClk
create_clock -period 25MHz $p0TxClk

set_input_delay -clock $p0RxClk -max 30 [get_ports {PHY0_RXDV PHY0_RXD[*]}]
set_input_delay -clock $p0RxClk -min 10 [get_ports {PHY0_RXDV PHY0_RXD[*]}]

set_output_delay -clock $p0TxClk -max 30 [get_ports {PHY0_TXEN PHY0_TXD[*]}]
set_output_delay -clock $p0TxClk -min  0 [get_ports {PHY0_TXEN PHY0_TXD[*]}]

create_clock -period 25MHz $p1RxClk
create_clock -period 25MHz $p1TxClk

set_input_delay -clock $p1RxClk -max 30 [get_ports {PHY1_RXDV PHY1_RXD[*]}]
set_input_delay -clock $p1RxClk -min 10 [get_ports {PHY1_RXDV PHY1_RXD[*]}]

set_output_delay -clock $p1TxClk -max 30 [get_ports {PHY1_TXEN PHY1_TXD[*]}]
set_output_delay -clock $p1TxClk -min  0 [get_ports {PHY1_TXEN PHY1_TXD[*]}]

# set clock groups (is equal to false_path command)
set_clock_groups -asynchronous 	-group [get_clocks $clk50] \
											-group [get_clocks $clk100] \
											-group [get_clocks $pcp_clk] \
											-group [get_clocks $ap_clk] \
											-group [get_clocks $p0TxClk] \
											-group [get_clocks $p0RxClk] \
											-group [get_clocks $p1TxClk] \
											-group [get_clocks $p1RxClk] \
											-group [get_clocks $ext_clk]
