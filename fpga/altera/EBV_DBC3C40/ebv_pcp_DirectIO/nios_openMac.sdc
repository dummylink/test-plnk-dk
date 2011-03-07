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
set pcp_clk 	inst|the_altpll_0|sd1|pll7|clk[1]
set clk50 		inst|the_altpll_0|sd1|pll7|clk[0]
set remote_clk	inst|the_altpll_0|sd1|pll7|clk[4]
set clk100		inst|the_altpll_0|sd1|pll7|clk[2]


# set clock groups (is equal to false_path command)
set_clock_groups -asynchronous 	-group [get_clocks $remote_clk] \
											-group [get_clocks $pcp_clk] \
											-group [get_clocks $clk50] \
											-group [get_clocks ext_clk] \
											-group [get_clocks $clk100]

# phy
set_input_delay -clock $clk50 -max 12 [get_ports {phy0_rx_crsdv phy0_rx_d[*]}]
set_input_delay -clock $clk50 -min 4 [get_ports {phy0_rx_crsdv phy0_rx_d[*]}]

set_input_delay -clock $clk50 -max 12 [get_ports {phy1_rx_crsdv phy1_rx_d[*]}]
set_input_delay -clock $clk50 -min 4 [get_ports {phy1_rx_crsdv phy1_rx_d[*]}]

set_output_delay -clock $clk50 -max 8 [get_ports {phy0_tx_en phy0_tx_d[*]}]
set_output_delay -clock $clk50 -min 4 [get_ports {phy0_tx_en phy0_tx_d[*]}]

set_output_delay -clock $clk50 -max 8 [get_ports {phy1_tx_en phy1_tx_d[*]}]
set_output_delay -clock $clk50 -min 4 [get_ports {phy1_tx_en phy1_tx_d[*]}]

set_multicycle_path -from [get_clocks $clk100] -to [get_clocks $clk50] -setup -start 2