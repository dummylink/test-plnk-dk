--megafunction wizard: %Altera SOPC Builder%
--GENERATION: STANDARD
--VERSION: WM1.0


--Legal Notice: (C)2011 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity altpll_0_pll_slave_arbitrator is 
        port (
              -- inputs:
                 signal altpll_0_pll_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_address_to_slave : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_0_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal altpll_0_pll_slave_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal altpll_0_pll_slave_read : OUT STD_LOGIC;
                 signal altpll_0_pll_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal altpll_0_pll_slave_reset : OUT STD_LOGIC;
                 signal altpll_0_pll_slave_write : OUT STD_LOGIC;
                 signal altpll_0_pll_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_altpll_0_pll_slave_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_out_granted_altpll_0_pll_slave : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_out_read_data_valid_altpll_0_pll_slave : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_out_requests_altpll_0_pll_slave : OUT STD_LOGIC
              );
end entity altpll_0_pll_slave_arbitrator;


architecture europa of altpll_0_pll_slave_arbitrator is
                signal altpll_0_pll_slave_allgrants :  STD_LOGIC;
                signal altpll_0_pll_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal altpll_0_pll_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal altpll_0_pll_slave_any_continuerequest :  STD_LOGIC;
                signal altpll_0_pll_slave_arb_counter_enable :  STD_LOGIC;
                signal altpll_0_pll_slave_arb_share_counter :  STD_LOGIC;
                signal altpll_0_pll_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal altpll_0_pll_slave_arb_share_set_values :  STD_LOGIC;
                signal altpll_0_pll_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal altpll_0_pll_slave_begins_xfer :  STD_LOGIC;
                signal altpll_0_pll_slave_end_xfer :  STD_LOGIC;
                signal altpll_0_pll_slave_firsttransfer :  STD_LOGIC;
                signal altpll_0_pll_slave_grant_vector :  STD_LOGIC;
                signal altpll_0_pll_slave_in_a_read_cycle :  STD_LOGIC;
                signal altpll_0_pll_slave_in_a_write_cycle :  STD_LOGIC;
                signal altpll_0_pll_slave_master_qreq_vector :  STD_LOGIC;
                signal altpll_0_pll_slave_non_bursting_master_requests :  STD_LOGIC;
                signal altpll_0_pll_slave_reg_firsttransfer :  STD_LOGIC;
                signal altpll_0_pll_slave_slavearbiterlockenable :  STD_LOGIC;
                signal altpll_0_pll_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal altpll_0_pll_slave_unreg_firsttransfer :  STD_LOGIC;
                signal altpll_0_pll_slave_waits_for_read :  STD_LOGIC;
                signal altpll_0_pll_slave_waits_for_write :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_altpll_0_pll_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_niosII_openMac_clock_0_out_granted_altpll_0_pll_slave :  STD_LOGIC;
                signal internal_niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave :  STD_LOGIC;
                signal internal_niosII_openMac_clock_0_out_requests_altpll_0_pll_slave :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_arbiterlock :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_arbiterlock2 :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_saved_grant_altpll_0_pll_slave :  STD_LOGIC;
                signal shifted_address_to_altpll_0_pll_slave_from_niosII_openMac_clock_0_out :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal wait_for_altpll_0_pll_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT altpll_0_pll_slave_end_xfer;
    end if;

  end process;

  altpll_0_pll_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave);
  --assign altpll_0_pll_slave_readdata_from_sa = altpll_0_pll_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  altpll_0_pll_slave_readdata_from_sa <= altpll_0_pll_slave_readdata;
  internal_niosII_openMac_clock_0_out_requests_altpll_0_pll_slave <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_0_out_read OR niosII_openMac_clock_0_out_write)))))));
  --altpll_0_pll_slave_arb_share_counter set values, which is an e_mux
  altpll_0_pll_slave_arb_share_set_values <= std_logic'('1');
  --altpll_0_pll_slave_non_bursting_master_requests mux, which is an e_mux
  altpll_0_pll_slave_non_bursting_master_requests <= internal_niosII_openMac_clock_0_out_requests_altpll_0_pll_slave;
  --altpll_0_pll_slave_any_bursting_master_saved_grant mux, which is an e_mux
  altpll_0_pll_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --altpll_0_pll_slave_arb_share_counter_next_value assignment, which is an e_assign
  altpll_0_pll_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(altpll_0_pll_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altpll_0_pll_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(altpll_0_pll_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altpll_0_pll_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --altpll_0_pll_slave_allgrants all slave grants, which is an e_mux
  altpll_0_pll_slave_allgrants <= altpll_0_pll_slave_grant_vector;
  --altpll_0_pll_slave_end_xfer assignment, which is an e_assign
  altpll_0_pll_slave_end_xfer <= NOT ((altpll_0_pll_slave_waits_for_read OR altpll_0_pll_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_altpll_0_pll_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_altpll_0_pll_slave <= altpll_0_pll_slave_end_xfer AND (((NOT altpll_0_pll_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --altpll_0_pll_slave_arb_share_counter arbitration counter enable, which is an e_assign
  altpll_0_pll_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_altpll_0_pll_slave AND altpll_0_pll_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_altpll_0_pll_slave AND NOT altpll_0_pll_slave_non_bursting_master_requests));
  --altpll_0_pll_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altpll_0_pll_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(altpll_0_pll_slave_arb_counter_enable) = '1' then 
        altpll_0_pll_slave_arb_share_counter <= altpll_0_pll_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --altpll_0_pll_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altpll_0_pll_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((altpll_0_pll_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_altpll_0_pll_slave)) OR ((end_xfer_arb_share_counter_term_altpll_0_pll_slave AND NOT altpll_0_pll_slave_non_bursting_master_requests)))) = '1' then 
        altpll_0_pll_slave_slavearbiterlockenable <= altpll_0_pll_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_0/out altpll_0/pll_slave arbiterlock, which is an e_assign
  niosII_openMac_clock_0_out_arbiterlock <= altpll_0_pll_slave_slavearbiterlockenable AND niosII_openMac_clock_0_out_continuerequest;
  --altpll_0_pll_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  altpll_0_pll_slave_slavearbiterlockenable2 <= altpll_0_pll_slave_arb_share_counter_next_value;
  --niosII_openMac_clock_0/out altpll_0/pll_slave arbiterlock2, which is an e_assign
  niosII_openMac_clock_0_out_arbiterlock2 <= altpll_0_pll_slave_slavearbiterlockenable2 AND niosII_openMac_clock_0_out_continuerequest;
  --altpll_0_pll_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  altpll_0_pll_slave_any_continuerequest <= std_logic'('1');
  --niosII_openMac_clock_0_out_continuerequest continued request, which is an e_assign
  niosII_openMac_clock_0_out_continuerequest <= std_logic'('1');
  internal_niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave <= internal_niosII_openMac_clock_0_out_requests_altpll_0_pll_slave;
  --altpll_0_pll_slave_writedata mux, which is an e_mux
  altpll_0_pll_slave_writedata <= niosII_openMac_clock_0_out_writedata;
  --master is always granted when requested
  internal_niosII_openMac_clock_0_out_granted_altpll_0_pll_slave <= internal_niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave;
  --niosII_openMac_clock_0/out saved-grant altpll_0/pll_slave, which is an e_assign
  niosII_openMac_clock_0_out_saved_grant_altpll_0_pll_slave <= internal_niosII_openMac_clock_0_out_requests_altpll_0_pll_slave;
  --allow new arb cycle for altpll_0/pll_slave, which is an e_assign
  altpll_0_pll_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  altpll_0_pll_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  altpll_0_pll_slave_master_qreq_vector <= std_logic'('1');
  --~altpll_0_pll_slave_reset assignment, which is an e_assign
  altpll_0_pll_slave_reset <= NOT reset_n;
  --altpll_0_pll_slave_firsttransfer first transaction, which is an e_assign
  altpll_0_pll_slave_firsttransfer <= A_WE_StdLogic((std_logic'(altpll_0_pll_slave_begins_xfer) = '1'), altpll_0_pll_slave_unreg_firsttransfer, altpll_0_pll_slave_reg_firsttransfer);
  --altpll_0_pll_slave_unreg_firsttransfer first transaction, which is an e_assign
  altpll_0_pll_slave_unreg_firsttransfer <= NOT ((altpll_0_pll_slave_slavearbiterlockenable AND altpll_0_pll_slave_any_continuerequest));
  --altpll_0_pll_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      altpll_0_pll_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(altpll_0_pll_slave_begins_xfer) = '1' then 
        altpll_0_pll_slave_reg_firsttransfer <= altpll_0_pll_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --altpll_0_pll_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  altpll_0_pll_slave_beginbursttransfer_internal <= altpll_0_pll_slave_begins_xfer;
  --altpll_0_pll_slave_read assignment, which is an e_mux
  altpll_0_pll_slave_read <= internal_niosII_openMac_clock_0_out_granted_altpll_0_pll_slave AND niosII_openMac_clock_0_out_read;
  --altpll_0_pll_slave_write assignment, which is an e_mux
  altpll_0_pll_slave_write <= internal_niosII_openMac_clock_0_out_granted_altpll_0_pll_slave AND niosII_openMac_clock_0_out_write;
  shifted_address_to_altpll_0_pll_slave_from_niosII_openMac_clock_0_out <= niosII_openMac_clock_0_out_address_to_slave;
  --altpll_0_pll_slave_address mux, which is an e_mux
  altpll_0_pll_slave_address <= A_EXT (A_SRL(shifted_address_to_altpll_0_pll_slave_from_niosII_openMac_clock_0_out,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_altpll_0_pll_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_altpll_0_pll_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_altpll_0_pll_slave_end_xfer <= altpll_0_pll_slave_end_xfer;
    end if;

  end process;

  --altpll_0_pll_slave_waits_for_read in a cycle, which is an e_mux
  altpll_0_pll_slave_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altpll_0_pll_slave_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --altpll_0_pll_slave_in_a_read_cycle assignment, which is an e_assign
  altpll_0_pll_slave_in_a_read_cycle <= internal_niosII_openMac_clock_0_out_granted_altpll_0_pll_slave AND niosII_openMac_clock_0_out_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= altpll_0_pll_slave_in_a_read_cycle;
  --altpll_0_pll_slave_waits_for_write in a cycle, which is an e_mux
  altpll_0_pll_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altpll_0_pll_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --altpll_0_pll_slave_in_a_write_cycle assignment, which is an e_assign
  altpll_0_pll_slave_in_a_write_cycle <= internal_niosII_openMac_clock_0_out_granted_altpll_0_pll_slave AND niosII_openMac_clock_0_out_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= altpll_0_pll_slave_in_a_write_cycle;
  wait_for_altpll_0_pll_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  niosII_openMac_clock_0_out_granted_altpll_0_pll_slave <= internal_niosII_openMac_clock_0_out_granted_altpll_0_pll_slave;
  --vhdl renameroo for output signals
  niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave <= internal_niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave;
  --vhdl renameroo for output signals
  niosII_openMac_clock_0_out_requests_altpll_0_pll_slave <= internal_niosII_openMac_clock_0_out_requests_altpll_0_pll_slave;
--synthesis translate_off
    --altpll_0/pll_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity avalon_master_bridge_0_AvalonMaster_arbitrator is 
        port (
              -- inputs:
                 signal avalon_address_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (14 DOWNTO 0);
                 signal avalon_byteenable_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal avalon_master_bridge_0_granted_powerlink_0_PDI_AP : IN STD_LOGIC;
                 signal avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP : IN STD_LOGIC;
                 signal avalon_master_bridge_0_read_data_valid_powerlink_0_PDI_AP : IN STD_LOGIC;
                 signal avalon_master_bridge_0_requests_powerlink_0_PDI_AP : IN STD_LOGIC;
                 signal avalon_read_from_the_avalon_master_bridge_0 : IN STD_LOGIC;
                 signal avalon_write_from_the_avalon_master_bridge_0 : IN STD_LOGIC;
                 signal avalon_writedata_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal d1_powerlink_0_PDI_AP_end_xfer : IN STD_LOGIC;
                 signal powerlink_0_PDI_AP_irq_from_sa : IN STD_LOGIC;
                 signal powerlink_0_PDI_AP_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal powerlink_0_PDI_AP_wait_counter_eq_0 : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_irq_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;
                 signal avalon_address_from_the_avalon_master_bridge_0_to_slave : OUT STD_LOGIC_VECTOR (14 DOWNTO 0);
                 signal avalon_master_bridge_0_latency_counter : OUT STD_LOGIC;
                 signal avalon_readdata_to_the_avalon_master_bridge_0 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal avalon_readdatavalid_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;
                 signal avalon_waitrequest_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;
                 signal reset_to_the_avalon_master_bridge_0 : OUT STD_LOGIC
              );
end entity avalon_master_bridge_0_AvalonMaster_arbitrator;


architecture europa of avalon_master_bridge_0_AvalonMaster_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal avalon_address_from_the_avalon_master_bridge_0_last_time :  STD_LOGIC_VECTOR (14 DOWNTO 0);
                signal avalon_byteenable_from_the_avalon_master_bridge_0_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal avalon_master_bridge_0_AvalonMaster_run :  STD_LOGIC;
                signal avalon_read_from_the_avalon_master_bridge_0_last_time :  STD_LOGIC;
                signal avalon_write_from_the_avalon_master_bridge_0_last_time :  STD_LOGIC;
                signal avalon_writedata_from_the_avalon_master_bridge_0_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_avalon_address_from_the_avalon_master_bridge_0_to_slave :  STD_LOGIC_VECTOR (14 DOWNTO 0);
                signal internal_avalon_waitrequest_to_the_avalon_master_bridge_1 :  STD_LOGIC;
                signal pre_flush_avalon_readdatavalid_to_the_avalon_master_bridge_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;

begin

  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP OR NOT avalon_master_bridge_0_requests_powerlink_0_PDI_AP)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP OR NOT avalon_read_from_the_avalon_master_bridge_0)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((powerlink_0_PDI_AP_wait_counter_eq_0 AND NOT d1_powerlink_0_PDI_AP_end_xfer)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(avalon_read_from_the_avalon_master_bridge_0)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP OR NOT avalon_write_from_the_avalon_master_bridge_0)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(avalon_write_from_the_avalon_master_bridge_0)))))))));
  --cascaded wait assignment, which is an e_assign
  avalon_master_bridge_0_AvalonMaster_run <= r_1;
  --optimize select-logic by passing only those address bits which matter.
  internal_avalon_address_from_the_avalon_master_bridge_0_to_slave <= avalon_address_from_the_avalon_master_bridge_0(14 DOWNTO 0);
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_avalon_readdatavalid_to_the_avalon_master_bridge_0 <= std_logic'('0');
  --latent slave read data valid which is not flushed, which is an e_mux
  avalon_readdatavalid_to_the_avalon_master_bridge_0 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000000") OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pre_flush_avalon_readdatavalid_to_the_avalon_master_bridge_0)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(avalon_master_bridge_0_read_data_valid_powerlink_0_PDI_AP)))));
  --avalon_master_bridge_0/AvalonMaster readdata mux, which is an e_mux
  avalon_readdata_to_the_avalon_master_bridge_0 <= powerlink_0_PDI_AP_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_avalon_waitrequest_to_the_avalon_master_bridge_1 <= NOT avalon_master_bridge_0_AvalonMaster_run;
  --latent max counter, which is an e_assign
  avalon_master_bridge_0_latency_counter <= std_logic'('0');
  --~reset_to_the_avalon_master_bridge_0 assignment, which is an e_assign
  reset_to_the_avalon_master_bridge_0 <= NOT reset_n;
  --irq assign, which is an e_assign
  ap_irq_to_the_avalon_master_bridge_0 <= powerlink_0_PDI_AP_irq_from_sa;
  --vhdl renameroo for output signals
  avalon_address_from_the_avalon_master_bridge_0_to_slave <= internal_avalon_address_from_the_avalon_master_bridge_0_to_slave;
  --vhdl renameroo for output signals
  avalon_waitrequest_to_the_avalon_master_bridge_0 <= internal_avalon_waitrequest_to_the_avalon_master_bridge_1;
--synthesis translate_off
    --avalon_address_from_the_avalon_master_bridge_0 check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        avalon_address_from_the_avalon_master_bridge_0_last_time <= std_logic_vector'("000000000000000");
      elsif clk'event and clk = '1' then
        avalon_address_from_the_avalon_master_bridge_0_last_time <= avalon_address_from_the_avalon_master_bridge_0;
      end if;

    end process;

    --avalon_master_bridge_0/AvalonMaster waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_avalon_waitrequest_to_the_avalon_master_bridge_1 AND ((avalon_read_from_the_avalon_master_bridge_0 OR avalon_write_from_the_avalon_master_bridge_0));
      end if;

    end process;

    --avalon_address_from_the_avalon_master_bridge_0 matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((avalon_address_from_the_avalon_master_bridge_0 /= avalon_address_from_the_avalon_master_bridge_0_last_time))))) = '1' then 
          write(write_line, now);
          write(write_line, string'(": "));
          write(write_line, string'("avalon_address_from_the_avalon_master_bridge_0 did not heed wait!!!"));
          write(output, write_line.all);
          deallocate (write_line);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --avalon_byteenable_from_the_avalon_master_bridge_0 check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        avalon_byteenable_from_the_avalon_master_bridge_0_last_time <= std_logic_vector'("0000");
      elsif clk'event and clk = '1' then
        avalon_byteenable_from_the_avalon_master_bridge_0_last_time <= avalon_byteenable_from_the_avalon_master_bridge_0;
      end if;

    end process;

    --avalon_byteenable_from_the_avalon_master_bridge_0 matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line1 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((avalon_byteenable_from_the_avalon_master_bridge_0 /= avalon_byteenable_from_the_avalon_master_bridge_0_last_time))))) = '1' then 
          write(write_line1, now);
          write(write_line1, string'(": "));
          write(write_line1, string'("avalon_byteenable_from_the_avalon_master_bridge_0 did not heed wait!!!"));
          write(output, write_line1.all);
          deallocate (write_line1);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --avalon_read_from_the_avalon_master_bridge_0 check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        avalon_read_from_the_avalon_master_bridge_0_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        avalon_read_from_the_avalon_master_bridge_0_last_time <= avalon_read_from_the_avalon_master_bridge_0;
      end if;

    end process;

    --avalon_read_from_the_avalon_master_bridge_0 matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line2 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(avalon_read_from_the_avalon_master_bridge_0) /= std_logic'(avalon_read_from_the_avalon_master_bridge_0_last_time)))))) = '1' then 
          write(write_line2, now);
          write(write_line2, string'(": "));
          write(write_line2, string'("avalon_read_from_the_avalon_master_bridge_0 did not heed wait!!!"));
          write(output, write_line2.all);
          deallocate (write_line2);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --avalon_write_from_the_avalon_master_bridge_0 check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        avalon_write_from_the_avalon_master_bridge_0_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        avalon_write_from_the_avalon_master_bridge_0_last_time <= avalon_write_from_the_avalon_master_bridge_0;
      end if;

    end process;

    --avalon_write_from_the_avalon_master_bridge_0 matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line3 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(avalon_write_from_the_avalon_master_bridge_0) /= std_logic'(avalon_write_from_the_avalon_master_bridge_0_last_time)))))) = '1' then 
          write(write_line3, now);
          write(write_line3, string'(": "));
          write(write_line3, string'("avalon_write_from_the_avalon_master_bridge_0 did not heed wait!!!"));
          write(output, write_line3.all);
          deallocate (write_line3);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --avalon_writedata_from_the_avalon_master_bridge_0 check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        avalon_writedata_from_the_avalon_master_bridge_0_last_time <= std_logic_vector'("00000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        avalon_writedata_from_the_avalon_master_bridge_0_last_time <= avalon_writedata_from_the_avalon_master_bridge_0;
      end if;

    end process;

    --avalon_writedata_from_the_avalon_master_bridge_0 matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line4 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((avalon_writedata_from_the_avalon_master_bridge_0 /= avalon_writedata_from_the_avalon_master_bridge_0_last_time)))) AND avalon_write_from_the_avalon_master_bridge_0)) = '1' then 
          write(write_line4, now);
          write(write_line4, string'(": "));
          write(write_line4, string'("avalon_writedata_from_the_avalon_master_bridge_0 did not heed wait!!!"));
          write(output, write_line4.all);
          deallocate (write_line4);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rdv_fifo_for_pcp_cpu_data_master_to_clock_crossing_0_s1_module is 
        port (
              -- inputs:
                 signal clear_fifo : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_reset : IN STD_LOGIC;
                 signal write : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC;
                 signal empty : OUT STD_LOGIC;
                 signal fifo_contains_ones_n : OUT STD_LOGIC;
                 signal full : OUT STD_LOGIC
              );
end entity rdv_fifo_for_pcp_cpu_data_master_to_clock_crossing_0_s1_module;


architecture europa of rdv_fifo_for_pcp_cpu_data_master_to_clock_crossing_0_s1_module is
                signal full_0 :  STD_LOGIC;
                signal full_1 :  STD_LOGIC;
                signal full_10 :  STD_LOGIC;
                signal full_11 :  STD_LOGIC;
                signal full_12 :  STD_LOGIC;
                signal full_13 :  STD_LOGIC;
                signal full_14 :  STD_LOGIC;
                signal full_15 :  STD_LOGIC;
                signal full_16 :  STD_LOGIC;
                signal full_17 :  STD_LOGIC;
                signal full_18 :  STD_LOGIC;
                signal full_19 :  STD_LOGIC;
                signal full_2 :  STD_LOGIC;
                signal full_20 :  STD_LOGIC;
                signal full_21 :  STD_LOGIC;
                signal full_22 :  STD_LOGIC;
                signal full_23 :  STD_LOGIC;
                signal full_24 :  STD_LOGIC;
                signal full_25 :  STD_LOGIC;
                signal full_26 :  STD_LOGIC;
                signal full_27 :  STD_LOGIC;
                signal full_28 :  STD_LOGIC;
                signal full_29 :  STD_LOGIC;
                signal full_3 :  STD_LOGIC;
                signal full_30 :  STD_LOGIC;
                signal full_31 :  STD_LOGIC;
                signal full_32 :  STD_LOGIC;
                signal full_4 :  STD_LOGIC;
                signal full_5 :  STD_LOGIC;
                signal full_6 :  STD_LOGIC;
                signal full_7 :  STD_LOGIC;
                signal full_8 :  STD_LOGIC;
                signal full_9 :  STD_LOGIC;
                signal how_many_ones :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_minus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal one_count_plus_one :  STD_LOGIC_VECTOR (6 DOWNTO 0);
                signal p0_full_0 :  STD_LOGIC;
                signal p0_stage_0 :  STD_LOGIC;
                signal p10_full_10 :  STD_LOGIC;
                signal p10_stage_10 :  STD_LOGIC;
                signal p11_full_11 :  STD_LOGIC;
                signal p11_stage_11 :  STD_LOGIC;
                signal p12_full_12 :  STD_LOGIC;
                signal p12_stage_12 :  STD_LOGIC;
                signal p13_full_13 :  STD_LOGIC;
                signal p13_stage_13 :  STD_LOGIC;
                signal p14_full_14 :  STD_LOGIC;
                signal p14_stage_14 :  STD_LOGIC;
                signal p15_full_15 :  STD_LOGIC;
                signal p15_stage_15 :  STD_LOGIC;
                signal p16_full_16 :  STD_LOGIC;
                signal p16_stage_16 :  STD_LOGIC;
                signal p17_full_17 :  STD_LOGIC;
                signal p17_stage_17 :  STD_LOGIC;
                signal p18_full_18 :  STD_LOGIC;
                signal p18_stage_18 :  STD_LOGIC;
                signal p19_full_19 :  STD_LOGIC;
                signal p19_stage_19 :  STD_LOGIC;
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC;
                signal p20_full_20 :  STD_LOGIC;
                signal p20_stage_20 :  STD_LOGIC;
                signal p21_full_21 :  STD_LOGIC;
                signal p21_stage_21 :  STD_LOGIC;
                signal p22_full_22 :  STD_LOGIC;
                signal p22_stage_22 :  STD_LOGIC;
                signal p23_full_23 :  STD_LOGIC;
                signal p23_stage_23 :  STD_LOGIC;
                signal p24_full_24 :  STD_LOGIC;
                signal p24_stage_24 :  STD_LOGIC;
                signal p25_full_25 :  STD_LOGIC;
                signal p25_stage_25 :  STD_LOGIC;
                signal p26_full_26 :  STD_LOGIC;
                signal p26_stage_26 :  STD_LOGIC;
                signal p27_full_27 :  STD_LOGIC;
                signal p27_stage_27 :  STD_LOGIC;
                signal p28_full_28 :  STD_LOGIC;
                signal p28_stage_28 :  STD_LOGIC;
                signal p29_full_29 :  STD_LOGIC;
                signal p29_stage_29 :  STD_LOGIC;
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC;
                signal p30_full_30 :  STD_LOGIC;
                signal p30_stage_30 :  STD_LOGIC;
                signal p31_full_31 :  STD_LOGIC;
                signal p31_stage_31 :  STD_LOGIC;
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC;
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC;
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC;
                signal p6_full_6 :  STD_LOGIC;
                signal p6_stage_6 :  STD_LOGIC;
                signal p7_full_7 :  STD_LOGIC;
                signal p7_stage_7 :  STD_LOGIC;
                signal p8_full_8 :  STD_LOGIC;
                signal p8_stage_8 :  STD_LOGIC;
                signal p9_full_9 :  STD_LOGIC;
                signal p9_stage_9 :  STD_LOGIC;
                signal stage_0 :  STD_LOGIC;
                signal stage_1 :  STD_LOGIC;
                signal stage_10 :  STD_LOGIC;
                signal stage_11 :  STD_LOGIC;
                signal stage_12 :  STD_LOGIC;
                signal stage_13 :  STD_LOGIC;
                signal stage_14 :  STD_LOGIC;
                signal stage_15 :  STD_LOGIC;
                signal stage_16 :  STD_LOGIC;
                signal stage_17 :  STD_LOGIC;
                signal stage_18 :  STD_LOGIC;
                signal stage_19 :  STD_LOGIC;
                signal stage_2 :  STD_LOGIC;
                signal stage_20 :  STD_LOGIC;
                signal stage_21 :  STD_LOGIC;
                signal stage_22 :  STD_LOGIC;
                signal stage_23 :  STD_LOGIC;
                signal stage_24 :  STD_LOGIC;
                signal stage_25 :  STD_LOGIC;
                signal stage_26 :  STD_LOGIC;
                signal stage_27 :  STD_LOGIC;
                signal stage_28 :  STD_LOGIC;
                signal stage_29 :  STD_LOGIC;
                signal stage_3 :  STD_LOGIC;
                signal stage_30 :  STD_LOGIC;
                signal stage_31 :  STD_LOGIC;
                signal stage_4 :  STD_LOGIC;
                signal stage_5 :  STD_LOGIC;
                signal stage_6 :  STD_LOGIC;
                signal stage_7 :  STD_LOGIC;
                signal stage_8 :  STD_LOGIC;
                signal stage_9 :  STD_LOGIC;
                signal updated_one_count :  STD_LOGIC_VECTOR (6 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_31;
  empty <= NOT(full_0);
  full_32 <= std_logic'('0');
  --data_31, which is an e_mux
  p31_stage_31 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_32 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
  --data_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_31))))) = '1' then 
        if std_logic'(((sync_reset AND full_31) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_32))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_31 <= std_logic'('0');
        else
          stage_31 <= p31_stage_31;
        end if;
      end if;
    end if;

  end process;

  --control_31, which is an e_mux
  p31_full_31 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))), std_logic_vector'("00000000000000000000000000000000")));
  --control_reg_31, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_31 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_31 <= std_logic'('0');
        else
          full_31 <= p31_full_31;
        end if;
      end if;
    end if;

  end process;

  --data_30, which is an e_mux
  p30_stage_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_31 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_31);
  --data_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_30))))) = '1' then 
        if std_logic'(((sync_reset AND full_30) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_31))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_30 <= std_logic'('0');
        else
          stage_30 <= p30_stage_30;
        end if;
      end if;
    end if;

  end process;

  --control_30, which is an e_mux
  p30_full_30 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_29, full_31);
  --control_reg_30, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_30 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_30 <= std_logic'('0');
        else
          full_30 <= p30_full_30;
        end if;
      end if;
    end if;

  end process;

  --data_29, which is an e_mux
  p29_stage_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_30 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_30);
  --data_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_29))))) = '1' then 
        if std_logic'(((sync_reset AND full_29) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_30))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_29 <= std_logic'('0');
        else
          stage_29 <= p29_stage_29;
        end if;
      end if;
    end if;

  end process;

  --control_29, which is an e_mux
  p29_full_29 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_28, full_30);
  --control_reg_29, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_29 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_29 <= std_logic'('0');
        else
          full_29 <= p29_full_29;
        end if;
      end if;
    end if;

  end process;

  --data_28, which is an e_mux
  p28_stage_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_29 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_29);
  --data_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_28))))) = '1' then 
        if std_logic'(((sync_reset AND full_28) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_29))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_28 <= std_logic'('0');
        else
          stage_28 <= p28_stage_28;
        end if;
      end if;
    end if;

  end process;

  --control_28, which is an e_mux
  p28_full_28 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_27, full_29);
  --control_reg_28, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_28 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_28 <= std_logic'('0');
        else
          full_28 <= p28_full_28;
        end if;
      end if;
    end if;

  end process;

  --data_27, which is an e_mux
  p27_stage_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_28 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_28);
  --data_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_27))))) = '1' then 
        if std_logic'(((sync_reset AND full_27) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_28))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_27 <= std_logic'('0');
        else
          stage_27 <= p27_stage_27;
        end if;
      end if;
    end if;

  end process;

  --control_27, which is an e_mux
  p27_full_27 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_26, full_28);
  --control_reg_27, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_27 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_27 <= std_logic'('0');
        else
          full_27 <= p27_full_27;
        end if;
      end if;
    end if;

  end process;

  --data_26, which is an e_mux
  p26_stage_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_27 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_27);
  --data_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_26))))) = '1' then 
        if std_logic'(((sync_reset AND full_26) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_27))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_26 <= std_logic'('0');
        else
          stage_26 <= p26_stage_26;
        end if;
      end if;
    end if;

  end process;

  --control_26, which is an e_mux
  p26_full_26 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_25, full_27);
  --control_reg_26, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_26 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_26 <= std_logic'('0');
        else
          full_26 <= p26_full_26;
        end if;
      end if;
    end if;

  end process;

  --data_25, which is an e_mux
  p25_stage_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_26 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_26);
  --data_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_25))))) = '1' then 
        if std_logic'(((sync_reset AND full_25) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_26))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_25 <= std_logic'('0');
        else
          stage_25 <= p25_stage_25;
        end if;
      end if;
    end if;

  end process;

  --control_25, which is an e_mux
  p25_full_25 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_24, full_26);
  --control_reg_25, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_25 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_25 <= std_logic'('0');
        else
          full_25 <= p25_full_25;
        end if;
      end if;
    end if;

  end process;

  --data_24, which is an e_mux
  p24_stage_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_25 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_25);
  --data_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_24))))) = '1' then 
        if std_logic'(((sync_reset AND full_24) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_25))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_24 <= std_logic'('0');
        else
          stage_24 <= p24_stage_24;
        end if;
      end if;
    end if;

  end process;

  --control_24, which is an e_mux
  p24_full_24 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_23, full_25);
  --control_reg_24, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_24 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_24 <= std_logic'('0');
        else
          full_24 <= p24_full_24;
        end if;
      end if;
    end if;

  end process;

  --data_23, which is an e_mux
  p23_stage_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_24 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_24);
  --data_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_23))))) = '1' then 
        if std_logic'(((sync_reset AND full_23) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_24))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_23 <= std_logic'('0');
        else
          stage_23 <= p23_stage_23;
        end if;
      end if;
    end if;

  end process;

  --control_23, which is an e_mux
  p23_full_23 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_22, full_24);
  --control_reg_23, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_23 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_23 <= std_logic'('0');
        else
          full_23 <= p23_full_23;
        end if;
      end if;
    end if;

  end process;

  --data_22, which is an e_mux
  p22_stage_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_23 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_23);
  --data_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_22))))) = '1' then 
        if std_logic'(((sync_reset AND full_22) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_23))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_22 <= std_logic'('0');
        else
          stage_22 <= p22_stage_22;
        end if;
      end if;
    end if;

  end process;

  --control_22, which is an e_mux
  p22_full_22 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_21, full_23);
  --control_reg_22, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_22 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_22 <= std_logic'('0');
        else
          full_22 <= p22_full_22;
        end if;
      end if;
    end if;

  end process;

  --data_21, which is an e_mux
  p21_stage_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_22 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_22);
  --data_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_21))))) = '1' then 
        if std_logic'(((sync_reset AND full_21) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_22))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_21 <= std_logic'('0');
        else
          stage_21 <= p21_stage_21;
        end if;
      end if;
    end if;

  end process;

  --control_21, which is an e_mux
  p21_full_21 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_20, full_22);
  --control_reg_21, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_21 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_21 <= std_logic'('0');
        else
          full_21 <= p21_full_21;
        end if;
      end if;
    end if;

  end process;

  --data_20, which is an e_mux
  p20_stage_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_21 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_21);
  --data_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_20))))) = '1' then 
        if std_logic'(((sync_reset AND full_20) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_21))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_20 <= std_logic'('0');
        else
          stage_20 <= p20_stage_20;
        end if;
      end if;
    end if;

  end process;

  --control_20, which is an e_mux
  p20_full_20 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_19, full_21);
  --control_reg_20, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_20 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_20 <= std_logic'('0');
        else
          full_20 <= p20_full_20;
        end if;
      end if;
    end if;

  end process;

  --data_19, which is an e_mux
  p19_stage_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_20 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_20);
  --data_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_19))))) = '1' then 
        if std_logic'(((sync_reset AND full_19) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_20))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_19 <= std_logic'('0');
        else
          stage_19 <= p19_stage_19;
        end if;
      end if;
    end if;

  end process;

  --control_19, which is an e_mux
  p19_full_19 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_18, full_20);
  --control_reg_19, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_19 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_19 <= std_logic'('0');
        else
          full_19 <= p19_full_19;
        end if;
      end if;
    end if;

  end process;

  --data_18, which is an e_mux
  p18_stage_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_19 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_19);
  --data_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_18))))) = '1' then 
        if std_logic'(((sync_reset AND full_18) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_19))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_18 <= std_logic'('0');
        else
          stage_18 <= p18_stage_18;
        end if;
      end if;
    end if;

  end process;

  --control_18, which is an e_mux
  p18_full_18 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_17, full_19);
  --control_reg_18, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_18 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_18 <= std_logic'('0');
        else
          full_18 <= p18_full_18;
        end if;
      end if;
    end if;

  end process;

  --data_17, which is an e_mux
  p17_stage_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_18 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_18);
  --data_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_17))))) = '1' then 
        if std_logic'(((sync_reset AND full_17) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_18))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_17 <= std_logic'('0');
        else
          stage_17 <= p17_stage_17;
        end if;
      end if;
    end if;

  end process;

  --control_17, which is an e_mux
  p17_full_17 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_16, full_18);
  --control_reg_17, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_17 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_17 <= std_logic'('0');
        else
          full_17 <= p17_full_17;
        end if;
      end if;
    end if;

  end process;

  --data_16, which is an e_mux
  p16_stage_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_17 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_17);
  --data_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_16))))) = '1' then 
        if std_logic'(((sync_reset AND full_16) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_17))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_16 <= std_logic'('0');
        else
          stage_16 <= p16_stage_16;
        end if;
      end if;
    end if;

  end process;

  --control_16, which is an e_mux
  p16_full_16 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_15, full_17);
  --control_reg_16, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_16 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_16 <= std_logic'('0');
        else
          full_16 <= p16_full_16;
        end if;
      end if;
    end if;

  end process;

  --data_15, which is an e_mux
  p15_stage_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_16 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_16);
  --data_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_15))))) = '1' then 
        if std_logic'(((sync_reset AND full_15) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_16))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_15 <= std_logic'('0');
        else
          stage_15 <= p15_stage_15;
        end if;
      end if;
    end if;

  end process;

  --control_15, which is an e_mux
  p15_full_15 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_14, full_16);
  --control_reg_15, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_15 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_15 <= std_logic'('0');
        else
          full_15 <= p15_full_15;
        end if;
      end if;
    end if;

  end process;

  --data_14, which is an e_mux
  p14_stage_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_15 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_15);
  --data_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_14))))) = '1' then 
        if std_logic'(((sync_reset AND full_14) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_15))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_14 <= std_logic'('0');
        else
          stage_14 <= p14_stage_14;
        end if;
      end if;
    end if;

  end process;

  --control_14, which is an e_mux
  p14_full_14 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_13, full_15);
  --control_reg_14, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_14 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_14 <= std_logic'('0');
        else
          full_14 <= p14_full_14;
        end if;
      end if;
    end if;

  end process;

  --data_13, which is an e_mux
  p13_stage_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_14 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_14);
  --data_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_13))))) = '1' then 
        if std_logic'(((sync_reset AND full_13) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_14))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_13 <= std_logic'('0');
        else
          stage_13 <= p13_stage_13;
        end if;
      end if;
    end if;

  end process;

  --control_13, which is an e_mux
  p13_full_13 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_12, full_14);
  --control_reg_13, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_13 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_13 <= std_logic'('0');
        else
          full_13 <= p13_full_13;
        end if;
      end if;
    end if;

  end process;

  --data_12, which is an e_mux
  p12_stage_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_13 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_13);
  --data_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_12))))) = '1' then 
        if std_logic'(((sync_reset AND full_12) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_13))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_12 <= std_logic'('0');
        else
          stage_12 <= p12_stage_12;
        end if;
      end if;
    end if;

  end process;

  --control_12, which is an e_mux
  p12_full_12 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_11, full_13);
  --control_reg_12, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_12 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_12 <= std_logic'('0');
        else
          full_12 <= p12_full_12;
        end if;
      end if;
    end if;

  end process;

  --data_11, which is an e_mux
  p11_stage_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_12 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_12);
  --data_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_11))))) = '1' then 
        if std_logic'(((sync_reset AND full_11) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_12))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_11 <= std_logic'('0');
        else
          stage_11 <= p11_stage_11;
        end if;
      end if;
    end if;

  end process;

  --control_11, which is an e_mux
  p11_full_11 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_10, full_12);
  --control_reg_11, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_11 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_11 <= std_logic'('0');
        else
          full_11 <= p11_full_11;
        end if;
      end if;
    end if;

  end process;

  --data_10, which is an e_mux
  p10_stage_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_11 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_11);
  --data_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_10))))) = '1' then 
        if std_logic'(((sync_reset AND full_10) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_11))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_10 <= std_logic'('0');
        else
          stage_10 <= p10_stage_10;
        end if;
      end if;
    end if;

  end process;

  --control_10, which is an e_mux
  p10_full_10 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_9, full_11);
  --control_reg_10, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_10 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_10 <= std_logic'('0');
        else
          full_10 <= p10_full_10;
        end if;
      end if;
    end if;

  end process;

  --data_9, which is an e_mux
  p9_stage_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_10 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_10);
  --data_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_9))))) = '1' then 
        if std_logic'(((sync_reset AND full_9) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_10))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_9 <= std_logic'('0');
        else
          stage_9 <= p9_stage_9;
        end if;
      end if;
    end if;

  end process;

  --control_9, which is an e_mux
  p9_full_9 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_8, full_10);
  --control_reg_9, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_9 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_9 <= std_logic'('0');
        else
          full_9 <= p9_full_9;
        end if;
      end if;
    end if;

  end process;

  --data_8, which is an e_mux
  p8_stage_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_9 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_9);
  --data_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_8))))) = '1' then 
        if std_logic'(((sync_reset AND full_8) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_9))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_8 <= std_logic'('0');
        else
          stage_8 <= p8_stage_8;
        end if;
      end if;
    end if;

  end process;

  --control_8, which is an e_mux
  p8_full_8 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_7, full_9);
  --control_reg_8, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_8 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_8 <= std_logic'('0');
        else
          full_8 <= p8_full_8;
        end if;
      end if;
    end if;

  end process;

  --data_7, which is an e_mux
  p7_stage_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_8 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_8);
  --data_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_7))))) = '1' then 
        if std_logic'(((sync_reset AND full_7) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_8))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_7 <= std_logic'('0');
        else
          stage_7 <= p7_stage_7;
        end if;
      end if;
    end if;

  end process;

  --control_7, which is an e_mux
  p7_full_7 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_6, full_8);
  --control_reg_7, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_7 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_7 <= std_logic'('0');
        else
          full_7 <= p7_full_7;
        end if;
      end if;
    end if;

  end process;

  --data_6, which is an e_mux
  p6_stage_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_7 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_7);
  --data_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_6))))) = '1' then 
        if std_logic'(((sync_reset AND full_6) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_7))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_6 <= std_logic'('0');
        else
          stage_6 <= p6_stage_6;
        end if;
      end if;
    end if;

  end process;

  --control_6, which is an e_mux
  p6_full_6 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_5, full_7);
  --control_reg_6, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_6 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_6 <= std_logic'('0');
        else
          full_6 <= p6_full_6;
        end if;
      end if;
    end if;

  end process;

  --data_5, which is an e_mux
  p5_stage_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_6);
  --data_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_5))))) = '1' then 
        if std_logic'(((sync_reset AND full_5) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_6))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_5 <= std_logic'('0');
        else
          stage_5 <= p5_stage_5;
        end if;
      end if;
    end if;

  end process;

  --control_5, which is an e_mux
  p5_full_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_4, full_6);
  --control_reg_5, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_5 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_5 <= std_logic'('0');
        else
          full_5 <= p5_full_5;
        end if;
      end if;
    end if;

  end process;

  --data_4, which is an e_mux
  p4_stage_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_5 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_5);
  --data_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_4))))) = '1' then 
        if std_logic'(((sync_reset AND full_4) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_5))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_4 <= std_logic'('0');
        else
          stage_4 <= p4_stage_4;
        end if;
      end if;
    end if;

  end process;

  --control_4, which is an e_mux
  p4_full_4 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_3, full_5);
  --control_reg_4, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_4 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_4 <= std_logic'('0');
        else
          full_4 <= p4_full_4;
        end if;
      end if;
    end if;

  end process;

  --data_3, which is an e_mux
  p3_stage_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_4 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_4);
  --data_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_3))))) = '1' then 
        if std_logic'(((sync_reset AND full_3) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_3 <= std_logic'('0');
        else
          stage_3 <= p3_stage_3;
        end if;
      end if;
    end if;

  end process;

  --control_3, which is an e_mux
  p3_full_3 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_2, full_4);
  --control_reg_3, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_3 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_3 <= std_logic'('0');
        else
          full_3 <= p3_full_3;
        end if;
      end if;
    end if;

  end process;

  --data_2, which is an e_mux
  p2_stage_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_3 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_3);
  --data_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_2))))) = '1' then 
        if std_logic'(((sync_reset AND full_2) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_3))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_2 <= std_logic'('0');
        else
          stage_2 <= p2_stage_2;
        end if;
      end if;
    end if;

  end process;

  --control_2, which is an e_mux
  p2_full_2 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_1, full_3);
  --control_reg_2, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_2 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_2 <= std_logic'('0');
        else
          full_2 <= p2_full_2;
        end if;
      end if;
    end if;

  end process;

  --data_1, which is an e_mux
  p1_stage_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_2 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_2);
  --data_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_1))))) = '1' then 
        if std_logic'(((sync_reset AND full_1) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_2))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_1 <= std_logic'('0');
        else
          stage_1 <= p1_stage_1;
        end if;
      end if;
    end if;

  end process;

  --control_1, which is an e_mux
  p1_full_1 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), full_0, full_2);
  --control_reg_1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(clear_fifo) = '1' then 
          full_1 <= std_logic'('0');
        else
          full_1 <= p1_full_1;
        end if;
      end if;
    end if;

  end process;

  --data_0, which is an e_mux
  p0_stage_0 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_1 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, stage_1);
  --data_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      stage_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'(((sync_reset AND full_0) AND NOT((((to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1))) = std_logic_vector'("00000000000000000000000000000000")))) AND read) AND write))))) = '1' then 
          stage_0 <= std_logic'('0');
        else
          stage_0 <= p0_stage_0;
        end if;
      end if;
    end if;

  end process;

  --control_0, which is an e_mux
  p0_full_0 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), std_logic_vector'("00000000000000000000000000000001"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_1)))));
  --control_reg_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      full_0 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(((clear_fifo OR ((read XOR write))) OR ((write AND NOT(full_0))))) = '1' then 
        if std_logic'((clear_fifo AND NOT write)) = '1' then 
          full_0 <= std_logic'('0');
        else
          full_0 <= p0_full_0;
        end if;
      end if;
    end if;

  end process;

  one_count_plus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) + std_logic_vector'("000000000000000000000000000000001")), 7);
  one_count_minus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000") & (how_many_ones)) - std_logic_vector'("000000000000000000000000000000001")), 7);
  --updated_one_count, which is an e_mux
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000000") & (A_TOSTDLOGICVECTOR(data_in))), A_WE_StdLogicVector((std_logic'(((((read AND (data_in)) AND write) AND (stage_0)))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (data_in)))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (stage_0)))) = '1'), one_count_minus_one, how_many_ones))))))), 7);
  --counts how many ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      how_many_ones <= std_logic_vector'("0000000");
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        how_many_ones <= updated_one_count;
      end if;
    end if;

  end process;

  --this fifo contains ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      fifo_contains_ones_n <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'((((clear_fifo OR sync_reset) OR read) OR write)) = '1' then 
        fifo_contains_ones_n <= NOT (or_reduce(updated_one_count));
      end if;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity clock_crossing_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_s1_endofpacket : IN STD_LOGIC;
                 signal clock_crossing_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clock_crossing_0_s1_readdatavalid : IN STD_LOGIC;
                 signal clock_crossing_0_s1_waitrequest : IN STD_LOGIC;
                 signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal pcp_cpu_data_master_read : IN STD_LOGIC;
                 signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal pcp_cpu_data_master_write : IN STD_LOGIC;
                 signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal clock_crossing_0_s1_address : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                 signal clock_crossing_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal clock_crossing_0_s1_endofpacket_from_sa : OUT STD_LOGIC;
                 signal clock_crossing_0_s1_nativeaddress : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                 signal clock_crossing_0_s1_read : OUT STD_LOGIC;
                 signal clock_crossing_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clock_crossing_0_s1_reset_n : OUT STD_LOGIC;
                 signal clock_crossing_0_s1_waitrequest_from_sa : OUT STD_LOGIC;
                 signal clock_crossing_0_s1_write : OUT STD_LOGIC;
                 signal clock_crossing_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_clock_crossing_0_s1_end_xfer : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_granted_clock_crossing_0_s1 : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_clock_crossing_0_s1 : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1 : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_requests_clock_crossing_0_s1 : OUT STD_LOGIC
              );
end entity clock_crossing_0_s1_arbitrator;


architecture europa of clock_crossing_0_s1_arbitrator is
component rdv_fifo_for_pcp_cpu_data_master_to_clock_crossing_0_s1_module is 
           port (
                 -- inputs:
                    signal clear_fifo : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC;
                    signal empty : OUT STD_LOGIC;
                    signal fifo_contains_ones_n : OUT STD_LOGIC;
                    signal full : OUT STD_LOGIC
                 );
end component rdv_fifo_for_pcp_cpu_data_master_to_clock_crossing_0_s1_module;

                signal clock_crossing_0_s1_allgrants :  STD_LOGIC;
                signal clock_crossing_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal clock_crossing_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal clock_crossing_0_s1_any_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_s1_arb_counter_enable :  STD_LOGIC;
                signal clock_crossing_0_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal clock_crossing_0_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal clock_crossing_0_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal clock_crossing_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal clock_crossing_0_s1_begins_xfer :  STD_LOGIC;
                signal clock_crossing_0_s1_end_xfer :  STD_LOGIC;
                signal clock_crossing_0_s1_firsttransfer :  STD_LOGIC;
                signal clock_crossing_0_s1_grant_vector :  STD_LOGIC;
                signal clock_crossing_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal clock_crossing_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal clock_crossing_0_s1_master_qreq_vector :  STD_LOGIC;
                signal clock_crossing_0_s1_move_on_to_next_transaction :  STD_LOGIC;
                signal clock_crossing_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal clock_crossing_0_s1_readdatavalid_from_sa :  STD_LOGIC;
                signal clock_crossing_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal clock_crossing_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal clock_crossing_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal clock_crossing_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal clock_crossing_0_s1_waits_for_read :  STD_LOGIC;
                signal clock_crossing_0_s1_waits_for_write :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_clock_crossing_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_s1_waitrequest_from_sa :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_granted_clock_crossing_0_s1 :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_qualified_request_clock_crossing_0_s1 :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_requests_clock_crossing_0_s1 :  STD_LOGIC;
                signal module_input :  STD_LOGIC;
                signal module_input1 :  STD_LOGIC;
                signal module_input2 :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_data_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_data_master_rdv_fifo_empty_clock_crossing_0_s1 :  STD_LOGIC;
                signal pcp_cpu_data_master_rdv_fifo_output_from_clock_crossing_0_s1 :  STD_LOGIC;
                signal pcp_cpu_data_master_saved_grant_clock_crossing_0_s1 :  STD_LOGIC;
                signal shifted_address_to_clock_crossing_0_s1_from_pcp_cpu_data_master :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal wait_for_clock_crossing_0_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT clock_crossing_0_s1_end_xfer;
    end if;

  end process;

  clock_crossing_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_pcp_cpu_data_master_qualified_request_clock_crossing_0_s1);
  --assign clock_crossing_0_s1_readdata_from_sa = clock_crossing_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  clock_crossing_0_s1_readdata_from_sa <= clock_crossing_0_s1_readdata;
  internal_pcp_cpu_data_master_requests_clock_crossing_0_s1 <= to_std_logic(((Std_Logic_Vector'(pcp_cpu_data_master_address_to_slave(24 DOWNTO 14) & std_logic_vector'("00000000000000")) = std_logic_vector'("1000000000000000000000000")))) AND ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write));
  --assign clock_crossing_0_s1_waitrequest_from_sa = clock_crossing_0_s1_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_clock_crossing_0_s1_waitrequest_from_sa <= clock_crossing_0_s1_waitrequest;
  --assign clock_crossing_0_s1_readdatavalid_from_sa = clock_crossing_0_s1_readdatavalid so that symbol knows where to group signals which may go to master only, which is an e_assign
  clock_crossing_0_s1_readdatavalid_from_sa <= clock_crossing_0_s1_readdatavalid;
  --clock_crossing_0_s1_arb_share_counter set values, which is an e_mux
  clock_crossing_0_s1_arb_share_set_values <= std_logic_vector'("01");
  --clock_crossing_0_s1_non_bursting_master_requests mux, which is an e_mux
  clock_crossing_0_s1_non_bursting_master_requests <= internal_pcp_cpu_data_master_requests_clock_crossing_0_s1;
  --clock_crossing_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  clock_crossing_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --clock_crossing_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  clock_crossing_0_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(clock_crossing_0_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (clock_crossing_0_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(clock_crossing_0_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (clock_crossing_0_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --clock_crossing_0_s1_allgrants all slave grants, which is an e_mux
  clock_crossing_0_s1_allgrants <= clock_crossing_0_s1_grant_vector;
  --clock_crossing_0_s1_end_xfer assignment, which is an e_assign
  clock_crossing_0_s1_end_xfer <= NOT ((clock_crossing_0_s1_waits_for_read OR clock_crossing_0_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_clock_crossing_0_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_clock_crossing_0_s1 <= clock_crossing_0_s1_end_xfer AND (((NOT clock_crossing_0_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --clock_crossing_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  clock_crossing_0_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_clock_crossing_0_s1 AND clock_crossing_0_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_clock_crossing_0_s1 AND NOT clock_crossing_0_s1_non_bursting_master_requests));
  --clock_crossing_0_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      clock_crossing_0_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(clock_crossing_0_s1_arb_counter_enable) = '1' then 
        clock_crossing_0_s1_arb_share_counter <= clock_crossing_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --clock_crossing_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      clock_crossing_0_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((clock_crossing_0_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_clock_crossing_0_s1)) OR ((end_xfer_arb_share_counter_term_clock_crossing_0_s1 AND NOT clock_crossing_0_s1_non_bursting_master_requests)))) = '1' then 
        clock_crossing_0_s1_slavearbiterlockenable <= or_reduce(clock_crossing_0_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --pcp_cpu/data_master clock_crossing_0/s1 arbiterlock, which is an e_assign
  pcp_cpu_data_master_arbiterlock <= clock_crossing_0_s1_slavearbiterlockenable AND pcp_cpu_data_master_continuerequest;
  --clock_crossing_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  clock_crossing_0_s1_slavearbiterlockenable2 <= or_reduce(clock_crossing_0_s1_arb_share_counter_next_value);
  --pcp_cpu/data_master clock_crossing_0/s1 arbiterlock2, which is an e_assign
  pcp_cpu_data_master_arbiterlock2 <= clock_crossing_0_s1_slavearbiterlockenable2 AND pcp_cpu_data_master_continuerequest;
  --clock_crossing_0_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  clock_crossing_0_s1_any_continuerequest <= std_logic'('1');
  --pcp_cpu_data_master_continuerequest continued request, which is an e_assign
  pcp_cpu_data_master_continuerequest <= std_logic'('1');
  internal_pcp_cpu_data_master_qualified_request_clock_crossing_0_s1 <= internal_pcp_cpu_data_master_requests_clock_crossing_0_s1 AND NOT ((((pcp_cpu_data_master_read AND ((NOT pcp_cpu_data_master_waitrequest OR (internal_pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register))))) OR (((NOT pcp_cpu_data_master_waitrequest) AND pcp_cpu_data_master_write))));
  --unique name for clock_crossing_0_s1_move_on_to_next_transaction, which is an e_assign
  clock_crossing_0_s1_move_on_to_next_transaction <= clock_crossing_0_s1_readdatavalid_from_sa;
  --rdv_fifo_for_pcp_cpu_data_master_to_clock_crossing_0_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_pcp_cpu_data_master_to_clock_crossing_0_s1 : rdv_fifo_for_pcp_cpu_data_master_to_clock_crossing_0_s1_module
    port map(
      data_out => pcp_cpu_data_master_rdv_fifo_output_from_clock_crossing_0_s1,
      empty => open,
      fifo_contains_ones_n => pcp_cpu_data_master_rdv_fifo_empty_clock_crossing_0_s1,
      full => open,
      clear_fifo => module_input,
      clk => clk,
      data_in => internal_pcp_cpu_data_master_granted_clock_crossing_0_s1,
      read => clock_crossing_0_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input1,
      write => module_input2
    );

  module_input <= std_logic'('0');
  module_input1 <= std_logic'('0');
  module_input2 <= in_a_read_cycle AND NOT clock_crossing_0_s1_waits_for_read;

  internal_pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register <= NOT pcp_cpu_data_master_rdv_fifo_empty_clock_crossing_0_s1;
  --local readdatavalid pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1, which is an e_mux
  pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1 <= clock_crossing_0_s1_readdatavalid_from_sa;
  --clock_crossing_0_s1_writedata mux, which is an e_mux
  clock_crossing_0_s1_writedata <= pcp_cpu_data_master_writedata;
  --assign clock_crossing_0_s1_endofpacket_from_sa = clock_crossing_0_s1_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  clock_crossing_0_s1_endofpacket_from_sa <= clock_crossing_0_s1_endofpacket;
  --master is always granted when requested
  internal_pcp_cpu_data_master_granted_clock_crossing_0_s1 <= internal_pcp_cpu_data_master_qualified_request_clock_crossing_0_s1;
  --pcp_cpu/data_master saved-grant clock_crossing_0/s1, which is an e_assign
  pcp_cpu_data_master_saved_grant_clock_crossing_0_s1 <= internal_pcp_cpu_data_master_requests_clock_crossing_0_s1;
  --allow new arb cycle for clock_crossing_0/s1, which is an e_assign
  clock_crossing_0_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  clock_crossing_0_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  clock_crossing_0_s1_master_qreq_vector <= std_logic'('1');
  --clock_crossing_0_s1_reset_n assignment, which is an e_assign
  clock_crossing_0_s1_reset_n <= reset_n;
  --clock_crossing_0_s1_firsttransfer first transaction, which is an e_assign
  clock_crossing_0_s1_firsttransfer <= A_WE_StdLogic((std_logic'(clock_crossing_0_s1_begins_xfer) = '1'), clock_crossing_0_s1_unreg_firsttransfer, clock_crossing_0_s1_reg_firsttransfer);
  --clock_crossing_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  clock_crossing_0_s1_unreg_firsttransfer <= NOT ((clock_crossing_0_s1_slavearbiterlockenable AND clock_crossing_0_s1_any_continuerequest));
  --clock_crossing_0_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      clock_crossing_0_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(clock_crossing_0_s1_begins_xfer) = '1' then 
        clock_crossing_0_s1_reg_firsttransfer <= clock_crossing_0_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --clock_crossing_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  clock_crossing_0_s1_beginbursttransfer_internal <= clock_crossing_0_s1_begins_xfer;
  --clock_crossing_0_s1_read assignment, which is an e_mux
  clock_crossing_0_s1_read <= internal_pcp_cpu_data_master_granted_clock_crossing_0_s1 AND pcp_cpu_data_master_read;
  --clock_crossing_0_s1_write assignment, which is an e_mux
  clock_crossing_0_s1_write <= internal_pcp_cpu_data_master_granted_clock_crossing_0_s1 AND pcp_cpu_data_master_write;
  shifted_address_to_clock_crossing_0_s1_from_pcp_cpu_data_master <= pcp_cpu_data_master_address_to_slave;
  --clock_crossing_0_s1_address mux, which is an e_mux
  clock_crossing_0_s1_address <= A_EXT (A_SRL(shifted_address_to_clock_crossing_0_s1_from_pcp_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 12);
  --slaveid clock_crossing_0_s1_nativeaddress nativeaddress mux, which is an e_mux
  clock_crossing_0_s1_nativeaddress <= A_EXT (A_SRL(pcp_cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 12);
  --d1_clock_crossing_0_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_clock_crossing_0_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_clock_crossing_0_s1_end_xfer <= clock_crossing_0_s1_end_xfer;
    end if;

  end process;

  --clock_crossing_0_s1_waits_for_read in a cycle, which is an e_mux
  clock_crossing_0_s1_waits_for_read <= clock_crossing_0_s1_in_a_read_cycle AND internal_clock_crossing_0_s1_waitrequest_from_sa;
  --clock_crossing_0_s1_in_a_read_cycle assignment, which is an e_assign
  clock_crossing_0_s1_in_a_read_cycle <= internal_pcp_cpu_data_master_granted_clock_crossing_0_s1 AND pcp_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= clock_crossing_0_s1_in_a_read_cycle;
  --clock_crossing_0_s1_waits_for_write in a cycle, which is an e_mux
  clock_crossing_0_s1_waits_for_write <= clock_crossing_0_s1_in_a_write_cycle AND internal_clock_crossing_0_s1_waitrequest_from_sa;
  --clock_crossing_0_s1_in_a_write_cycle assignment, which is an e_assign
  clock_crossing_0_s1_in_a_write_cycle <= internal_pcp_cpu_data_master_granted_clock_crossing_0_s1 AND pcp_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= clock_crossing_0_s1_in_a_write_cycle;
  wait_for_clock_crossing_0_s1_counter <= std_logic'('0');
  --clock_crossing_0_s1_byteenable byte enable port mux, which is an e_mux
  clock_crossing_0_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_clock_crossing_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (pcp_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  clock_crossing_0_s1_waitrequest_from_sa <= internal_clock_crossing_0_s1_waitrequest_from_sa;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_granted_clock_crossing_0_s1 <= internal_pcp_cpu_data_master_granted_clock_crossing_0_s1;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_qualified_request_clock_crossing_0_s1 <= internal_pcp_cpu_data_master_qualified_request_clock_crossing_0_s1;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register <= internal_pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_requests_clock_crossing_0_s1 <= internal_pcp_cpu_data_master_requests_clock_crossing_0_s1;
--synthesis translate_off
    --clock_crossing_0/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity clock_crossing_0_m1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_m1_address : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal clock_crossing_0_m1_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                 signal clock_crossing_0_m1_granted_node_switch_pio_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_granted_powerlink_0_MAC_CMP : IN STD_LOGIC;
                 signal clock_crossing_0_m1_granted_powerlink_0_MAC_REG : IN STD_LOGIC;
                 signal clock_crossing_0_m1_granted_status_led_pio_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_granted_system_timer_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_node_switch_pio_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_status_led_pio_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_system_timer_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_node_switch_pio_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_CMP : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_REG : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_status_led_pio_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_system_timer_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_node_switch_pio_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_powerlink_0_MAC_CMP : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_powerlink_0_MAC_REG : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_status_led_pio_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_system_timer_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_jtag_uart_0_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                 signal d1_node_switch_pio_s1_end_xfer : IN STD_LOGIC;
                 signal d1_powerlink_0_MAC_CMP_end_xfer : IN STD_LOGIC;
                 signal d1_powerlink_0_MAC_REG_end_xfer : IN STD_LOGIC;
                 signal d1_status_led_pio_s1_end_xfer : IN STD_LOGIC;
                 signal d1_system_timer_s1_end_xfer : IN STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                 signal node_switch_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal powerlink_0_MAC_CMP_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal powerlink_0_MAC_REG_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal status_led_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal system_timer_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal clock_crossing_0_m1_address_to_slave : OUT STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal clock_crossing_0_m1_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal clock_crossing_0_m1_dbs_write_16 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clock_crossing_0_m1_readdatavalid : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_reset_n : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_waitrequest : OUT STD_LOGIC
              );
end entity clock_crossing_0_m1_arbitrator;


architecture europa of clock_crossing_0_m1_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal clock_crossing_0_m1_address_last_time :  STD_LOGIC_VECTOR (13 DOWNTO 0);
                signal clock_crossing_0_m1_byteenable_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal clock_crossing_0_m1_dbs_increment :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal clock_crossing_0_m1_is_granted_some_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_read_but_no_slave_selected :  STD_LOGIC;
                signal clock_crossing_0_m1_read_last_time :  STD_LOGIC;
                signal clock_crossing_0_m1_run :  STD_LOGIC;
                signal clock_crossing_0_m1_write_last_time :  STD_LOGIC;
                signal clock_crossing_0_m1_writedata_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal dbs_16_reg_segment_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal dbs_count_enable :  STD_LOGIC;
                signal dbs_counter_overflow :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_address_to_slave :  STD_LOGIC_VECTOR (13 DOWNTO 0);
                signal internal_clock_crossing_0_m1_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_clock_crossing_0_m1_latency_counter :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_waitrequest :  STD_LOGIC;
                signal latency_load_value :  STD_LOGIC;
                signal next_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_clock_crossing_0_m1_latency_counter :  STD_LOGIC;
                signal p1_dbs_16_reg_segment_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal pre_dbs_count_enable :  STD_LOGIC;
                signal pre_flush_clock_crossing_0_m1_readdatavalid :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave OR NOT clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave OR NOT ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave OR NOT ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_node_switch_pio_s1 OR NOT clock_crossing_0_m1_requests_node_switch_pio_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_node_switch_pio_s1 OR NOT clock_crossing_0_m1_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_node_switch_pio_s1_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_node_switch_pio_s1 OR NOT clock_crossing_0_m1_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_write)))))))));
  --cascaded wait assignment, which is an e_assign
  clock_crossing_0_m1_run <= r_0 AND r_1;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP OR NOT clock_crossing_0_m1_requests_powerlink_0_MAC_CMP)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP OR NOT clock_crossing_0_m1_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_powerlink_0_MAC_CMP_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP OR NOT clock_crossing_0_m1_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG OR (((clock_crossing_0_m1_write AND NOT(or_reduce(clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG))) AND internal_clock_crossing_0_m1_dbs_address(1)))) OR NOT clock_crossing_0_m1_requests_powerlink_0_MAC_REG)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG OR NOT clock_crossing_0_m1_read)))) OR ((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_powerlink_0_MAC_REG_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((internal_clock_crossing_0_m1_dbs_address(1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG OR NOT clock_crossing_0_m1_write)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((internal_clock_crossing_0_m1_dbs_address(1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_status_led_pio_s1 OR NOT clock_crossing_0_m1_requests_status_led_pio_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_status_led_pio_s1 OR NOT clock_crossing_0_m1_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_status_led_pio_s1_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_status_led_pio_s1 OR NOT clock_crossing_0_m1_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_system_timer_s1 OR NOT clock_crossing_0_m1_requests_system_timer_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_system_timer_s1 OR NOT clock_crossing_0_m1_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_system_timer_s1_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_system_timer_s1 OR NOT clock_crossing_0_m1_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_write)))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_clock_crossing_0_m1_address_to_slave <= clock_crossing_0_m1_address(13 DOWNTO 0);
  --clock_crossing_0_m1_read_but_no_slave_selected assignment, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      clock_crossing_0_m1_read_but_no_slave_selected <= std_logic'('0');
    elsif clk'event and clk = '1' then
      clock_crossing_0_m1_read_but_no_slave_selected <= (clock_crossing_0_m1_read AND clock_crossing_0_m1_run) AND NOT clock_crossing_0_m1_is_granted_some_slave;
    end if;

  end process;

  --some slave is getting selected, which is an e_mux
  clock_crossing_0_m1_is_granted_some_slave <= ((((clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave OR clock_crossing_0_m1_granted_node_switch_pio_s1) OR clock_crossing_0_m1_granted_powerlink_0_MAC_CMP) OR clock_crossing_0_m1_granted_powerlink_0_MAC_REG) OR clock_crossing_0_m1_granted_status_led_pio_s1) OR clock_crossing_0_m1_granted_system_timer_s1;
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_clock_crossing_0_m1_readdatavalid <= std_logic'('0');
  --latent slave read data valid which is not flushed, which is an e_mux
  clock_crossing_0_m1_readdatavalid <= ((((((((((((((((clock_crossing_0_m1_read_but_no_slave_selected OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_jtag_uart_0_avalon_jtag_slave) OR clock_crossing_0_m1_read_but_no_slave_selected) OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_node_switch_pio_s1) OR clock_crossing_0_m1_read_but_no_slave_selected) OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_CMP) OR clock_crossing_0_m1_read_but_no_slave_selected) OR pre_flush_clock_crossing_0_m1_readdatavalid) OR ((clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_REG AND dbs_counter_overflow))) OR clock_crossing_0_m1_read_but_no_slave_selected) OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_status_led_pio_s1) OR clock_crossing_0_m1_read_but_no_slave_selected) OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_system_timer_s1;
  --clock_crossing_0/m1 readdata mux, which is an e_mux
  clock_crossing_0_m1_readdata <= ((((((A_REP(NOT ((clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave AND clock_crossing_0_m1_read)) , 32) OR jtag_uart_0_avalon_jtag_slave_readdata_from_sa)) AND ((A_REP(NOT ((clock_crossing_0_m1_qualified_request_node_switch_pio_s1 AND clock_crossing_0_m1_read)) , 32) OR (std_logic_vector'("000000000000000000000000") & (node_switch_pio_s1_readdata_from_sa))))) AND ((A_REP(NOT ((clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP AND clock_crossing_0_m1_read)) , 32) OR powerlink_0_MAC_CMP_readdata_from_sa))) AND ((A_REP(NOT ((clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG AND clock_crossing_0_m1_read)) , 32) OR Std_Logic_Vector'(powerlink_0_MAC_REG_readdata_from_sa(15 DOWNTO 0) & dbs_16_reg_segment_0)))) AND ((A_REP(NOT ((clock_crossing_0_m1_qualified_request_status_led_pio_s1 AND clock_crossing_0_m1_read)) , 32) OR (std_logic_vector'("000000000000000000000000000000") & (status_led_pio_s1_readdata_from_sa))))) AND ((A_REP(NOT ((clock_crossing_0_m1_qualified_request_system_timer_s1 AND clock_crossing_0_m1_read)) , 32) OR (std_logic_vector'("0000000000000000") & (system_timer_s1_readdata_from_sa))));
  --actual waitrequest port, which is an e_assign
  internal_clock_crossing_0_m1_waitrequest <= NOT clock_crossing_0_m1_run;
  --latent max counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_clock_crossing_0_m1_latency_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      internal_clock_crossing_0_m1_latency_counter <= p1_clock_crossing_0_m1_latency_counter;
    end if;

  end process;

  --latency counter load mux, which is an e_mux
  p1_clock_crossing_0_m1_latency_counter <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(((clock_crossing_0_m1_run AND clock_crossing_0_m1_read))) = '1'), (std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(latency_load_value))), A_WE_StdLogicVector((std_logic'((internal_clock_crossing_0_m1_latency_counter)) = '1'), ((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(internal_clock_crossing_0_m1_latency_counter))) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))));
  --read latency load values, which is an e_mux
  latency_load_value <= std_logic'('0');
  --clock_crossing_0_m1_reset_n assignment, which is an e_assign
  clock_crossing_0_m1_reset_n <= reset_n;
  --pre dbs count enable, which is an e_mux
  pre_dbs_count_enable <= Vector_To_Std_Logic((((((((NOT std_logic_vector'("00000000000000000000000000000000")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_requests_powerlink_0_MAC_REG)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_write)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT(or_reduce(clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG))))))) OR (((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((clock_crossing_0_m1_granted_powerlink_0_MAC_REG AND clock_crossing_0_m1_read)))) AND std_logic_vector'("00000000000000000000000000000001")) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_powerlink_0_MAC_REG_end_xfer)))))) OR ((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((clock_crossing_0_m1_granted_powerlink_0_MAC_REG AND clock_crossing_0_m1_write)))) AND std_logic_vector'("00000000000000000000000000000001")) AND std_logic_vector'("00000000000000000000000000000001")))));
  --input to dbs-16 stored 0, which is an e_mux
  p1_dbs_16_reg_segment_0 <= powerlink_0_MAC_REG_readdata_from_sa;
  --dbs register for dbs-16 segment 0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      dbs_16_reg_segment_0 <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      if std_logic'((dbs_count_enable AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((internal_clock_crossing_0_m1_dbs_address(1))))) = std_logic_vector'("00000000000000000000000000000000")))))) = '1' then 
        dbs_16_reg_segment_0 <= p1_dbs_16_reg_segment_0;
      end if;
    end if;

  end process;

  --mux write dbs 1, which is an e_mux
  clock_crossing_0_m1_dbs_write_16 <= A_WE_StdLogicVector((std_logic'((internal_clock_crossing_0_m1_dbs_address(1))) = '1'), clock_crossing_0_m1_writedata(31 DOWNTO 16), clock_crossing_0_m1_writedata(15 DOWNTO 0));
  --dbs count increment, which is an e_mux
  clock_crossing_0_m1_dbs_increment <= A_EXT (A_WE_StdLogicVector((std_logic'((clock_crossing_0_m1_requests_powerlink_0_MAC_REG)) = '1'), std_logic_vector'("00000000000000000000000000000010"), std_logic_vector'("00000000000000000000000000000000")), 2);
  --dbs counter overflow, which is an e_assign
  dbs_counter_overflow <= internal_clock_crossing_0_m1_dbs_address(1) AND NOT((next_dbs_address(1)));
  --next master address, which is an e_assign
  next_dbs_address <= A_EXT (((std_logic_vector'("0") & (internal_clock_crossing_0_m1_dbs_address)) + (std_logic_vector'("0") & (clock_crossing_0_m1_dbs_increment))), 2);
  --dbs count enable, which is an e_mux
  dbs_count_enable <= pre_dbs_count_enable;
  --dbs counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_clock_crossing_0_m1_dbs_address <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(dbs_count_enable) = '1' then 
        internal_clock_crossing_0_m1_dbs_address <= next_dbs_address;
      end if;
    end if;

  end process;

  --vhdl renameroo for output signals
  clock_crossing_0_m1_address_to_slave <= internal_clock_crossing_0_m1_address_to_slave;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_dbs_address <= internal_clock_crossing_0_m1_dbs_address;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_latency_counter <= internal_clock_crossing_0_m1_latency_counter;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_waitrequest <= internal_clock_crossing_0_m1_waitrequest;
--synthesis translate_off
    --clock_crossing_0_m1_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        clock_crossing_0_m1_address_last_time <= std_logic_vector'("00000000000000");
      elsif clk'event and clk = '1' then
        clock_crossing_0_m1_address_last_time <= clock_crossing_0_m1_address;
      end if;

    end process;

    --clock_crossing_0/m1 waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_clock_crossing_0_m1_waitrequest AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write));
      end if;

    end process;

    --clock_crossing_0_m1_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line5 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((clock_crossing_0_m1_address /= clock_crossing_0_m1_address_last_time))))) = '1' then 
          write(write_line5, now);
          write(write_line5, string'(": "));
          write(write_line5, string'("clock_crossing_0_m1_address did not heed wait!!!"));
          write(output, write_line5.all);
          deallocate (write_line5);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --clock_crossing_0_m1_byteenable check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        clock_crossing_0_m1_byteenable_last_time <= std_logic_vector'("0000");
      elsif clk'event and clk = '1' then
        clock_crossing_0_m1_byteenable_last_time <= clock_crossing_0_m1_byteenable;
      end if;

    end process;

    --clock_crossing_0_m1_byteenable matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line6 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((clock_crossing_0_m1_byteenable /= clock_crossing_0_m1_byteenable_last_time))))) = '1' then 
          write(write_line6, now);
          write(write_line6, string'(": "));
          write(write_line6, string'("clock_crossing_0_m1_byteenable did not heed wait!!!"));
          write(output, write_line6.all);
          deallocate (write_line6);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --clock_crossing_0_m1_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        clock_crossing_0_m1_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        clock_crossing_0_m1_read_last_time <= clock_crossing_0_m1_read;
      end if;

    end process;

    --clock_crossing_0_m1_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line7 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(clock_crossing_0_m1_read) /= std_logic'(clock_crossing_0_m1_read_last_time)))))) = '1' then 
          write(write_line7, now);
          write(write_line7, string'(": "));
          write(write_line7, string'("clock_crossing_0_m1_read did not heed wait!!!"));
          write(output, write_line7.all);
          deallocate (write_line7);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --clock_crossing_0_m1_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        clock_crossing_0_m1_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        clock_crossing_0_m1_write_last_time <= clock_crossing_0_m1_write;
      end if;

    end process;

    --clock_crossing_0_m1_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line8 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(clock_crossing_0_m1_write) /= std_logic'(clock_crossing_0_m1_write_last_time)))))) = '1' then 
          write(write_line8, now);
          write(write_line8, string'(": "));
          write(write_line8, string'("clock_crossing_0_m1_write did not heed wait!!!"));
          write(output, write_line8.all);
          deallocate (write_line8);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --clock_crossing_0_m1_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        clock_crossing_0_m1_writedata_last_time <= std_logic_vector'("00000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        clock_crossing_0_m1_writedata_last_time <= clock_crossing_0_m1_writedata;
      end if;

    end process;

    --clock_crossing_0_m1_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line9 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((clock_crossing_0_m1_writedata /= clock_crossing_0_m1_writedata_last_time)))) AND clock_crossing_0_m1_write)) = '1' then 
          write(write_line9, now);
          write(write_line9, string'(": "));
          write(write_line9, string'("clock_crossing_0_m1_writedata did not heed wait!!!"));
          write(output, write_line9.all);
          deallocate (write_line9);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity clock_crossing_0_bridge_arbitrator is 
end entity clock_crossing_0_bridge_arbitrator;


architecture europa of clock_crossing_0_bridge_arbitrator is

begin


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity epcs_flash_controller_0_epcs_control_port_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_dataavailable : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_endofpacket : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_irq : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal epcs_flash_controller_0_epcs_control_port_readyfordata : IN STD_LOGIC;
                 signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal pcp_cpu_data_master_read : IN STD_LOGIC;
                 signal pcp_cpu_data_master_write : IN STD_LOGIC;
                 signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (21 DOWNTO 0);
                 signal pcp_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pcp_cpu_instruction_master_read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : OUT STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal epcs_flash_controller_0_epcs_control_port_chipselect : OUT STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa : OUT STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa : OUT STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_irq_from_sa : OUT STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_read_n : OUT STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa : OUT STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_reset_n : OUT STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_write_n : OUT STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC
              );
end entity epcs_flash_controller_0_epcs_control_port_arbitrator;


architecture europa of epcs_flash_controller_0_epcs_control_port_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_allgrants :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_allow_new_arb_cycle :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_any_bursting_master_saved_grant :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_any_continuerequest :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_arb_counter_enable :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_arbitration_holdoff_internal :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_beginbursttransfer_internal :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_begins_xfer :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_end_xfer :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_firsttransfer :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_in_a_read_cycle :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_in_a_write_cycle :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_reg_firsttransfer :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_unreg_firsttransfer :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_waits_for_read :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_waits_for_write :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal last_cycle_pcp_cpu_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal last_cycle_pcp_cpu_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_data_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_data_master_saved_grant_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal pcp_cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_instruction_master_saved_grant_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_pcp_cpu_data_master :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_pcp_cpu_instruction_master :  STD_LOGIC_VECTOR (21 DOWNTO 0);
                signal wait_for_epcs_flash_controller_0_epcs_control_port_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT epcs_flash_controller_0_epcs_control_port_end_xfer;
    end if;

  end process;

  epcs_flash_controller_0_epcs_control_port_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR internal_pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port));
  --assign epcs_flash_controller_0_epcs_control_port_readdata_from_sa = epcs_flash_controller_0_epcs_control_port_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_readdata_from_sa <= epcs_flash_controller_0_epcs_control_port_readdata;
  internal_pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port <= to_std_logic(((Std_Logic_Vector'(pcp_cpu_data_master_address_to_slave(24 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0000000000000000000000000")))) AND ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write));
  --assign epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa = epcs_flash_controller_0_epcs_control_port_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa <= epcs_flash_controller_0_epcs_control_port_dataavailable;
  --assign epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa = epcs_flash_controller_0_epcs_control_port_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa <= epcs_flash_controller_0_epcs_control_port_readyfordata;
  --epcs_flash_controller_0_epcs_control_port_arb_share_counter set values, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_arb_share_set_values <= std_logic_vector'("01");
  --epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests mux, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests <= ((internal_pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port OR internal_pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port) OR internal_pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port) OR internal_pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;
  --epcs_flash_controller_0_epcs_control_port_any_bursting_master_saved_grant mux, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_any_bursting_master_saved_grant <= std_logic'('0');
  --epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value assignment, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(epcs_flash_controller_0_epcs_control_port_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (epcs_flash_controller_0_epcs_control_port_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(epcs_flash_controller_0_epcs_control_port_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (epcs_flash_controller_0_epcs_control_port_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --epcs_flash_controller_0_epcs_control_port_allgrants all slave grants, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_allgrants <= (((or_reduce(epcs_flash_controller_0_epcs_control_port_grant_vector)) OR (or_reduce(epcs_flash_controller_0_epcs_control_port_grant_vector))) OR (or_reduce(epcs_flash_controller_0_epcs_control_port_grant_vector))) OR (or_reduce(epcs_flash_controller_0_epcs_control_port_grant_vector));
  --epcs_flash_controller_0_epcs_control_port_end_xfer assignment, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_end_xfer <= NOT ((epcs_flash_controller_0_epcs_control_port_waits_for_read OR epcs_flash_controller_0_epcs_control_port_waits_for_write));
  --end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port <= epcs_flash_controller_0_epcs_control_port_end_xfer AND (((NOT epcs_flash_controller_0_epcs_control_port_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --epcs_flash_controller_0_epcs_control_port_arb_share_counter arbitration counter enable, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_arb_counter_enable <= ((end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port AND epcs_flash_controller_0_epcs_control_port_allgrants)) OR ((end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port AND NOT epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests));
  --epcs_flash_controller_0_epcs_control_port_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      epcs_flash_controller_0_epcs_control_port_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(epcs_flash_controller_0_epcs_control_port_arb_counter_enable) = '1' then 
        epcs_flash_controller_0_epcs_control_port_arb_share_counter <= epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(epcs_flash_controller_0_epcs_control_port_master_qreq_vector) AND end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port)) OR ((end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port AND NOT epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests)))) = '1' then 
        epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable <= or_reduce(epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --pcp_cpu/data_master epcs_flash_controller_0/epcs_control_port arbiterlock, which is an e_assign
  pcp_cpu_data_master_arbiterlock <= epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable AND pcp_cpu_data_master_continuerequest;
  --epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 <= or_reduce(epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value);
  --pcp_cpu/data_master epcs_flash_controller_0/epcs_control_port arbiterlock2, which is an e_assign
  pcp_cpu_data_master_arbiterlock2 <= epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 AND pcp_cpu_data_master_continuerequest;
  --pcp_cpu/instruction_master epcs_flash_controller_0/epcs_control_port arbiterlock, which is an e_assign
  pcp_cpu_instruction_master_arbiterlock <= epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable AND pcp_cpu_instruction_master_continuerequest;
  --pcp_cpu/instruction_master epcs_flash_controller_0/epcs_control_port arbiterlock2, which is an e_assign
  pcp_cpu_instruction_master_arbiterlock2 <= epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 AND pcp_cpu_instruction_master_continuerequest;
  --pcp_cpu/instruction_master granted epcs_flash_controller_0/epcs_control_port last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_pcp_cpu_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_pcp_cpu_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pcp_cpu_instruction_master_saved_grant_epcs_flash_controller_0_epcs_control_port) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((epcs_flash_controller_0_epcs_control_port_arbitration_holdoff_internal OR NOT internal_pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_pcp_cpu_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port))))));
    end if;

  end process;

  --pcp_cpu_instruction_master_continuerequest continued request, which is an e_mux
  pcp_cpu_instruction_master_continuerequest <= last_cycle_pcp_cpu_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port AND internal_pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;
  --epcs_flash_controller_0_epcs_control_port_any_continuerequest at least one master continues requesting, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_any_continuerequest <= pcp_cpu_instruction_master_continuerequest OR pcp_cpu_data_master_continuerequest;
  internal_pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port <= internal_pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port AND NOT (pcp_cpu_instruction_master_arbiterlock);
  --epcs_flash_controller_0_epcs_control_port_writedata mux, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_writedata <= pcp_cpu_data_master_writedata;
  --assign epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa = epcs_flash_controller_0_epcs_control_port_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa <= epcs_flash_controller_0_epcs_control_port_endofpacket;
  internal_pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port <= ((to_std_logic(((Std_Logic_Vector'(pcp_cpu_instruction_master_address_to_slave(21 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0000000000000000000000")))) AND (pcp_cpu_instruction_master_read))) AND pcp_cpu_instruction_master_read;
  --pcp_cpu/data_master granted epcs_flash_controller_0/epcs_control_port last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_pcp_cpu_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_pcp_cpu_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pcp_cpu_data_master_saved_grant_epcs_flash_controller_0_epcs_control_port) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((epcs_flash_controller_0_epcs_control_port_arbitration_holdoff_internal OR NOT internal_pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_pcp_cpu_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port))))));
    end if;

  end process;

  --pcp_cpu_data_master_continuerequest continued request, which is an e_mux
  pcp_cpu_data_master_continuerequest <= last_cycle_pcp_cpu_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port AND internal_pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port;
  internal_pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port <= internal_pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port AND NOT ((((pcp_cpu_instruction_master_read AND to_std_logic((((std_logic_vector'("000000000000000000000000000000") & (pcp_cpu_instruction_master_latency_counter)) /= std_logic_vector'("00000000000000000000000000000000")))))) OR pcp_cpu_data_master_arbiterlock));
  --local readdatavalid pcp_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port, which is an e_mux
  pcp_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port <= (internal_pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port AND pcp_cpu_instruction_master_read) AND NOT epcs_flash_controller_0_epcs_control_port_waits_for_read;
  --allow new arb cycle for epcs_flash_controller_0/epcs_control_port, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_allow_new_arb_cycle <= NOT pcp_cpu_data_master_arbiterlock AND NOT pcp_cpu_instruction_master_arbiterlock;
  --pcp_cpu/instruction_master assignment into master qualified-requests vector for epcs_flash_controller_0/epcs_control_port, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_master_qreq_vector(0) <= internal_pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  --pcp_cpu/instruction_master grant epcs_flash_controller_0/epcs_control_port, which is an e_assign
  internal_pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port <= epcs_flash_controller_0_epcs_control_port_grant_vector(0);
  --pcp_cpu/instruction_master saved-grant epcs_flash_controller_0/epcs_control_port, which is an e_assign
  pcp_cpu_instruction_master_saved_grant_epcs_flash_controller_0_epcs_control_port <= epcs_flash_controller_0_epcs_control_port_arb_winner(0) AND internal_pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;
  --pcp_cpu/data_master assignment into master qualified-requests vector for epcs_flash_controller_0/epcs_control_port, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_master_qreq_vector(1) <= internal_pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  --pcp_cpu/data_master grant epcs_flash_controller_0/epcs_control_port, which is an e_assign
  internal_pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port <= epcs_flash_controller_0_epcs_control_port_grant_vector(1);
  --pcp_cpu/data_master saved-grant epcs_flash_controller_0/epcs_control_port, which is an e_assign
  pcp_cpu_data_master_saved_grant_epcs_flash_controller_0_epcs_control_port <= epcs_flash_controller_0_epcs_control_port_arb_winner(1) AND internal_pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port;
  --epcs_flash_controller_0/epcs_control_port chosen-master double-vector, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((epcs_flash_controller_0_epcs_control_port_master_qreq_vector & epcs_flash_controller_0_epcs_control_port_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT epcs_flash_controller_0_epcs_control_port_master_qreq_vector & NOT epcs_flash_controller_0_epcs_control_port_master_qreq_vector))) + (std_logic_vector'("000") & (epcs_flash_controller_0_epcs_control_port_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  epcs_flash_controller_0_epcs_control_port_arb_winner <= A_WE_StdLogicVector((std_logic'(((epcs_flash_controller_0_epcs_control_port_allow_new_arb_cycle AND or_reduce(epcs_flash_controller_0_epcs_control_port_grant_vector)))) = '1'), epcs_flash_controller_0_epcs_control_port_grant_vector, epcs_flash_controller_0_epcs_control_port_saved_chosen_master_vector);
  --saved epcs_flash_controller_0_epcs_control_port_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      epcs_flash_controller_0_epcs_control_port_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(epcs_flash_controller_0_epcs_control_port_allow_new_arb_cycle) = '1' then 
        epcs_flash_controller_0_epcs_control_port_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(epcs_flash_controller_0_epcs_control_port_grant_vector)) = '1'), epcs_flash_controller_0_epcs_control_port_grant_vector, epcs_flash_controller_0_epcs_control_port_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  epcs_flash_controller_0_epcs_control_port_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((epcs_flash_controller_0_epcs_control_port_chosen_master_double_vector(1) OR epcs_flash_controller_0_epcs_control_port_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((epcs_flash_controller_0_epcs_control_port_chosen_master_double_vector(0) OR epcs_flash_controller_0_epcs_control_port_chosen_master_double_vector(2)))));
  --epcs_flash_controller_0/epcs_control_port chosen master rotated left, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(epcs_flash_controller_0_epcs_control_port_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(epcs_flash_controller_0_epcs_control_port_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --epcs_flash_controller_0/epcs_control_port's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      epcs_flash_controller_0_epcs_control_port_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(epcs_flash_controller_0_epcs_control_port_grant_vector)) = '1' then 
        epcs_flash_controller_0_epcs_control_port_arb_addend <= A_WE_StdLogicVector((std_logic'(epcs_flash_controller_0_epcs_control_port_end_xfer) = '1'), epcs_flash_controller_0_epcs_control_port_chosen_master_rot_left, epcs_flash_controller_0_epcs_control_port_grant_vector);
      end if;
    end if;

  end process;

  --epcs_flash_controller_0_epcs_control_port_reset_n assignment, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_reset_n <= reset_n;
  epcs_flash_controller_0_epcs_control_port_chipselect <= internal_pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port OR internal_pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port;
  --epcs_flash_controller_0_epcs_control_port_firsttransfer first transaction, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_firsttransfer <= A_WE_StdLogic((std_logic'(epcs_flash_controller_0_epcs_control_port_begins_xfer) = '1'), epcs_flash_controller_0_epcs_control_port_unreg_firsttransfer, epcs_flash_controller_0_epcs_control_port_reg_firsttransfer);
  --epcs_flash_controller_0_epcs_control_port_unreg_firsttransfer first transaction, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_unreg_firsttransfer <= NOT ((epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable AND epcs_flash_controller_0_epcs_control_port_any_continuerequest));
  --epcs_flash_controller_0_epcs_control_port_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      epcs_flash_controller_0_epcs_control_port_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(epcs_flash_controller_0_epcs_control_port_begins_xfer) = '1' then 
        epcs_flash_controller_0_epcs_control_port_reg_firsttransfer <= epcs_flash_controller_0_epcs_control_port_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --epcs_flash_controller_0_epcs_control_port_beginbursttransfer_internal begin burst transfer, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_beginbursttransfer_internal <= epcs_flash_controller_0_epcs_control_port_begins_xfer;
  --epcs_flash_controller_0_epcs_control_port_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_arbitration_holdoff_internal <= epcs_flash_controller_0_epcs_control_port_begins_xfer AND epcs_flash_controller_0_epcs_control_port_firsttransfer;
  --~epcs_flash_controller_0_epcs_control_port_read_n assignment, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_read_n <= NOT ((((internal_pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port AND pcp_cpu_data_master_read)) OR ((internal_pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port AND pcp_cpu_instruction_master_read))));
  --~epcs_flash_controller_0_epcs_control_port_write_n assignment, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_write_n <= NOT ((internal_pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port AND pcp_cpu_data_master_write));
  shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_pcp_cpu_data_master <= pcp_cpu_data_master_address_to_slave;
  --epcs_flash_controller_0_epcs_control_port_address mux, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port)) = '1'), (A_SRL(shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_pcp_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (std_logic_vector'("000") & ((A_SRL(shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_pcp_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))))), 9);
  shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_pcp_cpu_instruction_master <= pcp_cpu_instruction_master_address_to_slave;
  --d1_epcs_flash_controller_0_epcs_control_port_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_epcs_flash_controller_0_epcs_control_port_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_epcs_flash_controller_0_epcs_control_port_end_xfer <= epcs_flash_controller_0_epcs_control_port_end_xfer;
    end if;

  end process;

  --epcs_flash_controller_0_epcs_control_port_waits_for_read in a cycle, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_waits_for_read <= epcs_flash_controller_0_epcs_control_port_in_a_read_cycle AND epcs_flash_controller_0_epcs_control_port_begins_xfer;
  --epcs_flash_controller_0_epcs_control_port_in_a_read_cycle assignment, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_in_a_read_cycle <= ((internal_pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port AND pcp_cpu_data_master_read)) OR ((internal_pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port AND pcp_cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= epcs_flash_controller_0_epcs_control_port_in_a_read_cycle;
  --epcs_flash_controller_0_epcs_control_port_waits_for_write in a cycle, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_waits_for_write <= epcs_flash_controller_0_epcs_control_port_in_a_write_cycle AND epcs_flash_controller_0_epcs_control_port_begins_xfer;
  --epcs_flash_controller_0_epcs_control_port_in_a_write_cycle assignment, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_in_a_write_cycle <= internal_pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port AND pcp_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= epcs_flash_controller_0_epcs_control_port_in_a_write_cycle;
  wait_for_epcs_flash_controller_0_epcs_control_port_counter <= std_logic'('0');
  --assign epcs_flash_controller_0_epcs_control_port_irq_from_sa = epcs_flash_controller_0_epcs_control_port_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_irq_from_sa <= epcs_flash_controller_0_epcs_control_port_irq;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port <= internal_pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port <= internal_pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port <= internal_pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port <= internal_pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port <= internal_pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port <= internal_pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;
--synthesis translate_off
    --epcs_flash_controller_0/epcs_control_port enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line10 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line10, now);
          write(write_line10, string'(": "));
          write(write_line10, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line10.all);
          deallocate (write_line10);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line11 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_saved_grant_epcs_flash_controller_0_epcs_control_port))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(pcp_cpu_instruction_master_saved_grant_epcs_flash_controller_0_epcs_control_port))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line11, now);
          write(write_line11, string'(": "));
          write(write_line11, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line11.all);
          deallocate (write_line11);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity jtag_uart_0_avalon_jtag_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_0_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_irq : IN STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_0_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                 signal d1_jtag_uart_0_avalon_jtag_slave_end_xfer : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_address : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_chipselect : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_irq_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_read_n : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_reset_n : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_write_n : OUT STD_LOGIC;
                 signal jtag_uart_0_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity jtag_uart_0_avalon_jtag_slave_arbitrator;


architecture europa of jtag_uart_0_avalon_jtag_slave_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal internal_jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_allgrants :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_any_continuerequest :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_arb_counter_enable :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_begins_xfer :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_firsttransfer :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_grant_vector :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_in_a_read_cycle :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_in_a_write_cycle :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_master_qreq_vector :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_non_bursting_master_requests :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_reg_firsttransfer :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_unreg_firsttransfer :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_waits_for_read :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_waits_for_write :  STD_LOGIC;
                signal wait_for_jtag_uart_0_avalon_jtag_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT jtag_uart_0_avalon_jtag_slave_end_xfer;
    end if;

  end process;

  jtag_uart_0_avalon_jtag_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave);
  --assign jtag_uart_0_avalon_jtag_slave_readdata_from_sa = jtag_uart_0_avalon_jtag_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_readdata_from_sa <= jtag_uart_0_avalon_jtag_slave_readdata;
  internal_clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave <= to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(13 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("10000001100000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write));
  --assign jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_0_avalon_jtag_slave_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa <= jtag_uart_0_avalon_jtag_slave_dataavailable;
  --assign jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_0_avalon_jtag_slave_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa <= jtag_uart_0_avalon_jtag_slave_readyfordata;
  --assign jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_0_avalon_jtag_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa <= jtag_uart_0_avalon_jtag_slave_waitrequest;
  --jtag_uart_0_avalon_jtag_slave_arb_share_counter set values, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_arb_share_set_values <= std_logic_vector'("01");
  --jtag_uart_0_avalon_jtag_slave_non_bursting_master_requests mux, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave;
  --jtag_uart_0_avalon_jtag_slave_any_bursting_master_saved_grant mux, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --jtag_uart_0_avalon_jtag_slave_arb_share_counter_next_value assignment, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(jtag_uart_0_avalon_jtag_slave_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (jtag_uart_0_avalon_jtag_slave_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(jtag_uart_0_avalon_jtag_slave_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (jtag_uart_0_avalon_jtag_slave_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --jtag_uart_0_avalon_jtag_slave_allgrants all slave grants, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_allgrants <= jtag_uart_0_avalon_jtag_slave_grant_vector;
  --jtag_uart_0_avalon_jtag_slave_end_xfer assignment, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_end_xfer <= NOT ((jtag_uart_0_avalon_jtag_slave_waits_for_read OR jtag_uart_0_avalon_jtag_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave <= jtag_uart_0_avalon_jtag_slave_end_xfer AND (((NOT jtag_uart_0_avalon_jtag_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --jtag_uart_0_avalon_jtag_slave_arb_share_counter arbitration counter enable, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave AND jtag_uart_0_avalon_jtag_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave AND NOT jtag_uart_0_avalon_jtag_slave_non_bursting_master_requests));
  --jtag_uart_0_avalon_jtag_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_0_avalon_jtag_slave_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(jtag_uart_0_avalon_jtag_slave_arb_counter_enable) = '1' then 
        jtag_uart_0_avalon_jtag_slave_arb_share_counter <= jtag_uart_0_avalon_jtag_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((jtag_uart_0_avalon_jtag_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave)) OR ((end_xfer_arb_share_counter_term_jtag_uart_0_avalon_jtag_slave AND NOT jtag_uart_0_avalon_jtag_slave_non_bursting_master_requests)))) = '1' then 
        jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable <= or_reduce(jtag_uart_0_avalon_jtag_slave_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 jtag_uart_0/avalon_jtag_slave arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable2 <= or_reduce(jtag_uart_0_avalon_jtag_slave_arb_share_counter_next_value);
  --clock_crossing_0/m1 jtag_uart_0/avalon_jtag_slave arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --jtag_uart_0_avalon_jtag_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave <= internal_clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave AND NOT ((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_jtag_uart_0_avalon_jtag_slave, which is an e_mux
  clock_crossing_0_m1_read_data_valid_jtag_uart_0_avalon_jtag_slave <= (internal_clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave AND clock_crossing_0_m1_read) AND NOT jtag_uart_0_avalon_jtag_slave_waits_for_read;
  --jtag_uart_0_avalon_jtag_slave_writedata mux, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_writedata <= clock_crossing_0_m1_writedata;
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave <= internal_clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave;
  --clock_crossing_0/m1 saved-grant jtag_uart_0/avalon_jtag_slave, which is an e_assign
  clock_crossing_0_m1_saved_grant_jtag_uart_0_avalon_jtag_slave <= internal_clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave;
  --allow new arb cycle for jtag_uart_0/avalon_jtag_slave, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  jtag_uart_0_avalon_jtag_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  jtag_uart_0_avalon_jtag_slave_master_qreq_vector <= std_logic'('1');
  --jtag_uart_0_avalon_jtag_slave_reset_n assignment, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_reset_n <= reset_n;
  jtag_uart_0_avalon_jtag_slave_chipselect <= internal_clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave;
  --jtag_uart_0_avalon_jtag_slave_firsttransfer first transaction, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_firsttransfer <= A_WE_StdLogic((std_logic'(jtag_uart_0_avalon_jtag_slave_begins_xfer) = '1'), jtag_uart_0_avalon_jtag_slave_unreg_firsttransfer, jtag_uart_0_avalon_jtag_slave_reg_firsttransfer);
  --jtag_uart_0_avalon_jtag_slave_unreg_firsttransfer first transaction, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_unreg_firsttransfer <= NOT ((jtag_uart_0_avalon_jtag_slave_slavearbiterlockenable AND jtag_uart_0_avalon_jtag_slave_any_continuerequest));
  --jtag_uart_0_avalon_jtag_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_0_avalon_jtag_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(jtag_uart_0_avalon_jtag_slave_begins_xfer) = '1' then 
        jtag_uart_0_avalon_jtag_slave_reg_firsttransfer <= jtag_uart_0_avalon_jtag_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --jtag_uart_0_avalon_jtag_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_beginbursttransfer_internal <= jtag_uart_0_avalon_jtag_slave_begins_xfer;
  --~jtag_uart_0_avalon_jtag_slave_read_n assignment, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_read_n <= NOT ((internal_clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave AND clock_crossing_0_m1_read));
  --~jtag_uart_0_avalon_jtag_slave_write_n assignment, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_write_n <= NOT ((internal_clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave AND clock_crossing_0_m1_write));
  --jtag_uart_0_avalon_jtag_slave_address mux, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_address <= clock_crossing_0_m1_nativeaddress(0);
  --d1_jtag_uart_0_avalon_jtag_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_jtag_uart_0_avalon_jtag_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_jtag_uart_0_avalon_jtag_slave_end_xfer <= jtag_uart_0_avalon_jtag_slave_end_xfer;
    end if;

  end process;

  --jtag_uart_0_avalon_jtag_slave_waits_for_read in a cycle, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_waits_for_read <= jtag_uart_0_avalon_jtag_slave_in_a_read_cycle AND internal_jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_0_avalon_jtag_slave_in_a_read_cycle assignment, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= jtag_uart_0_avalon_jtag_slave_in_a_read_cycle;
  --jtag_uart_0_avalon_jtag_slave_waits_for_write in a cycle, which is an e_mux
  jtag_uart_0_avalon_jtag_slave_waits_for_write <= jtag_uart_0_avalon_jtag_slave_in_a_write_cycle AND internal_jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_0_avalon_jtag_slave_in_a_write_cycle assignment, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= jtag_uart_0_avalon_jtag_slave_in_a_write_cycle;
  wait_for_jtag_uart_0_avalon_jtag_slave_counter <= std_logic'('0');
  --assign jtag_uart_0_avalon_jtag_slave_irq_from_sa = jtag_uart_0_avalon_jtag_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_0_avalon_jtag_slave_irq_from_sa <= jtag_uart_0_avalon_jtag_slave_irq;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave <= internal_clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave <= internal_clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave <= internal_clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave;
  --vhdl renameroo for output signals
  jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa <= internal_jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa;
--synthesis translate_off
    --jtag_uart_0/avalon_jtag_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity niosII_openMac_clock_0_in_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_in_endofpacket : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_waitrequest : IN STD_LOGIC;
                 signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal pcp_cpu_data_master_read : IN STD_LOGIC;
                 signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal pcp_cpu_data_master_write : IN STD_LOGIC;
                 signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_niosII_openMac_clock_0_in_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_in_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_in_nativeaddress : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_read : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_in_write : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_data_master_granted_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_requests_niosII_openMac_clock_0_in : OUT STD_LOGIC
              );
end entity niosII_openMac_clock_0_in_arbitrator;


architecture europa of niosII_openMac_clock_0_in_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_niosII_openMac_clock_0_in_waitrequest_from_sa :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_granted_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_requests_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_allgrants :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_allow_new_arb_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_any_bursting_master_saved_grant :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_any_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_arb_counter_enable :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_0_in_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_0_in_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_0_in_beginbursttransfer_internal :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_begins_xfer :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_end_xfer :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_grant_vector :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_in_a_read_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_in_a_write_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_master_qreq_vector :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_non_bursting_master_requests :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_reg_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_slavearbiterlockenable :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_slavearbiterlockenable2 :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_unreg_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_waits_for_read :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_waits_for_write :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_data_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_data_master_saved_grant_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal wait_for_niosII_openMac_clock_0_in_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT niosII_openMac_clock_0_in_end_xfer;
    end if;

  end process;

  niosII_openMac_clock_0_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in);
  --assign niosII_openMac_clock_0_in_readdata_from_sa = niosII_openMac_clock_0_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_0_in_readdata_from_sa <= niosII_openMac_clock_0_in_readdata;
  internal_pcp_cpu_data_master_requests_niosII_openMac_clock_0_in <= to_std_logic(((Std_Logic_Vector'(pcp_cpu_data_master_address_to_slave(24 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000100100000000")))) AND ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write));
  --assign niosII_openMac_clock_0_in_waitrequest_from_sa = niosII_openMac_clock_0_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_niosII_openMac_clock_0_in_waitrequest_from_sa <= niosII_openMac_clock_0_in_waitrequest;
  --niosII_openMac_clock_0_in_arb_share_counter set values, which is an e_mux
  niosII_openMac_clock_0_in_arb_share_set_values <= std_logic_vector'("01");
  --niosII_openMac_clock_0_in_non_bursting_master_requests mux, which is an e_mux
  niosII_openMac_clock_0_in_non_bursting_master_requests <= internal_pcp_cpu_data_master_requests_niosII_openMac_clock_0_in;
  --niosII_openMac_clock_0_in_any_bursting_master_saved_grant mux, which is an e_mux
  niosII_openMac_clock_0_in_any_bursting_master_saved_grant <= std_logic'('0');
  --niosII_openMac_clock_0_in_arb_share_counter_next_value assignment, which is an e_assign
  niosII_openMac_clock_0_in_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(niosII_openMac_clock_0_in_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (niosII_openMac_clock_0_in_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(niosII_openMac_clock_0_in_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (niosII_openMac_clock_0_in_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --niosII_openMac_clock_0_in_allgrants all slave grants, which is an e_mux
  niosII_openMac_clock_0_in_allgrants <= niosII_openMac_clock_0_in_grant_vector;
  --niosII_openMac_clock_0_in_end_xfer assignment, which is an e_assign
  niosII_openMac_clock_0_in_end_xfer <= NOT ((niosII_openMac_clock_0_in_waits_for_read OR niosII_openMac_clock_0_in_waits_for_write));
  --end_xfer_arb_share_counter_term_niosII_openMac_clock_0_in arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_niosII_openMac_clock_0_in <= niosII_openMac_clock_0_in_end_xfer AND (((NOT niosII_openMac_clock_0_in_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --niosII_openMac_clock_0_in_arb_share_counter arbitration counter enable, which is an e_assign
  niosII_openMac_clock_0_in_arb_counter_enable <= ((end_xfer_arb_share_counter_term_niosII_openMac_clock_0_in AND niosII_openMac_clock_0_in_allgrants)) OR ((end_xfer_arb_share_counter_term_niosII_openMac_clock_0_in AND NOT niosII_openMac_clock_0_in_non_bursting_master_requests));
  --niosII_openMac_clock_0_in_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_0_in_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(niosII_openMac_clock_0_in_arb_counter_enable) = '1' then 
        niosII_openMac_clock_0_in_arb_share_counter <= niosII_openMac_clock_0_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_0_in_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_0_in_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((niosII_openMac_clock_0_in_master_qreq_vector AND end_xfer_arb_share_counter_term_niosII_openMac_clock_0_in)) OR ((end_xfer_arb_share_counter_term_niosII_openMac_clock_0_in AND NOT niosII_openMac_clock_0_in_non_bursting_master_requests)))) = '1' then 
        niosII_openMac_clock_0_in_slavearbiterlockenable <= or_reduce(niosII_openMac_clock_0_in_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --pcp_cpu/data_master niosII_openMac_clock_0/in arbiterlock, which is an e_assign
  pcp_cpu_data_master_arbiterlock <= niosII_openMac_clock_0_in_slavearbiterlockenable AND pcp_cpu_data_master_continuerequest;
  --niosII_openMac_clock_0_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  niosII_openMac_clock_0_in_slavearbiterlockenable2 <= or_reduce(niosII_openMac_clock_0_in_arb_share_counter_next_value);
  --pcp_cpu/data_master niosII_openMac_clock_0/in arbiterlock2, which is an e_assign
  pcp_cpu_data_master_arbiterlock2 <= niosII_openMac_clock_0_in_slavearbiterlockenable2 AND pcp_cpu_data_master_continuerequest;
  --niosII_openMac_clock_0_in_any_continuerequest at least one master continues requesting, which is an e_assign
  niosII_openMac_clock_0_in_any_continuerequest <= std_logic'('1');
  --pcp_cpu_data_master_continuerequest continued request, which is an e_assign
  pcp_cpu_data_master_continuerequest <= std_logic'('1');
  internal_pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in <= internal_pcp_cpu_data_master_requests_niosII_openMac_clock_0_in AND NOT ((((pcp_cpu_data_master_read AND (NOT pcp_cpu_data_master_waitrequest))) OR (((NOT pcp_cpu_data_master_waitrequest) AND pcp_cpu_data_master_write))));
  --niosII_openMac_clock_0_in_writedata mux, which is an e_mux
  niosII_openMac_clock_0_in_writedata <= pcp_cpu_data_master_writedata;
  --assign niosII_openMac_clock_0_in_endofpacket_from_sa = niosII_openMac_clock_0_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_0_in_endofpacket_from_sa <= niosII_openMac_clock_0_in_endofpacket;
  --master is always granted when requested
  internal_pcp_cpu_data_master_granted_niosII_openMac_clock_0_in <= internal_pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in;
  --pcp_cpu/data_master saved-grant niosII_openMac_clock_0/in, which is an e_assign
  pcp_cpu_data_master_saved_grant_niosII_openMac_clock_0_in <= internal_pcp_cpu_data_master_requests_niosII_openMac_clock_0_in;
  --allow new arb cycle for niosII_openMac_clock_0/in, which is an e_assign
  niosII_openMac_clock_0_in_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  niosII_openMac_clock_0_in_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  niosII_openMac_clock_0_in_master_qreq_vector <= std_logic'('1');
  --niosII_openMac_clock_0_in_reset_n assignment, which is an e_assign
  niosII_openMac_clock_0_in_reset_n <= reset_n;
  --niosII_openMac_clock_0_in_firsttransfer first transaction, which is an e_assign
  niosII_openMac_clock_0_in_firsttransfer <= A_WE_StdLogic((std_logic'(niosII_openMac_clock_0_in_begins_xfer) = '1'), niosII_openMac_clock_0_in_unreg_firsttransfer, niosII_openMac_clock_0_in_reg_firsttransfer);
  --niosII_openMac_clock_0_in_unreg_firsttransfer first transaction, which is an e_assign
  niosII_openMac_clock_0_in_unreg_firsttransfer <= NOT ((niosII_openMac_clock_0_in_slavearbiterlockenable AND niosII_openMac_clock_0_in_any_continuerequest));
  --niosII_openMac_clock_0_in_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_0_in_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(niosII_openMac_clock_0_in_begins_xfer) = '1' then 
        niosII_openMac_clock_0_in_reg_firsttransfer <= niosII_openMac_clock_0_in_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_0_in_beginbursttransfer_internal begin burst transfer, which is an e_assign
  niosII_openMac_clock_0_in_beginbursttransfer_internal <= niosII_openMac_clock_0_in_begins_xfer;
  --niosII_openMac_clock_0_in_read assignment, which is an e_mux
  niosII_openMac_clock_0_in_read <= internal_pcp_cpu_data_master_granted_niosII_openMac_clock_0_in AND pcp_cpu_data_master_read;
  --niosII_openMac_clock_0_in_write assignment, which is an e_mux
  niosII_openMac_clock_0_in_write <= internal_pcp_cpu_data_master_granted_niosII_openMac_clock_0_in AND pcp_cpu_data_master_write;
  --niosII_openMac_clock_0_in_address mux, which is an e_mux
  niosII_openMac_clock_0_in_address <= pcp_cpu_data_master_address_to_slave (3 DOWNTO 0);
  --slaveid niosII_openMac_clock_0_in_nativeaddress nativeaddress mux, which is an e_mux
  niosII_openMac_clock_0_in_nativeaddress <= A_EXT (A_SRL(pcp_cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_niosII_openMac_clock_0_in_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_niosII_openMac_clock_0_in_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_niosII_openMac_clock_0_in_end_xfer <= niosII_openMac_clock_0_in_end_xfer;
    end if;

  end process;

  --niosII_openMac_clock_0_in_waits_for_read in a cycle, which is an e_mux
  niosII_openMac_clock_0_in_waits_for_read <= niosII_openMac_clock_0_in_in_a_read_cycle AND internal_niosII_openMac_clock_0_in_waitrequest_from_sa;
  --niosII_openMac_clock_0_in_in_a_read_cycle assignment, which is an e_assign
  niosII_openMac_clock_0_in_in_a_read_cycle <= internal_pcp_cpu_data_master_granted_niosII_openMac_clock_0_in AND pcp_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= niosII_openMac_clock_0_in_in_a_read_cycle;
  --niosII_openMac_clock_0_in_waits_for_write in a cycle, which is an e_mux
  niosII_openMac_clock_0_in_waits_for_write <= niosII_openMac_clock_0_in_in_a_write_cycle AND internal_niosII_openMac_clock_0_in_waitrequest_from_sa;
  --niosII_openMac_clock_0_in_in_a_write_cycle assignment, which is an e_assign
  niosII_openMac_clock_0_in_in_a_write_cycle <= internal_pcp_cpu_data_master_granted_niosII_openMac_clock_0_in AND pcp_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= niosII_openMac_clock_0_in_in_a_write_cycle;
  wait_for_niosII_openMac_clock_0_in_counter <= std_logic'('0');
  --niosII_openMac_clock_0_in_byteenable byte enable port mux, which is an e_mux
  niosII_openMac_clock_0_in_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_niosII_openMac_clock_0_in)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (pcp_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  niosII_openMac_clock_0_in_waitrequest_from_sa <= internal_niosII_openMac_clock_0_in_waitrequest_from_sa;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_granted_niosII_openMac_clock_0_in <= internal_pcp_cpu_data_master_granted_niosII_openMac_clock_0_in;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in <= internal_pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_requests_niosII_openMac_clock_0_in <= internal_pcp_cpu_data_master_requests_niosII_openMac_clock_0_in;
--synthesis translate_off
    --niosII_openMac_clock_0/in enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity niosII_openMac_clock_0_out_arbitrator is 
        port (
              -- inputs:
                 signal altpll_0_pll_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal d1_altpll_0_pll_slave_end_xfer : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_0_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_0_out_granted_altpll_0_pll_slave : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_read_data_valid_altpll_0_pll_slave : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_requests_altpll_0_pll_slave : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal niosII_openMac_clock_0_out_address_to_slave : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_0_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_0_out_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_out_waitrequest : OUT STD_LOGIC
              );
end entity niosII_openMac_clock_0_out_arbitrator;


architecture europa of niosII_openMac_clock_0_out_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_niosII_openMac_clock_0_out_address_to_slave :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_niosII_openMac_clock_0_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_address_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_0_out_byteenable_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_0_out_read_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_run :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_write_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_writedata_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal r_0 :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001") AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave OR NOT ((niosII_openMac_clock_0_out_read OR niosII_openMac_clock_0_out_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_0_out_read OR niosII_openMac_clock_0_out_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave OR NOT ((niosII_openMac_clock_0_out_read OR niosII_openMac_clock_0_out_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_0_out_read OR niosII_openMac_clock_0_out_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  niosII_openMac_clock_0_out_run <= r_0;
  --optimize select-logic by passing only those address bits which matter.
  internal_niosII_openMac_clock_0_out_address_to_slave <= niosII_openMac_clock_0_out_address;
  --niosII_openMac_clock_0/out readdata mux, which is an e_mux
  niosII_openMac_clock_0_out_readdata <= altpll_0_pll_slave_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_niosII_openMac_clock_0_out_waitrequest <= NOT niosII_openMac_clock_0_out_run;
  --niosII_openMac_clock_0_out_reset_n assignment, which is an e_assign
  niosII_openMac_clock_0_out_reset_n <= reset_n;
  --vhdl renameroo for output signals
  niosII_openMac_clock_0_out_address_to_slave <= internal_niosII_openMac_clock_0_out_address_to_slave;
  --vhdl renameroo for output signals
  niosII_openMac_clock_0_out_waitrequest <= internal_niosII_openMac_clock_0_out_waitrequest;
--synthesis translate_off
    --niosII_openMac_clock_0_out_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_0_out_address_last_time <= std_logic_vector'("0000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_0_out_address_last_time <= niosII_openMac_clock_0_out_address;
      end if;

    end process;

    --niosII_openMac_clock_0/out waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_niosII_openMac_clock_0_out_waitrequest AND ((niosII_openMac_clock_0_out_read OR niosII_openMac_clock_0_out_write));
      end if;

    end process;

    --niosII_openMac_clock_0_out_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line12 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_0_out_address /= niosII_openMac_clock_0_out_address_last_time))))) = '1' then 
          write(write_line12, now);
          write(write_line12, string'(": "));
          write(write_line12, string'("niosII_openMac_clock_0_out_address did not heed wait!!!"));
          write(output, write_line12.all);
          deallocate (write_line12);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_0_out_byteenable check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_0_out_byteenable_last_time <= std_logic_vector'("0000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_0_out_byteenable_last_time <= niosII_openMac_clock_0_out_byteenable;
      end if;

    end process;

    --niosII_openMac_clock_0_out_byteenable matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line13 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_0_out_byteenable /= niosII_openMac_clock_0_out_byteenable_last_time))))) = '1' then 
          write(write_line13, now);
          write(write_line13, string'(": "));
          write(write_line13, string'("niosII_openMac_clock_0_out_byteenable did not heed wait!!!"));
          write(output, write_line13.all);
          deallocate (write_line13);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_0_out_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_0_out_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_0_out_read_last_time <= niosII_openMac_clock_0_out_read;
      end if;

    end process;

    --niosII_openMac_clock_0_out_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line14 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_0_out_read) /= std_logic'(niosII_openMac_clock_0_out_read_last_time)))))) = '1' then 
          write(write_line14, now);
          write(write_line14, string'(": "));
          write(write_line14, string'("niosII_openMac_clock_0_out_read did not heed wait!!!"));
          write(output, write_line14.all);
          deallocate (write_line14);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_0_out_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_0_out_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_0_out_write_last_time <= niosII_openMac_clock_0_out_write;
      end if;

    end process;

    --niosII_openMac_clock_0_out_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line15 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_0_out_write) /= std_logic'(niosII_openMac_clock_0_out_write_last_time)))))) = '1' then 
          write(write_line15, now);
          write(write_line15, string'(": "));
          write(write_line15, string'("niosII_openMac_clock_0_out_write did not heed wait!!!"));
          write(output, write_line15.all);
          deallocate (write_line15);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_0_out_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_0_out_writedata_last_time <= std_logic_vector'("00000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_0_out_writedata_last_time <= niosII_openMac_clock_0_out_writedata;
      end if;

    end process;

    --niosII_openMac_clock_0_out_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line16 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_0_out_writedata /= niosII_openMac_clock_0_out_writedata_last_time)))) AND niosII_openMac_clock_0_out_write)) = '1' then 
          write(write_line16, now);
          write(write_line16, string'(": "));
          write(write_line16, string'("niosII_openMac_clock_0_out_writedata did not heed wait!!!"));
          write(output, write_line16.all);
          deallocate (write_line16);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity niosII_openMac_clock_1_in_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_in_endofpacket : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_waitrequest : IN STD_LOGIC;
                 signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal pcp_cpu_data_master_read : IN STD_LOGIC;
                 signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal pcp_cpu_data_master_write : IN STD_LOGIC;
                 signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_niosII_openMac_clock_1_in_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_address : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_nativeaddress : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_read : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_write : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_data_master_granted_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_requests_niosII_openMac_clock_1_in : OUT STD_LOGIC
              );
end entity niosII_openMac_clock_1_in_arbitrator;


architecture europa of niosII_openMac_clock_1_in_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_in_waitrequest_from_sa :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_granted_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_requests_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_allgrants :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_allow_new_arb_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_any_bursting_master_saved_grant :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_any_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_arb_counter_enable :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_1_in_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_1_in_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_1_in_beginbursttransfer_internal :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_begins_xfer :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_end_xfer :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_grant_vector :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_in_a_read_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_in_a_write_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_master_qreq_vector :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_non_bursting_master_requests :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_reg_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_slavearbiterlockenable :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_slavearbiterlockenable2 :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_unreg_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_waits_for_read :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_waits_for_write :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_data_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_data_master_saved_grant_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal shifted_address_to_niosII_openMac_clock_1_in_from_pcp_cpu_data_master :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal wait_for_niosII_openMac_clock_1_in_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT niosII_openMac_clock_1_in_end_xfer;
    end if;

  end process;

  niosII_openMac_clock_1_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in);
  --assign niosII_openMac_clock_1_in_readdata_from_sa = niosII_openMac_clock_1_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_1_in_readdata_from_sa <= niosII_openMac_clock_1_in_readdata;
  internal_pcp_cpu_data_master_requests_niosII_openMac_clock_1_in <= to_std_logic(((Std_Logic_Vector'(pcp_cpu_data_master_address_to_slave(24 DOWNTO 8) & std_logic_vector'("00000000")) = std_logic_vector'("0000000000000100000000000")))) AND ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write));
  --assign niosII_openMac_clock_1_in_waitrequest_from_sa = niosII_openMac_clock_1_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_niosII_openMac_clock_1_in_waitrequest_from_sa <= niosII_openMac_clock_1_in_waitrequest;
  --niosII_openMac_clock_1_in_arb_share_counter set values, which is an e_mux
  niosII_openMac_clock_1_in_arb_share_set_values <= std_logic_vector'("01");
  --niosII_openMac_clock_1_in_non_bursting_master_requests mux, which is an e_mux
  niosII_openMac_clock_1_in_non_bursting_master_requests <= internal_pcp_cpu_data_master_requests_niosII_openMac_clock_1_in;
  --niosII_openMac_clock_1_in_any_bursting_master_saved_grant mux, which is an e_mux
  niosII_openMac_clock_1_in_any_bursting_master_saved_grant <= std_logic'('0');
  --niosII_openMac_clock_1_in_arb_share_counter_next_value assignment, which is an e_assign
  niosII_openMac_clock_1_in_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(niosII_openMac_clock_1_in_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (niosII_openMac_clock_1_in_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(niosII_openMac_clock_1_in_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (niosII_openMac_clock_1_in_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --niosII_openMac_clock_1_in_allgrants all slave grants, which is an e_mux
  niosII_openMac_clock_1_in_allgrants <= niosII_openMac_clock_1_in_grant_vector;
  --niosII_openMac_clock_1_in_end_xfer assignment, which is an e_assign
  niosII_openMac_clock_1_in_end_xfer <= NOT ((niosII_openMac_clock_1_in_waits_for_read OR niosII_openMac_clock_1_in_waits_for_write));
  --end_xfer_arb_share_counter_term_niosII_openMac_clock_1_in arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_niosII_openMac_clock_1_in <= niosII_openMac_clock_1_in_end_xfer AND (((NOT niosII_openMac_clock_1_in_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --niosII_openMac_clock_1_in_arb_share_counter arbitration counter enable, which is an e_assign
  niosII_openMac_clock_1_in_arb_counter_enable <= ((end_xfer_arb_share_counter_term_niosII_openMac_clock_1_in AND niosII_openMac_clock_1_in_allgrants)) OR ((end_xfer_arb_share_counter_term_niosII_openMac_clock_1_in AND NOT niosII_openMac_clock_1_in_non_bursting_master_requests));
  --niosII_openMac_clock_1_in_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_1_in_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(niosII_openMac_clock_1_in_arb_counter_enable) = '1' then 
        niosII_openMac_clock_1_in_arb_share_counter <= niosII_openMac_clock_1_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_1_in_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_1_in_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((niosII_openMac_clock_1_in_master_qreq_vector AND end_xfer_arb_share_counter_term_niosII_openMac_clock_1_in)) OR ((end_xfer_arb_share_counter_term_niosII_openMac_clock_1_in AND NOT niosII_openMac_clock_1_in_non_bursting_master_requests)))) = '1' then 
        niosII_openMac_clock_1_in_slavearbiterlockenable <= or_reduce(niosII_openMac_clock_1_in_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --pcp_cpu/data_master niosII_openMac_clock_1/in arbiterlock, which is an e_assign
  pcp_cpu_data_master_arbiterlock <= niosII_openMac_clock_1_in_slavearbiterlockenable AND pcp_cpu_data_master_continuerequest;
  --niosII_openMac_clock_1_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  niosII_openMac_clock_1_in_slavearbiterlockenable2 <= or_reduce(niosII_openMac_clock_1_in_arb_share_counter_next_value);
  --pcp_cpu/data_master niosII_openMac_clock_1/in arbiterlock2, which is an e_assign
  pcp_cpu_data_master_arbiterlock2 <= niosII_openMac_clock_1_in_slavearbiterlockenable2 AND pcp_cpu_data_master_continuerequest;
  --niosII_openMac_clock_1_in_any_continuerequest at least one master continues requesting, which is an e_assign
  niosII_openMac_clock_1_in_any_continuerequest <= std_logic'('1');
  --pcp_cpu_data_master_continuerequest continued request, which is an e_assign
  pcp_cpu_data_master_continuerequest <= std_logic'('1');
  internal_pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in <= internal_pcp_cpu_data_master_requests_niosII_openMac_clock_1_in AND NOT ((((pcp_cpu_data_master_read AND (NOT pcp_cpu_data_master_waitrequest))) OR (((NOT pcp_cpu_data_master_waitrequest) AND pcp_cpu_data_master_write))));
  --niosII_openMac_clock_1_in_writedata mux, which is an e_mux
  niosII_openMac_clock_1_in_writedata <= pcp_cpu_data_master_writedata;
  --assign niosII_openMac_clock_1_in_endofpacket_from_sa = niosII_openMac_clock_1_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_1_in_endofpacket_from_sa <= niosII_openMac_clock_1_in_endofpacket;
  --master is always granted when requested
  internal_pcp_cpu_data_master_granted_niosII_openMac_clock_1_in <= internal_pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in;
  --pcp_cpu/data_master saved-grant niosII_openMac_clock_1/in, which is an e_assign
  pcp_cpu_data_master_saved_grant_niosII_openMac_clock_1_in <= internal_pcp_cpu_data_master_requests_niosII_openMac_clock_1_in;
  --allow new arb cycle for niosII_openMac_clock_1/in, which is an e_assign
  niosII_openMac_clock_1_in_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  niosII_openMac_clock_1_in_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  niosII_openMac_clock_1_in_master_qreq_vector <= std_logic'('1');
  --niosII_openMac_clock_1_in_reset_n assignment, which is an e_assign
  niosII_openMac_clock_1_in_reset_n <= reset_n;
  --niosII_openMac_clock_1_in_firsttransfer first transaction, which is an e_assign
  niosII_openMac_clock_1_in_firsttransfer <= A_WE_StdLogic((std_logic'(niosII_openMac_clock_1_in_begins_xfer) = '1'), niosII_openMac_clock_1_in_unreg_firsttransfer, niosII_openMac_clock_1_in_reg_firsttransfer);
  --niosII_openMac_clock_1_in_unreg_firsttransfer first transaction, which is an e_assign
  niosII_openMac_clock_1_in_unreg_firsttransfer <= NOT ((niosII_openMac_clock_1_in_slavearbiterlockenable AND niosII_openMac_clock_1_in_any_continuerequest));
  --niosII_openMac_clock_1_in_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_1_in_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(niosII_openMac_clock_1_in_begins_xfer) = '1' then 
        niosII_openMac_clock_1_in_reg_firsttransfer <= niosII_openMac_clock_1_in_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_1_in_beginbursttransfer_internal begin burst transfer, which is an e_assign
  niosII_openMac_clock_1_in_beginbursttransfer_internal <= niosII_openMac_clock_1_in_begins_xfer;
  --niosII_openMac_clock_1_in_read assignment, which is an e_mux
  niosII_openMac_clock_1_in_read <= internal_pcp_cpu_data_master_granted_niosII_openMac_clock_1_in AND pcp_cpu_data_master_read;
  --niosII_openMac_clock_1_in_write assignment, which is an e_mux
  niosII_openMac_clock_1_in_write <= internal_pcp_cpu_data_master_granted_niosII_openMac_clock_1_in AND pcp_cpu_data_master_write;
  shifted_address_to_niosII_openMac_clock_1_in_from_pcp_cpu_data_master <= pcp_cpu_data_master_address_to_slave;
  --niosII_openMac_clock_1_in_address mux, which is an e_mux
  niosII_openMac_clock_1_in_address <= A_EXT (A_SRL(shifted_address_to_niosII_openMac_clock_1_in_from_pcp_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 8);
  --slaveid niosII_openMac_clock_1_in_nativeaddress nativeaddress mux, which is an e_mux
  niosII_openMac_clock_1_in_nativeaddress <= A_EXT (A_SRL(pcp_cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 6);
  --d1_niosII_openMac_clock_1_in_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_niosII_openMac_clock_1_in_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_niosII_openMac_clock_1_in_end_xfer <= niosII_openMac_clock_1_in_end_xfer;
    end if;

  end process;

  --niosII_openMac_clock_1_in_waits_for_read in a cycle, which is an e_mux
  niosII_openMac_clock_1_in_waits_for_read <= niosII_openMac_clock_1_in_in_a_read_cycle AND internal_niosII_openMac_clock_1_in_waitrequest_from_sa;
  --niosII_openMac_clock_1_in_in_a_read_cycle assignment, which is an e_assign
  niosII_openMac_clock_1_in_in_a_read_cycle <= internal_pcp_cpu_data_master_granted_niosII_openMac_clock_1_in AND pcp_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= niosII_openMac_clock_1_in_in_a_read_cycle;
  --niosII_openMac_clock_1_in_waits_for_write in a cycle, which is an e_mux
  niosII_openMac_clock_1_in_waits_for_write <= niosII_openMac_clock_1_in_in_a_write_cycle AND internal_niosII_openMac_clock_1_in_waitrequest_from_sa;
  --niosII_openMac_clock_1_in_in_a_write_cycle assignment, which is an e_assign
  niosII_openMac_clock_1_in_in_a_write_cycle <= internal_pcp_cpu_data_master_granted_niosII_openMac_clock_1_in AND pcp_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= niosII_openMac_clock_1_in_in_a_write_cycle;
  wait_for_niosII_openMac_clock_1_in_counter <= std_logic'('0');
  --niosII_openMac_clock_1_in_byteenable byte enable port mux, which is an e_mux
  niosII_openMac_clock_1_in_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_niosII_openMac_clock_1_in)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (pcp_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_in_waitrequest_from_sa <= internal_niosII_openMac_clock_1_in_waitrequest_from_sa;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_granted_niosII_openMac_clock_1_in <= internal_pcp_cpu_data_master_granted_niosII_openMac_clock_1_in;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in <= internal_pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_requests_niosII_openMac_clock_1_in <= internal_pcp_cpu_data_master_requests_niosII_openMac_clock_1_in;
--synthesis translate_off
    --niosII_openMac_clock_1/in enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity niosII_openMac_clock_1_out_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal d1_remote_update_cycloneiii_0_s1_end_xfer : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal remote_update_cycloneiii_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal remote_update_cycloneiii_0_s1_waitrequest_from_sa : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal niosII_openMac_clock_1_out_address_to_slave : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_waitrequest : OUT STD_LOGIC
              );
end entity niosII_openMac_clock_1_out_arbitrator;


architecture europa of niosII_openMac_clock_1_out_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_out_address_to_slave :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_niosII_openMac_clock_1_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_address_last_time :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal niosII_openMac_clock_1_out_byteenable_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_1_out_read_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_run :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_write_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_writedata_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal r_1 :  STD_LOGIC;

begin

  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1 OR niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1) OR NOT niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1 OR NOT niosII_openMac_clock_1_out_read) OR ((niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1 AND niosII_openMac_clock_1_out_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1 OR NOT ((niosII_openMac_clock_1_out_read OR niosII_openMac_clock_1_out_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT remote_update_cycloneiii_0_s1_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_1_out_read OR niosII_openMac_clock_1_out_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  niosII_openMac_clock_1_out_run <= r_1;
  --optimize select-logic by passing only those address bits which matter.
  internal_niosII_openMac_clock_1_out_address_to_slave <= niosII_openMac_clock_1_out_address;
  --niosII_openMac_clock_1/out readdata mux, which is an e_mux
  niosII_openMac_clock_1_out_readdata <= remote_update_cycloneiii_0_s1_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_niosII_openMac_clock_1_out_waitrequest <= NOT niosII_openMac_clock_1_out_run;
  --niosII_openMac_clock_1_out_reset_n assignment, which is an e_assign
  niosII_openMac_clock_1_out_reset_n <= reset_n;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_address_to_slave <= internal_niosII_openMac_clock_1_out_address_to_slave;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_waitrequest <= internal_niosII_openMac_clock_1_out_waitrequest;
--synthesis translate_off
    --niosII_openMac_clock_1_out_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_1_out_address_last_time <= std_logic_vector'("00000000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_1_out_address_last_time <= niosII_openMac_clock_1_out_address;
      end if;

    end process;

    --niosII_openMac_clock_1/out waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_niosII_openMac_clock_1_out_waitrequest AND ((niosII_openMac_clock_1_out_read OR niosII_openMac_clock_1_out_write));
      end if;

    end process;

    --niosII_openMac_clock_1_out_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line17 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_1_out_address /= niosII_openMac_clock_1_out_address_last_time))))) = '1' then 
          write(write_line17, now);
          write(write_line17, string'(": "));
          write(write_line17, string'("niosII_openMac_clock_1_out_address did not heed wait!!!"));
          write(output, write_line17.all);
          deallocate (write_line17);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_1_out_byteenable check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_1_out_byteenable_last_time <= std_logic_vector'("0000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_1_out_byteenable_last_time <= niosII_openMac_clock_1_out_byteenable;
      end if;

    end process;

    --niosII_openMac_clock_1_out_byteenable matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line18 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_1_out_byteenable /= niosII_openMac_clock_1_out_byteenable_last_time))))) = '1' then 
          write(write_line18, now);
          write(write_line18, string'(": "));
          write(write_line18, string'("niosII_openMac_clock_1_out_byteenable did not heed wait!!!"));
          write(output, write_line18.all);
          deallocate (write_line18);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_1_out_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_1_out_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_1_out_read_last_time <= niosII_openMac_clock_1_out_read;
      end if;

    end process;

    --niosII_openMac_clock_1_out_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line19 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_1_out_read) /= std_logic'(niosII_openMac_clock_1_out_read_last_time)))))) = '1' then 
          write(write_line19, now);
          write(write_line19, string'(": "));
          write(write_line19, string'("niosII_openMac_clock_1_out_read did not heed wait!!!"));
          write(output, write_line19.all);
          deallocate (write_line19);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_1_out_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_1_out_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_1_out_write_last_time <= niosII_openMac_clock_1_out_write;
      end if;

    end process;

    --niosII_openMac_clock_1_out_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line20 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_1_out_write) /= std_logic'(niosII_openMac_clock_1_out_write_last_time)))))) = '1' then 
          write(write_line20, now);
          write(write_line20, string'(": "));
          write(write_line20, string'("niosII_openMac_clock_1_out_write did not heed wait!!!"));
          write(output, write_line20.all);
          deallocate (write_line20);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_1_out_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_1_out_writedata_last_time <= std_logic_vector'("00000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_1_out_writedata_last_time <= niosII_openMac_clock_1_out_writedata;
      end if;

    end process;

    --niosII_openMac_clock_1_out_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line21 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_1_out_writedata /= niosII_openMac_clock_1_out_writedata_last_time)))) AND niosII_openMac_clock_1_out_write)) = '1' then 
          write(write_line21, now);
          write(write_line21, string'(": "));
          write(write_line21, string'("niosII_openMac_clock_1_out_writedata did not heed wait!!!"));
          write(output, write_line21.all);
          deallocate (write_line21);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity node_switch_pio_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal node_switch_pio_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal clock_crossing_0_m1_granted_node_switch_pio_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_node_switch_pio_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_node_switch_pio_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_node_switch_pio_s1 : OUT STD_LOGIC;
                 signal d1_node_switch_pio_s1_end_xfer : OUT STD_LOGIC;
                 signal node_switch_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal node_switch_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal node_switch_pio_s1_reset_n : OUT STD_LOGIC
              );
end entity node_switch_pio_s1_arbitrator;


architecture europa of node_switch_pio_s1_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_node_switch_pio_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_node_switch_pio_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_granted_node_switch_pio_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_node_switch_pio_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_node_switch_pio_s1 :  STD_LOGIC;
                signal node_switch_pio_s1_allgrants :  STD_LOGIC;
                signal node_switch_pio_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal node_switch_pio_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal node_switch_pio_s1_any_continuerequest :  STD_LOGIC;
                signal node_switch_pio_s1_arb_counter_enable :  STD_LOGIC;
                signal node_switch_pio_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal node_switch_pio_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal node_switch_pio_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal node_switch_pio_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal node_switch_pio_s1_begins_xfer :  STD_LOGIC;
                signal node_switch_pio_s1_end_xfer :  STD_LOGIC;
                signal node_switch_pio_s1_firsttransfer :  STD_LOGIC;
                signal node_switch_pio_s1_grant_vector :  STD_LOGIC;
                signal node_switch_pio_s1_in_a_read_cycle :  STD_LOGIC;
                signal node_switch_pio_s1_in_a_write_cycle :  STD_LOGIC;
                signal node_switch_pio_s1_master_qreq_vector :  STD_LOGIC;
                signal node_switch_pio_s1_non_bursting_master_requests :  STD_LOGIC;
                signal node_switch_pio_s1_reg_firsttransfer :  STD_LOGIC;
                signal node_switch_pio_s1_slavearbiterlockenable :  STD_LOGIC;
                signal node_switch_pio_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal node_switch_pio_s1_unreg_firsttransfer :  STD_LOGIC;
                signal node_switch_pio_s1_waits_for_read :  STD_LOGIC;
                signal node_switch_pio_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_node_switch_pio_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT node_switch_pio_s1_end_xfer;
    end if;

  end process;

  node_switch_pio_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_node_switch_pio_s1);
  --assign node_switch_pio_s1_readdata_from_sa = node_switch_pio_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  node_switch_pio_s1_readdata_from_sa <= node_switch_pio_s1_readdata;
  internal_clock_crossing_0_m1_requests_node_switch_pio_s1 <= ((to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(13 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("10000001010000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))) AND clock_crossing_0_m1_read;
  --node_switch_pio_s1_arb_share_counter set values, which is an e_mux
  node_switch_pio_s1_arb_share_set_values <= std_logic_vector'("01");
  --node_switch_pio_s1_non_bursting_master_requests mux, which is an e_mux
  node_switch_pio_s1_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_node_switch_pio_s1;
  --node_switch_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  node_switch_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --node_switch_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  node_switch_pio_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(node_switch_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (node_switch_pio_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(node_switch_pio_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (node_switch_pio_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --node_switch_pio_s1_allgrants all slave grants, which is an e_mux
  node_switch_pio_s1_allgrants <= node_switch_pio_s1_grant_vector;
  --node_switch_pio_s1_end_xfer assignment, which is an e_assign
  node_switch_pio_s1_end_xfer <= NOT ((node_switch_pio_s1_waits_for_read OR node_switch_pio_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_node_switch_pio_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_node_switch_pio_s1 <= node_switch_pio_s1_end_xfer AND (((NOT node_switch_pio_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --node_switch_pio_s1_arb_share_counter arbitration counter enable, which is an e_assign
  node_switch_pio_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_node_switch_pio_s1 AND node_switch_pio_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_node_switch_pio_s1 AND NOT node_switch_pio_s1_non_bursting_master_requests));
  --node_switch_pio_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      node_switch_pio_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(node_switch_pio_s1_arb_counter_enable) = '1' then 
        node_switch_pio_s1_arb_share_counter <= node_switch_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --node_switch_pio_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      node_switch_pio_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((node_switch_pio_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_node_switch_pio_s1)) OR ((end_xfer_arb_share_counter_term_node_switch_pio_s1 AND NOT node_switch_pio_s1_non_bursting_master_requests)))) = '1' then 
        node_switch_pio_s1_slavearbiterlockenable <= or_reduce(node_switch_pio_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 node_switch_pio/s1 arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= node_switch_pio_s1_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --node_switch_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  node_switch_pio_s1_slavearbiterlockenable2 <= or_reduce(node_switch_pio_s1_arb_share_counter_next_value);
  --clock_crossing_0/m1 node_switch_pio/s1 arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= node_switch_pio_s1_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --node_switch_pio_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  node_switch_pio_s1_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_node_switch_pio_s1 <= internal_clock_crossing_0_m1_requests_node_switch_pio_s1 AND NOT ((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_node_switch_pio_s1, which is an e_mux
  clock_crossing_0_m1_read_data_valid_node_switch_pio_s1 <= (internal_clock_crossing_0_m1_granted_node_switch_pio_s1 AND clock_crossing_0_m1_read) AND NOT node_switch_pio_s1_waits_for_read;
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_node_switch_pio_s1 <= internal_clock_crossing_0_m1_qualified_request_node_switch_pio_s1;
  --clock_crossing_0/m1 saved-grant node_switch_pio/s1, which is an e_assign
  clock_crossing_0_m1_saved_grant_node_switch_pio_s1 <= internal_clock_crossing_0_m1_requests_node_switch_pio_s1;
  --allow new arb cycle for node_switch_pio/s1, which is an e_assign
  node_switch_pio_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  node_switch_pio_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  node_switch_pio_s1_master_qreq_vector <= std_logic'('1');
  --node_switch_pio_s1_reset_n assignment, which is an e_assign
  node_switch_pio_s1_reset_n <= reset_n;
  --node_switch_pio_s1_firsttransfer first transaction, which is an e_assign
  node_switch_pio_s1_firsttransfer <= A_WE_StdLogic((std_logic'(node_switch_pio_s1_begins_xfer) = '1'), node_switch_pio_s1_unreg_firsttransfer, node_switch_pio_s1_reg_firsttransfer);
  --node_switch_pio_s1_unreg_firsttransfer first transaction, which is an e_assign
  node_switch_pio_s1_unreg_firsttransfer <= NOT ((node_switch_pio_s1_slavearbiterlockenable AND node_switch_pio_s1_any_continuerequest));
  --node_switch_pio_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      node_switch_pio_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(node_switch_pio_s1_begins_xfer) = '1' then 
        node_switch_pio_s1_reg_firsttransfer <= node_switch_pio_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --node_switch_pio_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  node_switch_pio_s1_beginbursttransfer_internal <= node_switch_pio_s1_begins_xfer;
  --node_switch_pio_s1_address mux, which is an e_mux
  node_switch_pio_s1_address <= clock_crossing_0_m1_nativeaddress (1 DOWNTO 0);
  --d1_node_switch_pio_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_node_switch_pio_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_node_switch_pio_s1_end_xfer <= node_switch_pio_s1_end_xfer;
    end if;

  end process;

  --node_switch_pio_s1_waits_for_read in a cycle, which is an e_mux
  node_switch_pio_s1_waits_for_read <= node_switch_pio_s1_in_a_read_cycle AND node_switch_pio_s1_begins_xfer;
  --node_switch_pio_s1_in_a_read_cycle assignment, which is an e_assign
  node_switch_pio_s1_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_node_switch_pio_s1 AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= node_switch_pio_s1_in_a_read_cycle;
  --node_switch_pio_s1_waits_for_write in a cycle, which is an e_mux
  node_switch_pio_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(node_switch_pio_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --node_switch_pio_s1_in_a_write_cycle assignment, which is an e_assign
  node_switch_pio_s1_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_node_switch_pio_s1 AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= node_switch_pio_s1_in_a_write_cycle;
  wait_for_node_switch_pio_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_node_switch_pio_s1 <= internal_clock_crossing_0_m1_granted_node_switch_pio_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_node_switch_pio_s1 <= internal_clock_crossing_0_m1_qualified_request_node_switch_pio_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_node_switch_pio_s1 <= internal_clock_crossing_0_m1_requests_node_switch_pio_s1;
--synthesis translate_off
    --node_switch_pio/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity onchip_memory_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal onchip_memory_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal pcp_cpu_data_master_read : IN STD_LOGIC;
                 signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal pcp_cpu_data_master_write : IN STD_LOGIC;
                 signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (21 DOWNTO 0);
                 signal pcp_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pcp_cpu_instruction_master_read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_onchip_memory_0_s1_end_xfer : OUT STD_LOGIC;
                 signal onchip_memory_0_s1_address : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal onchip_memory_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal onchip_memory_0_s1_chipselect : OUT STD_LOGIC;
                 signal onchip_memory_0_s1_clken : OUT STD_LOGIC;
                 signal onchip_memory_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal onchip_memory_0_s1_write : OUT STD_LOGIC;
                 signal onchip_memory_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_data_master_granted_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_requests_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_granted_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_requests_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal registered_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 : OUT STD_LOGIC
              );
end entity onchip_memory_0_s1_arbitrator;


architecture europa of onchip_memory_0_s1_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_onchip_memory_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_granted_onchip_memory_0_s1 :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_requests_onchip_memory_0_s1 :  STD_LOGIC;
                signal internal_pcp_cpu_instruction_master_granted_onchip_memory_0_s1 :  STD_LOGIC;
                signal internal_pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1 :  STD_LOGIC;
                signal internal_pcp_cpu_instruction_master_requests_onchip_memory_0_s1 :  STD_LOGIC;
                signal last_cycle_pcp_cpu_data_master_granted_slave_onchip_memory_0_s1 :  STD_LOGIC;
                signal last_cycle_pcp_cpu_instruction_master_granted_slave_onchip_memory_0_s1 :  STD_LOGIC;
                signal onchip_memory_0_s1_allgrants :  STD_LOGIC;
                signal onchip_memory_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal onchip_memory_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal onchip_memory_0_s1_any_continuerequest :  STD_LOGIC;
                signal onchip_memory_0_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory_0_s1_arb_counter_enable :  STD_LOGIC;
                signal onchip_memory_0_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory_0_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory_0_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory_0_s1_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory_0_s1_arbitration_holdoff_internal :  STD_LOGIC;
                signal onchip_memory_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal onchip_memory_0_s1_begins_xfer :  STD_LOGIC;
                signal onchip_memory_0_s1_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal onchip_memory_0_s1_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory_0_s1_end_xfer :  STD_LOGIC;
                signal onchip_memory_0_s1_firsttransfer :  STD_LOGIC;
                signal onchip_memory_0_s1_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal onchip_memory_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal onchip_memory_0_s1_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal onchip_memory_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal onchip_memory_0_s1_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal onchip_memory_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal onchip_memory_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal onchip_memory_0_s1_waits_for_read :  STD_LOGIC;
                signal onchip_memory_0_s1_waits_for_write :  STD_LOGIC;
                signal p1_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register :  STD_LOGIC;
                signal p1_pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_data_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register_in :  STD_LOGIC;
                signal pcp_cpu_data_master_saved_grant_onchip_memory_0_s1 :  STD_LOGIC;
                signal pcp_cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register :  STD_LOGIC;
                signal pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register_in :  STD_LOGIC;
                signal pcp_cpu_instruction_master_saved_grant_onchip_memory_0_s1 :  STD_LOGIC;
                signal shifted_address_to_onchip_memory_0_s1_from_pcp_cpu_data_master :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal shifted_address_to_onchip_memory_0_s1_from_pcp_cpu_instruction_master :  STD_LOGIC_VECTOR (21 DOWNTO 0);
                signal wait_for_onchip_memory_0_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT onchip_memory_0_s1_end_xfer;
    end if;

  end process;

  onchip_memory_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 OR internal_pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1));
  --assign onchip_memory_0_s1_readdata_from_sa = onchip_memory_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  onchip_memory_0_s1_readdata_from_sa <= onchip_memory_0_s1_readdata;
  internal_pcp_cpu_data_master_requests_onchip_memory_0_s1 <= to_std_logic(((Std_Logic_Vector'(pcp_cpu_data_master_address_to_slave(24 DOWNTO 10) & std_logic_vector'("0000000000")) = std_logic_vector'("0000000000010000000000000")))) AND ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write));
  --registered rdv signal_name registered_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 assignment, which is an e_assign
  registered_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 <= pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register_in;
  --onchip_memory_0_s1_arb_share_counter set values, which is an e_mux
  onchip_memory_0_s1_arb_share_set_values <= std_logic_vector'("01");
  --onchip_memory_0_s1_non_bursting_master_requests mux, which is an e_mux
  onchip_memory_0_s1_non_bursting_master_requests <= ((internal_pcp_cpu_data_master_requests_onchip_memory_0_s1 OR internal_pcp_cpu_instruction_master_requests_onchip_memory_0_s1) OR internal_pcp_cpu_data_master_requests_onchip_memory_0_s1) OR internal_pcp_cpu_instruction_master_requests_onchip_memory_0_s1;
  --onchip_memory_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  onchip_memory_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --onchip_memory_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  onchip_memory_0_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(onchip_memory_0_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (onchip_memory_0_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(onchip_memory_0_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (onchip_memory_0_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --onchip_memory_0_s1_allgrants all slave grants, which is an e_mux
  onchip_memory_0_s1_allgrants <= (((or_reduce(onchip_memory_0_s1_grant_vector)) OR (or_reduce(onchip_memory_0_s1_grant_vector))) OR (or_reduce(onchip_memory_0_s1_grant_vector))) OR (or_reduce(onchip_memory_0_s1_grant_vector));
  --onchip_memory_0_s1_end_xfer assignment, which is an e_assign
  onchip_memory_0_s1_end_xfer <= NOT ((onchip_memory_0_s1_waits_for_read OR onchip_memory_0_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_onchip_memory_0_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_onchip_memory_0_s1 <= onchip_memory_0_s1_end_xfer AND (((NOT onchip_memory_0_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --onchip_memory_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  onchip_memory_0_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_onchip_memory_0_s1 AND onchip_memory_0_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_onchip_memory_0_s1 AND NOT onchip_memory_0_s1_non_bursting_master_requests));
  --onchip_memory_0_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory_0_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_memory_0_s1_arb_counter_enable) = '1' then 
        onchip_memory_0_s1_arb_share_counter <= onchip_memory_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --onchip_memory_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory_0_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(onchip_memory_0_s1_master_qreq_vector) AND end_xfer_arb_share_counter_term_onchip_memory_0_s1)) OR ((end_xfer_arb_share_counter_term_onchip_memory_0_s1 AND NOT onchip_memory_0_s1_non_bursting_master_requests)))) = '1' then 
        onchip_memory_0_s1_slavearbiterlockenable <= or_reduce(onchip_memory_0_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --pcp_cpu/data_master onchip_memory_0/s1 arbiterlock, which is an e_assign
  pcp_cpu_data_master_arbiterlock <= onchip_memory_0_s1_slavearbiterlockenable AND pcp_cpu_data_master_continuerequest;
  --onchip_memory_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  onchip_memory_0_s1_slavearbiterlockenable2 <= or_reduce(onchip_memory_0_s1_arb_share_counter_next_value);
  --pcp_cpu/data_master onchip_memory_0/s1 arbiterlock2, which is an e_assign
  pcp_cpu_data_master_arbiterlock2 <= onchip_memory_0_s1_slavearbiterlockenable2 AND pcp_cpu_data_master_continuerequest;
  --pcp_cpu/instruction_master onchip_memory_0/s1 arbiterlock, which is an e_assign
  pcp_cpu_instruction_master_arbiterlock <= onchip_memory_0_s1_slavearbiterlockenable AND pcp_cpu_instruction_master_continuerequest;
  --pcp_cpu/instruction_master onchip_memory_0/s1 arbiterlock2, which is an e_assign
  pcp_cpu_instruction_master_arbiterlock2 <= onchip_memory_0_s1_slavearbiterlockenable2 AND pcp_cpu_instruction_master_continuerequest;
  --pcp_cpu/instruction_master granted onchip_memory_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_pcp_cpu_instruction_master_granted_slave_onchip_memory_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_pcp_cpu_instruction_master_granted_slave_onchip_memory_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pcp_cpu_instruction_master_saved_grant_onchip_memory_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_memory_0_s1_arbitration_holdoff_internal OR NOT internal_pcp_cpu_instruction_master_requests_onchip_memory_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_pcp_cpu_instruction_master_granted_slave_onchip_memory_0_s1))))));
    end if;

  end process;

  --pcp_cpu_instruction_master_continuerequest continued request, which is an e_mux
  pcp_cpu_instruction_master_continuerequest <= last_cycle_pcp_cpu_instruction_master_granted_slave_onchip_memory_0_s1 AND internal_pcp_cpu_instruction_master_requests_onchip_memory_0_s1;
  --onchip_memory_0_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  onchip_memory_0_s1_any_continuerequest <= pcp_cpu_instruction_master_continuerequest OR pcp_cpu_data_master_continuerequest;
  internal_pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 <= internal_pcp_cpu_data_master_requests_onchip_memory_0_s1 AND NOT (((((pcp_cpu_data_master_read AND (pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register))) OR (((NOT pcp_cpu_data_master_waitrequest) AND pcp_cpu_data_master_write))) OR pcp_cpu_instruction_master_arbiterlock));
  --pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register_in <= ((internal_pcp_cpu_data_master_granted_onchip_memory_0_s1 AND pcp_cpu_data_master_read) AND NOT onchip_memory_0_s1_waits_for_read) AND NOT (pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register);
  --shift register p1 pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register) & A_ToStdLogicVector(pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register_in)));
  --pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register <= p1_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register;
    end if;

  end process;

  --local readdatavalid pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1, which is an e_mux
  pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 <= pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register;
  --onchip_memory_0_s1_writedata mux, which is an e_mux
  onchip_memory_0_s1_writedata <= pcp_cpu_data_master_writedata;
  --mux onchip_memory_0_s1_clken, which is an e_mux
  onchip_memory_0_s1_clken <= std_logic'('1');
  internal_pcp_cpu_instruction_master_requests_onchip_memory_0_s1 <= ((to_std_logic(((Std_Logic_Vector'(pcp_cpu_instruction_master_address_to_slave(21 DOWNTO 10) & std_logic_vector'("0000000000")) = std_logic_vector'("0000000010000000000000")))) AND (pcp_cpu_instruction_master_read))) AND pcp_cpu_instruction_master_read;
  --pcp_cpu/data_master granted onchip_memory_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_pcp_cpu_data_master_granted_slave_onchip_memory_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_pcp_cpu_data_master_granted_slave_onchip_memory_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pcp_cpu_data_master_saved_grant_onchip_memory_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_memory_0_s1_arbitration_holdoff_internal OR NOT internal_pcp_cpu_data_master_requests_onchip_memory_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_pcp_cpu_data_master_granted_slave_onchip_memory_0_s1))))));
    end if;

  end process;

  --pcp_cpu_data_master_continuerequest continued request, which is an e_mux
  pcp_cpu_data_master_continuerequest <= last_cycle_pcp_cpu_data_master_granted_slave_onchip_memory_0_s1 AND internal_pcp_cpu_data_master_requests_onchip_memory_0_s1;
  internal_pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1 <= internal_pcp_cpu_instruction_master_requests_onchip_memory_0_s1 AND NOT ((((pcp_cpu_instruction_master_read AND to_std_logic(((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("000000000000000000000000000000") & (pcp_cpu_instruction_master_latency_counter))))))) OR pcp_cpu_data_master_arbiterlock));
  --pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register_in <= (internal_pcp_cpu_instruction_master_granted_onchip_memory_0_s1 AND pcp_cpu_instruction_master_read) AND NOT onchip_memory_0_s1_waits_for_read;
  --shift register p1 pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register) & A_ToStdLogicVector(pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register_in)));
  --pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register <= p1_pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register;
    end if;

  end process;

  --local readdatavalid pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1, which is an e_mux
  pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 <= pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register;
  --allow new arb cycle for onchip_memory_0/s1, which is an e_assign
  onchip_memory_0_s1_allow_new_arb_cycle <= NOT pcp_cpu_data_master_arbiterlock AND NOT pcp_cpu_instruction_master_arbiterlock;
  --pcp_cpu/instruction_master assignment into master qualified-requests vector for onchip_memory_0/s1, which is an e_assign
  onchip_memory_0_s1_master_qreq_vector(0) <= internal_pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1;
  --pcp_cpu/instruction_master grant onchip_memory_0/s1, which is an e_assign
  internal_pcp_cpu_instruction_master_granted_onchip_memory_0_s1 <= onchip_memory_0_s1_grant_vector(0);
  --pcp_cpu/instruction_master saved-grant onchip_memory_0/s1, which is an e_assign
  pcp_cpu_instruction_master_saved_grant_onchip_memory_0_s1 <= onchip_memory_0_s1_arb_winner(0) AND internal_pcp_cpu_instruction_master_requests_onchip_memory_0_s1;
  --pcp_cpu/data_master assignment into master qualified-requests vector for onchip_memory_0/s1, which is an e_assign
  onchip_memory_0_s1_master_qreq_vector(1) <= internal_pcp_cpu_data_master_qualified_request_onchip_memory_0_s1;
  --pcp_cpu/data_master grant onchip_memory_0/s1, which is an e_assign
  internal_pcp_cpu_data_master_granted_onchip_memory_0_s1 <= onchip_memory_0_s1_grant_vector(1);
  --pcp_cpu/data_master saved-grant onchip_memory_0/s1, which is an e_assign
  pcp_cpu_data_master_saved_grant_onchip_memory_0_s1 <= onchip_memory_0_s1_arb_winner(1) AND internal_pcp_cpu_data_master_requests_onchip_memory_0_s1;
  --onchip_memory_0/s1 chosen-master double-vector, which is an e_assign
  onchip_memory_0_s1_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((onchip_memory_0_s1_master_qreq_vector & onchip_memory_0_s1_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT onchip_memory_0_s1_master_qreq_vector & NOT onchip_memory_0_s1_master_qreq_vector))) + (std_logic_vector'("000") & (onchip_memory_0_s1_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  onchip_memory_0_s1_arb_winner <= A_WE_StdLogicVector((std_logic'(((onchip_memory_0_s1_allow_new_arb_cycle AND or_reduce(onchip_memory_0_s1_grant_vector)))) = '1'), onchip_memory_0_s1_grant_vector, onchip_memory_0_s1_saved_chosen_master_vector);
  --saved onchip_memory_0_s1_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory_0_s1_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_memory_0_s1_allow_new_arb_cycle) = '1' then 
        onchip_memory_0_s1_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(onchip_memory_0_s1_grant_vector)) = '1'), onchip_memory_0_s1_grant_vector, onchip_memory_0_s1_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  onchip_memory_0_s1_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((onchip_memory_0_s1_chosen_master_double_vector(1) OR onchip_memory_0_s1_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((onchip_memory_0_s1_chosen_master_double_vector(0) OR onchip_memory_0_s1_chosen_master_double_vector(2)))));
  --onchip_memory_0/s1 chosen master rotated left, which is an e_assign
  onchip_memory_0_s1_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(onchip_memory_0_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(onchip_memory_0_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --onchip_memory_0/s1's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory_0_s1_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(onchip_memory_0_s1_grant_vector)) = '1' then 
        onchip_memory_0_s1_arb_addend <= A_WE_StdLogicVector((std_logic'(onchip_memory_0_s1_end_xfer) = '1'), onchip_memory_0_s1_chosen_master_rot_left, onchip_memory_0_s1_grant_vector);
      end if;
    end if;

  end process;

  onchip_memory_0_s1_chipselect <= internal_pcp_cpu_data_master_granted_onchip_memory_0_s1 OR internal_pcp_cpu_instruction_master_granted_onchip_memory_0_s1;
  --onchip_memory_0_s1_firsttransfer first transaction, which is an e_assign
  onchip_memory_0_s1_firsttransfer <= A_WE_StdLogic((std_logic'(onchip_memory_0_s1_begins_xfer) = '1'), onchip_memory_0_s1_unreg_firsttransfer, onchip_memory_0_s1_reg_firsttransfer);
  --onchip_memory_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  onchip_memory_0_s1_unreg_firsttransfer <= NOT ((onchip_memory_0_s1_slavearbiterlockenable AND onchip_memory_0_s1_any_continuerequest));
  --onchip_memory_0_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory_0_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_memory_0_s1_begins_xfer) = '1' then 
        onchip_memory_0_s1_reg_firsttransfer <= onchip_memory_0_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --onchip_memory_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  onchip_memory_0_s1_beginbursttransfer_internal <= onchip_memory_0_s1_begins_xfer;
  --onchip_memory_0_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  onchip_memory_0_s1_arbitration_holdoff_internal <= onchip_memory_0_s1_begins_xfer AND onchip_memory_0_s1_firsttransfer;
  --onchip_memory_0_s1_write assignment, which is an e_mux
  onchip_memory_0_s1_write <= internal_pcp_cpu_data_master_granted_onchip_memory_0_s1 AND pcp_cpu_data_master_write;
  shifted_address_to_onchip_memory_0_s1_from_pcp_cpu_data_master <= pcp_cpu_data_master_address_to_slave;
  --onchip_memory_0_s1_address mux, which is an e_mux
  onchip_memory_0_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_onchip_memory_0_s1)) = '1'), (A_SRL(shifted_address_to_onchip_memory_0_s1_from_pcp_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (std_logic_vector'("000") & ((A_SRL(shifted_address_to_onchip_memory_0_s1_from_pcp_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))))), 8);
  shifted_address_to_onchip_memory_0_s1_from_pcp_cpu_instruction_master <= pcp_cpu_instruction_master_address_to_slave;
  --d1_onchip_memory_0_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_onchip_memory_0_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_onchip_memory_0_s1_end_xfer <= onchip_memory_0_s1_end_xfer;
    end if;

  end process;

  --onchip_memory_0_s1_waits_for_read in a cycle, which is an e_mux
  onchip_memory_0_s1_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_memory_0_s1_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_memory_0_s1_in_a_read_cycle assignment, which is an e_assign
  onchip_memory_0_s1_in_a_read_cycle <= ((internal_pcp_cpu_data_master_granted_onchip_memory_0_s1 AND pcp_cpu_data_master_read)) OR ((internal_pcp_cpu_instruction_master_granted_onchip_memory_0_s1 AND pcp_cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= onchip_memory_0_s1_in_a_read_cycle;
  --onchip_memory_0_s1_waits_for_write in a cycle, which is an e_mux
  onchip_memory_0_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_memory_0_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_memory_0_s1_in_a_write_cycle assignment, which is an e_assign
  onchip_memory_0_s1_in_a_write_cycle <= internal_pcp_cpu_data_master_granted_onchip_memory_0_s1 AND pcp_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= onchip_memory_0_s1_in_a_write_cycle;
  wait_for_onchip_memory_0_s1_counter <= std_logic'('0');
  --onchip_memory_0_s1_byteenable byte enable port mux, which is an e_mux
  onchip_memory_0_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_onchip_memory_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (pcp_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  pcp_cpu_data_master_granted_onchip_memory_0_s1 <= internal_pcp_cpu_data_master_granted_onchip_memory_0_s1;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 <= internal_pcp_cpu_data_master_qualified_request_onchip_memory_0_s1;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_requests_onchip_memory_0_s1 <= internal_pcp_cpu_data_master_requests_onchip_memory_0_s1;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_granted_onchip_memory_0_s1 <= internal_pcp_cpu_instruction_master_granted_onchip_memory_0_s1;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1 <= internal_pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_requests_onchip_memory_0_s1 <= internal_pcp_cpu_instruction_master_requests_onchip_memory_0_s1;
--synthesis translate_off
    --onchip_memory_0/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line22 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_pcp_cpu_data_master_granted_onchip_memory_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_pcp_cpu_instruction_master_granted_onchip_memory_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line22, now);
          write(write_line22, string'(": "));
          write(write_line22, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line22.all);
          deallocate (write_line22);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line23 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_saved_grant_onchip_memory_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(pcp_cpu_instruction_master_saved_grant_onchip_memory_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line23, now);
          write(write_line23, string'(": "));
          write(write_line23, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line23.all);
          deallocate (write_line23);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity pcp_cpu_jtag_debug_module_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal pcp_cpu_data_master_debugaccess : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read : IN STD_LOGIC;
                 signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal pcp_cpu_data_master_write : IN STD_LOGIC;
                 signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (21 DOWNTO 0);
                 signal pcp_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pcp_cpu_instruction_master_read : IN STD_LOGIC;
                 signal pcp_cpu_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_jtag_debug_module_resetrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_pcp_cpu_jtag_debug_module_end_xfer : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_read_data_valid_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal pcp_cpu_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal pcp_cpu_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                 signal pcp_cpu_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal pcp_cpu_jtag_debug_module_chipselect : OUT STD_LOGIC;
                 signal pcp_cpu_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                 signal pcp_cpu_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_jtag_debug_module_reset_n : OUT STD_LOGIC;
                 signal pcp_cpu_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                 signal pcp_cpu_jtag_debug_module_write : OUT STD_LOGIC;
                 signal pcp_cpu_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity pcp_cpu_jtag_debug_module_arbitrator;


architecture europa of pcp_cpu_jtag_debug_module_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal last_cycle_pcp_cpu_data_master_granted_slave_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal last_cycle_pcp_cpu_instruction_master_granted_slave_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_data_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_data_master_saved_grant_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal pcp_cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_instruction_master_saved_grant_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_allgrants :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_allow_new_arb_cycle :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_any_bursting_master_saved_grant :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_any_continuerequest :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_arb_counter_enable :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_arbitration_holdoff_internal :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_beginbursttransfer_internal :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_begins_xfer :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_firsttransfer :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_in_a_read_cycle :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_in_a_write_cycle :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_non_bursting_master_requests :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_reg_firsttransfer :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_slavearbiterlockenable :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_slavearbiterlockenable2 :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_unreg_firsttransfer :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_waits_for_read :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_pcp_cpu_jtag_debug_module_from_pcp_cpu_data_master :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal shifted_address_to_pcp_cpu_jtag_debug_module_from_pcp_cpu_instruction_master :  STD_LOGIC_VECTOR (21 DOWNTO 0);
                signal wait_for_pcp_cpu_jtag_debug_module_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT pcp_cpu_jtag_debug_module_end_xfer;
    end if;

  end process;

  pcp_cpu_jtag_debug_module_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module OR internal_pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module));
  --assign pcp_cpu_jtag_debug_module_readdata_from_sa = pcp_cpu_jtag_debug_module_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  pcp_cpu_jtag_debug_module_readdata_from_sa <= pcp_cpu_jtag_debug_module_readdata;
  internal_pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module <= to_std_logic(((Std_Logic_Vector'(pcp_cpu_data_master_address_to_slave(24 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0000000000001100000000000")))) AND ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write));
  --pcp_cpu_jtag_debug_module_arb_share_counter set values, which is an e_mux
  pcp_cpu_jtag_debug_module_arb_share_set_values <= std_logic_vector'("01");
  --pcp_cpu_jtag_debug_module_non_bursting_master_requests mux, which is an e_mux
  pcp_cpu_jtag_debug_module_non_bursting_master_requests <= ((internal_pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module OR internal_pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module) OR internal_pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module) OR internal_pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module;
  --pcp_cpu_jtag_debug_module_any_bursting_master_saved_grant mux, which is an e_mux
  pcp_cpu_jtag_debug_module_any_bursting_master_saved_grant <= std_logic'('0');
  --pcp_cpu_jtag_debug_module_arb_share_counter_next_value assignment, which is an e_assign
  pcp_cpu_jtag_debug_module_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(pcp_cpu_jtag_debug_module_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pcp_cpu_jtag_debug_module_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(pcp_cpu_jtag_debug_module_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (pcp_cpu_jtag_debug_module_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --pcp_cpu_jtag_debug_module_allgrants all slave grants, which is an e_mux
  pcp_cpu_jtag_debug_module_allgrants <= (((or_reduce(pcp_cpu_jtag_debug_module_grant_vector)) OR (or_reduce(pcp_cpu_jtag_debug_module_grant_vector))) OR (or_reduce(pcp_cpu_jtag_debug_module_grant_vector))) OR (or_reduce(pcp_cpu_jtag_debug_module_grant_vector));
  --pcp_cpu_jtag_debug_module_end_xfer assignment, which is an e_assign
  pcp_cpu_jtag_debug_module_end_xfer <= NOT ((pcp_cpu_jtag_debug_module_waits_for_read OR pcp_cpu_jtag_debug_module_waits_for_write));
  --end_xfer_arb_share_counter_term_pcp_cpu_jtag_debug_module arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_pcp_cpu_jtag_debug_module <= pcp_cpu_jtag_debug_module_end_xfer AND (((NOT pcp_cpu_jtag_debug_module_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --pcp_cpu_jtag_debug_module_arb_share_counter arbitration counter enable, which is an e_assign
  pcp_cpu_jtag_debug_module_arb_counter_enable <= ((end_xfer_arb_share_counter_term_pcp_cpu_jtag_debug_module AND pcp_cpu_jtag_debug_module_allgrants)) OR ((end_xfer_arb_share_counter_term_pcp_cpu_jtag_debug_module AND NOT pcp_cpu_jtag_debug_module_non_bursting_master_requests));
  --pcp_cpu_jtag_debug_module_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pcp_cpu_jtag_debug_module_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(pcp_cpu_jtag_debug_module_arb_counter_enable) = '1' then 
        pcp_cpu_jtag_debug_module_arb_share_counter <= pcp_cpu_jtag_debug_module_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --pcp_cpu_jtag_debug_module_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pcp_cpu_jtag_debug_module_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(pcp_cpu_jtag_debug_module_master_qreq_vector) AND end_xfer_arb_share_counter_term_pcp_cpu_jtag_debug_module)) OR ((end_xfer_arb_share_counter_term_pcp_cpu_jtag_debug_module AND NOT pcp_cpu_jtag_debug_module_non_bursting_master_requests)))) = '1' then 
        pcp_cpu_jtag_debug_module_slavearbiterlockenable <= or_reduce(pcp_cpu_jtag_debug_module_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --pcp_cpu/data_master pcp_cpu/jtag_debug_module arbiterlock, which is an e_assign
  pcp_cpu_data_master_arbiterlock <= pcp_cpu_jtag_debug_module_slavearbiterlockenable AND pcp_cpu_data_master_continuerequest;
  --pcp_cpu_jtag_debug_module_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  pcp_cpu_jtag_debug_module_slavearbiterlockenable2 <= or_reduce(pcp_cpu_jtag_debug_module_arb_share_counter_next_value);
  --pcp_cpu/data_master pcp_cpu/jtag_debug_module arbiterlock2, which is an e_assign
  pcp_cpu_data_master_arbiterlock2 <= pcp_cpu_jtag_debug_module_slavearbiterlockenable2 AND pcp_cpu_data_master_continuerequest;
  --pcp_cpu/instruction_master pcp_cpu/jtag_debug_module arbiterlock, which is an e_assign
  pcp_cpu_instruction_master_arbiterlock <= pcp_cpu_jtag_debug_module_slavearbiterlockenable AND pcp_cpu_instruction_master_continuerequest;
  --pcp_cpu/instruction_master pcp_cpu/jtag_debug_module arbiterlock2, which is an e_assign
  pcp_cpu_instruction_master_arbiterlock2 <= pcp_cpu_jtag_debug_module_slavearbiterlockenable2 AND pcp_cpu_instruction_master_continuerequest;
  --pcp_cpu/instruction_master granted pcp_cpu/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_pcp_cpu_instruction_master_granted_slave_pcp_cpu_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_pcp_cpu_instruction_master_granted_slave_pcp_cpu_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pcp_cpu_instruction_master_saved_grant_pcp_cpu_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((pcp_cpu_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_pcp_cpu_instruction_master_granted_slave_pcp_cpu_jtag_debug_module))))));
    end if;

  end process;

  --pcp_cpu_instruction_master_continuerequest continued request, which is an e_mux
  pcp_cpu_instruction_master_continuerequest <= last_cycle_pcp_cpu_instruction_master_granted_slave_pcp_cpu_jtag_debug_module AND internal_pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module;
  --pcp_cpu_jtag_debug_module_any_continuerequest at least one master continues requesting, which is an e_mux
  pcp_cpu_jtag_debug_module_any_continuerequest <= pcp_cpu_instruction_master_continuerequest OR pcp_cpu_data_master_continuerequest;
  internal_pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module <= internal_pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module AND NOT (((((NOT pcp_cpu_data_master_waitrequest) AND pcp_cpu_data_master_write)) OR pcp_cpu_instruction_master_arbiterlock));
  --pcp_cpu_jtag_debug_module_writedata mux, which is an e_mux
  pcp_cpu_jtag_debug_module_writedata <= pcp_cpu_data_master_writedata;
  internal_pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module <= ((to_std_logic(((Std_Logic_Vector'(pcp_cpu_instruction_master_address_to_slave(21 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0000000001100000000000")))) AND (pcp_cpu_instruction_master_read))) AND pcp_cpu_instruction_master_read;
  --pcp_cpu/data_master granted pcp_cpu/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_pcp_cpu_data_master_granted_slave_pcp_cpu_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_pcp_cpu_data_master_granted_slave_pcp_cpu_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pcp_cpu_data_master_saved_grant_pcp_cpu_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((pcp_cpu_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_pcp_cpu_data_master_granted_slave_pcp_cpu_jtag_debug_module))))));
    end if;

  end process;

  --pcp_cpu_data_master_continuerequest continued request, which is an e_mux
  pcp_cpu_data_master_continuerequest <= last_cycle_pcp_cpu_data_master_granted_slave_pcp_cpu_jtag_debug_module AND internal_pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module;
  internal_pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module <= internal_pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module AND NOT ((((pcp_cpu_instruction_master_read AND to_std_logic((((std_logic_vector'("000000000000000000000000000000") & (pcp_cpu_instruction_master_latency_counter)) /= std_logic_vector'("00000000000000000000000000000000")))))) OR pcp_cpu_data_master_arbiterlock));
  --local readdatavalid pcp_cpu_instruction_master_read_data_valid_pcp_cpu_jtag_debug_module, which is an e_mux
  pcp_cpu_instruction_master_read_data_valid_pcp_cpu_jtag_debug_module <= (internal_pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module AND pcp_cpu_instruction_master_read) AND NOT pcp_cpu_jtag_debug_module_waits_for_read;
  --allow new arb cycle for pcp_cpu/jtag_debug_module, which is an e_assign
  pcp_cpu_jtag_debug_module_allow_new_arb_cycle <= NOT pcp_cpu_data_master_arbiterlock AND NOT pcp_cpu_instruction_master_arbiterlock;
  --pcp_cpu/instruction_master assignment into master qualified-requests vector for pcp_cpu/jtag_debug_module, which is an e_assign
  pcp_cpu_jtag_debug_module_master_qreq_vector(0) <= internal_pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module;
  --pcp_cpu/instruction_master grant pcp_cpu/jtag_debug_module, which is an e_assign
  internal_pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module <= pcp_cpu_jtag_debug_module_grant_vector(0);
  --pcp_cpu/instruction_master saved-grant pcp_cpu/jtag_debug_module, which is an e_assign
  pcp_cpu_instruction_master_saved_grant_pcp_cpu_jtag_debug_module <= pcp_cpu_jtag_debug_module_arb_winner(0) AND internal_pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module;
  --pcp_cpu/data_master assignment into master qualified-requests vector for pcp_cpu/jtag_debug_module, which is an e_assign
  pcp_cpu_jtag_debug_module_master_qreq_vector(1) <= internal_pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module;
  --pcp_cpu/data_master grant pcp_cpu/jtag_debug_module, which is an e_assign
  internal_pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module <= pcp_cpu_jtag_debug_module_grant_vector(1);
  --pcp_cpu/data_master saved-grant pcp_cpu/jtag_debug_module, which is an e_assign
  pcp_cpu_data_master_saved_grant_pcp_cpu_jtag_debug_module <= pcp_cpu_jtag_debug_module_arb_winner(1) AND internal_pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module;
  --pcp_cpu/jtag_debug_module chosen-master double-vector, which is an e_assign
  pcp_cpu_jtag_debug_module_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((pcp_cpu_jtag_debug_module_master_qreq_vector & pcp_cpu_jtag_debug_module_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT pcp_cpu_jtag_debug_module_master_qreq_vector & NOT pcp_cpu_jtag_debug_module_master_qreq_vector))) + (std_logic_vector'("000") & (pcp_cpu_jtag_debug_module_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  pcp_cpu_jtag_debug_module_arb_winner <= A_WE_StdLogicVector((std_logic'(((pcp_cpu_jtag_debug_module_allow_new_arb_cycle AND or_reduce(pcp_cpu_jtag_debug_module_grant_vector)))) = '1'), pcp_cpu_jtag_debug_module_grant_vector, pcp_cpu_jtag_debug_module_saved_chosen_master_vector);
  --saved pcp_cpu_jtag_debug_module_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pcp_cpu_jtag_debug_module_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(pcp_cpu_jtag_debug_module_allow_new_arb_cycle) = '1' then 
        pcp_cpu_jtag_debug_module_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(pcp_cpu_jtag_debug_module_grant_vector)) = '1'), pcp_cpu_jtag_debug_module_grant_vector, pcp_cpu_jtag_debug_module_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  pcp_cpu_jtag_debug_module_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((pcp_cpu_jtag_debug_module_chosen_master_double_vector(1) OR pcp_cpu_jtag_debug_module_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((pcp_cpu_jtag_debug_module_chosen_master_double_vector(0) OR pcp_cpu_jtag_debug_module_chosen_master_double_vector(2)))));
  --pcp_cpu/jtag_debug_module chosen master rotated left, which is an e_assign
  pcp_cpu_jtag_debug_module_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(pcp_cpu_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(pcp_cpu_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --pcp_cpu/jtag_debug_module's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pcp_cpu_jtag_debug_module_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(pcp_cpu_jtag_debug_module_grant_vector)) = '1' then 
        pcp_cpu_jtag_debug_module_arb_addend <= A_WE_StdLogicVector((std_logic'(pcp_cpu_jtag_debug_module_end_xfer) = '1'), pcp_cpu_jtag_debug_module_chosen_master_rot_left, pcp_cpu_jtag_debug_module_grant_vector);
      end if;
    end if;

  end process;

  pcp_cpu_jtag_debug_module_begintransfer <= pcp_cpu_jtag_debug_module_begins_xfer;
  --pcp_cpu_jtag_debug_module_reset_n assignment, which is an e_assign
  pcp_cpu_jtag_debug_module_reset_n <= reset_n;
  --assign pcp_cpu_jtag_debug_module_resetrequest_from_sa = pcp_cpu_jtag_debug_module_resetrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  pcp_cpu_jtag_debug_module_resetrequest_from_sa <= pcp_cpu_jtag_debug_module_resetrequest;
  pcp_cpu_jtag_debug_module_chipselect <= internal_pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module OR internal_pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module;
  --pcp_cpu_jtag_debug_module_firsttransfer first transaction, which is an e_assign
  pcp_cpu_jtag_debug_module_firsttransfer <= A_WE_StdLogic((std_logic'(pcp_cpu_jtag_debug_module_begins_xfer) = '1'), pcp_cpu_jtag_debug_module_unreg_firsttransfer, pcp_cpu_jtag_debug_module_reg_firsttransfer);
  --pcp_cpu_jtag_debug_module_unreg_firsttransfer first transaction, which is an e_assign
  pcp_cpu_jtag_debug_module_unreg_firsttransfer <= NOT ((pcp_cpu_jtag_debug_module_slavearbiterlockenable AND pcp_cpu_jtag_debug_module_any_continuerequest));
  --pcp_cpu_jtag_debug_module_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pcp_cpu_jtag_debug_module_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(pcp_cpu_jtag_debug_module_begins_xfer) = '1' then 
        pcp_cpu_jtag_debug_module_reg_firsttransfer <= pcp_cpu_jtag_debug_module_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --pcp_cpu_jtag_debug_module_beginbursttransfer_internal begin burst transfer, which is an e_assign
  pcp_cpu_jtag_debug_module_beginbursttransfer_internal <= pcp_cpu_jtag_debug_module_begins_xfer;
  --pcp_cpu_jtag_debug_module_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  pcp_cpu_jtag_debug_module_arbitration_holdoff_internal <= pcp_cpu_jtag_debug_module_begins_xfer AND pcp_cpu_jtag_debug_module_firsttransfer;
  --pcp_cpu_jtag_debug_module_write assignment, which is an e_mux
  pcp_cpu_jtag_debug_module_write <= internal_pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module AND pcp_cpu_data_master_write;
  shifted_address_to_pcp_cpu_jtag_debug_module_from_pcp_cpu_data_master <= pcp_cpu_data_master_address_to_slave;
  --pcp_cpu_jtag_debug_module_address mux, which is an e_mux
  pcp_cpu_jtag_debug_module_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module)) = '1'), (A_SRL(shifted_address_to_pcp_cpu_jtag_debug_module_from_pcp_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (std_logic_vector'("000") & ((A_SRL(shifted_address_to_pcp_cpu_jtag_debug_module_from_pcp_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))))), 9);
  shifted_address_to_pcp_cpu_jtag_debug_module_from_pcp_cpu_instruction_master <= pcp_cpu_instruction_master_address_to_slave;
  --d1_pcp_cpu_jtag_debug_module_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_pcp_cpu_jtag_debug_module_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_pcp_cpu_jtag_debug_module_end_xfer <= pcp_cpu_jtag_debug_module_end_xfer;
    end if;

  end process;

  --pcp_cpu_jtag_debug_module_waits_for_read in a cycle, which is an e_mux
  pcp_cpu_jtag_debug_module_waits_for_read <= pcp_cpu_jtag_debug_module_in_a_read_cycle AND pcp_cpu_jtag_debug_module_begins_xfer;
  --pcp_cpu_jtag_debug_module_in_a_read_cycle assignment, which is an e_assign
  pcp_cpu_jtag_debug_module_in_a_read_cycle <= ((internal_pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module AND pcp_cpu_data_master_read)) OR ((internal_pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module AND pcp_cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= pcp_cpu_jtag_debug_module_in_a_read_cycle;
  --pcp_cpu_jtag_debug_module_waits_for_write in a cycle, which is an e_mux
  pcp_cpu_jtag_debug_module_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_jtag_debug_module_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --pcp_cpu_jtag_debug_module_in_a_write_cycle assignment, which is an e_assign
  pcp_cpu_jtag_debug_module_in_a_write_cycle <= internal_pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module AND pcp_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= pcp_cpu_jtag_debug_module_in_a_write_cycle;
  wait_for_pcp_cpu_jtag_debug_module_counter <= std_logic'('0');
  --pcp_cpu_jtag_debug_module_byteenable byte enable port mux, which is an e_mux
  pcp_cpu_jtag_debug_module_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (pcp_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --debugaccess mux, which is an e_mux
  pcp_cpu_jtag_debug_module_debugaccess <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_debugaccess))), std_logic_vector'("00000000000000000000000000000000")));
  --vhdl renameroo for output signals
  pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module <= internal_pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module <= internal_pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module <= internal_pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module <= internal_pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module <= internal_pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module <= internal_pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module;
--synthesis translate_off
    --pcp_cpu/jtag_debug_module enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line24 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line24, now);
          write(write_line24, string'(": "));
          write(write_line24, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line24.all);
          deallocate (write_line24);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line25 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_saved_grant_pcp_cpu_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(pcp_cpu_instruction_master_saved_grant_pcp_cpu_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line25, now);
          write(write_line25, string'(": "));
          write(write_line25, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line25.all);
          deallocate (write_line25);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity jtag_uart_0_avalon_jtag_slave_irq_from_sa_clock_crossing_pcp_cpu_data_master_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity jtag_uart_0_avalon_jtag_slave_irq_from_sa_clock_crossing_pcp_cpu_data_master_module;


architecture europa of jtag_uart_0_avalon_jtag_slave_irq_from_sa_clock_crossing_pcp_cpu_data_master_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_in_d1 <= data_in;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_out <= data_in_d1;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity powerlink_0_MAC_CMP_irq_from_sa_clock_crossing_pcp_cpu_data_master_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity powerlink_0_MAC_CMP_irq_from_sa_clock_crossing_pcp_cpu_data_master_module;


architecture europa of powerlink_0_MAC_CMP_irq_from_sa_clock_crossing_pcp_cpu_data_master_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_in_d1 <= data_in;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_out <= data_in_d1;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity powerlink_0_MAC_REG_irq_from_sa_clock_crossing_pcp_cpu_data_master_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity powerlink_0_MAC_REG_irq_from_sa_clock_crossing_pcp_cpu_data_master_module;


architecture europa of powerlink_0_MAC_REG_irq_from_sa_clock_crossing_pcp_cpu_data_master_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_in_d1 <= data_in;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_out <= data_in_d1;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity system_timer_s1_irq_from_sa_clock_crossing_pcp_cpu_data_master_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity system_timer_s1_irq_from_sa_clock_crossing_pcp_cpu_data_master_module;


architecture europa of system_timer_s1_irq_from_sa_clock_crossing_pcp_cpu_data_master_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_in_d1 <= data_in;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_out <= data_in_d1;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pcp_cpu_data_master_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clock_crossing_0_s1_waitrequest_from_sa : IN STD_LOGIC;
                 signal d1_clock_crossing_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : IN STD_LOGIC;
                 signal d1_niosII_openMac_clock_0_in_end_xfer : IN STD_LOGIC;
                 signal d1_niosII_openMac_clock_1_in_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_memory_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_pcp_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_powerlink_0_MAC_BUF_end_xfer : IN STD_LOGIC;
                 signal d1_powerlink_0_PDI_PCP_end_xfer : IN STD_LOGIC;
                 signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                 signal d1_tri_state_bridge_0_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_irq_from_sa : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal incoming_tri_state_bridge_0_data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal jtag_uart_0_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal onchip_memory_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_clk : IN STD_LOGIC;
                 signal pcp_clk_reset_n : IN STD_LOGIC;
                 signal pcp_cpu_data_master_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal pcp_cpu_data_master_granted_clock_crossing_0_s1 : IN STD_LOGIC;
                 signal pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal pcp_cpu_data_master_granted_niosII_openMac_clock_0_in : IN STD_LOGIC;
                 signal pcp_cpu_data_master_granted_niosII_openMac_clock_1_in : IN STD_LOGIC;
                 signal pcp_cpu_data_master_granted_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal pcp_cpu_data_master_granted_powerlink_0_MAC_BUF : IN STD_LOGIC;
                 signal pcp_cpu_data_master_granted_powerlink_0_PDI_PCP : IN STD_LOGIC;
                 signal pcp_cpu_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_clock_crossing_0_s1 : IN STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in : IN STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in : IN STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF : IN STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP : IN STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1 : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_0_in : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_powerlink_0_MAC_BUF : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_powerlink_0_PDI_PCP : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                 signal pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal pcp_cpu_data_master_requests_clock_crossing_0_s1 : IN STD_LOGIC;
                 signal pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal pcp_cpu_data_master_requests_niosII_openMac_clock_0_in : IN STD_LOGIC;
                 signal pcp_cpu_data_master_requests_niosII_openMac_clock_1_in : IN STD_LOGIC;
                 signal pcp_cpu_data_master_requests_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal pcp_cpu_data_master_requests_powerlink_0_MAC_BUF : IN STD_LOGIC;
                 signal pcp_cpu_data_master_requests_powerlink_0_PDI_PCP : IN STD_LOGIC;
                 signal pcp_cpu_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                 signal pcp_cpu_data_master_write : IN STD_LOGIC;
                 signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal powerlink_0_MAC_BUF_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal powerlink_0_MAC_BUF_wait_counter_eq_0 : IN STD_LOGIC;
                 signal powerlink_0_MAC_CMP_irq_from_sa : IN STD_LOGIC;
                 signal powerlink_0_MAC_REG_irq_from_sa : IN STD_LOGIC;
                 signal powerlink_0_PDI_PCP_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal powerlink_0_PDI_PCP_wait_counter_eq_0 : IN STD_LOGIC;
                 signal registered_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal registered_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal system_timer_s1_irq_from_sa : IN STD_LOGIC;

              -- outputs:
                 signal pcp_cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal pcp_cpu_data_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pcp_cpu_data_master_dbs_write_16 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal pcp_cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_data_master_no_byte_enables_and_last_term : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_data_master_waitrequest : OUT STD_LOGIC
              );
end entity pcp_cpu_data_master_arbitrator;


architecture europa of pcp_cpu_data_master_arbitrator is
component jtag_uart_0_avalon_jtag_slave_irq_from_sa_clock_crossing_pcp_cpu_data_master_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component jtag_uart_0_avalon_jtag_slave_irq_from_sa_clock_crossing_pcp_cpu_data_master_module;

component powerlink_0_MAC_CMP_irq_from_sa_clock_crossing_pcp_cpu_data_master_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component powerlink_0_MAC_CMP_irq_from_sa_clock_crossing_pcp_cpu_data_master_module;

component powerlink_0_MAC_REG_irq_from_sa_clock_crossing_pcp_cpu_data_master_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component powerlink_0_MAC_REG_irq_from_sa_clock_crossing_pcp_cpu_data_master_module;

component system_timer_s1_irq_from_sa_clock_crossing_pcp_cpu_data_master_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component system_timer_s1_irq_from_sa_clock_crossing_pcp_cpu_data_master_module;

                signal dbs_16_reg_segment_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal dbs_count_enable :  STD_LOGIC;
                signal dbs_counter_overflow :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal internal_pcp_cpu_data_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_pcp_cpu_data_master_no_byte_enables_and_last_term :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_waitrequest :  STD_LOGIC;
                signal last_dbs_term_and_run :  STD_LOGIC;
                signal next_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_dbs_16_reg_segment_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal p1_registered_pcp_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pcp_clk_jtag_uart_0_avalon_jtag_slave_irq_from_sa :  STD_LOGIC;
                signal pcp_clk_powerlink_0_MAC_CMP_irq_from_sa :  STD_LOGIC;
                signal pcp_clk_powerlink_0_MAC_REG_irq_from_sa :  STD_LOGIC;
                signal pcp_clk_system_timer_s1_irq_from_sa :  STD_LOGIC;
                signal pcp_cpu_data_master_dbs_increment :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_data_master_run :  STD_LOGIC;
                signal pre_dbs_count_enable :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal r_2 :  STD_LOGIC;
                signal registered_pcp_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((pcp_cpu_data_master_qualified_request_clock_crossing_0_s1 OR pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1) OR NOT pcp_cpu_data_master_requests_clock_crossing_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT pcp_cpu_data_master_qualified_request_clock_crossing_0_s1 OR NOT pcp_cpu_data_master_read) OR ((pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1 AND pcp_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_clock_crossing_0_s1 OR NOT ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT clock_crossing_0_s1_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port OR NOT pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in OR NOT pcp_cpu_data_master_requests_niosII_openMac_clock_0_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in OR NOT ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_0_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in OR NOT ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_0_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in OR NOT pcp_cpu_data_master_requests_niosII_openMac_clock_1_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in OR NOT ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_1_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in OR NOT ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_1_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 OR registered_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1) OR NOT pcp_cpu_data_master_requests_onchip_memory_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_granted_onchip_memory_0_s1 OR NOT pcp_cpu_data_master_qualified_request_onchip_memory_0_s1)))))));
  --cascaded wait assignment, which is an e_assign
  pcp_cpu_data_master_run <= (r_0 AND r_1) AND r_2;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((((((((((((((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 OR NOT pcp_cpu_data_master_read) OR ((registered_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 AND pcp_cpu_data_master_read))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 OR NOT ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module OR NOT pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module OR NOT pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module OR NOT pcp_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module OR NOT pcp_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF OR NOT pcp_cpu_data_master_requests_powerlink_0_MAC_BUF)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF OR NOT pcp_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_powerlink_0_MAC_BUF_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF OR NOT pcp_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP OR NOT pcp_cpu_data_master_requests_powerlink_0_PDI_PCP)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP OR NOT pcp_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_powerlink_0_PDI_PCP_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP OR NOT pcp_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_sysid_control_slave OR NOT pcp_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_sysid_control_slave OR NOT pcp_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((((pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave OR ((registered_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave AND internal_pcp_cpu_data_master_dbs_address(1)))) OR (((pcp_cpu_data_master_write AND NOT(or_reduce(pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave))) AND internal_pcp_cpu_data_master_dbs_address(1)))) OR NOT pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave)))))));
  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave OR NOT pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave)) AND (((NOT pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave OR NOT pcp_cpu_data_master_read) OR (((registered_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave AND (internal_pcp_cpu_data_master_dbs_address(1))) AND pcp_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave OR NOT pcp_cpu_data_master_write)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((internal_pcp_cpu_data_master_dbs_address(1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_write)))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_pcp_cpu_data_master_address_to_slave <= Std_Logic_Vector'(A_ToStdLogicVector(pcp_cpu_data_master_address(24)) & std_logic_vector'("00") & A_ToStdLogicVector(pcp_cpu_data_master_address(21)) & A_ToStdLogicVector(std_logic'('0')) & pcp_cpu_data_master_address(19 DOWNTO 0));
  --unpredictable registered wait state incoming data, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      registered_pcp_cpu_data_master_readdata <= std_logic_vector'("00000000000000000000000000000000");
    elsif clk'event and clk = '1' then
      registered_pcp_cpu_data_master_readdata <= p1_registered_pcp_cpu_data_master_readdata;
    end if;

  end process;

  --registered readdata mux, which is an e_mux
  p1_registered_pcp_cpu_data_master_readdata <= (((A_REP(NOT pcp_cpu_data_master_requests_clock_crossing_0_s1, 32) OR clock_crossing_0_s1_readdata_from_sa)) AND ((A_REP(NOT pcp_cpu_data_master_requests_niosII_openMac_clock_0_in, 32) OR niosII_openMac_clock_0_in_readdata_from_sa))) AND ((A_REP(NOT pcp_cpu_data_master_requests_niosII_openMac_clock_1_in, 32) OR niosII_openMac_clock_1_in_readdata_from_sa));
  --pcp_cpu/data_master readdata mux, which is an e_mux
  pcp_cpu_data_master_readdata <= ((((((((((A_REP(NOT pcp_cpu_data_master_requests_clock_crossing_0_s1, 32) OR registered_pcp_cpu_data_master_readdata)) AND ((A_REP(NOT pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port, 32) OR epcs_flash_controller_0_epcs_control_port_readdata_from_sa))) AND ((A_REP(NOT pcp_cpu_data_master_requests_niosII_openMac_clock_0_in, 32) OR registered_pcp_cpu_data_master_readdata))) AND ((A_REP(NOT pcp_cpu_data_master_requests_niosII_openMac_clock_1_in, 32) OR registered_pcp_cpu_data_master_readdata))) AND ((A_REP(NOT pcp_cpu_data_master_requests_onchip_memory_0_s1, 32) OR onchip_memory_0_s1_readdata_from_sa))) AND ((A_REP(NOT pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module, 32) OR pcp_cpu_jtag_debug_module_readdata_from_sa))) AND ((A_REP(NOT pcp_cpu_data_master_requests_powerlink_0_MAC_BUF, 32) OR powerlink_0_MAC_BUF_readdata_from_sa))) AND ((A_REP(NOT pcp_cpu_data_master_requests_powerlink_0_PDI_PCP, 32) OR powerlink_0_PDI_PCP_readdata_from_sa))) AND ((A_REP(NOT pcp_cpu_data_master_requests_sysid_control_slave, 32) OR sysid_control_slave_readdata_from_sa))) AND ((A_REP(NOT pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave, 32) OR Std_Logic_Vector'(incoming_tri_state_bridge_0_data(15 DOWNTO 0) & dbs_16_reg_segment_0)));
  --actual waitrequest port, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_pcp_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      internal_pcp_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT (A_WE_StdLogicVector((std_logic'((NOT ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_data_master_run AND internal_pcp_cpu_data_master_waitrequest))))))));
    end if;

  end process;

  --irq assign, which is an e_assign
  pcp_cpu_data_master_irq <= Std_Logic_Vector'(A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(epcs_flash_controller_0_epcs_control_port_irq_from_sa) & A_ToStdLogicVector(pcp_clk_jtag_uart_0_avalon_jtag_slave_irq_from_sa) & A_ToStdLogicVector(pcp_clk_system_timer_s1_irq_from_sa) & A_ToStdLogicVector(pcp_clk_powerlink_0_MAC_REG_irq_from_sa) & A_ToStdLogicVector(pcp_clk_powerlink_0_MAC_CMP_irq_from_sa));
  --jtag_uart_0_avalon_jtag_slave_irq_from_sa from clk50Meg to pcp_clk
  jtag_uart_0_avalon_jtag_slave_irq_from_sa_clock_crossing_pcp_cpu_data_master : jtag_uart_0_avalon_jtag_slave_irq_from_sa_clock_crossing_pcp_cpu_data_master_module
    port map(
      data_out => pcp_clk_jtag_uart_0_avalon_jtag_slave_irq_from_sa,
      clk => pcp_clk,
      data_in => jtag_uart_0_avalon_jtag_slave_irq_from_sa,
      reset_n => pcp_clk_reset_n
    );


  --powerlink_0_MAC_CMP_irq_from_sa from clk50Meg to pcp_clk
  powerlink_0_MAC_CMP_irq_from_sa_clock_crossing_pcp_cpu_data_master : powerlink_0_MAC_CMP_irq_from_sa_clock_crossing_pcp_cpu_data_master_module
    port map(
      data_out => pcp_clk_powerlink_0_MAC_CMP_irq_from_sa,
      clk => pcp_clk,
      data_in => powerlink_0_MAC_CMP_irq_from_sa,
      reset_n => pcp_clk_reset_n
    );


  --powerlink_0_MAC_REG_irq_from_sa from clk50Meg to pcp_clk
  powerlink_0_MAC_REG_irq_from_sa_clock_crossing_pcp_cpu_data_master : powerlink_0_MAC_REG_irq_from_sa_clock_crossing_pcp_cpu_data_master_module
    port map(
      data_out => pcp_clk_powerlink_0_MAC_REG_irq_from_sa,
      clk => pcp_clk,
      data_in => powerlink_0_MAC_REG_irq_from_sa,
      reset_n => pcp_clk_reset_n
    );


  --system_timer_s1_irq_from_sa from clk50Meg to pcp_clk
  system_timer_s1_irq_from_sa_clock_crossing_pcp_cpu_data_master : system_timer_s1_irq_from_sa_clock_crossing_pcp_cpu_data_master_module
    port map(
      data_out => pcp_clk_system_timer_s1_irq_from_sa,
      clk => pcp_clk,
      data_in => system_timer_s1_irq_from_sa,
      reset_n => pcp_clk_reset_n
    );


  --no_byte_enables_and_last_term, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_pcp_cpu_data_master_no_byte_enables_and_last_term <= std_logic'('0');
    elsif clk'event and clk = '1' then
      internal_pcp_cpu_data_master_no_byte_enables_and_last_term <= last_dbs_term_and_run;
    end if;

  end process;

  --compute the last dbs term, which is an e_mux
  last_dbs_term_and_run <= (to_std_logic(((internal_pcp_cpu_data_master_dbs_address = std_logic_vector'("10")))) AND pcp_cpu_data_master_write) AND NOT(or_reduce(pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave));
  --pre dbs count enable, which is an e_mux
  pre_dbs_count_enable <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((((((NOT internal_pcp_cpu_data_master_no_byte_enables_and_last_term) AND pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave) AND pcp_cpu_data_master_write) AND NOT(or_reduce(pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave)))) OR pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave)))) OR ((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave AND pcp_cpu_data_master_write)))) AND std_logic_vector'("00000000000000000000000000000001")) AND std_logic_vector'("00000000000000000000000000000001")))));
  --input to dbs-16 stored 0, which is an e_mux
  p1_dbs_16_reg_segment_0 <= incoming_tri_state_bridge_0_data;
  --dbs register for dbs-16 segment 0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      dbs_16_reg_segment_0 <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      if std_logic'((dbs_count_enable AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((internal_pcp_cpu_data_master_dbs_address(1))))) = std_logic_vector'("00000000000000000000000000000000")))))) = '1' then 
        dbs_16_reg_segment_0 <= p1_dbs_16_reg_segment_0;
      end if;
    end if;

  end process;

  --mux write dbs 1, which is an e_mux
  pcp_cpu_data_master_dbs_write_16 <= A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_dbs_address(1))) = '1'), pcp_cpu_data_master_writedata(31 DOWNTO 16), pcp_cpu_data_master_writedata(15 DOWNTO 0));
  --dbs count increment, which is an e_mux
  pcp_cpu_data_master_dbs_increment <= A_EXT (A_WE_StdLogicVector((std_logic'((pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave)) = '1'), std_logic_vector'("00000000000000000000000000000010"), std_logic_vector'("00000000000000000000000000000000")), 2);
  --dbs counter overflow, which is an e_assign
  dbs_counter_overflow <= internal_pcp_cpu_data_master_dbs_address(1) AND NOT((next_dbs_address(1)));
  --next master address, which is an e_assign
  next_dbs_address <= A_EXT (((std_logic_vector'("0") & (internal_pcp_cpu_data_master_dbs_address)) + (std_logic_vector'("0") & (pcp_cpu_data_master_dbs_increment))), 2);
  --dbs count enable, which is an e_mux
  dbs_count_enable <= pre_dbs_count_enable AND (NOT (((pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave AND NOT internal_pcp_cpu_data_master_waitrequest) AND pcp_cpu_data_master_write)));
  --dbs counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_pcp_cpu_data_master_dbs_address <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(dbs_count_enable) = '1' then 
        internal_pcp_cpu_data_master_dbs_address <= next_dbs_address;
      end if;
    end if;

  end process;

  --vhdl renameroo for output signals
  pcp_cpu_data_master_address_to_slave <= internal_pcp_cpu_data_master_address_to_slave;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_dbs_address <= internal_pcp_cpu_data_master_dbs_address;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_no_byte_enables_and_last_term <= internal_pcp_cpu_data_master_no_byte_enables_and_last_term;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_waitrequest <= internal_pcp_cpu_data_master_waitrequest;

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity pcp_cpu_instruction_master_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_memory_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_pcp_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_tri_state_bridge_0_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal incoming_tri_state_bridge_0_data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal onchip_memory_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_instruction_master_address : IN STD_LOGIC_VECTOR (21 DOWNTO 0);
                 signal pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_granted_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_read : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_read_data_valid_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_requests_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal pcp_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal pcp_cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (21 DOWNTO 0);
                 signal pcp_cpu_instruction_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pcp_cpu_instruction_master_latency_counter : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pcp_cpu_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal pcp_cpu_instruction_master_readdatavalid : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_waitrequest : OUT STD_LOGIC
              );
end entity pcp_cpu_instruction_master_arbitrator;


architecture europa of pcp_cpu_instruction_master_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal dbs_count_enable :  STD_LOGIC;
                signal dbs_counter_overflow :  STD_LOGIC;
                signal dbs_latent_16_reg_segment_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal dbs_rdv_count_enable :  STD_LOGIC;
                signal dbs_rdv_counter_overflow :  STD_LOGIC;
                signal internal_pcp_cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (21 DOWNTO 0);
                signal internal_pcp_cpu_instruction_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_pcp_cpu_instruction_master_latency_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_pcp_cpu_instruction_master_waitrequest :  STD_LOGIC;
                signal latency_load_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal next_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_dbs_latent_16_reg_segment_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal p1_pcp_cpu_instruction_master_latency_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_instruction_master_address_last_time :  STD_LOGIC_VECTOR (21 DOWNTO 0);
                signal pcp_cpu_instruction_master_dbs_increment :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_instruction_master_dbs_rdv_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_instruction_master_dbs_rdv_counter_inc :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_instruction_master_is_granted_some_slave :  STD_LOGIC;
                signal pcp_cpu_instruction_master_next_dbs_rdv_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_instruction_master_read_but_no_slave_selected :  STD_LOGIC;
                signal pcp_cpu_instruction_master_read_last_time :  STD_LOGIC;
                signal pcp_cpu_instruction_master_run :  STD_LOGIC;
                signal pre_dbs_count_enable :  STD_LOGIC;
                signal pre_flush_pcp_cpu_instruction_master_readdatavalid :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal r_2 :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port OR NOT pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT (pcp_cpu_instruction_master_read))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_epcs_flash_controller_0_epcs_control_port_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((pcp_cpu_instruction_master_read))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1 OR NOT pcp_cpu_instruction_master_requests_onchip_memory_0_s1)))))));
  --cascaded wait assignment, which is an e_assign
  pcp_cpu_instruction_master_run <= (r_0 AND r_1) AND r_2;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_instruction_master_granted_onchip_memory_0_s1 OR NOT pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1 OR NOT pcp_cpu_instruction_master_read)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_instruction_master_read)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module OR NOT pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module OR NOT pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module OR NOT pcp_cpu_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_pcp_cpu_jtag_debug_module_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_instruction_master_read)))))))));
  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave OR NOT pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave OR NOT pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave OR NOT pcp_cpu_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((internal_pcp_cpu_instruction_master_dbs_address(1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_instruction_master_read)))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_pcp_cpu_instruction_master_address_to_slave <= Std_Logic_Vector'(A_ToStdLogicVector(pcp_cpu_instruction_master_address(21)) & A_ToStdLogicVector(std_logic'('0')) & pcp_cpu_instruction_master_address(19 DOWNTO 0));
  --pcp_cpu_instruction_master_read_but_no_slave_selected assignment, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pcp_cpu_instruction_master_read_but_no_slave_selected <= std_logic'('0');
    elsif clk'event and clk = '1' then
      pcp_cpu_instruction_master_read_but_no_slave_selected <= (pcp_cpu_instruction_master_read AND pcp_cpu_instruction_master_run) AND NOT pcp_cpu_instruction_master_is_granted_some_slave;
    end if;

  end process;

  --some slave is getting selected, which is an e_mux
  pcp_cpu_instruction_master_is_granted_some_slave <= ((pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port OR pcp_cpu_instruction_master_granted_onchip_memory_0_s1) OR pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module) OR pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave;
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_pcp_cpu_instruction_master_readdatavalid <= pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 OR ((pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave AND dbs_rdv_counter_overflow));
  --latent slave read data valid which is not flushed, which is an e_mux
  pcp_cpu_instruction_master_readdatavalid <= ((((((((pcp_cpu_instruction_master_read_but_no_slave_selected OR pre_flush_pcp_cpu_instruction_master_readdatavalid) OR pcp_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port) OR pcp_cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_pcp_cpu_instruction_master_readdatavalid) OR pcp_cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_pcp_cpu_instruction_master_readdatavalid) OR pcp_cpu_instruction_master_read_data_valid_pcp_cpu_jtag_debug_module) OR pcp_cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_pcp_cpu_instruction_master_readdatavalid;
  --pcp_cpu/instruction_master readdata mux, which is an e_mux
  pcp_cpu_instruction_master_readdata <= ((((A_REP(NOT ((pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port AND pcp_cpu_instruction_master_read)) , 32) OR epcs_flash_controller_0_epcs_control_port_readdata_from_sa)) AND ((A_REP(NOT pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1, 32) OR onchip_memory_0_s1_readdata_from_sa))) AND ((A_REP(NOT ((pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module AND pcp_cpu_instruction_master_read)) , 32) OR pcp_cpu_jtag_debug_module_readdata_from_sa))) AND ((A_REP(NOT pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave, 32) OR Std_Logic_Vector'(incoming_tri_state_bridge_0_data(15 DOWNTO 0) & dbs_latent_16_reg_segment_0)));
  --actual waitrequest port, which is an e_assign
  internal_pcp_cpu_instruction_master_waitrequest <= NOT pcp_cpu_instruction_master_run;
  --latent max counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_pcp_cpu_instruction_master_latency_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      internal_pcp_cpu_instruction_master_latency_counter <= p1_pcp_cpu_instruction_master_latency_counter;
    end if;

  end process;

  --latency counter load mux, which is an e_mux
  p1_pcp_cpu_instruction_master_latency_counter <= A_EXT (A_WE_StdLogicVector((std_logic'(((pcp_cpu_instruction_master_run AND pcp_cpu_instruction_master_read))) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (latency_load_value)), A_WE_StdLogicVector((((internal_pcp_cpu_instruction_master_latency_counter)) /= std_logic_vector'("00")), ((std_logic_vector'("0000000000000000000000000000000") & (internal_pcp_cpu_instruction_master_latency_counter)) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --read latency load values, which is an e_mux
  latency_load_value <= A_EXT (((((std_logic_vector'("000000000000000000000000000000") & (A_REP(pcp_cpu_instruction_master_requests_onchip_memory_0_s1, 2))) AND std_logic_vector'("00000000000000000000000000000001"))) OR (((std_logic_vector'("000000000000000000000000000000") & (A_REP(pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave, 2))) AND std_logic_vector'("00000000000000000000000000000010")))), 2);
  --input to latent dbs-16 stored 0, which is an e_mux
  p1_dbs_latent_16_reg_segment_0 <= incoming_tri_state_bridge_0_data;
  --dbs register for latent dbs-16 segment 0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      dbs_latent_16_reg_segment_0 <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      if std_logic'((dbs_rdv_count_enable AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((pcp_cpu_instruction_master_dbs_rdv_counter(1))))) = std_logic_vector'("00000000000000000000000000000000")))))) = '1' then 
        dbs_latent_16_reg_segment_0 <= p1_dbs_latent_16_reg_segment_0;
      end if;
    end if;

  end process;

  --dbs count increment, which is an e_mux
  pcp_cpu_instruction_master_dbs_increment <= A_EXT (A_WE_StdLogicVector((std_logic'((pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave)) = '1'), std_logic_vector'("00000000000000000000000000000010"), std_logic_vector'("00000000000000000000000000000000")), 2);
  --dbs counter overflow, which is an e_assign
  dbs_counter_overflow <= internal_pcp_cpu_instruction_master_dbs_address(1) AND NOT((next_dbs_address(1)));
  --next master address, which is an e_assign
  next_dbs_address <= A_EXT (((std_logic_vector'("0") & (internal_pcp_cpu_instruction_master_dbs_address)) + (std_logic_vector'("0") & (pcp_cpu_instruction_master_dbs_increment))), 2);
  --dbs count enable, which is an e_mux
  dbs_count_enable <= pre_dbs_count_enable;
  --dbs counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_pcp_cpu_instruction_master_dbs_address <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(dbs_count_enable) = '1' then 
        internal_pcp_cpu_instruction_master_dbs_address <= next_dbs_address;
      end if;
    end if;

  end process;

  --p1 dbs rdv counter, which is an e_assign
  pcp_cpu_instruction_master_next_dbs_rdv_counter <= A_EXT (((std_logic_vector'("0") & (pcp_cpu_instruction_master_dbs_rdv_counter)) + (std_logic_vector'("0") & (pcp_cpu_instruction_master_dbs_rdv_counter_inc))), 2);
  --pcp_cpu_instruction_master_rdv_inc_mux, which is an e_mux
  pcp_cpu_instruction_master_dbs_rdv_counter_inc <= std_logic_vector'("10");
  --master any slave rdv, which is an e_mux
  dbs_rdv_count_enable <= pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave;
  --dbs rdv counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pcp_cpu_instruction_master_dbs_rdv_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(dbs_rdv_count_enable) = '1' then 
        pcp_cpu_instruction_master_dbs_rdv_counter <= pcp_cpu_instruction_master_next_dbs_rdv_counter;
      end if;
    end if;

  end process;

  --dbs rdv counter overflow, which is an e_assign
  dbs_rdv_counter_overflow <= pcp_cpu_instruction_master_dbs_rdv_counter(1) AND NOT pcp_cpu_instruction_master_next_dbs_rdv_counter(1);
  --pre dbs count enable, which is an e_mux
  pre_dbs_count_enable <= Vector_To_Std_Logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave AND pcp_cpu_instruction_master_read)))) AND std_logic_vector'("00000000000000000000000000000001")) AND std_logic_vector'("00000000000000000000000000000001")));
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_address_to_slave <= internal_pcp_cpu_instruction_master_address_to_slave;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_dbs_address <= internal_pcp_cpu_instruction_master_dbs_address;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_latency_counter <= internal_pcp_cpu_instruction_master_latency_counter;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_waitrequest <= internal_pcp_cpu_instruction_master_waitrequest;
--synthesis translate_off
    --pcp_cpu_instruction_master_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        pcp_cpu_instruction_master_address_last_time <= std_logic_vector'("0000000000000000000000");
      elsif clk'event and clk = '1' then
        pcp_cpu_instruction_master_address_last_time <= pcp_cpu_instruction_master_address;
      end if;

    end process;

    --pcp_cpu/instruction_master waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_pcp_cpu_instruction_master_waitrequest AND (pcp_cpu_instruction_master_read);
      end if;

    end process;

    --pcp_cpu_instruction_master_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line26 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((pcp_cpu_instruction_master_address /= pcp_cpu_instruction_master_address_last_time))))) = '1' then 
          write(write_line26, now);
          write(write_line26, string'(": "));
          write(write_line26, string'("pcp_cpu_instruction_master_address did not heed wait!!!"));
          write(output, write_line26.all);
          deallocate (write_line26);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --pcp_cpu_instruction_master_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        pcp_cpu_instruction_master_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        pcp_cpu_instruction_master_read_last_time <= pcp_cpu_instruction_master_read;
      end if;

    end process;

    --pcp_cpu_instruction_master_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line27 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(pcp_cpu_instruction_master_read) /= std_logic'(pcp_cpu_instruction_master_read_last_time)))))) = '1' then 
          write(write_line27, now);
          write(write_line27, string'(": "));
          write(write_line27, string'("pcp_cpu_instruction_master_read did not heed wait!!!"));
          write(output, write_line27.all);
          deallocate (write_line27);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity powerlink_0_MAC_BUF_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal pcp_cpu_data_master_read : IN STD_LOGIC;
                 signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal pcp_cpu_data_master_write : IN STD_LOGIC;
                 signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal powerlink_0_MAC_BUF_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_powerlink_0_MAC_BUF_end_xfer : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_granted_powerlink_0_MAC_BUF : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_powerlink_0_MAC_BUF : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_requests_powerlink_0_MAC_BUF : OUT STD_LOGIC;
                 signal powerlink_0_MAC_BUF_address : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                 signal powerlink_0_MAC_BUF_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal powerlink_0_MAC_BUF_chipselect : OUT STD_LOGIC;
                 signal powerlink_0_MAC_BUF_read_n : OUT STD_LOGIC;
                 signal powerlink_0_MAC_BUF_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal powerlink_0_MAC_BUF_reset : OUT STD_LOGIC;
                 signal powerlink_0_MAC_BUF_wait_counter_eq_0 : OUT STD_LOGIC;
                 signal powerlink_0_MAC_BUF_write_n : OUT STD_LOGIC;
                 signal powerlink_0_MAC_BUF_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity powerlink_0_MAC_BUF_arbitrator;


architecture europa of powerlink_0_MAC_BUF_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_powerlink_0_MAC_BUF :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_granted_powerlink_0_MAC_BUF :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_requests_powerlink_0_MAC_BUF :  STD_LOGIC;
                signal internal_powerlink_0_MAC_BUF_wait_counter_eq_0 :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_data_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_data_master_saved_grant_powerlink_0_MAC_BUF :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_allgrants :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_allow_new_arb_cycle :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_any_bursting_master_saved_grant :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_any_continuerequest :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_arb_counter_enable :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_MAC_BUF_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_MAC_BUF_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_MAC_BUF_beginbursttransfer_internal :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_begins_xfer :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_counter_load_value :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_end_xfer :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_firsttransfer :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_grant_vector :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_in_a_read_cycle :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_in_a_write_cycle :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_master_qreq_vector :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_non_bursting_master_requests :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_reg_firsttransfer :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_slavearbiterlockenable :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_slavearbiterlockenable2 :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_unreg_firsttransfer :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_wait_counter :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_waits_for_read :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_powerlink_0_MAC_BUF_from_pcp_cpu_data_master :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal wait_for_powerlink_0_MAC_BUF_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT powerlink_0_MAC_BUF_end_xfer;
    end if;

  end process;

  powerlink_0_MAC_BUF_begins_xfer <= NOT d1_reasons_to_wait AND (internal_pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF);
  --assign powerlink_0_MAC_BUF_readdata_from_sa = powerlink_0_MAC_BUF_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  powerlink_0_MAC_BUF_readdata_from_sa <= powerlink_0_MAC_BUF_readdata;
  internal_pcp_cpu_data_master_requests_powerlink_0_MAC_BUF <= to_std_logic(((Std_Logic_Vector'(pcp_cpu_data_master_address_to_slave(24 DOWNTO 14) & std_logic_vector'("00000000000000")) = std_logic_vector'("0000000000100000000000000")))) AND ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write));
  --powerlink_0_MAC_BUF_arb_share_counter set values, which is an e_mux
  powerlink_0_MAC_BUF_arb_share_set_values <= std_logic_vector'("01");
  --powerlink_0_MAC_BUF_non_bursting_master_requests mux, which is an e_mux
  powerlink_0_MAC_BUF_non_bursting_master_requests <= internal_pcp_cpu_data_master_requests_powerlink_0_MAC_BUF;
  --powerlink_0_MAC_BUF_any_bursting_master_saved_grant mux, which is an e_mux
  powerlink_0_MAC_BUF_any_bursting_master_saved_grant <= std_logic'('0');
  --powerlink_0_MAC_BUF_arb_share_counter_next_value assignment, which is an e_assign
  powerlink_0_MAC_BUF_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(powerlink_0_MAC_BUF_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (powerlink_0_MAC_BUF_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(powerlink_0_MAC_BUF_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (powerlink_0_MAC_BUF_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --powerlink_0_MAC_BUF_allgrants all slave grants, which is an e_mux
  powerlink_0_MAC_BUF_allgrants <= powerlink_0_MAC_BUF_grant_vector;
  --powerlink_0_MAC_BUF_end_xfer assignment, which is an e_assign
  powerlink_0_MAC_BUF_end_xfer <= NOT ((powerlink_0_MAC_BUF_waits_for_read OR powerlink_0_MAC_BUF_waits_for_write));
  --end_xfer_arb_share_counter_term_powerlink_0_MAC_BUF arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_powerlink_0_MAC_BUF <= powerlink_0_MAC_BUF_end_xfer AND (((NOT powerlink_0_MAC_BUF_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --powerlink_0_MAC_BUF_arb_share_counter arbitration counter enable, which is an e_assign
  powerlink_0_MAC_BUF_arb_counter_enable <= ((end_xfer_arb_share_counter_term_powerlink_0_MAC_BUF AND powerlink_0_MAC_BUF_allgrants)) OR ((end_xfer_arb_share_counter_term_powerlink_0_MAC_BUF AND NOT powerlink_0_MAC_BUF_non_bursting_master_requests));
  --powerlink_0_MAC_BUF_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_MAC_BUF_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(powerlink_0_MAC_BUF_arb_counter_enable) = '1' then 
        powerlink_0_MAC_BUF_arb_share_counter <= powerlink_0_MAC_BUF_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --powerlink_0_MAC_BUF_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_MAC_BUF_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((powerlink_0_MAC_BUF_master_qreq_vector AND end_xfer_arb_share_counter_term_powerlink_0_MAC_BUF)) OR ((end_xfer_arb_share_counter_term_powerlink_0_MAC_BUF AND NOT powerlink_0_MAC_BUF_non_bursting_master_requests)))) = '1' then 
        powerlink_0_MAC_BUF_slavearbiterlockenable <= or_reduce(powerlink_0_MAC_BUF_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --pcp_cpu/data_master powerlink_0/MAC_BUF arbiterlock, which is an e_assign
  pcp_cpu_data_master_arbiterlock <= powerlink_0_MAC_BUF_slavearbiterlockenable AND pcp_cpu_data_master_continuerequest;
  --powerlink_0_MAC_BUF_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  powerlink_0_MAC_BUF_slavearbiterlockenable2 <= or_reduce(powerlink_0_MAC_BUF_arb_share_counter_next_value);
  --pcp_cpu/data_master powerlink_0/MAC_BUF arbiterlock2, which is an e_assign
  pcp_cpu_data_master_arbiterlock2 <= powerlink_0_MAC_BUF_slavearbiterlockenable2 AND pcp_cpu_data_master_continuerequest;
  --powerlink_0_MAC_BUF_any_continuerequest at least one master continues requesting, which is an e_assign
  powerlink_0_MAC_BUF_any_continuerequest <= std_logic'('1');
  --pcp_cpu_data_master_continuerequest continued request, which is an e_assign
  pcp_cpu_data_master_continuerequest <= std_logic'('1');
  internal_pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF <= internal_pcp_cpu_data_master_requests_powerlink_0_MAC_BUF AND NOT (((NOT pcp_cpu_data_master_waitrequest) AND pcp_cpu_data_master_write));
  --powerlink_0_MAC_BUF_writedata mux, which is an e_mux
  powerlink_0_MAC_BUF_writedata <= pcp_cpu_data_master_writedata;
  --master is always granted when requested
  internal_pcp_cpu_data_master_granted_powerlink_0_MAC_BUF <= internal_pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF;
  --pcp_cpu/data_master saved-grant powerlink_0/MAC_BUF, which is an e_assign
  pcp_cpu_data_master_saved_grant_powerlink_0_MAC_BUF <= internal_pcp_cpu_data_master_requests_powerlink_0_MAC_BUF;
  --allow new arb cycle for powerlink_0/MAC_BUF, which is an e_assign
  powerlink_0_MAC_BUF_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  powerlink_0_MAC_BUF_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  powerlink_0_MAC_BUF_master_qreq_vector <= std_logic'('1');
  --~powerlink_0_MAC_BUF_reset assignment, which is an e_assign
  powerlink_0_MAC_BUF_reset <= NOT reset_n;
  powerlink_0_MAC_BUF_chipselect <= internal_pcp_cpu_data_master_granted_powerlink_0_MAC_BUF;
  --powerlink_0_MAC_BUF_firsttransfer first transaction, which is an e_assign
  powerlink_0_MAC_BUF_firsttransfer <= A_WE_StdLogic((std_logic'(powerlink_0_MAC_BUF_begins_xfer) = '1'), powerlink_0_MAC_BUF_unreg_firsttransfer, powerlink_0_MAC_BUF_reg_firsttransfer);
  --powerlink_0_MAC_BUF_unreg_firsttransfer first transaction, which is an e_assign
  powerlink_0_MAC_BUF_unreg_firsttransfer <= NOT ((powerlink_0_MAC_BUF_slavearbiterlockenable AND powerlink_0_MAC_BUF_any_continuerequest));
  --powerlink_0_MAC_BUF_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_MAC_BUF_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(powerlink_0_MAC_BUF_begins_xfer) = '1' then 
        powerlink_0_MAC_BUF_reg_firsttransfer <= powerlink_0_MAC_BUF_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --powerlink_0_MAC_BUF_beginbursttransfer_internal begin burst transfer, which is an e_assign
  powerlink_0_MAC_BUF_beginbursttransfer_internal <= powerlink_0_MAC_BUF_begins_xfer;
  --~powerlink_0_MAC_BUF_read_n assignment, which is an e_mux
  powerlink_0_MAC_BUF_read_n <= NOT ((internal_pcp_cpu_data_master_granted_powerlink_0_MAC_BUF AND pcp_cpu_data_master_read));
  --~powerlink_0_MAC_BUF_write_n assignment, which is an e_mux
  powerlink_0_MAC_BUF_write_n <= NOT ((internal_pcp_cpu_data_master_granted_powerlink_0_MAC_BUF AND pcp_cpu_data_master_write));
  shifted_address_to_powerlink_0_MAC_BUF_from_pcp_cpu_data_master <= pcp_cpu_data_master_address_to_slave;
  --powerlink_0_MAC_BUF_address mux, which is an e_mux
  powerlink_0_MAC_BUF_address <= A_EXT (A_SRL(shifted_address_to_powerlink_0_MAC_BUF_from_pcp_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 12);
  --d1_powerlink_0_MAC_BUF_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_powerlink_0_MAC_BUF_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_powerlink_0_MAC_BUF_end_xfer <= powerlink_0_MAC_BUF_end_xfer;
    end if;

  end process;

  --powerlink_0_MAC_BUF_waits_for_read in a cycle, which is an e_mux
  powerlink_0_MAC_BUF_waits_for_read <= powerlink_0_MAC_BUF_in_a_read_cycle AND wait_for_powerlink_0_MAC_BUF_counter;
  --powerlink_0_MAC_BUF_in_a_read_cycle assignment, which is an e_assign
  powerlink_0_MAC_BUF_in_a_read_cycle <= internal_pcp_cpu_data_master_granted_powerlink_0_MAC_BUF AND pcp_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= powerlink_0_MAC_BUF_in_a_read_cycle;
  --powerlink_0_MAC_BUF_waits_for_write in a cycle, which is an e_mux
  powerlink_0_MAC_BUF_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(powerlink_0_MAC_BUF_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --powerlink_0_MAC_BUF_in_a_write_cycle assignment, which is an e_assign
  powerlink_0_MAC_BUF_in_a_write_cycle <= internal_pcp_cpu_data_master_granted_powerlink_0_MAC_BUF AND pcp_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= powerlink_0_MAC_BUF_in_a_write_cycle;
  internal_powerlink_0_MAC_BUF_wait_counter_eq_0 <= to_std_logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(powerlink_0_MAC_BUF_wait_counter))) = std_logic_vector'("00000000000000000000000000000000")));
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_MAC_BUF_wait_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      powerlink_0_MAC_BUF_wait_counter <= powerlink_0_MAC_BUF_counter_load_value;
    end if;

  end process;

  powerlink_0_MAC_BUF_counter_load_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(((powerlink_0_MAC_BUF_in_a_read_cycle AND powerlink_0_MAC_BUF_begins_xfer))) = '1'), std_logic_vector'("000000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'((NOT internal_powerlink_0_MAC_BUF_wait_counter_eq_0)) = '1'), ((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(powerlink_0_MAC_BUF_wait_counter))) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))));
  wait_for_powerlink_0_MAC_BUF_counter <= powerlink_0_MAC_BUF_begins_xfer OR NOT internal_powerlink_0_MAC_BUF_wait_counter_eq_0;
  --powerlink_0_MAC_BUF_byteenable byte enable port mux, which is an e_mux
  powerlink_0_MAC_BUF_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_powerlink_0_MAC_BUF)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (pcp_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  pcp_cpu_data_master_granted_powerlink_0_MAC_BUF <= internal_pcp_cpu_data_master_granted_powerlink_0_MAC_BUF;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF <= internal_pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_requests_powerlink_0_MAC_BUF <= internal_pcp_cpu_data_master_requests_powerlink_0_MAC_BUF;
  --vhdl renameroo for output signals
  powerlink_0_MAC_BUF_wait_counter_eq_0 <= internal_powerlink_0_MAC_BUF_wait_counter_eq_0;
--synthesis translate_off
    --powerlink_0/MAC_BUF enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity powerlink_0_MAC_CMP_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal clock_crossing_0_m1_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal powerlink_0_MAC_CMP_irq : IN STD_LOGIC;
                 signal powerlink_0_MAC_CMP_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal clock_crossing_0_m1_granted_powerlink_0_MAC_CMP : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_CMP : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_powerlink_0_MAC_CMP : OUT STD_LOGIC;
                 signal d1_powerlink_0_MAC_CMP_end_xfer : OUT STD_LOGIC;
                 signal powerlink_0_MAC_CMP_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal powerlink_0_MAC_CMP_byteenable_n : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal powerlink_0_MAC_CMP_chipselect : OUT STD_LOGIC;
                 signal powerlink_0_MAC_CMP_irq_from_sa : OUT STD_LOGIC;
                 signal powerlink_0_MAC_CMP_read_n : OUT STD_LOGIC;
                 signal powerlink_0_MAC_CMP_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal powerlink_0_MAC_CMP_write_n : OUT STD_LOGIC;
                 signal powerlink_0_MAC_CMP_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity powerlink_0_MAC_CMP_arbitrator;


architecture europa of powerlink_0_MAC_CMP_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_powerlink_0_MAC_CMP :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_powerlink_0_MAC_CMP :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_granted_powerlink_0_MAC_CMP :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_powerlink_0_MAC_CMP :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_allgrants :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_allow_new_arb_cycle :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_any_bursting_master_saved_grant :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_any_continuerequest :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_arb_counter_enable :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_MAC_CMP_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_MAC_CMP_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_MAC_CMP_beginbursttransfer_internal :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_begins_xfer :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_end_xfer :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_firsttransfer :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_grant_vector :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_in_a_read_cycle :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_in_a_write_cycle :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_master_qreq_vector :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_non_bursting_master_requests :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_reg_firsttransfer :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_slavearbiterlockenable :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_slavearbiterlockenable2 :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_unreg_firsttransfer :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_waits_for_read :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_powerlink_0_MAC_CMP_from_clock_crossing_0_m1 :  STD_LOGIC_VECTOR (13 DOWNTO 0);
                signal wait_for_powerlink_0_MAC_CMP_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT powerlink_0_MAC_CMP_end_xfer;
    end if;

  end process;

  powerlink_0_MAC_CMP_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP);
  --assign powerlink_0_MAC_CMP_readdata_from_sa = powerlink_0_MAC_CMP_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  powerlink_0_MAC_CMP_readdata_from_sa <= powerlink_0_MAC_CMP_readdata;
  internal_clock_crossing_0_m1_requests_powerlink_0_MAC_CMP <= to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(13 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("10000001000000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write));
  --powerlink_0_MAC_CMP_arb_share_counter set values, which is an e_mux
  powerlink_0_MAC_CMP_arb_share_set_values <= std_logic_vector'("01");
  --powerlink_0_MAC_CMP_non_bursting_master_requests mux, which is an e_mux
  powerlink_0_MAC_CMP_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_powerlink_0_MAC_CMP;
  --powerlink_0_MAC_CMP_any_bursting_master_saved_grant mux, which is an e_mux
  powerlink_0_MAC_CMP_any_bursting_master_saved_grant <= std_logic'('0');
  --powerlink_0_MAC_CMP_arb_share_counter_next_value assignment, which is an e_assign
  powerlink_0_MAC_CMP_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(powerlink_0_MAC_CMP_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (powerlink_0_MAC_CMP_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(powerlink_0_MAC_CMP_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (powerlink_0_MAC_CMP_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --powerlink_0_MAC_CMP_allgrants all slave grants, which is an e_mux
  powerlink_0_MAC_CMP_allgrants <= powerlink_0_MAC_CMP_grant_vector;
  --powerlink_0_MAC_CMP_end_xfer assignment, which is an e_assign
  powerlink_0_MAC_CMP_end_xfer <= NOT ((powerlink_0_MAC_CMP_waits_for_read OR powerlink_0_MAC_CMP_waits_for_write));
  --end_xfer_arb_share_counter_term_powerlink_0_MAC_CMP arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_powerlink_0_MAC_CMP <= powerlink_0_MAC_CMP_end_xfer AND (((NOT powerlink_0_MAC_CMP_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --powerlink_0_MAC_CMP_arb_share_counter arbitration counter enable, which is an e_assign
  powerlink_0_MAC_CMP_arb_counter_enable <= ((end_xfer_arb_share_counter_term_powerlink_0_MAC_CMP AND powerlink_0_MAC_CMP_allgrants)) OR ((end_xfer_arb_share_counter_term_powerlink_0_MAC_CMP AND NOT powerlink_0_MAC_CMP_non_bursting_master_requests));
  --powerlink_0_MAC_CMP_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_MAC_CMP_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(powerlink_0_MAC_CMP_arb_counter_enable) = '1' then 
        powerlink_0_MAC_CMP_arb_share_counter <= powerlink_0_MAC_CMP_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --powerlink_0_MAC_CMP_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_MAC_CMP_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((powerlink_0_MAC_CMP_master_qreq_vector AND end_xfer_arb_share_counter_term_powerlink_0_MAC_CMP)) OR ((end_xfer_arb_share_counter_term_powerlink_0_MAC_CMP AND NOT powerlink_0_MAC_CMP_non_bursting_master_requests)))) = '1' then 
        powerlink_0_MAC_CMP_slavearbiterlockenable <= or_reduce(powerlink_0_MAC_CMP_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 powerlink_0/MAC_CMP arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= powerlink_0_MAC_CMP_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --powerlink_0_MAC_CMP_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  powerlink_0_MAC_CMP_slavearbiterlockenable2 <= or_reduce(powerlink_0_MAC_CMP_arb_share_counter_next_value);
  --clock_crossing_0/m1 powerlink_0/MAC_CMP arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= powerlink_0_MAC_CMP_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --powerlink_0_MAC_CMP_any_continuerequest at least one master continues requesting, which is an e_assign
  powerlink_0_MAC_CMP_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP <= internal_clock_crossing_0_m1_requests_powerlink_0_MAC_CMP AND NOT ((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_CMP, which is an e_mux
  clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_CMP <= (internal_clock_crossing_0_m1_granted_powerlink_0_MAC_CMP AND clock_crossing_0_m1_read) AND NOT powerlink_0_MAC_CMP_waits_for_read;
  --powerlink_0_MAC_CMP_writedata mux, which is an e_mux
  powerlink_0_MAC_CMP_writedata <= clock_crossing_0_m1_writedata;
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_powerlink_0_MAC_CMP <= internal_clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP;
  --clock_crossing_0/m1 saved-grant powerlink_0/MAC_CMP, which is an e_assign
  clock_crossing_0_m1_saved_grant_powerlink_0_MAC_CMP <= internal_clock_crossing_0_m1_requests_powerlink_0_MAC_CMP;
  --allow new arb cycle for powerlink_0/MAC_CMP, which is an e_assign
  powerlink_0_MAC_CMP_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  powerlink_0_MAC_CMP_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  powerlink_0_MAC_CMP_master_qreq_vector <= std_logic'('1');
  powerlink_0_MAC_CMP_chipselect <= internal_clock_crossing_0_m1_granted_powerlink_0_MAC_CMP;
  --powerlink_0_MAC_CMP_firsttransfer first transaction, which is an e_assign
  powerlink_0_MAC_CMP_firsttransfer <= A_WE_StdLogic((std_logic'(powerlink_0_MAC_CMP_begins_xfer) = '1'), powerlink_0_MAC_CMP_unreg_firsttransfer, powerlink_0_MAC_CMP_reg_firsttransfer);
  --powerlink_0_MAC_CMP_unreg_firsttransfer first transaction, which is an e_assign
  powerlink_0_MAC_CMP_unreg_firsttransfer <= NOT ((powerlink_0_MAC_CMP_slavearbiterlockenable AND powerlink_0_MAC_CMP_any_continuerequest));
  --powerlink_0_MAC_CMP_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_MAC_CMP_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(powerlink_0_MAC_CMP_begins_xfer) = '1' then 
        powerlink_0_MAC_CMP_reg_firsttransfer <= powerlink_0_MAC_CMP_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --powerlink_0_MAC_CMP_beginbursttransfer_internal begin burst transfer, which is an e_assign
  powerlink_0_MAC_CMP_beginbursttransfer_internal <= powerlink_0_MAC_CMP_begins_xfer;
  --~powerlink_0_MAC_CMP_read_n assignment, which is an e_mux
  powerlink_0_MAC_CMP_read_n <= NOT ((internal_clock_crossing_0_m1_granted_powerlink_0_MAC_CMP AND clock_crossing_0_m1_read));
  --~powerlink_0_MAC_CMP_write_n assignment, which is an e_mux
  powerlink_0_MAC_CMP_write_n <= NOT ((internal_clock_crossing_0_m1_granted_powerlink_0_MAC_CMP AND clock_crossing_0_m1_write));
  shifted_address_to_powerlink_0_MAC_CMP_from_clock_crossing_0_m1 <= clock_crossing_0_m1_address_to_slave;
  --powerlink_0_MAC_CMP_address mux, which is an e_mux
  powerlink_0_MAC_CMP_address <= A_EXT (A_SRL(shifted_address_to_powerlink_0_MAC_CMP_from_clock_crossing_0_m1,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_powerlink_0_MAC_CMP_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_powerlink_0_MAC_CMP_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_powerlink_0_MAC_CMP_end_xfer <= powerlink_0_MAC_CMP_end_xfer;
    end if;

  end process;

  --powerlink_0_MAC_CMP_waits_for_read in a cycle, which is an e_mux
  powerlink_0_MAC_CMP_waits_for_read <= powerlink_0_MAC_CMP_in_a_read_cycle AND powerlink_0_MAC_CMP_begins_xfer;
  --powerlink_0_MAC_CMP_in_a_read_cycle assignment, which is an e_assign
  powerlink_0_MAC_CMP_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_powerlink_0_MAC_CMP AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= powerlink_0_MAC_CMP_in_a_read_cycle;
  --powerlink_0_MAC_CMP_waits_for_write in a cycle, which is an e_mux
  powerlink_0_MAC_CMP_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(powerlink_0_MAC_CMP_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --powerlink_0_MAC_CMP_in_a_write_cycle assignment, which is an e_assign
  powerlink_0_MAC_CMP_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_powerlink_0_MAC_CMP AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= powerlink_0_MAC_CMP_in_a_write_cycle;
  wait_for_powerlink_0_MAC_CMP_counter <= std_logic'('0');
  --~powerlink_0_MAC_CMP_byteenable_n byte enable port mux, which is an e_mux
  powerlink_0_MAC_CMP_byteenable_n <= A_EXT (NOT (A_WE_StdLogicVector((std_logic'((internal_clock_crossing_0_m1_granted_powerlink_0_MAC_CMP)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (clock_crossing_0_m1_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001")))), 4);
  --assign powerlink_0_MAC_CMP_irq_from_sa = powerlink_0_MAC_CMP_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  powerlink_0_MAC_CMP_irq_from_sa <= powerlink_0_MAC_CMP_irq;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_powerlink_0_MAC_CMP <= internal_clock_crossing_0_m1_granted_powerlink_0_MAC_CMP;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP <= internal_clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_powerlink_0_MAC_CMP <= internal_clock_crossing_0_m1_requests_powerlink_0_MAC_CMP;
--synthesis translate_off
    --powerlink_0/MAC_CMP enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity powerlink_0_MAC_REG_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal clock_crossing_0_m1_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal clock_crossing_0_m1_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal clock_crossing_0_m1_dbs_write_16 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal powerlink_0_MAC_REG_irq : IN STD_LOGIC;
                 signal powerlink_0_MAC_REG_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal clock_crossing_0_m1_granted_powerlink_0_MAC_REG : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_REG : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_powerlink_0_MAC_REG : OUT STD_LOGIC;
                 signal d1_powerlink_0_MAC_REG_end_xfer : OUT STD_LOGIC;
                 signal powerlink_0_MAC_REG_address : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                 signal powerlink_0_MAC_REG_byteenable_n : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal powerlink_0_MAC_REG_chipselect : OUT STD_LOGIC;
                 signal powerlink_0_MAC_REG_irq_from_sa : OUT STD_LOGIC;
                 signal powerlink_0_MAC_REG_read_n : OUT STD_LOGIC;
                 signal powerlink_0_MAC_REG_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal powerlink_0_MAC_REG_write_n : OUT STD_LOGIC;
                 signal powerlink_0_MAC_REG_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity powerlink_0_MAC_REG_arbitrator;


architecture europa of powerlink_0_MAC_REG_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG_segment_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG_segment_1 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_powerlink_0_MAC_REG :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_powerlink_0_MAC_REG :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_clock_crossing_0_m1_granted_powerlink_0_MAC_REG :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_powerlink_0_MAC_REG :  STD_LOGIC;
                signal powerlink_0_MAC_REG_allgrants :  STD_LOGIC;
                signal powerlink_0_MAC_REG_allow_new_arb_cycle :  STD_LOGIC;
                signal powerlink_0_MAC_REG_any_bursting_master_saved_grant :  STD_LOGIC;
                signal powerlink_0_MAC_REG_any_continuerequest :  STD_LOGIC;
                signal powerlink_0_MAC_REG_arb_counter_enable :  STD_LOGIC;
                signal powerlink_0_MAC_REG_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_MAC_REG_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_MAC_REG_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_MAC_REG_beginbursttransfer_internal :  STD_LOGIC;
                signal powerlink_0_MAC_REG_begins_xfer :  STD_LOGIC;
                signal powerlink_0_MAC_REG_end_xfer :  STD_LOGIC;
                signal powerlink_0_MAC_REG_firsttransfer :  STD_LOGIC;
                signal powerlink_0_MAC_REG_grant_vector :  STD_LOGIC;
                signal powerlink_0_MAC_REG_in_a_read_cycle :  STD_LOGIC;
                signal powerlink_0_MAC_REG_in_a_write_cycle :  STD_LOGIC;
                signal powerlink_0_MAC_REG_master_qreq_vector :  STD_LOGIC;
                signal powerlink_0_MAC_REG_non_bursting_master_requests :  STD_LOGIC;
                signal powerlink_0_MAC_REG_reg_firsttransfer :  STD_LOGIC;
                signal powerlink_0_MAC_REG_slavearbiterlockenable :  STD_LOGIC;
                signal powerlink_0_MAC_REG_slavearbiterlockenable2 :  STD_LOGIC;
                signal powerlink_0_MAC_REG_unreg_firsttransfer :  STD_LOGIC;
                signal powerlink_0_MAC_REG_waits_for_read :  STD_LOGIC;
                signal powerlink_0_MAC_REG_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_powerlink_0_MAC_REG_from_clock_crossing_0_m1 :  STD_LOGIC_VECTOR (13 DOWNTO 0);
                signal wait_for_powerlink_0_MAC_REG_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT powerlink_0_MAC_REG_end_xfer;
    end if;

  end process;

  powerlink_0_MAC_REG_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG);
  --assign powerlink_0_MAC_REG_readdata_from_sa = powerlink_0_MAC_REG_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  powerlink_0_MAC_REG_readdata_from_sa <= powerlink_0_MAC_REG_readdata;
  internal_clock_crossing_0_m1_requests_powerlink_0_MAC_REG <= to_std_logic(((Std_Logic_Vector'(A_ToStdLogicVector(clock_crossing_0_m1_address_to_slave(13)) & std_logic_vector'("0000000000000")) = std_logic_vector'("00000000000000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write));
  --powerlink_0_MAC_REG_arb_share_counter set values, which is an e_mux
  powerlink_0_MAC_REG_arb_share_set_values <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_clock_crossing_0_m1_granted_powerlink_0_MAC_REG)) = '1'), std_logic_vector'("00000000000000000000000000000010"), std_logic_vector'("00000000000000000000000000000001")), 2);
  --powerlink_0_MAC_REG_non_bursting_master_requests mux, which is an e_mux
  powerlink_0_MAC_REG_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_powerlink_0_MAC_REG;
  --powerlink_0_MAC_REG_any_bursting_master_saved_grant mux, which is an e_mux
  powerlink_0_MAC_REG_any_bursting_master_saved_grant <= std_logic'('0');
  --powerlink_0_MAC_REG_arb_share_counter_next_value assignment, which is an e_assign
  powerlink_0_MAC_REG_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(powerlink_0_MAC_REG_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (powerlink_0_MAC_REG_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(powerlink_0_MAC_REG_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (powerlink_0_MAC_REG_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --powerlink_0_MAC_REG_allgrants all slave grants, which is an e_mux
  powerlink_0_MAC_REG_allgrants <= powerlink_0_MAC_REG_grant_vector;
  --powerlink_0_MAC_REG_end_xfer assignment, which is an e_assign
  powerlink_0_MAC_REG_end_xfer <= NOT ((powerlink_0_MAC_REG_waits_for_read OR powerlink_0_MAC_REG_waits_for_write));
  --end_xfer_arb_share_counter_term_powerlink_0_MAC_REG arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_powerlink_0_MAC_REG <= powerlink_0_MAC_REG_end_xfer AND (((NOT powerlink_0_MAC_REG_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --powerlink_0_MAC_REG_arb_share_counter arbitration counter enable, which is an e_assign
  powerlink_0_MAC_REG_arb_counter_enable <= ((end_xfer_arb_share_counter_term_powerlink_0_MAC_REG AND powerlink_0_MAC_REG_allgrants)) OR ((end_xfer_arb_share_counter_term_powerlink_0_MAC_REG AND NOT powerlink_0_MAC_REG_non_bursting_master_requests));
  --powerlink_0_MAC_REG_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_MAC_REG_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(powerlink_0_MAC_REG_arb_counter_enable) = '1' then 
        powerlink_0_MAC_REG_arb_share_counter <= powerlink_0_MAC_REG_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --powerlink_0_MAC_REG_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_MAC_REG_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((powerlink_0_MAC_REG_master_qreq_vector AND end_xfer_arb_share_counter_term_powerlink_0_MAC_REG)) OR ((end_xfer_arb_share_counter_term_powerlink_0_MAC_REG AND NOT powerlink_0_MAC_REG_non_bursting_master_requests)))) = '1' then 
        powerlink_0_MAC_REG_slavearbiterlockenable <= or_reduce(powerlink_0_MAC_REG_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 powerlink_0/MAC_REG arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= powerlink_0_MAC_REG_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --powerlink_0_MAC_REG_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  powerlink_0_MAC_REG_slavearbiterlockenable2 <= or_reduce(powerlink_0_MAC_REG_arb_share_counter_next_value);
  --clock_crossing_0/m1 powerlink_0/MAC_REG arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= powerlink_0_MAC_REG_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --powerlink_0_MAC_REG_any_continuerequest at least one master continues requesting, which is an e_assign
  powerlink_0_MAC_REG_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG <= internal_clock_crossing_0_m1_requests_powerlink_0_MAC_REG AND NOT ((((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000")))))) OR (((NOT(or_reduce(internal_clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG))) AND clock_crossing_0_m1_write))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_REG, which is an e_mux
  clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_REG <= (internal_clock_crossing_0_m1_granted_powerlink_0_MAC_REG AND clock_crossing_0_m1_read) AND NOT powerlink_0_MAC_REG_waits_for_read;
  --powerlink_0_MAC_REG_writedata mux, which is an e_mux
  powerlink_0_MAC_REG_writedata <= clock_crossing_0_m1_dbs_write_16;
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_powerlink_0_MAC_REG <= internal_clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG;
  --clock_crossing_0/m1 saved-grant powerlink_0/MAC_REG, which is an e_assign
  clock_crossing_0_m1_saved_grant_powerlink_0_MAC_REG <= internal_clock_crossing_0_m1_requests_powerlink_0_MAC_REG;
  --allow new arb cycle for powerlink_0/MAC_REG, which is an e_assign
  powerlink_0_MAC_REG_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  powerlink_0_MAC_REG_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  powerlink_0_MAC_REG_master_qreq_vector <= std_logic'('1');
  powerlink_0_MAC_REG_chipselect <= internal_clock_crossing_0_m1_granted_powerlink_0_MAC_REG;
  --powerlink_0_MAC_REG_firsttransfer first transaction, which is an e_assign
  powerlink_0_MAC_REG_firsttransfer <= A_WE_StdLogic((std_logic'(powerlink_0_MAC_REG_begins_xfer) = '1'), powerlink_0_MAC_REG_unreg_firsttransfer, powerlink_0_MAC_REG_reg_firsttransfer);
  --powerlink_0_MAC_REG_unreg_firsttransfer first transaction, which is an e_assign
  powerlink_0_MAC_REG_unreg_firsttransfer <= NOT ((powerlink_0_MAC_REG_slavearbiterlockenable AND powerlink_0_MAC_REG_any_continuerequest));
  --powerlink_0_MAC_REG_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_MAC_REG_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(powerlink_0_MAC_REG_begins_xfer) = '1' then 
        powerlink_0_MAC_REG_reg_firsttransfer <= powerlink_0_MAC_REG_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --powerlink_0_MAC_REG_beginbursttransfer_internal begin burst transfer, which is an e_assign
  powerlink_0_MAC_REG_beginbursttransfer_internal <= powerlink_0_MAC_REG_begins_xfer;
  --~powerlink_0_MAC_REG_read_n assignment, which is an e_mux
  powerlink_0_MAC_REG_read_n <= NOT ((internal_clock_crossing_0_m1_granted_powerlink_0_MAC_REG AND clock_crossing_0_m1_read));
  --~powerlink_0_MAC_REG_write_n assignment, which is an e_mux
  powerlink_0_MAC_REG_write_n <= NOT ((internal_clock_crossing_0_m1_granted_powerlink_0_MAC_REG AND clock_crossing_0_m1_write));
  shifted_address_to_powerlink_0_MAC_REG_from_clock_crossing_0_m1 <= A_EXT (Std_Logic_Vector'(A_SRL(clock_crossing_0_m1_address_to_slave,std_logic_vector'("00000000000000000000000000000010")) & A_ToStdLogicVector(clock_crossing_0_m1_dbs_address(1)) & A_ToStdLogicVector(std_logic'('0'))), 14);
  --powerlink_0_MAC_REG_address mux, which is an e_mux
  powerlink_0_MAC_REG_address <= A_EXT (A_SRL(shifted_address_to_powerlink_0_MAC_REG_from_clock_crossing_0_m1,std_logic_vector'("00000000000000000000000000000001")), 12);
  --d1_powerlink_0_MAC_REG_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_powerlink_0_MAC_REG_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_powerlink_0_MAC_REG_end_xfer <= powerlink_0_MAC_REG_end_xfer;
    end if;

  end process;

  --powerlink_0_MAC_REG_waits_for_read in a cycle, which is an e_mux
  powerlink_0_MAC_REG_waits_for_read <= powerlink_0_MAC_REG_in_a_read_cycle AND powerlink_0_MAC_REG_begins_xfer;
  --powerlink_0_MAC_REG_in_a_read_cycle assignment, which is an e_assign
  powerlink_0_MAC_REG_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_powerlink_0_MAC_REG AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= powerlink_0_MAC_REG_in_a_read_cycle;
  --powerlink_0_MAC_REG_waits_for_write in a cycle, which is an e_mux
  powerlink_0_MAC_REG_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(powerlink_0_MAC_REG_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --powerlink_0_MAC_REG_in_a_write_cycle assignment, which is an e_assign
  powerlink_0_MAC_REG_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_powerlink_0_MAC_REG AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= powerlink_0_MAC_REG_in_a_write_cycle;
  wait_for_powerlink_0_MAC_REG_counter <= std_logic'('0');
  --~powerlink_0_MAC_REG_byteenable_n byte enable port mux, which is an e_mux
  powerlink_0_MAC_REG_byteenable_n <= A_EXT (NOT (A_WE_StdLogicVector((std_logic'((internal_clock_crossing_0_m1_granted_powerlink_0_MAC_REG)) = '1'), (std_logic_vector'("000000000000000000000000000000") & (internal_clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG)), -SIGNED(std_logic_vector'("00000000000000000000000000000001")))), 2);
  (clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG_segment_1(1), clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG_segment_1(0), clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG_segment_0(1), clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG_segment_0(0)) <= clock_crossing_0_m1_byteenable;
  internal_clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_dbs_address(1)))) = std_logic_vector'("00000000000000000000000000000000"))), clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG_segment_0, clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG_segment_1);
  --assign powerlink_0_MAC_REG_irq_from_sa = powerlink_0_MAC_REG_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  powerlink_0_MAC_REG_irq_from_sa <= powerlink_0_MAC_REG_irq;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG <= internal_clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_powerlink_0_MAC_REG <= internal_clock_crossing_0_m1_granted_powerlink_0_MAC_REG;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG <= internal_clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_powerlink_0_MAC_REG <= internal_clock_crossing_0_m1_requests_powerlink_0_MAC_REG;
--synthesis translate_off
    --powerlink_0/MAC_REG enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity powerlink_0_PDI_AP_arbitrator is 
        port (
              -- inputs:
                 signal avalon_address_from_the_avalon_master_bridge_0_to_slave : IN STD_LOGIC_VECTOR (14 DOWNTO 0);
                 signal avalon_byteenable_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal avalon_master_bridge_0_latency_counter : IN STD_LOGIC;
                 signal avalon_read_from_the_avalon_master_bridge_0 : IN STD_LOGIC;
                 signal avalon_write_from_the_avalon_master_bridge_0 : IN STD_LOGIC;
                 signal avalon_writedata_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal powerlink_0_PDI_AP_irq : IN STD_LOGIC;
                 signal powerlink_0_PDI_AP_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal avalon_master_bridge_0_granted_powerlink_0_PDI_AP : OUT STD_LOGIC;
                 signal avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP : OUT STD_LOGIC;
                 signal avalon_master_bridge_0_read_data_valid_powerlink_0_PDI_AP : OUT STD_LOGIC;
                 signal avalon_master_bridge_0_requests_powerlink_0_PDI_AP : OUT STD_LOGIC;
                 signal d1_powerlink_0_PDI_AP_end_xfer : OUT STD_LOGIC;
                 signal powerlink_0_PDI_AP_address : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                 signal powerlink_0_PDI_AP_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal powerlink_0_PDI_AP_chipselect : OUT STD_LOGIC;
                 signal powerlink_0_PDI_AP_irq_from_sa : OUT STD_LOGIC;
                 signal powerlink_0_PDI_AP_read : OUT STD_LOGIC;
                 signal powerlink_0_PDI_AP_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal powerlink_0_PDI_AP_reset : OUT STD_LOGIC;
                 signal powerlink_0_PDI_AP_wait_counter_eq_0 : OUT STD_LOGIC;
                 signal powerlink_0_PDI_AP_write : OUT STD_LOGIC;
                 signal powerlink_0_PDI_AP_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity powerlink_0_PDI_AP_arbitrator;


architecture europa of powerlink_0_PDI_AP_arbitrator is
                signal avalon_master_bridge_0_AvalonMaster_arbiterlock :  STD_LOGIC;
                signal avalon_master_bridge_0_AvalonMaster_arbiterlock2 :  STD_LOGIC;
                signal avalon_master_bridge_0_AvalonMaster_continuerequest :  STD_LOGIC;
                signal avalon_master_bridge_0_saved_grant_powerlink_0_PDI_AP :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_powerlink_0_PDI_AP :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_avalon_master_bridge_0_granted_powerlink_0_PDI_AP :  STD_LOGIC;
                signal internal_avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP :  STD_LOGIC;
                signal internal_avalon_master_bridge_0_requests_powerlink_0_PDI_AP :  STD_LOGIC;
                signal internal_powerlink_0_PDI_AP_wait_counter_eq_0 :  STD_LOGIC;
                signal powerlink_0_PDI_AP_allgrants :  STD_LOGIC;
                signal powerlink_0_PDI_AP_allow_new_arb_cycle :  STD_LOGIC;
                signal powerlink_0_PDI_AP_any_bursting_master_saved_grant :  STD_LOGIC;
                signal powerlink_0_PDI_AP_any_continuerequest :  STD_LOGIC;
                signal powerlink_0_PDI_AP_arb_counter_enable :  STD_LOGIC;
                signal powerlink_0_PDI_AP_arb_share_counter :  STD_LOGIC;
                signal powerlink_0_PDI_AP_arb_share_counter_next_value :  STD_LOGIC;
                signal powerlink_0_PDI_AP_arb_share_set_values :  STD_LOGIC;
                signal powerlink_0_PDI_AP_beginbursttransfer_internal :  STD_LOGIC;
                signal powerlink_0_PDI_AP_begins_xfer :  STD_LOGIC;
                signal powerlink_0_PDI_AP_counter_load_value :  STD_LOGIC;
                signal powerlink_0_PDI_AP_end_xfer :  STD_LOGIC;
                signal powerlink_0_PDI_AP_firsttransfer :  STD_LOGIC;
                signal powerlink_0_PDI_AP_grant_vector :  STD_LOGIC;
                signal powerlink_0_PDI_AP_in_a_read_cycle :  STD_LOGIC;
                signal powerlink_0_PDI_AP_in_a_write_cycle :  STD_LOGIC;
                signal powerlink_0_PDI_AP_master_qreq_vector :  STD_LOGIC;
                signal powerlink_0_PDI_AP_non_bursting_master_requests :  STD_LOGIC;
                signal powerlink_0_PDI_AP_reg_firsttransfer :  STD_LOGIC;
                signal powerlink_0_PDI_AP_slavearbiterlockenable :  STD_LOGIC;
                signal powerlink_0_PDI_AP_slavearbiterlockenable2 :  STD_LOGIC;
                signal powerlink_0_PDI_AP_unreg_firsttransfer :  STD_LOGIC;
                signal powerlink_0_PDI_AP_wait_counter :  STD_LOGIC;
                signal powerlink_0_PDI_AP_waits_for_read :  STD_LOGIC;
                signal powerlink_0_PDI_AP_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_powerlink_0_PDI_AP_from_avalon_master_bridge_0_AvalonMaster :  STD_LOGIC_VECTOR (14 DOWNTO 0);
                signal wait_for_powerlink_0_PDI_AP_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT powerlink_0_PDI_AP_end_xfer;
    end if;

  end process;

  powerlink_0_PDI_AP_begins_xfer <= NOT d1_reasons_to_wait AND (internal_avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP);
  --assign powerlink_0_PDI_AP_readdata_from_sa = powerlink_0_PDI_AP_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  powerlink_0_PDI_AP_readdata_from_sa <= powerlink_0_PDI_AP_readdata;
  internal_avalon_master_bridge_0_requests_powerlink_0_PDI_AP <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((avalon_read_from_the_avalon_master_bridge_0 OR avalon_write_from_the_avalon_master_bridge_0)))))));
  --powerlink_0_PDI_AP_arb_share_counter set values, which is an e_mux
  powerlink_0_PDI_AP_arb_share_set_values <= std_logic'('1');
  --powerlink_0_PDI_AP_non_bursting_master_requests mux, which is an e_mux
  powerlink_0_PDI_AP_non_bursting_master_requests <= internal_avalon_master_bridge_0_requests_powerlink_0_PDI_AP;
  --powerlink_0_PDI_AP_any_bursting_master_saved_grant mux, which is an e_mux
  powerlink_0_PDI_AP_any_bursting_master_saved_grant <= std_logic'('0');
  --powerlink_0_PDI_AP_arb_share_counter_next_value assignment, which is an e_assign
  powerlink_0_PDI_AP_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(powerlink_0_PDI_AP_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(powerlink_0_PDI_AP_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(powerlink_0_PDI_AP_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(powerlink_0_PDI_AP_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --powerlink_0_PDI_AP_allgrants all slave grants, which is an e_mux
  powerlink_0_PDI_AP_allgrants <= powerlink_0_PDI_AP_grant_vector;
  --powerlink_0_PDI_AP_end_xfer assignment, which is an e_assign
  powerlink_0_PDI_AP_end_xfer <= NOT ((powerlink_0_PDI_AP_waits_for_read OR powerlink_0_PDI_AP_waits_for_write));
  --end_xfer_arb_share_counter_term_powerlink_0_PDI_AP arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_powerlink_0_PDI_AP <= powerlink_0_PDI_AP_end_xfer AND (((NOT powerlink_0_PDI_AP_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --powerlink_0_PDI_AP_arb_share_counter arbitration counter enable, which is an e_assign
  powerlink_0_PDI_AP_arb_counter_enable <= ((end_xfer_arb_share_counter_term_powerlink_0_PDI_AP AND powerlink_0_PDI_AP_allgrants)) OR ((end_xfer_arb_share_counter_term_powerlink_0_PDI_AP AND NOT powerlink_0_PDI_AP_non_bursting_master_requests));
  --powerlink_0_PDI_AP_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_PDI_AP_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(powerlink_0_PDI_AP_arb_counter_enable) = '1' then 
        powerlink_0_PDI_AP_arb_share_counter <= powerlink_0_PDI_AP_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --powerlink_0_PDI_AP_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_PDI_AP_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((powerlink_0_PDI_AP_master_qreq_vector AND end_xfer_arb_share_counter_term_powerlink_0_PDI_AP)) OR ((end_xfer_arb_share_counter_term_powerlink_0_PDI_AP AND NOT powerlink_0_PDI_AP_non_bursting_master_requests)))) = '1' then 
        powerlink_0_PDI_AP_slavearbiterlockenable <= powerlink_0_PDI_AP_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --avalon_master_bridge_0/AvalonMaster powerlink_0/PDI_AP arbiterlock, which is an e_assign
  avalon_master_bridge_0_AvalonMaster_arbiterlock <= powerlink_0_PDI_AP_slavearbiterlockenable AND avalon_master_bridge_0_AvalonMaster_continuerequest;
  --powerlink_0_PDI_AP_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  powerlink_0_PDI_AP_slavearbiterlockenable2 <= powerlink_0_PDI_AP_arb_share_counter_next_value;
  --avalon_master_bridge_0/AvalonMaster powerlink_0/PDI_AP arbiterlock2, which is an e_assign
  avalon_master_bridge_0_AvalonMaster_arbiterlock2 <= powerlink_0_PDI_AP_slavearbiterlockenable2 AND avalon_master_bridge_0_AvalonMaster_continuerequest;
  --powerlink_0_PDI_AP_any_continuerequest at least one master continues requesting, which is an e_assign
  powerlink_0_PDI_AP_any_continuerequest <= std_logic'('1');
  --avalon_master_bridge_0_AvalonMaster_continuerequest continued request, which is an e_assign
  avalon_master_bridge_0_AvalonMaster_continuerequest <= std_logic'('1');
  internal_avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP <= internal_avalon_master_bridge_0_requests_powerlink_0_PDI_AP AND NOT ((avalon_read_from_the_avalon_master_bridge_0 AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(avalon_master_bridge_0_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid avalon_master_bridge_0_read_data_valid_powerlink_0_PDI_AP, which is an e_mux
  avalon_master_bridge_0_read_data_valid_powerlink_0_PDI_AP <= (internal_avalon_master_bridge_0_granted_powerlink_0_PDI_AP AND avalon_read_from_the_avalon_master_bridge_0) AND NOT powerlink_0_PDI_AP_waits_for_read;
  --powerlink_0_PDI_AP_writedata mux, which is an e_mux
  powerlink_0_PDI_AP_writedata <= avalon_writedata_from_the_avalon_master_bridge_0;
  --master is always granted when requested
  internal_avalon_master_bridge_0_granted_powerlink_0_PDI_AP <= internal_avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP;
  --avalon_master_bridge_0/AvalonMaster saved-grant powerlink_0/PDI_AP, which is an e_assign
  avalon_master_bridge_0_saved_grant_powerlink_0_PDI_AP <= internal_avalon_master_bridge_0_requests_powerlink_0_PDI_AP;
  --allow new arb cycle for powerlink_0/PDI_AP, which is an e_assign
  powerlink_0_PDI_AP_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  powerlink_0_PDI_AP_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  powerlink_0_PDI_AP_master_qreq_vector <= std_logic'('1');
  --~powerlink_0_PDI_AP_reset assignment, which is an e_assign
  powerlink_0_PDI_AP_reset <= NOT reset_n;
  powerlink_0_PDI_AP_chipselect <= internal_avalon_master_bridge_0_granted_powerlink_0_PDI_AP;
  --powerlink_0_PDI_AP_firsttransfer first transaction, which is an e_assign
  powerlink_0_PDI_AP_firsttransfer <= A_WE_StdLogic((std_logic'(powerlink_0_PDI_AP_begins_xfer) = '1'), powerlink_0_PDI_AP_unreg_firsttransfer, powerlink_0_PDI_AP_reg_firsttransfer);
  --powerlink_0_PDI_AP_unreg_firsttransfer first transaction, which is an e_assign
  powerlink_0_PDI_AP_unreg_firsttransfer <= NOT ((powerlink_0_PDI_AP_slavearbiterlockenable AND powerlink_0_PDI_AP_any_continuerequest));
  --powerlink_0_PDI_AP_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_PDI_AP_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(powerlink_0_PDI_AP_begins_xfer) = '1' then 
        powerlink_0_PDI_AP_reg_firsttransfer <= powerlink_0_PDI_AP_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --powerlink_0_PDI_AP_beginbursttransfer_internal begin burst transfer, which is an e_assign
  powerlink_0_PDI_AP_beginbursttransfer_internal <= powerlink_0_PDI_AP_begins_xfer;
  --powerlink_0_PDI_AP_read assignment, which is an e_mux
  powerlink_0_PDI_AP_read <= internal_avalon_master_bridge_0_granted_powerlink_0_PDI_AP AND avalon_read_from_the_avalon_master_bridge_0;
  --powerlink_0_PDI_AP_write assignment, which is an e_mux
  powerlink_0_PDI_AP_write <= internal_avalon_master_bridge_0_granted_powerlink_0_PDI_AP AND avalon_write_from_the_avalon_master_bridge_0;
  shifted_address_to_powerlink_0_PDI_AP_from_avalon_master_bridge_0_AvalonMaster <= avalon_address_from_the_avalon_master_bridge_0_to_slave;
  --powerlink_0_PDI_AP_address mux, which is an e_mux
  powerlink_0_PDI_AP_address <= A_EXT (A_SRL(shifted_address_to_powerlink_0_PDI_AP_from_avalon_master_bridge_0_AvalonMaster,std_logic_vector'("00000000000000000000000000000010")), 13);
  --d1_powerlink_0_PDI_AP_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_powerlink_0_PDI_AP_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_powerlink_0_PDI_AP_end_xfer <= powerlink_0_PDI_AP_end_xfer;
    end if;

  end process;

  --powerlink_0_PDI_AP_waits_for_read in a cycle, which is an e_mux
  powerlink_0_PDI_AP_waits_for_read <= powerlink_0_PDI_AP_in_a_read_cycle AND wait_for_powerlink_0_PDI_AP_counter;
  --powerlink_0_PDI_AP_in_a_read_cycle assignment, which is an e_assign
  powerlink_0_PDI_AP_in_a_read_cycle <= internal_avalon_master_bridge_0_granted_powerlink_0_PDI_AP AND avalon_read_from_the_avalon_master_bridge_0;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= powerlink_0_PDI_AP_in_a_read_cycle;
  --powerlink_0_PDI_AP_waits_for_write in a cycle, which is an e_mux
  powerlink_0_PDI_AP_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(powerlink_0_PDI_AP_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --powerlink_0_PDI_AP_in_a_write_cycle assignment, which is an e_assign
  powerlink_0_PDI_AP_in_a_write_cycle <= internal_avalon_master_bridge_0_granted_powerlink_0_PDI_AP AND avalon_write_from_the_avalon_master_bridge_0;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= powerlink_0_PDI_AP_in_a_write_cycle;
  internal_powerlink_0_PDI_AP_wait_counter_eq_0 <= to_std_logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(powerlink_0_PDI_AP_wait_counter))) = std_logic_vector'("00000000000000000000000000000000")));
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_PDI_AP_wait_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      powerlink_0_PDI_AP_wait_counter <= powerlink_0_PDI_AP_counter_load_value;
    end if;

  end process;

  powerlink_0_PDI_AP_counter_load_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(((powerlink_0_PDI_AP_in_a_read_cycle AND powerlink_0_PDI_AP_begins_xfer))) = '1'), std_logic_vector'("000000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'((NOT internal_powerlink_0_PDI_AP_wait_counter_eq_0)) = '1'), ((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(powerlink_0_PDI_AP_wait_counter))) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))));
  wait_for_powerlink_0_PDI_AP_counter <= powerlink_0_PDI_AP_begins_xfer OR NOT internal_powerlink_0_PDI_AP_wait_counter_eq_0;
  --powerlink_0_PDI_AP_byteenable byte enable port mux, which is an e_mux
  powerlink_0_PDI_AP_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_avalon_master_bridge_0_granted_powerlink_0_PDI_AP)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (avalon_byteenable_from_the_avalon_master_bridge_0)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --assign powerlink_0_PDI_AP_irq_from_sa = powerlink_0_PDI_AP_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  powerlink_0_PDI_AP_irq_from_sa <= powerlink_0_PDI_AP_irq;
  --vhdl renameroo for output signals
  avalon_master_bridge_0_granted_powerlink_0_PDI_AP <= internal_avalon_master_bridge_0_granted_powerlink_0_PDI_AP;
  --vhdl renameroo for output signals
  avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP <= internal_avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP;
  --vhdl renameroo for output signals
  avalon_master_bridge_0_requests_powerlink_0_PDI_AP <= internal_avalon_master_bridge_0_requests_powerlink_0_PDI_AP;
  --vhdl renameroo for output signals
  powerlink_0_PDI_AP_wait_counter_eq_0 <= internal_powerlink_0_PDI_AP_wait_counter_eq_0;
--synthesis translate_off
    --powerlink_0/PDI_AP enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity powerlink_0_PDI_PCP_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal pcp_cpu_data_master_read : IN STD_LOGIC;
                 signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal pcp_cpu_data_master_write : IN STD_LOGIC;
                 signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal powerlink_0_PDI_PCP_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_powerlink_0_PDI_PCP_end_xfer : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_granted_powerlink_0_PDI_PCP : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_powerlink_0_PDI_PCP : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_requests_powerlink_0_PDI_PCP : OUT STD_LOGIC;
                 signal powerlink_0_PDI_PCP_address : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                 signal powerlink_0_PDI_PCP_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal powerlink_0_PDI_PCP_chipselect : OUT STD_LOGIC;
                 signal powerlink_0_PDI_PCP_read : OUT STD_LOGIC;
                 signal powerlink_0_PDI_PCP_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal powerlink_0_PDI_PCP_wait_counter_eq_0 : OUT STD_LOGIC;
                 signal powerlink_0_PDI_PCP_write : OUT STD_LOGIC;
                 signal powerlink_0_PDI_PCP_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity powerlink_0_PDI_PCP_arbitrator;


architecture europa of powerlink_0_PDI_PCP_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_powerlink_0_PDI_PCP :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_granted_powerlink_0_PDI_PCP :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_requests_powerlink_0_PDI_PCP :  STD_LOGIC;
                signal internal_powerlink_0_PDI_PCP_wait_counter_eq_0 :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_data_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_data_master_saved_grant_powerlink_0_PDI_PCP :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_allgrants :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_allow_new_arb_cycle :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_any_bursting_master_saved_grant :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_any_continuerequest :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_arb_counter_enable :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_PDI_PCP_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_PDI_PCP_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_PDI_PCP_beginbursttransfer_internal :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_begins_xfer :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_counter_load_value :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_end_xfer :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_firsttransfer :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_grant_vector :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_in_a_read_cycle :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_in_a_write_cycle :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_master_qreq_vector :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_non_bursting_master_requests :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_reg_firsttransfer :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_slavearbiterlockenable :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_slavearbiterlockenable2 :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_unreg_firsttransfer :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_wait_counter :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_waits_for_read :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_powerlink_0_PDI_PCP_from_pcp_cpu_data_master :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal wait_for_powerlink_0_PDI_PCP_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT powerlink_0_PDI_PCP_end_xfer;
    end if;

  end process;

  powerlink_0_PDI_PCP_begins_xfer <= NOT d1_reasons_to_wait AND (internal_pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP);
  --assign powerlink_0_PDI_PCP_readdata_from_sa = powerlink_0_PDI_PCP_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  powerlink_0_PDI_PCP_readdata_from_sa <= powerlink_0_PDI_PCP_readdata;
  internal_pcp_cpu_data_master_requests_powerlink_0_PDI_PCP <= to_std_logic(((Std_Logic_Vector'(pcp_cpu_data_master_address_to_slave(24 DOWNTO 15) & std_logic_vector'("000000000000000")) = std_logic_vector'("0000000001000000000000000")))) AND ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write));
  --powerlink_0_PDI_PCP_arb_share_counter set values, which is an e_mux
  powerlink_0_PDI_PCP_arb_share_set_values <= std_logic_vector'("01");
  --powerlink_0_PDI_PCP_non_bursting_master_requests mux, which is an e_mux
  powerlink_0_PDI_PCP_non_bursting_master_requests <= internal_pcp_cpu_data_master_requests_powerlink_0_PDI_PCP;
  --powerlink_0_PDI_PCP_any_bursting_master_saved_grant mux, which is an e_mux
  powerlink_0_PDI_PCP_any_bursting_master_saved_grant <= std_logic'('0');
  --powerlink_0_PDI_PCP_arb_share_counter_next_value assignment, which is an e_assign
  powerlink_0_PDI_PCP_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(powerlink_0_PDI_PCP_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (powerlink_0_PDI_PCP_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(powerlink_0_PDI_PCP_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (powerlink_0_PDI_PCP_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --powerlink_0_PDI_PCP_allgrants all slave grants, which is an e_mux
  powerlink_0_PDI_PCP_allgrants <= powerlink_0_PDI_PCP_grant_vector;
  --powerlink_0_PDI_PCP_end_xfer assignment, which is an e_assign
  powerlink_0_PDI_PCP_end_xfer <= NOT ((powerlink_0_PDI_PCP_waits_for_read OR powerlink_0_PDI_PCP_waits_for_write));
  --end_xfer_arb_share_counter_term_powerlink_0_PDI_PCP arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_powerlink_0_PDI_PCP <= powerlink_0_PDI_PCP_end_xfer AND (((NOT powerlink_0_PDI_PCP_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --powerlink_0_PDI_PCP_arb_share_counter arbitration counter enable, which is an e_assign
  powerlink_0_PDI_PCP_arb_counter_enable <= ((end_xfer_arb_share_counter_term_powerlink_0_PDI_PCP AND powerlink_0_PDI_PCP_allgrants)) OR ((end_xfer_arb_share_counter_term_powerlink_0_PDI_PCP AND NOT powerlink_0_PDI_PCP_non_bursting_master_requests));
  --powerlink_0_PDI_PCP_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_PDI_PCP_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(powerlink_0_PDI_PCP_arb_counter_enable) = '1' then 
        powerlink_0_PDI_PCP_arb_share_counter <= powerlink_0_PDI_PCP_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --powerlink_0_PDI_PCP_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_PDI_PCP_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((powerlink_0_PDI_PCP_master_qreq_vector AND end_xfer_arb_share_counter_term_powerlink_0_PDI_PCP)) OR ((end_xfer_arb_share_counter_term_powerlink_0_PDI_PCP AND NOT powerlink_0_PDI_PCP_non_bursting_master_requests)))) = '1' then 
        powerlink_0_PDI_PCP_slavearbiterlockenable <= or_reduce(powerlink_0_PDI_PCP_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --pcp_cpu/data_master powerlink_0/PDI_PCP arbiterlock, which is an e_assign
  pcp_cpu_data_master_arbiterlock <= powerlink_0_PDI_PCP_slavearbiterlockenable AND pcp_cpu_data_master_continuerequest;
  --powerlink_0_PDI_PCP_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  powerlink_0_PDI_PCP_slavearbiterlockenable2 <= or_reduce(powerlink_0_PDI_PCP_arb_share_counter_next_value);
  --pcp_cpu/data_master powerlink_0/PDI_PCP arbiterlock2, which is an e_assign
  pcp_cpu_data_master_arbiterlock2 <= powerlink_0_PDI_PCP_slavearbiterlockenable2 AND pcp_cpu_data_master_continuerequest;
  --powerlink_0_PDI_PCP_any_continuerequest at least one master continues requesting, which is an e_assign
  powerlink_0_PDI_PCP_any_continuerequest <= std_logic'('1');
  --pcp_cpu_data_master_continuerequest continued request, which is an e_assign
  pcp_cpu_data_master_continuerequest <= std_logic'('1');
  internal_pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP <= internal_pcp_cpu_data_master_requests_powerlink_0_PDI_PCP AND NOT (((NOT pcp_cpu_data_master_waitrequest) AND pcp_cpu_data_master_write));
  --powerlink_0_PDI_PCP_writedata mux, which is an e_mux
  powerlink_0_PDI_PCP_writedata <= pcp_cpu_data_master_writedata;
  --master is always granted when requested
  internal_pcp_cpu_data_master_granted_powerlink_0_PDI_PCP <= internal_pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP;
  --pcp_cpu/data_master saved-grant powerlink_0/PDI_PCP, which is an e_assign
  pcp_cpu_data_master_saved_grant_powerlink_0_PDI_PCP <= internal_pcp_cpu_data_master_requests_powerlink_0_PDI_PCP;
  --allow new arb cycle for powerlink_0/PDI_PCP, which is an e_assign
  powerlink_0_PDI_PCP_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  powerlink_0_PDI_PCP_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  powerlink_0_PDI_PCP_master_qreq_vector <= std_logic'('1');
  powerlink_0_PDI_PCP_chipselect <= internal_pcp_cpu_data_master_granted_powerlink_0_PDI_PCP;
  --powerlink_0_PDI_PCP_firsttransfer first transaction, which is an e_assign
  powerlink_0_PDI_PCP_firsttransfer <= A_WE_StdLogic((std_logic'(powerlink_0_PDI_PCP_begins_xfer) = '1'), powerlink_0_PDI_PCP_unreg_firsttransfer, powerlink_0_PDI_PCP_reg_firsttransfer);
  --powerlink_0_PDI_PCP_unreg_firsttransfer first transaction, which is an e_assign
  powerlink_0_PDI_PCP_unreg_firsttransfer <= NOT ((powerlink_0_PDI_PCP_slavearbiterlockenable AND powerlink_0_PDI_PCP_any_continuerequest));
  --powerlink_0_PDI_PCP_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_PDI_PCP_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(powerlink_0_PDI_PCP_begins_xfer) = '1' then 
        powerlink_0_PDI_PCP_reg_firsttransfer <= powerlink_0_PDI_PCP_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --powerlink_0_PDI_PCP_beginbursttransfer_internal begin burst transfer, which is an e_assign
  powerlink_0_PDI_PCP_beginbursttransfer_internal <= powerlink_0_PDI_PCP_begins_xfer;
  --powerlink_0_PDI_PCP_read assignment, which is an e_mux
  powerlink_0_PDI_PCP_read <= internal_pcp_cpu_data_master_granted_powerlink_0_PDI_PCP AND pcp_cpu_data_master_read;
  --powerlink_0_PDI_PCP_write assignment, which is an e_mux
  powerlink_0_PDI_PCP_write <= internal_pcp_cpu_data_master_granted_powerlink_0_PDI_PCP AND pcp_cpu_data_master_write;
  shifted_address_to_powerlink_0_PDI_PCP_from_pcp_cpu_data_master <= pcp_cpu_data_master_address_to_slave;
  --powerlink_0_PDI_PCP_address mux, which is an e_mux
  powerlink_0_PDI_PCP_address <= A_EXT (A_SRL(shifted_address_to_powerlink_0_PDI_PCP_from_pcp_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 13);
  --d1_powerlink_0_PDI_PCP_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_powerlink_0_PDI_PCP_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_powerlink_0_PDI_PCP_end_xfer <= powerlink_0_PDI_PCP_end_xfer;
    end if;

  end process;

  --powerlink_0_PDI_PCP_waits_for_read in a cycle, which is an e_mux
  powerlink_0_PDI_PCP_waits_for_read <= powerlink_0_PDI_PCP_in_a_read_cycle AND wait_for_powerlink_0_PDI_PCP_counter;
  --powerlink_0_PDI_PCP_in_a_read_cycle assignment, which is an e_assign
  powerlink_0_PDI_PCP_in_a_read_cycle <= internal_pcp_cpu_data_master_granted_powerlink_0_PDI_PCP AND pcp_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= powerlink_0_PDI_PCP_in_a_read_cycle;
  --powerlink_0_PDI_PCP_waits_for_write in a cycle, which is an e_mux
  powerlink_0_PDI_PCP_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(powerlink_0_PDI_PCP_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --powerlink_0_PDI_PCP_in_a_write_cycle assignment, which is an e_assign
  powerlink_0_PDI_PCP_in_a_write_cycle <= internal_pcp_cpu_data_master_granted_powerlink_0_PDI_PCP AND pcp_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= powerlink_0_PDI_PCP_in_a_write_cycle;
  internal_powerlink_0_PDI_PCP_wait_counter_eq_0 <= to_std_logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(powerlink_0_PDI_PCP_wait_counter))) = std_logic_vector'("00000000000000000000000000000000")));
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      powerlink_0_PDI_PCP_wait_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      powerlink_0_PDI_PCP_wait_counter <= powerlink_0_PDI_PCP_counter_load_value;
    end if;

  end process;

  powerlink_0_PDI_PCP_counter_load_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(((powerlink_0_PDI_PCP_in_a_read_cycle AND powerlink_0_PDI_PCP_begins_xfer))) = '1'), std_logic_vector'("000000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'((NOT internal_powerlink_0_PDI_PCP_wait_counter_eq_0)) = '1'), ((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(powerlink_0_PDI_PCP_wait_counter))) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))));
  wait_for_powerlink_0_PDI_PCP_counter <= powerlink_0_PDI_PCP_begins_xfer OR NOT internal_powerlink_0_PDI_PCP_wait_counter_eq_0;
  --powerlink_0_PDI_PCP_byteenable byte enable port mux, which is an e_mux
  powerlink_0_PDI_PCP_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_powerlink_0_PDI_PCP)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (pcp_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  pcp_cpu_data_master_granted_powerlink_0_PDI_PCP <= internal_pcp_cpu_data_master_granted_powerlink_0_PDI_PCP;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP <= internal_pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_requests_powerlink_0_PDI_PCP <= internal_pcp_cpu_data_master_requests_powerlink_0_PDI_PCP;
  --vhdl renameroo for output signals
  powerlink_0_PDI_PCP_wait_counter_eq_0 <= internal_powerlink_0_PDI_PCP_wait_counter_eq_0;
--synthesis translate_off
    --powerlink_0/PDI_PCP enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity remote_update_cycloneiii_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal remote_update_cycloneiii_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal remote_update_cycloneiii_0_s1_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_remote_update_cycloneiii_0_s1_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                 signal remote_update_cycloneiii_0_s1_address : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal remote_update_cycloneiii_0_s1_chipselect : OUT STD_LOGIC;
                 signal remote_update_cycloneiii_0_s1_read : OUT STD_LOGIC;
                 signal remote_update_cycloneiii_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal remote_update_cycloneiii_0_s1_reset : OUT STD_LOGIC;
                 signal remote_update_cycloneiii_0_s1_waitrequest_from_sa : OUT STD_LOGIC;
                 signal remote_update_cycloneiii_0_s1_write : OUT STD_LOGIC;
                 signal remote_update_cycloneiii_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity remote_update_cycloneiii_0_s1_arbitrator;


architecture europa of remote_update_cycloneiii_0_s1_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal internal_remote_update_cycloneiii_0_s1_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_arbiterlock :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_arbiterlock2 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register_in :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_saved_grant_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal p1_niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal remote_update_cycloneiii_0_s1_allgrants :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_any_continuerequest :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_arb_counter_enable :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_arb_share_counter :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_arb_share_set_values :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_begins_xfer :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_end_xfer :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_firsttransfer :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_grant_vector :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_master_qreq_vector :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_waits_for_read :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_remote_update_cycloneiii_0_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT remote_update_cycloneiii_0_s1_end_xfer;
    end if;

  end process;

  remote_update_cycloneiii_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1);
  --assign remote_update_cycloneiii_0_s1_readdata_from_sa = remote_update_cycloneiii_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  remote_update_cycloneiii_0_s1_readdata_from_sa <= remote_update_cycloneiii_0_s1_readdata;
  internal_niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_1_out_read OR niosII_openMac_clock_1_out_write)))))));
  --assign remote_update_cycloneiii_0_s1_waitrequest_from_sa = remote_update_cycloneiii_0_s1_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_remote_update_cycloneiii_0_s1_waitrequest_from_sa <= remote_update_cycloneiii_0_s1_waitrequest;
  --remote_update_cycloneiii_0_s1_arb_share_counter set values, which is an e_mux
  remote_update_cycloneiii_0_s1_arb_share_set_values <= std_logic'('1');
  --remote_update_cycloneiii_0_s1_non_bursting_master_requests mux, which is an e_mux
  remote_update_cycloneiii_0_s1_non_bursting_master_requests <= internal_niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1;
  --remote_update_cycloneiii_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  remote_update_cycloneiii_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --remote_update_cycloneiii_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  remote_update_cycloneiii_0_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(remote_update_cycloneiii_0_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(remote_update_cycloneiii_0_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(remote_update_cycloneiii_0_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(remote_update_cycloneiii_0_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --remote_update_cycloneiii_0_s1_allgrants all slave grants, which is an e_mux
  remote_update_cycloneiii_0_s1_allgrants <= remote_update_cycloneiii_0_s1_grant_vector;
  --remote_update_cycloneiii_0_s1_end_xfer assignment, which is an e_assign
  remote_update_cycloneiii_0_s1_end_xfer <= NOT ((remote_update_cycloneiii_0_s1_waits_for_read OR remote_update_cycloneiii_0_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_remote_update_cycloneiii_0_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_remote_update_cycloneiii_0_s1 <= remote_update_cycloneiii_0_s1_end_xfer AND (((NOT remote_update_cycloneiii_0_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --remote_update_cycloneiii_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  remote_update_cycloneiii_0_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_remote_update_cycloneiii_0_s1 AND remote_update_cycloneiii_0_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_remote_update_cycloneiii_0_s1 AND NOT remote_update_cycloneiii_0_s1_non_bursting_master_requests));
  --remote_update_cycloneiii_0_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      remote_update_cycloneiii_0_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(remote_update_cycloneiii_0_s1_arb_counter_enable) = '1' then 
        remote_update_cycloneiii_0_s1_arb_share_counter <= remote_update_cycloneiii_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --remote_update_cycloneiii_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      remote_update_cycloneiii_0_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((remote_update_cycloneiii_0_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_remote_update_cycloneiii_0_s1)) OR ((end_xfer_arb_share_counter_term_remote_update_cycloneiii_0_s1 AND NOT remote_update_cycloneiii_0_s1_non_bursting_master_requests)))) = '1' then 
        remote_update_cycloneiii_0_s1_slavearbiterlockenable <= remote_update_cycloneiii_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_1/out remote_update_cycloneiii_0/s1 arbiterlock, which is an e_assign
  niosII_openMac_clock_1_out_arbiterlock <= remote_update_cycloneiii_0_s1_slavearbiterlockenable AND niosII_openMac_clock_1_out_continuerequest;
  --remote_update_cycloneiii_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  remote_update_cycloneiii_0_s1_slavearbiterlockenable2 <= remote_update_cycloneiii_0_s1_arb_share_counter_next_value;
  --niosII_openMac_clock_1/out remote_update_cycloneiii_0/s1 arbiterlock2, which is an e_assign
  niosII_openMac_clock_1_out_arbiterlock2 <= remote_update_cycloneiii_0_s1_slavearbiterlockenable2 AND niosII_openMac_clock_1_out_continuerequest;
  --remote_update_cycloneiii_0_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  remote_update_cycloneiii_0_s1_any_continuerequest <= std_logic'('1');
  --niosII_openMac_clock_1_out_continuerequest continued request, which is an e_assign
  niosII_openMac_clock_1_out_continuerequest <= std_logic'('1');
  internal_niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1 <= internal_niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1 AND NOT ((niosII_openMac_clock_1_out_read AND (or_reduce(niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register))));
  --niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register_in <= ((internal_niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 AND niosII_openMac_clock_1_out_read) AND NOT remote_update_cycloneiii_0_s1_waits_for_read) AND NOT (or_reduce(niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register));
  --shift register p1 niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register <= A_EXT ((niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register & A_ToStdLogicVector(niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register_in)), 2);
  --niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register <= p1_niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register;
    end if;

  end process;

  --local readdatavalid niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1, which is an e_mux
  niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1 <= niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register(1);
  --remote_update_cycloneiii_0_s1_writedata mux, which is an e_mux
  remote_update_cycloneiii_0_s1_writedata <= niosII_openMac_clock_1_out_writedata;
  --master is always granted when requested
  internal_niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 <= internal_niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1;
  --niosII_openMac_clock_1/out saved-grant remote_update_cycloneiii_0/s1, which is an e_assign
  niosII_openMac_clock_1_out_saved_grant_remote_update_cycloneiii_0_s1 <= internal_niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1;
  --allow new arb cycle for remote_update_cycloneiii_0/s1, which is an e_assign
  remote_update_cycloneiii_0_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  remote_update_cycloneiii_0_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  remote_update_cycloneiii_0_s1_master_qreq_vector <= std_logic'('1');
  --~remote_update_cycloneiii_0_s1_reset assignment, which is an e_assign
  remote_update_cycloneiii_0_s1_reset <= NOT reset_n;
  remote_update_cycloneiii_0_s1_chipselect <= internal_niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1;
  --remote_update_cycloneiii_0_s1_firsttransfer first transaction, which is an e_assign
  remote_update_cycloneiii_0_s1_firsttransfer <= A_WE_StdLogic((std_logic'(remote_update_cycloneiii_0_s1_begins_xfer) = '1'), remote_update_cycloneiii_0_s1_unreg_firsttransfer, remote_update_cycloneiii_0_s1_reg_firsttransfer);
  --remote_update_cycloneiii_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  remote_update_cycloneiii_0_s1_unreg_firsttransfer <= NOT ((remote_update_cycloneiii_0_s1_slavearbiterlockenable AND remote_update_cycloneiii_0_s1_any_continuerequest));
  --remote_update_cycloneiii_0_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      remote_update_cycloneiii_0_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(remote_update_cycloneiii_0_s1_begins_xfer) = '1' then 
        remote_update_cycloneiii_0_s1_reg_firsttransfer <= remote_update_cycloneiii_0_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --remote_update_cycloneiii_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  remote_update_cycloneiii_0_s1_beginbursttransfer_internal <= remote_update_cycloneiii_0_s1_begins_xfer;
  --remote_update_cycloneiii_0_s1_read assignment, which is an e_mux
  remote_update_cycloneiii_0_s1_read <= internal_niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 AND niosII_openMac_clock_1_out_read;
  --remote_update_cycloneiii_0_s1_write assignment, which is an e_mux
  remote_update_cycloneiii_0_s1_write <= internal_niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 AND niosII_openMac_clock_1_out_write;
  --remote_update_cycloneiii_0_s1_address mux, which is an e_mux
  remote_update_cycloneiii_0_s1_address <= niosII_openMac_clock_1_out_nativeaddress;
  --d1_remote_update_cycloneiii_0_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_remote_update_cycloneiii_0_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_remote_update_cycloneiii_0_s1_end_xfer <= remote_update_cycloneiii_0_s1_end_xfer;
    end if;

  end process;

  --remote_update_cycloneiii_0_s1_waits_for_read in a cycle, which is an e_mux
  remote_update_cycloneiii_0_s1_waits_for_read <= remote_update_cycloneiii_0_s1_in_a_read_cycle AND internal_remote_update_cycloneiii_0_s1_waitrequest_from_sa;
  --remote_update_cycloneiii_0_s1_in_a_read_cycle assignment, which is an e_assign
  remote_update_cycloneiii_0_s1_in_a_read_cycle <= internal_niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 AND niosII_openMac_clock_1_out_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= remote_update_cycloneiii_0_s1_in_a_read_cycle;
  --remote_update_cycloneiii_0_s1_waits_for_write in a cycle, which is an e_mux
  remote_update_cycloneiii_0_s1_waits_for_write <= remote_update_cycloneiii_0_s1_in_a_write_cycle AND internal_remote_update_cycloneiii_0_s1_waitrequest_from_sa;
  --remote_update_cycloneiii_0_s1_in_a_write_cycle assignment, which is an e_assign
  remote_update_cycloneiii_0_s1_in_a_write_cycle <= internal_niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 AND niosII_openMac_clock_1_out_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= remote_update_cycloneiii_0_s1_in_a_write_cycle;
  wait_for_remote_update_cycloneiii_0_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 <= internal_niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1 <= internal_niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1 <= internal_niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1;
  --vhdl renameroo for output signals
  remote_update_cycloneiii_0_s1_waitrequest_from_sa <= internal_remote_update_cycloneiii_0_s1_waitrequest_from_sa;
--synthesis translate_off
    --remote_update_cycloneiii_0/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity status_led_pio_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal status_led_pio_s1_readdata : IN STD_LOGIC_VECTOR (1 DOWNTO 0);

              -- outputs:
                 signal clock_crossing_0_m1_granted_status_led_pio_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_status_led_pio_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_status_led_pio_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_status_led_pio_s1 : OUT STD_LOGIC;
                 signal d1_status_led_pio_s1_end_xfer : OUT STD_LOGIC;
                 signal status_led_pio_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal status_led_pio_s1_chipselect : OUT STD_LOGIC;
                 signal status_led_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal status_led_pio_s1_reset_n : OUT STD_LOGIC;
                 signal status_led_pio_s1_write_n : OUT STD_LOGIC;
                 signal status_led_pio_s1_writedata : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
              );
end entity status_led_pio_s1_arbitrator;


architecture europa of status_led_pio_s1_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_status_led_pio_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_status_led_pio_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_granted_status_led_pio_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_status_led_pio_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_status_led_pio_s1 :  STD_LOGIC;
                signal status_led_pio_s1_allgrants :  STD_LOGIC;
                signal status_led_pio_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal status_led_pio_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal status_led_pio_s1_any_continuerequest :  STD_LOGIC;
                signal status_led_pio_s1_arb_counter_enable :  STD_LOGIC;
                signal status_led_pio_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal status_led_pio_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal status_led_pio_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal status_led_pio_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal status_led_pio_s1_begins_xfer :  STD_LOGIC;
                signal status_led_pio_s1_end_xfer :  STD_LOGIC;
                signal status_led_pio_s1_firsttransfer :  STD_LOGIC;
                signal status_led_pio_s1_grant_vector :  STD_LOGIC;
                signal status_led_pio_s1_in_a_read_cycle :  STD_LOGIC;
                signal status_led_pio_s1_in_a_write_cycle :  STD_LOGIC;
                signal status_led_pio_s1_master_qreq_vector :  STD_LOGIC;
                signal status_led_pio_s1_non_bursting_master_requests :  STD_LOGIC;
                signal status_led_pio_s1_reg_firsttransfer :  STD_LOGIC;
                signal status_led_pio_s1_slavearbiterlockenable :  STD_LOGIC;
                signal status_led_pio_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal status_led_pio_s1_unreg_firsttransfer :  STD_LOGIC;
                signal status_led_pio_s1_waits_for_read :  STD_LOGIC;
                signal status_led_pio_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_status_led_pio_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT status_led_pio_s1_end_xfer;
    end if;

  end process;

  status_led_pio_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_status_led_pio_s1);
  --assign status_led_pio_s1_readdata_from_sa = status_led_pio_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  status_led_pio_s1_readdata_from_sa <= status_led_pio_s1_readdata;
  internal_clock_crossing_0_m1_requests_status_led_pio_s1 <= to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(13 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("10000000100000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write));
  --status_led_pio_s1_arb_share_counter set values, which is an e_mux
  status_led_pio_s1_arb_share_set_values <= std_logic_vector'("01");
  --status_led_pio_s1_non_bursting_master_requests mux, which is an e_mux
  status_led_pio_s1_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_status_led_pio_s1;
  --status_led_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  status_led_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --status_led_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  status_led_pio_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(status_led_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (status_led_pio_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(status_led_pio_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (status_led_pio_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --status_led_pio_s1_allgrants all slave grants, which is an e_mux
  status_led_pio_s1_allgrants <= status_led_pio_s1_grant_vector;
  --status_led_pio_s1_end_xfer assignment, which is an e_assign
  status_led_pio_s1_end_xfer <= NOT ((status_led_pio_s1_waits_for_read OR status_led_pio_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_status_led_pio_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_status_led_pio_s1 <= status_led_pio_s1_end_xfer AND (((NOT status_led_pio_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --status_led_pio_s1_arb_share_counter arbitration counter enable, which is an e_assign
  status_led_pio_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_status_led_pio_s1 AND status_led_pio_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_status_led_pio_s1 AND NOT status_led_pio_s1_non_bursting_master_requests));
  --status_led_pio_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      status_led_pio_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(status_led_pio_s1_arb_counter_enable) = '1' then 
        status_led_pio_s1_arb_share_counter <= status_led_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --status_led_pio_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      status_led_pio_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((status_led_pio_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_status_led_pio_s1)) OR ((end_xfer_arb_share_counter_term_status_led_pio_s1 AND NOT status_led_pio_s1_non_bursting_master_requests)))) = '1' then 
        status_led_pio_s1_slavearbiterlockenable <= or_reduce(status_led_pio_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 status_led_pio/s1 arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= status_led_pio_s1_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --status_led_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  status_led_pio_s1_slavearbiterlockenable2 <= or_reduce(status_led_pio_s1_arb_share_counter_next_value);
  --clock_crossing_0/m1 status_led_pio/s1 arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= status_led_pio_s1_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --status_led_pio_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  status_led_pio_s1_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_status_led_pio_s1 <= internal_clock_crossing_0_m1_requests_status_led_pio_s1 AND NOT ((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_status_led_pio_s1, which is an e_mux
  clock_crossing_0_m1_read_data_valid_status_led_pio_s1 <= (internal_clock_crossing_0_m1_granted_status_led_pio_s1 AND clock_crossing_0_m1_read) AND NOT status_led_pio_s1_waits_for_read;
  --status_led_pio_s1_writedata mux, which is an e_mux
  status_led_pio_s1_writedata <= clock_crossing_0_m1_writedata (1 DOWNTO 0);
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_status_led_pio_s1 <= internal_clock_crossing_0_m1_qualified_request_status_led_pio_s1;
  --clock_crossing_0/m1 saved-grant status_led_pio/s1, which is an e_assign
  clock_crossing_0_m1_saved_grant_status_led_pio_s1 <= internal_clock_crossing_0_m1_requests_status_led_pio_s1;
  --allow new arb cycle for status_led_pio/s1, which is an e_assign
  status_led_pio_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  status_led_pio_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  status_led_pio_s1_master_qreq_vector <= std_logic'('1');
  --status_led_pio_s1_reset_n assignment, which is an e_assign
  status_led_pio_s1_reset_n <= reset_n;
  status_led_pio_s1_chipselect <= internal_clock_crossing_0_m1_granted_status_led_pio_s1;
  --status_led_pio_s1_firsttransfer first transaction, which is an e_assign
  status_led_pio_s1_firsttransfer <= A_WE_StdLogic((std_logic'(status_led_pio_s1_begins_xfer) = '1'), status_led_pio_s1_unreg_firsttransfer, status_led_pio_s1_reg_firsttransfer);
  --status_led_pio_s1_unreg_firsttransfer first transaction, which is an e_assign
  status_led_pio_s1_unreg_firsttransfer <= NOT ((status_led_pio_s1_slavearbiterlockenable AND status_led_pio_s1_any_continuerequest));
  --status_led_pio_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      status_led_pio_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(status_led_pio_s1_begins_xfer) = '1' then 
        status_led_pio_s1_reg_firsttransfer <= status_led_pio_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --status_led_pio_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  status_led_pio_s1_beginbursttransfer_internal <= status_led_pio_s1_begins_xfer;
  --~status_led_pio_s1_write_n assignment, which is an e_mux
  status_led_pio_s1_write_n <= NOT ((internal_clock_crossing_0_m1_granted_status_led_pio_s1 AND clock_crossing_0_m1_write));
  --status_led_pio_s1_address mux, which is an e_mux
  status_led_pio_s1_address <= clock_crossing_0_m1_nativeaddress (2 DOWNTO 0);
  --d1_status_led_pio_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_status_led_pio_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_status_led_pio_s1_end_xfer <= status_led_pio_s1_end_xfer;
    end if;

  end process;

  --status_led_pio_s1_waits_for_read in a cycle, which is an e_mux
  status_led_pio_s1_waits_for_read <= status_led_pio_s1_in_a_read_cycle AND status_led_pio_s1_begins_xfer;
  --status_led_pio_s1_in_a_read_cycle assignment, which is an e_assign
  status_led_pio_s1_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_status_led_pio_s1 AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= status_led_pio_s1_in_a_read_cycle;
  --status_led_pio_s1_waits_for_write in a cycle, which is an e_mux
  status_led_pio_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(status_led_pio_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --status_led_pio_s1_in_a_write_cycle assignment, which is an e_assign
  status_led_pio_s1_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_status_led_pio_s1 AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= status_led_pio_s1_in_a_write_cycle;
  wait_for_status_led_pio_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_status_led_pio_s1 <= internal_clock_crossing_0_m1_granted_status_led_pio_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_status_led_pio_s1 <= internal_clock_crossing_0_m1_qualified_request_status_led_pio_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_status_led_pio_s1 <= internal_clock_crossing_0_m1_requests_status_led_pio_s1;
--synthesis translate_off
    --status_led_pio/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sysid_control_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal pcp_cpu_data_master_read : IN STD_LOGIC;
                 signal pcp_cpu_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- outputs:
                 signal d1_sysid_control_slave_end_xfer : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_granted_sysid_control_slave : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_requests_sysid_control_slave : OUT STD_LOGIC;
                 signal sysid_control_slave_address : OUT STD_LOGIC;
                 signal sysid_control_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal sysid_control_slave_reset_n : OUT STD_LOGIC
              );
end entity sysid_control_slave_arbitrator;


architecture europa of sysid_control_slave_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_sysid_control_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_granted_sysid_control_slave :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_requests_sysid_control_slave :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_data_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_data_master_saved_grant_sysid_control_slave :  STD_LOGIC;
                signal shifted_address_to_sysid_control_slave_from_pcp_cpu_data_master :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal sysid_control_slave_allgrants :  STD_LOGIC;
                signal sysid_control_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal sysid_control_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal sysid_control_slave_any_continuerequest :  STD_LOGIC;
                signal sysid_control_slave_arb_counter_enable :  STD_LOGIC;
                signal sysid_control_slave_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sysid_control_slave_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sysid_control_slave_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sysid_control_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal sysid_control_slave_begins_xfer :  STD_LOGIC;
                signal sysid_control_slave_end_xfer :  STD_LOGIC;
                signal sysid_control_slave_firsttransfer :  STD_LOGIC;
                signal sysid_control_slave_grant_vector :  STD_LOGIC;
                signal sysid_control_slave_in_a_read_cycle :  STD_LOGIC;
                signal sysid_control_slave_in_a_write_cycle :  STD_LOGIC;
                signal sysid_control_slave_master_qreq_vector :  STD_LOGIC;
                signal sysid_control_slave_non_bursting_master_requests :  STD_LOGIC;
                signal sysid_control_slave_reg_firsttransfer :  STD_LOGIC;
                signal sysid_control_slave_slavearbiterlockenable :  STD_LOGIC;
                signal sysid_control_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal sysid_control_slave_unreg_firsttransfer :  STD_LOGIC;
                signal sysid_control_slave_waits_for_read :  STD_LOGIC;
                signal sysid_control_slave_waits_for_write :  STD_LOGIC;
                signal wait_for_sysid_control_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT sysid_control_slave_end_xfer;
    end if;

  end process;

  sysid_control_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_pcp_cpu_data_master_qualified_request_sysid_control_slave);
  --assign sysid_control_slave_readdata_from_sa = sysid_control_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  sysid_control_slave_readdata_from_sa <= sysid_control_slave_readdata;
  internal_pcp_cpu_data_master_requests_sysid_control_slave <= ((to_std_logic(((Std_Logic_Vector'(pcp_cpu_data_master_address_to_slave(24 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("0000000000000100100010000")))) AND ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write)))) AND pcp_cpu_data_master_read;
  --sysid_control_slave_arb_share_counter set values, which is an e_mux
  sysid_control_slave_arb_share_set_values <= std_logic_vector'("01");
  --sysid_control_slave_non_bursting_master_requests mux, which is an e_mux
  sysid_control_slave_non_bursting_master_requests <= internal_pcp_cpu_data_master_requests_sysid_control_slave;
  --sysid_control_slave_any_bursting_master_saved_grant mux, which is an e_mux
  sysid_control_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --sysid_control_slave_arb_share_counter_next_value assignment, which is an e_assign
  sysid_control_slave_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(sysid_control_slave_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (sysid_control_slave_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(sysid_control_slave_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (sysid_control_slave_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --sysid_control_slave_allgrants all slave grants, which is an e_mux
  sysid_control_slave_allgrants <= sysid_control_slave_grant_vector;
  --sysid_control_slave_end_xfer assignment, which is an e_assign
  sysid_control_slave_end_xfer <= NOT ((sysid_control_slave_waits_for_read OR sysid_control_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_sysid_control_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_sysid_control_slave <= sysid_control_slave_end_xfer AND (((NOT sysid_control_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --sysid_control_slave_arb_share_counter arbitration counter enable, which is an e_assign
  sysid_control_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_sysid_control_slave AND sysid_control_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_sysid_control_slave AND NOT sysid_control_slave_non_bursting_master_requests));
  --sysid_control_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sysid_control_slave_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(sysid_control_slave_arb_counter_enable) = '1' then 
        sysid_control_slave_arb_share_counter <= sysid_control_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --sysid_control_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sysid_control_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((sysid_control_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_sysid_control_slave)) OR ((end_xfer_arb_share_counter_term_sysid_control_slave AND NOT sysid_control_slave_non_bursting_master_requests)))) = '1' then 
        sysid_control_slave_slavearbiterlockenable <= or_reduce(sysid_control_slave_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --pcp_cpu/data_master sysid/control_slave arbiterlock, which is an e_assign
  pcp_cpu_data_master_arbiterlock <= sysid_control_slave_slavearbiterlockenable AND pcp_cpu_data_master_continuerequest;
  --sysid_control_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  sysid_control_slave_slavearbiterlockenable2 <= or_reduce(sysid_control_slave_arb_share_counter_next_value);
  --pcp_cpu/data_master sysid/control_slave arbiterlock2, which is an e_assign
  pcp_cpu_data_master_arbiterlock2 <= sysid_control_slave_slavearbiterlockenable2 AND pcp_cpu_data_master_continuerequest;
  --sysid_control_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  sysid_control_slave_any_continuerequest <= std_logic'('1');
  --pcp_cpu_data_master_continuerequest continued request, which is an e_assign
  pcp_cpu_data_master_continuerequest <= std_logic'('1');
  internal_pcp_cpu_data_master_qualified_request_sysid_control_slave <= internal_pcp_cpu_data_master_requests_sysid_control_slave;
  --master is always granted when requested
  internal_pcp_cpu_data_master_granted_sysid_control_slave <= internal_pcp_cpu_data_master_qualified_request_sysid_control_slave;
  --pcp_cpu/data_master saved-grant sysid/control_slave, which is an e_assign
  pcp_cpu_data_master_saved_grant_sysid_control_slave <= internal_pcp_cpu_data_master_requests_sysid_control_slave;
  --allow new arb cycle for sysid/control_slave, which is an e_assign
  sysid_control_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  sysid_control_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  sysid_control_slave_master_qreq_vector <= std_logic'('1');
  --sysid_control_slave_reset_n assignment, which is an e_assign
  sysid_control_slave_reset_n <= reset_n;
  --sysid_control_slave_firsttransfer first transaction, which is an e_assign
  sysid_control_slave_firsttransfer <= A_WE_StdLogic((std_logic'(sysid_control_slave_begins_xfer) = '1'), sysid_control_slave_unreg_firsttransfer, sysid_control_slave_reg_firsttransfer);
  --sysid_control_slave_unreg_firsttransfer first transaction, which is an e_assign
  sysid_control_slave_unreg_firsttransfer <= NOT ((sysid_control_slave_slavearbiterlockenable AND sysid_control_slave_any_continuerequest));
  --sysid_control_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sysid_control_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(sysid_control_slave_begins_xfer) = '1' then 
        sysid_control_slave_reg_firsttransfer <= sysid_control_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --sysid_control_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  sysid_control_slave_beginbursttransfer_internal <= sysid_control_slave_begins_xfer;
  shifted_address_to_sysid_control_slave_from_pcp_cpu_data_master <= pcp_cpu_data_master_address_to_slave;
  --sysid_control_slave_address mux, which is an e_mux
  sysid_control_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_sysid_control_slave_from_pcp_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")));
  --d1_sysid_control_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_sysid_control_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_sysid_control_slave_end_xfer <= sysid_control_slave_end_xfer;
    end if;

  end process;

  --sysid_control_slave_waits_for_read in a cycle, which is an e_mux
  sysid_control_slave_waits_for_read <= sysid_control_slave_in_a_read_cycle AND sysid_control_slave_begins_xfer;
  --sysid_control_slave_in_a_read_cycle assignment, which is an e_assign
  sysid_control_slave_in_a_read_cycle <= internal_pcp_cpu_data_master_granted_sysid_control_slave AND pcp_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= sysid_control_slave_in_a_read_cycle;
  --sysid_control_slave_waits_for_write in a cycle, which is an e_mux
  sysid_control_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sysid_control_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --sysid_control_slave_in_a_write_cycle assignment, which is an e_assign
  sysid_control_slave_in_a_write_cycle <= internal_pcp_cpu_data_master_granted_sysid_control_slave AND pcp_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= sysid_control_slave_in_a_write_cycle;
  wait_for_sysid_control_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  pcp_cpu_data_master_granted_sysid_control_slave <= internal_pcp_cpu_data_master_granted_sysid_control_slave;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_qualified_request_sysid_control_slave <= internal_pcp_cpu_data_master_qualified_request_sysid_control_slave;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_requests_sysid_control_slave <= internal_pcp_cpu_data_master_requests_sysid_control_slave;
--synthesis translate_off
    --sysid/control_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity system_timer_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal system_timer_s1_irq : IN STD_LOGIC;
                 signal system_timer_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal clock_crossing_0_m1_granted_system_timer_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_system_timer_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_system_timer_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_system_timer_s1 : OUT STD_LOGIC;
                 signal d1_system_timer_s1_end_xfer : OUT STD_LOGIC;
                 signal system_timer_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal system_timer_s1_chipselect : OUT STD_LOGIC;
                 signal system_timer_s1_irq_from_sa : OUT STD_LOGIC;
                 signal system_timer_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal system_timer_s1_reset_n : OUT STD_LOGIC;
                 signal system_timer_s1_write_n : OUT STD_LOGIC;
                 signal system_timer_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity system_timer_s1_arbitrator;


architecture europa of system_timer_s1_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_system_timer_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_system_timer_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_granted_system_timer_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_system_timer_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_system_timer_s1 :  STD_LOGIC;
                signal system_timer_s1_allgrants :  STD_LOGIC;
                signal system_timer_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal system_timer_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal system_timer_s1_any_continuerequest :  STD_LOGIC;
                signal system_timer_s1_arb_counter_enable :  STD_LOGIC;
                signal system_timer_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal system_timer_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal system_timer_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal system_timer_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal system_timer_s1_begins_xfer :  STD_LOGIC;
                signal system_timer_s1_end_xfer :  STD_LOGIC;
                signal system_timer_s1_firsttransfer :  STD_LOGIC;
                signal system_timer_s1_grant_vector :  STD_LOGIC;
                signal system_timer_s1_in_a_read_cycle :  STD_LOGIC;
                signal system_timer_s1_in_a_write_cycle :  STD_LOGIC;
                signal system_timer_s1_master_qreq_vector :  STD_LOGIC;
                signal system_timer_s1_non_bursting_master_requests :  STD_LOGIC;
                signal system_timer_s1_reg_firsttransfer :  STD_LOGIC;
                signal system_timer_s1_slavearbiterlockenable :  STD_LOGIC;
                signal system_timer_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal system_timer_s1_unreg_firsttransfer :  STD_LOGIC;
                signal system_timer_s1_waits_for_read :  STD_LOGIC;
                signal system_timer_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_system_timer_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT system_timer_s1_end_xfer;
    end if;

  end process;

  system_timer_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_system_timer_s1);
  --assign system_timer_s1_readdata_from_sa = system_timer_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  system_timer_s1_readdata_from_sa <= system_timer_s1_readdata;
  internal_clock_crossing_0_m1_requests_system_timer_s1 <= to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(13 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("10000000000000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write));
  --system_timer_s1_arb_share_counter set values, which is an e_mux
  system_timer_s1_arb_share_set_values <= std_logic_vector'("01");
  --system_timer_s1_non_bursting_master_requests mux, which is an e_mux
  system_timer_s1_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_system_timer_s1;
  --system_timer_s1_any_bursting_master_saved_grant mux, which is an e_mux
  system_timer_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --system_timer_s1_arb_share_counter_next_value assignment, which is an e_assign
  system_timer_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(system_timer_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (system_timer_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(system_timer_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (system_timer_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --system_timer_s1_allgrants all slave grants, which is an e_mux
  system_timer_s1_allgrants <= system_timer_s1_grant_vector;
  --system_timer_s1_end_xfer assignment, which is an e_assign
  system_timer_s1_end_xfer <= NOT ((system_timer_s1_waits_for_read OR system_timer_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_system_timer_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_system_timer_s1 <= system_timer_s1_end_xfer AND (((NOT system_timer_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --system_timer_s1_arb_share_counter arbitration counter enable, which is an e_assign
  system_timer_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_system_timer_s1 AND system_timer_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_system_timer_s1 AND NOT system_timer_s1_non_bursting_master_requests));
  --system_timer_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      system_timer_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(system_timer_s1_arb_counter_enable) = '1' then 
        system_timer_s1_arb_share_counter <= system_timer_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --system_timer_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      system_timer_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((system_timer_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_system_timer_s1)) OR ((end_xfer_arb_share_counter_term_system_timer_s1 AND NOT system_timer_s1_non_bursting_master_requests)))) = '1' then 
        system_timer_s1_slavearbiterlockenable <= or_reduce(system_timer_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 system_timer/s1 arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= system_timer_s1_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --system_timer_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  system_timer_s1_slavearbiterlockenable2 <= or_reduce(system_timer_s1_arb_share_counter_next_value);
  --clock_crossing_0/m1 system_timer/s1 arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= system_timer_s1_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --system_timer_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  system_timer_s1_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_system_timer_s1 <= internal_clock_crossing_0_m1_requests_system_timer_s1 AND NOT ((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_system_timer_s1, which is an e_mux
  clock_crossing_0_m1_read_data_valid_system_timer_s1 <= (internal_clock_crossing_0_m1_granted_system_timer_s1 AND clock_crossing_0_m1_read) AND NOT system_timer_s1_waits_for_read;
  --system_timer_s1_writedata mux, which is an e_mux
  system_timer_s1_writedata <= clock_crossing_0_m1_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_system_timer_s1 <= internal_clock_crossing_0_m1_qualified_request_system_timer_s1;
  --clock_crossing_0/m1 saved-grant system_timer/s1, which is an e_assign
  clock_crossing_0_m1_saved_grant_system_timer_s1 <= internal_clock_crossing_0_m1_requests_system_timer_s1;
  --allow new arb cycle for system_timer/s1, which is an e_assign
  system_timer_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  system_timer_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  system_timer_s1_master_qreq_vector <= std_logic'('1');
  --system_timer_s1_reset_n assignment, which is an e_assign
  system_timer_s1_reset_n <= reset_n;
  system_timer_s1_chipselect <= internal_clock_crossing_0_m1_granted_system_timer_s1;
  --system_timer_s1_firsttransfer first transaction, which is an e_assign
  system_timer_s1_firsttransfer <= A_WE_StdLogic((std_logic'(system_timer_s1_begins_xfer) = '1'), system_timer_s1_unreg_firsttransfer, system_timer_s1_reg_firsttransfer);
  --system_timer_s1_unreg_firsttransfer first transaction, which is an e_assign
  system_timer_s1_unreg_firsttransfer <= NOT ((system_timer_s1_slavearbiterlockenable AND system_timer_s1_any_continuerequest));
  --system_timer_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      system_timer_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(system_timer_s1_begins_xfer) = '1' then 
        system_timer_s1_reg_firsttransfer <= system_timer_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --system_timer_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  system_timer_s1_beginbursttransfer_internal <= system_timer_s1_begins_xfer;
  --~system_timer_s1_write_n assignment, which is an e_mux
  system_timer_s1_write_n <= NOT ((internal_clock_crossing_0_m1_granted_system_timer_s1 AND clock_crossing_0_m1_write));
  --system_timer_s1_address mux, which is an e_mux
  system_timer_s1_address <= clock_crossing_0_m1_nativeaddress (2 DOWNTO 0);
  --d1_system_timer_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_system_timer_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_system_timer_s1_end_xfer <= system_timer_s1_end_xfer;
    end if;

  end process;

  --system_timer_s1_waits_for_read in a cycle, which is an e_mux
  system_timer_s1_waits_for_read <= system_timer_s1_in_a_read_cycle AND system_timer_s1_begins_xfer;
  --system_timer_s1_in_a_read_cycle assignment, which is an e_assign
  system_timer_s1_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_system_timer_s1 AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= system_timer_s1_in_a_read_cycle;
  --system_timer_s1_waits_for_write in a cycle, which is an e_mux
  system_timer_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(system_timer_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --system_timer_s1_in_a_write_cycle assignment, which is an e_assign
  system_timer_s1_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_system_timer_s1 AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= system_timer_s1_in_a_write_cycle;
  wait_for_system_timer_s1_counter <= std_logic'('0');
  --assign system_timer_s1_irq_from_sa = system_timer_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  system_timer_s1_irq_from_sa <= system_timer_s1_irq;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_system_timer_s1 <= internal_clock_crossing_0_m1_granted_system_timer_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_system_timer_s1 <= internal_clock_crossing_0_m1_qualified_request_system_timer_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_system_timer_s1 <= internal_clock_crossing_0_m1_requests_system_timer_s1;
--synthesis translate_off
    --system_timer/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity tri_state_bridge_0_avalon_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal pcp_cpu_data_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pcp_cpu_data_master_dbs_write_16 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal pcp_cpu_data_master_no_byte_enables_and_last_term : IN STD_LOGIC;
                 signal pcp_cpu_data_master_read : IN STD_LOGIC;
                 signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal pcp_cpu_data_master_write : IN STD_LOGIC;
                 signal pcp_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (21 DOWNTO 0);
                 signal pcp_cpu_instruction_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pcp_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pcp_cpu_instruction_master_read : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ben_to_the_DBC3C40_SRAM_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal d1_tri_state_bridge_0_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal incoming_tri_state_bridge_0_data : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ncs_to_the_DBC3C40_SRAM_0 : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal registered_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal tri_state_bridge_0_address : OUT STD_LOGIC_VECTOR (19 DOWNTO 0);
                 signal tri_state_bridge_0_data : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal tri_state_bridge_0_readn : OUT STD_LOGIC;
                 signal tri_state_bridge_0_writen : OUT STD_LOGIC
              );
end entity tri_state_bridge_0_avalon_slave_arbitrator;


architecture europa of tri_state_bridge_0_avalon_slave_arbitrator is
                signal DBC3C40_SRAM_0_avalon_tristate_slave_in_a_read_cycle :  STD_LOGIC;
                signal DBC3C40_SRAM_0_avalon_tristate_slave_in_a_write_cycle :  STD_LOGIC;
                signal DBC3C40_SRAM_0_avalon_tristate_slave_waits_for_read :  STD_LOGIC;
                signal DBC3C40_SRAM_0_avalon_tristate_slave_waits_for_write :  STD_LOGIC;
                signal DBC3C40_SRAM_0_avalon_tristate_slave_with_write_latency :  STD_LOGIC;
                signal d1_in_a_write_cycle :  STD_LOGIC;
                signal d1_outgoing_tri_state_bridge_0_data :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal internal_pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal internal_pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal internal_pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal internal_pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal last_cycle_pcp_cpu_data_master_granted_slave_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal last_cycle_pcp_cpu_instruction_master_granted_slave_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal outgoing_tri_state_bridge_0_data :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal p1_ben_to_the_DBC3C40_SRAM_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_ncs_to_the_DBC3C40_SRAM_0 :  STD_LOGIC;
                signal p1_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_tri_state_bridge_0_address :  STD_LOGIC_VECTOR (19 DOWNTO 0);
                signal p1_tri_state_bridge_0_readn :  STD_LOGIC;
                signal p1_tri_state_bridge_0_writen :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave_segment_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave_segment_1 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_data_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register_in :  STD_LOGIC;
                signal pcp_cpu_data_master_saved_grant_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal pcp_cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal pcp_cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal pcp_cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register_in :  STD_LOGIC;
                signal pcp_cpu_instruction_master_saved_grant_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal time_to_write :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_allgrants :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_any_continuerequest :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_arb_counter_enable :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_arbitration_holdoff_internal :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_begins_xfer :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_end_xfer :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_firsttransfer :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_non_bursting_master_requests :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_read_pending :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_reg_firsttransfer :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_slavearbiterlockenable :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_unreg_firsttransfer :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_write_pending :  STD_LOGIC;
                signal wait_for_DBC3C40_SRAM_0_avalon_tristate_slave_counter :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of ben_to_the_DBC3C40_SRAM_0 : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of d1_in_a_write_cycle : signal is "FAST_OUTPUT_ENABLE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of d1_outgoing_tri_state_bridge_0_data : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of incoming_tri_state_bridge_0_data : signal is "FAST_INPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of ncs_to_the_DBC3C40_SRAM_0 : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of tri_state_bridge_0_address : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of tri_state_bridge_0_readn : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of tri_state_bridge_0_writen : signal is "FAST_OUTPUT_REGISTER=ON";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT tri_state_bridge_0_avalon_slave_end_xfer;
    end if;

  end process;

  tri_state_bridge_0_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave OR internal_pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave));
  internal_pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave <= to_std_logic(((Std_Logic_Vector'(pcp_cpu_data_master_address_to_slave(24 DOWNTO 20) & std_logic_vector'("00000000000000000000")) = std_logic_vector'("0001000000000000000000000")))) AND ((pcp_cpu_data_master_read OR pcp_cpu_data_master_write));
  --~ncs_to_the_DBC3C40_SRAM_0 of type chipselect to ~p1_ncs_to_the_DBC3C40_SRAM_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ncs_to_the_DBC3C40_SRAM_0 <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      ncs_to_the_DBC3C40_SRAM_0 <= p1_ncs_to_the_DBC3C40_SRAM_0;
    end if;

  end process;

  tri_state_bridge_0_avalon_slave_write_pending <= std_logic'('0');
  --tri_state_bridge_0/avalon_slave read pending calc, which is an e_assign
  tri_state_bridge_0_avalon_slave_read_pending <= std_logic'('0');
  --registered rdv signal_name registered_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave assignment, which is an e_assign
  registered_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave <= pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register(0);
  --tri_state_bridge_0_avalon_slave_arb_share_counter set values, which is an e_mux
  tri_state_bridge_0_avalon_slave_arb_share_set_values <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave)) = '1'), std_logic_vector'("00000000000000000000000000000010"), A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave)) = '1'), std_logic_vector'("00000000000000000000000000000010"), A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave)) = '1'), std_logic_vector'("00000000000000000000000000000010"), A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave)) = '1'), std_logic_vector'("00000000000000000000000000000010"), std_logic_vector'("00000000000000000000000000000001"))))), 2);
  --tri_state_bridge_0_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  tri_state_bridge_0_avalon_slave_non_bursting_master_requests <= ((internal_pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave OR internal_pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave) OR internal_pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave) OR internal_pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave;
  --tri_state_bridge_0_avalon_slave_any_bursting_master_saved_grant mux, which is an e_mux
  tri_state_bridge_0_avalon_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --tri_state_bridge_0_avalon_slave_arb_share_counter_next_value assignment, which is an e_assign
  tri_state_bridge_0_avalon_slave_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(tri_state_bridge_0_avalon_slave_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (tri_state_bridge_0_avalon_slave_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(tri_state_bridge_0_avalon_slave_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (tri_state_bridge_0_avalon_slave_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --tri_state_bridge_0_avalon_slave_allgrants all slave grants, which is an e_mux
  tri_state_bridge_0_avalon_slave_allgrants <= (((or_reduce(tri_state_bridge_0_avalon_slave_grant_vector)) OR (or_reduce(tri_state_bridge_0_avalon_slave_grant_vector))) OR (or_reduce(tri_state_bridge_0_avalon_slave_grant_vector))) OR (or_reduce(tri_state_bridge_0_avalon_slave_grant_vector));
  --tri_state_bridge_0_avalon_slave_end_xfer assignment, which is an e_assign
  tri_state_bridge_0_avalon_slave_end_xfer <= NOT ((DBC3C40_SRAM_0_avalon_tristate_slave_waits_for_read OR DBC3C40_SRAM_0_avalon_tristate_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave <= tri_state_bridge_0_avalon_slave_end_xfer AND (((NOT tri_state_bridge_0_avalon_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --tri_state_bridge_0_avalon_slave_arb_share_counter arbitration counter enable, which is an e_assign
  tri_state_bridge_0_avalon_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave AND tri_state_bridge_0_avalon_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave AND NOT tri_state_bridge_0_avalon_slave_non_bursting_master_requests));
  --tri_state_bridge_0_avalon_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      tri_state_bridge_0_avalon_slave_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(tri_state_bridge_0_avalon_slave_arb_counter_enable) = '1' then 
        tri_state_bridge_0_avalon_slave_arb_share_counter <= tri_state_bridge_0_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --tri_state_bridge_0_avalon_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      tri_state_bridge_0_avalon_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(tri_state_bridge_0_avalon_slave_master_qreq_vector) AND end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave)) OR ((end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave AND NOT tri_state_bridge_0_avalon_slave_non_bursting_master_requests)))) = '1' then 
        tri_state_bridge_0_avalon_slave_slavearbiterlockenable <= or_reduce(tri_state_bridge_0_avalon_slave_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --pcp_cpu/data_master tri_state_bridge_0/avalon_slave arbiterlock, which is an e_assign
  pcp_cpu_data_master_arbiterlock <= tri_state_bridge_0_avalon_slave_slavearbiterlockenable AND pcp_cpu_data_master_continuerequest;
  --tri_state_bridge_0_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  tri_state_bridge_0_avalon_slave_slavearbiterlockenable2 <= or_reduce(tri_state_bridge_0_avalon_slave_arb_share_counter_next_value);
  --pcp_cpu/data_master tri_state_bridge_0/avalon_slave arbiterlock2, which is an e_assign
  pcp_cpu_data_master_arbiterlock2 <= tri_state_bridge_0_avalon_slave_slavearbiterlockenable2 AND pcp_cpu_data_master_continuerequest;
  --pcp_cpu/instruction_master tri_state_bridge_0/avalon_slave arbiterlock, which is an e_assign
  pcp_cpu_instruction_master_arbiterlock <= tri_state_bridge_0_avalon_slave_slavearbiterlockenable AND pcp_cpu_instruction_master_continuerequest;
  --pcp_cpu/instruction_master tri_state_bridge_0/avalon_slave arbiterlock2, which is an e_assign
  pcp_cpu_instruction_master_arbiterlock2 <= tri_state_bridge_0_avalon_slave_slavearbiterlockenable2 AND pcp_cpu_instruction_master_continuerequest;
  --pcp_cpu/instruction_master granted DBC3C40_SRAM_0/avalon_tristate_slave last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_pcp_cpu_instruction_master_granted_slave_DBC3C40_SRAM_0_avalon_tristate_slave <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_pcp_cpu_instruction_master_granted_slave_DBC3C40_SRAM_0_avalon_tristate_slave <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pcp_cpu_instruction_master_saved_grant_DBC3C40_SRAM_0_avalon_tristate_slave) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((tri_state_bridge_0_avalon_slave_arbitration_holdoff_internal OR NOT internal_pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_pcp_cpu_instruction_master_granted_slave_DBC3C40_SRAM_0_avalon_tristate_slave))))));
    end if;

  end process;

  --pcp_cpu_instruction_master_continuerequest continued request, which is an e_mux
  pcp_cpu_instruction_master_continuerequest <= last_cycle_pcp_cpu_instruction_master_granted_slave_DBC3C40_SRAM_0_avalon_tristate_slave AND internal_pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave;
  --tri_state_bridge_0_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_mux
  tri_state_bridge_0_avalon_slave_any_continuerequest <= pcp_cpu_instruction_master_continuerequest OR pcp_cpu_data_master_continuerequest;
  internal_pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave <= internal_pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave AND NOT (((((pcp_cpu_data_master_read AND (((tri_state_bridge_0_avalon_slave_write_pending OR (tri_state_bridge_0_avalon_slave_read_pending)) OR (or_reduce(pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register)))))) OR ((((((NOT pcp_cpu_data_master_waitrequest OR tri_state_bridge_0_avalon_slave_read_pending) OR pcp_cpu_data_master_no_byte_enables_and_last_term) OR NOT(or_reduce(internal_pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave)))) AND pcp_cpu_data_master_write))) OR pcp_cpu_instruction_master_arbiterlock));
  --pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register_in <= ((internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave AND pcp_cpu_data_master_read) AND NOT DBC3C40_SRAM_0_avalon_tristate_slave_waits_for_read) AND NOT (or_reduce(pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register));
  --shift register p1 pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register <= A_EXT ((pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register & A_ToStdLogicVector(pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register_in)), 2);
  --pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register <= p1_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register;
    end if;

  end process;

  --local readdatavalid pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave, which is an e_mux
  pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave <= pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register(1);
  --tri_state_bridge_0_data register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      incoming_tri_state_bridge_0_data <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      incoming_tri_state_bridge_0_data <= tri_state_bridge_0_data;
    end if;

  end process;

  --DBC3C40_SRAM_0_avalon_tristate_slave_with_write_latency assignment, which is an e_assign
  DBC3C40_SRAM_0_avalon_tristate_slave_with_write_latency <= in_a_write_cycle AND ((internal_pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave OR internal_pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave));
  --time to write the data, which is an e_mux
  time_to_write <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((DBC3C40_SRAM_0_avalon_tristate_slave_with_write_latency)) = '1'), std_logic_vector'("00000000000000000000000000000001"), std_logic_vector'("00000000000000000000000000000000")));
  --d1_outgoing_tri_state_bridge_0_data register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_outgoing_tri_state_bridge_0_data <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      d1_outgoing_tri_state_bridge_0_data <= outgoing_tri_state_bridge_0_data;
    end if;

  end process;

  --write cycle delayed by 1, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_in_a_write_cycle <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_in_a_write_cycle <= time_to_write;
    end if;

  end process;

  --d1_outgoing_tri_state_bridge_0_data tristate driver, which is an e_assign
  tri_state_bridge_0_data <= A_WE_StdLogicVector((std_logic'((d1_in_a_write_cycle)) = '1'), d1_outgoing_tri_state_bridge_0_data, A_REP(std_logic'('Z'), 16));
  --outgoing_tri_state_bridge_0_data mux, which is an e_mux
  outgoing_tri_state_bridge_0_data <= pcp_cpu_data_master_dbs_write_16;
  internal_pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave <= ((to_std_logic(((Std_Logic_Vector'(pcp_cpu_instruction_master_address_to_slave(21 DOWNTO 20) & std_logic_vector'("00000000000000000000")) = std_logic_vector'("1000000000000000000000")))) AND (pcp_cpu_instruction_master_read))) AND pcp_cpu_instruction_master_read;
  --pcp_cpu/data_master granted DBC3C40_SRAM_0/avalon_tristate_slave last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_pcp_cpu_data_master_granted_slave_DBC3C40_SRAM_0_avalon_tristate_slave <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_pcp_cpu_data_master_granted_slave_DBC3C40_SRAM_0_avalon_tristate_slave <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(pcp_cpu_data_master_saved_grant_DBC3C40_SRAM_0_avalon_tristate_slave) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((tri_state_bridge_0_avalon_slave_arbitration_holdoff_internal OR NOT internal_pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_pcp_cpu_data_master_granted_slave_DBC3C40_SRAM_0_avalon_tristate_slave))))));
    end if;

  end process;

  --pcp_cpu_data_master_continuerequest continued request, which is an e_mux
  pcp_cpu_data_master_continuerequest <= last_cycle_pcp_cpu_data_master_granted_slave_DBC3C40_SRAM_0_avalon_tristate_slave AND internal_pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave;
  internal_pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave <= internal_pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave AND NOT ((((pcp_cpu_instruction_master_read AND (((tri_state_bridge_0_avalon_slave_write_pending OR (tri_state_bridge_0_avalon_slave_read_pending)) OR to_std_logic(((std_logic_vector'("00000000000000000000000000000010")<(std_logic_vector'("000000000000000000000000000000") & (pcp_cpu_instruction_master_latency_counter))))))))) OR pcp_cpu_data_master_arbiterlock));
  --pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register_in <= (internal_pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave AND pcp_cpu_instruction_master_read) AND NOT DBC3C40_SRAM_0_avalon_tristate_slave_waits_for_read;
  --shift register p1 pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register <= A_EXT ((pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register & A_ToStdLogicVector(pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register_in)), 2);
  --pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register <= p1_pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register;
    end if;

  end process;

  --local readdatavalid pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave, which is an e_mux
  pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave <= pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave_shift_register(1);
  --allow new arb cycle for tri_state_bridge_0/avalon_slave, which is an e_assign
  tri_state_bridge_0_avalon_slave_allow_new_arb_cycle <= NOT pcp_cpu_data_master_arbiterlock AND NOT pcp_cpu_instruction_master_arbiterlock;
  --pcp_cpu/instruction_master assignment into master qualified-requests vector for DBC3C40_SRAM_0/avalon_tristate_slave, which is an e_assign
  tri_state_bridge_0_avalon_slave_master_qreq_vector(0) <= internal_pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave;
  --pcp_cpu/instruction_master grant DBC3C40_SRAM_0/avalon_tristate_slave, which is an e_assign
  internal_pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave <= tri_state_bridge_0_avalon_slave_grant_vector(0);
  --pcp_cpu/instruction_master saved-grant DBC3C40_SRAM_0/avalon_tristate_slave, which is an e_assign
  pcp_cpu_instruction_master_saved_grant_DBC3C40_SRAM_0_avalon_tristate_slave <= tri_state_bridge_0_avalon_slave_arb_winner(0) AND internal_pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave;
  --pcp_cpu/data_master assignment into master qualified-requests vector for DBC3C40_SRAM_0/avalon_tristate_slave, which is an e_assign
  tri_state_bridge_0_avalon_slave_master_qreq_vector(1) <= internal_pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave;
  --pcp_cpu/data_master grant DBC3C40_SRAM_0/avalon_tristate_slave, which is an e_assign
  internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave <= tri_state_bridge_0_avalon_slave_grant_vector(1);
  --pcp_cpu/data_master saved-grant DBC3C40_SRAM_0/avalon_tristate_slave, which is an e_assign
  pcp_cpu_data_master_saved_grant_DBC3C40_SRAM_0_avalon_tristate_slave <= tri_state_bridge_0_avalon_slave_arb_winner(1) AND internal_pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave;
  --tri_state_bridge_0/avalon_slave chosen-master double-vector, which is an e_assign
  tri_state_bridge_0_avalon_slave_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((tri_state_bridge_0_avalon_slave_master_qreq_vector & tri_state_bridge_0_avalon_slave_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT tri_state_bridge_0_avalon_slave_master_qreq_vector & NOT tri_state_bridge_0_avalon_slave_master_qreq_vector))) + (std_logic_vector'("000") & (tri_state_bridge_0_avalon_slave_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  tri_state_bridge_0_avalon_slave_arb_winner <= A_WE_StdLogicVector((std_logic'(((tri_state_bridge_0_avalon_slave_allow_new_arb_cycle AND or_reduce(tri_state_bridge_0_avalon_slave_grant_vector)))) = '1'), tri_state_bridge_0_avalon_slave_grant_vector, tri_state_bridge_0_avalon_slave_saved_chosen_master_vector);
  --saved tri_state_bridge_0_avalon_slave_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      tri_state_bridge_0_avalon_slave_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(tri_state_bridge_0_avalon_slave_allow_new_arb_cycle) = '1' then 
        tri_state_bridge_0_avalon_slave_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(tri_state_bridge_0_avalon_slave_grant_vector)) = '1'), tri_state_bridge_0_avalon_slave_grant_vector, tri_state_bridge_0_avalon_slave_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  tri_state_bridge_0_avalon_slave_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((tri_state_bridge_0_avalon_slave_chosen_master_double_vector(1) OR tri_state_bridge_0_avalon_slave_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((tri_state_bridge_0_avalon_slave_chosen_master_double_vector(0) OR tri_state_bridge_0_avalon_slave_chosen_master_double_vector(2)))));
  --tri_state_bridge_0/avalon_slave chosen master rotated left, which is an e_assign
  tri_state_bridge_0_avalon_slave_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(tri_state_bridge_0_avalon_slave_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(tri_state_bridge_0_avalon_slave_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --tri_state_bridge_0/avalon_slave's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      tri_state_bridge_0_avalon_slave_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(tri_state_bridge_0_avalon_slave_grant_vector)) = '1' then 
        tri_state_bridge_0_avalon_slave_arb_addend <= A_WE_StdLogicVector((std_logic'(tri_state_bridge_0_avalon_slave_end_xfer) = '1'), tri_state_bridge_0_avalon_slave_chosen_master_rot_left, tri_state_bridge_0_avalon_slave_grant_vector);
      end if;
    end if;

  end process;

  p1_ncs_to_the_DBC3C40_SRAM_0 <= NOT ((internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave OR internal_pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave));
  --tri_state_bridge_0_avalon_slave_firsttransfer first transaction, which is an e_assign
  tri_state_bridge_0_avalon_slave_firsttransfer <= A_WE_StdLogic((std_logic'(tri_state_bridge_0_avalon_slave_begins_xfer) = '1'), tri_state_bridge_0_avalon_slave_unreg_firsttransfer, tri_state_bridge_0_avalon_slave_reg_firsttransfer);
  --tri_state_bridge_0_avalon_slave_unreg_firsttransfer first transaction, which is an e_assign
  tri_state_bridge_0_avalon_slave_unreg_firsttransfer <= NOT ((tri_state_bridge_0_avalon_slave_slavearbiterlockenable AND tri_state_bridge_0_avalon_slave_any_continuerequest));
  --tri_state_bridge_0_avalon_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      tri_state_bridge_0_avalon_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(tri_state_bridge_0_avalon_slave_begins_xfer) = '1' then 
        tri_state_bridge_0_avalon_slave_reg_firsttransfer <= tri_state_bridge_0_avalon_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --tri_state_bridge_0_avalon_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  tri_state_bridge_0_avalon_slave_beginbursttransfer_internal <= tri_state_bridge_0_avalon_slave_begins_xfer;
  --tri_state_bridge_0_avalon_slave_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  tri_state_bridge_0_avalon_slave_arbitration_holdoff_internal <= tri_state_bridge_0_avalon_slave_begins_xfer AND tri_state_bridge_0_avalon_slave_firsttransfer;
  --~tri_state_bridge_0_readn of type read to ~p1_tri_state_bridge_0_readn, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      tri_state_bridge_0_readn <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      tri_state_bridge_0_readn <= p1_tri_state_bridge_0_readn;
    end if;

  end process;

  --~p1_tri_state_bridge_0_readn assignment, which is an e_mux
  p1_tri_state_bridge_0_readn <= NOT ((((internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave AND pcp_cpu_data_master_read)) OR ((internal_pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave AND pcp_cpu_instruction_master_read))));
  --~tri_state_bridge_0_writen of type write to ~p1_tri_state_bridge_0_writen, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      tri_state_bridge_0_writen <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      tri_state_bridge_0_writen <= p1_tri_state_bridge_0_writen;
    end if;

  end process;

  --~ben_to_the_DBC3C40_SRAM_0 of type byteenable to ~p1_ben_to_the_DBC3C40_SRAM_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ben_to_the_DBC3C40_SRAM_0 <= A_EXT (NOT std_logic_vector'("00000000000000000000000000000000"), 2);
    elsif clk'event and clk = '1' then
      ben_to_the_DBC3C40_SRAM_0 <= p1_ben_to_the_DBC3C40_SRAM_0;
    end if;

  end process;

  --~p1_tri_state_bridge_0_writen assignment, which is an e_mux
  p1_tri_state_bridge_0_writen <= NOT ((internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave AND pcp_cpu_data_master_write));
  --tri_state_bridge_0_address of type address to p1_tri_state_bridge_0_address, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      tri_state_bridge_0_address <= std_logic_vector'("00000000000000000000");
    elsif clk'event and clk = '1' then
      tri_state_bridge_0_address <= p1_tri_state_bridge_0_address;
    end if;

  end process;

  --p1_tri_state_bridge_0_address mux, which is an e_mux
  p1_tri_state_bridge_0_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave)) = '1'), (Std_Logic_Vector'(A_SRL(pcp_cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")) & A_ToStdLogicVector(pcp_cpu_data_master_dbs_address(1)) & A_ToStdLogicVector(std_logic'('0')))), (std_logic_vector'("000") & ((Std_Logic_Vector'(A_SRL(pcp_cpu_instruction_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")) & A_ToStdLogicVector(pcp_cpu_instruction_master_dbs_address(1)) & A_ToStdLogicVector(std_logic'('0'))))))), 20);
  --d1_tri_state_bridge_0_avalon_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_tri_state_bridge_0_avalon_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_tri_state_bridge_0_avalon_slave_end_xfer <= tri_state_bridge_0_avalon_slave_end_xfer;
    end if;

  end process;

  --DBC3C40_SRAM_0_avalon_tristate_slave_waits_for_read in a cycle, which is an e_mux
  DBC3C40_SRAM_0_avalon_tristate_slave_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(DBC3C40_SRAM_0_avalon_tristate_slave_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --DBC3C40_SRAM_0_avalon_tristate_slave_in_a_read_cycle assignment, which is an e_assign
  DBC3C40_SRAM_0_avalon_tristate_slave_in_a_read_cycle <= ((internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave AND pcp_cpu_data_master_read)) OR ((internal_pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave AND pcp_cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= DBC3C40_SRAM_0_avalon_tristate_slave_in_a_read_cycle;
  --DBC3C40_SRAM_0_avalon_tristate_slave_waits_for_write in a cycle, which is an e_mux
  DBC3C40_SRAM_0_avalon_tristate_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(DBC3C40_SRAM_0_avalon_tristate_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --DBC3C40_SRAM_0_avalon_tristate_slave_in_a_write_cycle assignment, which is an e_assign
  DBC3C40_SRAM_0_avalon_tristate_slave_in_a_write_cycle <= internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave AND pcp_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= DBC3C40_SRAM_0_avalon_tristate_slave_in_a_write_cycle;
  wait_for_DBC3C40_SRAM_0_avalon_tristate_slave_counter <= std_logic'('0');
  --~p1_ben_to_the_DBC3C40_SRAM_0 byte enable port mux, which is an e_mux
  p1_ben_to_the_DBC3C40_SRAM_0 <= A_EXT (NOT (A_WE_StdLogicVector((std_logic'((internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave)) = '1'), (std_logic_vector'("000000000000000000000000000000") & (internal_pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave)), -SIGNED(std_logic_vector'("00000000000000000000000000000001")))), 2);
  (pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave_segment_1(1), pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave_segment_1(0), pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave_segment_0(1), pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave_segment_0(0)) <= pcp_cpu_data_master_byteenable;
  internal_pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_dbs_address(1)))) = std_logic_vector'("00000000000000000000000000000000"))), pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave_segment_0, pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave_segment_1);
  --vhdl renameroo for output signals
  pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave <= internal_pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave <= internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave <= internal_pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave <= internal_pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave <= internal_pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave <= internal_pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave <= internal_pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave;
--synthesis translate_off
    --DBC3C40_SRAM_0/avalon_tristate_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line28 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line28, now);
          write(write_line28, string'(": "));
          write(write_line28, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line28.all);
          deallocate (write_line28);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line29 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(pcp_cpu_data_master_saved_grant_DBC3C40_SRAM_0_avalon_tristate_slave))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(pcp_cpu_instruction_master_saved_grant_DBC3C40_SRAM_0_avalon_tristate_slave))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line29, now);
          write(write_line29, string'(": "));
          write(write_line29, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line29.all);
          deallocate (write_line29);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tri_state_bridge_0_bridge_arbitrator is 
end entity tri_state_bridge_0_bridge_arbitrator;


architecture europa of tri_state_bridge_0_bridge_arbitrator is

begin


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity niosII_openMac_reset_clk_0_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity niosII_openMac_reset_clk_0_domain_synch_module;


architecture europa of niosII_openMac_reset_clk_0_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_in_d1 <= data_in;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_out <= data_in_d1;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity niosII_openMac_reset_pcp_clk_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity niosII_openMac_reset_pcp_clk_domain_synch_module;


architecture europa of niosII_openMac_reset_pcp_clk_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_in_d1 <= data_in;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_out <= data_in_d1;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity niosII_openMac_reset_clk50Meg_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity niosII_openMac_reset_clk50Meg_domain_synch_module;


architecture europa of niosII_openMac_reset_clk50Meg_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_in_d1 <= data_in;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_out <= data_in_d1;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity niosII_openMac_reset_ap_clk_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity niosII_openMac_reset_ap_clk_domain_synch_module;


architecture europa of niosII_openMac_reset_ap_clk_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_in_d1 <= data_in;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_out <= data_in_d1;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity niosII_openMac_reset_clk25Meg_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity niosII_openMac_reset_clk25Meg_domain_synch_module;


architecture europa of niosII_openMac_reset_clk25Meg_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_in_d1 <= data_in;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_out <= data_in_d1;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity niosII_openMac is 
        port (
              -- 1) global signals:
                 signal ap_clk : OUT STD_LOGIC;
                 signal clk100Meg : OUT STD_LOGIC;
                 signal clk25Meg : OUT STD_LOGIC;
                 signal clk50Meg : OUT STD_LOGIC;
                 signal clk_0 : IN STD_LOGIC;
                 signal pcp_clk : OUT STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- the_altpll_0
                 signal locked_from_the_altpll_0 : OUT STD_LOGIC;
                 signal phasedone_from_the_altpll_0 : OUT STD_LOGIC;

              -- the_avalon_master_bridge_0_AvalonMaster
                 signal ap_irq_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;
                 signal avalon_address_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (14 DOWNTO 0);
                 signal avalon_byteenable_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal avalon_read_from_the_avalon_master_bridge_0 : IN STD_LOGIC;
                 signal avalon_readdata_to_the_avalon_master_bridge_0 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal avalon_readdatavalid_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;
                 signal avalon_waitrequest_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;
                 signal avalon_write_from_the_avalon_master_bridge_0 : IN STD_LOGIC;
                 signal avalon_writedata_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;

              -- the_epcs_flash_controller_0
                 signal data0_to_the_epcs_flash_controller_0 : IN STD_LOGIC;
                 signal dclk_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;
                 signal sce_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;
                 signal sdo_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;

              -- the_node_switch_pio
                 signal in_port_to_the_node_switch_pio : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_powerlink_0
                 signal phy0_MiiClk_from_the_powerlink_0 : OUT STD_LOGIC;
                 signal phy0_MiiDat_to_and_from_the_powerlink_0 : INOUT STD_LOGIC;
                 signal phy0_MiiRst_n_from_the_powerlink_0 : OUT STD_LOGIC;
                 signal phy0_RxDat_to_the_powerlink_0 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal phy0_RxDv_to_the_powerlink_0 : IN STD_LOGIC;
                 signal phy0_TxDat_from_the_powerlink_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal phy0_TxEn_from_the_powerlink_0 : OUT STD_LOGIC;
                 signal phy1_MiiClk_from_the_powerlink_0 : OUT STD_LOGIC;
                 signal phy1_MiiDat_to_and_from_the_powerlink_0 : INOUT STD_LOGIC;
                 signal phy1_MiiRst_n_from_the_powerlink_0 : OUT STD_LOGIC;
                 signal phy1_RxDat_to_the_powerlink_0 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal phy1_RxDv_to_the_powerlink_0 : IN STD_LOGIC;
                 signal phy1_TxDat_from_the_powerlink_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal phy1_TxEn_from_the_powerlink_0 : OUT STD_LOGIC;

              -- the_status_led_pio
                 signal out_port_from_the_status_led_pio : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);

              -- the_tri_state_bridge_0_avalon_slave
                 signal ben_to_the_DBC3C40_SRAM_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ncs_to_the_DBC3C40_SRAM_0 : OUT STD_LOGIC;
                 signal tri_state_bridge_0_address : OUT STD_LOGIC_VECTOR (19 DOWNTO 0);
                 signal tri_state_bridge_0_data : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal tri_state_bridge_0_readn : OUT STD_LOGIC;
                 signal tri_state_bridge_0_writen : OUT STD_LOGIC
              );
end entity niosII_openMac;


architecture europa of niosII_openMac is
component altpll_0_pll_slave_arbitrator is 
           port (
                 -- inputs:
                    signal altpll_0_pll_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_address_to_slave : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_0_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal altpll_0_pll_slave_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal altpll_0_pll_slave_read : OUT STD_LOGIC;
                    signal altpll_0_pll_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal altpll_0_pll_slave_reset : OUT STD_LOGIC;
                    signal altpll_0_pll_slave_write : OUT STD_LOGIC;
                    signal altpll_0_pll_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_altpll_0_pll_slave_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_out_granted_altpll_0_pll_slave : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_out_read_data_valid_altpll_0_pll_slave : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_out_requests_altpll_0_pll_slave : OUT STD_LOGIC
                 );
end component altpll_0_pll_slave_arbitrator;

component altpll_0 is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal c0 : OUT STD_LOGIC;
                    signal c1 : OUT STD_LOGIC;
                    signal c2 : OUT STD_LOGIC;
                    signal c3 : OUT STD_LOGIC;
                    signal c4 : OUT STD_LOGIC;
                    signal locked : OUT STD_LOGIC;
                    signal phasedone : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component altpll_0;

component avalon_master_bridge_0_AvalonMaster_arbitrator is 
           port (
                 -- inputs:
                    signal avalon_address_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (14 DOWNTO 0);
                    signal avalon_byteenable_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal avalon_master_bridge_0_granted_powerlink_0_PDI_AP : IN STD_LOGIC;
                    signal avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP : IN STD_LOGIC;
                    signal avalon_master_bridge_0_read_data_valid_powerlink_0_PDI_AP : IN STD_LOGIC;
                    signal avalon_master_bridge_0_requests_powerlink_0_PDI_AP : IN STD_LOGIC;
                    signal avalon_read_from_the_avalon_master_bridge_0 : IN STD_LOGIC;
                    signal avalon_write_from_the_avalon_master_bridge_0 : IN STD_LOGIC;
                    signal avalon_writedata_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal d1_powerlink_0_PDI_AP_end_xfer : IN STD_LOGIC;
                    signal powerlink_0_PDI_AP_irq_from_sa : IN STD_LOGIC;
                    signal powerlink_0_PDI_AP_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal powerlink_0_PDI_AP_wait_counter_eq_0 : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_irq_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;
                    signal avalon_address_from_the_avalon_master_bridge_0_to_slave : OUT STD_LOGIC_VECTOR (14 DOWNTO 0);
                    signal avalon_master_bridge_0_latency_counter : OUT STD_LOGIC;
                    signal avalon_readdata_to_the_avalon_master_bridge_0 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal avalon_readdatavalid_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;
                    signal avalon_waitrequest_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;
                    signal reset_to_the_avalon_master_bridge_0 : OUT STD_LOGIC
                 );
end component avalon_master_bridge_0_AvalonMaster_arbitrator;

component clock_crossing_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_s1_endofpacket : IN STD_LOGIC;
                    signal clock_crossing_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clock_crossing_0_s1_readdatavalid : IN STD_LOGIC;
                    signal clock_crossing_0_s1_waitrequest : IN STD_LOGIC;
                    signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal pcp_cpu_data_master_read : IN STD_LOGIC;
                    signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal pcp_cpu_data_master_write : IN STD_LOGIC;
                    signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal clock_crossing_0_s1_address : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal clock_crossing_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal clock_crossing_0_s1_endofpacket_from_sa : OUT STD_LOGIC;
                    signal clock_crossing_0_s1_nativeaddress : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal clock_crossing_0_s1_read : OUT STD_LOGIC;
                    signal clock_crossing_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clock_crossing_0_s1_reset_n : OUT STD_LOGIC;
                    signal clock_crossing_0_s1_waitrequest_from_sa : OUT STD_LOGIC;
                    signal clock_crossing_0_s1_write : OUT STD_LOGIC;
                    signal clock_crossing_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_clock_crossing_0_s1_end_xfer : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_granted_clock_crossing_0_s1 : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_clock_crossing_0_s1 : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1 : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_requests_clock_crossing_0_s1 : OUT STD_LOGIC
                 );
end component clock_crossing_0_s1_arbitrator;

component clock_crossing_0_m1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal clock_crossing_0_m1_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                    signal clock_crossing_0_m1_granted_node_switch_pio_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_granted_powerlink_0_MAC_CMP : IN STD_LOGIC;
                    signal clock_crossing_0_m1_granted_powerlink_0_MAC_REG : IN STD_LOGIC;
                    signal clock_crossing_0_m1_granted_status_led_pio_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_granted_system_timer_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_node_switch_pio_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_status_led_pio_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_system_timer_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_node_switch_pio_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_CMP : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_REG : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_status_led_pio_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_system_timer_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_node_switch_pio_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_powerlink_0_MAC_CMP : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_powerlink_0_MAC_REG : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_status_led_pio_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_system_timer_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_jtag_uart_0_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                    signal d1_node_switch_pio_s1_end_xfer : IN STD_LOGIC;
                    signal d1_powerlink_0_MAC_CMP_end_xfer : IN STD_LOGIC;
                    signal d1_powerlink_0_MAC_REG_end_xfer : IN STD_LOGIC;
                    signal d1_status_led_pio_s1_end_xfer : IN STD_LOGIC;
                    signal d1_system_timer_s1_end_xfer : IN STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                    signal node_switch_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal powerlink_0_MAC_CMP_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal powerlink_0_MAC_REG_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal status_led_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal system_timer_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal clock_crossing_0_m1_address_to_slave : OUT STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal clock_crossing_0_m1_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clock_crossing_0_m1_dbs_write_16 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clock_crossing_0_m1_readdatavalid : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_reset_n : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_waitrequest : OUT STD_LOGIC
                 );
end component clock_crossing_0_m1_arbitrator;

component clock_crossing_0 is 
           port (
                 -- inputs:
                    signal master_clk : IN STD_LOGIC;
                    signal master_endofpacket : IN STD_LOGIC;
                    signal master_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal master_readdatavalid : IN STD_LOGIC;
                    signal master_reset_n : IN STD_LOGIC;
                    signal master_waitrequest : IN STD_LOGIC;
                    signal slave_address : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal slave_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_nativeaddress : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;
                    signal slave_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal master_address : OUT STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal master_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal master_nativeaddress : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal master_read : OUT STD_LOGIC;
                    signal master_write : OUT STD_LOGIC;
                    signal master_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal slave_endofpacket : OUT STD_LOGIC;
                    signal slave_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal slave_readdatavalid : OUT STD_LOGIC;
                    signal slave_waitrequest : OUT STD_LOGIC
                 );
end component clock_crossing_0;

component clock_crossing_0_bridge_arbitrator is 
end component clock_crossing_0_bridge_arbitrator;

component epcs_flash_controller_0_epcs_control_port_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_dataavailable : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_endofpacket : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_irq : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal epcs_flash_controller_0_epcs_control_port_readyfordata : IN STD_LOGIC;
                    signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal pcp_cpu_data_master_read : IN STD_LOGIC;
                    signal pcp_cpu_data_master_write : IN STD_LOGIC;
                    signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (21 DOWNTO 0);
                    signal pcp_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pcp_cpu_instruction_master_read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : OUT STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal epcs_flash_controller_0_epcs_control_port_chipselect : OUT STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa : OUT STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa : OUT STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_irq_from_sa : OUT STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_read_n : OUT STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa : OUT STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_reset_n : OUT STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_write_n : OUT STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC
                 );
end component epcs_flash_controller_0_epcs_control_port_arbitrator;

component epcs_flash_controller_0 is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data0 : IN STD_LOGIC;
                    signal read_n : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal dataavailable : OUT STD_LOGIC;
                    signal dclk : OUT STD_LOGIC;
                    signal endofpacket : OUT STD_LOGIC;
                    signal irq : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal readyfordata : OUT STD_LOGIC;
                    signal sce : OUT STD_LOGIC;
                    signal sdo : OUT STD_LOGIC
                 );
end component epcs_flash_controller_0;

component jtag_uart_0_avalon_jtag_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_0_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_irq : IN STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_0_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave : OUT STD_LOGIC;
                    signal d1_jtag_uart_0_avalon_jtag_slave_end_xfer : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_address : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_chipselect : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_irq_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_read_n : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_reset_n : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_write_n : OUT STD_LOGIC;
                    signal jtag_uart_0_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component jtag_uart_0_avalon_jtag_slave_arbitrator;

component jtag_uart_0 is 
           port (
                 -- inputs:
                    signal av_address : IN STD_LOGIC;
                    signal av_chipselect : IN STD_LOGIC;
                    signal av_read_n : IN STD_LOGIC;
                    signal av_write_n : IN STD_LOGIC;
                    signal av_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal rst_n : IN STD_LOGIC;

                 -- outputs:
                    signal av_irq : OUT STD_LOGIC;
                    signal av_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal av_waitrequest : OUT STD_LOGIC;
                    signal dataavailable : OUT STD_LOGIC;
                    signal readyfordata : OUT STD_LOGIC
                 );
end component jtag_uart_0;

component niosII_openMac_clock_0_in_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_in_endofpacket : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_waitrequest : IN STD_LOGIC;
                    signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal pcp_cpu_data_master_read : IN STD_LOGIC;
                    signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal pcp_cpu_data_master_write : IN STD_LOGIC;
                    signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_niosII_openMac_clock_0_in_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_in_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_in_nativeaddress : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_read : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_in_write : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_data_master_granted_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_requests_niosII_openMac_clock_0_in : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_0_in_arbitrator;

component niosII_openMac_clock_0_out_arbitrator is 
           port (
                 -- inputs:
                    signal altpll_0_pll_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal d1_altpll_0_pll_slave_end_xfer : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_0_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_0_out_granted_altpll_0_pll_slave : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_read_data_valid_altpll_0_pll_slave : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_requests_altpll_0_pll_slave : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal niosII_openMac_clock_0_out_address_to_slave : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_0_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_0_out_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_out_waitrequest : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_0_out_arbitrator;

component niosII_openMac_clock_0 is 
           port (
                 -- inputs:
                    signal master_clk : IN STD_LOGIC;
                    signal master_endofpacket : IN STD_LOGIC;
                    signal master_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal master_reset_n : IN STD_LOGIC;
                    signal master_waitrequest : IN STD_LOGIC;
                    signal slave_address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal slave_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_nativeaddress : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;
                    signal slave_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal master_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal master_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal master_nativeaddress : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal master_read : OUT STD_LOGIC;
                    signal master_write : OUT STD_LOGIC;
                    signal master_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal slave_endofpacket : OUT STD_LOGIC;
                    signal slave_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal slave_waitrequest : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_0;

component niosII_openMac_clock_1_in_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_in_endofpacket : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_waitrequest : IN STD_LOGIC;
                    signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal pcp_cpu_data_master_read : IN STD_LOGIC;
                    signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal pcp_cpu_data_master_write : IN STD_LOGIC;
                    signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_niosII_openMac_clock_1_in_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_address : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_nativeaddress : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_read : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_write : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_data_master_granted_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_requests_niosII_openMac_clock_1_in : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_1_in_arbitrator;

component niosII_openMac_clock_1_out_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d1_remote_update_cycloneiii_0_s1_end_xfer : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal remote_update_cycloneiii_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal remote_update_cycloneiii_0_s1_waitrequest_from_sa : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal niosII_openMac_clock_1_out_address_to_slave : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_waitrequest : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_1_out_arbitrator;

component niosII_openMac_clock_1 is 
           port (
                 -- inputs:
                    signal master_clk : IN STD_LOGIC;
                    signal master_endofpacket : IN STD_LOGIC;
                    signal master_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal master_reset_n : IN STD_LOGIC;
                    signal master_waitrequest : IN STD_LOGIC;
                    signal slave_address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal slave_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;
                    signal slave_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal master_address : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal master_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal master_nativeaddress : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal master_read : OUT STD_LOGIC;
                    signal master_write : OUT STD_LOGIC;
                    signal master_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal slave_endofpacket : OUT STD_LOGIC;
                    signal slave_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal slave_waitrequest : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_1;

component node_switch_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal node_switch_pio_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal clock_crossing_0_m1_granted_node_switch_pio_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_node_switch_pio_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_node_switch_pio_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_node_switch_pio_s1 : OUT STD_LOGIC;
                    signal d1_node_switch_pio_s1_end_xfer : OUT STD_LOGIC;
                    signal node_switch_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal node_switch_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal node_switch_pio_s1_reset_n : OUT STD_LOGIC
                 );
end component node_switch_pio_s1_arbitrator;

component node_switch_pio is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component node_switch_pio;

component onchip_memory_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal onchip_memory_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal pcp_cpu_data_master_read : IN STD_LOGIC;
                    signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal pcp_cpu_data_master_write : IN STD_LOGIC;
                    signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (21 DOWNTO 0);
                    signal pcp_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pcp_cpu_instruction_master_read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_onchip_memory_0_s1_end_xfer : OUT STD_LOGIC;
                    signal onchip_memory_0_s1_address : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal onchip_memory_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal onchip_memory_0_s1_chipselect : OUT STD_LOGIC;
                    signal onchip_memory_0_s1_clken : OUT STD_LOGIC;
                    signal onchip_memory_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal onchip_memory_0_s1_write : OUT STD_LOGIC;
                    signal onchip_memory_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_data_master_granted_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_requests_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_granted_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_requests_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal registered_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 : OUT STD_LOGIC
                 );
end component onchip_memory_0_s1_arbitrator;

component onchip_memory_0 is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal clken : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component onchip_memory_0;

component pcp_cpu_jtag_debug_module_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal pcp_cpu_data_master_debugaccess : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read : IN STD_LOGIC;
                    signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal pcp_cpu_data_master_write : IN STD_LOGIC;
                    signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (21 DOWNTO 0);
                    signal pcp_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pcp_cpu_instruction_master_read : IN STD_LOGIC;
                    signal pcp_cpu_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_jtag_debug_module_resetrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_pcp_cpu_jtag_debug_module_end_xfer : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_read_data_valid_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal pcp_cpu_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal pcp_cpu_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                    signal pcp_cpu_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal pcp_cpu_jtag_debug_module_chipselect : OUT STD_LOGIC;
                    signal pcp_cpu_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                    signal pcp_cpu_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_jtag_debug_module_reset_n : OUT STD_LOGIC;
                    signal pcp_cpu_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                    signal pcp_cpu_jtag_debug_module_write : OUT STD_LOGIC;
                    signal pcp_cpu_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component pcp_cpu_jtag_debug_module_arbitrator;

component pcp_cpu_data_master_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clock_crossing_0_s1_waitrequest_from_sa : IN STD_LOGIC;
                    signal d1_clock_crossing_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : IN STD_LOGIC;
                    signal d1_niosII_openMac_clock_0_in_end_xfer : IN STD_LOGIC;
                    signal d1_niosII_openMac_clock_1_in_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_memory_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_pcp_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_powerlink_0_MAC_BUF_end_xfer : IN STD_LOGIC;
                    signal d1_powerlink_0_PDI_PCP_end_xfer : IN STD_LOGIC;
                    signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                    signal d1_tri_state_bridge_0_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_irq_from_sa : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal incoming_tri_state_bridge_0_data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal jtag_uart_0_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal onchip_memory_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_clk : IN STD_LOGIC;
                    signal pcp_clk_reset_n : IN STD_LOGIC;
                    signal pcp_cpu_data_master_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal pcp_cpu_data_master_granted_clock_crossing_0_s1 : IN STD_LOGIC;
                    signal pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal pcp_cpu_data_master_granted_niosII_openMac_clock_0_in : IN STD_LOGIC;
                    signal pcp_cpu_data_master_granted_niosII_openMac_clock_1_in : IN STD_LOGIC;
                    signal pcp_cpu_data_master_granted_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal pcp_cpu_data_master_granted_powerlink_0_MAC_BUF : IN STD_LOGIC;
                    signal pcp_cpu_data_master_granted_powerlink_0_PDI_PCP : IN STD_LOGIC;
                    signal pcp_cpu_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_clock_crossing_0_s1 : IN STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in : IN STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in : IN STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF : IN STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP : IN STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1 : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_0_in : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_powerlink_0_MAC_BUF : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_powerlink_0_PDI_PCP : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                    signal pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal pcp_cpu_data_master_requests_clock_crossing_0_s1 : IN STD_LOGIC;
                    signal pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal pcp_cpu_data_master_requests_niosII_openMac_clock_0_in : IN STD_LOGIC;
                    signal pcp_cpu_data_master_requests_niosII_openMac_clock_1_in : IN STD_LOGIC;
                    signal pcp_cpu_data_master_requests_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal pcp_cpu_data_master_requests_powerlink_0_MAC_BUF : IN STD_LOGIC;
                    signal pcp_cpu_data_master_requests_powerlink_0_PDI_PCP : IN STD_LOGIC;
                    signal pcp_cpu_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                    signal pcp_cpu_data_master_write : IN STD_LOGIC;
                    signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal powerlink_0_MAC_BUF_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal powerlink_0_MAC_BUF_wait_counter_eq_0 : IN STD_LOGIC;
                    signal powerlink_0_MAC_CMP_irq_from_sa : IN STD_LOGIC;
                    signal powerlink_0_MAC_REG_irq_from_sa : IN STD_LOGIC;
                    signal powerlink_0_PDI_PCP_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal powerlink_0_PDI_PCP_wait_counter_eq_0 : IN STD_LOGIC;
                    signal registered_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal registered_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal system_timer_s1_irq_from_sa : IN STD_LOGIC;

                 -- outputs:
                    signal pcp_cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal pcp_cpu_data_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pcp_cpu_data_master_dbs_write_16 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal pcp_cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_data_master_no_byte_enables_and_last_term : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_data_master_waitrequest : OUT STD_LOGIC
                 );
end component pcp_cpu_data_master_arbitrator;

component pcp_cpu_instruction_master_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_memory_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_pcp_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_tri_state_bridge_0_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal incoming_tri_state_bridge_0_data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal onchip_memory_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_instruction_master_address : IN STD_LOGIC_VECTOR (21 DOWNTO 0);
                    signal pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_granted_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_read : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_read_data_valid_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_requests_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal pcp_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal pcp_cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (21 DOWNTO 0);
                    signal pcp_cpu_instruction_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pcp_cpu_instruction_master_latency_counter : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pcp_cpu_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_cpu_instruction_master_readdatavalid : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_waitrequest : OUT STD_LOGIC
                 );
end component pcp_cpu_instruction_master_arbitrator;

component pcp_cpu is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d_irq : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d_waitrequest : IN STD_LOGIC;
                    signal i_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_readdatavalid : IN STD_LOGIC;
                    signal i_waitrequest : IN STD_LOGIC;
                    signal jtag_debug_module_address : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal jtag_debug_module_begintransfer : IN STD_LOGIC;
                    signal jtag_debug_module_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal jtag_debug_module_debugaccess : IN STD_LOGIC;
                    signal jtag_debug_module_select : IN STD_LOGIC;
                    signal jtag_debug_module_write : IN STD_LOGIC;
                    signal jtag_debug_module_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal d_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal d_read : OUT STD_LOGIC;
                    signal d_write : OUT STD_LOGIC;
                    signal d_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_address : OUT STD_LOGIC_VECTOR (21 DOWNTO 0);
                    signal i_read : OUT STD_LOGIC;
                    signal jtag_debug_module_debugaccess_to_roms : OUT STD_LOGIC;
                    signal jtag_debug_module_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_debug_module_resetrequest : OUT STD_LOGIC
                 );
end component pcp_cpu;

component powerlink_0_MAC_BUF_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal pcp_cpu_data_master_read : IN STD_LOGIC;
                    signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal pcp_cpu_data_master_write : IN STD_LOGIC;
                    signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal powerlink_0_MAC_BUF_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_powerlink_0_MAC_BUF_end_xfer : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_granted_powerlink_0_MAC_BUF : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_powerlink_0_MAC_BUF : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_requests_powerlink_0_MAC_BUF : OUT STD_LOGIC;
                    signal powerlink_0_MAC_BUF_address : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal powerlink_0_MAC_BUF_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal powerlink_0_MAC_BUF_chipselect : OUT STD_LOGIC;
                    signal powerlink_0_MAC_BUF_read_n : OUT STD_LOGIC;
                    signal powerlink_0_MAC_BUF_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal powerlink_0_MAC_BUF_reset : OUT STD_LOGIC;
                    signal powerlink_0_MAC_BUF_wait_counter_eq_0 : OUT STD_LOGIC;
                    signal powerlink_0_MAC_BUF_write_n : OUT STD_LOGIC;
                    signal powerlink_0_MAC_BUF_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component powerlink_0_MAC_BUF_arbitrator;

component powerlink_0_MAC_CMP_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal clock_crossing_0_m1_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal powerlink_0_MAC_CMP_irq : IN STD_LOGIC;
                    signal powerlink_0_MAC_CMP_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal clock_crossing_0_m1_granted_powerlink_0_MAC_CMP : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_CMP : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_powerlink_0_MAC_CMP : OUT STD_LOGIC;
                    signal d1_powerlink_0_MAC_CMP_end_xfer : OUT STD_LOGIC;
                    signal powerlink_0_MAC_CMP_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal powerlink_0_MAC_CMP_byteenable_n : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal powerlink_0_MAC_CMP_chipselect : OUT STD_LOGIC;
                    signal powerlink_0_MAC_CMP_irq_from_sa : OUT STD_LOGIC;
                    signal powerlink_0_MAC_CMP_read_n : OUT STD_LOGIC;
                    signal powerlink_0_MAC_CMP_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal powerlink_0_MAC_CMP_write_n : OUT STD_LOGIC;
                    signal powerlink_0_MAC_CMP_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component powerlink_0_MAC_CMP_arbitrator;

component powerlink_0_MAC_REG_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal clock_crossing_0_m1_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal clock_crossing_0_m1_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clock_crossing_0_m1_dbs_write_16 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal powerlink_0_MAC_REG_irq : IN STD_LOGIC;
                    signal powerlink_0_MAC_REG_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clock_crossing_0_m1_granted_powerlink_0_MAC_REG : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_REG : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_powerlink_0_MAC_REG : OUT STD_LOGIC;
                    signal d1_powerlink_0_MAC_REG_end_xfer : OUT STD_LOGIC;
                    signal powerlink_0_MAC_REG_address : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal powerlink_0_MAC_REG_byteenable_n : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal powerlink_0_MAC_REG_chipselect : OUT STD_LOGIC;
                    signal powerlink_0_MAC_REG_irq_from_sa : OUT STD_LOGIC;
                    signal powerlink_0_MAC_REG_read_n : OUT STD_LOGIC;
                    signal powerlink_0_MAC_REG_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal powerlink_0_MAC_REG_write_n : OUT STD_LOGIC;
                    signal powerlink_0_MAC_REG_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component powerlink_0_MAC_REG_arbitrator;

component powerlink_0_PDI_AP_arbitrator is 
           port (
                 -- inputs:
                    signal avalon_address_from_the_avalon_master_bridge_0_to_slave : IN STD_LOGIC_VECTOR (14 DOWNTO 0);
                    signal avalon_byteenable_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal avalon_master_bridge_0_latency_counter : IN STD_LOGIC;
                    signal avalon_read_from_the_avalon_master_bridge_0 : IN STD_LOGIC;
                    signal avalon_write_from_the_avalon_master_bridge_0 : IN STD_LOGIC;
                    signal avalon_writedata_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal powerlink_0_PDI_AP_irq : IN STD_LOGIC;
                    signal powerlink_0_PDI_AP_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal avalon_master_bridge_0_granted_powerlink_0_PDI_AP : OUT STD_LOGIC;
                    signal avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP : OUT STD_LOGIC;
                    signal avalon_master_bridge_0_read_data_valid_powerlink_0_PDI_AP : OUT STD_LOGIC;
                    signal avalon_master_bridge_0_requests_powerlink_0_PDI_AP : OUT STD_LOGIC;
                    signal d1_powerlink_0_PDI_AP_end_xfer : OUT STD_LOGIC;
                    signal powerlink_0_PDI_AP_address : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal powerlink_0_PDI_AP_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal powerlink_0_PDI_AP_chipselect : OUT STD_LOGIC;
                    signal powerlink_0_PDI_AP_irq_from_sa : OUT STD_LOGIC;
                    signal powerlink_0_PDI_AP_read : OUT STD_LOGIC;
                    signal powerlink_0_PDI_AP_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal powerlink_0_PDI_AP_reset : OUT STD_LOGIC;
                    signal powerlink_0_PDI_AP_wait_counter_eq_0 : OUT STD_LOGIC;
                    signal powerlink_0_PDI_AP_write : OUT STD_LOGIC;
                    signal powerlink_0_PDI_AP_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component powerlink_0_PDI_AP_arbitrator;

component powerlink_0_PDI_PCP_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal pcp_cpu_data_master_read : IN STD_LOGIC;
                    signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal pcp_cpu_data_master_write : IN STD_LOGIC;
                    signal pcp_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal powerlink_0_PDI_PCP_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_powerlink_0_PDI_PCP_end_xfer : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_granted_powerlink_0_PDI_PCP : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_powerlink_0_PDI_PCP : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_requests_powerlink_0_PDI_PCP : OUT STD_LOGIC;
                    signal powerlink_0_PDI_PCP_address : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal powerlink_0_PDI_PCP_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal powerlink_0_PDI_PCP_chipselect : OUT STD_LOGIC;
                    signal powerlink_0_PDI_PCP_read : OUT STD_LOGIC;
                    signal powerlink_0_PDI_PCP_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal powerlink_0_PDI_PCP_wait_counter_eq_0 : OUT STD_LOGIC;
                    signal powerlink_0_PDI_PCP_write : OUT STD_LOGIC;
                    signal powerlink_0_PDI_PCP_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component powerlink_0_PDI_PCP_arbitrator;

component powerlink_0 is 
           port (
                 -- inputs:
                    signal ap_address : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal ap_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_chipselect : IN STD_LOGIC;
                    signal ap_read : IN STD_LOGIC;
                    signal ap_write : IN STD_LOGIC;
                    signal ap_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk100 : IN STD_LOGIC;
                    signal clk50 : IN STD_LOGIC;
                    signal clkAp : IN STD_LOGIC;
                    signal clkPcp : IN STD_LOGIC;
                    signal mac_address : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal mac_byteenable_n : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal mac_chipselect : IN STD_LOGIC;
                    signal mac_read_n : IN STD_LOGIC;
                    signal mac_write_n : IN STD_LOGIC;
                    signal mac_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal mbf_address : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal mbf_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal mbf_chipselect : IN STD_LOGIC;
                    signal mbf_read_n : IN STD_LOGIC;
                    signal mbf_write_n : IN STD_LOGIC;
                    signal mbf_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_address : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal pcp_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal pcp_chipselect : IN STD_LOGIC;
                    signal pcp_read : IN STD_LOGIC;
                    signal pcp_write : IN STD_LOGIC;
                    signal pcp_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal phy0_RxDat : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal phy0_RxDv : IN STD_LOGIC;
                    signal phy1_RxDat : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal phy1_RxDv : IN STD_LOGIC;
                    signal rstAp : IN STD_LOGIC;
                    signal rstPcp : IN STD_LOGIC;
                    signal tcp_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal tcp_byteenable_n : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal tcp_chipselect : IN STD_LOGIC;
                    signal tcp_read_n : IN STD_LOGIC;
                    signal tcp_write_n : IN STD_LOGIC;
                    signal tcp_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal ap_irq : OUT STD_LOGIC;
                    signal ap_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal mac_irq : OUT STD_LOGIC;
                    signal mac_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal mbf_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal pcp_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal phy0_MiiClk : OUT STD_LOGIC;
                    signal phy0_MiiDat : INOUT STD_LOGIC;
                    signal phy0_MiiRst_n : OUT STD_LOGIC;
                    signal phy0_TxDat : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal phy0_TxEn : OUT STD_LOGIC;
                    signal phy1_MiiClk : OUT STD_LOGIC;
                    signal phy1_MiiDat : INOUT STD_LOGIC;
                    signal phy1_MiiRst_n : OUT STD_LOGIC;
                    signal phy1_TxDat : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal phy1_TxEn : OUT STD_LOGIC;
                    signal tcp_irq : OUT STD_LOGIC;
                    signal tcp_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component powerlink_0;

component remote_update_cycloneiii_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal remote_update_cycloneiii_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal remote_update_cycloneiii_0_s1_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_remote_update_cycloneiii_0_s1_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                    signal remote_update_cycloneiii_0_s1_address : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal remote_update_cycloneiii_0_s1_chipselect : OUT STD_LOGIC;
                    signal remote_update_cycloneiii_0_s1_read : OUT STD_LOGIC;
                    signal remote_update_cycloneiii_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal remote_update_cycloneiii_0_s1_reset : OUT STD_LOGIC;
                    signal remote_update_cycloneiii_0_s1_waitrequest_from_sa : OUT STD_LOGIC;
                    signal remote_update_cycloneiii_0_s1_write : OUT STD_LOGIC;
                    signal remote_update_cycloneiii_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component remote_update_cycloneiii_0_s1_arbitrator;

component remote_update_cycloneiii_0 is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal waitrequest : OUT STD_LOGIC
                 );
end component remote_update_cycloneiii_0;

component status_led_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal status_led_pio_s1_readdata : IN STD_LOGIC_VECTOR (1 DOWNTO 0);

                 -- outputs:
                    signal clock_crossing_0_m1_granted_status_led_pio_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_status_led_pio_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_status_led_pio_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_status_led_pio_s1 : OUT STD_LOGIC;
                    signal d1_status_led_pio_s1_end_xfer : OUT STD_LOGIC;
                    signal status_led_pio_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal status_led_pio_s1_chipselect : OUT STD_LOGIC;
                    signal status_led_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal status_led_pio_s1_reset_n : OUT STD_LOGIC;
                    signal status_led_pio_s1_write_n : OUT STD_LOGIC;
                    signal status_led_pio_s1_writedata : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
                 );
end component status_led_pio_s1_arbitrator;

component status_led_pio is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (1 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
                 );
end component status_led_pio;

component sysid_control_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal pcp_cpu_data_master_read : IN STD_LOGIC;
                    signal pcp_cpu_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal d1_sysid_control_slave_end_xfer : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_granted_sysid_control_slave : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_requests_sysid_control_slave : OUT STD_LOGIC;
                    signal sysid_control_slave_address : OUT STD_LOGIC;
                    signal sysid_control_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal sysid_control_slave_reset_n : OUT STD_LOGIC
                 );
end component sysid_control_slave_arbitrator;

component sysid is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC;
                    signal clock : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component sysid;

component system_timer_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal system_timer_s1_irq : IN STD_LOGIC;
                    signal system_timer_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal clock_crossing_0_m1_granted_system_timer_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_system_timer_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_system_timer_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_system_timer_s1 : OUT STD_LOGIC;
                    signal d1_system_timer_s1_end_xfer : OUT STD_LOGIC;
                    signal system_timer_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal system_timer_s1_chipselect : OUT STD_LOGIC;
                    signal system_timer_s1_irq_from_sa : OUT STD_LOGIC;
                    signal system_timer_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal system_timer_s1_reset_n : OUT STD_LOGIC;
                    signal system_timer_s1_write_n : OUT STD_LOGIC;
                    signal system_timer_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component system_timer_s1_arbitrator;

component system_timer is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal irq : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component system_timer;

component tri_state_bridge_0_avalon_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal pcp_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal pcp_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal pcp_cpu_data_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pcp_cpu_data_master_dbs_write_16 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal pcp_cpu_data_master_no_byte_enables_and_last_term : IN STD_LOGIC;
                    signal pcp_cpu_data_master_read : IN STD_LOGIC;
                    signal pcp_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal pcp_cpu_data_master_write : IN STD_LOGIC;
                    signal pcp_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (21 DOWNTO 0);
                    signal pcp_cpu_instruction_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pcp_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pcp_cpu_instruction_master_read : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ben_to_the_DBC3C40_SRAM_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal d1_tri_state_bridge_0_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal incoming_tri_state_bridge_0_data : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ncs_to_the_DBC3C40_SRAM_0 : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal registered_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal tri_state_bridge_0_address : OUT STD_LOGIC_VECTOR (19 DOWNTO 0);
                    signal tri_state_bridge_0_data : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal tri_state_bridge_0_readn : OUT STD_LOGIC;
                    signal tri_state_bridge_0_writen : OUT STD_LOGIC
                 );
end component tri_state_bridge_0_avalon_slave_arbitrator;

component tri_state_bridge_0 is 
end component tri_state_bridge_0;

component tri_state_bridge_0_bridge_arbitrator is 
end component tri_state_bridge_0_bridge_arbitrator;

component niosII_openMac_reset_clk_0_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component niosII_openMac_reset_clk_0_domain_synch_module;

component niosII_openMac_reset_pcp_clk_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component niosII_openMac_reset_pcp_clk_domain_synch_module;

component niosII_openMac_reset_clk50Meg_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component niosII_openMac_reset_clk50Meg_domain_synch_module;

component niosII_openMac_reset_ap_clk_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component niosII_openMac_reset_ap_clk_domain_synch_module;

component niosII_openMac_reset_clk25Meg_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component niosII_openMac_reset_clk25Meg_domain_synch_module;

                signal altpll_0_pll_slave_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altpll_0_pll_slave_read :  STD_LOGIC;
                signal altpll_0_pll_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal altpll_0_pll_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal altpll_0_pll_slave_reset :  STD_LOGIC;
                signal altpll_0_pll_slave_write :  STD_LOGIC;
                signal altpll_0_pll_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ap_clk_reset_n :  STD_LOGIC;
                signal avalon_address_from_the_avalon_master_bridge_0_to_slave :  STD_LOGIC_VECTOR (14 DOWNTO 0);
                signal avalon_master_bridge_0_granted_powerlink_0_PDI_AP :  STD_LOGIC;
                signal avalon_master_bridge_0_latency_counter :  STD_LOGIC;
                signal avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP :  STD_LOGIC;
                signal avalon_master_bridge_0_read_data_valid_powerlink_0_PDI_AP :  STD_LOGIC;
                signal avalon_master_bridge_0_requests_powerlink_0_PDI_AP :  STD_LOGIC;
                signal clk25Meg_reset_n :  STD_LOGIC;
                signal clk50Meg_reset_n :  STD_LOGIC;
                signal clk_0_reset_n :  STD_LOGIC;
                signal clock_crossing_0_m1_address :  STD_LOGIC_VECTOR (13 DOWNTO 0);
                signal clock_crossing_0_m1_address_to_slave :  STD_LOGIC_VECTOR (13 DOWNTO 0);
                signal clock_crossing_0_m1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal clock_crossing_0_m1_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal clock_crossing_0_m1_dbs_write_16 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal clock_crossing_0_m1_endofpacket :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_node_switch_pio_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_powerlink_0_MAC_CMP :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_powerlink_0_MAC_REG :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_status_led_pio_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_system_timer_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_latency_counter :  STD_LOGIC;
                signal clock_crossing_0_m1_nativeaddress :  STD_LOGIC_VECTOR (11 DOWNTO 0);
                signal clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_qualified_request_node_switch_pio_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP :  STD_LOGIC;
                signal clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG :  STD_LOGIC;
                signal clock_crossing_0_m1_qualified_request_status_led_pio_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_qualified_request_system_timer_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_read :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_node_switch_pio_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_CMP :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_REG :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_status_led_pio_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_system_timer_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal clock_crossing_0_m1_readdatavalid :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_node_switch_pio_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_powerlink_0_MAC_CMP :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_powerlink_0_MAC_REG :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_status_led_pio_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_system_timer_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_reset_n :  STD_LOGIC;
                signal clock_crossing_0_m1_waitrequest :  STD_LOGIC;
                signal clock_crossing_0_m1_write :  STD_LOGIC;
                signal clock_crossing_0_m1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal clock_crossing_0_s1_address :  STD_LOGIC_VECTOR (11 DOWNTO 0);
                signal clock_crossing_0_s1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal clock_crossing_0_s1_endofpacket :  STD_LOGIC;
                signal clock_crossing_0_s1_endofpacket_from_sa :  STD_LOGIC;
                signal clock_crossing_0_s1_nativeaddress :  STD_LOGIC_VECTOR (11 DOWNTO 0);
                signal clock_crossing_0_s1_read :  STD_LOGIC;
                signal clock_crossing_0_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal clock_crossing_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal clock_crossing_0_s1_readdatavalid :  STD_LOGIC;
                signal clock_crossing_0_s1_reset_n :  STD_LOGIC;
                signal clock_crossing_0_s1_waitrequest :  STD_LOGIC;
                signal clock_crossing_0_s1_waitrequest_from_sa :  STD_LOGIC;
                signal clock_crossing_0_s1_write :  STD_LOGIC;
                signal clock_crossing_0_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal d1_altpll_0_pll_slave_end_xfer :  STD_LOGIC;
                signal d1_clock_crossing_0_s1_end_xfer :  STD_LOGIC;
                signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer :  STD_LOGIC;
                signal d1_jtag_uart_0_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal d1_niosII_openMac_clock_0_in_end_xfer :  STD_LOGIC;
                signal d1_niosII_openMac_clock_1_in_end_xfer :  STD_LOGIC;
                signal d1_node_switch_pio_s1_end_xfer :  STD_LOGIC;
                signal d1_onchip_memory_0_s1_end_xfer :  STD_LOGIC;
                signal d1_pcp_cpu_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal d1_powerlink_0_MAC_BUF_end_xfer :  STD_LOGIC;
                signal d1_powerlink_0_MAC_CMP_end_xfer :  STD_LOGIC;
                signal d1_powerlink_0_MAC_REG_end_xfer :  STD_LOGIC;
                signal d1_powerlink_0_PDI_AP_end_xfer :  STD_LOGIC;
                signal d1_powerlink_0_PDI_PCP_end_xfer :  STD_LOGIC;
                signal d1_remote_update_cycloneiii_0_s1_end_xfer :  STD_LOGIC;
                signal d1_status_led_pio_s1_end_xfer :  STD_LOGIC;
                signal d1_sysid_control_slave_end_xfer :  STD_LOGIC;
                signal d1_system_timer_s1_end_xfer :  STD_LOGIC;
                signal d1_tri_state_bridge_0_avalon_slave_end_xfer :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_address :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_chipselect :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_dataavailable :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_endofpacket :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_irq :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_irq_from_sa :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_read_n :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_readyfordata :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_reset_n :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_write_n :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal incoming_tri_state_bridge_0_data :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_ap_clk :  STD_LOGIC;
                signal internal_ap_irq_to_the_avalon_master_bridge_0 :  STD_LOGIC;
                signal internal_avalon_readdata_to_the_avalon_master_bridge_0 :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_avalon_readdatavalid_to_the_avalon_master_bridge_0 :  STD_LOGIC;
                signal internal_avalon_waitrequest_to_the_avalon_master_bridge_0 :  STD_LOGIC;
                signal internal_ben_to_the_DBC3C40_SRAM_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_clk100Meg :  STD_LOGIC;
                signal internal_clk25Meg :  STD_LOGIC;
                signal internal_clk50Meg :  STD_LOGIC;
                signal internal_dclk_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal internal_locked_from_the_altpll_0 :  STD_LOGIC;
                signal internal_ncs_to_the_DBC3C40_SRAM_0 :  STD_LOGIC;
                signal internal_out_port_from_the_status_led_pio :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_pcp_clk :  STD_LOGIC;
                signal internal_phasedone_from_the_altpll_0 :  STD_LOGIC;
                signal internal_phy0_MiiClk_from_the_powerlink_0 :  STD_LOGIC;
                signal internal_phy0_MiiRst_n_from_the_powerlink_0 :  STD_LOGIC;
                signal internal_phy0_TxDat_from_the_powerlink_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_phy0_TxEn_from_the_powerlink_0 :  STD_LOGIC;
                signal internal_phy1_MiiClk_from_the_powerlink_0 :  STD_LOGIC;
                signal internal_phy1_MiiRst_n_from_the_powerlink_0 :  STD_LOGIC;
                signal internal_phy1_TxDat_from_the_powerlink_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_phy1_TxEn_from_the_powerlink_0 :  STD_LOGIC;
                signal internal_reset_to_the_avalon_master_bridge_0 :  STD_LOGIC;
                signal internal_sce_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal internal_sdo_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal internal_tri_state_bridge_0_address :  STD_LOGIC_VECTOR (19 DOWNTO 0);
                signal internal_tri_state_bridge_0_readn :  STD_LOGIC;
                signal internal_tri_state_bridge_0_writen :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_address :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_chipselect :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_dataavailable :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_irq :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_irq_from_sa :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_read_n :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_readyfordata :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_reset_n :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_waitrequest :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_write_n :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal module_input3 :  STD_LOGIC;
                signal module_input4 :  STD_LOGIC;
                signal module_input5 :  STD_LOGIC;
                signal module_input6 :  STD_LOGIC;
                signal module_input7 :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_address :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_0_in_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_0_in_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_nativeaddress :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_0_in_read :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_0_in_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_0_in_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_write :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_0_out_address :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_0_out_address_to_slave :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_0_out_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_0_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_granted_altpll_0_pll_slave :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_nativeaddress :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_read :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_read_data_valid_altpll_0_pll_slave :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_0_out_requests_altpll_0_pll_slave :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_write :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_1_in_address :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal niosII_openMac_clock_1_in_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_1_in_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_nativeaddress :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal niosII_openMac_clock_1_in_read :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_1_in_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_1_in_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_write :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_1_out_address :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal niosII_openMac_clock_1_out_address_to_slave :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal niosII_openMac_clock_1_out_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_1_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_nativeaddress :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_read :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_write :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal node_switch_pio_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal node_switch_pio_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal node_switch_pio_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal node_switch_pio_s1_reset_n :  STD_LOGIC;
                signal onchip_memory_0_s1_address :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal onchip_memory_0_s1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal onchip_memory_0_s1_chipselect :  STD_LOGIC;
                signal onchip_memory_0_s1_clken :  STD_LOGIC;
                signal onchip_memory_0_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_memory_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_memory_0_s1_write :  STD_LOGIC;
                signal onchip_memory_0_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal out_clk_altpll_0_c0 :  STD_LOGIC;
                signal out_clk_altpll_0_c1 :  STD_LOGIC;
                signal out_clk_altpll_0_c2 :  STD_LOGIC;
                signal out_clk_altpll_0_c3 :  STD_LOGIC;
                signal out_clk_altpll_0_c4 :  STD_LOGIC;
                signal pcp_clk_reset_n :  STD_LOGIC;
                signal pcp_cpu_data_master_address :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal pcp_cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal pcp_cpu_data_master_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_data_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_data_master_dbs_write_16 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal pcp_cpu_data_master_debugaccess :  STD_LOGIC;
                signal pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal pcp_cpu_data_master_granted_clock_crossing_0_s1 :  STD_LOGIC;
                signal pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal pcp_cpu_data_master_granted_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal pcp_cpu_data_master_granted_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal pcp_cpu_data_master_granted_onchip_memory_0_s1 :  STD_LOGIC;
                signal pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal pcp_cpu_data_master_granted_powerlink_0_MAC_BUF :  STD_LOGIC;
                signal pcp_cpu_data_master_granted_powerlink_0_PDI_PCP :  STD_LOGIC;
                signal pcp_cpu_data_master_granted_sysid_control_slave :  STD_LOGIC;
                signal pcp_cpu_data_master_irq :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pcp_cpu_data_master_no_byte_enables_and_last_term :  STD_LOGIC;
                signal pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal pcp_cpu_data_master_qualified_request_clock_crossing_0_s1 :  STD_LOGIC;
                signal pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 :  STD_LOGIC;
                signal pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF :  STD_LOGIC;
                signal pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP :  STD_LOGIC;
                signal pcp_cpu_data_master_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal pcp_cpu_data_master_read :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1 :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_powerlink_0_MAC_BUF :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_powerlink_0_PDI_PCP :  STD_LOGIC;
                signal pcp_cpu_data_master_read_data_valid_sysid_control_slave :  STD_LOGIC;
                signal pcp_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal pcp_cpu_data_master_requests_clock_crossing_0_s1 :  STD_LOGIC;
                signal pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal pcp_cpu_data_master_requests_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal pcp_cpu_data_master_requests_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal pcp_cpu_data_master_requests_onchip_memory_0_s1 :  STD_LOGIC;
                signal pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal pcp_cpu_data_master_requests_powerlink_0_MAC_BUF :  STD_LOGIC;
                signal pcp_cpu_data_master_requests_powerlink_0_PDI_PCP :  STD_LOGIC;
                signal pcp_cpu_data_master_requests_sysid_control_slave :  STD_LOGIC;
                signal pcp_cpu_data_master_waitrequest :  STD_LOGIC;
                signal pcp_cpu_data_master_write :  STD_LOGIC;
                signal pcp_cpu_data_master_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pcp_cpu_instruction_master_address :  STD_LOGIC_VECTOR (21 DOWNTO 0);
                signal pcp_cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (21 DOWNTO 0);
                signal pcp_cpu_instruction_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal pcp_cpu_instruction_master_granted_onchip_memory_0_s1 :  STD_LOGIC;
                signal pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal pcp_cpu_instruction_master_latency_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1 :  STD_LOGIC;
                signal pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal pcp_cpu_instruction_master_read :  STD_LOGIC;
                signal pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal pcp_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 :  STD_LOGIC;
                signal pcp_cpu_instruction_master_read_data_valid_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal pcp_cpu_instruction_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pcp_cpu_instruction_master_readdatavalid :  STD_LOGIC;
                signal pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal pcp_cpu_instruction_master_requests_onchip_memory_0_s1 :  STD_LOGIC;
                signal pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module :  STD_LOGIC;
                signal pcp_cpu_instruction_master_waitrequest :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_address :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_begintransfer :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_chipselect :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_debugaccess :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pcp_cpu_jtag_debug_module_reset_n :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_resetrequest :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_resetrequest_from_sa :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_write :  STD_LOGIC;
                signal pcp_cpu_jtag_debug_module_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal powerlink_0_MAC_BUF_address :  STD_LOGIC_VECTOR (11 DOWNTO 0);
                signal powerlink_0_MAC_BUF_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal powerlink_0_MAC_BUF_chipselect :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_read_n :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal powerlink_0_MAC_BUF_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal powerlink_0_MAC_BUF_reset :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_wait_counter_eq_0 :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_write_n :  STD_LOGIC;
                signal powerlink_0_MAC_BUF_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal powerlink_0_MAC_CMP_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_MAC_CMP_byteenable_n :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal powerlink_0_MAC_CMP_chipselect :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_irq :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_irq_from_sa :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_read_n :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal powerlink_0_MAC_CMP_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal powerlink_0_MAC_CMP_write_n :  STD_LOGIC;
                signal powerlink_0_MAC_CMP_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal powerlink_0_MAC_REG_address :  STD_LOGIC_VECTOR (11 DOWNTO 0);
                signal powerlink_0_MAC_REG_byteenable_n :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal powerlink_0_MAC_REG_chipselect :  STD_LOGIC;
                signal powerlink_0_MAC_REG_irq :  STD_LOGIC;
                signal powerlink_0_MAC_REG_irq_from_sa :  STD_LOGIC;
                signal powerlink_0_MAC_REG_read_n :  STD_LOGIC;
                signal powerlink_0_MAC_REG_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal powerlink_0_MAC_REG_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal powerlink_0_MAC_REG_write_n :  STD_LOGIC;
                signal powerlink_0_MAC_REG_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal powerlink_0_PDI_AP_address :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal powerlink_0_PDI_AP_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal powerlink_0_PDI_AP_chipselect :  STD_LOGIC;
                signal powerlink_0_PDI_AP_irq :  STD_LOGIC;
                signal powerlink_0_PDI_AP_irq_from_sa :  STD_LOGIC;
                signal powerlink_0_PDI_AP_read :  STD_LOGIC;
                signal powerlink_0_PDI_AP_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal powerlink_0_PDI_AP_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal powerlink_0_PDI_AP_reset :  STD_LOGIC;
                signal powerlink_0_PDI_AP_wait_counter_eq_0 :  STD_LOGIC;
                signal powerlink_0_PDI_AP_write :  STD_LOGIC;
                signal powerlink_0_PDI_AP_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal powerlink_0_PDI_PCP_address :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal powerlink_0_PDI_PCP_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal powerlink_0_PDI_PCP_chipselect :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_read :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal powerlink_0_PDI_PCP_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal powerlink_0_PDI_PCP_wait_counter_eq_0 :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_write :  STD_LOGIC;
                signal powerlink_0_PDI_PCP_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal registered_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal registered_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_address :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal remote_update_cycloneiii_0_s1_chipselect :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_read :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal remote_update_cycloneiii_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal remote_update_cycloneiii_0_s1_reset :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_waitrequest :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_waitrequest_from_sa :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_write :  STD_LOGIC;
                signal remote_update_cycloneiii_0_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal reset_n_sources :  STD_LOGIC;
                signal status_led_pio_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal status_led_pio_s1_chipselect :  STD_LOGIC;
                signal status_led_pio_s1_readdata :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal status_led_pio_s1_readdata_from_sa :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal status_led_pio_s1_reset_n :  STD_LOGIC;
                signal status_led_pio_s1_write_n :  STD_LOGIC;
                signal status_led_pio_s1_writedata :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sysid_control_slave_address :  STD_LOGIC;
                signal sysid_control_slave_clock :  STD_LOGIC;
                signal sysid_control_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal sysid_control_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal sysid_control_slave_reset_n :  STD_LOGIC;
                signal system_timer_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal system_timer_s1_chipselect :  STD_LOGIC;
                signal system_timer_s1_irq :  STD_LOGIC;
                signal system_timer_s1_irq_from_sa :  STD_LOGIC;
                signal system_timer_s1_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal system_timer_s1_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal system_timer_s1_reset_n :  STD_LOGIC;
                signal system_timer_s1_write_n :  STD_LOGIC;
                signal system_timer_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);

begin

  --the_altpll_0_pll_slave, which is an e_instance
  the_altpll_0_pll_slave : altpll_0_pll_slave_arbitrator
    port map(
      altpll_0_pll_slave_address => altpll_0_pll_slave_address,
      altpll_0_pll_slave_read => altpll_0_pll_slave_read,
      altpll_0_pll_slave_readdata_from_sa => altpll_0_pll_slave_readdata_from_sa,
      altpll_0_pll_slave_reset => altpll_0_pll_slave_reset,
      altpll_0_pll_slave_write => altpll_0_pll_slave_write,
      altpll_0_pll_slave_writedata => altpll_0_pll_slave_writedata,
      d1_altpll_0_pll_slave_end_xfer => d1_altpll_0_pll_slave_end_xfer,
      niosII_openMac_clock_0_out_granted_altpll_0_pll_slave => niosII_openMac_clock_0_out_granted_altpll_0_pll_slave,
      niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave => niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave,
      niosII_openMac_clock_0_out_read_data_valid_altpll_0_pll_slave => niosII_openMac_clock_0_out_read_data_valid_altpll_0_pll_slave,
      niosII_openMac_clock_0_out_requests_altpll_0_pll_slave => niosII_openMac_clock_0_out_requests_altpll_0_pll_slave,
      altpll_0_pll_slave_readdata => altpll_0_pll_slave_readdata,
      clk => clk_0,
      niosII_openMac_clock_0_out_address_to_slave => niosII_openMac_clock_0_out_address_to_slave,
      niosII_openMac_clock_0_out_read => niosII_openMac_clock_0_out_read,
      niosII_openMac_clock_0_out_write => niosII_openMac_clock_0_out_write,
      niosII_openMac_clock_0_out_writedata => niosII_openMac_clock_0_out_writedata,
      reset_n => clk_0_reset_n
    );


  --clk50Meg out_clk assignment, which is an e_assign
  internal_clk50Meg <= out_clk_altpll_0_c0;
  --pcp_clk out_clk assignment, which is an e_assign
  internal_pcp_clk <= out_clk_altpll_0_c1;
  --clk100Meg out_clk assignment, which is an e_assign
  internal_clk100Meg <= out_clk_altpll_0_c2;
  --ap_clk out_clk assignment, which is an e_assign
  internal_ap_clk <= out_clk_altpll_0_c3;
  --clk25Meg out_clk assignment, which is an e_assign
  internal_clk25Meg <= out_clk_altpll_0_c4;
  --the_altpll_0, which is an e_ptf_instance
  the_altpll_0 : altpll_0
    port map(
      c0 => out_clk_altpll_0_c0,
      c1 => out_clk_altpll_0_c1,
      c2 => out_clk_altpll_0_c2,
      c3 => out_clk_altpll_0_c3,
      c4 => out_clk_altpll_0_c4,
      locked => internal_locked_from_the_altpll_0,
      phasedone => internal_phasedone_from_the_altpll_0,
      readdata => altpll_0_pll_slave_readdata,
      address => altpll_0_pll_slave_address,
      clk => clk_0,
      read => altpll_0_pll_slave_read,
      reset => altpll_0_pll_slave_reset,
      write => altpll_0_pll_slave_write,
      writedata => altpll_0_pll_slave_writedata
    );


  --the_avalon_master_bridge_0_AvalonMaster, which is an e_instance
  the_avalon_master_bridge_0_AvalonMaster : avalon_master_bridge_0_AvalonMaster_arbitrator
    port map(
      ap_irq_to_the_avalon_master_bridge_0 => internal_ap_irq_to_the_avalon_master_bridge_0,
      avalon_address_from_the_avalon_master_bridge_0_to_slave => avalon_address_from_the_avalon_master_bridge_0_to_slave,
      avalon_master_bridge_0_latency_counter => avalon_master_bridge_0_latency_counter,
      avalon_readdata_to_the_avalon_master_bridge_0 => internal_avalon_readdata_to_the_avalon_master_bridge_0,
      avalon_readdatavalid_to_the_avalon_master_bridge_0 => internal_avalon_readdatavalid_to_the_avalon_master_bridge_0,
      avalon_waitrequest_to_the_avalon_master_bridge_0 => internal_avalon_waitrequest_to_the_avalon_master_bridge_0,
      reset_to_the_avalon_master_bridge_0 => internal_reset_to_the_avalon_master_bridge_0,
      avalon_address_from_the_avalon_master_bridge_0 => avalon_address_from_the_avalon_master_bridge_0,
      avalon_byteenable_from_the_avalon_master_bridge_0 => avalon_byteenable_from_the_avalon_master_bridge_0,
      avalon_master_bridge_0_granted_powerlink_0_PDI_AP => avalon_master_bridge_0_granted_powerlink_0_PDI_AP,
      avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP => avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP,
      avalon_master_bridge_0_read_data_valid_powerlink_0_PDI_AP => avalon_master_bridge_0_read_data_valid_powerlink_0_PDI_AP,
      avalon_master_bridge_0_requests_powerlink_0_PDI_AP => avalon_master_bridge_0_requests_powerlink_0_PDI_AP,
      avalon_read_from_the_avalon_master_bridge_0 => avalon_read_from_the_avalon_master_bridge_0,
      avalon_write_from_the_avalon_master_bridge_0 => avalon_write_from_the_avalon_master_bridge_0,
      avalon_writedata_from_the_avalon_master_bridge_0 => avalon_writedata_from_the_avalon_master_bridge_0,
      clk => internal_ap_clk,
      d1_powerlink_0_PDI_AP_end_xfer => d1_powerlink_0_PDI_AP_end_xfer,
      powerlink_0_PDI_AP_irq_from_sa => powerlink_0_PDI_AP_irq_from_sa,
      powerlink_0_PDI_AP_readdata_from_sa => powerlink_0_PDI_AP_readdata_from_sa,
      powerlink_0_PDI_AP_wait_counter_eq_0 => powerlink_0_PDI_AP_wait_counter_eq_0,
      reset_n => ap_clk_reset_n
    );


  --the_clock_crossing_0_s1, which is an e_instance
  the_clock_crossing_0_s1 : clock_crossing_0_s1_arbitrator
    port map(
      clock_crossing_0_s1_address => clock_crossing_0_s1_address,
      clock_crossing_0_s1_byteenable => clock_crossing_0_s1_byteenable,
      clock_crossing_0_s1_endofpacket_from_sa => clock_crossing_0_s1_endofpacket_from_sa,
      clock_crossing_0_s1_nativeaddress => clock_crossing_0_s1_nativeaddress,
      clock_crossing_0_s1_read => clock_crossing_0_s1_read,
      clock_crossing_0_s1_readdata_from_sa => clock_crossing_0_s1_readdata_from_sa,
      clock_crossing_0_s1_reset_n => clock_crossing_0_s1_reset_n,
      clock_crossing_0_s1_waitrequest_from_sa => clock_crossing_0_s1_waitrequest_from_sa,
      clock_crossing_0_s1_write => clock_crossing_0_s1_write,
      clock_crossing_0_s1_writedata => clock_crossing_0_s1_writedata,
      d1_clock_crossing_0_s1_end_xfer => d1_clock_crossing_0_s1_end_xfer,
      pcp_cpu_data_master_granted_clock_crossing_0_s1 => pcp_cpu_data_master_granted_clock_crossing_0_s1,
      pcp_cpu_data_master_qualified_request_clock_crossing_0_s1 => pcp_cpu_data_master_qualified_request_clock_crossing_0_s1,
      pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1 => pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1,
      pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register => pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register,
      pcp_cpu_data_master_requests_clock_crossing_0_s1 => pcp_cpu_data_master_requests_clock_crossing_0_s1,
      clk => internal_pcp_clk,
      clock_crossing_0_s1_endofpacket => clock_crossing_0_s1_endofpacket,
      clock_crossing_0_s1_readdata => clock_crossing_0_s1_readdata,
      clock_crossing_0_s1_readdatavalid => clock_crossing_0_s1_readdatavalid,
      clock_crossing_0_s1_waitrequest => clock_crossing_0_s1_waitrequest,
      pcp_cpu_data_master_address_to_slave => pcp_cpu_data_master_address_to_slave,
      pcp_cpu_data_master_byteenable => pcp_cpu_data_master_byteenable,
      pcp_cpu_data_master_read => pcp_cpu_data_master_read,
      pcp_cpu_data_master_waitrequest => pcp_cpu_data_master_waitrequest,
      pcp_cpu_data_master_write => pcp_cpu_data_master_write,
      pcp_cpu_data_master_writedata => pcp_cpu_data_master_writedata,
      reset_n => pcp_clk_reset_n
    );


  --the_clock_crossing_0_m1, which is an e_instance
  the_clock_crossing_0_m1 : clock_crossing_0_m1_arbitrator
    port map(
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_dbs_address => clock_crossing_0_m1_dbs_address,
      clock_crossing_0_m1_dbs_write_16 => clock_crossing_0_m1_dbs_write_16,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_readdata => clock_crossing_0_m1_readdata,
      clock_crossing_0_m1_readdatavalid => clock_crossing_0_m1_readdatavalid,
      clock_crossing_0_m1_reset_n => clock_crossing_0_m1_reset_n,
      clock_crossing_0_m1_waitrequest => clock_crossing_0_m1_waitrequest,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address => clock_crossing_0_m1_address,
      clock_crossing_0_m1_byteenable => clock_crossing_0_m1_byteenable,
      clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG => clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG,
      clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave => clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave,
      clock_crossing_0_m1_granted_node_switch_pio_s1 => clock_crossing_0_m1_granted_node_switch_pio_s1,
      clock_crossing_0_m1_granted_powerlink_0_MAC_CMP => clock_crossing_0_m1_granted_powerlink_0_MAC_CMP,
      clock_crossing_0_m1_granted_powerlink_0_MAC_REG => clock_crossing_0_m1_granted_powerlink_0_MAC_REG,
      clock_crossing_0_m1_granted_status_led_pio_s1 => clock_crossing_0_m1_granted_status_led_pio_s1,
      clock_crossing_0_m1_granted_system_timer_s1 => clock_crossing_0_m1_granted_system_timer_s1,
      clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave => clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave,
      clock_crossing_0_m1_qualified_request_node_switch_pio_s1 => clock_crossing_0_m1_qualified_request_node_switch_pio_s1,
      clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP => clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP,
      clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG => clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG,
      clock_crossing_0_m1_qualified_request_status_led_pio_s1 => clock_crossing_0_m1_qualified_request_status_led_pio_s1,
      clock_crossing_0_m1_qualified_request_system_timer_s1 => clock_crossing_0_m1_qualified_request_system_timer_s1,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_read_data_valid_jtag_uart_0_avalon_jtag_slave => clock_crossing_0_m1_read_data_valid_jtag_uart_0_avalon_jtag_slave,
      clock_crossing_0_m1_read_data_valid_node_switch_pio_s1 => clock_crossing_0_m1_read_data_valid_node_switch_pio_s1,
      clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_CMP => clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_CMP,
      clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_REG => clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_REG,
      clock_crossing_0_m1_read_data_valid_status_led_pio_s1 => clock_crossing_0_m1_read_data_valid_status_led_pio_s1,
      clock_crossing_0_m1_read_data_valid_system_timer_s1 => clock_crossing_0_m1_read_data_valid_system_timer_s1,
      clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave => clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave,
      clock_crossing_0_m1_requests_node_switch_pio_s1 => clock_crossing_0_m1_requests_node_switch_pio_s1,
      clock_crossing_0_m1_requests_powerlink_0_MAC_CMP => clock_crossing_0_m1_requests_powerlink_0_MAC_CMP,
      clock_crossing_0_m1_requests_powerlink_0_MAC_REG => clock_crossing_0_m1_requests_powerlink_0_MAC_REG,
      clock_crossing_0_m1_requests_status_led_pio_s1 => clock_crossing_0_m1_requests_status_led_pio_s1,
      clock_crossing_0_m1_requests_system_timer_s1 => clock_crossing_0_m1_requests_system_timer_s1,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      clock_crossing_0_m1_writedata => clock_crossing_0_m1_writedata,
      d1_jtag_uart_0_avalon_jtag_slave_end_xfer => d1_jtag_uart_0_avalon_jtag_slave_end_xfer,
      d1_node_switch_pio_s1_end_xfer => d1_node_switch_pio_s1_end_xfer,
      d1_powerlink_0_MAC_CMP_end_xfer => d1_powerlink_0_MAC_CMP_end_xfer,
      d1_powerlink_0_MAC_REG_end_xfer => d1_powerlink_0_MAC_REG_end_xfer,
      d1_status_led_pio_s1_end_xfer => d1_status_led_pio_s1_end_xfer,
      d1_system_timer_s1_end_xfer => d1_system_timer_s1_end_xfer,
      jtag_uart_0_avalon_jtag_slave_readdata_from_sa => jtag_uart_0_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa,
      node_switch_pio_s1_readdata_from_sa => node_switch_pio_s1_readdata_from_sa,
      powerlink_0_MAC_CMP_readdata_from_sa => powerlink_0_MAC_CMP_readdata_from_sa,
      powerlink_0_MAC_REG_readdata_from_sa => powerlink_0_MAC_REG_readdata_from_sa,
      reset_n => clk50Meg_reset_n,
      status_led_pio_s1_readdata_from_sa => status_led_pio_s1_readdata_from_sa,
      system_timer_s1_readdata_from_sa => system_timer_s1_readdata_from_sa
    );


  --the_clock_crossing_0, which is an e_ptf_instance
  the_clock_crossing_0 : clock_crossing_0
    port map(
      master_address => clock_crossing_0_m1_address,
      master_byteenable => clock_crossing_0_m1_byteenable,
      master_nativeaddress => clock_crossing_0_m1_nativeaddress,
      master_read => clock_crossing_0_m1_read,
      master_write => clock_crossing_0_m1_write,
      master_writedata => clock_crossing_0_m1_writedata,
      slave_endofpacket => clock_crossing_0_s1_endofpacket,
      slave_readdata => clock_crossing_0_s1_readdata,
      slave_readdatavalid => clock_crossing_0_s1_readdatavalid,
      slave_waitrequest => clock_crossing_0_s1_waitrequest,
      master_clk => internal_clk50Meg,
      master_endofpacket => clock_crossing_0_m1_endofpacket,
      master_readdata => clock_crossing_0_m1_readdata,
      master_readdatavalid => clock_crossing_0_m1_readdatavalid,
      master_reset_n => clock_crossing_0_m1_reset_n,
      master_waitrequest => clock_crossing_0_m1_waitrequest,
      slave_address => clock_crossing_0_s1_address,
      slave_byteenable => clock_crossing_0_s1_byteenable,
      slave_clk => internal_pcp_clk,
      slave_nativeaddress => clock_crossing_0_s1_nativeaddress,
      slave_read => clock_crossing_0_s1_read,
      slave_reset_n => clock_crossing_0_s1_reset_n,
      slave_write => clock_crossing_0_s1_write,
      slave_writedata => clock_crossing_0_s1_writedata
    );


  --the_epcs_flash_controller_0_epcs_control_port, which is an e_instance
  the_epcs_flash_controller_0_epcs_control_port : epcs_flash_controller_0_epcs_control_port_arbitrator
    port map(
      d1_epcs_flash_controller_0_epcs_control_port_end_xfer => d1_epcs_flash_controller_0_epcs_control_port_end_xfer,
      epcs_flash_controller_0_epcs_control_port_address => epcs_flash_controller_0_epcs_control_port_address,
      epcs_flash_controller_0_epcs_control_port_chipselect => epcs_flash_controller_0_epcs_control_port_chipselect,
      epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa => epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa,
      epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa => epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa,
      epcs_flash_controller_0_epcs_control_port_irq_from_sa => epcs_flash_controller_0_epcs_control_port_irq_from_sa,
      epcs_flash_controller_0_epcs_control_port_read_n => epcs_flash_controller_0_epcs_control_port_read_n,
      epcs_flash_controller_0_epcs_control_port_readdata_from_sa => epcs_flash_controller_0_epcs_control_port_readdata_from_sa,
      epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa => epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa,
      epcs_flash_controller_0_epcs_control_port_reset_n => epcs_flash_controller_0_epcs_control_port_reset_n,
      epcs_flash_controller_0_epcs_control_port_write_n => epcs_flash_controller_0_epcs_control_port_write_n,
      epcs_flash_controller_0_epcs_control_port_writedata => epcs_flash_controller_0_epcs_control_port_writedata,
      pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port => pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port => pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port => pcp_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port => pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port => pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port => pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port => pcp_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port => pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port,
      clk => internal_pcp_clk,
      epcs_flash_controller_0_epcs_control_port_dataavailable => epcs_flash_controller_0_epcs_control_port_dataavailable,
      epcs_flash_controller_0_epcs_control_port_endofpacket => epcs_flash_controller_0_epcs_control_port_endofpacket,
      epcs_flash_controller_0_epcs_control_port_irq => epcs_flash_controller_0_epcs_control_port_irq,
      epcs_flash_controller_0_epcs_control_port_readdata => epcs_flash_controller_0_epcs_control_port_readdata,
      epcs_flash_controller_0_epcs_control_port_readyfordata => epcs_flash_controller_0_epcs_control_port_readyfordata,
      pcp_cpu_data_master_address_to_slave => pcp_cpu_data_master_address_to_slave,
      pcp_cpu_data_master_read => pcp_cpu_data_master_read,
      pcp_cpu_data_master_write => pcp_cpu_data_master_write,
      pcp_cpu_data_master_writedata => pcp_cpu_data_master_writedata,
      pcp_cpu_instruction_master_address_to_slave => pcp_cpu_instruction_master_address_to_slave,
      pcp_cpu_instruction_master_latency_counter => pcp_cpu_instruction_master_latency_counter,
      pcp_cpu_instruction_master_read => pcp_cpu_instruction_master_read,
      reset_n => pcp_clk_reset_n
    );


  --the_epcs_flash_controller_0, which is an e_ptf_instance
  the_epcs_flash_controller_0 : epcs_flash_controller_0
    port map(
      dataavailable => epcs_flash_controller_0_epcs_control_port_dataavailable,
      dclk => internal_dclk_from_the_epcs_flash_controller_0,
      endofpacket => epcs_flash_controller_0_epcs_control_port_endofpacket,
      irq => epcs_flash_controller_0_epcs_control_port_irq,
      readdata => epcs_flash_controller_0_epcs_control_port_readdata,
      readyfordata => epcs_flash_controller_0_epcs_control_port_readyfordata,
      sce => internal_sce_from_the_epcs_flash_controller_0,
      sdo => internal_sdo_from_the_epcs_flash_controller_0,
      address => epcs_flash_controller_0_epcs_control_port_address,
      chipselect => epcs_flash_controller_0_epcs_control_port_chipselect,
      clk => internal_pcp_clk,
      data0 => data0_to_the_epcs_flash_controller_0,
      read_n => epcs_flash_controller_0_epcs_control_port_read_n,
      reset_n => epcs_flash_controller_0_epcs_control_port_reset_n,
      write_n => epcs_flash_controller_0_epcs_control_port_write_n,
      writedata => epcs_flash_controller_0_epcs_control_port_writedata
    );


  --the_jtag_uart_0_avalon_jtag_slave, which is an e_instance
  the_jtag_uart_0_avalon_jtag_slave : jtag_uart_0_avalon_jtag_slave_arbitrator
    port map(
      clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave => clock_crossing_0_m1_granted_jtag_uart_0_avalon_jtag_slave,
      clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave => clock_crossing_0_m1_qualified_request_jtag_uart_0_avalon_jtag_slave,
      clock_crossing_0_m1_read_data_valid_jtag_uart_0_avalon_jtag_slave => clock_crossing_0_m1_read_data_valid_jtag_uart_0_avalon_jtag_slave,
      clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave => clock_crossing_0_m1_requests_jtag_uart_0_avalon_jtag_slave,
      d1_jtag_uart_0_avalon_jtag_slave_end_xfer => d1_jtag_uart_0_avalon_jtag_slave_end_xfer,
      jtag_uart_0_avalon_jtag_slave_address => jtag_uart_0_avalon_jtag_slave_address,
      jtag_uart_0_avalon_jtag_slave_chipselect => jtag_uart_0_avalon_jtag_slave_chipselect,
      jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa => jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa,
      jtag_uart_0_avalon_jtag_slave_irq_from_sa => jtag_uart_0_avalon_jtag_slave_irq_from_sa,
      jtag_uart_0_avalon_jtag_slave_read_n => jtag_uart_0_avalon_jtag_slave_read_n,
      jtag_uart_0_avalon_jtag_slave_readdata_from_sa => jtag_uart_0_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa => jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa,
      jtag_uart_0_avalon_jtag_slave_reset_n => jtag_uart_0_avalon_jtag_slave_reset_n,
      jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_0_avalon_jtag_slave_waitrequest_from_sa,
      jtag_uart_0_avalon_jtag_slave_write_n => jtag_uart_0_avalon_jtag_slave_write_n,
      jtag_uart_0_avalon_jtag_slave_writedata => jtag_uart_0_avalon_jtag_slave_writedata,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_nativeaddress => clock_crossing_0_m1_nativeaddress,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      clock_crossing_0_m1_writedata => clock_crossing_0_m1_writedata,
      jtag_uart_0_avalon_jtag_slave_dataavailable => jtag_uart_0_avalon_jtag_slave_dataavailable,
      jtag_uart_0_avalon_jtag_slave_irq => jtag_uart_0_avalon_jtag_slave_irq,
      jtag_uart_0_avalon_jtag_slave_readdata => jtag_uart_0_avalon_jtag_slave_readdata,
      jtag_uart_0_avalon_jtag_slave_readyfordata => jtag_uart_0_avalon_jtag_slave_readyfordata,
      jtag_uart_0_avalon_jtag_slave_waitrequest => jtag_uart_0_avalon_jtag_slave_waitrequest,
      reset_n => clk50Meg_reset_n
    );


  --the_jtag_uart_0, which is an e_ptf_instance
  the_jtag_uart_0 : jtag_uart_0
    port map(
      av_irq => jtag_uart_0_avalon_jtag_slave_irq,
      av_readdata => jtag_uart_0_avalon_jtag_slave_readdata,
      av_waitrequest => jtag_uart_0_avalon_jtag_slave_waitrequest,
      dataavailable => jtag_uart_0_avalon_jtag_slave_dataavailable,
      readyfordata => jtag_uart_0_avalon_jtag_slave_readyfordata,
      av_address => jtag_uart_0_avalon_jtag_slave_address,
      av_chipselect => jtag_uart_0_avalon_jtag_slave_chipselect,
      av_read_n => jtag_uart_0_avalon_jtag_slave_read_n,
      av_write_n => jtag_uart_0_avalon_jtag_slave_write_n,
      av_writedata => jtag_uart_0_avalon_jtag_slave_writedata,
      clk => internal_clk50Meg,
      rst_n => jtag_uart_0_avalon_jtag_slave_reset_n
    );


  --the_niosII_openMac_clock_0_in, which is an e_instance
  the_niosII_openMac_clock_0_in : niosII_openMac_clock_0_in_arbitrator
    port map(
      d1_niosII_openMac_clock_0_in_end_xfer => d1_niosII_openMac_clock_0_in_end_xfer,
      niosII_openMac_clock_0_in_address => niosII_openMac_clock_0_in_address,
      niosII_openMac_clock_0_in_byteenable => niosII_openMac_clock_0_in_byteenable,
      niosII_openMac_clock_0_in_endofpacket_from_sa => niosII_openMac_clock_0_in_endofpacket_from_sa,
      niosII_openMac_clock_0_in_nativeaddress => niosII_openMac_clock_0_in_nativeaddress,
      niosII_openMac_clock_0_in_read => niosII_openMac_clock_0_in_read,
      niosII_openMac_clock_0_in_readdata_from_sa => niosII_openMac_clock_0_in_readdata_from_sa,
      niosII_openMac_clock_0_in_reset_n => niosII_openMac_clock_0_in_reset_n,
      niosII_openMac_clock_0_in_waitrequest_from_sa => niosII_openMac_clock_0_in_waitrequest_from_sa,
      niosII_openMac_clock_0_in_write => niosII_openMac_clock_0_in_write,
      niosII_openMac_clock_0_in_writedata => niosII_openMac_clock_0_in_writedata,
      pcp_cpu_data_master_granted_niosII_openMac_clock_0_in => pcp_cpu_data_master_granted_niosII_openMac_clock_0_in,
      pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in => pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in,
      pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_0_in => pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_0_in,
      pcp_cpu_data_master_requests_niosII_openMac_clock_0_in => pcp_cpu_data_master_requests_niosII_openMac_clock_0_in,
      clk => internal_pcp_clk,
      niosII_openMac_clock_0_in_endofpacket => niosII_openMac_clock_0_in_endofpacket,
      niosII_openMac_clock_0_in_readdata => niosII_openMac_clock_0_in_readdata,
      niosII_openMac_clock_0_in_waitrequest => niosII_openMac_clock_0_in_waitrequest,
      pcp_cpu_data_master_address_to_slave => pcp_cpu_data_master_address_to_slave,
      pcp_cpu_data_master_byteenable => pcp_cpu_data_master_byteenable,
      pcp_cpu_data_master_read => pcp_cpu_data_master_read,
      pcp_cpu_data_master_waitrequest => pcp_cpu_data_master_waitrequest,
      pcp_cpu_data_master_write => pcp_cpu_data_master_write,
      pcp_cpu_data_master_writedata => pcp_cpu_data_master_writedata,
      reset_n => pcp_clk_reset_n
    );


  --the_niosII_openMac_clock_0_out, which is an e_instance
  the_niosII_openMac_clock_0_out : niosII_openMac_clock_0_out_arbitrator
    port map(
      niosII_openMac_clock_0_out_address_to_slave => niosII_openMac_clock_0_out_address_to_slave,
      niosII_openMac_clock_0_out_readdata => niosII_openMac_clock_0_out_readdata,
      niosII_openMac_clock_0_out_reset_n => niosII_openMac_clock_0_out_reset_n,
      niosII_openMac_clock_0_out_waitrequest => niosII_openMac_clock_0_out_waitrequest,
      altpll_0_pll_slave_readdata_from_sa => altpll_0_pll_slave_readdata_from_sa,
      clk => clk_0,
      d1_altpll_0_pll_slave_end_xfer => d1_altpll_0_pll_slave_end_xfer,
      niosII_openMac_clock_0_out_address => niosII_openMac_clock_0_out_address,
      niosII_openMac_clock_0_out_byteenable => niosII_openMac_clock_0_out_byteenable,
      niosII_openMac_clock_0_out_granted_altpll_0_pll_slave => niosII_openMac_clock_0_out_granted_altpll_0_pll_slave,
      niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave => niosII_openMac_clock_0_out_qualified_request_altpll_0_pll_slave,
      niosII_openMac_clock_0_out_read => niosII_openMac_clock_0_out_read,
      niosII_openMac_clock_0_out_read_data_valid_altpll_0_pll_slave => niosII_openMac_clock_0_out_read_data_valid_altpll_0_pll_slave,
      niosII_openMac_clock_0_out_requests_altpll_0_pll_slave => niosII_openMac_clock_0_out_requests_altpll_0_pll_slave,
      niosII_openMac_clock_0_out_write => niosII_openMac_clock_0_out_write,
      niosII_openMac_clock_0_out_writedata => niosII_openMac_clock_0_out_writedata,
      reset_n => clk_0_reset_n
    );


  --the_niosII_openMac_clock_0, which is an e_ptf_instance
  the_niosII_openMac_clock_0 : niosII_openMac_clock_0
    port map(
      master_address => niosII_openMac_clock_0_out_address,
      master_byteenable => niosII_openMac_clock_0_out_byteenable,
      master_nativeaddress => niosII_openMac_clock_0_out_nativeaddress,
      master_read => niosII_openMac_clock_0_out_read,
      master_write => niosII_openMac_clock_0_out_write,
      master_writedata => niosII_openMac_clock_0_out_writedata,
      slave_endofpacket => niosII_openMac_clock_0_in_endofpacket,
      slave_readdata => niosII_openMac_clock_0_in_readdata,
      slave_waitrequest => niosII_openMac_clock_0_in_waitrequest,
      master_clk => clk_0,
      master_endofpacket => niosII_openMac_clock_0_out_endofpacket,
      master_readdata => niosII_openMac_clock_0_out_readdata,
      master_reset_n => niosII_openMac_clock_0_out_reset_n,
      master_waitrequest => niosII_openMac_clock_0_out_waitrequest,
      slave_address => niosII_openMac_clock_0_in_address,
      slave_byteenable => niosII_openMac_clock_0_in_byteenable,
      slave_clk => internal_pcp_clk,
      slave_nativeaddress => niosII_openMac_clock_0_in_nativeaddress,
      slave_read => niosII_openMac_clock_0_in_read,
      slave_reset_n => niosII_openMac_clock_0_in_reset_n,
      slave_write => niosII_openMac_clock_0_in_write,
      slave_writedata => niosII_openMac_clock_0_in_writedata
    );


  --the_niosII_openMac_clock_1_in, which is an e_instance
  the_niosII_openMac_clock_1_in : niosII_openMac_clock_1_in_arbitrator
    port map(
      d1_niosII_openMac_clock_1_in_end_xfer => d1_niosII_openMac_clock_1_in_end_xfer,
      niosII_openMac_clock_1_in_address => niosII_openMac_clock_1_in_address,
      niosII_openMac_clock_1_in_byteenable => niosII_openMac_clock_1_in_byteenable,
      niosII_openMac_clock_1_in_endofpacket_from_sa => niosII_openMac_clock_1_in_endofpacket_from_sa,
      niosII_openMac_clock_1_in_nativeaddress => niosII_openMac_clock_1_in_nativeaddress,
      niosII_openMac_clock_1_in_read => niosII_openMac_clock_1_in_read,
      niosII_openMac_clock_1_in_readdata_from_sa => niosII_openMac_clock_1_in_readdata_from_sa,
      niosII_openMac_clock_1_in_reset_n => niosII_openMac_clock_1_in_reset_n,
      niosII_openMac_clock_1_in_waitrequest_from_sa => niosII_openMac_clock_1_in_waitrequest_from_sa,
      niosII_openMac_clock_1_in_write => niosII_openMac_clock_1_in_write,
      niosII_openMac_clock_1_in_writedata => niosII_openMac_clock_1_in_writedata,
      pcp_cpu_data_master_granted_niosII_openMac_clock_1_in => pcp_cpu_data_master_granted_niosII_openMac_clock_1_in,
      pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in => pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in,
      pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in => pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in,
      pcp_cpu_data_master_requests_niosII_openMac_clock_1_in => pcp_cpu_data_master_requests_niosII_openMac_clock_1_in,
      clk => internal_pcp_clk,
      niosII_openMac_clock_1_in_endofpacket => niosII_openMac_clock_1_in_endofpacket,
      niosII_openMac_clock_1_in_readdata => niosII_openMac_clock_1_in_readdata,
      niosII_openMac_clock_1_in_waitrequest => niosII_openMac_clock_1_in_waitrequest,
      pcp_cpu_data_master_address_to_slave => pcp_cpu_data_master_address_to_slave,
      pcp_cpu_data_master_byteenable => pcp_cpu_data_master_byteenable,
      pcp_cpu_data_master_read => pcp_cpu_data_master_read,
      pcp_cpu_data_master_waitrequest => pcp_cpu_data_master_waitrequest,
      pcp_cpu_data_master_write => pcp_cpu_data_master_write,
      pcp_cpu_data_master_writedata => pcp_cpu_data_master_writedata,
      reset_n => pcp_clk_reset_n
    );


  --the_niosII_openMac_clock_1_out, which is an e_instance
  the_niosII_openMac_clock_1_out : niosII_openMac_clock_1_out_arbitrator
    port map(
      niosII_openMac_clock_1_out_address_to_slave => niosII_openMac_clock_1_out_address_to_slave,
      niosII_openMac_clock_1_out_readdata => niosII_openMac_clock_1_out_readdata,
      niosII_openMac_clock_1_out_reset_n => niosII_openMac_clock_1_out_reset_n,
      niosII_openMac_clock_1_out_waitrequest => niosII_openMac_clock_1_out_waitrequest,
      clk => internal_clk25Meg,
      d1_remote_update_cycloneiii_0_s1_end_xfer => d1_remote_update_cycloneiii_0_s1_end_xfer,
      niosII_openMac_clock_1_out_address => niosII_openMac_clock_1_out_address,
      niosII_openMac_clock_1_out_byteenable => niosII_openMac_clock_1_out_byteenable,
      niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_1_out_read => niosII_openMac_clock_1_out_read,
      niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_1_out_write => niosII_openMac_clock_1_out_write,
      niosII_openMac_clock_1_out_writedata => niosII_openMac_clock_1_out_writedata,
      remote_update_cycloneiii_0_s1_readdata_from_sa => remote_update_cycloneiii_0_s1_readdata_from_sa,
      remote_update_cycloneiii_0_s1_waitrequest_from_sa => remote_update_cycloneiii_0_s1_waitrequest_from_sa,
      reset_n => clk25Meg_reset_n
    );


  --the_niosII_openMac_clock_1, which is an e_ptf_instance
  the_niosII_openMac_clock_1 : niosII_openMac_clock_1
    port map(
      master_address => niosII_openMac_clock_1_out_address,
      master_byteenable => niosII_openMac_clock_1_out_byteenable,
      master_nativeaddress => niosII_openMac_clock_1_out_nativeaddress,
      master_read => niosII_openMac_clock_1_out_read,
      master_write => niosII_openMac_clock_1_out_write,
      master_writedata => niosII_openMac_clock_1_out_writedata,
      slave_endofpacket => niosII_openMac_clock_1_in_endofpacket,
      slave_readdata => niosII_openMac_clock_1_in_readdata,
      slave_waitrequest => niosII_openMac_clock_1_in_waitrequest,
      master_clk => internal_clk25Meg,
      master_endofpacket => niosII_openMac_clock_1_out_endofpacket,
      master_readdata => niosII_openMac_clock_1_out_readdata,
      master_reset_n => niosII_openMac_clock_1_out_reset_n,
      master_waitrequest => niosII_openMac_clock_1_out_waitrequest,
      slave_address => niosII_openMac_clock_1_in_address,
      slave_byteenable => niosII_openMac_clock_1_in_byteenable,
      slave_clk => internal_pcp_clk,
      slave_nativeaddress => niosII_openMac_clock_1_in_nativeaddress,
      slave_read => niosII_openMac_clock_1_in_read,
      slave_reset_n => niosII_openMac_clock_1_in_reset_n,
      slave_write => niosII_openMac_clock_1_in_write,
      slave_writedata => niosII_openMac_clock_1_in_writedata
    );


  --the_node_switch_pio_s1, which is an e_instance
  the_node_switch_pio_s1 : node_switch_pio_s1_arbitrator
    port map(
      clock_crossing_0_m1_granted_node_switch_pio_s1 => clock_crossing_0_m1_granted_node_switch_pio_s1,
      clock_crossing_0_m1_qualified_request_node_switch_pio_s1 => clock_crossing_0_m1_qualified_request_node_switch_pio_s1,
      clock_crossing_0_m1_read_data_valid_node_switch_pio_s1 => clock_crossing_0_m1_read_data_valid_node_switch_pio_s1,
      clock_crossing_0_m1_requests_node_switch_pio_s1 => clock_crossing_0_m1_requests_node_switch_pio_s1,
      d1_node_switch_pio_s1_end_xfer => d1_node_switch_pio_s1_end_xfer,
      node_switch_pio_s1_address => node_switch_pio_s1_address,
      node_switch_pio_s1_readdata_from_sa => node_switch_pio_s1_readdata_from_sa,
      node_switch_pio_s1_reset_n => node_switch_pio_s1_reset_n,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_nativeaddress => clock_crossing_0_m1_nativeaddress,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      node_switch_pio_s1_readdata => node_switch_pio_s1_readdata,
      reset_n => clk50Meg_reset_n
    );


  --the_node_switch_pio, which is an e_ptf_instance
  the_node_switch_pio : node_switch_pio
    port map(
      readdata => node_switch_pio_s1_readdata,
      address => node_switch_pio_s1_address,
      clk => internal_clk50Meg,
      in_port => in_port_to_the_node_switch_pio,
      reset_n => node_switch_pio_s1_reset_n
    );


  --the_onchip_memory_0_s1, which is an e_instance
  the_onchip_memory_0_s1 : onchip_memory_0_s1_arbitrator
    port map(
      d1_onchip_memory_0_s1_end_xfer => d1_onchip_memory_0_s1_end_xfer,
      onchip_memory_0_s1_address => onchip_memory_0_s1_address,
      onchip_memory_0_s1_byteenable => onchip_memory_0_s1_byteenable,
      onchip_memory_0_s1_chipselect => onchip_memory_0_s1_chipselect,
      onchip_memory_0_s1_clken => onchip_memory_0_s1_clken,
      onchip_memory_0_s1_readdata_from_sa => onchip_memory_0_s1_readdata_from_sa,
      onchip_memory_0_s1_write => onchip_memory_0_s1_write,
      onchip_memory_0_s1_writedata => onchip_memory_0_s1_writedata,
      pcp_cpu_data_master_granted_onchip_memory_0_s1 => pcp_cpu_data_master_granted_onchip_memory_0_s1,
      pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 => pcp_cpu_data_master_qualified_request_onchip_memory_0_s1,
      pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 => pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1,
      pcp_cpu_data_master_requests_onchip_memory_0_s1 => pcp_cpu_data_master_requests_onchip_memory_0_s1,
      pcp_cpu_instruction_master_granted_onchip_memory_0_s1 => pcp_cpu_instruction_master_granted_onchip_memory_0_s1,
      pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1 => pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1,
      pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 => pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1,
      pcp_cpu_instruction_master_requests_onchip_memory_0_s1 => pcp_cpu_instruction_master_requests_onchip_memory_0_s1,
      registered_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 => registered_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1,
      clk => internal_pcp_clk,
      onchip_memory_0_s1_readdata => onchip_memory_0_s1_readdata,
      pcp_cpu_data_master_address_to_slave => pcp_cpu_data_master_address_to_slave,
      pcp_cpu_data_master_byteenable => pcp_cpu_data_master_byteenable,
      pcp_cpu_data_master_read => pcp_cpu_data_master_read,
      pcp_cpu_data_master_waitrequest => pcp_cpu_data_master_waitrequest,
      pcp_cpu_data_master_write => pcp_cpu_data_master_write,
      pcp_cpu_data_master_writedata => pcp_cpu_data_master_writedata,
      pcp_cpu_instruction_master_address_to_slave => pcp_cpu_instruction_master_address_to_slave,
      pcp_cpu_instruction_master_latency_counter => pcp_cpu_instruction_master_latency_counter,
      pcp_cpu_instruction_master_read => pcp_cpu_instruction_master_read,
      reset_n => pcp_clk_reset_n
    );


  --the_onchip_memory_0, which is an e_ptf_instance
  the_onchip_memory_0 : onchip_memory_0
    port map(
      readdata => onchip_memory_0_s1_readdata,
      address => onchip_memory_0_s1_address,
      byteenable => onchip_memory_0_s1_byteenable,
      chipselect => onchip_memory_0_s1_chipselect,
      clk => internal_pcp_clk,
      clken => onchip_memory_0_s1_clken,
      write => onchip_memory_0_s1_write,
      writedata => onchip_memory_0_s1_writedata
    );


  --the_pcp_cpu_jtag_debug_module, which is an e_instance
  the_pcp_cpu_jtag_debug_module : pcp_cpu_jtag_debug_module_arbitrator
    port map(
      d1_pcp_cpu_jtag_debug_module_end_xfer => d1_pcp_cpu_jtag_debug_module_end_xfer,
      pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module => pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module,
      pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module => pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module,
      pcp_cpu_data_master_read_data_valid_pcp_cpu_jtag_debug_module => pcp_cpu_data_master_read_data_valid_pcp_cpu_jtag_debug_module,
      pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module => pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module,
      pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module => pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module,
      pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module => pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module,
      pcp_cpu_instruction_master_read_data_valid_pcp_cpu_jtag_debug_module => pcp_cpu_instruction_master_read_data_valid_pcp_cpu_jtag_debug_module,
      pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module => pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module,
      pcp_cpu_jtag_debug_module_address => pcp_cpu_jtag_debug_module_address,
      pcp_cpu_jtag_debug_module_begintransfer => pcp_cpu_jtag_debug_module_begintransfer,
      pcp_cpu_jtag_debug_module_byteenable => pcp_cpu_jtag_debug_module_byteenable,
      pcp_cpu_jtag_debug_module_chipselect => pcp_cpu_jtag_debug_module_chipselect,
      pcp_cpu_jtag_debug_module_debugaccess => pcp_cpu_jtag_debug_module_debugaccess,
      pcp_cpu_jtag_debug_module_readdata_from_sa => pcp_cpu_jtag_debug_module_readdata_from_sa,
      pcp_cpu_jtag_debug_module_reset_n => pcp_cpu_jtag_debug_module_reset_n,
      pcp_cpu_jtag_debug_module_resetrequest_from_sa => pcp_cpu_jtag_debug_module_resetrequest_from_sa,
      pcp_cpu_jtag_debug_module_write => pcp_cpu_jtag_debug_module_write,
      pcp_cpu_jtag_debug_module_writedata => pcp_cpu_jtag_debug_module_writedata,
      clk => internal_pcp_clk,
      pcp_cpu_data_master_address_to_slave => pcp_cpu_data_master_address_to_slave,
      pcp_cpu_data_master_byteenable => pcp_cpu_data_master_byteenable,
      pcp_cpu_data_master_debugaccess => pcp_cpu_data_master_debugaccess,
      pcp_cpu_data_master_read => pcp_cpu_data_master_read,
      pcp_cpu_data_master_waitrequest => pcp_cpu_data_master_waitrequest,
      pcp_cpu_data_master_write => pcp_cpu_data_master_write,
      pcp_cpu_data_master_writedata => pcp_cpu_data_master_writedata,
      pcp_cpu_instruction_master_address_to_slave => pcp_cpu_instruction_master_address_to_slave,
      pcp_cpu_instruction_master_latency_counter => pcp_cpu_instruction_master_latency_counter,
      pcp_cpu_instruction_master_read => pcp_cpu_instruction_master_read,
      pcp_cpu_jtag_debug_module_readdata => pcp_cpu_jtag_debug_module_readdata,
      pcp_cpu_jtag_debug_module_resetrequest => pcp_cpu_jtag_debug_module_resetrequest,
      reset_n => pcp_clk_reset_n
    );


  --the_pcp_cpu_data_master, which is an e_instance
  the_pcp_cpu_data_master : pcp_cpu_data_master_arbitrator
    port map(
      pcp_cpu_data_master_address_to_slave => pcp_cpu_data_master_address_to_slave,
      pcp_cpu_data_master_dbs_address => pcp_cpu_data_master_dbs_address,
      pcp_cpu_data_master_dbs_write_16 => pcp_cpu_data_master_dbs_write_16,
      pcp_cpu_data_master_irq => pcp_cpu_data_master_irq,
      pcp_cpu_data_master_no_byte_enables_and_last_term => pcp_cpu_data_master_no_byte_enables_and_last_term,
      pcp_cpu_data_master_readdata => pcp_cpu_data_master_readdata,
      pcp_cpu_data_master_waitrequest => pcp_cpu_data_master_waitrequest,
      clk => internal_pcp_clk,
      clock_crossing_0_s1_readdata_from_sa => clock_crossing_0_s1_readdata_from_sa,
      clock_crossing_0_s1_waitrequest_from_sa => clock_crossing_0_s1_waitrequest_from_sa,
      d1_clock_crossing_0_s1_end_xfer => d1_clock_crossing_0_s1_end_xfer,
      d1_epcs_flash_controller_0_epcs_control_port_end_xfer => d1_epcs_flash_controller_0_epcs_control_port_end_xfer,
      d1_niosII_openMac_clock_0_in_end_xfer => d1_niosII_openMac_clock_0_in_end_xfer,
      d1_niosII_openMac_clock_1_in_end_xfer => d1_niosII_openMac_clock_1_in_end_xfer,
      d1_onchip_memory_0_s1_end_xfer => d1_onchip_memory_0_s1_end_xfer,
      d1_pcp_cpu_jtag_debug_module_end_xfer => d1_pcp_cpu_jtag_debug_module_end_xfer,
      d1_powerlink_0_MAC_BUF_end_xfer => d1_powerlink_0_MAC_BUF_end_xfer,
      d1_powerlink_0_PDI_PCP_end_xfer => d1_powerlink_0_PDI_PCP_end_xfer,
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      d1_tri_state_bridge_0_avalon_slave_end_xfer => d1_tri_state_bridge_0_avalon_slave_end_xfer,
      epcs_flash_controller_0_epcs_control_port_irq_from_sa => epcs_flash_controller_0_epcs_control_port_irq_from_sa,
      epcs_flash_controller_0_epcs_control_port_readdata_from_sa => epcs_flash_controller_0_epcs_control_port_readdata_from_sa,
      incoming_tri_state_bridge_0_data => incoming_tri_state_bridge_0_data,
      jtag_uart_0_avalon_jtag_slave_irq_from_sa => jtag_uart_0_avalon_jtag_slave_irq_from_sa,
      niosII_openMac_clock_0_in_readdata_from_sa => niosII_openMac_clock_0_in_readdata_from_sa,
      niosII_openMac_clock_0_in_waitrequest_from_sa => niosII_openMac_clock_0_in_waitrequest_from_sa,
      niosII_openMac_clock_1_in_readdata_from_sa => niosII_openMac_clock_1_in_readdata_from_sa,
      niosII_openMac_clock_1_in_waitrequest_from_sa => niosII_openMac_clock_1_in_waitrequest_from_sa,
      onchip_memory_0_s1_readdata_from_sa => onchip_memory_0_s1_readdata_from_sa,
      pcp_clk => internal_pcp_clk,
      pcp_clk_reset_n => pcp_clk_reset_n,
      pcp_cpu_data_master_address => pcp_cpu_data_master_address,
      pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_data_master_granted_clock_crossing_0_s1 => pcp_cpu_data_master_granted_clock_crossing_0_s1,
      pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port => pcp_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_data_master_granted_niosII_openMac_clock_0_in => pcp_cpu_data_master_granted_niosII_openMac_clock_0_in,
      pcp_cpu_data_master_granted_niosII_openMac_clock_1_in => pcp_cpu_data_master_granted_niosII_openMac_clock_1_in,
      pcp_cpu_data_master_granted_onchip_memory_0_s1 => pcp_cpu_data_master_granted_onchip_memory_0_s1,
      pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module => pcp_cpu_data_master_granted_pcp_cpu_jtag_debug_module,
      pcp_cpu_data_master_granted_powerlink_0_MAC_BUF => pcp_cpu_data_master_granted_powerlink_0_MAC_BUF,
      pcp_cpu_data_master_granted_powerlink_0_PDI_PCP => pcp_cpu_data_master_granted_powerlink_0_PDI_PCP,
      pcp_cpu_data_master_granted_sysid_control_slave => pcp_cpu_data_master_granted_sysid_control_slave,
      pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_data_master_qualified_request_clock_crossing_0_s1 => pcp_cpu_data_master_qualified_request_clock_crossing_0_s1,
      pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port => pcp_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in => pcp_cpu_data_master_qualified_request_niosII_openMac_clock_0_in,
      pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in => pcp_cpu_data_master_qualified_request_niosII_openMac_clock_1_in,
      pcp_cpu_data_master_qualified_request_onchip_memory_0_s1 => pcp_cpu_data_master_qualified_request_onchip_memory_0_s1,
      pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module => pcp_cpu_data_master_qualified_request_pcp_cpu_jtag_debug_module,
      pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF => pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF,
      pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP => pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP,
      pcp_cpu_data_master_qualified_request_sysid_control_slave => pcp_cpu_data_master_qualified_request_sysid_control_slave,
      pcp_cpu_data_master_read => pcp_cpu_data_master_read,
      pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1 => pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1,
      pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register => pcp_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register,
      pcp_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port => pcp_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_0_in => pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_0_in,
      pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in => pcp_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in,
      pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 => pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1,
      pcp_cpu_data_master_read_data_valid_pcp_cpu_jtag_debug_module => pcp_cpu_data_master_read_data_valid_pcp_cpu_jtag_debug_module,
      pcp_cpu_data_master_read_data_valid_powerlink_0_MAC_BUF => pcp_cpu_data_master_read_data_valid_powerlink_0_MAC_BUF,
      pcp_cpu_data_master_read_data_valid_powerlink_0_PDI_PCP => pcp_cpu_data_master_read_data_valid_powerlink_0_PDI_PCP,
      pcp_cpu_data_master_read_data_valid_sysid_control_slave => pcp_cpu_data_master_read_data_valid_sysid_control_slave,
      pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_data_master_requests_clock_crossing_0_s1 => pcp_cpu_data_master_requests_clock_crossing_0_s1,
      pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port => pcp_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_data_master_requests_niosII_openMac_clock_0_in => pcp_cpu_data_master_requests_niosII_openMac_clock_0_in,
      pcp_cpu_data_master_requests_niosII_openMac_clock_1_in => pcp_cpu_data_master_requests_niosII_openMac_clock_1_in,
      pcp_cpu_data_master_requests_onchip_memory_0_s1 => pcp_cpu_data_master_requests_onchip_memory_0_s1,
      pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module => pcp_cpu_data_master_requests_pcp_cpu_jtag_debug_module,
      pcp_cpu_data_master_requests_powerlink_0_MAC_BUF => pcp_cpu_data_master_requests_powerlink_0_MAC_BUF,
      pcp_cpu_data_master_requests_powerlink_0_PDI_PCP => pcp_cpu_data_master_requests_powerlink_0_PDI_PCP,
      pcp_cpu_data_master_requests_sysid_control_slave => pcp_cpu_data_master_requests_sysid_control_slave,
      pcp_cpu_data_master_write => pcp_cpu_data_master_write,
      pcp_cpu_data_master_writedata => pcp_cpu_data_master_writedata,
      pcp_cpu_jtag_debug_module_readdata_from_sa => pcp_cpu_jtag_debug_module_readdata_from_sa,
      powerlink_0_MAC_BUF_readdata_from_sa => powerlink_0_MAC_BUF_readdata_from_sa,
      powerlink_0_MAC_BUF_wait_counter_eq_0 => powerlink_0_MAC_BUF_wait_counter_eq_0,
      powerlink_0_MAC_CMP_irq_from_sa => powerlink_0_MAC_CMP_irq_from_sa,
      powerlink_0_MAC_REG_irq_from_sa => powerlink_0_MAC_REG_irq_from_sa,
      powerlink_0_PDI_PCP_readdata_from_sa => powerlink_0_PDI_PCP_readdata_from_sa,
      powerlink_0_PDI_PCP_wait_counter_eq_0 => powerlink_0_PDI_PCP_wait_counter_eq_0,
      registered_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave => registered_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave,
      registered_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1 => registered_pcp_cpu_data_master_read_data_valid_onchip_memory_0_s1,
      reset_n => pcp_clk_reset_n,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      system_timer_s1_irq_from_sa => system_timer_s1_irq_from_sa
    );


  --the_pcp_cpu_instruction_master, which is an e_instance
  the_pcp_cpu_instruction_master : pcp_cpu_instruction_master_arbitrator
    port map(
      pcp_cpu_instruction_master_address_to_slave => pcp_cpu_instruction_master_address_to_slave,
      pcp_cpu_instruction_master_dbs_address => pcp_cpu_instruction_master_dbs_address,
      pcp_cpu_instruction_master_latency_counter => pcp_cpu_instruction_master_latency_counter,
      pcp_cpu_instruction_master_readdata => pcp_cpu_instruction_master_readdata,
      pcp_cpu_instruction_master_readdatavalid => pcp_cpu_instruction_master_readdatavalid,
      pcp_cpu_instruction_master_waitrequest => pcp_cpu_instruction_master_waitrequest,
      clk => internal_pcp_clk,
      d1_epcs_flash_controller_0_epcs_control_port_end_xfer => d1_epcs_flash_controller_0_epcs_control_port_end_xfer,
      d1_onchip_memory_0_s1_end_xfer => d1_onchip_memory_0_s1_end_xfer,
      d1_pcp_cpu_jtag_debug_module_end_xfer => d1_pcp_cpu_jtag_debug_module_end_xfer,
      d1_tri_state_bridge_0_avalon_slave_end_xfer => d1_tri_state_bridge_0_avalon_slave_end_xfer,
      epcs_flash_controller_0_epcs_control_port_readdata_from_sa => epcs_flash_controller_0_epcs_control_port_readdata_from_sa,
      incoming_tri_state_bridge_0_data => incoming_tri_state_bridge_0_data,
      onchip_memory_0_s1_readdata_from_sa => onchip_memory_0_s1_readdata_from_sa,
      pcp_cpu_instruction_master_address => pcp_cpu_instruction_master_address,
      pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port => pcp_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_instruction_master_granted_onchip_memory_0_s1 => pcp_cpu_instruction_master_granted_onchip_memory_0_s1,
      pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module => pcp_cpu_instruction_master_granted_pcp_cpu_jtag_debug_module,
      pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port => pcp_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1 => pcp_cpu_instruction_master_qualified_request_onchip_memory_0_s1,
      pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module => pcp_cpu_instruction_master_qualified_request_pcp_cpu_jtag_debug_module,
      pcp_cpu_instruction_master_read => pcp_cpu_instruction_master_read,
      pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port => pcp_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 => pcp_cpu_instruction_master_read_data_valid_onchip_memory_0_s1,
      pcp_cpu_instruction_master_read_data_valid_pcp_cpu_jtag_debug_module => pcp_cpu_instruction_master_read_data_valid_pcp_cpu_jtag_debug_module,
      pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port => pcp_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port,
      pcp_cpu_instruction_master_requests_onchip_memory_0_s1 => pcp_cpu_instruction_master_requests_onchip_memory_0_s1,
      pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module => pcp_cpu_instruction_master_requests_pcp_cpu_jtag_debug_module,
      pcp_cpu_jtag_debug_module_readdata_from_sa => pcp_cpu_jtag_debug_module_readdata_from_sa,
      reset_n => pcp_clk_reset_n
    );


  --the_pcp_cpu, which is an e_ptf_instance
  the_pcp_cpu : pcp_cpu
    port map(
      d_address => pcp_cpu_data_master_address,
      d_byteenable => pcp_cpu_data_master_byteenable,
      d_read => pcp_cpu_data_master_read,
      d_write => pcp_cpu_data_master_write,
      d_writedata => pcp_cpu_data_master_writedata,
      i_address => pcp_cpu_instruction_master_address,
      i_read => pcp_cpu_instruction_master_read,
      jtag_debug_module_debugaccess_to_roms => pcp_cpu_data_master_debugaccess,
      jtag_debug_module_readdata => pcp_cpu_jtag_debug_module_readdata,
      jtag_debug_module_resetrequest => pcp_cpu_jtag_debug_module_resetrequest,
      clk => internal_pcp_clk,
      d_irq => pcp_cpu_data_master_irq,
      d_readdata => pcp_cpu_data_master_readdata,
      d_waitrequest => pcp_cpu_data_master_waitrequest,
      i_readdata => pcp_cpu_instruction_master_readdata,
      i_readdatavalid => pcp_cpu_instruction_master_readdatavalid,
      i_waitrequest => pcp_cpu_instruction_master_waitrequest,
      jtag_debug_module_address => pcp_cpu_jtag_debug_module_address,
      jtag_debug_module_begintransfer => pcp_cpu_jtag_debug_module_begintransfer,
      jtag_debug_module_byteenable => pcp_cpu_jtag_debug_module_byteenable,
      jtag_debug_module_debugaccess => pcp_cpu_jtag_debug_module_debugaccess,
      jtag_debug_module_select => pcp_cpu_jtag_debug_module_chipselect,
      jtag_debug_module_write => pcp_cpu_jtag_debug_module_write,
      jtag_debug_module_writedata => pcp_cpu_jtag_debug_module_writedata,
      reset_n => pcp_cpu_jtag_debug_module_reset_n
    );


  --the_powerlink_0_MAC_BUF, which is an e_instance
  the_powerlink_0_MAC_BUF : powerlink_0_MAC_BUF_arbitrator
    port map(
      d1_powerlink_0_MAC_BUF_end_xfer => d1_powerlink_0_MAC_BUF_end_xfer,
      pcp_cpu_data_master_granted_powerlink_0_MAC_BUF => pcp_cpu_data_master_granted_powerlink_0_MAC_BUF,
      pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF => pcp_cpu_data_master_qualified_request_powerlink_0_MAC_BUF,
      pcp_cpu_data_master_read_data_valid_powerlink_0_MAC_BUF => pcp_cpu_data_master_read_data_valid_powerlink_0_MAC_BUF,
      pcp_cpu_data_master_requests_powerlink_0_MAC_BUF => pcp_cpu_data_master_requests_powerlink_0_MAC_BUF,
      powerlink_0_MAC_BUF_address => powerlink_0_MAC_BUF_address,
      powerlink_0_MAC_BUF_byteenable => powerlink_0_MAC_BUF_byteenable,
      powerlink_0_MAC_BUF_chipselect => powerlink_0_MAC_BUF_chipselect,
      powerlink_0_MAC_BUF_read_n => powerlink_0_MAC_BUF_read_n,
      powerlink_0_MAC_BUF_readdata_from_sa => powerlink_0_MAC_BUF_readdata_from_sa,
      powerlink_0_MAC_BUF_reset => powerlink_0_MAC_BUF_reset,
      powerlink_0_MAC_BUF_wait_counter_eq_0 => powerlink_0_MAC_BUF_wait_counter_eq_0,
      powerlink_0_MAC_BUF_write_n => powerlink_0_MAC_BUF_write_n,
      powerlink_0_MAC_BUF_writedata => powerlink_0_MAC_BUF_writedata,
      clk => internal_pcp_clk,
      pcp_cpu_data_master_address_to_slave => pcp_cpu_data_master_address_to_slave,
      pcp_cpu_data_master_byteenable => pcp_cpu_data_master_byteenable,
      pcp_cpu_data_master_read => pcp_cpu_data_master_read,
      pcp_cpu_data_master_waitrequest => pcp_cpu_data_master_waitrequest,
      pcp_cpu_data_master_write => pcp_cpu_data_master_write,
      pcp_cpu_data_master_writedata => pcp_cpu_data_master_writedata,
      powerlink_0_MAC_BUF_readdata => powerlink_0_MAC_BUF_readdata,
      reset_n => pcp_clk_reset_n
    );


  --the_powerlink_0_MAC_CMP, which is an e_instance
  the_powerlink_0_MAC_CMP : powerlink_0_MAC_CMP_arbitrator
    port map(
      clock_crossing_0_m1_granted_powerlink_0_MAC_CMP => clock_crossing_0_m1_granted_powerlink_0_MAC_CMP,
      clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP => clock_crossing_0_m1_qualified_request_powerlink_0_MAC_CMP,
      clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_CMP => clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_CMP,
      clock_crossing_0_m1_requests_powerlink_0_MAC_CMP => clock_crossing_0_m1_requests_powerlink_0_MAC_CMP,
      d1_powerlink_0_MAC_CMP_end_xfer => d1_powerlink_0_MAC_CMP_end_xfer,
      powerlink_0_MAC_CMP_address => powerlink_0_MAC_CMP_address,
      powerlink_0_MAC_CMP_byteenable_n => powerlink_0_MAC_CMP_byteenable_n,
      powerlink_0_MAC_CMP_chipselect => powerlink_0_MAC_CMP_chipselect,
      powerlink_0_MAC_CMP_irq_from_sa => powerlink_0_MAC_CMP_irq_from_sa,
      powerlink_0_MAC_CMP_read_n => powerlink_0_MAC_CMP_read_n,
      powerlink_0_MAC_CMP_readdata_from_sa => powerlink_0_MAC_CMP_readdata_from_sa,
      powerlink_0_MAC_CMP_write_n => powerlink_0_MAC_CMP_write_n,
      powerlink_0_MAC_CMP_writedata => powerlink_0_MAC_CMP_writedata,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_byteenable => clock_crossing_0_m1_byteenable,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      clock_crossing_0_m1_writedata => clock_crossing_0_m1_writedata,
      powerlink_0_MAC_CMP_irq => powerlink_0_MAC_CMP_irq,
      powerlink_0_MAC_CMP_readdata => powerlink_0_MAC_CMP_readdata,
      reset_n => clk50Meg_reset_n
    );


  --the_powerlink_0_MAC_REG, which is an e_instance
  the_powerlink_0_MAC_REG : powerlink_0_MAC_REG_arbitrator
    port map(
      clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG => clock_crossing_0_m1_byteenable_powerlink_0_MAC_REG,
      clock_crossing_0_m1_granted_powerlink_0_MAC_REG => clock_crossing_0_m1_granted_powerlink_0_MAC_REG,
      clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG => clock_crossing_0_m1_qualified_request_powerlink_0_MAC_REG,
      clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_REG => clock_crossing_0_m1_read_data_valid_powerlink_0_MAC_REG,
      clock_crossing_0_m1_requests_powerlink_0_MAC_REG => clock_crossing_0_m1_requests_powerlink_0_MAC_REG,
      d1_powerlink_0_MAC_REG_end_xfer => d1_powerlink_0_MAC_REG_end_xfer,
      powerlink_0_MAC_REG_address => powerlink_0_MAC_REG_address,
      powerlink_0_MAC_REG_byteenable_n => powerlink_0_MAC_REG_byteenable_n,
      powerlink_0_MAC_REG_chipselect => powerlink_0_MAC_REG_chipselect,
      powerlink_0_MAC_REG_irq_from_sa => powerlink_0_MAC_REG_irq_from_sa,
      powerlink_0_MAC_REG_read_n => powerlink_0_MAC_REG_read_n,
      powerlink_0_MAC_REG_readdata_from_sa => powerlink_0_MAC_REG_readdata_from_sa,
      powerlink_0_MAC_REG_write_n => powerlink_0_MAC_REG_write_n,
      powerlink_0_MAC_REG_writedata => powerlink_0_MAC_REG_writedata,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_byteenable => clock_crossing_0_m1_byteenable,
      clock_crossing_0_m1_dbs_address => clock_crossing_0_m1_dbs_address,
      clock_crossing_0_m1_dbs_write_16 => clock_crossing_0_m1_dbs_write_16,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      powerlink_0_MAC_REG_irq => powerlink_0_MAC_REG_irq,
      powerlink_0_MAC_REG_readdata => powerlink_0_MAC_REG_readdata,
      reset_n => clk50Meg_reset_n
    );


  --the_powerlink_0_PDI_AP, which is an e_instance
  the_powerlink_0_PDI_AP : powerlink_0_PDI_AP_arbitrator
    port map(
      avalon_master_bridge_0_granted_powerlink_0_PDI_AP => avalon_master_bridge_0_granted_powerlink_0_PDI_AP,
      avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP => avalon_master_bridge_0_qualified_request_powerlink_0_PDI_AP,
      avalon_master_bridge_0_read_data_valid_powerlink_0_PDI_AP => avalon_master_bridge_0_read_data_valid_powerlink_0_PDI_AP,
      avalon_master_bridge_0_requests_powerlink_0_PDI_AP => avalon_master_bridge_0_requests_powerlink_0_PDI_AP,
      d1_powerlink_0_PDI_AP_end_xfer => d1_powerlink_0_PDI_AP_end_xfer,
      powerlink_0_PDI_AP_address => powerlink_0_PDI_AP_address,
      powerlink_0_PDI_AP_byteenable => powerlink_0_PDI_AP_byteenable,
      powerlink_0_PDI_AP_chipselect => powerlink_0_PDI_AP_chipselect,
      powerlink_0_PDI_AP_irq_from_sa => powerlink_0_PDI_AP_irq_from_sa,
      powerlink_0_PDI_AP_read => powerlink_0_PDI_AP_read,
      powerlink_0_PDI_AP_readdata_from_sa => powerlink_0_PDI_AP_readdata_from_sa,
      powerlink_0_PDI_AP_reset => powerlink_0_PDI_AP_reset,
      powerlink_0_PDI_AP_wait_counter_eq_0 => powerlink_0_PDI_AP_wait_counter_eq_0,
      powerlink_0_PDI_AP_write => powerlink_0_PDI_AP_write,
      powerlink_0_PDI_AP_writedata => powerlink_0_PDI_AP_writedata,
      avalon_address_from_the_avalon_master_bridge_0_to_slave => avalon_address_from_the_avalon_master_bridge_0_to_slave,
      avalon_byteenable_from_the_avalon_master_bridge_0 => avalon_byteenable_from_the_avalon_master_bridge_0,
      avalon_master_bridge_0_latency_counter => avalon_master_bridge_0_latency_counter,
      avalon_read_from_the_avalon_master_bridge_0 => avalon_read_from_the_avalon_master_bridge_0,
      avalon_write_from_the_avalon_master_bridge_0 => avalon_write_from_the_avalon_master_bridge_0,
      avalon_writedata_from_the_avalon_master_bridge_0 => avalon_writedata_from_the_avalon_master_bridge_0,
      clk => internal_ap_clk,
      powerlink_0_PDI_AP_irq => powerlink_0_PDI_AP_irq,
      powerlink_0_PDI_AP_readdata => powerlink_0_PDI_AP_readdata,
      reset_n => ap_clk_reset_n
    );


  --the_powerlink_0_PDI_PCP, which is an e_instance
  the_powerlink_0_PDI_PCP : powerlink_0_PDI_PCP_arbitrator
    port map(
      d1_powerlink_0_PDI_PCP_end_xfer => d1_powerlink_0_PDI_PCP_end_xfer,
      pcp_cpu_data_master_granted_powerlink_0_PDI_PCP => pcp_cpu_data_master_granted_powerlink_0_PDI_PCP,
      pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP => pcp_cpu_data_master_qualified_request_powerlink_0_PDI_PCP,
      pcp_cpu_data_master_read_data_valid_powerlink_0_PDI_PCP => pcp_cpu_data_master_read_data_valid_powerlink_0_PDI_PCP,
      pcp_cpu_data_master_requests_powerlink_0_PDI_PCP => pcp_cpu_data_master_requests_powerlink_0_PDI_PCP,
      powerlink_0_PDI_PCP_address => powerlink_0_PDI_PCP_address,
      powerlink_0_PDI_PCP_byteenable => powerlink_0_PDI_PCP_byteenable,
      powerlink_0_PDI_PCP_chipselect => powerlink_0_PDI_PCP_chipselect,
      powerlink_0_PDI_PCP_read => powerlink_0_PDI_PCP_read,
      powerlink_0_PDI_PCP_readdata_from_sa => powerlink_0_PDI_PCP_readdata_from_sa,
      powerlink_0_PDI_PCP_wait_counter_eq_0 => powerlink_0_PDI_PCP_wait_counter_eq_0,
      powerlink_0_PDI_PCP_write => powerlink_0_PDI_PCP_write,
      powerlink_0_PDI_PCP_writedata => powerlink_0_PDI_PCP_writedata,
      clk => internal_pcp_clk,
      pcp_cpu_data_master_address_to_slave => pcp_cpu_data_master_address_to_slave,
      pcp_cpu_data_master_byteenable => pcp_cpu_data_master_byteenable,
      pcp_cpu_data_master_read => pcp_cpu_data_master_read,
      pcp_cpu_data_master_waitrequest => pcp_cpu_data_master_waitrequest,
      pcp_cpu_data_master_write => pcp_cpu_data_master_write,
      pcp_cpu_data_master_writedata => pcp_cpu_data_master_writedata,
      powerlink_0_PDI_PCP_readdata => powerlink_0_PDI_PCP_readdata,
      reset_n => pcp_clk_reset_n
    );


  --the_powerlink_0, which is an e_ptf_instance
  the_powerlink_0 : powerlink_0
    port map(
      ap_irq => powerlink_0_PDI_AP_irq,
      ap_readdata => powerlink_0_PDI_AP_readdata,
      mac_irq => powerlink_0_MAC_REG_irq,
      mac_readdata => powerlink_0_MAC_REG_readdata,
      mbf_readdata => powerlink_0_MAC_BUF_readdata,
      pcp_readdata => powerlink_0_PDI_PCP_readdata,
      phy0_MiiClk => internal_phy0_MiiClk_from_the_powerlink_0,
      phy0_MiiDat => phy0_MiiDat_to_and_from_the_powerlink_0,
      phy0_MiiRst_n => internal_phy0_MiiRst_n_from_the_powerlink_0,
      phy0_TxDat => internal_phy0_TxDat_from_the_powerlink_0,
      phy0_TxEn => internal_phy0_TxEn_from_the_powerlink_0,
      phy1_MiiClk => internal_phy1_MiiClk_from_the_powerlink_0,
      phy1_MiiDat => phy1_MiiDat_to_and_from_the_powerlink_0,
      phy1_MiiRst_n => internal_phy1_MiiRst_n_from_the_powerlink_0,
      phy1_TxDat => internal_phy1_TxDat_from_the_powerlink_0,
      phy1_TxEn => internal_phy1_TxEn_from_the_powerlink_0,
      tcp_irq => powerlink_0_MAC_CMP_irq,
      tcp_readdata => powerlink_0_MAC_CMP_readdata,
      ap_address => powerlink_0_PDI_AP_address,
      ap_byteenable => powerlink_0_PDI_AP_byteenable,
      ap_chipselect => powerlink_0_PDI_AP_chipselect,
      ap_read => powerlink_0_PDI_AP_read,
      ap_write => powerlink_0_PDI_AP_write,
      ap_writedata => powerlink_0_PDI_AP_writedata,
      clk100 => internal_clk100Meg,
      clk50 => internal_clk50Meg,
      clkAp => internal_ap_clk,
      clkPcp => internal_pcp_clk,
      mac_address => powerlink_0_MAC_REG_address,
      mac_byteenable_n => powerlink_0_MAC_REG_byteenable_n,
      mac_chipselect => powerlink_0_MAC_REG_chipselect,
      mac_read_n => powerlink_0_MAC_REG_read_n,
      mac_write_n => powerlink_0_MAC_REG_write_n,
      mac_writedata => powerlink_0_MAC_REG_writedata,
      mbf_address => powerlink_0_MAC_BUF_address,
      mbf_byteenable => powerlink_0_MAC_BUF_byteenable,
      mbf_chipselect => powerlink_0_MAC_BUF_chipselect,
      mbf_read_n => powerlink_0_MAC_BUF_read_n,
      mbf_write_n => powerlink_0_MAC_BUF_write_n,
      mbf_writedata => powerlink_0_MAC_BUF_writedata,
      pcp_address => powerlink_0_PDI_PCP_address,
      pcp_byteenable => powerlink_0_PDI_PCP_byteenable,
      pcp_chipselect => powerlink_0_PDI_PCP_chipselect,
      pcp_read => powerlink_0_PDI_PCP_read,
      pcp_write => powerlink_0_PDI_PCP_write,
      pcp_writedata => powerlink_0_PDI_PCP_writedata,
      phy0_RxDat => phy0_RxDat_to_the_powerlink_0,
      phy0_RxDv => phy0_RxDv_to_the_powerlink_0,
      phy1_RxDat => phy1_RxDat_to_the_powerlink_0,
      phy1_RxDv => phy1_RxDv_to_the_powerlink_0,
      rstAp => powerlink_0_PDI_AP_reset,
      rstPcp => powerlink_0_MAC_BUF_reset,
      tcp_address => powerlink_0_MAC_CMP_address,
      tcp_byteenable_n => powerlink_0_MAC_CMP_byteenable_n,
      tcp_chipselect => powerlink_0_MAC_CMP_chipselect,
      tcp_read_n => powerlink_0_MAC_CMP_read_n,
      tcp_write_n => powerlink_0_MAC_CMP_write_n,
      tcp_writedata => powerlink_0_MAC_CMP_writedata
    );


  --the_remote_update_cycloneiii_0_s1, which is an e_instance
  the_remote_update_cycloneiii_0_s1 : remote_update_cycloneiii_0_s1_arbitrator
    port map(
      d1_remote_update_cycloneiii_0_s1_end_xfer => d1_remote_update_cycloneiii_0_s1_end_xfer,
      niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_1_out_granted_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_1_out_qualified_request_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_1_out_read_data_valid_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_1_out_requests_remote_update_cycloneiii_0_s1,
      remote_update_cycloneiii_0_s1_address => remote_update_cycloneiii_0_s1_address,
      remote_update_cycloneiii_0_s1_chipselect => remote_update_cycloneiii_0_s1_chipselect,
      remote_update_cycloneiii_0_s1_read => remote_update_cycloneiii_0_s1_read,
      remote_update_cycloneiii_0_s1_readdata_from_sa => remote_update_cycloneiii_0_s1_readdata_from_sa,
      remote_update_cycloneiii_0_s1_reset => remote_update_cycloneiii_0_s1_reset,
      remote_update_cycloneiii_0_s1_waitrequest_from_sa => remote_update_cycloneiii_0_s1_waitrequest_from_sa,
      remote_update_cycloneiii_0_s1_write => remote_update_cycloneiii_0_s1_write,
      remote_update_cycloneiii_0_s1_writedata => remote_update_cycloneiii_0_s1_writedata,
      clk => internal_clk25Meg,
      niosII_openMac_clock_1_out_address_to_slave => niosII_openMac_clock_1_out_address_to_slave,
      niosII_openMac_clock_1_out_nativeaddress => niosII_openMac_clock_1_out_nativeaddress,
      niosII_openMac_clock_1_out_read => niosII_openMac_clock_1_out_read,
      niosII_openMac_clock_1_out_write => niosII_openMac_clock_1_out_write,
      niosII_openMac_clock_1_out_writedata => niosII_openMac_clock_1_out_writedata,
      remote_update_cycloneiii_0_s1_readdata => remote_update_cycloneiii_0_s1_readdata,
      remote_update_cycloneiii_0_s1_waitrequest => remote_update_cycloneiii_0_s1_waitrequest,
      reset_n => clk25Meg_reset_n
    );


  --the_remote_update_cycloneiii_0, which is an e_ptf_instance
  the_remote_update_cycloneiii_0 : remote_update_cycloneiii_0
    port map(
      readdata => remote_update_cycloneiii_0_s1_readdata,
      waitrequest => remote_update_cycloneiii_0_s1_waitrequest,
      address => remote_update_cycloneiii_0_s1_address,
      chipselect => remote_update_cycloneiii_0_s1_chipselect,
      clk => internal_clk25Meg,
      read => remote_update_cycloneiii_0_s1_read,
      reset => remote_update_cycloneiii_0_s1_reset,
      write => remote_update_cycloneiii_0_s1_write,
      writedata => remote_update_cycloneiii_0_s1_writedata
    );


  --the_status_led_pio_s1, which is an e_instance
  the_status_led_pio_s1 : status_led_pio_s1_arbitrator
    port map(
      clock_crossing_0_m1_granted_status_led_pio_s1 => clock_crossing_0_m1_granted_status_led_pio_s1,
      clock_crossing_0_m1_qualified_request_status_led_pio_s1 => clock_crossing_0_m1_qualified_request_status_led_pio_s1,
      clock_crossing_0_m1_read_data_valid_status_led_pio_s1 => clock_crossing_0_m1_read_data_valid_status_led_pio_s1,
      clock_crossing_0_m1_requests_status_led_pio_s1 => clock_crossing_0_m1_requests_status_led_pio_s1,
      d1_status_led_pio_s1_end_xfer => d1_status_led_pio_s1_end_xfer,
      status_led_pio_s1_address => status_led_pio_s1_address,
      status_led_pio_s1_chipselect => status_led_pio_s1_chipselect,
      status_led_pio_s1_readdata_from_sa => status_led_pio_s1_readdata_from_sa,
      status_led_pio_s1_reset_n => status_led_pio_s1_reset_n,
      status_led_pio_s1_write_n => status_led_pio_s1_write_n,
      status_led_pio_s1_writedata => status_led_pio_s1_writedata,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_nativeaddress => clock_crossing_0_m1_nativeaddress,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      clock_crossing_0_m1_writedata => clock_crossing_0_m1_writedata,
      reset_n => clk50Meg_reset_n,
      status_led_pio_s1_readdata => status_led_pio_s1_readdata
    );


  --the_status_led_pio, which is an e_ptf_instance
  the_status_led_pio : status_led_pio
    port map(
      out_port => internal_out_port_from_the_status_led_pio,
      readdata => status_led_pio_s1_readdata,
      address => status_led_pio_s1_address,
      chipselect => status_led_pio_s1_chipselect,
      clk => internal_clk50Meg,
      reset_n => status_led_pio_s1_reset_n,
      write_n => status_led_pio_s1_write_n,
      writedata => status_led_pio_s1_writedata
    );


  --the_sysid_control_slave, which is an e_instance
  the_sysid_control_slave : sysid_control_slave_arbitrator
    port map(
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      pcp_cpu_data_master_granted_sysid_control_slave => pcp_cpu_data_master_granted_sysid_control_slave,
      pcp_cpu_data_master_qualified_request_sysid_control_slave => pcp_cpu_data_master_qualified_request_sysid_control_slave,
      pcp_cpu_data_master_read_data_valid_sysid_control_slave => pcp_cpu_data_master_read_data_valid_sysid_control_slave,
      pcp_cpu_data_master_requests_sysid_control_slave => pcp_cpu_data_master_requests_sysid_control_slave,
      sysid_control_slave_address => sysid_control_slave_address,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      sysid_control_slave_reset_n => sysid_control_slave_reset_n,
      clk => internal_pcp_clk,
      pcp_cpu_data_master_address_to_slave => pcp_cpu_data_master_address_to_slave,
      pcp_cpu_data_master_read => pcp_cpu_data_master_read,
      pcp_cpu_data_master_write => pcp_cpu_data_master_write,
      reset_n => pcp_clk_reset_n,
      sysid_control_slave_readdata => sysid_control_slave_readdata
    );


  --the_sysid, which is an e_ptf_instance
  the_sysid : sysid
    port map(
      readdata => sysid_control_slave_readdata,
      address => sysid_control_slave_address,
      clock => sysid_control_slave_clock,
      reset_n => sysid_control_slave_reset_n
    );


  --the_system_timer_s1, which is an e_instance
  the_system_timer_s1 : system_timer_s1_arbitrator
    port map(
      clock_crossing_0_m1_granted_system_timer_s1 => clock_crossing_0_m1_granted_system_timer_s1,
      clock_crossing_0_m1_qualified_request_system_timer_s1 => clock_crossing_0_m1_qualified_request_system_timer_s1,
      clock_crossing_0_m1_read_data_valid_system_timer_s1 => clock_crossing_0_m1_read_data_valid_system_timer_s1,
      clock_crossing_0_m1_requests_system_timer_s1 => clock_crossing_0_m1_requests_system_timer_s1,
      d1_system_timer_s1_end_xfer => d1_system_timer_s1_end_xfer,
      system_timer_s1_address => system_timer_s1_address,
      system_timer_s1_chipselect => system_timer_s1_chipselect,
      system_timer_s1_irq_from_sa => system_timer_s1_irq_from_sa,
      system_timer_s1_readdata_from_sa => system_timer_s1_readdata_from_sa,
      system_timer_s1_reset_n => system_timer_s1_reset_n,
      system_timer_s1_write_n => system_timer_s1_write_n,
      system_timer_s1_writedata => system_timer_s1_writedata,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_nativeaddress => clock_crossing_0_m1_nativeaddress,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      clock_crossing_0_m1_writedata => clock_crossing_0_m1_writedata,
      reset_n => clk50Meg_reset_n,
      system_timer_s1_irq => system_timer_s1_irq,
      system_timer_s1_readdata => system_timer_s1_readdata
    );


  --the_system_timer, which is an e_ptf_instance
  the_system_timer : system_timer
    port map(
      irq => system_timer_s1_irq,
      readdata => system_timer_s1_readdata,
      address => system_timer_s1_address,
      chipselect => system_timer_s1_chipselect,
      clk => internal_clk50Meg,
      reset_n => system_timer_s1_reset_n,
      write_n => system_timer_s1_write_n,
      writedata => system_timer_s1_writedata
    );


  --the_tri_state_bridge_0_avalon_slave, which is an e_instance
  the_tri_state_bridge_0_avalon_slave : tri_state_bridge_0_avalon_slave_arbitrator
    port map(
      ben_to_the_DBC3C40_SRAM_0 => internal_ben_to_the_DBC3C40_SRAM_0,
      d1_tri_state_bridge_0_avalon_slave_end_xfer => d1_tri_state_bridge_0_avalon_slave_end_xfer,
      incoming_tri_state_bridge_0_data => incoming_tri_state_bridge_0_data,
      ncs_to_the_DBC3C40_SRAM_0 => internal_ncs_to_the_DBC3C40_SRAM_0,
      pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_data_master_byteenable_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_data_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_data_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_data_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_instruction_master_granted_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_instruction_master_qualified_request_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_instruction_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave,
      pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave => pcp_cpu_instruction_master_requests_DBC3C40_SRAM_0_avalon_tristate_slave,
      registered_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave => registered_pcp_cpu_data_master_read_data_valid_DBC3C40_SRAM_0_avalon_tristate_slave,
      tri_state_bridge_0_address => internal_tri_state_bridge_0_address,
      tri_state_bridge_0_data => tri_state_bridge_0_data,
      tri_state_bridge_0_readn => internal_tri_state_bridge_0_readn,
      tri_state_bridge_0_writen => internal_tri_state_bridge_0_writen,
      clk => internal_pcp_clk,
      pcp_cpu_data_master_address_to_slave => pcp_cpu_data_master_address_to_slave,
      pcp_cpu_data_master_byteenable => pcp_cpu_data_master_byteenable,
      pcp_cpu_data_master_dbs_address => pcp_cpu_data_master_dbs_address,
      pcp_cpu_data_master_dbs_write_16 => pcp_cpu_data_master_dbs_write_16,
      pcp_cpu_data_master_no_byte_enables_and_last_term => pcp_cpu_data_master_no_byte_enables_and_last_term,
      pcp_cpu_data_master_read => pcp_cpu_data_master_read,
      pcp_cpu_data_master_waitrequest => pcp_cpu_data_master_waitrequest,
      pcp_cpu_data_master_write => pcp_cpu_data_master_write,
      pcp_cpu_instruction_master_address_to_slave => pcp_cpu_instruction_master_address_to_slave,
      pcp_cpu_instruction_master_dbs_address => pcp_cpu_instruction_master_dbs_address,
      pcp_cpu_instruction_master_latency_counter => pcp_cpu_instruction_master_latency_counter,
      pcp_cpu_instruction_master_read => pcp_cpu_instruction_master_read,
      reset_n => pcp_clk_reset_n
    );


  --reset is asserted asynchronously and deasserted synchronously
  niosII_openMac_reset_clk_0_domain_synch : niosII_openMac_reset_clk_0_domain_synch_module
    port map(
      data_out => clk_0_reset_n,
      clk => clk_0,
      data_in => module_input3,
      reset_n => reset_n_sources
    );

  module_input3 <= std_logic'('1');

  --reset sources mux, which is an e_mux
  reset_n_sources <= Vector_To_Std_Logic(NOT (((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT reset_n))) OR std_logic_vector'("00000000000000000000000000000000")) OR std_logic_vector'("00000000000000000000000000000000")) OR std_logic_vector'("00000000000000000000000000000000")) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_jtag_debug_module_resetrequest_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(pcp_cpu_jtag_debug_module_resetrequest_from_sa)))) OR std_logic_vector'("00000000000000000000000000000000")) OR std_logic_vector'("00000000000000000000000000000000"))));
  --reset is asserted asynchronously and deasserted synchronously
  niosII_openMac_reset_pcp_clk_domain_synch : niosII_openMac_reset_pcp_clk_domain_synch_module
    port map(
      data_out => pcp_clk_reset_n,
      clk => internal_pcp_clk,
      data_in => module_input4,
      reset_n => reset_n_sources
    );

  module_input4 <= std_logic'('1');

  --reset is asserted asynchronously and deasserted synchronously
  niosII_openMac_reset_clk50Meg_domain_synch : niosII_openMac_reset_clk50Meg_domain_synch_module
    port map(
      data_out => clk50Meg_reset_n,
      clk => internal_clk50Meg,
      data_in => module_input5,
      reset_n => reset_n_sources
    );

  module_input5 <= std_logic'('1');

  --reset is asserted asynchronously and deasserted synchronously
  niosII_openMac_reset_ap_clk_domain_synch : niosII_openMac_reset_ap_clk_domain_synch_module
    port map(
      data_out => ap_clk_reset_n,
      clk => internal_ap_clk,
      data_in => module_input6,
      reset_n => reset_n_sources
    );

  module_input6 <= std_logic'('1');

  --reset is asserted asynchronously and deasserted synchronously
  niosII_openMac_reset_clk25Meg_domain_synch : niosII_openMac_reset_clk25Meg_domain_synch_module
    port map(
      data_out => clk25Meg_reset_n,
      clk => internal_clk25Meg,
      data_in => module_input7,
      reset_n => reset_n_sources
    );

  module_input7 <= std_logic'('1');

  --clock_crossing_0_m1_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  clock_crossing_0_m1_endofpacket <= std_logic'('0');
  --niosII_openMac_clock_0_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  niosII_openMac_clock_0_out_endofpacket <= std_logic'('0');
  --niosII_openMac_clock_1_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  niosII_openMac_clock_1_out_endofpacket <= std_logic'('0');
  --sysid_control_slave_clock of type clock does not connect to anything so wire it to default (0)
  sysid_control_slave_clock <= std_logic'('0');
  --vhdl renameroo for output signals
  ap_clk <= internal_ap_clk;
  --vhdl renameroo for output signals
  ap_irq_to_the_avalon_master_bridge_0 <= internal_ap_irq_to_the_avalon_master_bridge_0;
  --vhdl renameroo for output signals
  avalon_readdata_to_the_avalon_master_bridge_0 <= internal_avalon_readdata_to_the_avalon_master_bridge_0;
  --vhdl renameroo for output signals
  avalon_readdatavalid_to_the_avalon_master_bridge_0 <= internal_avalon_readdatavalid_to_the_avalon_master_bridge_0;
  --vhdl renameroo for output signals
  avalon_waitrequest_to_the_avalon_master_bridge_0 <= internal_avalon_waitrequest_to_the_avalon_master_bridge_0;
  --vhdl renameroo for output signals
  ben_to_the_DBC3C40_SRAM_0 <= internal_ben_to_the_DBC3C40_SRAM_0;
  --vhdl renameroo for output signals
  clk100Meg <= internal_clk100Meg;
  --vhdl renameroo for output signals
  clk25Meg <= internal_clk25Meg;
  --vhdl renameroo for output signals
  clk50Meg <= internal_clk50Meg;
  --vhdl renameroo for output signals
  dclk_from_the_epcs_flash_controller_0 <= internal_dclk_from_the_epcs_flash_controller_0;
  --vhdl renameroo for output signals
  locked_from_the_altpll_0 <= internal_locked_from_the_altpll_0;
  --vhdl renameroo for output signals
  ncs_to_the_DBC3C40_SRAM_0 <= internal_ncs_to_the_DBC3C40_SRAM_0;
  --vhdl renameroo for output signals
  out_port_from_the_status_led_pio <= internal_out_port_from_the_status_led_pio;
  --vhdl renameroo for output signals
  pcp_clk <= internal_pcp_clk;
  --vhdl renameroo for output signals
  phasedone_from_the_altpll_0 <= internal_phasedone_from_the_altpll_0;
  --vhdl renameroo for output signals
  phy0_MiiClk_from_the_powerlink_0 <= internal_phy0_MiiClk_from_the_powerlink_0;
  --vhdl renameroo for output signals
  phy0_MiiRst_n_from_the_powerlink_0 <= internal_phy0_MiiRst_n_from_the_powerlink_0;
  --vhdl renameroo for output signals
  phy0_TxDat_from_the_powerlink_0 <= internal_phy0_TxDat_from_the_powerlink_0;
  --vhdl renameroo for output signals
  phy0_TxEn_from_the_powerlink_0 <= internal_phy0_TxEn_from_the_powerlink_0;
  --vhdl renameroo for output signals
  phy1_MiiClk_from_the_powerlink_0 <= internal_phy1_MiiClk_from_the_powerlink_0;
  --vhdl renameroo for output signals
  phy1_MiiRst_n_from_the_powerlink_0 <= internal_phy1_MiiRst_n_from_the_powerlink_0;
  --vhdl renameroo for output signals
  phy1_TxDat_from_the_powerlink_0 <= internal_phy1_TxDat_from_the_powerlink_0;
  --vhdl renameroo for output signals
  phy1_TxEn_from_the_powerlink_0 <= internal_phy1_TxEn_from_the_powerlink_0;
  --vhdl renameroo for output signals
  reset_to_the_avalon_master_bridge_0 <= internal_reset_to_the_avalon_master_bridge_0;
  --vhdl renameroo for output signals
  sce_from_the_epcs_flash_controller_0 <= internal_sce_from_the_epcs_flash_controller_0;
  --vhdl renameroo for output signals
  sdo_from_the_epcs_flash_controller_0 <= internal_sdo_from_the_epcs_flash_controller_0;
  --vhdl renameroo for output signals
  tri_state_bridge_0_address <= internal_tri_state_bridge_0_address;
  --vhdl renameroo for output signals
  tri_state_bridge_0_readn <= internal_tri_state_bridge_0_readn;
  --vhdl renameroo for output signals
  tri_state_bridge_0_writen <= internal_tri_state_bridge_0_writen;

end europa;


--synthesis translate_off

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your libraries here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>

entity test_bench is 
end entity test_bench;


architecture europa of test_bench is
component niosII_openMac is 
           port (
                 -- 1) global signals:
                    signal ap_clk : OUT STD_LOGIC;
                    signal clk100Meg : OUT STD_LOGIC;
                    signal clk25Meg : OUT STD_LOGIC;
                    signal clk50Meg : OUT STD_LOGIC;
                    signal clk_0 : IN STD_LOGIC;
                    signal pcp_clk : OUT STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- the_altpll_0
                    signal locked_from_the_altpll_0 : OUT STD_LOGIC;
                    signal phasedone_from_the_altpll_0 : OUT STD_LOGIC;

                 -- the_avalon_master_bridge_0_AvalonMaster
                    signal ap_irq_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;
                    signal avalon_address_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (14 DOWNTO 0);
                    signal avalon_byteenable_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal avalon_read_from_the_avalon_master_bridge_0 : IN STD_LOGIC;
                    signal avalon_readdata_to_the_avalon_master_bridge_0 : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal avalon_readdatavalid_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;
                    signal avalon_waitrequest_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;
                    signal avalon_write_from_the_avalon_master_bridge_0 : IN STD_LOGIC;
                    signal avalon_writedata_from_the_avalon_master_bridge_0 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_to_the_avalon_master_bridge_0 : OUT STD_LOGIC;

                 -- the_epcs_flash_controller_0
                    signal data0_to_the_epcs_flash_controller_0 : IN STD_LOGIC;
                    signal dclk_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;
                    signal sce_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;
                    signal sdo_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;

                 -- the_node_switch_pio
                    signal in_port_to_the_node_switch_pio : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_powerlink_0
                    signal phy0_MiiClk_from_the_powerlink_0 : OUT STD_LOGIC;
                    signal phy0_MiiDat_to_and_from_the_powerlink_0 : INOUT STD_LOGIC;
                    signal phy0_MiiRst_n_from_the_powerlink_0 : OUT STD_LOGIC;
                    signal phy0_RxDat_to_the_powerlink_0 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal phy0_RxDv_to_the_powerlink_0 : IN STD_LOGIC;
                    signal phy0_TxDat_from_the_powerlink_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal phy0_TxEn_from_the_powerlink_0 : OUT STD_LOGIC;
                    signal phy1_MiiClk_from_the_powerlink_0 : OUT STD_LOGIC;
                    signal phy1_MiiDat_to_and_from_the_powerlink_0 : INOUT STD_LOGIC;
                    signal phy1_MiiRst_n_from_the_powerlink_0 : OUT STD_LOGIC;
                    signal phy1_RxDat_to_the_powerlink_0 : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal phy1_RxDv_to_the_powerlink_0 : IN STD_LOGIC;
                    signal phy1_TxDat_from_the_powerlink_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal phy1_TxEn_from_the_powerlink_0 : OUT STD_LOGIC;

                 -- the_status_led_pio
                    signal out_port_from_the_status_led_pio : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);

                 -- the_tri_state_bridge_0_avalon_slave
                    signal ben_to_the_DBC3C40_SRAM_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ncs_to_the_DBC3C40_SRAM_0 : OUT STD_LOGIC;
                    signal tri_state_bridge_0_address : OUT STD_LOGIC_VECTOR (19 DOWNTO 0);
                    signal tri_state_bridge_0_data : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal tri_state_bridge_0_readn : OUT STD_LOGIC;
                    signal tri_state_bridge_0_writen : OUT STD_LOGIC
                 );
end component niosII_openMac;

                signal ap_clk :  STD_LOGIC;
                signal ap_irq_to_the_avalon_master_bridge_0 :  STD_LOGIC;
                signal avalon_address_from_the_avalon_master_bridge_0 :  STD_LOGIC_VECTOR (14 DOWNTO 0);
                signal avalon_byteenable_from_the_avalon_master_bridge_0 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal avalon_read_from_the_avalon_master_bridge_0 :  STD_LOGIC;
                signal avalon_readdata_to_the_avalon_master_bridge_0 :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal avalon_readdatavalid_to_the_avalon_master_bridge_0 :  STD_LOGIC;
                signal avalon_waitrequest_to_the_avalon_master_bridge_0 :  STD_LOGIC;
                signal avalon_write_from_the_avalon_master_bridge_0 :  STD_LOGIC;
                signal avalon_writedata_from_the_avalon_master_bridge_0 :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ben_to_the_DBC3C40_SRAM_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal clk :  STD_LOGIC;
                signal clk100Meg :  STD_LOGIC;
                signal clk25Meg :  STD_LOGIC;
                signal clk50Meg :  STD_LOGIC;
                signal clk_0 :  STD_LOGIC;
                signal clock_crossing_0_m1_endofpacket :  STD_LOGIC;
                signal clock_crossing_0_s1_endofpacket_from_sa :  STD_LOGIC;
                signal data0_to_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal dclk_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa :  STD_LOGIC;
                signal in_port_to_the_node_switch_pio :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal jtag_uart_0_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_0_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal locked_from_the_altpll_0 :  STD_LOGIC;
                signal ncs_to_the_DBC3C40_SRAM_0 :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_nativeaddress :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_1_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_endofpacket :  STD_LOGIC;
                signal out_port_from_the_status_led_pio :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pcp_clk :  STD_LOGIC;
                signal phasedone_from_the_altpll_0 :  STD_LOGIC;
                signal phy0_MiiClk_from_the_powerlink_0 :  STD_LOGIC;
                signal phy0_MiiDat_to_and_from_the_powerlink_0 :  STD_LOGIC;
                signal phy0_MiiRst_n_from_the_powerlink_0 :  STD_LOGIC;
                signal phy0_RxDat_to_the_powerlink_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal phy0_RxDv_to_the_powerlink_0 :  STD_LOGIC;
                signal phy0_TxDat_from_the_powerlink_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal phy0_TxEn_from_the_powerlink_0 :  STD_LOGIC;
                signal phy1_MiiClk_from_the_powerlink_0 :  STD_LOGIC;
                signal phy1_MiiDat_to_and_from_the_powerlink_0 :  STD_LOGIC;
                signal phy1_MiiRst_n_from_the_powerlink_0 :  STD_LOGIC;
                signal phy1_RxDat_to_the_powerlink_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal phy1_RxDv_to_the_powerlink_0 :  STD_LOGIC;
                signal phy1_TxDat_from_the_powerlink_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal phy1_TxEn_from_the_powerlink_0 :  STD_LOGIC;
                signal reset_n :  STD_LOGIC;
                signal reset_to_the_avalon_master_bridge_0 :  STD_LOGIC;
                signal sce_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal sdo_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal sysid_control_slave_clock :  STD_LOGIC;
                signal tri_state_bridge_0_address :  STD_LOGIC_VECTOR (19 DOWNTO 0);
                signal tri_state_bridge_0_data :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal tri_state_bridge_0_readn :  STD_LOGIC;
                signal tri_state_bridge_0_writen :  STD_LOGIC;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your component and signal declaration here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


begin

  --Set us up the Dut
  DUT : niosII_openMac
    port map(
      ap_clk => ap_clk,
      ap_irq_to_the_avalon_master_bridge_0 => ap_irq_to_the_avalon_master_bridge_0,
      avalon_readdata_to_the_avalon_master_bridge_0 => avalon_readdata_to_the_avalon_master_bridge_0,
      avalon_readdatavalid_to_the_avalon_master_bridge_0 => avalon_readdatavalid_to_the_avalon_master_bridge_0,
      avalon_waitrequest_to_the_avalon_master_bridge_0 => avalon_waitrequest_to_the_avalon_master_bridge_0,
      ben_to_the_DBC3C40_SRAM_0 => ben_to_the_DBC3C40_SRAM_0,
      clk100Meg => clk100Meg,
      clk25Meg => clk25Meg,
      clk50Meg => clk50Meg,
      dclk_from_the_epcs_flash_controller_0 => dclk_from_the_epcs_flash_controller_0,
      locked_from_the_altpll_0 => locked_from_the_altpll_0,
      ncs_to_the_DBC3C40_SRAM_0 => ncs_to_the_DBC3C40_SRAM_0,
      out_port_from_the_status_led_pio => out_port_from_the_status_led_pio,
      pcp_clk => pcp_clk,
      phasedone_from_the_altpll_0 => phasedone_from_the_altpll_0,
      phy0_MiiClk_from_the_powerlink_0 => phy0_MiiClk_from_the_powerlink_0,
      phy0_MiiDat_to_and_from_the_powerlink_0 => phy0_MiiDat_to_and_from_the_powerlink_0,
      phy0_MiiRst_n_from_the_powerlink_0 => phy0_MiiRst_n_from_the_powerlink_0,
      phy0_TxDat_from_the_powerlink_0 => phy0_TxDat_from_the_powerlink_0,
      phy0_TxEn_from_the_powerlink_0 => phy0_TxEn_from_the_powerlink_0,
      phy1_MiiClk_from_the_powerlink_0 => phy1_MiiClk_from_the_powerlink_0,
      phy1_MiiDat_to_and_from_the_powerlink_0 => phy1_MiiDat_to_and_from_the_powerlink_0,
      phy1_MiiRst_n_from_the_powerlink_0 => phy1_MiiRst_n_from_the_powerlink_0,
      phy1_TxDat_from_the_powerlink_0 => phy1_TxDat_from_the_powerlink_0,
      phy1_TxEn_from_the_powerlink_0 => phy1_TxEn_from_the_powerlink_0,
      reset_to_the_avalon_master_bridge_0 => reset_to_the_avalon_master_bridge_0,
      sce_from_the_epcs_flash_controller_0 => sce_from_the_epcs_flash_controller_0,
      sdo_from_the_epcs_flash_controller_0 => sdo_from_the_epcs_flash_controller_0,
      tri_state_bridge_0_address => tri_state_bridge_0_address,
      tri_state_bridge_0_data => tri_state_bridge_0_data,
      tri_state_bridge_0_readn => tri_state_bridge_0_readn,
      tri_state_bridge_0_writen => tri_state_bridge_0_writen,
      avalon_address_from_the_avalon_master_bridge_0 => avalon_address_from_the_avalon_master_bridge_0,
      avalon_byteenable_from_the_avalon_master_bridge_0 => avalon_byteenable_from_the_avalon_master_bridge_0,
      avalon_read_from_the_avalon_master_bridge_0 => avalon_read_from_the_avalon_master_bridge_0,
      avalon_write_from_the_avalon_master_bridge_0 => avalon_write_from_the_avalon_master_bridge_0,
      avalon_writedata_from_the_avalon_master_bridge_0 => avalon_writedata_from_the_avalon_master_bridge_0,
      clk_0 => clk_0,
      data0_to_the_epcs_flash_controller_0 => data0_to_the_epcs_flash_controller_0,
      in_port_to_the_node_switch_pio => in_port_to_the_node_switch_pio,
      phy0_RxDat_to_the_powerlink_0 => phy0_RxDat_to_the_powerlink_0,
      phy0_RxDv_to_the_powerlink_0 => phy0_RxDv_to_the_powerlink_0,
      phy1_RxDat_to_the_powerlink_0 => phy1_RxDat_to_the_powerlink_0,
      phy1_RxDv_to_the_powerlink_0 => phy1_RxDv_to_the_powerlink_0,
      reset_n => reset_n
    );


  process
  begin
    clk_0 <= '0';
    loop
       wait for 10 ns;
       clk_0 <= not clk_0;
    end loop;
  end process;
  PROCESS
    BEGIN
       reset_n <= '0';
       wait for 200 ns;
       reset_n <= '1'; 
    WAIT;
  END PROCESS;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add additional architecture here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


end europa;



--synthesis translate_on
