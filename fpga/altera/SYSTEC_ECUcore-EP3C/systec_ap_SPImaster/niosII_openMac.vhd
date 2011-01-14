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

entity ap_cpu_jtag_debug_module_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ap_cpu_data_master_debugaccess : IN STD_LOGIC;
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                 signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                 signal ap_cpu_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_jtag_debug_module_resetrequest : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal ap_cpu_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal ap_cpu_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                 signal ap_cpu_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ap_cpu_jtag_debug_module_chipselect : OUT STD_LOGIC;
                 signal ap_cpu_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                 signal ap_cpu_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_jtag_debug_module_reset_n : OUT STD_LOGIC;
                 signal ap_cpu_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                 signal ap_cpu_jtag_debug_module_write : OUT STD_LOGIC;
                 signal ap_cpu_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_ap_cpu_jtag_debug_module_end_xfer : OUT STD_LOGIC
              );
end entity ap_cpu_jtag_debug_module_arbitrator;


architecture europa of ap_cpu_jtag_debug_module_arbitrator is
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_instruction_master_saved_grant_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_allgrants :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_allow_new_arb_cycle :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_any_bursting_master_saved_grant :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_any_continuerequest :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_jtag_debug_module_arb_counter_enable :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_arb_share_counter :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_arb_share_counter_next_value :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_arb_share_set_values :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_jtag_debug_module_arbitration_holdoff_internal :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_beginbursttransfer_internal :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_begins_xfer :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ap_cpu_jtag_debug_module_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_firsttransfer :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_jtag_debug_module_in_a_read_cycle :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_in_a_write_cycle :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_jtag_debug_module_non_bursting_master_requests :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_reg_firsttransfer :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_jtag_debug_module_slavearbiterlockenable :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_slavearbiterlockenable2 :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_unreg_firsttransfer :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_waits_for_read :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_waits_for_write :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal last_cycle_ap_cpu_data_master_granted_slave_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal last_cycle_ap_cpu_instruction_master_granted_slave_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal shifted_address_to_ap_cpu_jtag_debug_module_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal shifted_address_to_ap_cpu_jtag_debug_module_from_ap_cpu_instruction_master :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal wait_for_ap_cpu_jtag_debug_module_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT ap_cpu_jtag_debug_module_end_xfer;
    end if;

  end process;

  ap_cpu_jtag_debug_module_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module OR internal_ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module));
  --assign ap_cpu_jtag_debug_module_readdata_from_sa = ap_cpu_jtag_debug_module_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  ap_cpu_jtag_debug_module_readdata_from_sa <= ap_cpu_jtag_debug_module_readdata;
  internal_ap_cpu_data_master_requests_ap_cpu_jtag_debug_module <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(24 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0000000000001000000000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --ap_cpu_jtag_debug_module_arb_share_counter set values, which is an e_mux
  ap_cpu_jtag_debug_module_arb_share_set_values <= std_logic'('1');
  --ap_cpu_jtag_debug_module_non_bursting_master_requests mux, which is an e_mux
  ap_cpu_jtag_debug_module_non_bursting_master_requests <= ((internal_ap_cpu_data_master_requests_ap_cpu_jtag_debug_module OR internal_ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module) OR internal_ap_cpu_data_master_requests_ap_cpu_jtag_debug_module) OR internal_ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module;
  --ap_cpu_jtag_debug_module_any_bursting_master_saved_grant mux, which is an e_mux
  ap_cpu_jtag_debug_module_any_bursting_master_saved_grant <= std_logic'('0');
  --ap_cpu_jtag_debug_module_arb_share_counter_next_value assignment, which is an e_assign
  ap_cpu_jtag_debug_module_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ap_cpu_jtag_debug_module_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_jtag_debug_module_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(ap_cpu_jtag_debug_module_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_jtag_debug_module_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --ap_cpu_jtag_debug_module_allgrants all slave grants, which is an e_mux
  ap_cpu_jtag_debug_module_allgrants <= (((or_reduce(ap_cpu_jtag_debug_module_grant_vector)) OR (or_reduce(ap_cpu_jtag_debug_module_grant_vector))) OR (or_reduce(ap_cpu_jtag_debug_module_grant_vector))) OR (or_reduce(ap_cpu_jtag_debug_module_grant_vector));
  --ap_cpu_jtag_debug_module_end_xfer assignment, which is an e_assign
  ap_cpu_jtag_debug_module_end_xfer <= NOT ((ap_cpu_jtag_debug_module_waits_for_read OR ap_cpu_jtag_debug_module_waits_for_write));
  --end_xfer_arb_share_counter_term_ap_cpu_jtag_debug_module arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_ap_cpu_jtag_debug_module <= ap_cpu_jtag_debug_module_end_xfer AND (((NOT ap_cpu_jtag_debug_module_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --ap_cpu_jtag_debug_module_arb_share_counter arbitration counter enable, which is an e_assign
  ap_cpu_jtag_debug_module_arb_counter_enable <= ((end_xfer_arb_share_counter_term_ap_cpu_jtag_debug_module AND ap_cpu_jtag_debug_module_allgrants)) OR ((end_xfer_arb_share_counter_term_ap_cpu_jtag_debug_module AND NOT ap_cpu_jtag_debug_module_non_bursting_master_requests));
  --ap_cpu_jtag_debug_module_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ap_cpu_jtag_debug_module_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(ap_cpu_jtag_debug_module_arb_counter_enable) = '1' then 
        ap_cpu_jtag_debug_module_arb_share_counter <= ap_cpu_jtag_debug_module_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ap_cpu_jtag_debug_module_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ap_cpu_jtag_debug_module_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(ap_cpu_jtag_debug_module_master_qreq_vector) AND end_xfer_arb_share_counter_term_ap_cpu_jtag_debug_module)) OR ((end_xfer_arb_share_counter_term_ap_cpu_jtag_debug_module AND NOT ap_cpu_jtag_debug_module_non_bursting_master_requests)))) = '1' then 
        ap_cpu_jtag_debug_module_slavearbiterlockenable <= ap_cpu_jtag_debug_module_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ap_cpu/data_master ap_cpu/jtag_debug_module arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= ap_cpu_jtag_debug_module_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --ap_cpu_jtag_debug_module_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  ap_cpu_jtag_debug_module_slavearbiterlockenable2 <= ap_cpu_jtag_debug_module_arb_share_counter_next_value;
  --ap_cpu/data_master ap_cpu/jtag_debug_module arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= ap_cpu_jtag_debug_module_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --ap_cpu/instruction_master ap_cpu/jtag_debug_module arbiterlock, which is an e_assign
  ap_cpu_instruction_master_arbiterlock <= ap_cpu_jtag_debug_module_slavearbiterlockenable AND ap_cpu_instruction_master_continuerequest;
  --ap_cpu/instruction_master ap_cpu/jtag_debug_module arbiterlock2, which is an e_assign
  ap_cpu_instruction_master_arbiterlock2 <= ap_cpu_jtag_debug_module_slavearbiterlockenable2 AND ap_cpu_instruction_master_continuerequest;
  --ap_cpu/instruction_master granted ap_cpu/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ap_cpu_instruction_master_granted_slave_ap_cpu_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_ap_cpu_instruction_master_granted_slave_ap_cpu_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ap_cpu_instruction_master_saved_grant_ap_cpu_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((ap_cpu_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ap_cpu_instruction_master_granted_slave_ap_cpu_jtag_debug_module))))));
    end if;

  end process;

  --ap_cpu_instruction_master_continuerequest continued request, which is an e_mux
  ap_cpu_instruction_master_continuerequest <= last_cycle_ap_cpu_instruction_master_granted_slave_ap_cpu_jtag_debug_module AND internal_ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module;
  --ap_cpu_jtag_debug_module_any_continuerequest at least one master continues requesting, which is an e_mux
  ap_cpu_jtag_debug_module_any_continuerequest <= ap_cpu_instruction_master_continuerequest OR ap_cpu_data_master_continuerequest;
  internal_ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module <= internal_ap_cpu_data_master_requests_ap_cpu_jtag_debug_module AND NOT (((((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write)) OR ap_cpu_instruction_master_arbiterlock));
  --ap_cpu_jtag_debug_module_writedata mux, which is an e_mux
  ap_cpu_jtag_debug_module_writedata <= ap_cpu_data_master_writedata;
  internal_ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module <= ((to_std_logic(((Std_Logic_Vector'(ap_cpu_instruction_master_address_to_slave(22 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("00000000001000000000000")))) AND (ap_cpu_instruction_master_read))) AND ap_cpu_instruction_master_read;
  --ap_cpu/data_master granted ap_cpu/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ap_cpu_data_master_granted_slave_ap_cpu_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_ap_cpu_data_master_granted_slave_ap_cpu_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ap_cpu_data_master_saved_grant_ap_cpu_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((ap_cpu_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_ap_cpu_data_master_requests_ap_cpu_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ap_cpu_data_master_granted_slave_ap_cpu_jtag_debug_module))))));
    end if;

  end process;

  --ap_cpu_data_master_continuerequest continued request, which is an e_mux
  ap_cpu_data_master_continuerequest <= last_cycle_ap_cpu_data_master_granted_slave_ap_cpu_jtag_debug_module AND internal_ap_cpu_data_master_requests_ap_cpu_jtag_debug_module;
  internal_ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module <= internal_ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module AND NOT ((((ap_cpu_instruction_master_read AND to_std_logic((((std_logic_vector'("000000000000000000000000000000") & (ap_cpu_instruction_master_latency_counter)) /= std_logic_vector'("00000000000000000000000000000000")))))) OR ap_cpu_data_master_arbiterlock));
  --local readdatavalid ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module, which is an e_mux
  ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module <= (internal_ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module AND ap_cpu_instruction_master_read) AND NOT ap_cpu_jtag_debug_module_waits_for_read;
  --allow new arb cycle for ap_cpu/jtag_debug_module, which is an e_assign
  ap_cpu_jtag_debug_module_allow_new_arb_cycle <= NOT ap_cpu_data_master_arbiterlock AND NOT ap_cpu_instruction_master_arbiterlock;
  --ap_cpu/instruction_master assignment into master qualified-requests vector for ap_cpu/jtag_debug_module, which is an e_assign
  ap_cpu_jtag_debug_module_master_qreq_vector(0) <= internal_ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module;
  --ap_cpu/instruction_master grant ap_cpu/jtag_debug_module, which is an e_assign
  internal_ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module <= ap_cpu_jtag_debug_module_grant_vector(0);
  --ap_cpu/instruction_master saved-grant ap_cpu/jtag_debug_module, which is an e_assign
  ap_cpu_instruction_master_saved_grant_ap_cpu_jtag_debug_module <= ap_cpu_jtag_debug_module_arb_winner(0) AND internal_ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module;
  --ap_cpu/data_master assignment into master qualified-requests vector for ap_cpu/jtag_debug_module, which is an e_assign
  ap_cpu_jtag_debug_module_master_qreq_vector(1) <= internal_ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module;
  --ap_cpu/data_master grant ap_cpu/jtag_debug_module, which is an e_assign
  internal_ap_cpu_data_master_granted_ap_cpu_jtag_debug_module <= ap_cpu_jtag_debug_module_grant_vector(1);
  --ap_cpu/data_master saved-grant ap_cpu/jtag_debug_module, which is an e_assign
  ap_cpu_data_master_saved_grant_ap_cpu_jtag_debug_module <= ap_cpu_jtag_debug_module_arb_winner(1) AND internal_ap_cpu_data_master_requests_ap_cpu_jtag_debug_module;
  --ap_cpu/jtag_debug_module chosen-master double-vector, which is an e_assign
  ap_cpu_jtag_debug_module_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((ap_cpu_jtag_debug_module_master_qreq_vector & ap_cpu_jtag_debug_module_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT ap_cpu_jtag_debug_module_master_qreq_vector & NOT ap_cpu_jtag_debug_module_master_qreq_vector))) + (std_logic_vector'("000") & (ap_cpu_jtag_debug_module_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  ap_cpu_jtag_debug_module_arb_winner <= A_WE_StdLogicVector((std_logic'(((ap_cpu_jtag_debug_module_allow_new_arb_cycle AND or_reduce(ap_cpu_jtag_debug_module_grant_vector)))) = '1'), ap_cpu_jtag_debug_module_grant_vector, ap_cpu_jtag_debug_module_saved_chosen_master_vector);
  --saved ap_cpu_jtag_debug_module_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ap_cpu_jtag_debug_module_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(ap_cpu_jtag_debug_module_allow_new_arb_cycle) = '1' then 
        ap_cpu_jtag_debug_module_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(ap_cpu_jtag_debug_module_grant_vector)) = '1'), ap_cpu_jtag_debug_module_grant_vector, ap_cpu_jtag_debug_module_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  ap_cpu_jtag_debug_module_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((ap_cpu_jtag_debug_module_chosen_master_double_vector(1) OR ap_cpu_jtag_debug_module_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((ap_cpu_jtag_debug_module_chosen_master_double_vector(0) OR ap_cpu_jtag_debug_module_chosen_master_double_vector(2)))));
  --ap_cpu/jtag_debug_module chosen master rotated left, which is an e_assign
  ap_cpu_jtag_debug_module_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(ap_cpu_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(ap_cpu_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --ap_cpu/jtag_debug_module's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ap_cpu_jtag_debug_module_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(ap_cpu_jtag_debug_module_grant_vector)) = '1' then 
        ap_cpu_jtag_debug_module_arb_addend <= A_WE_StdLogicVector((std_logic'(ap_cpu_jtag_debug_module_end_xfer) = '1'), ap_cpu_jtag_debug_module_chosen_master_rot_left, ap_cpu_jtag_debug_module_grant_vector);
      end if;
    end if;

  end process;

  ap_cpu_jtag_debug_module_begintransfer <= ap_cpu_jtag_debug_module_begins_xfer;
  --ap_cpu_jtag_debug_module_reset_n assignment, which is an e_assign
  ap_cpu_jtag_debug_module_reset_n <= reset_n;
  --assign ap_cpu_jtag_debug_module_resetrequest_from_sa = ap_cpu_jtag_debug_module_resetrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  ap_cpu_jtag_debug_module_resetrequest_from_sa <= ap_cpu_jtag_debug_module_resetrequest;
  ap_cpu_jtag_debug_module_chipselect <= internal_ap_cpu_data_master_granted_ap_cpu_jtag_debug_module OR internal_ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module;
  --ap_cpu_jtag_debug_module_firsttransfer first transaction, which is an e_assign
  ap_cpu_jtag_debug_module_firsttransfer <= A_WE_StdLogic((std_logic'(ap_cpu_jtag_debug_module_begins_xfer) = '1'), ap_cpu_jtag_debug_module_unreg_firsttransfer, ap_cpu_jtag_debug_module_reg_firsttransfer);
  --ap_cpu_jtag_debug_module_unreg_firsttransfer first transaction, which is an e_assign
  ap_cpu_jtag_debug_module_unreg_firsttransfer <= NOT ((ap_cpu_jtag_debug_module_slavearbiterlockenable AND ap_cpu_jtag_debug_module_any_continuerequest));
  --ap_cpu_jtag_debug_module_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ap_cpu_jtag_debug_module_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(ap_cpu_jtag_debug_module_begins_xfer) = '1' then 
        ap_cpu_jtag_debug_module_reg_firsttransfer <= ap_cpu_jtag_debug_module_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --ap_cpu_jtag_debug_module_beginbursttransfer_internal begin burst transfer, which is an e_assign
  ap_cpu_jtag_debug_module_beginbursttransfer_internal <= ap_cpu_jtag_debug_module_begins_xfer;
  --ap_cpu_jtag_debug_module_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  ap_cpu_jtag_debug_module_arbitration_holdoff_internal <= ap_cpu_jtag_debug_module_begins_xfer AND ap_cpu_jtag_debug_module_firsttransfer;
  --ap_cpu_jtag_debug_module_write assignment, which is an e_mux
  ap_cpu_jtag_debug_module_write <= internal_ap_cpu_data_master_granted_ap_cpu_jtag_debug_module AND ap_cpu_data_master_write;
  shifted_address_to_ap_cpu_jtag_debug_module_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --ap_cpu_jtag_debug_module_address mux, which is an e_mux
  ap_cpu_jtag_debug_module_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_ap_cpu_jtag_debug_module)) = '1'), (A_SRL(shifted_address_to_ap_cpu_jtag_debug_module_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (std_logic_vector'("00") & ((A_SRL(shifted_address_to_ap_cpu_jtag_debug_module_from_ap_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))))), 9);
  shifted_address_to_ap_cpu_jtag_debug_module_from_ap_cpu_instruction_master <= ap_cpu_instruction_master_address_to_slave;
  --d1_ap_cpu_jtag_debug_module_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_ap_cpu_jtag_debug_module_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_ap_cpu_jtag_debug_module_end_xfer <= ap_cpu_jtag_debug_module_end_xfer;
    end if;

  end process;

  --ap_cpu_jtag_debug_module_waits_for_read in a cycle, which is an e_mux
  ap_cpu_jtag_debug_module_waits_for_read <= ap_cpu_jtag_debug_module_in_a_read_cycle AND ap_cpu_jtag_debug_module_begins_xfer;
  --ap_cpu_jtag_debug_module_in_a_read_cycle assignment, which is an e_assign
  ap_cpu_jtag_debug_module_in_a_read_cycle <= ((internal_ap_cpu_data_master_granted_ap_cpu_jtag_debug_module AND ap_cpu_data_master_read)) OR ((internal_ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module AND ap_cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= ap_cpu_jtag_debug_module_in_a_read_cycle;
  --ap_cpu_jtag_debug_module_waits_for_write in a cycle, which is an e_mux
  ap_cpu_jtag_debug_module_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_jtag_debug_module_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --ap_cpu_jtag_debug_module_in_a_write_cycle assignment, which is an e_assign
  ap_cpu_jtag_debug_module_in_a_write_cycle <= internal_ap_cpu_data_master_granted_ap_cpu_jtag_debug_module AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= ap_cpu_jtag_debug_module_in_a_write_cycle;
  wait_for_ap_cpu_jtag_debug_module_counter <= std_logic'('0');
  --ap_cpu_jtag_debug_module_byteenable byte enable port mux, which is an e_mux
  ap_cpu_jtag_debug_module_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_ap_cpu_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ap_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --debugaccess mux, which is an e_mux
  ap_cpu_jtag_debug_module_debugaccess <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_ap_cpu_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_debugaccess))), std_logic_vector'("00000000000000000000000000000000")));
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_ap_cpu_jtag_debug_module <= internal_ap_cpu_data_master_granted_ap_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module <= internal_ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_ap_cpu_jtag_debug_module <= internal_ap_cpu_data_master_requests_ap_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module <= internal_ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module <= internal_ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module <= internal_ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module;
--synthesis translate_off
    --ap_cpu/jtag_debug_module enable non-zero assertions, which is an e_register
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
    VARIABLE write_line : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ap_cpu_data_master_granted_ap_cpu_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line, now);
          write(write_line, string'(": "));
          write(write_line, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line.all);
          deallocate (write_line);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line1 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_saved_grant_ap_cpu_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_saved_grant_ap_cpu_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line1, now);
          write(write_line1, string'(": "));
          write(write_line1, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line1.all);
          deallocate (write_line1);
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

entity jtag_uart_1_avalon_jtag_slave_irq_from_sa_clock_crossing_ap_cpu_data_master_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity jtag_uart_1_avalon_jtag_slave_irq_from_sa_clock_crossing_ap_cpu_data_master_module;


architecture europa of jtag_uart_1_avalon_jtag_slave_irq_from_sa_clock_crossing_ap_cpu_data_master_module is
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

entity spi_master_spi_control_port_irq_from_sa_clock_crossing_ap_cpu_data_master_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity spi_master_spi_control_port_irq_from_sa_clock_crossing_ap_cpu_data_master_module;


architecture europa of spi_master_spi_control_port_irq_from_sa_clock_crossing_ap_cpu_data_master_module is
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

entity sync_irq_from_pcp_s1_irq_from_sa_clock_crossing_ap_cpu_data_master_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity sync_irq_from_pcp_s1_irq_from_sa_clock_crossing_ap_cpu_data_master_module;


architecture europa of sync_irq_from_pcp_s1_irq_from_sa_clock_crossing_ap_cpu_data_master_module is
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

entity system_timer_ap_s1_irq_from_sa_clock_crossing_ap_cpu_data_master_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity system_timer_ap_s1_irq_from_sa_clock_crossing_ap_cpu_data_master_module;


architecture europa of system_timer_ap_s1_irq_from_sa_clock_crossing_ap_cpu_data_master_module is
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

entity ap_cpu_data_master_arbitrator is 
        port (
              -- inputs:
                 signal ap_clk : IN STD_LOGIC;
                 signal ap_clk_reset_n : IN STD_LOGIC;
                 signal ap_cpu_data_master_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_clock_crossing_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_clock_crossing_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_clock_crossing_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_clock_crossing_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clock_crossing_0_s1_waitrequest_from_sa : IN STD_LOGIC;
                 signal d1_ap_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_clock_crossing_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_memory_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_tri_state_bridge_0_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_irq_from_sa : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal incoming_tri_state_bridge_0_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_1_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                 signal onchip_memory_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal registered_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal registered_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal spi_master_spi_control_port_irq_from_sa : IN STD_LOGIC;
                 signal sync_irq_from_pcp_s1_irq_from_sa : IN STD_LOGIC;
                 signal system_timer_ap_s1_irq_from_sa : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ap_cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_data_master_waitrequest : OUT STD_LOGIC
              );
end entity ap_cpu_data_master_arbitrator;


architecture europa of ap_cpu_data_master_arbitrator is
component jtag_uart_1_avalon_jtag_slave_irq_from_sa_clock_crossing_ap_cpu_data_master_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component jtag_uart_1_avalon_jtag_slave_irq_from_sa_clock_crossing_ap_cpu_data_master_module;

component spi_master_spi_control_port_irq_from_sa_clock_crossing_ap_cpu_data_master_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component spi_master_spi_control_port_irq_from_sa_clock_crossing_ap_cpu_data_master_module;

component sync_irq_from_pcp_s1_irq_from_sa_clock_crossing_ap_cpu_data_master_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component sync_irq_from_pcp_s1_irq_from_sa_clock_crossing_ap_cpu_data_master_module;

component system_timer_ap_s1_irq_from_sa_clock_crossing_ap_cpu_data_master_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component system_timer_ap_s1_irq_from_sa_clock_crossing_ap_cpu_data_master_module;

                signal ap_clk_jtag_uart_1_avalon_jtag_slave_irq_from_sa :  STD_LOGIC;
                signal ap_clk_spi_master_spi_control_port_irq_from_sa :  STD_LOGIC;
                signal ap_clk_sync_irq_from_pcp_s1_irq_from_sa :  STD_LOGIC;
                signal ap_clk_system_timer_ap_s1_irq_from_sa :  STD_LOGIC;
                signal ap_cpu_data_master_run :  STD_LOGIC;
                signal internal_ap_cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal internal_ap_cpu_data_master_waitrequest :  STD_LOGIC;
                signal p1_registered_ap_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal registered_ap_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic(((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module OR NOT ap_cpu_data_master_requests_ap_cpu_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_granted_ap_cpu_jtag_debug_module OR NOT ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module OR NOT ap_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module OR NOT ap_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((ap_cpu_data_master_qualified_request_clock_crossing_0_s1 OR ap_cpu_data_master_read_data_valid_clock_crossing_0_s1) OR NOT ap_cpu_data_master_requests_clock_crossing_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT ap_cpu_data_master_qualified_request_clock_crossing_0_s1 OR NOT ap_cpu_data_master_read) OR ((ap_cpu_data_master_read_data_valid_clock_crossing_0_s1 AND ap_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_clock_crossing_0_s1 OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT clock_crossing_0_s1_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port OR NOT ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((ap_cpu_data_master_qualified_request_onchip_memory_0_s1 OR registered_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1) OR NOT ap_cpu_data_master_requests_onchip_memory_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_granted_onchip_memory_0_s1 OR NOT ap_cpu_data_master_qualified_request_onchip_memory_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT ap_cpu_data_master_qualified_request_onchip_memory_0_s1 OR NOT ap_cpu_data_master_read) OR ((registered_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 AND ap_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_onchip_memory_0_s1 OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  ap_cpu_data_master_run <= r_0 AND r_1;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave OR registered_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave) OR NOT ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave OR NOT ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave OR NOT ap_cpu_data_master_read) OR ((registered_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave AND ap_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave OR NOT ap_cpu_data_master_write)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_write)))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_ap_cpu_data_master_address_to_slave <= Std_Logic_Vector'(A_ToStdLogicVector(ap_cpu_data_master_address(24)) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(ap_cpu_data_master_address(22)) & A_ToStdLogicVector(std_logic'('0')) & ap_cpu_data_master_address(20 DOWNTO 0));
  --ap_cpu/data_master readdata mux, which is an e_mux
  ap_cpu_data_master_readdata <= (((((A_REP(NOT ap_cpu_data_master_requests_ap_cpu_jtag_debug_module, 32) OR ap_cpu_jtag_debug_module_readdata_from_sa)) AND ((A_REP(NOT ap_cpu_data_master_requests_clock_crossing_0_s1, 32) OR registered_ap_cpu_data_master_readdata))) AND ((A_REP(NOT ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port, 32) OR epcs_flash_controller_0_epcs_control_port_readdata_from_sa))) AND ((A_REP(NOT ap_cpu_data_master_requests_onchip_memory_0_s1, 32) OR onchip_memory_0_s1_readdata_from_sa))) AND ((A_REP(NOT ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave, 32) OR incoming_tri_state_bridge_0_data));
  --actual waitrequest port, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_ap_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      internal_ap_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT (A_WE_StdLogicVector((std_logic'((NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_run AND internal_ap_cpu_data_master_waitrequest))))))));
    end if;

  end process;

  --unpredictable registered wait state incoming data, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      registered_ap_cpu_data_master_readdata <= std_logic_vector'("00000000000000000000000000000000");
    elsif clk'event and clk = '1' then
      registered_ap_cpu_data_master_readdata <= p1_registered_ap_cpu_data_master_readdata;
    end if;

  end process;

  --registered readdata mux, which is an e_mux
  p1_registered_ap_cpu_data_master_readdata <= A_REP(NOT ap_cpu_data_master_requests_clock_crossing_0_s1, 32) OR clock_crossing_0_s1_readdata_from_sa;
  --irq assign, which is an e_assign
  ap_cpu_data_master_irq <= Std_Logic_Vector'(A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(epcs_flash_controller_0_epcs_control_port_irq_from_sa) & A_ToStdLogicVector(ap_clk_sync_irq_from_pcp_s1_irq_from_sa) & A_ToStdLogicVector(ap_clk_system_timer_ap_s1_irq_from_sa) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(ap_clk_jtag_uart_1_avalon_jtag_slave_irq_from_sa) & A_ToStdLogicVector(ap_clk_spi_master_spi_control_port_irq_from_sa));
  --jtag_uart_1_avalon_jtag_slave_irq_from_sa from clk50Meg to ap_clk
  jtag_uart_1_avalon_jtag_slave_irq_from_sa_clock_crossing_ap_cpu_data_master : jtag_uart_1_avalon_jtag_slave_irq_from_sa_clock_crossing_ap_cpu_data_master_module
    port map(
      data_out => ap_clk_jtag_uart_1_avalon_jtag_slave_irq_from_sa,
      clk => ap_clk,
      data_in => jtag_uart_1_avalon_jtag_slave_irq_from_sa,
      reset_n => ap_clk_reset_n
    );


  --spi_master_spi_control_port_irq_from_sa from clk_0 to ap_clk
  spi_master_spi_control_port_irq_from_sa_clock_crossing_ap_cpu_data_master : spi_master_spi_control_port_irq_from_sa_clock_crossing_ap_cpu_data_master_module
    port map(
      data_out => ap_clk_spi_master_spi_control_port_irq_from_sa,
      clk => ap_clk,
      data_in => spi_master_spi_control_port_irq_from_sa,
      reset_n => ap_clk_reset_n
    );


  --sync_irq_from_pcp_s1_irq_from_sa from clk50Meg to ap_clk
  sync_irq_from_pcp_s1_irq_from_sa_clock_crossing_ap_cpu_data_master : sync_irq_from_pcp_s1_irq_from_sa_clock_crossing_ap_cpu_data_master_module
    port map(
      data_out => ap_clk_sync_irq_from_pcp_s1_irq_from_sa,
      clk => ap_clk,
      data_in => sync_irq_from_pcp_s1_irq_from_sa,
      reset_n => ap_clk_reset_n
    );


  --system_timer_ap_s1_irq_from_sa from clk50Meg to ap_clk
  system_timer_ap_s1_irq_from_sa_clock_crossing_ap_cpu_data_master : system_timer_ap_s1_irq_from_sa_clock_crossing_ap_cpu_data_master_module
    port map(
      data_out => ap_clk_system_timer_ap_s1_irq_from_sa,
      clk => ap_clk,
      data_in => system_timer_ap_s1_irq_from_sa,
      reset_n => ap_clk_reset_n
    );


  --vhdl renameroo for output signals
  ap_cpu_data_master_address_to_slave <= internal_ap_cpu_data_master_address_to_slave;
  --vhdl renameroo for output signals
  ap_cpu_data_master_waitrequest <= internal_ap_cpu_data_master_waitrequest;

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

entity ap_cpu_instruction_master_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_instruction_master_address : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                 signal ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_granted_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_onchip_memory_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal d1_ap_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_memory_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_tri_state_bridge_0_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal incoming_tri_state_bridge_0_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal onchip_memory_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                 signal ap_cpu_instruction_master_latency_counter : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ap_cpu_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_instruction_master_readdatavalid : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_waitrequest : OUT STD_LOGIC
              );
end entity ap_cpu_instruction_master_arbitrator;


architecture europa of ap_cpu_instruction_master_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal ap_cpu_instruction_master_address_last_time :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal ap_cpu_instruction_master_is_granted_some_slave :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_but_no_slave_selected :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_last_time :  STD_LOGIC;
                signal ap_cpu_instruction_master_run :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal internal_ap_cpu_instruction_master_latency_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_ap_cpu_instruction_master_waitrequest :  STD_LOGIC;
                signal latency_load_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_ap_cpu_instruction_master_latency_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal pre_flush_ap_cpu_instruction_master_readdatavalid :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module OR NOT ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module OR NOT ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module OR NOT ap_cpu_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_ap_cpu_jtag_debug_module_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_read)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port OR NOT ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT (ap_cpu_instruction_master_read))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_epcs_flash_controller_0_epcs_control_port_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((ap_cpu_instruction_master_read))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1 OR NOT ap_cpu_instruction_master_requests_onchip_memory_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_granted_onchip_memory_0_s1 OR NOT ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1 OR NOT ap_cpu_instruction_master_read)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_read)))))))));
  --cascaded wait assignment, which is an e_assign
  ap_cpu_instruction_master_run <= r_0 AND r_1;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave OR NOT ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave OR NOT ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave OR NOT ap_cpu_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_tri_state_bridge_0_avalon_slave_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_read)))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_ap_cpu_instruction_master_address_to_slave <= Std_Logic_Vector'(A_ToStdLogicVector(ap_cpu_instruction_master_address(22)) & A_ToStdLogicVector(std_logic'('0')) & ap_cpu_instruction_master_address(20 DOWNTO 0));
  --ap_cpu_instruction_master_read_but_no_slave_selected assignment, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ap_cpu_instruction_master_read_but_no_slave_selected <= std_logic'('0');
    elsif clk'event and clk = '1' then
      ap_cpu_instruction_master_read_but_no_slave_selected <= (ap_cpu_instruction_master_read AND ap_cpu_instruction_master_run) AND NOT ap_cpu_instruction_master_is_granted_some_slave;
    end if;

  end process;

  --some slave is getting selected, which is an e_mux
  ap_cpu_instruction_master_is_granted_some_slave <= ((ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module OR ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port) OR ap_cpu_instruction_master_granted_onchip_memory_0_s1) OR ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave;
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_ap_cpu_instruction_master_readdatavalid <= ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 OR ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave;
  --latent slave read data valid which is not flushed, which is an e_mux
  ap_cpu_instruction_master_readdatavalid <= ((((((((ap_cpu_instruction_master_read_but_no_slave_selected OR pre_flush_ap_cpu_instruction_master_readdatavalid) OR ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module) OR ap_cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_ap_cpu_instruction_master_readdatavalid) OR ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port) OR ap_cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_ap_cpu_instruction_master_readdatavalid) OR ap_cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_ap_cpu_instruction_master_readdatavalid;
  --ap_cpu/instruction_master readdata mux, which is an e_mux
  ap_cpu_instruction_master_readdata <= ((((A_REP(NOT ((ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module AND ap_cpu_instruction_master_read)) , 32) OR ap_cpu_jtag_debug_module_readdata_from_sa)) AND ((A_REP(NOT ((ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port AND ap_cpu_instruction_master_read)) , 32) OR epcs_flash_controller_0_epcs_control_port_readdata_from_sa))) AND ((A_REP(NOT ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1, 32) OR onchip_memory_0_s1_readdata_from_sa))) AND ((A_REP(NOT ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave, 32) OR incoming_tri_state_bridge_0_data));
  --actual waitrequest port, which is an e_assign
  internal_ap_cpu_instruction_master_waitrequest <= NOT ap_cpu_instruction_master_run;
  --latent max counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_ap_cpu_instruction_master_latency_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      internal_ap_cpu_instruction_master_latency_counter <= p1_ap_cpu_instruction_master_latency_counter;
    end if;

  end process;

  --latency counter load mux, which is an e_mux
  p1_ap_cpu_instruction_master_latency_counter <= A_EXT (A_WE_StdLogicVector((std_logic'(((ap_cpu_instruction_master_run AND ap_cpu_instruction_master_read))) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (latency_load_value)), A_WE_StdLogicVector((((internal_ap_cpu_instruction_master_latency_counter)) /= std_logic_vector'("00")), ((std_logic_vector'("0000000000000000000000000000000") & (internal_ap_cpu_instruction_master_latency_counter)) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --read latency load values, which is an e_mux
  latency_load_value <= A_EXT (((((std_logic_vector'("000000000000000000000000000000") & (A_REP(ap_cpu_instruction_master_requests_onchip_memory_0_s1, 2))) AND std_logic_vector'("00000000000000000000000000000001"))) OR (((std_logic_vector'("000000000000000000000000000000") & (A_REP(ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave, 2))) AND std_logic_vector'("00000000000000000000000000000010")))), 2);
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_address_to_slave <= internal_ap_cpu_instruction_master_address_to_slave;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_latency_counter <= internal_ap_cpu_instruction_master_latency_counter;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_waitrequest <= internal_ap_cpu_instruction_master_waitrequest;
--synthesis translate_off
    --ap_cpu_instruction_master_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ap_cpu_instruction_master_address_last_time <= std_logic_vector'("00000000000000000000000");
      elsif clk'event and clk = '1' then
        ap_cpu_instruction_master_address_last_time <= ap_cpu_instruction_master_address;
      end if;

    end process;

    --ap_cpu/instruction_master waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_ap_cpu_instruction_master_waitrequest AND (ap_cpu_instruction_master_read);
      end if;

    end process;

    --ap_cpu_instruction_master_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line2 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((ap_cpu_instruction_master_address /= ap_cpu_instruction_master_address_last_time))))) = '1' then 
          write(write_line2, now);
          write(write_line2, string'(": "));
          write(write_line2, string'("ap_cpu_instruction_master_address did not heed wait!!!"));
          write(output, write_line2.all);
          deallocate (write_line2);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --ap_cpu_instruction_master_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        ap_cpu_instruction_master_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        ap_cpu_instruction_master_read_last_time <= ap_cpu_instruction_master_read;
      end if;

    end process;

    --ap_cpu_instruction_master_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line3 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(ap_cpu_instruction_master_read) /= std_logic'(ap_cpu_instruction_master_read_last_time)))))) = '1' then 
          write(write_line3, now);
          write(write_line3, string'(": "));
          write(write_line3, string'("ap_cpu_instruction_master_read did not heed wait!!!"));
          write(output, write_line3.all);
          deallocate (write_line3);
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

entity rdv_fifo_for_ap_cpu_data_master_to_clock_crossing_0_s1_module is 
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
end entity rdv_fifo_for_ap_cpu_data_master_to_clock_crossing_0_s1_module;


architecture europa of rdv_fifo_for_ap_cpu_data_master_to_clock_crossing_0_s1_module is
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
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_s1_endofpacket : IN STD_LOGIC;
                 signal clock_crossing_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clock_crossing_0_s1_readdatavalid : IN STD_LOGIC;
                 signal clock_crossing_0_s1_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_clock_crossing_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_clock_crossing_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_clock_crossing_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_clock_crossing_0_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_s1_address : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal clock_crossing_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal clock_crossing_0_s1_endofpacket_from_sa : OUT STD_LOGIC;
                 signal clock_crossing_0_s1_nativeaddress : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal clock_crossing_0_s1_read : OUT STD_LOGIC;
                 signal clock_crossing_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clock_crossing_0_s1_reset_n : OUT STD_LOGIC;
                 signal clock_crossing_0_s1_waitrequest_from_sa : OUT STD_LOGIC;
                 signal clock_crossing_0_s1_write : OUT STD_LOGIC;
                 signal clock_crossing_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_clock_crossing_0_s1_end_xfer : OUT STD_LOGIC
              );
end entity clock_crossing_0_s1_arbitrator;


architecture europa of clock_crossing_0_s1_arbitrator is
component rdv_fifo_for_ap_cpu_data_master_to_clock_crossing_0_s1_module is 
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
end component rdv_fifo_for_ap_cpu_data_master_to_clock_crossing_0_s1_module;

                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_rdv_fifo_empty_clock_crossing_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_rdv_fifo_output_from_clock_crossing_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_clock_crossing_0_s1 :  STD_LOGIC;
                signal clock_crossing_0_s1_allgrants :  STD_LOGIC;
                signal clock_crossing_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal clock_crossing_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal clock_crossing_0_s1_any_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_s1_arb_counter_enable :  STD_LOGIC;
                signal clock_crossing_0_s1_arb_share_counter :  STD_LOGIC;
                signal clock_crossing_0_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal clock_crossing_0_s1_arb_share_set_values :  STD_LOGIC;
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
                signal internal_ap_cpu_data_master_granted_clock_crossing_0_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_clock_crossing_0_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_clock_crossing_0_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_s1_waitrequest_from_sa :  STD_LOGIC;
                signal module_input :  STD_LOGIC;
                signal module_input1 :  STD_LOGIC;
                signal module_input2 :  STD_LOGIC;
                signal shifted_address_to_clock_crossing_0_s1_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (24 DOWNTO 0);
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

  clock_crossing_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_clock_crossing_0_s1);
  --assign clock_crossing_0_s1_readdata_from_sa = clock_crossing_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  clock_crossing_0_s1_readdata_from_sa <= clock_crossing_0_s1_readdata;
  internal_ap_cpu_data_master_requests_clock_crossing_0_s1 <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(24 DOWNTO 8) & std_logic_vector'("00000000")) = std_logic_vector'("1000000000000000000000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --assign clock_crossing_0_s1_waitrequest_from_sa = clock_crossing_0_s1_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_clock_crossing_0_s1_waitrequest_from_sa <= clock_crossing_0_s1_waitrequest;
  --assign clock_crossing_0_s1_readdatavalid_from_sa = clock_crossing_0_s1_readdatavalid so that symbol knows where to group signals which may go to master only, which is an e_assign
  clock_crossing_0_s1_readdatavalid_from_sa <= clock_crossing_0_s1_readdatavalid;
  --clock_crossing_0_s1_arb_share_counter set values, which is an e_mux
  clock_crossing_0_s1_arb_share_set_values <= std_logic'('1');
  --clock_crossing_0_s1_non_bursting_master_requests mux, which is an e_mux
  clock_crossing_0_s1_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_clock_crossing_0_s1;
  --clock_crossing_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  clock_crossing_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --clock_crossing_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  clock_crossing_0_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(clock_crossing_0_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(clock_crossing_0_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
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
      clock_crossing_0_s1_arb_share_counter <= std_logic'('0');
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
        clock_crossing_0_s1_slavearbiterlockenable <= clock_crossing_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ap_cpu/data_master clock_crossing_0/s1 arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= clock_crossing_0_s1_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --clock_crossing_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  clock_crossing_0_s1_slavearbiterlockenable2 <= clock_crossing_0_s1_arb_share_counter_next_value;
  --ap_cpu/data_master clock_crossing_0/s1 arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= clock_crossing_0_s1_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --clock_crossing_0_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  clock_crossing_0_s1_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_clock_crossing_0_s1 <= internal_ap_cpu_data_master_requests_clock_crossing_0_s1 AND NOT ((((ap_cpu_data_master_read AND ((NOT ap_cpu_data_master_waitrequest OR (internal_ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register))))) OR (((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write))));
  --unique name for clock_crossing_0_s1_move_on_to_next_transaction, which is an e_assign
  clock_crossing_0_s1_move_on_to_next_transaction <= clock_crossing_0_s1_readdatavalid_from_sa;
  --rdv_fifo_for_ap_cpu_data_master_to_clock_crossing_0_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_ap_cpu_data_master_to_clock_crossing_0_s1 : rdv_fifo_for_ap_cpu_data_master_to_clock_crossing_0_s1_module
    port map(
      data_out => ap_cpu_data_master_rdv_fifo_output_from_clock_crossing_0_s1,
      empty => open,
      fifo_contains_ones_n => ap_cpu_data_master_rdv_fifo_empty_clock_crossing_0_s1,
      full => open,
      clear_fifo => module_input,
      clk => clk,
      data_in => internal_ap_cpu_data_master_granted_clock_crossing_0_s1,
      read => clock_crossing_0_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input1,
      write => module_input2
    );

  module_input <= std_logic'('0');
  module_input1 <= std_logic'('0');
  module_input2 <= in_a_read_cycle AND NOT clock_crossing_0_s1_waits_for_read;

  internal_ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register <= NOT ap_cpu_data_master_rdv_fifo_empty_clock_crossing_0_s1;
  --local readdatavalid ap_cpu_data_master_read_data_valid_clock_crossing_0_s1, which is an e_mux
  ap_cpu_data_master_read_data_valid_clock_crossing_0_s1 <= clock_crossing_0_s1_readdatavalid_from_sa;
  --clock_crossing_0_s1_writedata mux, which is an e_mux
  clock_crossing_0_s1_writedata <= ap_cpu_data_master_writedata;
  --assign clock_crossing_0_s1_endofpacket_from_sa = clock_crossing_0_s1_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  clock_crossing_0_s1_endofpacket_from_sa <= clock_crossing_0_s1_endofpacket;
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_clock_crossing_0_s1 <= internal_ap_cpu_data_master_qualified_request_clock_crossing_0_s1;
  --ap_cpu/data_master saved-grant clock_crossing_0/s1, which is an e_assign
  ap_cpu_data_master_saved_grant_clock_crossing_0_s1 <= internal_ap_cpu_data_master_requests_clock_crossing_0_s1;
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
  clock_crossing_0_s1_read <= internal_ap_cpu_data_master_granted_clock_crossing_0_s1 AND ap_cpu_data_master_read;
  --clock_crossing_0_s1_write assignment, which is an e_mux
  clock_crossing_0_s1_write <= internal_ap_cpu_data_master_granted_clock_crossing_0_s1 AND ap_cpu_data_master_write;
  shifted_address_to_clock_crossing_0_s1_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --clock_crossing_0_s1_address mux, which is an e_mux
  clock_crossing_0_s1_address <= A_EXT (A_SRL(shifted_address_to_clock_crossing_0_s1_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 6);
  --slaveid clock_crossing_0_s1_nativeaddress nativeaddress mux, which is an e_mux
  clock_crossing_0_s1_nativeaddress <= A_EXT (A_SRL(ap_cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 6);
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
  clock_crossing_0_s1_in_a_read_cycle <= internal_ap_cpu_data_master_granted_clock_crossing_0_s1 AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= clock_crossing_0_s1_in_a_read_cycle;
  --clock_crossing_0_s1_waits_for_write in a cycle, which is an e_mux
  clock_crossing_0_s1_waits_for_write <= clock_crossing_0_s1_in_a_write_cycle AND internal_clock_crossing_0_s1_waitrequest_from_sa;
  --clock_crossing_0_s1_in_a_write_cycle assignment, which is an e_assign
  clock_crossing_0_s1_in_a_write_cycle <= internal_ap_cpu_data_master_granted_clock_crossing_0_s1 AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= clock_crossing_0_s1_in_a_write_cycle;
  wait_for_clock_crossing_0_s1_counter <= std_logic'('0');
  --clock_crossing_0_s1_byteenable byte enable port mux, which is an e_mux
  clock_crossing_0_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_clock_crossing_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ap_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_clock_crossing_0_s1 <= internal_ap_cpu_data_master_granted_clock_crossing_0_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_clock_crossing_0_s1 <= internal_ap_cpu_data_master_qualified_request_clock_crossing_0_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register <= internal_ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_clock_crossing_0_s1 <= internal_ap_cpu_data_master_requests_clock_crossing_0_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_s1_waitrequest_from_sa <= internal_clock_crossing_0_s1_waitrequest_from_sa;
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
                 signal clock_crossing_0_m1_address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clock_crossing_0_m1_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal clock_crossing_0_m1_granted_inport_ap_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                 signal clock_crossing_0_m1_granted_niosII_openMac_clock_0_in : IN STD_LOGIC;
                 signal clock_crossing_0_m1_granted_niosII_openMac_clock_1_in : IN STD_LOGIC;
                 signal clock_crossing_0_m1_granted_outport_ap_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_granted_status_led_pio_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_granted_sysid_control_slave : IN STD_LOGIC;
                 signal clock_crossing_0_m1_granted_system_timer_ap_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_inport_ap_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_outport_ap_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_status_led_pio_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_sysid_control_slave : IN STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_system_timer_ap_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_inport_ap_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_0_in : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_1_in : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_outport_ap_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_status_led_pio_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_system_timer_ap_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_inport_ap_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_niosII_openMac_clock_0_in : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_niosII_openMac_clock_1_in : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_outport_ap_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_status_led_pio_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_sysid_control_slave : IN STD_LOGIC;
                 signal clock_crossing_0_m1_requests_system_timer_ap_s1 : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_inport_ap_s1_end_xfer : IN STD_LOGIC;
                 signal d1_jtag_uart_1_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                 signal d1_niosII_openMac_clock_0_in_end_xfer : IN STD_LOGIC;
                 signal d1_niosII_openMac_clock_1_in_end_xfer : IN STD_LOGIC;
                 signal d1_outport_ap_s1_end_xfer : IN STD_LOGIC;
                 signal d1_status_led_pio_s1_end_xfer : IN STD_LOGIC;
                 signal d1_sync_irq_from_pcp_s1_end_xfer : IN STD_LOGIC;
                 signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                 signal d1_system_timer_ap_s1_end_xfer : IN STD_LOGIC;
                 signal inport_ap_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal jtag_uart_1_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_in_endofpacket_from_sa : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_in_endofpacket_from_sa : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_in_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal outport_ap_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal status_led_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal sync_irq_from_pcp_s1_readdata_from_sa : IN STD_LOGIC;
                 signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal system_timer_ap_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal clock_crossing_0_m1_address_to_slave : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clock_crossing_0_m1_endofpacket : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_latency_counter : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clock_crossing_0_m1_readdatavalid : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_reset_n : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_waitrequest : OUT STD_LOGIC
              );
end entity clock_crossing_0_m1_arbitrator;


architecture europa of clock_crossing_0_m1_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal clock_crossing_0_m1_address_last_time :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal clock_crossing_0_m1_byteenable_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal clock_crossing_0_m1_is_granted_some_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_read_but_no_slave_selected :  STD_LOGIC;
                signal clock_crossing_0_m1_read_last_time :  STD_LOGIC;
                signal clock_crossing_0_m1_run :  STD_LOGIC;
                signal clock_crossing_0_m1_write_last_time :  STD_LOGIC;
                signal clock_crossing_0_m1_writedata_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal internal_clock_crossing_0_m1_address_to_slave :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_clock_crossing_0_m1_latency_counter :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_waitrequest :  STD_LOGIC;
                signal latency_load_value :  STD_LOGIC;
                signal p1_clock_crossing_0_m1_latency_counter :  STD_LOGIC;
                signal pre_flush_clock_crossing_0_m1_readdatavalid :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_inport_ap_s1 OR NOT clock_crossing_0_m1_requests_inport_ap_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_inport_ap_s1 OR NOT clock_crossing_0_m1_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_inport_ap_s1_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_inport_ap_s1 OR NOT clock_crossing_0_m1_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave OR NOT clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave OR NOT ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave OR NOT ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in OR NOT clock_crossing_0_m1_requests_niosII_openMac_clock_0_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in OR NOT ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_0_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in OR NOT ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_0_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in OR NOT clock_crossing_0_m1_requests_niosII_openMac_clock_1_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in OR NOT ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_1_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in OR NOT ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_1_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_outport_ap_s1 OR NOT clock_crossing_0_m1_requests_outport_ap_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_outport_ap_s1 OR NOT clock_crossing_0_m1_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_outport_ap_s1_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_outport_ap_s1 OR NOT clock_crossing_0_m1_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_write)))))))));
  --cascaded wait assignment, which is an e_assign
  clock_crossing_0_m1_run <= r_0 AND r_1;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_status_led_pio_s1 OR NOT clock_crossing_0_m1_requests_status_led_pio_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_status_led_pio_s1 OR NOT clock_crossing_0_m1_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_status_led_pio_s1_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_status_led_pio_s1 OR NOT clock_crossing_0_m1_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 OR NOT clock_crossing_0_m1_requests_sync_irq_from_pcp_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 OR NOT clock_crossing_0_m1_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_sync_irq_from_pcp_s1_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 OR NOT clock_crossing_0_m1_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_sysid_control_slave OR NOT clock_crossing_0_m1_requests_sysid_control_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_sysid_control_slave OR NOT clock_crossing_0_m1_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_sysid_control_slave_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_sysid_control_slave OR NOT clock_crossing_0_m1_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((clock_crossing_0_m1_qualified_request_system_timer_ap_s1 OR NOT clock_crossing_0_m1_requests_system_timer_ap_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_system_timer_ap_s1 OR NOT clock_crossing_0_m1_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_system_timer_ap_s1_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT clock_crossing_0_m1_qualified_request_system_timer_ap_s1 OR NOT clock_crossing_0_m1_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_write)))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_clock_crossing_0_m1_address_to_slave <= clock_crossing_0_m1_address(7 DOWNTO 0);
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
  clock_crossing_0_m1_is_granted_some_slave <= (((((((clock_crossing_0_m1_granted_inport_ap_s1 OR clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave) OR clock_crossing_0_m1_granted_niosII_openMac_clock_0_in) OR clock_crossing_0_m1_granted_niosII_openMac_clock_1_in) OR clock_crossing_0_m1_granted_outport_ap_s1) OR clock_crossing_0_m1_granted_status_led_pio_s1) OR clock_crossing_0_m1_granted_sync_irq_from_pcp_s1) OR clock_crossing_0_m1_granted_sysid_control_slave) OR clock_crossing_0_m1_granted_system_timer_ap_s1;
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_clock_crossing_0_m1_readdatavalid <= std_logic'('0');
  --latent slave read data valid which is not flushed, which is an e_mux
  clock_crossing_0_m1_readdatavalid <= (((((((((((((((((((((((((clock_crossing_0_m1_read_but_no_slave_selected OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_inport_ap_s1) OR clock_crossing_0_m1_read_but_no_slave_selected) OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_jtag_uart_1_avalon_jtag_slave) OR clock_crossing_0_m1_read_but_no_slave_selected) OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_0_in) OR clock_crossing_0_m1_read_but_no_slave_selected) OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_1_in) OR clock_crossing_0_m1_read_but_no_slave_selected) OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_outport_ap_s1) OR clock_crossing_0_m1_read_but_no_slave_selected) OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_status_led_pio_s1) OR clock_crossing_0_m1_read_but_no_slave_selected) OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_sync_irq_from_pcp_s1) OR clock_crossing_0_m1_read_but_no_slave_selected) OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_sysid_control_slave) OR clock_crossing_0_m1_read_but_no_slave_selected) OR pre_flush_clock_crossing_0_m1_readdatavalid) OR clock_crossing_0_m1_read_data_valid_system_timer_ap_s1;
  --clock_crossing_0/m1 readdata mux, which is an e_mux
  clock_crossing_0_m1_readdata <= (((((((((A_REP(NOT ((clock_crossing_0_m1_qualified_request_inport_ap_s1 AND clock_crossing_0_m1_read)) , 32) OR (std_logic_vector'("000000000000000000000000") & (inport_ap_s1_readdata_from_sa)))) AND ((A_REP(NOT ((clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave AND clock_crossing_0_m1_read)) , 32) OR jtag_uart_1_avalon_jtag_slave_readdata_from_sa))) AND ((A_REP(NOT ((clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in AND clock_crossing_0_m1_read)) , 32) OR niosII_openMac_clock_0_in_readdata_from_sa))) AND ((A_REP(NOT ((clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in AND clock_crossing_0_m1_read)) , 32) OR (std_logic_vector'("0000000000000000") & (niosII_openMac_clock_1_in_readdata_from_sa))))) AND ((A_REP(NOT ((clock_crossing_0_m1_qualified_request_outport_ap_s1 AND clock_crossing_0_m1_read)) , 32) OR (std_logic_vector'("00000000") & (outport_ap_s1_readdata_from_sa))))) AND ((A_REP(NOT ((clock_crossing_0_m1_qualified_request_status_led_pio_s1 AND clock_crossing_0_m1_read)) , 32) OR (std_logic_vector'("000000000000000000000000000000") & (status_led_pio_s1_readdata_from_sa))))) AND ((A_REP(NOT ((clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 AND clock_crossing_0_m1_read)) , 32) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sync_irq_from_pcp_s1_readdata_from_sa)))))) AND ((A_REP(NOT ((clock_crossing_0_m1_qualified_request_sysid_control_slave AND clock_crossing_0_m1_read)) , 32) OR sysid_control_slave_readdata_from_sa))) AND ((A_REP(NOT ((clock_crossing_0_m1_qualified_request_system_timer_ap_s1 AND clock_crossing_0_m1_read)) , 32) OR (std_logic_vector'("0000000000000000") & (system_timer_ap_s1_readdata_from_sa))));
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
  --mux clock_crossing_0_m1_endofpacket, which is an e_mux
  clock_crossing_0_m1_endofpacket <= A_WE_StdLogic((std_logic'((clock_crossing_0_m1_requests_niosII_openMac_clock_0_in)) = '1'), niosII_openMac_clock_0_in_endofpacket_from_sa, niosII_openMac_clock_1_in_endofpacket_from_sa);
  --vhdl renameroo for output signals
  clock_crossing_0_m1_address_to_slave <= internal_clock_crossing_0_m1_address_to_slave;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_latency_counter <= internal_clock_crossing_0_m1_latency_counter;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_waitrequest <= internal_clock_crossing_0_m1_waitrequest;
--synthesis translate_off
    --clock_crossing_0_m1_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        clock_crossing_0_m1_address_last_time <= std_logic_vector'("00000000");
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
    VARIABLE write_line4 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((clock_crossing_0_m1_address /= clock_crossing_0_m1_address_last_time))))) = '1' then 
          write(write_line4, now);
          write(write_line4, string'(": "));
          write(write_line4, string'("clock_crossing_0_m1_address did not heed wait!!!"));
          write(output, write_line4.all);
          deallocate (write_line4);
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
    VARIABLE write_line5 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((clock_crossing_0_m1_byteenable /= clock_crossing_0_m1_byteenable_last_time))))) = '1' then 
          write(write_line5, now);
          write(write_line5, string'(": "));
          write(write_line5, string'("clock_crossing_0_m1_byteenable did not heed wait!!!"));
          write(output, write_line5.all);
          deallocate (write_line5);
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
    VARIABLE write_line6 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(clock_crossing_0_m1_read) /= std_logic'(clock_crossing_0_m1_read_last_time)))))) = '1' then 
          write(write_line6, now);
          write(write_line6, string'(": "));
          write(write_line6, string'("clock_crossing_0_m1_read did not heed wait!!!"));
          write(output, write_line6.all);
          deallocate (write_line6);
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
    VARIABLE write_line7 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(clock_crossing_0_m1_write) /= std_logic'(clock_crossing_0_m1_write_last_time)))))) = '1' then 
          write(write_line7, now);
          write(write_line7, string'(": "));
          write(write_line7, string'("clock_crossing_0_m1_write did not heed wait!!!"));
          write(output, write_line7.all);
          deallocate (write_line7);
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
    VARIABLE write_line8 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((clock_crossing_0_m1_writedata /= clock_crossing_0_m1_writedata_last_time)))) AND clock_crossing_0_m1_write)) = '1' then 
          write(write_line8, now);
          write(write_line8, string'(": "));
          write(write_line8, string'("clock_crossing_0_m1_writedata did not heed wait!!!"));
          write(output, write_line8.all);
          deallocate (write_line8);
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
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                 signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_dataavailable : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_endofpacket : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_irq : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal epcs_flash_controller_0_epcs_control_port_readyfordata : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
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
                 signal epcs_flash_controller_0_epcs_control_port_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity epcs_flash_controller_0_epcs_control_port_arbitrator;


architecture europa of epcs_flash_controller_0_epcs_control_port_arbitrator is
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_instruction_master_saved_grant_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_allgrants :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_allow_new_arb_cycle :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_any_bursting_master_saved_grant :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_any_continuerequest :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_arb_counter_enable :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_arb_share_counter :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_arb_share_set_values :  STD_LOGIC;
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
                signal internal_ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal last_cycle_ap_cpu_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal last_cycle_ap_cpu_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_ap_cpu_instruction_master :  STD_LOGIC_VECTOR (22 DOWNTO 0);
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

  epcs_flash_controller_0_epcs_control_port_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR internal_ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port));
  --assign epcs_flash_controller_0_epcs_control_port_readdata_from_sa = epcs_flash_controller_0_epcs_control_port_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_readdata_from_sa <= epcs_flash_controller_0_epcs_control_port_readdata;
  internal_ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(24 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0000000000000000000000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --assign epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa = epcs_flash_controller_0_epcs_control_port_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa <= epcs_flash_controller_0_epcs_control_port_dataavailable;
  --assign epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa = epcs_flash_controller_0_epcs_control_port_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa <= epcs_flash_controller_0_epcs_control_port_readyfordata;
  --epcs_flash_controller_0_epcs_control_port_arb_share_counter set values, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_arb_share_set_values <= std_logic'('1');
  --epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests mux, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests <= ((internal_ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port OR internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port) OR internal_ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port) OR internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;
  --epcs_flash_controller_0_epcs_control_port_any_bursting_master_saved_grant mux, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_any_bursting_master_saved_grant <= std_logic'('0');
  --epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value assignment, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(epcs_flash_controller_0_epcs_control_port_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(epcs_flash_controller_0_epcs_control_port_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(epcs_flash_controller_0_epcs_control_port_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(epcs_flash_controller_0_epcs_control_port_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
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
      epcs_flash_controller_0_epcs_control_port_arb_share_counter <= std_logic'('0');
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
        epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable <= epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ap_cpu/data_master epcs_flash_controller_0/epcs_control_port arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 <= epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value;
  --ap_cpu/data_master epcs_flash_controller_0/epcs_control_port arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --ap_cpu/instruction_master epcs_flash_controller_0/epcs_control_port arbiterlock, which is an e_assign
  ap_cpu_instruction_master_arbiterlock <= epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable AND ap_cpu_instruction_master_continuerequest;
  --ap_cpu/instruction_master epcs_flash_controller_0/epcs_control_port arbiterlock2, which is an e_assign
  ap_cpu_instruction_master_arbiterlock2 <= epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 AND ap_cpu_instruction_master_continuerequest;
  --ap_cpu/instruction_master granted epcs_flash_controller_0/epcs_control_port last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ap_cpu_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_ap_cpu_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ap_cpu_instruction_master_saved_grant_epcs_flash_controller_0_epcs_control_port) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((epcs_flash_controller_0_epcs_control_port_arbitration_holdoff_internal OR NOT internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ap_cpu_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port))))));
    end if;

  end process;

  --ap_cpu_instruction_master_continuerequest continued request, which is an e_mux
  ap_cpu_instruction_master_continuerequest <= last_cycle_ap_cpu_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port AND internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;
  --epcs_flash_controller_0_epcs_control_port_any_continuerequest at least one master continues requesting, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_any_continuerequest <= ap_cpu_instruction_master_continuerequest OR ap_cpu_data_master_continuerequest;
  internal_ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port <= internal_ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port AND NOT (ap_cpu_instruction_master_arbiterlock);
  --epcs_flash_controller_0_epcs_control_port_writedata mux, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_writedata <= ap_cpu_data_master_writedata;
  --assign epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa = epcs_flash_controller_0_epcs_control_port_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa <= epcs_flash_controller_0_epcs_control_port_endofpacket;
  internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port <= ((to_std_logic(((Std_Logic_Vector'(ap_cpu_instruction_master_address_to_slave(22 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("00000000000000000000000")))) AND (ap_cpu_instruction_master_read))) AND ap_cpu_instruction_master_read;
  --ap_cpu/data_master granted epcs_flash_controller_0/epcs_control_port last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ap_cpu_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_ap_cpu_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ap_cpu_data_master_saved_grant_epcs_flash_controller_0_epcs_control_port) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((epcs_flash_controller_0_epcs_control_port_arbitration_holdoff_internal OR NOT internal_ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ap_cpu_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port))))));
    end if;

  end process;

  --ap_cpu_data_master_continuerequest continued request, which is an e_mux
  ap_cpu_data_master_continuerequest <= last_cycle_ap_cpu_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port AND internal_ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port;
  internal_ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port <= internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port AND NOT ((((ap_cpu_instruction_master_read AND to_std_logic((((std_logic_vector'("000000000000000000000000000000") & (ap_cpu_instruction_master_latency_counter)) /= std_logic_vector'("00000000000000000000000000000000")))))) OR ap_cpu_data_master_arbiterlock));
  --local readdatavalid ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port, which is an e_mux
  ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port <= (internal_ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port AND ap_cpu_instruction_master_read) AND NOT epcs_flash_controller_0_epcs_control_port_waits_for_read;
  --allow new arb cycle for epcs_flash_controller_0/epcs_control_port, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_allow_new_arb_cycle <= NOT ap_cpu_data_master_arbiterlock AND NOT ap_cpu_instruction_master_arbiterlock;
  --ap_cpu/instruction_master assignment into master qualified-requests vector for epcs_flash_controller_0/epcs_control_port, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_master_qreq_vector(0) <= internal_ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  --ap_cpu/instruction_master grant epcs_flash_controller_0/epcs_control_port, which is an e_assign
  internal_ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port <= epcs_flash_controller_0_epcs_control_port_grant_vector(0);
  --ap_cpu/instruction_master saved-grant epcs_flash_controller_0/epcs_control_port, which is an e_assign
  ap_cpu_instruction_master_saved_grant_epcs_flash_controller_0_epcs_control_port <= epcs_flash_controller_0_epcs_control_port_arb_winner(0) AND internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;
  --ap_cpu/data_master assignment into master qualified-requests vector for epcs_flash_controller_0/epcs_control_port, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_master_qreq_vector(1) <= internal_ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  --ap_cpu/data_master grant epcs_flash_controller_0/epcs_control_port, which is an e_assign
  internal_ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port <= epcs_flash_controller_0_epcs_control_port_grant_vector(1);
  --ap_cpu/data_master saved-grant epcs_flash_controller_0/epcs_control_port, which is an e_assign
  ap_cpu_data_master_saved_grant_epcs_flash_controller_0_epcs_control_port <= epcs_flash_controller_0_epcs_control_port_arb_winner(1) AND internal_ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port;
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
  epcs_flash_controller_0_epcs_control_port_chipselect <= internal_ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port OR internal_ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port;
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
  epcs_flash_controller_0_epcs_control_port_read_n <= NOT ((((internal_ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port AND ap_cpu_data_master_read)) OR ((internal_ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port AND ap_cpu_instruction_master_read))));
  --~epcs_flash_controller_0_epcs_control_port_write_n assignment, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_write_n <= NOT ((internal_ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port AND ap_cpu_data_master_write));
  shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --epcs_flash_controller_0_epcs_control_port_address mux, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port)) = '1'), (A_SRL(shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (std_logic_vector'("00") & ((A_SRL(shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_ap_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))))), 9);
  shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_ap_cpu_instruction_master <= ap_cpu_instruction_master_address_to_slave;
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
  epcs_flash_controller_0_epcs_control_port_in_a_read_cycle <= ((internal_ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port AND ap_cpu_data_master_read)) OR ((internal_ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port AND ap_cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= epcs_flash_controller_0_epcs_control_port_in_a_read_cycle;
  --epcs_flash_controller_0_epcs_control_port_waits_for_write in a cycle, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_waits_for_write <= epcs_flash_controller_0_epcs_control_port_in_a_write_cycle AND epcs_flash_controller_0_epcs_control_port_begins_xfer;
  --epcs_flash_controller_0_epcs_control_port_in_a_write_cycle assignment, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_in_a_write_cycle <= internal_ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= epcs_flash_controller_0_epcs_control_port_in_a_write_cycle;
  wait_for_epcs_flash_controller_0_epcs_control_port_counter <= std_logic'('0');
  --assign epcs_flash_controller_0_epcs_control_port_irq_from_sa = epcs_flash_controller_0_epcs_control_port_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_irq_from_sa <= epcs_flash_controller_0_epcs_control_port_irq;
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port <= internal_ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port <= internal_ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port <= internal_ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port <= internal_ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port <= internal_ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port <= internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;
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
    VARIABLE write_line9 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line9, now);
          write(write_line9, string'(": "));
          write(write_line9, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line9.all);
          deallocate (write_line9);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line10 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_saved_grant_epcs_flash_controller_0_epcs_control_port))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_saved_grant_epcs_flash_controller_0_epcs_control_port))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line10, now);
          write(write_line10, string'(": "));
          write(write_line10, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line10.all);
          deallocate (write_line10);
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

entity inport_ap_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal inport_ap_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal clock_crossing_0_m1_granted_inport_ap_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_inport_ap_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_inport_ap_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_inport_ap_s1 : OUT STD_LOGIC;
                 signal d1_inport_ap_s1_end_xfer : OUT STD_LOGIC;
                 signal inport_ap_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal inport_ap_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal inport_ap_s1_reset_n : OUT STD_LOGIC
              );
end entity inport_ap_s1_arbitrator;


architecture europa of inport_ap_s1_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_inport_ap_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_inport_ap_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal inport_ap_s1_allgrants :  STD_LOGIC;
                signal inport_ap_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal inport_ap_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal inport_ap_s1_any_continuerequest :  STD_LOGIC;
                signal inport_ap_s1_arb_counter_enable :  STD_LOGIC;
                signal inport_ap_s1_arb_share_counter :  STD_LOGIC;
                signal inport_ap_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal inport_ap_s1_arb_share_set_values :  STD_LOGIC;
                signal inport_ap_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal inport_ap_s1_begins_xfer :  STD_LOGIC;
                signal inport_ap_s1_end_xfer :  STD_LOGIC;
                signal inport_ap_s1_firsttransfer :  STD_LOGIC;
                signal inport_ap_s1_grant_vector :  STD_LOGIC;
                signal inport_ap_s1_in_a_read_cycle :  STD_LOGIC;
                signal inport_ap_s1_in_a_write_cycle :  STD_LOGIC;
                signal inport_ap_s1_master_qreq_vector :  STD_LOGIC;
                signal inport_ap_s1_non_bursting_master_requests :  STD_LOGIC;
                signal inport_ap_s1_reg_firsttransfer :  STD_LOGIC;
                signal inport_ap_s1_slavearbiterlockenable :  STD_LOGIC;
                signal inport_ap_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal inport_ap_s1_unreg_firsttransfer :  STD_LOGIC;
                signal inport_ap_s1_waits_for_read :  STD_LOGIC;
                signal inport_ap_s1_waits_for_write :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_granted_inport_ap_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_inport_ap_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_inport_ap_s1 :  STD_LOGIC;
                signal wait_for_inport_ap_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT inport_ap_s1_end_xfer;
    end if;

  end process;

  inport_ap_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_inport_ap_s1);
  --assign inport_ap_s1_readdata_from_sa = inport_ap_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  inport_ap_s1_readdata_from_sa <= inport_ap_s1_readdata;
  internal_clock_crossing_0_m1_requests_inport_ap_s1 <= ((to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(7 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("10000000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))) AND clock_crossing_0_m1_read;
  --inport_ap_s1_arb_share_counter set values, which is an e_mux
  inport_ap_s1_arb_share_set_values <= std_logic'('1');
  --inport_ap_s1_non_bursting_master_requests mux, which is an e_mux
  inport_ap_s1_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_inport_ap_s1;
  --inport_ap_s1_any_bursting_master_saved_grant mux, which is an e_mux
  inport_ap_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --inport_ap_s1_arb_share_counter_next_value assignment, which is an e_assign
  inport_ap_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(inport_ap_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(inport_ap_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(inport_ap_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(inport_ap_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --inport_ap_s1_allgrants all slave grants, which is an e_mux
  inport_ap_s1_allgrants <= inport_ap_s1_grant_vector;
  --inport_ap_s1_end_xfer assignment, which is an e_assign
  inport_ap_s1_end_xfer <= NOT ((inport_ap_s1_waits_for_read OR inport_ap_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_inport_ap_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_inport_ap_s1 <= inport_ap_s1_end_xfer AND (((NOT inport_ap_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --inport_ap_s1_arb_share_counter arbitration counter enable, which is an e_assign
  inport_ap_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_inport_ap_s1 AND inport_ap_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_inport_ap_s1 AND NOT inport_ap_s1_non_bursting_master_requests));
  --inport_ap_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      inport_ap_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(inport_ap_s1_arb_counter_enable) = '1' then 
        inport_ap_s1_arb_share_counter <= inport_ap_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --inport_ap_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      inport_ap_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((inport_ap_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_inport_ap_s1)) OR ((end_xfer_arb_share_counter_term_inport_ap_s1 AND NOT inport_ap_s1_non_bursting_master_requests)))) = '1' then 
        inport_ap_s1_slavearbiterlockenable <= inport_ap_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 inport_ap/s1 arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= inport_ap_s1_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --inport_ap_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  inport_ap_s1_slavearbiterlockenable2 <= inport_ap_s1_arb_share_counter_next_value;
  --clock_crossing_0/m1 inport_ap/s1 arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= inport_ap_s1_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --inport_ap_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  inport_ap_s1_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_inport_ap_s1 <= internal_clock_crossing_0_m1_requests_inport_ap_s1 AND NOT ((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_inport_ap_s1, which is an e_mux
  clock_crossing_0_m1_read_data_valid_inport_ap_s1 <= (internal_clock_crossing_0_m1_granted_inport_ap_s1 AND clock_crossing_0_m1_read) AND NOT inport_ap_s1_waits_for_read;
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_inport_ap_s1 <= internal_clock_crossing_0_m1_qualified_request_inport_ap_s1;
  --clock_crossing_0/m1 saved-grant inport_ap/s1, which is an e_assign
  clock_crossing_0_m1_saved_grant_inport_ap_s1 <= internal_clock_crossing_0_m1_requests_inport_ap_s1;
  --allow new arb cycle for inport_ap/s1, which is an e_assign
  inport_ap_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  inport_ap_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  inport_ap_s1_master_qreq_vector <= std_logic'('1');
  --inport_ap_s1_reset_n assignment, which is an e_assign
  inport_ap_s1_reset_n <= reset_n;
  --inport_ap_s1_firsttransfer first transaction, which is an e_assign
  inport_ap_s1_firsttransfer <= A_WE_StdLogic((std_logic'(inport_ap_s1_begins_xfer) = '1'), inport_ap_s1_unreg_firsttransfer, inport_ap_s1_reg_firsttransfer);
  --inport_ap_s1_unreg_firsttransfer first transaction, which is an e_assign
  inport_ap_s1_unreg_firsttransfer <= NOT ((inport_ap_s1_slavearbiterlockenable AND inport_ap_s1_any_continuerequest));
  --inport_ap_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      inport_ap_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(inport_ap_s1_begins_xfer) = '1' then 
        inport_ap_s1_reg_firsttransfer <= inport_ap_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --inport_ap_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  inport_ap_s1_beginbursttransfer_internal <= inport_ap_s1_begins_xfer;
  --inport_ap_s1_address mux, which is an e_mux
  inport_ap_s1_address <= clock_crossing_0_m1_nativeaddress (1 DOWNTO 0);
  --d1_inport_ap_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_inport_ap_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_inport_ap_s1_end_xfer <= inport_ap_s1_end_xfer;
    end if;

  end process;

  --inport_ap_s1_waits_for_read in a cycle, which is an e_mux
  inport_ap_s1_waits_for_read <= inport_ap_s1_in_a_read_cycle AND inport_ap_s1_begins_xfer;
  --inport_ap_s1_in_a_read_cycle assignment, which is an e_assign
  inport_ap_s1_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_inport_ap_s1 AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= inport_ap_s1_in_a_read_cycle;
  --inport_ap_s1_waits_for_write in a cycle, which is an e_mux
  inport_ap_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(inport_ap_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --inport_ap_s1_in_a_write_cycle assignment, which is an e_assign
  inport_ap_s1_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_inport_ap_s1 AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= inport_ap_s1_in_a_write_cycle;
  wait_for_inport_ap_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_inport_ap_s1 <= internal_clock_crossing_0_m1_granted_inport_ap_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_inport_ap_s1 <= internal_clock_crossing_0_m1_qualified_request_inport_ap_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_inport_ap_s1 <= internal_clock_crossing_0_m1_requests_inport_ap_s1;
--synthesis translate_off
    --inport_ap/s1 enable non-zero assertions, which is an e_register
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

entity jtag_uart_1_avalon_jtag_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_1_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_irq : IN STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_1_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                 signal d1_jtag_uart_1_avalon_jtag_slave_end_xfer : OUT STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_address : OUT STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_chipselect : OUT STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_irq_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_read_n : OUT STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_reset_n : OUT STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_write_n : OUT STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity jtag_uart_1_avalon_jtag_slave_arbitrator;


architecture europa of jtag_uart_1_avalon_jtag_slave_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal internal_jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_allgrants :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_any_continuerequest :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_arb_counter_enable :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_arb_share_counter :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_arb_share_set_values :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_begins_xfer :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_firsttransfer :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_grant_vector :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_in_a_read_cycle :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_in_a_write_cycle :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_master_qreq_vector :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_non_bursting_master_requests :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_reg_firsttransfer :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_unreg_firsttransfer :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_waits_for_read :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_waits_for_write :  STD_LOGIC;
                signal wait_for_jtag_uart_1_avalon_jtag_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT jtag_uart_1_avalon_jtag_slave_end_xfer;
    end if;

  end process;

  jtag_uart_1_avalon_jtag_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave);
  --assign jtag_uart_1_avalon_jtag_slave_readdata_from_sa = jtag_uart_1_avalon_jtag_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_readdata_from_sa <= jtag_uart_1_avalon_jtag_slave_readdata;
  internal_clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave <= to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(7 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("10100000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write));
  --assign jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_1_avalon_jtag_slave_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa <= jtag_uart_1_avalon_jtag_slave_dataavailable;
  --assign jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_1_avalon_jtag_slave_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa <= jtag_uart_1_avalon_jtag_slave_readyfordata;
  --assign jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_1_avalon_jtag_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa <= jtag_uart_1_avalon_jtag_slave_waitrequest;
  --jtag_uart_1_avalon_jtag_slave_arb_share_counter set values, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_arb_share_set_values <= std_logic'('1');
  --jtag_uart_1_avalon_jtag_slave_non_bursting_master_requests mux, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave;
  --jtag_uart_1_avalon_jtag_slave_any_bursting_master_saved_grant mux, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value assignment, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(jtag_uart_1_avalon_jtag_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(jtag_uart_1_avalon_jtag_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(jtag_uart_1_avalon_jtag_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(jtag_uart_1_avalon_jtag_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --jtag_uart_1_avalon_jtag_slave_allgrants all slave grants, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_allgrants <= jtag_uart_1_avalon_jtag_slave_grant_vector;
  --jtag_uart_1_avalon_jtag_slave_end_xfer assignment, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_end_xfer <= NOT ((jtag_uart_1_avalon_jtag_slave_waits_for_read OR jtag_uart_1_avalon_jtag_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave <= jtag_uart_1_avalon_jtag_slave_end_xfer AND (((NOT jtag_uart_1_avalon_jtag_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --jtag_uart_1_avalon_jtag_slave_arb_share_counter arbitration counter enable, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave AND jtag_uart_1_avalon_jtag_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave AND NOT jtag_uart_1_avalon_jtag_slave_non_bursting_master_requests));
  --jtag_uart_1_avalon_jtag_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_1_avalon_jtag_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(jtag_uart_1_avalon_jtag_slave_arb_counter_enable) = '1' then 
        jtag_uart_1_avalon_jtag_slave_arb_share_counter <= jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((jtag_uart_1_avalon_jtag_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave)) OR ((end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave AND NOT jtag_uart_1_avalon_jtag_slave_non_bursting_master_requests)))) = '1' then 
        jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable <= jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 jtag_uart_1/avalon_jtag_slave arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable2 <= jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value;
  --clock_crossing_0/m1 jtag_uart_1/avalon_jtag_slave arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --jtag_uart_1_avalon_jtag_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave <= internal_clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave AND NOT ((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_jtag_uart_1_avalon_jtag_slave, which is an e_mux
  clock_crossing_0_m1_read_data_valid_jtag_uart_1_avalon_jtag_slave <= (internal_clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave AND clock_crossing_0_m1_read) AND NOT jtag_uart_1_avalon_jtag_slave_waits_for_read;
  --jtag_uart_1_avalon_jtag_slave_writedata mux, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_writedata <= clock_crossing_0_m1_writedata;
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave <= internal_clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave;
  --clock_crossing_0/m1 saved-grant jtag_uart_1/avalon_jtag_slave, which is an e_assign
  clock_crossing_0_m1_saved_grant_jtag_uart_1_avalon_jtag_slave <= internal_clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave;
  --allow new arb cycle for jtag_uart_1/avalon_jtag_slave, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  jtag_uart_1_avalon_jtag_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  jtag_uart_1_avalon_jtag_slave_master_qreq_vector <= std_logic'('1');
  --jtag_uart_1_avalon_jtag_slave_reset_n assignment, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_reset_n <= reset_n;
  jtag_uart_1_avalon_jtag_slave_chipselect <= internal_clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave;
  --jtag_uart_1_avalon_jtag_slave_firsttransfer first transaction, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_firsttransfer <= A_WE_StdLogic((std_logic'(jtag_uart_1_avalon_jtag_slave_begins_xfer) = '1'), jtag_uart_1_avalon_jtag_slave_unreg_firsttransfer, jtag_uart_1_avalon_jtag_slave_reg_firsttransfer);
  --jtag_uart_1_avalon_jtag_slave_unreg_firsttransfer first transaction, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_unreg_firsttransfer <= NOT ((jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable AND jtag_uart_1_avalon_jtag_slave_any_continuerequest));
  --jtag_uart_1_avalon_jtag_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_1_avalon_jtag_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(jtag_uart_1_avalon_jtag_slave_begins_xfer) = '1' then 
        jtag_uart_1_avalon_jtag_slave_reg_firsttransfer <= jtag_uart_1_avalon_jtag_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --jtag_uart_1_avalon_jtag_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_beginbursttransfer_internal <= jtag_uart_1_avalon_jtag_slave_begins_xfer;
  --~jtag_uart_1_avalon_jtag_slave_read_n assignment, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_read_n <= NOT ((internal_clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave AND clock_crossing_0_m1_read));
  --~jtag_uart_1_avalon_jtag_slave_write_n assignment, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_write_n <= NOT ((internal_clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave AND clock_crossing_0_m1_write));
  --jtag_uart_1_avalon_jtag_slave_address mux, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_address <= clock_crossing_0_m1_nativeaddress(0);
  --d1_jtag_uart_1_avalon_jtag_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_jtag_uart_1_avalon_jtag_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_jtag_uart_1_avalon_jtag_slave_end_xfer <= jtag_uart_1_avalon_jtag_slave_end_xfer;
    end if;

  end process;

  --jtag_uart_1_avalon_jtag_slave_waits_for_read in a cycle, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_waits_for_read <= jtag_uart_1_avalon_jtag_slave_in_a_read_cycle AND internal_jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_1_avalon_jtag_slave_in_a_read_cycle assignment, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= jtag_uart_1_avalon_jtag_slave_in_a_read_cycle;
  --jtag_uart_1_avalon_jtag_slave_waits_for_write in a cycle, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_waits_for_write <= jtag_uart_1_avalon_jtag_slave_in_a_write_cycle AND internal_jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_1_avalon_jtag_slave_in_a_write_cycle assignment, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= jtag_uart_1_avalon_jtag_slave_in_a_write_cycle;
  wait_for_jtag_uart_1_avalon_jtag_slave_counter <= std_logic'('0');
  --assign jtag_uart_1_avalon_jtag_slave_irq_from_sa = jtag_uart_1_avalon_jtag_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_irq_from_sa <= jtag_uart_1_avalon_jtag_slave_irq;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave <= internal_clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave <= internal_clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave <= internal_clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave;
  --vhdl renameroo for output signals
  jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa <= internal_jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa;
--synthesis translate_off
    --jtag_uart_1/avalon_jtag_slave enable non-zero assertions, which is an e_register
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
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clock_crossing_0_m1_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_endofpacket : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal clock_crossing_0_m1_granted_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_niosII_openMac_clock_0_in : OUT STD_LOGIC;
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
                 signal niosII_openMac_clock_0_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity niosII_openMac_clock_0_in_arbitrator;


architecture europa of niosII_openMac_clock_0_in_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_granted_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal internal_niosII_openMac_clock_0_in_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_allgrants :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_allow_new_arb_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_any_bursting_master_saved_grant :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_any_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_arb_counter_enable :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_arb_share_counter :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_arb_share_counter_next_value :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_arb_share_set_values :  STD_LOGIC;
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

  niosII_openMac_clock_0_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in);
  --assign niosII_openMac_clock_0_in_readdata_from_sa = niosII_openMac_clock_0_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_0_in_readdata_from_sa <= niosII_openMac_clock_0_in_readdata;
  internal_clock_crossing_0_m1_requests_niosII_openMac_clock_0_in <= to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(7 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("01100000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write));
  --assign niosII_openMac_clock_0_in_waitrequest_from_sa = niosII_openMac_clock_0_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_niosII_openMac_clock_0_in_waitrequest_from_sa <= niosII_openMac_clock_0_in_waitrequest;
  --niosII_openMac_clock_0_in_arb_share_counter set values, which is an e_mux
  niosII_openMac_clock_0_in_arb_share_set_values <= std_logic'('1');
  --niosII_openMac_clock_0_in_non_bursting_master_requests mux, which is an e_mux
  niosII_openMac_clock_0_in_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_niosII_openMac_clock_0_in;
  --niosII_openMac_clock_0_in_any_bursting_master_saved_grant mux, which is an e_mux
  niosII_openMac_clock_0_in_any_bursting_master_saved_grant <= std_logic'('0');
  --niosII_openMac_clock_0_in_arb_share_counter_next_value assignment, which is an e_assign
  niosII_openMac_clock_0_in_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(niosII_openMac_clock_0_in_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(niosII_openMac_clock_0_in_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(niosII_openMac_clock_0_in_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(niosII_openMac_clock_0_in_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
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
      niosII_openMac_clock_0_in_arb_share_counter <= std_logic'('0');
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
        niosII_openMac_clock_0_in_slavearbiterlockenable <= niosII_openMac_clock_0_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 niosII_openMac_clock_0/in arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= niosII_openMac_clock_0_in_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --niosII_openMac_clock_0_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  niosII_openMac_clock_0_in_slavearbiterlockenable2 <= niosII_openMac_clock_0_in_arb_share_counter_next_value;
  --clock_crossing_0/m1 niosII_openMac_clock_0/in arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= niosII_openMac_clock_0_in_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --niosII_openMac_clock_0_in_any_continuerequest at least one master continues requesting, which is an e_assign
  niosII_openMac_clock_0_in_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in <= internal_clock_crossing_0_m1_requests_niosII_openMac_clock_0_in AND NOT ((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_0_in, which is an e_mux
  clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_0_in <= (internal_clock_crossing_0_m1_granted_niosII_openMac_clock_0_in AND clock_crossing_0_m1_read) AND NOT niosII_openMac_clock_0_in_waits_for_read;
  --niosII_openMac_clock_0_in_writedata mux, which is an e_mux
  niosII_openMac_clock_0_in_writedata <= clock_crossing_0_m1_writedata;
  --assign niosII_openMac_clock_0_in_endofpacket_from_sa = niosII_openMac_clock_0_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_0_in_endofpacket_from_sa <= niosII_openMac_clock_0_in_endofpacket;
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_niosII_openMac_clock_0_in <= internal_clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in;
  --clock_crossing_0/m1 saved-grant niosII_openMac_clock_0/in, which is an e_assign
  clock_crossing_0_m1_saved_grant_niosII_openMac_clock_0_in <= internal_clock_crossing_0_m1_requests_niosII_openMac_clock_0_in;
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
  niosII_openMac_clock_0_in_read <= internal_clock_crossing_0_m1_granted_niosII_openMac_clock_0_in AND clock_crossing_0_m1_read;
  --niosII_openMac_clock_0_in_write assignment, which is an e_mux
  niosII_openMac_clock_0_in_write <= internal_clock_crossing_0_m1_granted_niosII_openMac_clock_0_in AND clock_crossing_0_m1_write;
  --niosII_openMac_clock_0_in_address mux, which is an e_mux
  niosII_openMac_clock_0_in_address <= clock_crossing_0_m1_address_to_slave (3 DOWNTO 0);
  --slaveid niosII_openMac_clock_0_in_nativeaddress nativeaddress mux, which is an e_mux
  niosII_openMac_clock_0_in_nativeaddress <= clock_crossing_0_m1_nativeaddress (1 DOWNTO 0);
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
  niosII_openMac_clock_0_in_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_niosII_openMac_clock_0_in AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= niosII_openMac_clock_0_in_in_a_read_cycle;
  --niosII_openMac_clock_0_in_waits_for_write in a cycle, which is an e_mux
  niosII_openMac_clock_0_in_waits_for_write <= niosII_openMac_clock_0_in_in_a_write_cycle AND internal_niosII_openMac_clock_0_in_waitrequest_from_sa;
  --niosII_openMac_clock_0_in_in_a_write_cycle assignment, which is an e_assign
  niosII_openMac_clock_0_in_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_niosII_openMac_clock_0_in AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= niosII_openMac_clock_0_in_in_a_write_cycle;
  wait_for_niosII_openMac_clock_0_in_counter <= std_logic'('0');
  --niosII_openMac_clock_0_in_byteenable byte enable port mux, which is an e_mux
  niosII_openMac_clock_0_in_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_clock_crossing_0_m1_granted_niosII_openMac_clock_0_in)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (clock_crossing_0_m1_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_niosII_openMac_clock_0_in <= internal_clock_crossing_0_m1_granted_niosII_openMac_clock_0_in;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in <= internal_clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_niosII_openMac_clock_0_in <= internal_clock_crossing_0_m1_requests_niosII_openMac_clock_0_in;
  --vhdl renameroo for output signals
  niosII_openMac_clock_0_in_waitrequest_from_sa <= internal_niosII_openMac_clock_0_in_waitrequest_from_sa;
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
    VARIABLE write_line11 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_0_out_address /= niosII_openMac_clock_0_out_address_last_time))))) = '1' then 
          write(write_line11, now);
          write(write_line11, string'(": "));
          write(write_line11, string'("niosII_openMac_clock_0_out_address did not heed wait!!!"));
          write(output, write_line11.all);
          deallocate (write_line11);
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
    VARIABLE write_line12 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_0_out_byteenable /= niosII_openMac_clock_0_out_byteenable_last_time))))) = '1' then 
          write(write_line12, now);
          write(write_line12, string'(": "));
          write(write_line12, string'("niosII_openMac_clock_0_out_byteenable did not heed wait!!!"));
          write(output, write_line12.all);
          deallocate (write_line12);
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
    VARIABLE write_line13 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_0_out_read) /= std_logic'(niosII_openMac_clock_0_out_read_last_time)))))) = '1' then 
          write(write_line13, now);
          write(write_line13, string'(": "));
          write(write_line13, string'("niosII_openMac_clock_0_out_read did not heed wait!!!"));
          write(output, write_line13.all);
          deallocate (write_line13);
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
    VARIABLE write_line14 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_0_out_write) /= std_logic'(niosII_openMac_clock_0_out_write_last_time)))))) = '1' then 
          write(write_line14, now);
          write(write_line14, string'(": "));
          write(write_line14, string'("niosII_openMac_clock_0_out_write did not heed wait!!!"));
          write(output, write_line14.all);
          deallocate (write_line14);
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
    VARIABLE write_line15 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_0_out_writedata /= niosII_openMac_clock_0_out_writedata_last_time)))) AND niosII_openMac_clock_0_out_write)) = '1' then 
          write(write_line15, now);
          write(write_line15, string'(": "));
          write(write_line15, string'("niosII_openMac_clock_0_out_writedata did not heed wait!!!"));
          write(output, write_line15.all);
          deallocate (write_line15);
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
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clock_crossing_0_m1_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_endofpacket : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_in_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal clock_crossing_0_m1_granted_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                 signal d1_niosII_openMac_clock_1_in_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_nativeaddress : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_read : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_write : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity niosII_openMac_clock_1_in_arbitrator;


architecture europa of niosII_openMac_clock_1_in_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_granted_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_in_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_allgrants :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_allow_new_arb_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_any_bursting_master_saved_grant :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_any_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_arb_counter_enable :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_arb_share_counter :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_arb_share_counter_next_value :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_arb_share_set_values :  STD_LOGIC;
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

  niosII_openMac_clock_1_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in);
  --assign niosII_openMac_clock_1_in_readdata_from_sa = niosII_openMac_clock_1_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_1_in_readdata_from_sa <= niosII_openMac_clock_1_in_readdata;
  internal_clock_crossing_0_m1_requests_niosII_openMac_clock_1_in <= to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(7 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("01000000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write));
  --assign niosII_openMac_clock_1_in_waitrequest_from_sa = niosII_openMac_clock_1_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_niosII_openMac_clock_1_in_waitrequest_from_sa <= niosII_openMac_clock_1_in_waitrequest;
  --niosII_openMac_clock_1_in_arb_share_counter set values, which is an e_mux
  niosII_openMac_clock_1_in_arb_share_set_values <= std_logic'('1');
  --niosII_openMac_clock_1_in_non_bursting_master_requests mux, which is an e_mux
  niosII_openMac_clock_1_in_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_niosII_openMac_clock_1_in;
  --niosII_openMac_clock_1_in_any_bursting_master_saved_grant mux, which is an e_mux
  niosII_openMac_clock_1_in_any_bursting_master_saved_grant <= std_logic'('0');
  --niosII_openMac_clock_1_in_arb_share_counter_next_value assignment, which is an e_assign
  niosII_openMac_clock_1_in_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(niosII_openMac_clock_1_in_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(niosII_openMac_clock_1_in_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(niosII_openMac_clock_1_in_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(niosII_openMac_clock_1_in_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
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
      niosII_openMac_clock_1_in_arb_share_counter <= std_logic'('0');
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
        niosII_openMac_clock_1_in_slavearbiterlockenable <= niosII_openMac_clock_1_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 niosII_openMac_clock_1/in arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= niosII_openMac_clock_1_in_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --niosII_openMac_clock_1_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  niosII_openMac_clock_1_in_slavearbiterlockenable2 <= niosII_openMac_clock_1_in_arb_share_counter_next_value;
  --clock_crossing_0/m1 niosII_openMac_clock_1/in arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= niosII_openMac_clock_1_in_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --niosII_openMac_clock_1_in_any_continuerequest at least one master continues requesting, which is an e_assign
  niosII_openMac_clock_1_in_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in <= internal_clock_crossing_0_m1_requests_niosII_openMac_clock_1_in AND NOT ((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_1_in, which is an e_mux
  clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_1_in <= (internal_clock_crossing_0_m1_granted_niosII_openMac_clock_1_in AND clock_crossing_0_m1_read) AND NOT niosII_openMac_clock_1_in_waits_for_read;
  --niosII_openMac_clock_1_in_writedata mux, which is an e_mux
  niosII_openMac_clock_1_in_writedata <= clock_crossing_0_m1_writedata (15 DOWNTO 0);
  --assign niosII_openMac_clock_1_in_endofpacket_from_sa = niosII_openMac_clock_1_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_1_in_endofpacket_from_sa <= niosII_openMac_clock_1_in_endofpacket;
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_niosII_openMac_clock_1_in <= internal_clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in;
  --clock_crossing_0/m1 saved-grant niosII_openMac_clock_1/in, which is an e_assign
  clock_crossing_0_m1_saved_grant_niosII_openMac_clock_1_in <= internal_clock_crossing_0_m1_requests_niosII_openMac_clock_1_in;
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
  niosII_openMac_clock_1_in_read <= internal_clock_crossing_0_m1_granted_niosII_openMac_clock_1_in AND clock_crossing_0_m1_read;
  --niosII_openMac_clock_1_in_write assignment, which is an e_mux
  niosII_openMac_clock_1_in_write <= internal_clock_crossing_0_m1_granted_niosII_openMac_clock_1_in AND clock_crossing_0_m1_write;
  --niosII_openMac_clock_1_in_address mux, which is an e_mux
  niosII_openMac_clock_1_in_address <= clock_crossing_0_m1_address_to_slave (3 DOWNTO 0);
  --slaveid niosII_openMac_clock_1_in_nativeaddress nativeaddress mux, which is an e_mux
  niosII_openMac_clock_1_in_nativeaddress <= clock_crossing_0_m1_nativeaddress (2 DOWNTO 0);
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
  niosII_openMac_clock_1_in_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_niosII_openMac_clock_1_in AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= niosII_openMac_clock_1_in_in_a_read_cycle;
  --niosII_openMac_clock_1_in_waits_for_write in a cycle, which is an e_mux
  niosII_openMac_clock_1_in_waits_for_write <= niosII_openMac_clock_1_in_in_a_write_cycle AND internal_niosII_openMac_clock_1_in_waitrequest_from_sa;
  --niosII_openMac_clock_1_in_in_a_write_cycle assignment, which is an e_assign
  niosII_openMac_clock_1_in_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_niosII_openMac_clock_1_in AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= niosII_openMac_clock_1_in_in_a_write_cycle;
  wait_for_niosII_openMac_clock_1_in_counter <= std_logic'('0');
  --niosII_openMac_clock_1_in_byteenable byte enable port mux, which is an e_mux
  niosII_openMac_clock_1_in_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_clock_crossing_0_m1_granted_niosII_openMac_clock_1_in)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (clock_crossing_0_m1_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 2);
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_niosII_openMac_clock_1_in <= internal_clock_crossing_0_m1_granted_niosII_openMac_clock_1_in;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in <= internal_clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_niosII_openMac_clock_1_in <= internal_clock_crossing_0_m1_requests_niosII_openMac_clock_1_in;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_in_waitrequest_from_sa <= internal_niosII_openMac_clock_1_in_waitrequest_from_sa;
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
                 signal d1_spi_master_spi_control_port_end_xfer : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_granted_spi_master_spi_control_port : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_read_data_valid_spi_master_spi_control_port : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_requests_spi_master_spi_control_port : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal spi_master_spi_control_port_endofpacket_from_sa : IN STD_LOGIC;
                 signal spi_master_spi_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal niosII_openMac_clock_1_out_address_to_slave : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_endofpacket : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_waitrequest : OUT STD_LOGIC
              );
end entity niosII_openMac_clock_1_out_arbitrator;


architecture europa of niosII_openMac_clock_1_out_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_out_address_to_slave :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_niosII_openMac_clock_1_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_address_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_1_out_byteenable_last_time :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_1_out_read_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_run :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_write_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_writedata_last_time :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal r_1 :  STD_LOGIC;

begin

  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001") AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port OR NOT ((niosII_openMac_clock_1_out_read OR niosII_openMac_clock_1_out_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_spi_master_spi_control_port_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_1_out_read OR niosII_openMac_clock_1_out_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port OR NOT ((niosII_openMac_clock_1_out_read OR niosII_openMac_clock_1_out_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_spi_master_spi_control_port_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_1_out_read OR niosII_openMac_clock_1_out_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  niosII_openMac_clock_1_out_run <= r_1;
  --optimize select-logic by passing only those address bits which matter.
  internal_niosII_openMac_clock_1_out_address_to_slave <= niosII_openMac_clock_1_out_address;
  --niosII_openMac_clock_1/out readdata mux, which is an e_mux
  niosII_openMac_clock_1_out_readdata <= spi_master_spi_control_port_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_niosII_openMac_clock_1_out_waitrequest <= NOT niosII_openMac_clock_1_out_run;
  --niosII_openMac_clock_1_out_reset_n assignment, which is an e_assign
  niosII_openMac_clock_1_out_reset_n <= reset_n;
  --mux niosII_openMac_clock_1_out_endofpacket, which is an e_mux
  niosII_openMac_clock_1_out_endofpacket <= spi_master_spi_control_port_endofpacket_from_sa;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_address_to_slave <= internal_niosII_openMac_clock_1_out_address_to_slave;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_waitrequest <= internal_niosII_openMac_clock_1_out_waitrequest;
--synthesis translate_off
    --niosII_openMac_clock_1_out_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_1_out_address_last_time <= std_logic_vector'("0000");
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
    VARIABLE write_line16 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_1_out_address /= niosII_openMac_clock_1_out_address_last_time))))) = '1' then 
          write(write_line16, now);
          write(write_line16, string'(": "));
          write(write_line16, string'("niosII_openMac_clock_1_out_address did not heed wait!!!"));
          write(output, write_line16.all);
          deallocate (write_line16);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_1_out_byteenable check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_1_out_byteenable_last_time <= std_logic_vector'("00");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_1_out_byteenable_last_time <= niosII_openMac_clock_1_out_byteenable;
      end if;

    end process;

    --niosII_openMac_clock_1_out_byteenable matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line17 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_1_out_byteenable /= niosII_openMac_clock_1_out_byteenable_last_time))))) = '1' then 
          write(write_line17, now);
          write(write_line17, string'(": "));
          write(write_line17, string'("niosII_openMac_clock_1_out_byteenable did not heed wait!!!"));
          write(output, write_line17.all);
          deallocate (write_line17);
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
    VARIABLE write_line18 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_1_out_read) /= std_logic'(niosII_openMac_clock_1_out_read_last_time)))))) = '1' then 
          write(write_line18, now);
          write(write_line18, string'(": "));
          write(write_line18, string'("niosII_openMac_clock_1_out_read did not heed wait!!!"));
          write(output, write_line18.all);
          deallocate (write_line18);
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
    VARIABLE write_line19 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_1_out_write) /= std_logic'(niosII_openMac_clock_1_out_write_last_time)))))) = '1' then 
          write(write_line19, now);
          write(write_line19, string'(": "));
          write(write_line19, string'("niosII_openMac_clock_1_out_write did not heed wait!!!"));
          write(output, write_line19.all);
          deallocate (write_line19);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_1_out_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_1_out_writedata_last_time <= std_logic_vector'("0000000000000000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_1_out_writedata_last_time <= niosII_openMac_clock_1_out_writedata;
      end if;

    end process;

    --niosII_openMac_clock_1_out_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line20 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_1_out_writedata /= niosII_openMac_clock_1_out_writedata_last_time)))) AND niosII_openMac_clock_1_out_write)) = '1' then 
          write(write_line20, now);
          write(write_line20, string'(": "));
          write(write_line20, string'("niosII_openMac_clock_1_out_writedata did not heed wait!!!"));
          write(output, write_line20.all);
          deallocate (write_line20);
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

entity onchip_memory_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                 signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal onchip_memory_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_granted_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_onchip_memory_0_s1 : OUT STD_LOGIC;
                 signal d1_onchip_memory_0_s1_end_xfer : OUT STD_LOGIC;
                 signal onchip_memory_0_s1_address : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal onchip_memory_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal onchip_memory_0_s1_chipselect : OUT STD_LOGIC;
                 signal onchip_memory_0_s1_clken : OUT STD_LOGIC;
                 signal onchip_memory_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal onchip_memory_0_s1_write : OUT STD_LOGIC;
                 signal onchip_memory_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal registered_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 : OUT STD_LOGIC
              );
end entity onchip_memory_0_s1_arbitrator;


architecture europa of onchip_memory_0_s1_arbitrator is
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register_in :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_onchip_memory_0_s1 :  STD_LOGIC;
                signal ap_cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register_in :  STD_LOGIC;
                signal ap_cpu_instruction_master_saved_grant_onchip_memory_0_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_onchip_memory_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_onchip_memory_0_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_onchip_memory_0_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_onchip_memory_0_s1 :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_granted_onchip_memory_0_s1 :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1 :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_requests_onchip_memory_0_s1 :  STD_LOGIC;
                signal last_cycle_ap_cpu_data_master_granted_slave_onchip_memory_0_s1 :  STD_LOGIC;
                signal last_cycle_ap_cpu_instruction_master_granted_slave_onchip_memory_0_s1 :  STD_LOGIC;
                signal onchip_memory_0_s1_allgrants :  STD_LOGIC;
                signal onchip_memory_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal onchip_memory_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal onchip_memory_0_s1_any_continuerequest :  STD_LOGIC;
                signal onchip_memory_0_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory_0_s1_arb_counter_enable :  STD_LOGIC;
                signal onchip_memory_0_s1_arb_share_counter :  STD_LOGIC;
                signal onchip_memory_0_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal onchip_memory_0_s1_arb_share_set_values :  STD_LOGIC;
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
                signal p1_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register :  STD_LOGIC;
                signal p1_ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register :  STD_LOGIC;
                signal shifted_address_to_onchip_memory_0_s1_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal shifted_address_to_onchip_memory_0_s1_from_ap_cpu_instruction_master :  STD_LOGIC_VECTOR (22 DOWNTO 0);
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

  onchip_memory_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_ap_cpu_data_master_qualified_request_onchip_memory_0_s1 OR internal_ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1));
  --assign onchip_memory_0_s1_readdata_from_sa = onchip_memory_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  onchip_memory_0_s1_readdata_from_sa <= onchip_memory_0_s1_readdata;
  internal_ap_cpu_data_master_requests_onchip_memory_0_s1 <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(24 DOWNTO 10) & std_logic_vector'("0000000000")) = std_logic_vector'("0000000000001110000000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --registered rdv signal_name registered_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 assignment, which is an e_assign
  registered_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 <= ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register_in;
  --onchip_memory_0_s1_arb_share_counter set values, which is an e_mux
  onchip_memory_0_s1_arb_share_set_values <= std_logic'('1');
  --onchip_memory_0_s1_non_bursting_master_requests mux, which is an e_mux
  onchip_memory_0_s1_non_bursting_master_requests <= ((internal_ap_cpu_data_master_requests_onchip_memory_0_s1 OR internal_ap_cpu_instruction_master_requests_onchip_memory_0_s1) OR internal_ap_cpu_data_master_requests_onchip_memory_0_s1) OR internal_ap_cpu_instruction_master_requests_onchip_memory_0_s1;
  --onchip_memory_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  onchip_memory_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --onchip_memory_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  onchip_memory_0_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(onchip_memory_0_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_memory_0_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(onchip_memory_0_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_memory_0_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
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
      onchip_memory_0_s1_arb_share_counter <= std_logic'('0');
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
        onchip_memory_0_s1_slavearbiterlockenable <= onchip_memory_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ap_cpu/data_master onchip_memory_0/s1 arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= onchip_memory_0_s1_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --onchip_memory_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  onchip_memory_0_s1_slavearbiterlockenable2 <= onchip_memory_0_s1_arb_share_counter_next_value;
  --ap_cpu/data_master onchip_memory_0/s1 arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= onchip_memory_0_s1_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --ap_cpu/instruction_master onchip_memory_0/s1 arbiterlock, which is an e_assign
  ap_cpu_instruction_master_arbiterlock <= onchip_memory_0_s1_slavearbiterlockenable AND ap_cpu_instruction_master_continuerequest;
  --ap_cpu/instruction_master onchip_memory_0/s1 arbiterlock2, which is an e_assign
  ap_cpu_instruction_master_arbiterlock2 <= onchip_memory_0_s1_slavearbiterlockenable2 AND ap_cpu_instruction_master_continuerequest;
  --ap_cpu/instruction_master granted onchip_memory_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ap_cpu_instruction_master_granted_slave_onchip_memory_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_ap_cpu_instruction_master_granted_slave_onchip_memory_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ap_cpu_instruction_master_saved_grant_onchip_memory_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_memory_0_s1_arbitration_holdoff_internal OR NOT internal_ap_cpu_instruction_master_requests_onchip_memory_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ap_cpu_instruction_master_granted_slave_onchip_memory_0_s1))))));
    end if;

  end process;

  --ap_cpu_instruction_master_continuerequest continued request, which is an e_mux
  ap_cpu_instruction_master_continuerequest <= last_cycle_ap_cpu_instruction_master_granted_slave_onchip_memory_0_s1 AND internal_ap_cpu_instruction_master_requests_onchip_memory_0_s1;
  --onchip_memory_0_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  onchip_memory_0_s1_any_continuerequest <= ap_cpu_instruction_master_continuerequest OR ap_cpu_data_master_continuerequest;
  internal_ap_cpu_data_master_qualified_request_onchip_memory_0_s1 <= internal_ap_cpu_data_master_requests_onchip_memory_0_s1 AND NOT (((((ap_cpu_data_master_read AND (ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register))) OR (((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write))) OR ap_cpu_instruction_master_arbiterlock));
  --ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register_in <= ((internal_ap_cpu_data_master_granted_onchip_memory_0_s1 AND ap_cpu_data_master_read) AND NOT onchip_memory_0_s1_waits_for_read) AND NOT (ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register);
  --shift register p1 ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register) & A_ToStdLogicVector(ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register_in)));
  --ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register <= p1_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register;
    end if;

  end process;

  --local readdatavalid ap_cpu_data_master_read_data_valid_onchip_memory_0_s1, which is an e_mux
  ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 <= ap_cpu_data_master_read_data_valid_onchip_memory_0_s1_shift_register;
  --onchip_memory_0_s1_writedata mux, which is an e_mux
  onchip_memory_0_s1_writedata <= ap_cpu_data_master_writedata;
  --mux onchip_memory_0_s1_clken, which is an e_mux
  onchip_memory_0_s1_clken <= std_logic'('1');
  internal_ap_cpu_instruction_master_requests_onchip_memory_0_s1 <= ((to_std_logic(((Std_Logic_Vector'(ap_cpu_instruction_master_address_to_slave(22 DOWNTO 10) & std_logic_vector'("0000000000")) = std_logic_vector'("00000000001110000000000")))) AND (ap_cpu_instruction_master_read))) AND ap_cpu_instruction_master_read;
  --ap_cpu/data_master granted onchip_memory_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ap_cpu_data_master_granted_slave_onchip_memory_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_ap_cpu_data_master_granted_slave_onchip_memory_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ap_cpu_data_master_saved_grant_onchip_memory_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_memory_0_s1_arbitration_holdoff_internal OR NOT internal_ap_cpu_data_master_requests_onchip_memory_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ap_cpu_data_master_granted_slave_onchip_memory_0_s1))))));
    end if;

  end process;

  --ap_cpu_data_master_continuerequest continued request, which is an e_mux
  ap_cpu_data_master_continuerequest <= last_cycle_ap_cpu_data_master_granted_slave_onchip_memory_0_s1 AND internal_ap_cpu_data_master_requests_onchip_memory_0_s1;
  internal_ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1 <= internal_ap_cpu_instruction_master_requests_onchip_memory_0_s1 AND NOT ((((ap_cpu_instruction_master_read AND to_std_logic(((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("000000000000000000000000000000") & (ap_cpu_instruction_master_latency_counter))))))) OR ap_cpu_data_master_arbiterlock));
  --ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register_in <= (internal_ap_cpu_instruction_master_granted_onchip_memory_0_s1 AND ap_cpu_instruction_master_read) AND NOT onchip_memory_0_s1_waits_for_read;
  --shift register p1 ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register) & A_ToStdLogicVector(ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register_in)));
  --ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register <= p1_ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register;
    end if;

  end process;

  --local readdatavalid ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1, which is an e_mux
  ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 <= ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1_shift_register;
  --allow new arb cycle for onchip_memory_0/s1, which is an e_assign
  onchip_memory_0_s1_allow_new_arb_cycle <= NOT ap_cpu_data_master_arbiterlock AND NOT ap_cpu_instruction_master_arbiterlock;
  --ap_cpu/instruction_master assignment into master qualified-requests vector for onchip_memory_0/s1, which is an e_assign
  onchip_memory_0_s1_master_qreq_vector(0) <= internal_ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1;
  --ap_cpu/instruction_master grant onchip_memory_0/s1, which is an e_assign
  internal_ap_cpu_instruction_master_granted_onchip_memory_0_s1 <= onchip_memory_0_s1_grant_vector(0);
  --ap_cpu/instruction_master saved-grant onchip_memory_0/s1, which is an e_assign
  ap_cpu_instruction_master_saved_grant_onchip_memory_0_s1 <= onchip_memory_0_s1_arb_winner(0) AND internal_ap_cpu_instruction_master_requests_onchip_memory_0_s1;
  --ap_cpu/data_master assignment into master qualified-requests vector for onchip_memory_0/s1, which is an e_assign
  onchip_memory_0_s1_master_qreq_vector(1) <= internal_ap_cpu_data_master_qualified_request_onchip_memory_0_s1;
  --ap_cpu/data_master grant onchip_memory_0/s1, which is an e_assign
  internal_ap_cpu_data_master_granted_onchip_memory_0_s1 <= onchip_memory_0_s1_grant_vector(1);
  --ap_cpu/data_master saved-grant onchip_memory_0/s1, which is an e_assign
  ap_cpu_data_master_saved_grant_onchip_memory_0_s1 <= onchip_memory_0_s1_arb_winner(1) AND internal_ap_cpu_data_master_requests_onchip_memory_0_s1;
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

  onchip_memory_0_s1_chipselect <= internal_ap_cpu_data_master_granted_onchip_memory_0_s1 OR internal_ap_cpu_instruction_master_granted_onchip_memory_0_s1;
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
  onchip_memory_0_s1_write <= internal_ap_cpu_data_master_granted_onchip_memory_0_s1 AND ap_cpu_data_master_write;
  shifted_address_to_onchip_memory_0_s1_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --onchip_memory_0_s1_address mux, which is an e_mux
  onchip_memory_0_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_onchip_memory_0_s1)) = '1'), (A_SRL(shifted_address_to_onchip_memory_0_s1_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (std_logic_vector'("00") & ((A_SRL(shifted_address_to_onchip_memory_0_s1_from_ap_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))))), 8);
  shifted_address_to_onchip_memory_0_s1_from_ap_cpu_instruction_master <= ap_cpu_instruction_master_address_to_slave;
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
  onchip_memory_0_s1_in_a_read_cycle <= ((internal_ap_cpu_data_master_granted_onchip_memory_0_s1 AND ap_cpu_data_master_read)) OR ((internal_ap_cpu_instruction_master_granted_onchip_memory_0_s1 AND ap_cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= onchip_memory_0_s1_in_a_read_cycle;
  --onchip_memory_0_s1_waits_for_write in a cycle, which is an e_mux
  onchip_memory_0_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_memory_0_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_memory_0_s1_in_a_write_cycle assignment, which is an e_assign
  onchip_memory_0_s1_in_a_write_cycle <= internal_ap_cpu_data_master_granted_onchip_memory_0_s1 AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= onchip_memory_0_s1_in_a_write_cycle;
  wait_for_onchip_memory_0_s1_counter <= std_logic'('0');
  --onchip_memory_0_s1_byteenable byte enable port mux, which is an e_mux
  onchip_memory_0_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_onchip_memory_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ap_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_onchip_memory_0_s1 <= internal_ap_cpu_data_master_granted_onchip_memory_0_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_onchip_memory_0_s1 <= internal_ap_cpu_data_master_qualified_request_onchip_memory_0_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_onchip_memory_0_s1 <= internal_ap_cpu_data_master_requests_onchip_memory_0_s1;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_granted_onchip_memory_0_s1 <= internal_ap_cpu_instruction_master_granted_onchip_memory_0_s1;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1 <= internal_ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_requests_onchip_memory_0_s1 <= internal_ap_cpu_instruction_master_requests_onchip_memory_0_s1;
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
    VARIABLE write_line21 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ap_cpu_data_master_granted_onchip_memory_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ap_cpu_instruction_master_granted_onchip_memory_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line21, now);
          write(write_line21, string'(": "));
          write(write_line21, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line21.all);
          deallocate (write_line21);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line22 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_saved_grant_onchip_memory_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_saved_grant_onchip_memory_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line22, now);
          write(write_line22, string'(": "));
          write(write_line22, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line22.all);
          deallocate (write_line22);
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

entity outport_ap_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal outport_ap_s1_readdata : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal clock_crossing_0_m1_granted_outport_ap_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_outport_ap_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_outport_ap_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_outport_ap_s1 : OUT STD_LOGIC;
                 signal d1_outport_ap_s1_end_xfer : OUT STD_LOGIC;
                 signal outport_ap_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal outport_ap_s1_chipselect : OUT STD_LOGIC;
                 signal outport_ap_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal outport_ap_s1_reset_n : OUT STD_LOGIC;
                 signal outport_ap_s1_write_n : OUT STD_LOGIC;
                 signal outport_ap_s1_writedata : OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
              );
end entity outport_ap_s1_arbitrator;


architecture europa of outport_ap_s1_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_outport_ap_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_outport_ap_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_granted_outport_ap_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_outport_ap_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_outport_ap_s1 :  STD_LOGIC;
                signal outport_ap_s1_allgrants :  STD_LOGIC;
                signal outport_ap_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal outport_ap_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal outport_ap_s1_any_continuerequest :  STD_LOGIC;
                signal outport_ap_s1_arb_counter_enable :  STD_LOGIC;
                signal outport_ap_s1_arb_share_counter :  STD_LOGIC;
                signal outport_ap_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal outport_ap_s1_arb_share_set_values :  STD_LOGIC;
                signal outport_ap_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal outport_ap_s1_begins_xfer :  STD_LOGIC;
                signal outport_ap_s1_end_xfer :  STD_LOGIC;
                signal outport_ap_s1_firsttransfer :  STD_LOGIC;
                signal outport_ap_s1_grant_vector :  STD_LOGIC;
                signal outport_ap_s1_in_a_read_cycle :  STD_LOGIC;
                signal outport_ap_s1_in_a_write_cycle :  STD_LOGIC;
                signal outport_ap_s1_master_qreq_vector :  STD_LOGIC;
                signal outport_ap_s1_non_bursting_master_requests :  STD_LOGIC;
                signal outport_ap_s1_reg_firsttransfer :  STD_LOGIC;
                signal outport_ap_s1_slavearbiterlockenable :  STD_LOGIC;
                signal outport_ap_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal outport_ap_s1_unreg_firsttransfer :  STD_LOGIC;
                signal outport_ap_s1_waits_for_read :  STD_LOGIC;
                signal outport_ap_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_outport_ap_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT outport_ap_s1_end_xfer;
    end if;

  end process;

  outport_ap_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_outport_ap_s1);
  --assign outport_ap_s1_readdata_from_sa = outport_ap_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  outport_ap_s1_readdata_from_sa <= outport_ap_s1_readdata;
  internal_clock_crossing_0_m1_requests_outport_ap_s1 <= to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(7 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("01110000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write));
  --outport_ap_s1_arb_share_counter set values, which is an e_mux
  outport_ap_s1_arb_share_set_values <= std_logic'('1');
  --outport_ap_s1_non_bursting_master_requests mux, which is an e_mux
  outport_ap_s1_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_outport_ap_s1;
  --outport_ap_s1_any_bursting_master_saved_grant mux, which is an e_mux
  outport_ap_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --outport_ap_s1_arb_share_counter_next_value assignment, which is an e_assign
  outport_ap_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(outport_ap_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(outport_ap_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(outport_ap_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(outport_ap_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --outport_ap_s1_allgrants all slave grants, which is an e_mux
  outport_ap_s1_allgrants <= outport_ap_s1_grant_vector;
  --outport_ap_s1_end_xfer assignment, which is an e_assign
  outport_ap_s1_end_xfer <= NOT ((outport_ap_s1_waits_for_read OR outport_ap_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_outport_ap_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_outport_ap_s1 <= outport_ap_s1_end_xfer AND (((NOT outport_ap_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --outport_ap_s1_arb_share_counter arbitration counter enable, which is an e_assign
  outport_ap_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_outport_ap_s1 AND outport_ap_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_outport_ap_s1 AND NOT outport_ap_s1_non_bursting_master_requests));
  --outport_ap_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      outport_ap_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(outport_ap_s1_arb_counter_enable) = '1' then 
        outport_ap_s1_arb_share_counter <= outport_ap_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --outport_ap_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      outport_ap_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((outport_ap_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_outport_ap_s1)) OR ((end_xfer_arb_share_counter_term_outport_ap_s1 AND NOT outport_ap_s1_non_bursting_master_requests)))) = '1' then 
        outport_ap_s1_slavearbiterlockenable <= outport_ap_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 outport_ap/s1 arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= outport_ap_s1_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --outport_ap_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  outport_ap_s1_slavearbiterlockenable2 <= outport_ap_s1_arb_share_counter_next_value;
  --clock_crossing_0/m1 outport_ap/s1 arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= outport_ap_s1_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --outport_ap_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  outport_ap_s1_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_outport_ap_s1 <= internal_clock_crossing_0_m1_requests_outport_ap_s1 AND NOT ((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_outport_ap_s1, which is an e_mux
  clock_crossing_0_m1_read_data_valid_outport_ap_s1 <= (internal_clock_crossing_0_m1_granted_outport_ap_s1 AND clock_crossing_0_m1_read) AND NOT outport_ap_s1_waits_for_read;
  --outport_ap_s1_writedata mux, which is an e_mux
  outport_ap_s1_writedata <= clock_crossing_0_m1_writedata (23 DOWNTO 0);
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_outport_ap_s1 <= internal_clock_crossing_0_m1_qualified_request_outport_ap_s1;
  --clock_crossing_0/m1 saved-grant outport_ap/s1, which is an e_assign
  clock_crossing_0_m1_saved_grant_outport_ap_s1 <= internal_clock_crossing_0_m1_requests_outport_ap_s1;
  --allow new arb cycle for outport_ap/s1, which is an e_assign
  outport_ap_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  outport_ap_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  outport_ap_s1_master_qreq_vector <= std_logic'('1');
  --outport_ap_s1_reset_n assignment, which is an e_assign
  outport_ap_s1_reset_n <= reset_n;
  outport_ap_s1_chipselect <= internal_clock_crossing_0_m1_granted_outport_ap_s1;
  --outport_ap_s1_firsttransfer first transaction, which is an e_assign
  outport_ap_s1_firsttransfer <= A_WE_StdLogic((std_logic'(outport_ap_s1_begins_xfer) = '1'), outport_ap_s1_unreg_firsttransfer, outport_ap_s1_reg_firsttransfer);
  --outport_ap_s1_unreg_firsttransfer first transaction, which is an e_assign
  outport_ap_s1_unreg_firsttransfer <= NOT ((outport_ap_s1_slavearbiterlockenable AND outport_ap_s1_any_continuerequest));
  --outport_ap_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      outport_ap_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(outport_ap_s1_begins_xfer) = '1' then 
        outport_ap_s1_reg_firsttransfer <= outport_ap_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --outport_ap_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  outport_ap_s1_beginbursttransfer_internal <= outport_ap_s1_begins_xfer;
  --~outport_ap_s1_write_n assignment, which is an e_mux
  outport_ap_s1_write_n <= NOT ((internal_clock_crossing_0_m1_granted_outport_ap_s1 AND clock_crossing_0_m1_write));
  --outport_ap_s1_address mux, which is an e_mux
  outport_ap_s1_address <= clock_crossing_0_m1_nativeaddress (1 DOWNTO 0);
  --d1_outport_ap_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_outport_ap_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_outport_ap_s1_end_xfer <= outport_ap_s1_end_xfer;
    end if;

  end process;

  --outport_ap_s1_waits_for_read in a cycle, which is an e_mux
  outport_ap_s1_waits_for_read <= outport_ap_s1_in_a_read_cycle AND outport_ap_s1_begins_xfer;
  --outport_ap_s1_in_a_read_cycle assignment, which is an e_assign
  outport_ap_s1_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_outport_ap_s1 AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= outport_ap_s1_in_a_read_cycle;
  --outport_ap_s1_waits_for_write in a cycle, which is an e_mux
  outport_ap_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(outport_ap_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --outport_ap_s1_in_a_write_cycle assignment, which is an e_assign
  outport_ap_s1_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_outport_ap_s1 AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= outport_ap_s1_in_a_write_cycle;
  wait_for_outport_ap_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_outport_ap_s1 <= internal_clock_crossing_0_m1_granted_outport_ap_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_outport_ap_s1 <= internal_clock_crossing_0_m1_qualified_request_outport_ap_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_outport_ap_s1 <= internal_clock_crossing_0_m1_requests_outport_ap_s1;
--synthesis translate_off
    --outport_ap/s1 enable non-zero assertions, which is an e_register
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

entity spi_master_spi_control_port_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_address_to_slave : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_nativeaddress : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal spi_master_spi_control_port_dataavailable : IN STD_LOGIC;
                 signal spi_master_spi_control_port_endofpacket : IN STD_LOGIC;
                 signal spi_master_spi_control_port_irq : IN STD_LOGIC;
                 signal spi_master_spi_control_port_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal spi_master_spi_control_port_readyfordata : IN STD_LOGIC;

              -- outputs:
                 signal d1_spi_master_spi_control_port_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_granted_spi_master_spi_control_port : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_read_data_valid_spi_master_spi_control_port : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_requests_spi_master_spi_control_port : OUT STD_LOGIC;
                 signal spi_master_spi_control_port_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal spi_master_spi_control_port_chipselect : OUT STD_LOGIC;
                 signal spi_master_spi_control_port_dataavailable_from_sa : OUT STD_LOGIC;
                 signal spi_master_spi_control_port_endofpacket_from_sa : OUT STD_LOGIC;
                 signal spi_master_spi_control_port_irq_from_sa : OUT STD_LOGIC;
                 signal spi_master_spi_control_port_read_n : OUT STD_LOGIC;
                 signal spi_master_spi_control_port_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal spi_master_spi_control_port_readyfordata_from_sa : OUT STD_LOGIC;
                 signal spi_master_spi_control_port_reset_n : OUT STD_LOGIC;
                 signal spi_master_spi_control_port_write_n : OUT STD_LOGIC;
                 signal spi_master_spi_control_port_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity spi_master_spi_control_port_arbitrator;


architecture europa of spi_master_spi_control_port_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_spi_master_spi_control_port :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_out_granted_spi_master_spi_control_port :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_out_requests_spi_master_spi_control_port :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_arbiterlock :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_arbiterlock2 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_saved_grant_spi_master_spi_control_port :  STD_LOGIC;
                signal spi_master_spi_control_port_allgrants :  STD_LOGIC;
                signal spi_master_spi_control_port_allow_new_arb_cycle :  STD_LOGIC;
                signal spi_master_spi_control_port_any_bursting_master_saved_grant :  STD_LOGIC;
                signal spi_master_spi_control_port_any_continuerequest :  STD_LOGIC;
                signal spi_master_spi_control_port_arb_counter_enable :  STD_LOGIC;
                signal spi_master_spi_control_port_arb_share_counter :  STD_LOGIC;
                signal spi_master_spi_control_port_arb_share_counter_next_value :  STD_LOGIC;
                signal spi_master_spi_control_port_arb_share_set_values :  STD_LOGIC;
                signal spi_master_spi_control_port_beginbursttransfer_internal :  STD_LOGIC;
                signal spi_master_spi_control_port_begins_xfer :  STD_LOGIC;
                signal spi_master_spi_control_port_end_xfer :  STD_LOGIC;
                signal spi_master_spi_control_port_firsttransfer :  STD_LOGIC;
                signal spi_master_spi_control_port_grant_vector :  STD_LOGIC;
                signal spi_master_spi_control_port_in_a_read_cycle :  STD_LOGIC;
                signal spi_master_spi_control_port_in_a_write_cycle :  STD_LOGIC;
                signal spi_master_spi_control_port_master_qreq_vector :  STD_LOGIC;
                signal spi_master_spi_control_port_non_bursting_master_requests :  STD_LOGIC;
                signal spi_master_spi_control_port_reg_firsttransfer :  STD_LOGIC;
                signal spi_master_spi_control_port_slavearbiterlockenable :  STD_LOGIC;
                signal spi_master_spi_control_port_slavearbiterlockenable2 :  STD_LOGIC;
                signal spi_master_spi_control_port_unreg_firsttransfer :  STD_LOGIC;
                signal spi_master_spi_control_port_waits_for_read :  STD_LOGIC;
                signal spi_master_spi_control_port_waits_for_write :  STD_LOGIC;
                signal wait_for_spi_master_spi_control_port_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT spi_master_spi_control_port_end_xfer;
    end if;

  end process;

  spi_master_spi_control_port_begins_xfer <= NOT d1_reasons_to_wait AND (internal_niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port);
  --assign spi_master_spi_control_port_readdata_from_sa = spi_master_spi_control_port_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  spi_master_spi_control_port_readdata_from_sa <= spi_master_spi_control_port_readdata;
  internal_niosII_openMac_clock_1_out_requests_spi_master_spi_control_port <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_1_out_read OR niosII_openMac_clock_1_out_write)))))));
  --assign spi_master_spi_control_port_dataavailable_from_sa = spi_master_spi_control_port_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  spi_master_spi_control_port_dataavailable_from_sa <= spi_master_spi_control_port_dataavailable;
  --assign spi_master_spi_control_port_readyfordata_from_sa = spi_master_spi_control_port_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  spi_master_spi_control_port_readyfordata_from_sa <= spi_master_spi_control_port_readyfordata;
  --spi_master_spi_control_port_arb_share_counter set values, which is an e_mux
  spi_master_spi_control_port_arb_share_set_values <= std_logic'('1');
  --spi_master_spi_control_port_non_bursting_master_requests mux, which is an e_mux
  spi_master_spi_control_port_non_bursting_master_requests <= internal_niosII_openMac_clock_1_out_requests_spi_master_spi_control_port;
  --spi_master_spi_control_port_any_bursting_master_saved_grant mux, which is an e_mux
  spi_master_spi_control_port_any_bursting_master_saved_grant <= std_logic'('0');
  --spi_master_spi_control_port_arb_share_counter_next_value assignment, which is an e_assign
  spi_master_spi_control_port_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(spi_master_spi_control_port_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(spi_master_spi_control_port_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(spi_master_spi_control_port_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(spi_master_spi_control_port_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --spi_master_spi_control_port_allgrants all slave grants, which is an e_mux
  spi_master_spi_control_port_allgrants <= spi_master_spi_control_port_grant_vector;
  --spi_master_spi_control_port_end_xfer assignment, which is an e_assign
  spi_master_spi_control_port_end_xfer <= NOT ((spi_master_spi_control_port_waits_for_read OR spi_master_spi_control_port_waits_for_write));
  --end_xfer_arb_share_counter_term_spi_master_spi_control_port arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_spi_master_spi_control_port <= spi_master_spi_control_port_end_xfer AND (((NOT spi_master_spi_control_port_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --spi_master_spi_control_port_arb_share_counter arbitration counter enable, which is an e_assign
  spi_master_spi_control_port_arb_counter_enable <= ((end_xfer_arb_share_counter_term_spi_master_spi_control_port AND spi_master_spi_control_port_allgrants)) OR ((end_xfer_arb_share_counter_term_spi_master_spi_control_port AND NOT spi_master_spi_control_port_non_bursting_master_requests));
  --spi_master_spi_control_port_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      spi_master_spi_control_port_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(spi_master_spi_control_port_arb_counter_enable) = '1' then 
        spi_master_spi_control_port_arb_share_counter <= spi_master_spi_control_port_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --spi_master_spi_control_port_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      spi_master_spi_control_port_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((spi_master_spi_control_port_master_qreq_vector AND end_xfer_arb_share_counter_term_spi_master_spi_control_port)) OR ((end_xfer_arb_share_counter_term_spi_master_spi_control_port AND NOT spi_master_spi_control_port_non_bursting_master_requests)))) = '1' then 
        spi_master_spi_control_port_slavearbiterlockenable <= spi_master_spi_control_port_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_1/out spi_master/spi_control_port arbiterlock, which is an e_assign
  niosII_openMac_clock_1_out_arbiterlock <= spi_master_spi_control_port_slavearbiterlockenable AND niosII_openMac_clock_1_out_continuerequest;
  --spi_master_spi_control_port_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  spi_master_spi_control_port_slavearbiterlockenable2 <= spi_master_spi_control_port_arb_share_counter_next_value;
  --niosII_openMac_clock_1/out spi_master/spi_control_port arbiterlock2, which is an e_assign
  niosII_openMac_clock_1_out_arbiterlock2 <= spi_master_spi_control_port_slavearbiterlockenable2 AND niosII_openMac_clock_1_out_continuerequest;
  --spi_master_spi_control_port_any_continuerequest at least one master continues requesting, which is an e_assign
  spi_master_spi_control_port_any_continuerequest <= std_logic'('1');
  --niosII_openMac_clock_1_out_continuerequest continued request, which is an e_assign
  niosII_openMac_clock_1_out_continuerequest <= std_logic'('1');
  internal_niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port <= internal_niosII_openMac_clock_1_out_requests_spi_master_spi_control_port;
  --spi_master_spi_control_port_writedata mux, which is an e_mux
  spi_master_spi_control_port_writedata <= niosII_openMac_clock_1_out_writedata;
  --assign spi_master_spi_control_port_endofpacket_from_sa = spi_master_spi_control_port_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  spi_master_spi_control_port_endofpacket_from_sa <= spi_master_spi_control_port_endofpacket;
  --master is always granted when requested
  internal_niosII_openMac_clock_1_out_granted_spi_master_spi_control_port <= internal_niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port;
  --niosII_openMac_clock_1/out saved-grant spi_master/spi_control_port, which is an e_assign
  niosII_openMac_clock_1_out_saved_grant_spi_master_spi_control_port <= internal_niosII_openMac_clock_1_out_requests_spi_master_spi_control_port;
  --allow new arb cycle for spi_master/spi_control_port, which is an e_assign
  spi_master_spi_control_port_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  spi_master_spi_control_port_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  spi_master_spi_control_port_master_qreq_vector <= std_logic'('1');
  --spi_master_spi_control_port_reset_n assignment, which is an e_assign
  spi_master_spi_control_port_reset_n <= reset_n;
  spi_master_spi_control_port_chipselect <= internal_niosII_openMac_clock_1_out_granted_spi_master_spi_control_port;
  --spi_master_spi_control_port_firsttransfer first transaction, which is an e_assign
  spi_master_spi_control_port_firsttransfer <= A_WE_StdLogic((std_logic'(spi_master_spi_control_port_begins_xfer) = '1'), spi_master_spi_control_port_unreg_firsttransfer, spi_master_spi_control_port_reg_firsttransfer);
  --spi_master_spi_control_port_unreg_firsttransfer first transaction, which is an e_assign
  spi_master_spi_control_port_unreg_firsttransfer <= NOT ((spi_master_spi_control_port_slavearbiterlockenable AND spi_master_spi_control_port_any_continuerequest));
  --spi_master_spi_control_port_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      spi_master_spi_control_port_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(spi_master_spi_control_port_begins_xfer) = '1' then 
        spi_master_spi_control_port_reg_firsttransfer <= spi_master_spi_control_port_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --spi_master_spi_control_port_beginbursttransfer_internal begin burst transfer, which is an e_assign
  spi_master_spi_control_port_beginbursttransfer_internal <= spi_master_spi_control_port_begins_xfer;
  --~spi_master_spi_control_port_read_n assignment, which is an e_mux
  spi_master_spi_control_port_read_n <= NOT ((internal_niosII_openMac_clock_1_out_granted_spi_master_spi_control_port AND niosII_openMac_clock_1_out_read));
  --~spi_master_spi_control_port_write_n assignment, which is an e_mux
  spi_master_spi_control_port_write_n <= NOT ((internal_niosII_openMac_clock_1_out_granted_spi_master_spi_control_port AND niosII_openMac_clock_1_out_write));
  --spi_master_spi_control_port_address mux, which is an e_mux
  spi_master_spi_control_port_address <= niosII_openMac_clock_1_out_nativeaddress;
  --d1_spi_master_spi_control_port_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_spi_master_spi_control_port_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_spi_master_spi_control_port_end_xfer <= spi_master_spi_control_port_end_xfer;
    end if;

  end process;

  --spi_master_spi_control_port_waits_for_read in a cycle, which is an e_mux
  spi_master_spi_control_port_waits_for_read <= spi_master_spi_control_port_in_a_read_cycle AND spi_master_spi_control_port_begins_xfer;
  --spi_master_spi_control_port_in_a_read_cycle assignment, which is an e_assign
  spi_master_spi_control_port_in_a_read_cycle <= internal_niosII_openMac_clock_1_out_granted_spi_master_spi_control_port AND niosII_openMac_clock_1_out_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= spi_master_spi_control_port_in_a_read_cycle;
  --spi_master_spi_control_port_waits_for_write in a cycle, which is an e_mux
  spi_master_spi_control_port_waits_for_write <= spi_master_spi_control_port_in_a_write_cycle AND spi_master_spi_control_port_begins_xfer;
  --spi_master_spi_control_port_in_a_write_cycle assignment, which is an e_assign
  spi_master_spi_control_port_in_a_write_cycle <= internal_niosII_openMac_clock_1_out_granted_spi_master_spi_control_port AND niosII_openMac_clock_1_out_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= spi_master_spi_control_port_in_a_write_cycle;
  wait_for_spi_master_spi_control_port_counter <= std_logic'('0');
  --assign spi_master_spi_control_port_irq_from_sa = spi_master_spi_control_port_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  spi_master_spi_control_port_irq_from_sa <= spi_master_spi_control_port_irq;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_granted_spi_master_spi_control_port <= internal_niosII_openMac_clock_1_out_granted_spi_master_spi_control_port;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port <= internal_niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_requests_spi_master_spi_control_port <= internal_niosII_openMac_clock_1_out_requests_spi_master_spi_control_port;
--synthesis translate_off
    --spi_master/spi_control_port enable non-zero assertions, which is an e_register
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
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
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
                signal status_led_pio_s1_arb_share_counter :  STD_LOGIC;
                signal status_led_pio_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal status_led_pio_s1_arb_share_set_values :  STD_LOGIC;
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
  internal_clock_crossing_0_m1_requests_status_led_pio_s1 <= to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(7 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("00000000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write));
  --status_led_pio_s1_arb_share_counter set values, which is an e_mux
  status_led_pio_s1_arb_share_set_values <= std_logic'('1');
  --status_led_pio_s1_non_bursting_master_requests mux, which is an e_mux
  status_led_pio_s1_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_status_led_pio_s1;
  --status_led_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  status_led_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --status_led_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  status_led_pio_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(status_led_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(status_led_pio_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(status_led_pio_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(status_led_pio_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
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
      status_led_pio_s1_arb_share_counter <= std_logic'('0');
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
        status_led_pio_s1_slavearbiterlockenable <= status_led_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 status_led_pio/s1 arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= status_led_pio_s1_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --status_led_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  status_led_pio_s1_slavearbiterlockenable2 <= status_led_pio_s1_arb_share_counter_next_value;
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

entity sync_irq_from_pcp_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal sync_irq_from_pcp_s1_irq : IN STD_LOGIC;
                 signal sync_irq_from_pcp_s1_readdata : IN STD_LOGIC;

              -- outputs:
                 signal clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                 signal d1_sync_irq_from_pcp_s1_end_xfer : OUT STD_LOGIC;
                 signal sync_irq_from_pcp_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal sync_irq_from_pcp_s1_chipselect : OUT STD_LOGIC;
                 signal sync_irq_from_pcp_s1_irq_from_sa : OUT STD_LOGIC;
                 signal sync_irq_from_pcp_s1_readdata_from_sa : OUT STD_LOGIC;
                 signal sync_irq_from_pcp_s1_reset_n : OUT STD_LOGIC;
                 signal sync_irq_from_pcp_s1_write_n : OUT STD_LOGIC;
                 signal sync_irq_from_pcp_s1_writedata : OUT STD_LOGIC
              );
end entity sync_irq_from_pcp_s1_arbitrator;


architecture europa of sync_irq_from_pcp_s1_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_allgrants :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_any_continuerequest :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_arb_counter_enable :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_arb_share_counter :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_arb_share_set_values :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_begins_xfer :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_end_xfer :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_firsttransfer :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_grant_vector :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_in_a_read_cycle :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_in_a_write_cycle :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_master_qreq_vector :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_non_bursting_master_requests :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_reg_firsttransfer :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_slavearbiterlockenable :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_unreg_firsttransfer :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_waits_for_read :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_sync_irq_from_pcp_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT sync_irq_from_pcp_s1_end_xfer;
    end if;

  end process;

  sync_irq_from_pcp_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1);
  --assign sync_irq_from_pcp_s1_readdata_from_sa = sync_irq_from_pcp_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  sync_irq_from_pcp_s1_readdata_from_sa <= sync_irq_from_pcp_s1_readdata;
  internal_clock_crossing_0_m1_requests_sync_irq_from_pcp_s1 <= to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(7 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("10010000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write));
  --sync_irq_from_pcp_s1_arb_share_counter set values, which is an e_mux
  sync_irq_from_pcp_s1_arb_share_set_values <= std_logic'('1');
  --sync_irq_from_pcp_s1_non_bursting_master_requests mux, which is an e_mux
  sync_irq_from_pcp_s1_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_sync_irq_from_pcp_s1;
  --sync_irq_from_pcp_s1_any_bursting_master_saved_grant mux, which is an e_mux
  sync_irq_from_pcp_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --sync_irq_from_pcp_s1_arb_share_counter_next_value assignment, which is an e_assign
  sync_irq_from_pcp_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(sync_irq_from_pcp_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sync_irq_from_pcp_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(sync_irq_from_pcp_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sync_irq_from_pcp_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --sync_irq_from_pcp_s1_allgrants all slave grants, which is an e_mux
  sync_irq_from_pcp_s1_allgrants <= sync_irq_from_pcp_s1_grant_vector;
  --sync_irq_from_pcp_s1_end_xfer assignment, which is an e_assign
  sync_irq_from_pcp_s1_end_xfer <= NOT ((sync_irq_from_pcp_s1_waits_for_read OR sync_irq_from_pcp_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_sync_irq_from_pcp_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_sync_irq_from_pcp_s1 <= sync_irq_from_pcp_s1_end_xfer AND (((NOT sync_irq_from_pcp_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --sync_irq_from_pcp_s1_arb_share_counter arbitration counter enable, which is an e_assign
  sync_irq_from_pcp_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_sync_irq_from_pcp_s1 AND sync_irq_from_pcp_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_sync_irq_from_pcp_s1 AND NOT sync_irq_from_pcp_s1_non_bursting_master_requests));
  --sync_irq_from_pcp_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sync_irq_from_pcp_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(sync_irq_from_pcp_s1_arb_counter_enable) = '1' then 
        sync_irq_from_pcp_s1_arb_share_counter <= sync_irq_from_pcp_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --sync_irq_from_pcp_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sync_irq_from_pcp_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((sync_irq_from_pcp_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_sync_irq_from_pcp_s1)) OR ((end_xfer_arb_share_counter_term_sync_irq_from_pcp_s1 AND NOT sync_irq_from_pcp_s1_non_bursting_master_requests)))) = '1' then 
        sync_irq_from_pcp_s1_slavearbiterlockenable <= sync_irq_from_pcp_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 sync_irq_from_pcp/s1 arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= sync_irq_from_pcp_s1_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --sync_irq_from_pcp_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  sync_irq_from_pcp_s1_slavearbiterlockenable2 <= sync_irq_from_pcp_s1_arb_share_counter_next_value;
  --clock_crossing_0/m1 sync_irq_from_pcp/s1 arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= sync_irq_from_pcp_s1_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --sync_irq_from_pcp_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  sync_irq_from_pcp_s1_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 <= internal_clock_crossing_0_m1_requests_sync_irq_from_pcp_s1 AND NOT ((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_sync_irq_from_pcp_s1, which is an e_mux
  clock_crossing_0_m1_read_data_valid_sync_irq_from_pcp_s1 <= (internal_clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 AND clock_crossing_0_m1_read) AND NOT sync_irq_from_pcp_s1_waits_for_read;
  --sync_irq_from_pcp_s1_writedata mux, which is an e_mux
  sync_irq_from_pcp_s1_writedata <= clock_crossing_0_m1_writedata(0);
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 <= internal_clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1;
  --clock_crossing_0/m1 saved-grant sync_irq_from_pcp/s1, which is an e_assign
  clock_crossing_0_m1_saved_grant_sync_irq_from_pcp_s1 <= internal_clock_crossing_0_m1_requests_sync_irq_from_pcp_s1;
  --allow new arb cycle for sync_irq_from_pcp/s1, which is an e_assign
  sync_irq_from_pcp_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  sync_irq_from_pcp_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  sync_irq_from_pcp_s1_master_qreq_vector <= std_logic'('1');
  --sync_irq_from_pcp_s1_reset_n assignment, which is an e_assign
  sync_irq_from_pcp_s1_reset_n <= reset_n;
  sync_irq_from_pcp_s1_chipselect <= internal_clock_crossing_0_m1_granted_sync_irq_from_pcp_s1;
  --sync_irq_from_pcp_s1_firsttransfer first transaction, which is an e_assign
  sync_irq_from_pcp_s1_firsttransfer <= A_WE_StdLogic((std_logic'(sync_irq_from_pcp_s1_begins_xfer) = '1'), sync_irq_from_pcp_s1_unreg_firsttransfer, sync_irq_from_pcp_s1_reg_firsttransfer);
  --sync_irq_from_pcp_s1_unreg_firsttransfer first transaction, which is an e_assign
  sync_irq_from_pcp_s1_unreg_firsttransfer <= NOT ((sync_irq_from_pcp_s1_slavearbiterlockenable AND sync_irq_from_pcp_s1_any_continuerequest));
  --sync_irq_from_pcp_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sync_irq_from_pcp_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(sync_irq_from_pcp_s1_begins_xfer) = '1' then 
        sync_irq_from_pcp_s1_reg_firsttransfer <= sync_irq_from_pcp_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --sync_irq_from_pcp_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  sync_irq_from_pcp_s1_beginbursttransfer_internal <= sync_irq_from_pcp_s1_begins_xfer;
  --~sync_irq_from_pcp_s1_write_n assignment, which is an e_mux
  sync_irq_from_pcp_s1_write_n <= NOT ((internal_clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 AND clock_crossing_0_m1_write));
  --sync_irq_from_pcp_s1_address mux, which is an e_mux
  sync_irq_from_pcp_s1_address <= clock_crossing_0_m1_nativeaddress (1 DOWNTO 0);
  --d1_sync_irq_from_pcp_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_sync_irq_from_pcp_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_sync_irq_from_pcp_s1_end_xfer <= sync_irq_from_pcp_s1_end_xfer;
    end if;

  end process;

  --sync_irq_from_pcp_s1_waits_for_read in a cycle, which is an e_mux
  sync_irq_from_pcp_s1_waits_for_read <= sync_irq_from_pcp_s1_in_a_read_cycle AND sync_irq_from_pcp_s1_begins_xfer;
  --sync_irq_from_pcp_s1_in_a_read_cycle assignment, which is an e_assign
  sync_irq_from_pcp_s1_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= sync_irq_from_pcp_s1_in_a_read_cycle;
  --sync_irq_from_pcp_s1_waits_for_write in a cycle, which is an e_mux
  sync_irq_from_pcp_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sync_irq_from_pcp_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --sync_irq_from_pcp_s1_in_a_write_cycle assignment, which is an e_assign
  sync_irq_from_pcp_s1_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= sync_irq_from_pcp_s1_in_a_write_cycle;
  wait_for_sync_irq_from_pcp_s1_counter <= std_logic'('0');
  --assign sync_irq_from_pcp_s1_irq_from_sa = sync_irq_from_pcp_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  sync_irq_from_pcp_s1_irq_from_sa <= sync_irq_from_pcp_s1_irq;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 <= internal_clock_crossing_0_m1_granted_sync_irq_from_pcp_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 <= internal_clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_sync_irq_from_pcp_s1 <= internal_clock_crossing_0_m1_requests_sync_irq_from_pcp_s1;
--synthesis translate_off
    --sync_irq_from_pcp/s1 enable non-zero assertions, which is an e_register
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
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- outputs:
                 signal clock_crossing_0_m1_granted_sysid_control_slave : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_sysid_control_slave : OUT STD_LOGIC;
                 signal d1_sysid_control_slave_end_xfer : OUT STD_LOGIC;
                 signal sysid_control_slave_address : OUT STD_LOGIC;
                 signal sysid_control_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal sysid_control_slave_reset_n : OUT STD_LOGIC
              );
end entity sysid_control_slave_arbitrator;


architecture europa of sysid_control_slave_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_sysid_control_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_sysid_control_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_granted_sysid_control_slave :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_sysid_control_slave :  STD_LOGIC;
                signal sysid_control_slave_allgrants :  STD_LOGIC;
                signal sysid_control_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal sysid_control_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal sysid_control_slave_any_continuerequest :  STD_LOGIC;
                signal sysid_control_slave_arb_counter_enable :  STD_LOGIC;
                signal sysid_control_slave_arb_share_counter :  STD_LOGIC;
                signal sysid_control_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal sysid_control_slave_arb_share_set_values :  STD_LOGIC;
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

  sysid_control_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_sysid_control_slave);
  --assign sysid_control_slave_readdata_from_sa = sysid_control_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  sysid_control_slave_readdata_from_sa <= sysid_control_slave_readdata;
  internal_clock_crossing_0_m1_requests_sysid_control_slave <= ((to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(7 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("10101000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write)))) AND clock_crossing_0_m1_read;
  --sysid_control_slave_arb_share_counter set values, which is an e_mux
  sysid_control_slave_arb_share_set_values <= std_logic'('1');
  --sysid_control_slave_non_bursting_master_requests mux, which is an e_mux
  sysid_control_slave_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_sysid_control_slave;
  --sysid_control_slave_any_bursting_master_saved_grant mux, which is an e_mux
  sysid_control_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --sysid_control_slave_arb_share_counter_next_value assignment, which is an e_assign
  sysid_control_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(sysid_control_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sysid_control_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(sysid_control_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sysid_control_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
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
      sysid_control_slave_arb_share_counter <= std_logic'('0');
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
        sysid_control_slave_slavearbiterlockenable <= sysid_control_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 sysid/control_slave arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= sysid_control_slave_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --sysid_control_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  sysid_control_slave_slavearbiterlockenable2 <= sysid_control_slave_arb_share_counter_next_value;
  --clock_crossing_0/m1 sysid/control_slave arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= sysid_control_slave_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --sysid_control_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  sysid_control_slave_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_sysid_control_slave <= internal_clock_crossing_0_m1_requests_sysid_control_slave AND NOT ((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_sysid_control_slave, which is an e_mux
  clock_crossing_0_m1_read_data_valid_sysid_control_slave <= (internal_clock_crossing_0_m1_granted_sysid_control_slave AND clock_crossing_0_m1_read) AND NOT sysid_control_slave_waits_for_read;
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_sysid_control_slave <= internal_clock_crossing_0_m1_qualified_request_sysid_control_slave;
  --clock_crossing_0/m1 saved-grant sysid/control_slave, which is an e_assign
  clock_crossing_0_m1_saved_grant_sysid_control_slave <= internal_clock_crossing_0_m1_requests_sysid_control_slave;
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
  --sysid_control_slave_address mux, which is an e_mux
  sysid_control_slave_address <= clock_crossing_0_m1_nativeaddress(0);
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
  sysid_control_slave_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_sysid_control_slave AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= sysid_control_slave_in_a_read_cycle;
  --sysid_control_slave_waits_for_write in a cycle, which is an e_mux
  sysid_control_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sysid_control_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --sysid_control_slave_in_a_write_cycle assignment, which is an e_assign
  sysid_control_slave_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_sysid_control_slave AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= sysid_control_slave_in_a_write_cycle;
  wait_for_sysid_control_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_sysid_control_slave <= internal_clock_crossing_0_m1_granted_sysid_control_slave;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_sysid_control_slave <= internal_clock_crossing_0_m1_qualified_request_sysid_control_slave;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_sysid_control_slave <= internal_clock_crossing_0_m1_requests_sysid_control_slave;
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

entity system_timer_ap_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                 signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal clock_crossing_0_m1_read : IN STD_LOGIC;
                 signal clock_crossing_0_m1_write : IN STD_LOGIC;
                 signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal system_timer_ap_s1_irq : IN STD_LOGIC;
                 signal system_timer_ap_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal clock_crossing_0_m1_granted_system_timer_ap_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_qualified_request_system_timer_ap_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_read_data_valid_system_timer_ap_s1 : OUT STD_LOGIC;
                 signal clock_crossing_0_m1_requests_system_timer_ap_s1 : OUT STD_LOGIC;
                 signal d1_system_timer_ap_s1_end_xfer : OUT STD_LOGIC;
                 signal system_timer_ap_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal system_timer_ap_s1_chipselect : OUT STD_LOGIC;
                 signal system_timer_ap_s1_irq_from_sa : OUT STD_LOGIC;
                 signal system_timer_ap_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal system_timer_ap_s1_reset_n : OUT STD_LOGIC;
                 signal system_timer_ap_s1_write_n : OUT STD_LOGIC;
                 signal system_timer_ap_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity system_timer_ap_s1_arbitrator;


architecture europa of system_timer_ap_s1_arbitrator is
                signal clock_crossing_0_m1_arbiterlock :  STD_LOGIC;
                signal clock_crossing_0_m1_arbiterlock2 :  STD_LOGIC;
                signal clock_crossing_0_m1_continuerequest :  STD_LOGIC;
                signal clock_crossing_0_m1_saved_grant_system_timer_ap_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_system_timer_ap_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_granted_system_timer_ap_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_qualified_request_system_timer_ap_s1 :  STD_LOGIC;
                signal internal_clock_crossing_0_m1_requests_system_timer_ap_s1 :  STD_LOGIC;
                signal system_timer_ap_s1_allgrants :  STD_LOGIC;
                signal system_timer_ap_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal system_timer_ap_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal system_timer_ap_s1_any_continuerequest :  STD_LOGIC;
                signal system_timer_ap_s1_arb_counter_enable :  STD_LOGIC;
                signal system_timer_ap_s1_arb_share_counter :  STD_LOGIC;
                signal system_timer_ap_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal system_timer_ap_s1_arb_share_set_values :  STD_LOGIC;
                signal system_timer_ap_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal system_timer_ap_s1_begins_xfer :  STD_LOGIC;
                signal system_timer_ap_s1_end_xfer :  STD_LOGIC;
                signal system_timer_ap_s1_firsttransfer :  STD_LOGIC;
                signal system_timer_ap_s1_grant_vector :  STD_LOGIC;
                signal system_timer_ap_s1_in_a_read_cycle :  STD_LOGIC;
                signal system_timer_ap_s1_in_a_write_cycle :  STD_LOGIC;
                signal system_timer_ap_s1_master_qreq_vector :  STD_LOGIC;
                signal system_timer_ap_s1_non_bursting_master_requests :  STD_LOGIC;
                signal system_timer_ap_s1_reg_firsttransfer :  STD_LOGIC;
                signal system_timer_ap_s1_slavearbiterlockenable :  STD_LOGIC;
                signal system_timer_ap_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal system_timer_ap_s1_unreg_firsttransfer :  STD_LOGIC;
                signal system_timer_ap_s1_waits_for_read :  STD_LOGIC;
                signal system_timer_ap_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_system_timer_ap_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT system_timer_ap_s1_end_xfer;
    end if;

  end process;

  system_timer_ap_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_clock_crossing_0_m1_qualified_request_system_timer_ap_s1);
  --assign system_timer_ap_s1_readdata_from_sa = system_timer_ap_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  system_timer_ap_s1_readdata_from_sa <= system_timer_ap_s1_readdata;
  internal_clock_crossing_0_m1_requests_system_timer_ap_s1 <= to_std_logic(((Std_Logic_Vector'(clock_crossing_0_m1_address_to_slave(7 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("00100000")))) AND ((clock_crossing_0_m1_read OR clock_crossing_0_m1_write));
  --system_timer_ap_s1_arb_share_counter set values, which is an e_mux
  system_timer_ap_s1_arb_share_set_values <= std_logic'('1');
  --system_timer_ap_s1_non_bursting_master_requests mux, which is an e_mux
  system_timer_ap_s1_non_bursting_master_requests <= internal_clock_crossing_0_m1_requests_system_timer_ap_s1;
  --system_timer_ap_s1_any_bursting_master_saved_grant mux, which is an e_mux
  system_timer_ap_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --system_timer_ap_s1_arb_share_counter_next_value assignment, which is an e_assign
  system_timer_ap_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(system_timer_ap_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(system_timer_ap_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(system_timer_ap_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(system_timer_ap_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --system_timer_ap_s1_allgrants all slave grants, which is an e_mux
  system_timer_ap_s1_allgrants <= system_timer_ap_s1_grant_vector;
  --system_timer_ap_s1_end_xfer assignment, which is an e_assign
  system_timer_ap_s1_end_xfer <= NOT ((system_timer_ap_s1_waits_for_read OR system_timer_ap_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_system_timer_ap_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_system_timer_ap_s1 <= system_timer_ap_s1_end_xfer AND (((NOT system_timer_ap_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --system_timer_ap_s1_arb_share_counter arbitration counter enable, which is an e_assign
  system_timer_ap_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_system_timer_ap_s1 AND system_timer_ap_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_system_timer_ap_s1 AND NOT system_timer_ap_s1_non_bursting_master_requests));
  --system_timer_ap_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      system_timer_ap_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(system_timer_ap_s1_arb_counter_enable) = '1' then 
        system_timer_ap_s1_arb_share_counter <= system_timer_ap_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --system_timer_ap_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      system_timer_ap_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((system_timer_ap_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_system_timer_ap_s1)) OR ((end_xfer_arb_share_counter_term_system_timer_ap_s1 AND NOT system_timer_ap_s1_non_bursting_master_requests)))) = '1' then 
        system_timer_ap_s1_slavearbiterlockenable <= system_timer_ap_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --clock_crossing_0/m1 system_timer_ap/s1 arbiterlock, which is an e_assign
  clock_crossing_0_m1_arbiterlock <= system_timer_ap_s1_slavearbiterlockenable AND clock_crossing_0_m1_continuerequest;
  --system_timer_ap_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  system_timer_ap_s1_slavearbiterlockenable2 <= system_timer_ap_s1_arb_share_counter_next_value;
  --clock_crossing_0/m1 system_timer_ap/s1 arbiterlock2, which is an e_assign
  clock_crossing_0_m1_arbiterlock2 <= system_timer_ap_s1_slavearbiterlockenable2 AND clock_crossing_0_m1_continuerequest;
  --system_timer_ap_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  system_timer_ap_s1_any_continuerequest <= std_logic'('1');
  --clock_crossing_0_m1_continuerequest continued request, which is an e_assign
  clock_crossing_0_m1_continuerequest <= std_logic'('1');
  internal_clock_crossing_0_m1_qualified_request_system_timer_ap_s1 <= internal_clock_crossing_0_m1_requests_system_timer_ap_s1 AND NOT ((clock_crossing_0_m1_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(clock_crossing_0_m1_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid clock_crossing_0_m1_read_data_valid_system_timer_ap_s1, which is an e_mux
  clock_crossing_0_m1_read_data_valid_system_timer_ap_s1 <= (internal_clock_crossing_0_m1_granted_system_timer_ap_s1 AND clock_crossing_0_m1_read) AND NOT system_timer_ap_s1_waits_for_read;
  --system_timer_ap_s1_writedata mux, which is an e_mux
  system_timer_ap_s1_writedata <= clock_crossing_0_m1_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_clock_crossing_0_m1_granted_system_timer_ap_s1 <= internal_clock_crossing_0_m1_qualified_request_system_timer_ap_s1;
  --clock_crossing_0/m1 saved-grant system_timer_ap/s1, which is an e_assign
  clock_crossing_0_m1_saved_grant_system_timer_ap_s1 <= internal_clock_crossing_0_m1_requests_system_timer_ap_s1;
  --allow new arb cycle for system_timer_ap/s1, which is an e_assign
  system_timer_ap_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  system_timer_ap_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  system_timer_ap_s1_master_qreq_vector <= std_logic'('1');
  --system_timer_ap_s1_reset_n assignment, which is an e_assign
  system_timer_ap_s1_reset_n <= reset_n;
  system_timer_ap_s1_chipselect <= internal_clock_crossing_0_m1_granted_system_timer_ap_s1;
  --system_timer_ap_s1_firsttransfer first transaction, which is an e_assign
  system_timer_ap_s1_firsttransfer <= A_WE_StdLogic((std_logic'(system_timer_ap_s1_begins_xfer) = '1'), system_timer_ap_s1_unreg_firsttransfer, system_timer_ap_s1_reg_firsttransfer);
  --system_timer_ap_s1_unreg_firsttransfer first transaction, which is an e_assign
  system_timer_ap_s1_unreg_firsttransfer <= NOT ((system_timer_ap_s1_slavearbiterlockenable AND system_timer_ap_s1_any_continuerequest));
  --system_timer_ap_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      system_timer_ap_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(system_timer_ap_s1_begins_xfer) = '1' then 
        system_timer_ap_s1_reg_firsttransfer <= system_timer_ap_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --system_timer_ap_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  system_timer_ap_s1_beginbursttransfer_internal <= system_timer_ap_s1_begins_xfer;
  --~system_timer_ap_s1_write_n assignment, which is an e_mux
  system_timer_ap_s1_write_n <= NOT ((internal_clock_crossing_0_m1_granted_system_timer_ap_s1 AND clock_crossing_0_m1_write));
  --system_timer_ap_s1_address mux, which is an e_mux
  system_timer_ap_s1_address <= clock_crossing_0_m1_nativeaddress (2 DOWNTO 0);
  --d1_system_timer_ap_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_system_timer_ap_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_system_timer_ap_s1_end_xfer <= system_timer_ap_s1_end_xfer;
    end if;

  end process;

  --system_timer_ap_s1_waits_for_read in a cycle, which is an e_mux
  system_timer_ap_s1_waits_for_read <= system_timer_ap_s1_in_a_read_cycle AND system_timer_ap_s1_begins_xfer;
  --system_timer_ap_s1_in_a_read_cycle assignment, which is an e_assign
  system_timer_ap_s1_in_a_read_cycle <= internal_clock_crossing_0_m1_granted_system_timer_ap_s1 AND clock_crossing_0_m1_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= system_timer_ap_s1_in_a_read_cycle;
  --system_timer_ap_s1_waits_for_write in a cycle, which is an e_mux
  system_timer_ap_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(system_timer_ap_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --system_timer_ap_s1_in_a_write_cycle assignment, which is an e_assign
  system_timer_ap_s1_in_a_write_cycle <= internal_clock_crossing_0_m1_granted_system_timer_ap_s1 AND clock_crossing_0_m1_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= system_timer_ap_s1_in_a_write_cycle;
  wait_for_system_timer_ap_s1_counter <= std_logic'('0');
  --assign system_timer_ap_s1_irq_from_sa = system_timer_ap_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  system_timer_ap_s1_irq_from_sa <= system_timer_ap_s1_irq;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_granted_system_timer_ap_s1 <= internal_clock_crossing_0_m1_granted_system_timer_ap_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_qualified_request_system_timer_ap_s1 <= internal_clock_crossing_0_m1_qualified_request_system_timer_ap_s1;
  --vhdl renameroo for output signals
  clock_crossing_0_m1_requests_system_timer_ap_s1 <= internal_clock_crossing_0_m1_requests_system_timer_ap_s1;
--synthesis translate_off
    --system_timer_ap/s1 enable non-zero assertions, which is an e_register
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
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                 signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal addr_to_the_SRAM_0 : OUT STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal ben_to_the_SRAM_0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal d1_tri_state_bridge_0_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal incoming_tri_state_bridge_0_data : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ncs_to_the_SRAM_0 : OUT STD_LOGIC;
                 signal rdn_to_the_SRAM_0 : OUT STD_LOGIC;
                 signal registered_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal tri_state_bridge_0_data : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal wrn_to_the_SRAM_0 : OUT STD_LOGIC
              );
end entity tri_state_bridge_0_avalon_slave_arbitrator;


architecture europa of tri_state_bridge_0_avalon_slave_arbitrator is
                signal SRAM_0_avalon_tristate_slave_in_a_read_cycle :  STD_LOGIC;
                signal SRAM_0_avalon_tristate_slave_in_a_write_cycle :  STD_LOGIC;
                signal SRAM_0_avalon_tristate_slave_waits_for_read :  STD_LOGIC;
                signal SRAM_0_avalon_tristate_slave_waits_for_write :  STD_LOGIC;
                signal SRAM_0_avalon_tristate_slave_with_write_latency :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register_in :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal ap_cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register_in :  STD_LOGIC;
                signal ap_cpu_instruction_master_saved_grant_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal d1_in_a_write_cycle :  STD_LOGIC;
                signal d1_outgoing_tri_state_bridge_0_data :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal last_cycle_ap_cpu_data_master_granted_slave_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal last_cycle_ap_cpu_instruction_master_granted_slave_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal outgoing_tri_state_bridge_0_data :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal p1_addr_to_the_SRAM_0 :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal p1_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_ben_to_the_SRAM_0 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal p1_ncs_to_the_SRAM_0 :  STD_LOGIC;
                signal p1_rdn_to_the_SRAM_0 :  STD_LOGIC;
                signal p1_wrn_to_the_SRAM_0 :  STD_LOGIC;
                signal time_to_write :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_allgrants :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_any_continuerequest :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_arb_counter_enable :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_arb_share_counter :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_arb_share_set_values :  STD_LOGIC;
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
                signal wait_for_SRAM_0_avalon_tristate_slave_counter :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of addr_to_the_SRAM_0 : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of ben_to_the_SRAM_0 : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of d1_in_a_write_cycle : signal is "FAST_OUTPUT_ENABLE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of d1_outgoing_tri_state_bridge_0_data : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of incoming_tri_state_bridge_0_data : signal is "FAST_INPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of ncs_to_the_SRAM_0 : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of rdn_to_the_SRAM_0 : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of wrn_to_the_SRAM_0 : signal is "FAST_OUTPUT_REGISTER=ON";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT tri_state_bridge_0_avalon_slave_end_xfer;
    end if;

  end process;

  tri_state_bridge_0_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave OR internal_ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave));
  internal_ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(24 DOWNTO 21) & std_logic_vector'("000000000000000000000")) = std_logic_vector'("0010000000000000000000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --~ncs_to_the_SRAM_0 of type chipselect to ~p1_ncs_to_the_SRAM_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ncs_to_the_SRAM_0 <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      ncs_to_the_SRAM_0 <= p1_ncs_to_the_SRAM_0;
    end if;

  end process;

  tri_state_bridge_0_avalon_slave_write_pending <= std_logic'('0');
  --tri_state_bridge_0/avalon_slave read pending calc, which is an e_assign
  tri_state_bridge_0_avalon_slave_read_pending <= std_logic'('0');
  --registered rdv signal_name registered_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave assignment, which is an e_assign
  registered_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave <= ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register(0);
  --tri_state_bridge_0_avalon_slave_arb_share_counter set values, which is an e_mux
  tri_state_bridge_0_avalon_slave_arb_share_set_values <= std_logic'('1');
  --tri_state_bridge_0_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  tri_state_bridge_0_avalon_slave_non_bursting_master_requests <= ((internal_ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave OR internal_ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave) OR internal_ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave) OR internal_ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave;
  --tri_state_bridge_0_avalon_slave_any_bursting_master_saved_grant mux, which is an e_mux
  tri_state_bridge_0_avalon_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --tri_state_bridge_0_avalon_slave_arb_share_counter_next_value assignment, which is an e_assign
  tri_state_bridge_0_avalon_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(tri_state_bridge_0_avalon_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(tri_state_bridge_0_avalon_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(tri_state_bridge_0_avalon_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(tri_state_bridge_0_avalon_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --tri_state_bridge_0_avalon_slave_allgrants all slave grants, which is an e_mux
  tri_state_bridge_0_avalon_slave_allgrants <= (((or_reduce(tri_state_bridge_0_avalon_slave_grant_vector)) OR (or_reduce(tri_state_bridge_0_avalon_slave_grant_vector))) OR (or_reduce(tri_state_bridge_0_avalon_slave_grant_vector))) OR (or_reduce(tri_state_bridge_0_avalon_slave_grant_vector));
  --tri_state_bridge_0_avalon_slave_end_xfer assignment, which is an e_assign
  tri_state_bridge_0_avalon_slave_end_xfer <= NOT ((SRAM_0_avalon_tristate_slave_waits_for_read OR SRAM_0_avalon_tristate_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave <= tri_state_bridge_0_avalon_slave_end_xfer AND (((NOT tri_state_bridge_0_avalon_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --tri_state_bridge_0_avalon_slave_arb_share_counter arbitration counter enable, which is an e_assign
  tri_state_bridge_0_avalon_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave AND tri_state_bridge_0_avalon_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave AND NOT tri_state_bridge_0_avalon_slave_non_bursting_master_requests));
  --tri_state_bridge_0_avalon_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      tri_state_bridge_0_avalon_slave_arb_share_counter <= std_logic'('0');
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
        tri_state_bridge_0_avalon_slave_slavearbiterlockenable <= tri_state_bridge_0_avalon_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ap_cpu/data_master tri_state_bridge_0/avalon_slave arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= tri_state_bridge_0_avalon_slave_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --tri_state_bridge_0_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  tri_state_bridge_0_avalon_slave_slavearbiterlockenable2 <= tri_state_bridge_0_avalon_slave_arb_share_counter_next_value;
  --ap_cpu/data_master tri_state_bridge_0/avalon_slave arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= tri_state_bridge_0_avalon_slave_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --ap_cpu/instruction_master tri_state_bridge_0/avalon_slave arbiterlock, which is an e_assign
  ap_cpu_instruction_master_arbiterlock <= tri_state_bridge_0_avalon_slave_slavearbiterlockenable AND ap_cpu_instruction_master_continuerequest;
  --ap_cpu/instruction_master tri_state_bridge_0/avalon_slave arbiterlock2, which is an e_assign
  ap_cpu_instruction_master_arbiterlock2 <= tri_state_bridge_0_avalon_slave_slavearbiterlockenable2 AND ap_cpu_instruction_master_continuerequest;
  --ap_cpu/instruction_master granted SRAM_0/avalon_tristate_slave last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ap_cpu_instruction_master_granted_slave_SRAM_0_avalon_tristate_slave <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_ap_cpu_instruction_master_granted_slave_SRAM_0_avalon_tristate_slave <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ap_cpu_instruction_master_saved_grant_SRAM_0_avalon_tristate_slave) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((tri_state_bridge_0_avalon_slave_arbitration_holdoff_internal OR NOT internal_ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ap_cpu_instruction_master_granted_slave_SRAM_0_avalon_tristate_slave))))));
    end if;

  end process;

  --ap_cpu_instruction_master_continuerequest continued request, which is an e_mux
  ap_cpu_instruction_master_continuerequest <= last_cycle_ap_cpu_instruction_master_granted_slave_SRAM_0_avalon_tristate_slave AND internal_ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave;
  --tri_state_bridge_0_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_mux
  tri_state_bridge_0_avalon_slave_any_continuerequest <= ap_cpu_instruction_master_continuerequest OR ap_cpu_data_master_continuerequest;
  internal_ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave <= internal_ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave AND NOT (((((ap_cpu_data_master_read AND (((tri_state_bridge_0_avalon_slave_write_pending OR (tri_state_bridge_0_avalon_slave_read_pending)) OR (or_reduce(ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register)))))) OR (((tri_state_bridge_0_avalon_slave_read_pending) AND ap_cpu_data_master_write))) OR ap_cpu_instruction_master_arbiterlock));
  --ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register_in <= ((internal_ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave AND ap_cpu_data_master_read) AND NOT SRAM_0_avalon_tristate_slave_waits_for_read) AND NOT (or_reduce(ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register));
  --shift register p1 ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register <= A_EXT ((ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register & A_ToStdLogicVector(ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register_in)), 2);
  --ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register <= p1_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register;
    end if;

  end process;

  --local readdatavalid ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave, which is an e_mux
  ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave <= ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register(1);
  --tri_state_bridge_0_data register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      incoming_tri_state_bridge_0_data <= std_logic_vector'("00000000000000000000000000000000");
    elsif clk'event and clk = '1' then
      incoming_tri_state_bridge_0_data <= tri_state_bridge_0_data;
    end if;

  end process;

  --SRAM_0_avalon_tristate_slave_with_write_latency assignment, which is an e_assign
  SRAM_0_avalon_tristate_slave_with_write_latency <= in_a_write_cycle AND ((internal_ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave OR internal_ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave));
  --time to write the data, which is an e_mux
  time_to_write <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((SRAM_0_avalon_tristate_slave_with_write_latency)) = '1'), std_logic_vector'("00000000000000000000000000000001"), std_logic_vector'("00000000000000000000000000000000")));
  --d1_outgoing_tri_state_bridge_0_data register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_outgoing_tri_state_bridge_0_data <= std_logic_vector'("00000000000000000000000000000000");
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
  tri_state_bridge_0_data <= A_WE_StdLogicVector((std_logic'((d1_in_a_write_cycle)) = '1'), d1_outgoing_tri_state_bridge_0_data, A_REP(std_logic'('Z'), 32));
  --outgoing_tri_state_bridge_0_data mux, which is an e_mux
  outgoing_tri_state_bridge_0_data <= ap_cpu_data_master_writedata;
  internal_ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave <= ((to_std_logic(((Std_Logic_Vector'(ap_cpu_instruction_master_address_to_slave(22 DOWNTO 21) & std_logic_vector'("000000000000000000000")) = std_logic_vector'("10000000000000000000000")))) AND (ap_cpu_instruction_master_read))) AND ap_cpu_instruction_master_read;
  --ap_cpu/data_master granted SRAM_0/avalon_tristate_slave last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ap_cpu_data_master_granted_slave_SRAM_0_avalon_tristate_slave <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_ap_cpu_data_master_granted_slave_SRAM_0_avalon_tristate_slave <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ap_cpu_data_master_saved_grant_SRAM_0_avalon_tristate_slave) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((tri_state_bridge_0_avalon_slave_arbitration_holdoff_internal OR NOT internal_ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ap_cpu_data_master_granted_slave_SRAM_0_avalon_tristate_slave))))));
    end if;

  end process;

  --ap_cpu_data_master_continuerequest continued request, which is an e_mux
  ap_cpu_data_master_continuerequest <= last_cycle_ap_cpu_data_master_granted_slave_SRAM_0_avalon_tristate_slave AND internal_ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave;
  internal_ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave <= internal_ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave AND NOT ((((ap_cpu_instruction_master_read AND (((tri_state_bridge_0_avalon_slave_write_pending OR (tri_state_bridge_0_avalon_slave_read_pending)) OR to_std_logic(((std_logic_vector'("00000000000000000000000000000010")<(std_logic_vector'("000000000000000000000000000000") & (ap_cpu_instruction_master_latency_counter))))))))) OR ap_cpu_data_master_arbiterlock));
  --ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register_in <= (internal_ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave AND ap_cpu_instruction_master_read) AND NOT SRAM_0_avalon_tristate_slave_waits_for_read;
  --shift register p1 ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register <= A_EXT ((ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register & A_ToStdLogicVector(ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register_in)), 2);
  --ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register <= p1_ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register;
    end if;

  end process;

  --local readdatavalid ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave, which is an e_mux
  ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave <= ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave_shift_register(1);
  --allow new arb cycle for tri_state_bridge_0/avalon_slave, which is an e_assign
  tri_state_bridge_0_avalon_slave_allow_new_arb_cycle <= NOT ap_cpu_data_master_arbiterlock AND NOT ap_cpu_instruction_master_arbiterlock;
  --ap_cpu/instruction_master assignment into master qualified-requests vector for SRAM_0/avalon_tristate_slave, which is an e_assign
  tri_state_bridge_0_avalon_slave_master_qreq_vector(0) <= internal_ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave;
  --ap_cpu/instruction_master grant SRAM_0/avalon_tristate_slave, which is an e_assign
  internal_ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave <= tri_state_bridge_0_avalon_slave_grant_vector(0);
  --ap_cpu/instruction_master saved-grant SRAM_0/avalon_tristate_slave, which is an e_assign
  ap_cpu_instruction_master_saved_grant_SRAM_0_avalon_tristate_slave <= tri_state_bridge_0_avalon_slave_arb_winner(0) AND internal_ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave;
  --ap_cpu/data_master assignment into master qualified-requests vector for SRAM_0/avalon_tristate_slave, which is an e_assign
  tri_state_bridge_0_avalon_slave_master_qreq_vector(1) <= internal_ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave;
  --ap_cpu/data_master grant SRAM_0/avalon_tristate_slave, which is an e_assign
  internal_ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave <= tri_state_bridge_0_avalon_slave_grant_vector(1);
  --ap_cpu/data_master saved-grant SRAM_0/avalon_tristate_slave, which is an e_assign
  ap_cpu_data_master_saved_grant_SRAM_0_avalon_tristate_slave <= tri_state_bridge_0_avalon_slave_arb_winner(1) AND internal_ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave;
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

  p1_ncs_to_the_SRAM_0 <= NOT ((internal_ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave OR internal_ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave));
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
  --~rdn_to_the_SRAM_0 of type read to ~p1_rdn_to_the_SRAM_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      rdn_to_the_SRAM_0 <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      rdn_to_the_SRAM_0 <= p1_rdn_to_the_SRAM_0;
    end if;

  end process;

  --~p1_rdn_to_the_SRAM_0 assignment, which is an e_mux
  p1_rdn_to_the_SRAM_0 <= NOT ((((internal_ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave AND ap_cpu_data_master_read)) OR ((internal_ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave AND ap_cpu_instruction_master_read))));
  --~wrn_to_the_SRAM_0 of type write to ~p1_wrn_to_the_SRAM_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      wrn_to_the_SRAM_0 <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      wrn_to_the_SRAM_0 <= p1_wrn_to_the_SRAM_0;
    end if;

  end process;

  --~ben_to_the_SRAM_0 of type byteenable to ~p1_ben_to_the_SRAM_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ben_to_the_SRAM_0 <= A_EXT (NOT std_logic_vector'("00000000000000000000000000000000"), 4);
    elsif clk'event and clk = '1' then
      ben_to_the_SRAM_0 <= p1_ben_to_the_SRAM_0;
    end if;

  end process;

  --~p1_wrn_to_the_SRAM_0 assignment, which is an e_mux
  p1_wrn_to_the_SRAM_0 <= NOT ((((internal_ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave AND ap_cpu_data_master_write)) AND (tri_state_bridge_0_avalon_slave_begins_xfer)));
  --addr_to_the_SRAM_0 of type address to p1_addr_to_the_SRAM_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      addr_to_the_SRAM_0 <= std_logic_vector'("000000000000000000000");
    elsif clk'event and clk = '1' then
      addr_to_the_SRAM_0 <= p1_addr_to_the_SRAM_0;
    end if;

  end process;

  --p1_addr_to_the_SRAM_0 mux, which is an e_mux
  p1_addr_to_the_SRAM_0 <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave)) = '1'), ap_cpu_data_master_address_to_slave, (std_logic_vector'("00") & (ap_cpu_instruction_master_address_to_slave))), 21);
  --d1_tri_state_bridge_0_avalon_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_tri_state_bridge_0_avalon_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_tri_state_bridge_0_avalon_slave_end_xfer <= tri_state_bridge_0_avalon_slave_end_xfer;
    end if;

  end process;

  --SRAM_0_avalon_tristate_slave_waits_for_read in a cycle, which is an e_mux
  SRAM_0_avalon_tristate_slave_waits_for_read <= SRAM_0_avalon_tristate_slave_in_a_read_cycle AND tri_state_bridge_0_avalon_slave_begins_xfer;
  --SRAM_0_avalon_tristate_slave_in_a_read_cycle assignment, which is an e_assign
  SRAM_0_avalon_tristate_slave_in_a_read_cycle <= ((internal_ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave AND ap_cpu_data_master_read)) OR ((internal_ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave AND ap_cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= SRAM_0_avalon_tristate_slave_in_a_read_cycle;
  --SRAM_0_avalon_tristate_slave_waits_for_write in a cycle, which is an e_mux
  SRAM_0_avalon_tristate_slave_waits_for_write <= SRAM_0_avalon_tristate_slave_in_a_write_cycle AND tri_state_bridge_0_avalon_slave_begins_xfer;
  --SRAM_0_avalon_tristate_slave_in_a_write_cycle assignment, which is an e_assign
  SRAM_0_avalon_tristate_slave_in_a_write_cycle <= internal_ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= SRAM_0_avalon_tristate_slave_in_a_write_cycle;
  wait_for_SRAM_0_avalon_tristate_slave_counter <= std_logic'('0');
  --~p1_ben_to_the_SRAM_0 byte enable port mux, which is an e_mux
  p1_ben_to_the_SRAM_0 <= A_EXT (NOT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ap_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001")))), 4);
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave <= internal_ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave <= internal_ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave <= internal_ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave <= internal_ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave <= internal_ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave <= internal_ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave;
--synthesis translate_off
    --SRAM_0/avalon_tristate_slave enable non-zero assertions, which is an e_register
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
    VARIABLE write_line23 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line23, now);
          write(write_line23, string'(": "));
          write(write_line23, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line23.all);
          deallocate (write_line23);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line24 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_saved_grant_SRAM_0_avalon_tristate_slave))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_saved_grant_SRAM_0_avalon_tristate_slave))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line24, now);
          write(write_line24, string'(": "));
          write(write_line24, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line24.all);
          deallocate (write_line24);
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

entity niosII_openMac is 
        port (
              -- 1) global signals:
                 signal ap_clk : OUT STD_LOGIC;
                 signal ap_clkSDRAM : OUT STD_LOGIC;
                 signal clk100Meg : OUT STD_LOGIC;
                 signal clk25Meg : OUT STD_LOGIC;
                 signal clk50Meg : OUT STD_LOGIC;
                 signal clk_0 : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- the_altpll_0
                 signal locked_from_the_altpll_0 : OUT STD_LOGIC;
                 signal phasedone_from_the_altpll_0 : OUT STD_LOGIC;

              -- the_epcs_flash_controller_0
                 signal data0_to_the_epcs_flash_controller_0 : IN STD_LOGIC;
                 signal dclk_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;
                 signal sce_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;
                 signal sdo_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;

              -- the_inport_ap
                 signal in_port_to_the_inport_ap : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_outport_ap
                 signal out_port_from_the_outport_ap : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);

              -- the_spi_master
                 signal MISO_to_the_spi_master : IN STD_LOGIC;
                 signal MOSI_from_the_spi_master : OUT STD_LOGIC;
                 signal SCLK_from_the_spi_master : OUT STD_LOGIC;
                 signal SS_n_from_the_spi_master : OUT STD_LOGIC;

              -- the_status_led_pio
                 signal out_port_from_the_status_led_pio : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);

              -- the_sync_irq_from_pcp
                 signal in_port_to_the_sync_irq_from_pcp : IN STD_LOGIC;

              -- the_tri_state_bridge_0_avalon_slave
                 signal addr_to_the_SRAM_0 : OUT STD_LOGIC_VECTOR (20 DOWNTO 0);
                 signal ben_to_the_SRAM_0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ncs_to_the_SRAM_0 : OUT STD_LOGIC;
                 signal rdn_to_the_SRAM_0 : OUT STD_LOGIC;
                 signal tri_state_bridge_0_data : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal wrn_to_the_SRAM_0 : OUT STD_LOGIC
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

component ap_cpu_jtag_debug_module_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_cpu_data_master_debugaccess : IN STD_LOGIC;
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                    signal ap_cpu_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_jtag_debug_module_resetrequest : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal ap_cpu_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal ap_cpu_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                    signal ap_cpu_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_cpu_jtag_debug_module_chipselect : OUT STD_LOGIC;
                    signal ap_cpu_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                    signal ap_cpu_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_jtag_debug_module_reset_n : OUT STD_LOGIC;
                    signal ap_cpu_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                    signal ap_cpu_jtag_debug_module_write : OUT STD_LOGIC;
                    signal ap_cpu_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_ap_cpu_jtag_debug_module_end_xfer : OUT STD_LOGIC
                 );
end component ap_cpu_jtag_debug_module_arbitrator;

component ap_cpu_data_master_arbitrator is 
           port (
                 -- inputs:
                    signal ap_clk : IN STD_LOGIC;
                    signal ap_clk_reset_n : IN STD_LOGIC;
                    signal ap_cpu_data_master_address : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_clock_crossing_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_clock_crossing_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_clock_crossing_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_clock_crossing_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clock_crossing_0_s1_waitrequest_from_sa : IN STD_LOGIC;
                    signal d1_ap_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_clock_crossing_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_memory_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_tri_state_bridge_0_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_irq_from_sa : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal incoming_tri_state_bridge_0_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_1_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                    signal onchip_memory_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal registered_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal registered_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal spi_master_spi_control_port_irq_from_sa : IN STD_LOGIC;
                    signal sync_irq_from_pcp_s1_irq_from_sa : IN STD_LOGIC;
                    signal system_timer_ap_s1_irq_from_sa : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ap_cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_data_master_waitrequest : OUT STD_LOGIC
                 );
end component ap_cpu_data_master_arbitrator;

component ap_cpu_instruction_master_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_instruction_master_address : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_granted_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_onchip_memory_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal d1_ap_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_memory_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_tri_state_bridge_0_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal incoming_tri_state_bridge_0_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal onchip_memory_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal ap_cpu_instruction_master_latency_counter : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ap_cpu_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_instruction_master_readdatavalid : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_waitrequest : OUT STD_LOGIC
                 );
end component ap_cpu_instruction_master_arbitrator;

component ap_cpu is 
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
                    signal i_address : OUT STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal i_read : OUT STD_LOGIC;
                    signal jtag_debug_module_debugaccess_to_roms : OUT STD_LOGIC;
                    signal jtag_debug_module_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_debug_module_resetrequest : OUT STD_LOGIC
                 );
end component ap_cpu;

component clock_crossing_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_s1_endofpacket : IN STD_LOGIC;
                    signal clock_crossing_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clock_crossing_0_s1_readdatavalid : IN STD_LOGIC;
                    signal clock_crossing_0_s1_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_clock_crossing_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_clock_crossing_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_clock_crossing_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_clock_crossing_0_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_s1_address : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal clock_crossing_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal clock_crossing_0_s1_endofpacket_from_sa : OUT STD_LOGIC;
                    signal clock_crossing_0_s1_nativeaddress : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal clock_crossing_0_s1_read : OUT STD_LOGIC;
                    signal clock_crossing_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clock_crossing_0_s1_reset_n : OUT STD_LOGIC;
                    signal clock_crossing_0_s1_waitrequest_from_sa : OUT STD_LOGIC;
                    signal clock_crossing_0_s1_write : OUT STD_LOGIC;
                    signal clock_crossing_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_clock_crossing_0_s1_end_xfer : OUT STD_LOGIC
                 );
end component clock_crossing_0_s1_arbitrator;

component clock_crossing_0_m1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clock_crossing_0_m1_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal clock_crossing_0_m1_granted_inport_ap_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                    signal clock_crossing_0_m1_granted_niosII_openMac_clock_0_in : IN STD_LOGIC;
                    signal clock_crossing_0_m1_granted_niosII_openMac_clock_1_in : IN STD_LOGIC;
                    signal clock_crossing_0_m1_granted_outport_ap_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_granted_status_led_pio_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_granted_sysid_control_slave : IN STD_LOGIC;
                    signal clock_crossing_0_m1_granted_system_timer_ap_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_inport_ap_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_outport_ap_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_status_led_pio_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_sysid_control_slave : IN STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_system_timer_ap_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_inport_ap_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_0_in : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_1_in : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_outport_ap_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_status_led_pio_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_system_timer_ap_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_inport_ap_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_niosII_openMac_clock_0_in : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_niosII_openMac_clock_1_in : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_outport_ap_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_status_led_pio_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_sysid_control_slave : IN STD_LOGIC;
                    signal clock_crossing_0_m1_requests_system_timer_ap_s1 : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_inport_ap_s1_end_xfer : IN STD_LOGIC;
                    signal d1_jtag_uart_1_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                    signal d1_niosII_openMac_clock_0_in_end_xfer : IN STD_LOGIC;
                    signal d1_niosII_openMac_clock_1_in_end_xfer : IN STD_LOGIC;
                    signal d1_outport_ap_s1_end_xfer : IN STD_LOGIC;
                    signal d1_status_led_pio_s1_end_xfer : IN STD_LOGIC;
                    signal d1_sync_irq_from_pcp_s1_end_xfer : IN STD_LOGIC;
                    signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                    signal d1_system_timer_ap_s1_end_xfer : IN STD_LOGIC;
                    signal inport_ap_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal jtag_uart_1_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_in_endofpacket_from_sa : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_in_endofpacket_from_sa : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_in_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal outport_ap_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal status_led_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal sync_irq_from_pcp_s1_readdata_from_sa : IN STD_LOGIC;
                    signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal system_timer_ap_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal clock_crossing_0_m1_address_to_slave : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clock_crossing_0_m1_endofpacket : OUT STD_LOGIC;
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
                    signal slave_address : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
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
                    signal slave_readdatavalid : OUT STD_LOGIC;
                    signal slave_waitrequest : OUT STD_LOGIC
                 );
end component clock_crossing_0;

component clock_crossing_0_bridge_arbitrator is 
end component clock_crossing_0_bridge_arbitrator;

component epcs_flash_controller_0_epcs_control_port_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_dataavailable : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_endofpacket : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_irq : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal epcs_flash_controller_0_epcs_control_port_readyfordata : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port : OUT STD_LOGIC;
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
                    signal epcs_flash_controller_0_epcs_control_port_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
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

component inport_ap_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal inport_ap_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal clock_crossing_0_m1_granted_inport_ap_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_inport_ap_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_inport_ap_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_inport_ap_s1 : OUT STD_LOGIC;
                    signal d1_inport_ap_s1_end_xfer : OUT STD_LOGIC;
                    signal inport_ap_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal inport_ap_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal inport_ap_s1_reset_n : OUT STD_LOGIC
                 );
end component inport_ap_s1_arbitrator;

component inport_ap is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component inport_ap;

component jtag_uart_1_avalon_jtag_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_1_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_irq : IN STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_1_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                    signal d1_jtag_uart_1_avalon_jtag_slave_end_xfer : OUT STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_address : OUT STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_chipselect : OUT STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_irq_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_read_n : OUT STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_reset_n : OUT STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_write_n : OUT STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component jtag_uart_1_avalon_jtag_slave_arbitrator;

component jtag_uart_1 is 
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
end component jtag_uart_1;

component niosII_openMac_clock_0_in_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clock_crossing_0_m1_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_endofpacket : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal clock_crossing_0_m1_granted_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_niosII_openMac_clock_0_in : OUT STD_LOGIC;
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
                    signal niosII_openMac_clock_0_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
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
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clock_crossing_0_m1_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_endofpacket : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_in_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal clock_crossing_0_m1_granted_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                    signal d1_niosII_openMac_clock_1_in_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_nativeaddress : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_read : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_write : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component niosII_openMac_clock_1_in_arbitrator;

component niosII_openMac_clock_1_out_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d1_spi_master_spi_control_port_end_xfer : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_granted_spi_master_spi_control_port : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_read_data_valid_spi_master_spi_control_port : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_requests_spi_master_spi_control_port : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal spi_master_spi_control_port_endofpacket_from_sa : IN STD_LOGIC;
                    signal spi_master_spi_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal niosII_openMac_clock_1_out_address_to_slave : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_endofpacket : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_waitrequest : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_1_out_arbitrator;

component niosII_openMac_clock_1 is 
           port (
                 -- inputs:
                    signal master_clk : IN STD_LOGIC;
                    signal master_endofpacket : IN STD_LOGIC;
                    signal master_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal master_reset_n : IN STD_LOGIC;
                    signal master_waitrequest : IN STD_LOGIC;
                    signal slave_address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal slave_byteenable : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_nativeaddress : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;
                    signal slave_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal master_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal master_byteenable : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal master_nativeaddress : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal master_read : OUT STD_LOGIC;
                    signal master_write : OUT STD_LOGIC;
                    signal master_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal slave_endofpacket : OUT STD_LOGIC;
                    signal slave_readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal slave_waitrequest : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_1;

component onchip_memory_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal onchip_memory_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_granted_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_onchip_memory_0_s1 : OUT STD_LOGIC;
                    signal d1_onchip_memory_0_s1_end_xfer : OUT STD_LOGIC;
                    signal onchip_memory_0_s1_address : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal onchip_memory_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal onchip_memory_0_s1_chipselect : OUT STD_LOGIC;
                    signal onchip_memory_0_s1_clken : OUT STD_LOGIC;
                    signal onchip_memory_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal onchip_memory_0_s1_write : OUT STD_LOGIC;
                    signal onchip_memory_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal registered_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 : OUT STD_LOGIC
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

component outport_ap_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal outport_ap_s1_readdata : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal clock_crossing_0_m1_granted_outport_ap_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_outport_ap_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_outport_ap_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_outport_ap_s1 : OUT STD_LOGIC;
                    signal d1_outport_ap_s1_end_xfer : OUT STD_LOGIC;
                    signal outport_ap_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal outport_ap_s1_chipselect : OUT STD_LOGIC;
                    signal outport_ap_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal outport_ap_s1_reset_n : OUT STD_LOGIC;
                    signal outport_ap_s1_write_n : OUT STD_LOGIC;
                    signal outport_ap_s1_writedata : OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
                 );
end component outport_ap_s1_arbitrator;

component outport_ap is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (23 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
                 );
end component outport_ap;

component spi_master_spi_control_port_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_address_to_slave : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_nativeaddress : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal spi_master_spi_control_port_dataavailable : IN STD_LOGIC;
                    signal spi_master_spi_control_port_endofpacket : IN STD_LOGIC;
                    signal spi_master_spi_control_port_irq : IN STD_LOGIC;
                    signal spi_master_spi_control_port_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal spi_master_spi_control_port_readyfordata : IN STD_LOGIC;

                 -- outputs:
                    signal d1_spi_master_spi_control_port_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_granted_spi_master_spi_control_port : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_read_data_valid_spi_master_spi_control_port : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_requests_spi_master_spi_control_port : OUT STD_LOGIC;
                    signal spi_master_spi_control_port_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal spi_master_spi_control_port_chipselect : OUT STD_LOGIC;
                    signal spi_master_spi_control_port_dataavailable_from_sa : OUT STD_LOGIC;
                    signal spi_master_spi_control_port_endofpacket_from_sa : OUT STD_LOGIC;
                    signal spi_master_spi_control_port_irq_from_sa : OUT STD_LOGIC;
                    signal spi_master_spi_control_port_read_n : OUT STD_LOGIC;
                    signal spi_master_spi_control_port_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal spi_master_spi_control_port_readyfordata_from_sa : OUT STD_LOGIC;
                    signal spi_master_spi_control_port_reset_n : OUT STD_LOGIC;
                    signal spi_master_spi_control_port_write_n : OUT STD_LOGIC;
                    signal spi_master_spi_control_port_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component spi_master_spi_control_port_arbitrator;

component spi_master is 
           port (
                 -- inputs:
                    signal MISO : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal data_from_cpu : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal mem_addr : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal read_n : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal spi_select : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;

                 -- outputs:
                    signal MOSI : OUT STD_LOGIC;
                    signal SCLK : OUT STD_LOGIC;
                    signal SS_n : OUT STD_LOGIC;
                    signal data_to_cpu : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal dataavailable : OUT STD_LOGIC;
                    signal endofpacket : OUT STD_LOGIC;
                    signal irq : OUT STD_LOGIC;
                    signal readyfordata : OUT STD_LOGIC
                 );
end component spi_master;

component status_led_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
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

component sync_irq_from_pcp_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal sync_irq_from_pcp_s1_irq : IN STD_LOGIC;
                    signal sync_irq_from_pcp_s1_readdata : IN STD_LOGIC;

                 -- outputs:
                    signal clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                    signal d1_sync_irq_from_pcp_s1_end_xfer : OUT STD_LOGIC;
                    signal sync_irq_from_pcp_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal sync_irq_from_pcp_s1_chipselect : OUT STD_LOGIC;
                    signal sync_irq_from_pcp_s1_irq_from_sa : OUT STD_LOGIC;
                    signal sync_irq_from_pcp_s1_readdata_from_sa : OUT STD_LOGIC;
                    signal sync_irq_from_pcp_s1_reset_n : OUT STD_LOGIC;
                    signal sync_irq_from_pcp_s1_write_n : OUT STD_LOGIC;
                    signal sync_irq_from_pcp_s1_writedata : OUT STD_LOGIC
                 );
end component sync_irq_from_pcp_s1_arbitrator;

component sync_irq_from_pcp is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC;

                 -- outputs:
                    signal irq : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC
                 );
end component sync_irq_from_pcp;

component sysid_control_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal clock_crossing_0_m1_granted_sysid_control_slave : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_sysid_control_slave : OUT STD_LOGIC;
                    signal d1_sysid_control_slave_end_xfer : OUT STD_LOGIC;
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

component system_timer_ap_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal clock_crossing_0_m1_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clock_crossing_0_m1_latency_counter : IN STD_LOGIC;
                    signal clock_crossing_0_m1_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal clock_crossing_0_m1_read : IN STD_LOGIC;
                    signal clock_crossing_0_m1_write : IN STD_LOGIC;
                    signal clock_crossing_0_m1_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal system_timer_ap_s1_irq : IN STD_LOGIC;
                    signal system_timer_ap_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal clock_crossing_0_m1_granted_system_timer_ap_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_qualified_request_system_timer_ap_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_read_data_valid_system_timer_ap_s1 : OUT STD_LOGIC;
                    signal clock_crossing_0_m1_requests_system_timer_ap_s1 : OUT STD_LOGIC;
                    signal d1_system_timer_ap_s1_end_xfer : OUT STD_LOGIC;
                    signal system_timer_ap_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal system_timer_ap_s1_chipselect : OUT STD_LOGIC;
                    signal system_timer_ap_s1_irq_from_sa : OUT STD_LOGIC;
                    signal system_timer_ap_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal system_timer_ap_s1_reset_n : OUT STD_LOGIC;
                    signal system_timer_ap_s1_write_n : OUT STD_LOGIC;
                    signal system_timer_ap_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component system_timer_ap_s1_arbitrator;

component system_timer_ap is 
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
end component system_timer_ap;

component tri_state_bridge_0_avalon_slave_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (22 DOWNTO 0);
                    signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal addr_to_the_SRAM_0 : OUT STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal ben_to_the_SRAM_0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal d1_tri_state_bridge_0_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal incoming_tri_state_bridge_0_data : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ncs_to_the_SRAM_0 : OUT STD_LOGIC;
                    signal rdn_to_the_SRAM_0 : OUT STD_LOGIC;
                    signal registered_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal tri_state_bridge_0_data : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal wrn_to_the_SRAM_0 : OUT STD_LOGIC
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

                signal altpll_0_pll_slave_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altpll_0_pll_slave_read :  STD_LOGIC;
                signal altpll_0_pll_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal altpll_0_pll_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal altpll_0_pll_slave_reset :  STD_LOGIC;
                signal altpll_0_pll_slave_write :  STD_LOGIC;
                signal altpll_0_pll_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ap_clk_reset_n :  STD_LOGIC;
                signal ap_cpu_data_master_address :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal ap_cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal ap_cpu_data_master_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ap_cpu_data_master_debugaccess :  STD_LOGIC;
                signal ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal ap_cpu_data_master_granted_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_data_master_granted_clock_crossing_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_data_master_granted_onchip_memory_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_irq :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_clock_crossing_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_onchip_memory_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_read :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_clock_crossing_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal ap_cpu_data_master_requests_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_data_master_requests_clock_crossing_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_data_master_requests_onchip_memory_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_waitrequest :  STD_LOGIC;
                signal ap_cpu_data_master_write :  STD_LOGIC;
                signal ap_cpu_data_master_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ap_cpu_instruction_master_address :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal ap_cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (22 DOWNTO 0);
                signal ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_instruction_master_granted_onchip_memory_0_s1 :  STD_LOGIC;
                signal ap_cpu_instruction_master_latency_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1 :  STD_LOGIC;
                signal ap_cpu_instruction_master_read :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 :  STD_LOGIC;
                signal ap_cpu_instruction_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ap_cpu_instruction_master_readdatavalid :  STD_LOGIC;
                signal ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_instruction_master_requests_onchip_memory_0_s1 :  STD_LOGIC;
                signal ap_cpu_instruction_master_waitrequest :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_address :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal ap_cpu_jtag_debug_module_begintransfer :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ap_cpu_jtag_debug_module_chipselect :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_debugaccess :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ap_cpu_jtag_debug_module_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ap_cpu_jtag_debug_module_reset_n :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_resetrequest :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_resetrequest_from_sa :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_write :  STD_LOGIC;
                signal ap_cpu_jtag_debug_module_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal clk50Meg_reset_n :  STD_LOGIC;
                signal clk_0_reset_n :  STD_LOGIC;
                signal clock_crossing_0_m1_address :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal clock_crossing_0_m1_address_to_slave :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal clock_crossing_0_m1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal clock_crossing_0_m1_endofpacket :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_inport_ap_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_outport_ap_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_status_led_pio_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_sysid_control_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_granted_system_timer_ap_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_latency_counter :  STD_LOGIC;
                signal clock_crossing_0_m1_nativeaddress :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal clock_crossing_0_m1_qualified_request_inport_ap_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal clock_crossing_0_m1_qualified_request_outport_ap_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_qualified_request_status_led_pio_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_qualified_request_system_timer_ap_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_read :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_inport_ap_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_outport_ap_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_status_led_pio_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_sysid_control_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_read_data_valid_system_timer_ap_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal clock_crossing_0_m1_readdatavalid :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_inport_ap_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_outport_ap_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_status_led_pio_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_sysid_control_slave :  STD_LOGIC;
                signal clock_crossing_0_m1_requests_system_timer_ap_s1 :  STD_LOGIC;
                signal clock_crossing_0_m1_reset_n :  STD_LOGIC;
                signal clock_crossing_0_m1_waitrequest :  STD_LOGIC;
                signal clock_crossing_0_m1_write :  STD_LOGIC;
                signal clock_crossing_0_m1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal clock_crossing_0_s1_address :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal clock_crossing_0_s1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal clock_crossing_0_s1_endofpacket :  STD_LOGIC;
                signal clock_crossing_0_s1_endofpacket_from_sa :  STD_LOGIC;
                signal clock_crossing_0_s1_nativeaddress :  STD_LOGIC_VECTOR (5 DOWNTO 0);
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
                signal d1_ap_cpu_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal d1_clock_crossing_0_s1_end_xfer :  STD_LOGIC;
                signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer :  STD_LOGIC;
                signal d1_inport_ap_s1_end_xfer :  STD_LOGIC;
                signal d1_jtag_uart_1_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal d1_niosII_openMac_clock_0_in_end_xfer :  STD_LOGIC;
                signal d1_niosII_openMac_clock_1_in_end_xfer :  STD_LOGIC;
                signal d1_onchip_memory_0_s1_end_xfer :  STD_LOGIC;
                signal d1_outport_ap_s1_end_xfer :  STD_LOGIC;
                signal d1_spi_master_spi_control_port_end_xfer :  STD_LOGIC;
                signal d1_status_led_pio_s1_end_xfer :  STD_LOGIC;
                signal d1_sync_irq_from_pcp_s1_end_xfer :  STD_LOGIC;
                signal d1_sysid_control_slave_end_xfer :  STD_LOGIC;
                signal d1_system_timer_ap_s1_end_xfer :  STD_LOGIC;
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
                signal incoming_tri_state_bridge_0_data :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal inport_ap_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal inport_ap_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal inport_ap_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal inport_ap_s1_reset_n :  STD_LOGIC;
                signal internal_MOSI_from_the_spi_master :  STD_LOGIC;
                signal internal_SCLK_from_the_spi_master :  STD_LOGIC;
                signal internal_SS_n_from_the_spi_master :  STD_LOGIC;
                signal internal_addr_to_the_SRAM_0 :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal internal_ap_clk :  STD_LOGIC;
                signal internal_ben_to_the_SRAM_0 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_clk50Meg :  STD_LOGIC;
                signal internal_dclk_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal internal_locked_from_the_altpll_0 :  STD_LOGIC;
                signal internal_ncs_to_the_SRAM_0 :  STD_LOGIC;
                signal internal_out_port_from_the_outport_ap :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal internal_out_port_from_the_status_led_pio :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_phasedone_from_the_altpll_0 :  STD_LOGIC;
                signal internal_rdn_to_the_SRAM_0 :  STD_LOGIC;
                signal internal_sce_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal internal_sdo_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal internal_wrn_to_the_SRAM_0 :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_address :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_chipselect :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_dataavailable :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_irq :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_irq_from_sa :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_read_n :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_1_avalon_jtag_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_1_avalon_jtag_slave_readyfordata :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_reset_n :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_waitrequest :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_write_n :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal module_input3 :  STD_LOGIC;
                signal module_input4 :  STD_LOGIC;
                signal module_input5 :  STD_LOGIC;
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
                signal niosII_openMac_clock_1_in_address :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_1_in_byteenable :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_1_in_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_nativeaddress :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal niosII_openMac_clock_1_in_read :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal niosII_openMac_clock_1_in_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal niosII_openMac_clock_1_in_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_write :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal niosII_openMac_clock_1_out_address :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_1_out_address_to_slave :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_1_out_byteenable :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_1_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_granted_spi_master_spi_control_port :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_nativeaddress :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_read :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_read_data_valid_spi_master_spi_control_port :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal niosII_openMac_clock_1_out_requests_spi_master_spi_control_port :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_write :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
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
                signal outport_ap_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal outport_ap_s1_chipselect :  STD_LOGIC;
                signal outport_ap_s1_readdata :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal outport_ap_s1_readdata_from_sa :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal outport_ap_s1_reset_n :  STD_LOGIC;
                signal outport_ap_s1_write_n :  STD_LOGIC;
                signal outport_ap_s1_writedata :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal registered_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave :  STD_LOGIC;
                signal registered_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 :  STD_LOGIC;
                signal reset_n_sources :  STD_LOGIC;
                signal spi_master_spi_control_port_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal spi_master_spi_control_port_chipselect :  STD_LOGIC;
                signal spi_master_spi_control_port_dataavailable :  STD_LOGIC;
                signal spi_master_spi_control_port_dataavailable_from_sa :  STD_LOGIC;
                signal spi_master_spi_control_port_endofpacket :  STD_LOGIC;
                signal spi_master_spi_control_port_endofpacket_from_sa :  STD_LOGIC;
                signal spi_master_spi_control_port_irq :  STD_LOGIC;
                signal spi_master_spi_control_port_irq_from_sa :  STD_LOGIC;
                signal spi_master_spi_control_port_read_n :  STD_LOGIC;
                signal spi_master_spi_control_port_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal spi_master_spi_control_port_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal spi_master_spi_control_port_readyfordata :  STD_LOGIC;
                signal spi_master_spi_control_port_readyfordata_from_sa :  STD_LOGIC;
                signal spi_master_spi_control_port_reset_n :  STD_LOGIC;
                signal spi_master_spi_control_port_write_n :  STD_LOGIC;
                signal spi_master_spi_control_port_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal status_led_pio_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal status_led_pio_s1_chipselect :  STD_LOGIC;
                signal status_led_pio_s1_readdata :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal status_led_pio_s1_readdata_from_sa :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal status_led_pio_s1_reset_n :  STD_LOGIC;
                signal status_led_pio_s1_write_n :  STD_LOGIC;
                signal status_led_pio_s1_writedata :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sync_irq_from_pcp_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sync_irq_from_pcp_s1_chipselect :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_irq :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_irq_from_sa :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_readdata :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_readdata_from_sa :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_reset_n :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_write_n :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_writedata :  STD_LOGIC;
                signal sysid_control_slave_address :  STD_LOGIC;
                signal sysid_control_slave_clock :  STD_LOGIC;
                signal sysid_control_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal sysid_control_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal sysid_control_slave_reset_n :  STD_LOGIC;
                signal system_timer_ap_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal system_timer_ap_s1_chipselect :  STD_LOGIC;
                signal system_timer_ap_s1_irq :  STD_LOGIC;
                signal system_timer_ap_s1_irq_from_sa :  STD_LOGIC;
                signal system_timer_ap_s1_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal system_timer_ap_s1_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal system_timer_ap_s1_reset_n :  STD_LOGIC;
                signal system_timer_ap_s1_write_n :  STD_LOGIC;
                signal system_timer_ap_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);

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
  --ap_clk out_clk assignment, which is an e_assign
  internal_ap_clk <= out_clk_altpll_0_c1;
  --clk100Meg out_clk assignment, which is an e_assign
  clk100Meg <= out_clk_altpll_0_c2;
  --ap_clkSDRAM out_clk assignment, which is an e_assign
  ap_clkSDRAM <= out_clk_altpll_0_c3;
  --clk25Meg out_clk assignment, which is an e_assign
  clk25Meg <= out_clk_altpll_0_c4;
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


  --the_ap_cpu_jtag_debug_module, which is an e_instance
  the_ap_cpu_jtag_debug_module : ap_cpu_jtag_debug_module_arbitrator
    port map(
      ap_cpu_data_master_granted_ap_cpu_jtag_debug_module => ap_cpu_data_master_granted_ap_cpu_jtag_debug_module,
      ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module => ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module,
      ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module => ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module,
      ap_cpu_data_master_requests_ap_cpu_jtag_debug_module => ap_cpu_data_master_requests_ap_cpu_jtag_debug_module,
      ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module => ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module,
      ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module => ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module,
      ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module => ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module,
      ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module => ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module,
      ap_cpu_jtag_debug_module_address => ap_cpu_jtag_debug_module_address,
      ap_cpu_jtag_debug_module_begintransfer => ap_cpu_jtag_debug_module_begintransfer,
      ap_cpu_jtag_debug_module_byteenable => ap_cpu_jtag_debug_module_byteenable,
      ap_cpu_jtag_debug_module_chipselect => ap_cpu_jtag_debug_module_chipselect,
      ap_cpu_jtag_debug_module_debugaccess => ap_cpu_jtag_debug_module_debugaccess,
      ap_cpu_jtag_debug_module_readdata_from_sa => ap_cpu_jtag_debug_module_readdata_from_sa,
      ap_cpu_jtag_debug_module_reset_n => ap_cpu_jtag_debug_module_reset_n,
      ap_cpu_jtag_debug_module_resetrequest_from_sa => ap_cpu_jtag_debug_module_resetrequest_from_sa,
      ap_cpu_jtag_debug_module_write => ap_cpu_jtag_debug_module_write,
      ap_cpu_jtag_debug_module_writedata => ap_cpu_jtag_debug_module_writedata,
      d1_ap_cpu_jtag_debug_module_end_xfer => d1_ap_cpu_jtag_debug_module_end_xfer,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_byteenable => ap_cpu_data_master_byteenable,
      ap_cpu_data_master_debugaccess => ap_cpu_data_master_debugaccess,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      ap_cpu_instruction_master_address_to_slave => ap_cpu_instruction_master_address_to_slave,
      ap_cpu_instruction_master_latency_counter => ap_cpu_instruction_master_latency_counter,
      ap_cpu_instruction_master_read => ap_cpu_instruction_master_read,
      ap_cpu_jtag_debug_module_readdata => ap_cpu_jtag_debug_module_readdata,
      ap_cpu_jtag_debug_module_resetrequest => ap_cpu_jtag_debug_module_resetrequest,
      clk => internal_ap_clk,
      reset_n => ap_clk_reset_n
    );


  --the_ap_cpu_data_master, which is an e_instance
  the_ap_cpu_data_master : ap_cpu_data_master_arbitrator
    port map(
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_irq => ap_cpu_data_master_irq,
      ap_cpu_data_master_readdata => ap_cpu_data_master_readdata,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_clk => internal_ap_clk,
      ap_clk_reset_n => ap_clk_reset_n,
      ap_cpu_data_master_address => ap_cpu_data_master_address,
      ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave => ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave,
      ap_cpu_data_master_granted_ap_cpu_jtag_debug_module => ap_cpu_data_master_granted_ap_cpu_jtag_debug_module,
      ap_cpu_data_master_granted_clock_crossing_0_s1 => ap_cpu_data_master_granted_clock_crossing_0_s1,
      ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port => ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_data_master_granted_onchip_memory_0_s1 => ap_cpu_data_master_granted_onchip_memory_0_s1,
      ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave => ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave,
      ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module => ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module,
      ap_cpu_data_master_qualified_request_clock_crossing_0_s1 => ap_cpu_data_master_qualified_request_clock_crossing_0_s1,
      ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port => ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_data_master_qualified_request_onchip_memory_0_s1 => ap_cpu_data_master_qualified_request_onchip_memory_0_s1,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave => ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave,
      ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module => ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module,
      ap_cpu_data_master_read_data_valid_clock_crossing_0_s1 => ap_cpu_data_master_read_data_valid_clock_crossing_0_s1,
      ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register => ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register,
      ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port => ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 => ap_cpu_data_master_read_data_valid_onchip_memory_0_s1,
      ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave => ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave,
      ap_cpu_data_master_requests_ap_cpu_jtag_debug_module => ap_cpu_data_master_requests_ap_cpu_jtag_debug_module,
      ap_cpu_data_master_requests_clock_crossing_0_s1 => ap_cpu_data_master_requests_clock_crossing_0_s1,
      ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port => ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_data_master_requests_onchip_memory_0_s1 => ap_cpu_data_master_requests_onchip_memory_0_s1,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_jtag_debug_module_readdata_from_sa => ap_cpu_jtag_debug_module_readdata_from_sa,
      clk => internal_ap_clk,
      clock_crossing_0_s1_readdata_from_sa => clock_crossing_0_s1_readdata_from_sa,
      clock_crossing_0_s1_waitrequest_from_sa => clock_crossing_0_s1_waitrequest_from_sa,
      d1_ap_cpu_jtag_debug_module_end_xfer => d1_ap_cpu_jtag_debug_module_end_xfer,
      d1_clock_crossing_0_s1_end_xfer => d1_clock_crossing_0_s1_end_xfer,
      d1_epcs_flash_controller_0_epcs_control_port_end_xfer => d1_epcs_flash_controller_0_epcs_control_port_end_xfer,
      d1_onchip_memory_0_s1_end_xfer => d1_onchip_memory_0_s1_end_xfer,
      d1_tri_state_bridge_0_avalon_slave_end_xfer => d1_tri_state_bridge_0_avalon_slave_end_xfer,
      epcs_flash_controller_0_epcs_control_port_irq_from_sa => epcs_flash_controller_0_epcs_control_port_irq_from_sa,
      epcs_flash_controller_0_epcs_control_port_readdata_from_sa => epcs_flash_controller_0_epcs_control_port_readdata_from_sa,
      incoming_tri_state_bridge_0_data => incoming_tri_state_bridge_0_data,
      jtag_uart_1_avalon_jtag_slave_irq_from_sa => jtag_uart_1_avalon_jtag_slave_irq_from_sa,
      onchip_memory_0_s1_readdata_from_sa => onchip_memory_0_s1_readdata_from_sa,
      registered_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave => registered_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave,
      registered_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 => registered_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1,
      reset_n => ap_clk_reset_n,
      spi_master_spi_control_port_irq_from_sa => spi_master_spi_control_port_irq_from_sa,
      sync_irq_from_pcp_s1_irq_from_sa => sync_irq_from_pcp_s1_irq_from_sa,
      system_timer_ap_s1_irq_from_sa => system_timer_ap_s1_irq_from_sa
    );


  --the_ap_cpu_instruction_master, which is an e_instance
  the_ap_cpu_instruction_master : ap_cpu_instruction_master_arbitrator
    port map(
      ap_cpu_instruction_master_address_to_slave => ap_cpu_instruction_master_address_to_slave,
      ap_cpu_instruction_master_latency_counter => ap_cpu_instruction_master_latency_counter,
      ap_cpu_instruction_master_readdata => ap_cpu_instruction_master_readdata,
      ap_cpu_instruction_master_readdatavalid => ap_cpu_instruction_master_readdatavalid,
      ap_cpu_instruction_master_waitrequest => ap_cpu_instruction_master_waitrequest,
      ap_cpu_instruction_master_address => ap_cpu_instruction_master_address,
      ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave => ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave,
      ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module => ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module,
      ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port => ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_instruction_master_granted_onchip_memory_0_s1 => ap_cpu_instruction_master_granted_onchip_memory_0_s1,
      ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave => ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave,
      ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module => ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module,
      ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port => ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1 => ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1,
      ap_cpu_instruction_master_read => ap_cpu_instruction_master_read,
      ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave => ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave,
      ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module => ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module,
      ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port => ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 => ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1,
      ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave => ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave,
      ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module => ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module,
      ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port => ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_instruction_master_requests_onchip_memory_0_s1 => ap_cpu_instruction_master_requests_onchip_memory_0_s1,
      ap_cpu_jtag_debug_module_readdata_from_sa => ap_cpu_jtag_debug_module_readdata_from_sa,
      clk => internal_ap_clk,
      d1_ap_cpu_jtag_debug_module_end_xfer => d1_ap_cpu_jtag_debug_module_end_xfer,
      d1_epcs_flash_controller_0_epcs_control_port_end_xfer => d1_epcs_flash_controller_0_epcs_control_port_end_xfer,
      d1_onchip_memory_0_s1_end_xfer => d1_onchip_memory_0_s1_end_xfer,
      d1_tri_state_bridge_0_avalon_slave_end_xfer => d1_tri_state_bridge_0_avalon_slave_end_xfer,
      epcs_flash_controller_0_epcs_control_port_readdata_from_sa => epcs_flash_controller_0_epcs_control_port_readdata_from_sa,
      incoming_tri_state_bridge_0_data => incoming_tri_state_bridge_0_data,
      onchip_memory_0_s1_readdata_from_sa => onchip_memory_0_s1_readdata_from_sa,
      reset_n => ap_clk_reset_n
    );


  --the_ap_cpu, which is an e_ptf_instance
  the_ap_cpu : ap_cpu
    port map(
      d_address => ap_cpu_data_master_address,
      d_byteenable => ap_cpu_data_master_byteenable,
      d_read => ap_cpu_data_master_read,
      d_write => ap_cpu_data_master_write,
      d_writedata => ap_cpu_data_master_writedata,
      i_address => ap_cpu_instruction_master_address,
      i_read => ap_cpu_instruction_master_read,
      jtag_debug_module_debugaccess_to_roms => ap_cpu_data_master_debugaccess,
      jtag_debug_module_readdata => ap_cpu_jtag_debug_module_readdata,
      jtag_debug_module_resetrequest => ap_cpu_jtag_debug_module_resetrequest,
      clk => internal_ap_clk,
      d_irq => ap_cpu_data_master_irq,
      d_readdata => ap_cpu_data_master_readdata,
      d_waitrequest => ap_cpu_data_master_waitrequest,
      i_readdata => ap_cpu_instruction_master_readdata,
      i_readdatavalid => ap_cpu_instruction_master_readdatavalid,
      i_waitrequest => ap_cpu_instruction_master_waitrequest,
      jtag_debug_module_address => ap_cpu_jtag_debug_module_address,
      jtag_debug_module_begintransfer => ap_cpu_jtag_debug_module_begintransfer,
      jtag_debug_module_byteenable => ap_cpu_jtag_debug_module_byteenable,
      jtag_debug_module_debugaccess => ap_cpu_jtag_debug_module_debugaccess,
      jtag_debug_module_select => ap_cpu_jtag_debug_module_chipselect,
      jtag_debug_module_write => ap_cpu_jtag_debug_module_write,
      jtag_debug_module_writedata => ap_cpu_jtag_debug_module_writedata,
      reset_n => ap_cpu_jtag_debug_module_reset_n
    );


  --the_clock_crossing_0_s1, which is an e_instance
  the_clock_crossing_0_s1 : clock_crossing_0_s1_arbitrator
    port map(
      ap_cpu_data_master_granted_clock_crossing_0_s1 => ap_cpu_data_master_granted_clock_crossing_0_s1,
      ap_cpu_data_master_qualified_request_clock_crossing_0_s1 => ap_cpu_data_master_qualified_request_clock_crossing_0_s1,
      ap_cpu_data_master_read_data_valid_clock_crossing_0_s1 => ap_cpu_data_master_read_data_valid_clock_crossing_0_s1,
      ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register => ap_cpu_data_master_read_data_valid_clock_crossing_0_s1_shift_register,
      ap_cpu_data_master_requests_clock_crossing_0_s1 => ap_cpu_data_master_requests_clock_crossing_0_s1,
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
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_byteenable => ap_cpu_data_master_byteenable,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      clk => internal_ap_clk,
      clock_crossing_0_s1_endofpacket => clock_crossing_0_s1_endofpacket,
      clock_crossing_0_s1_readdata => clock_crossing_0_s1_readdata,
      clock_crossing_0_s1_readdatavalid => clock_crossing_0_s1_readdatavalid,
      clock_crossing_0_s1_waitrequest => clock_crossing_0_s1_waitrequest,
      reset_n => ap_clk_reset_n
    );


  --the_clock_crossing_0_m1, which is an e_instance
  the_clock_crossing_0_m1 : clock_crossing_0_m1_arbitrator
    port map(
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_endofpacket => clock_crossing_0_m1_endofpacket,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_readdata => clock_crossing_0_m1_readdata,
      clock_crossing_0_m1_readdatavalid => clock_crossing_0_m1_readdatavalid,
      clock_crossing_0_m1_reset_n => clock_crossing_0_m1_reset_n,
      clock_crossing_0_m1_waitrequest => clock_crossing_0_m1_waitrequest,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address => clock_crossing_0_m1_address,
      clock_crossing_0_m1_byteenable => clock_crossing_0_m1_byteenable,
      clock_crossing_0_m1_granted_inport_ap_s1 => clock_crossing_0_m1_granted_inport_ap_s1,
      clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave => clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave,
      clock_crossing_0_m1_granted_niosII_openMac_clock_0_in => clock_crossing_0_m1_granted_niosII_openMac_clock_0_in,
      clock_crossing_0_m1_granted_niosII_openMac_clock_1_in => clock_crossing_0_m1_granted_niosII_openMac_clock_1_in,
      clock_crossing_0_m1_granted_outport_ap_s1 => clock_crossing_0_m1_granted_outport_ap_s1,
      clock_crossing_0_m1_granted_status_led_pio_s1 => clock_crossing_0_m1_granted_status_led_pio_s1,
      clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 => clock_crossing_0_m1_granted_sync_irq_from_pcp_s1,
      clock_crossing_0_m1_granted_sysid_control_slave => clock_crossing_0_m1_granted_sysid_control_slave,
      clock_crossing_0_m1_granted_system_timer_ap_s1 => clock_crossing_0_m1_granted_system_timer_ap_s1,
      clock_crossing_0_m1_qualified_request_inport_ap_s1 => clock_crossing_0_m1_qualified_request_inport_ap_s1,
      clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave => clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave,
      clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in => clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in,
      clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in => clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in,
      clock_crossing_0_m1_qualified_request_outport_ap_s1 => clock_crossing_0_m1_qualified_request_outport_ap_s1,
      clock_crossing_0_m1_qualified_request_status_led_pio_s1 => clock_crossing_0_m1_qualified_request_status_led_pio_s1,
      clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 => clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1,
      clock_crossing_0_m1_qualified_request_sysid_control_slave => clock_crossing_0_m1_qualified_request_sysid_control_slave,
      clock_crossing_0_m1_qualified_request_system_timer_ap_s1 => clock_crossing_0_m1_qualified_request_system_timer_ap_s1,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_read_data_valid_inport_ap_s1 => clock_crossing_0_m1_read_data_valid_inport_ap_s1,
      clock_crossing_0_m1_read_data_valid_jtag_uart_1_avalon_jtag_slave => clock_crossing_0_m1_read_data_valid_jtag_uart_1_avalon_jtag_slave,
      clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_0_in => clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_0_in,
      clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_1_in => clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_1_in,
      clock_crossing_0_m1_read_data_valid_outport_ap_s1 => clock_crossing_0_m1_read_data_valid_outport_ap_s1,
      clock_crossing_0_m1_read_data_valid_status_led_pio_s1 => clock_crossing_0_m1_read_data_valid_status_led_pio_s1,
      clock_crossing_0_m1_read_data_valid_sync_irq_from_pcp_s1 => clock_crossing_0_m1_read_data_valid_sync_irq_from_pcp_s1,
      clock_crossing_0_m1_read_data_valid_sysid_control_slave => clock_crossing_0_m1_read_data_valid_sysid_control_slave,
      clock_crossing_0_m1_read_data_valid_system_timer_ap_s1 => clock_crossing_0_m1_read_data_valid_system_timer_ap_s1,
      clock_crossing_0_m1_requests_inport_ap_s1 => clock_crossing_0_m1_requests_inport_ap_s1,
      clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave => clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave,
      clock_crossing_0_m1_requests_niosII_openMac_clock_0_in => clock_crossing_0_m1_requests_niosII_openMac_clock_0_in,
      clock_crossing_0_m1_requests_niosII_openMac_clock_1_in => clock_crossing_0_m1_requests_niosII_openMac_clock_1_in,
      clock_crossing_0_m1_requests_outport_ap_s1 => clock_crossing_0_m1_requests_outport_ap_s1,
      clock_crossing_0_m1_requests_status_led_pio_s1 => clock_crossing_0_m1_requests_status_led_pio_s1,
      clock_crossing_0_m1_requests_sync_irq_from_pcp_s1 => clock_crossing_0_m1_requests_sync_irq_from_pcp_s1,
      clock_crossing_0_m1_requests_sysid_control_slave => clock_crossing_0_m1_requests_sysid_control_slave,
      clock_crossing_0_m1_requests_system_timer_ap_s1 => clock_crossing_0_m1_requests_system_timer_ap_s1,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      clock_crossing_0_m1_writedata => clock_crossing_0_m1_writedata,
      d1_inport_ap_s1_end_xfer => d1_inport_ap_s1_end_xfer,
      d1_jtag_uart_1_avalon_jtag_slave_end_xfer => d1_jtag_uart_1_avalon_jtag_slave_end_xfer,
      d1_niosII_openMac_clock_0_in_end_xfer => d1_niosII_openMac_clock_0_in_end_xfer,
      d1_niosII_openMac_clock_1_in_end_xfer => d1_niosII_openMac_clock_1_in_end_xfer,
      d1_outport_ap_s1_end_xfer => d1_outport_ap_s1_end_xfer,
      d1_status_led_pio_s1_end_xfer => d1_status_led_pio_s1_end_xfer,
      d1_sync_irq_from_pcp_s1_end_xfer => d1_sync_irq_from_pcp_s1_end_xfer,
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      d1_system_timer_ap_s1_end_xfer => d1_system_timer_ap_s1_end_xfer,
      inport_ap_s1_readdata_from_sa => inport_ap_s1_readdata_from_sa,
      jtag_uart_1_avalon_jtag_slave_readdata_from_sa => jtag_uart_1_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa,
      niosII_openMac_clock_0_in_endofpacket_from_sa => niosII_openMac_clock_0_in_endofpacket_from_sa,
      niosII_openMac_clock_0_in_readdata_from_sa => niosII_openMac_clock_0_in_readdata_from_sa,
      niosII_openMac_clock_0_in_waitrequest_from_sa => niosII_openMac_clock_0_in_waitrequest_from_sa,
      niosII_openMac_clock_1_in_endofpacket_from_sa => niosII_openMac_clock_1_in_endofpacket_from_sa,
      niosII_openMac_clock_1_in_readdata_from_sa => niosII_openMac_clock_1_in_readdata_from_sa,
      niosII_openMac_clock_1_in_waitrequest_from_sa => niosII_openMac_clock_1_in_waitrequest_from_sa,
      outport_ap_s1_readdata_from_sa => outport_ap_s1_readdata_from_sa,
      reset_n => clk50Meg_reset_n,
      status_led_pio_s1_readdata_from_sa => status_led_pio_s1_readdata_from_sa,
      sync_irq_from_pcp_s1_readdata_from_sa => sync_irq_from_pcp_s1_readdata_from_sa,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      system_timer_ap_s1_readdata_from_sa => system_timer_ap_s1_readdata_from_sa
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
      slave_clk => internal_ap_clk,
      slave_nativeaddress => clock_crossing_0_s1_nativeaddress,
      slave_read => clock_crossing_0_s1_read,
      slave_reset_n => clock_crossing_0_s1_reset_n,
      slave_write => clock_crossing_0_s1_write,
      slave_writedata => clock_crossing_0_s1_writedata
    );


  --the_epcs_flash_controller_0_epcs_control_port, which is an e_instance
  the_epcs_flash_controller_0_epcs_control_port : epcs_flash_controller_0_epcs_control_port_arbitrator
    port map(
      ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port => ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port => ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port => ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port => ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port => ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port => ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port => ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port => ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port,
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
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      ap_cpu_instruction_master_address_to_slave => ap_cpu_instruction_master_address_to_slave,
      ap_cpu_instruction_master_latency_counter => ap_cpu_instruction_master_latency_counter,
      ap_cpu_instruction_master_read => ap_cpu_instruction_master_read,
      clk => internal_ap_clk,
      epcs_flash_controller_0_epcs_control_port_dataavailable => epcs_flash_controller_0_epcs_control_port_dataavailable,
      epcs_flash_controller_0_epcs_control_port_endofpacket => epcs_flash_controller_0_epcs_control_port_endofpacket,
      epcs_flash_controller_0_epcs_control_port_irq => epcs_flash_controller_0_epcs_control_port_irq,
      epcs_flash_controller_0_epcs_control_port_readdata => epcs_flash_controller_0_epcs_control_port_readdata,
      epcs_flash_controller_0_epcs_control_port_readyfordata => epcs_flash_controller_0_epcs_control_port_readyfordata,
      reset_n => ap_clk_reset_n
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
      clk => internal_ap_clk,
      data0 => data0_to_the_epcs_flash_controller_0,
      read_n => epcs_flash_controller_0_epcs_control_port_read_n,
      reset_n => epcs_flash_controller_0_epcs_control_port_reset_n,
      write_n => epcs_flash_controller_0_epcs_control_port_write_n,
      writedata => epcs_flash_controller_0_epcs_control_port_writedata
    );


  --the_inport_ap_s1, which is an e_instance
  the_inport_ap_s1 : inport_ap_s1_arbitrator
    port map(
      clock_crossing_0_m1_granted_inport_ap_s1 => clock_crossing_0_m1_granted_inport_ap_s1,
      clock_crossing_0_m1_qualified_request_inport_ap_s1 => clock_crossing_0_m1_qualified_request_inport_ap_s1,
      clock_crossing_0_m1_read_data_valid_inport_ap_s1 => clock_crossing_0_m1_read_data_valid_inport_ap_s1,
      clock_crossing_0_m1_requests_inport_ap_s1 => clock_crossing_0_m1_requests_inport_ap_s1,
      d1_inport_ap_s1_end_xfer => d1_inport_ap_s1_end_xfer,
      inport_ap_s1_address => inport_ap_s1_address,
      inport_ap_s1_readdata_from_sa => inport_ap_s1_readdata_from_sa,
      inport_ap_s1_reset_n => inport_ap_s1_reset_n,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_nativeaddress => clock_crossing_0_m1_nativeaddress,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      inport_ap_s1_readdata => inport_ap_s1_readdata,
      reset_n => clk50Meg_reset_n
    );


  --the_inport_ap, which is an e_ptf_instance
  the_inport_ap : inport_ap
    port map(
      readdata => inport_ap_s1_readdata,
      address => inport_ap_s1_address,
      clk => internal_clk50Meg,
      in_port => in_port_to_the_inport_ap,
      reset_n => inport_ap_s1_reset_n
    );


  --the_jtag_uart_1_avalon_jtag_slave, which is an e_instance
  the_jtag_uart_1_avalon_jtag_slave : jtag_uart_1_avalon_jtag_slave_arbitrator
    port map(
      clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave => clock_crossing_0_m1_granted_jtag_uart_1_avalon_jtag_slave,
      clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave => clock_crossing_0_m1_qualified_request_jtag_uart_1_avalon_jtag_slave,
      clock_crossing_0_m1_read_data_valid_jtag_uart_1_avalon_jtag_slave => clock_crossing_0_m1_read_data_valid_jtag_uart_1_avalon_jtag_slave,
      clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave => clock_crossing_0_m1_requests_jtag_uart_1_avalon_jtag_slave,
      d1_jtag_uart_1_avalon_jtag_slave_end_xfer => d1_jtag_uart_1_avalon_jtag_slave_end_xfer,
      jtag_uart_1_avalon_jtag_slave_address => jtag_uart_1_avalon_jtag_slave_address,
      jtag_uart_1_avalon_jtag_slave_chipselect => jtag_uart_1_avalon_jtag_slave_chipselect,
      jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa => jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa,
      jtag_uart_1_avalon_jtag_slave_irq_from_sa => jtag_uart_1_avalon_jtag_slave_irq_from_sa,
      jtag_uart_1_avalon_jtag_slave_read_n => jtag_uart_1_avalon_jtag_slave_read_n,
      jtag_uart_1_avalon_jtag_slave_readdata_from_sa => jtag_uart_1_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa => jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa,
      jtag_uart_1_avalon_jtag_slave_reset_n => jtag_uart_1_avalon_jtag_slave_reset_n,
      jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa,
      jtag_uart_1_avalon_jtag_slave_write_n => jtag_uart_1_avalon_jtag_slave_write_n,
      jtag_uart_1_avalon_jtag_slave_writedata => jtag_uart_1_avalon_jtag_slave_writedata,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_nativeaddress => clock_crossing_0_m1_nativeaddress,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      clock_crossing_0_m1_writedata => clock_crossing_0_m1_writedata,
      jtag_uart_1_avalon_jtag_slave_dataavailable => jtag_uart_1_avalon_jtag_slave_dataavailable,
      jtag_uart_1_avalon_jtag_slave_irq => jtag_uart_1_avalon_jtag_slave_irq,
      jtag_uart_1_avalon_jtag_slave_readdata => jtag_uart_1_avalon_jtag_slave_readdata,
      jtag_uart_1_avalon_jtag_slave_readyfordata => jtag_uart_1_avalon_jtag_slave_readyfordata,
      jtag_uart_1_avalon_jtag_slave_waitrequest => jtag_uart_1_avalon_jtag_slave_waitrequest,
      reset_n => clk50Meg_reset_n
    );


  --the_jtag_uart_1, which is an e_ptf_instance
  the_jtag_uart_1 : jtag_uart_1
    port map(
      av_irq => jtag_uart_1_avalon_jtag_slave_irq,
      av_readdata => jtag_uart_1_avalon_jtag_slave_readdata,
      av_waitrequest => jtag_uart_1_avalon_jtag_slave_waitrequest,
      dataavailable => jtag_uart_1_avalon_jtag_slave_dataavailable,
      readyfordata => jtag_uart_1_avalon_jtag_slave_readyfordata,
      av_address => jtag_uart_1_avalon_jtag_slave_address,
      av_chipselect => jtag_uart_1_avalon_jtag_slave_chipselect,
      av_read_n => jtag_uart_1_avalon_jtag_slave_read_n,
      av_write_n => jtag_uart_1_avalon_jtag_slave_write_n,
      av_writedata => jtag_uart_1_avalon_jtag_slave_writedata,
      clk => internal_clk50Meg,
      rst_n => jtag_uart_1_avalon_jtag_slave_reset_n
    );


  --the_niosII_openMac_clock_0_in, which is an e_instance
  the_niosII_openMac_clock_0_in : niosII_openMac_clock_0_in_arbitrator
    port map(
      clock_crossing_0_m1_granted_niosII_openMac_clock_0_in => clock_crossing_0_m1_granted_niosII_openMac_clock_0_in,
      clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in => clock_crossing_0_m1_qualified_request_niosII_openMac_clock_0_in,
      clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_0_in => clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_0_in,
      clock_crossing_0_m1_requests_niosII_openMac_clock_0_in => clock_crossing_0_m1_requests_niosII_openMac_clock_0_in,
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
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_byteenable => clock_crossing_0_m1_byteenable,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_nativeaddress => clock_crossing_0_m1_nativeaddress,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      clock_crossing_0_m1_writedata => clock_crossing_0_m1_writedata,
      niosII_openMac_clock_0_in_endofpacket => niosII_openMac_clock_0_in_endofpacket,
      niosII_openMac_clock_0_in_readdata => niosII_openMac_clock_0_in_readdata,
      niosII_openMac_clock_0_in_waitrequest => niosII_openMac_clock_0_in_waitrequest,
      reset_n => clk50Meg_reset_n
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
      slave_clk => internal_clk50Meg,
      slave_nativeaddress => niosII_openMac_clock_0_in_nativeaddress,
      slave_read => niosII_openMac_clock_0_in_read,
      slave_reset_n => niosII_openMac_clock_0_in_reset_n,
      slave_write => niosII_openMac_clock_0_in_write,
      slave_writedata => niosII_openMac_clock_0_in_writedata
    );


  --the_niosII_openMac_clock_1_in, which is an e_instance
  the_niosII_openMac_clock_1_in : niosII_openMac_clock_1_in_arbitrator
    port map(
      clock_crossing_0_m1_granted_niosII_openMac_clock_1_in => clock_crossing_0_m1_granted_niosII_openMac_clock_1_in,
      clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in => clock_crossing_0_m1_qualified_request_niosII_openMac_clock_1_in,
      clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_1_in => clock_crossing_0_m1_read_data_valid_niosII_openMac_clock_1_in,
      clock_crossing_0_m1_requests_niosII_openMac_clock_1_in => clock_crossing_0_m1_requests_niosII_openMac_clock_1_in,
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
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_byteenable => clock_crossing_0_m1_byteenable,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_nativeaddress => clock_crossing_0_m1_nativeaddress,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      clock_crossing_0_m1_writedata => clock_crossing_0_m1_writedata,
      niosII_openMac_clock_1_in_endofpacket => niosII_openMac_clock_1_in_endofpacket,
      niosII_openMac_clock_1_in_readdata => niosII_openMac_clock_1_in_readdata,
      niosII_openMac_clock_1_in_waitrequest => niosII_openMac_clock_1_in_waitrequest,
      reset_n => clk50Meg_reset_n
    );


  --the_niosII_openMac_clock_1_out, which is an e_instance
  the_niosII_openMac_clock_1_out : niosII_openMac_clock_1_out_arbitrator
    port map(
      niosII_openMac_clock_1_out_address_to_slave => niosII_openMac_clock_1_out_address_to_slave,
      niosII_openMac_clock_1_out_endofpacket => niosII_openMac_clock_1_out_endofpacket,
      niosII_openMac_clock_1_out_readdata => niosII_openMac_clock_1_out_readdata,
      niosII_openMac_clock_1_out_reset_n => niosII_openMac_clock_1_out_reset_n,
      niosII_openMac_clock_1_out_waitrequest => niosII_openMac_clock_1_out_waitrequest,
      clk => clk_0,
      d1_spi_master_spi_control_port_end_xfer => d1_spi_master_spi_control_port_end_xfer,
      niosII_openMac_clock_1_out_address => niosII_openMac_clock_1_out_address,
      niosII_openMac_clock_1_out_byteenable => niosII_openMac_clock_1_out_byteenable,
      niosII_openMac_clock_1_out_granted_spi_master_spi_control_port => niosII_openMac_clock_1_out_granted_spi_master_spi_control_port,
      niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port => niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port,
      niosII_openMac_clock_1_out_read => niosII_openMac_clock_1_out_read,
      niosII_openMac_clock_1_out_read_data_valid_spi_master_spi_control_port => niosII_openMac_clock_1_out_read_data_valid_spi_master_spi_control_port,
      niosII_openMac_clock_1_out_requests_spi_master_spi_control_port => niosII_openMac_clock_1_out_requests_spi_master_spi_control_port,
      niosII_openMac_clock_1_out_write => niosII_openMac_clock_1_out_write,
      niosII_openMac_clock_1_out_writedata => niosII_openMac_clock_1_out_writedata,
      reset_n => clk_0_reset_n,
      spi_master_spi_control_port_endofpacket_from_sa => spi_master_spi_control_port_endofpacket_from_sa,
      spi_master_spi_control_port_readdata_from_sa => spi_master_spi_control_port_readdata_from_sa
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
      master_clk => clk_0,
      master_endofpacket => niosII_openMac_clock_1_out_endofpacket,
      master_readdata => niosII_openMac_clock_1_out_readdata,
      master_reset_n => niosII_openMac_clock_1_out_reset_n,
      master_waitrequest => niosII_openMac_clock_1_out_waitrequest,
      slave_address => niosII_openMac_clock_1_in_address,
      slave_byteenable => niosII_openMac_clock_1_in_byteenable,
      slave_clk => internal_clk50Meg,
      slave_nativeaddress => niosII_openMac_clock_1_in_nativeaddress,
      slave_read => niosII_openMac_clock_1_in_read,
      slave_reset_n => niosII_openMac_clock_1_in_reset_n,
      slave_write => niosII_openMac_clock_1_in_write,
      slave_writedata => niosII_openMac_clock_1_in_writedata
    );


  --the_onchip_memory_0_s1, which is an e_instance
  the_onchip_memory_0_s1 : onchip_memory_0_s1_arbitrator
    port map(
      ap_cpu_data_master_granted_onchip_memory_0_s1 => ap_cpu_data_master_granted_onchip_memory_0_s1,
      ap_cpu_data_master_qualified_request_onchip_memory_0_s1 => ap_cpu_data_master_qualified_request_onchip_memory_0_s1,
      ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 => ap_cpu_data_master_read_data_valid_onchip_memory_0_s1,
      ap_cpu_data_master_requests_onchip_memory_0_s1 => ap_cpu_data_master_requests_onchip_memory_0_s1,
      ap_cpu_instruction_master_granted_onchip_memory_0_s1 => ap_cpu_instruction_master_granted_onchip_memory_0_s1,
      ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1 => ap_cpu_instruction_master_qualified_request_onchip_memory_0_s1,
      ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1 => ap_cpu_instruction_master_read_data_valid_onchip_memory_0_s1,
      ap_cpu_instruction_master_requests_onchip_memory_0_s1 => ap_cpu_instruction_master_requests_onchip_memory_0_s1,
      d1_onchip_memory_0_s1_end_xfer => d1_onchip_memory_0_s1_end_xfer,
      onchip_memory_0_s1_address => onchip_memory_0_s1_address,
      onchip_memory_0_s1_byteenable => onchip_memory_0_s1_byteenable,
      onchip_memory_0_s1_chipselect => onchip_memory_0_s1_chipselect,
      onchip_memory_0_s1_clken => onchip_memory_0_s1_clken,
      onchip_memory_0_s1_readdata_from_sa => onchip_memory_0_s1_readdata_from_sa,
      onchip_memory_0_s1_write => onchip_memory_0_s1_write,
      onchip_memory_0_s1_writedata => onchip_memory_0_s1_writedata,
      registered_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1 => registered_ap_cpu_data_master_read_data_valid_onchip_memory_0_s1,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_byteenable => ap_cpu_data_master_byteenable,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      ap_cpu_instruction_master_address_to_slave => ap_cpu_instruction_master_address_to_slave,
      ap_cpu_instruction_master_latency_counter => ap_cpu_instruction_master_latency_counter,
      ap_cpu_instruction_master_read => ap_cpu_instruction_master_read,
      clk => internal_ap_clk,
      onchip_memory_0_s1_readdata => onchip_memory_0_s1_readdata,
      reset_n => ap_clk_reset_n
    );


  --the_onchip_memory_0, which is an e_ptf_instance
  the_onchip_memory_0 : onchip_memory_0
    port map(
      readdata => onchip_memory_0_s1_readdata,
      address => onchip_memory_0_s1_address,
      byteenable => onchip_memory_0_s1_byteenable,
      chipselect => onchip_memory_0_s1_chipselect,
      clk => internal_ap_clk,
      clken => onchip_memory_0_s1_clken,
      write => onchip_memory_0_s1_write,
      writedata => onchip_memory_0_s1_writedata
    );


  --the_outport_ap_s1, which is an e_instance
  the_outport_ap_s1 : outport_ap_s1_arbitrator
    port map(
      clock_crossing_0_m1_granted_outport_ap_s1 => clock_crossing_0_m1_granted_outport_ap_s1,
      clock_crossing_0_m1_qualified_request_outport_ap_s1 => clock_crossing_0_m1_qualified_request_outport_ap_s1,
      clock_crossing_0_m1_read_data_valid_outport_ap_s1 => clock_crossing_0_m1_read_data_valid_outport_ap_s1,
      clock_crossing_0_m1_requests_outport_ap_s1 => clock_crossing_0_m1_requests_outport_ap_s1,
      d1_outport_ap_s1_end_xfer => d1_outport_ap_s1_end_xfer,
      outport_ap_s1_address => outport_ap_s1_address,
      outport_ap_s1_chipselect => outport_ap_s1_chipselect,
      outport_ap_s1_readdata_from_sa => outport_ap_s1_readdata_from_sa,
      outport_ap_s1_reset_n => outport_ap_s1_reset_n,
      outport_ap_s1_write_n => outport_ap_s1_write_n,
      outport_ap_s1_writedata => outport_ap_s1_writedata,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_nativeaddress => clock_crossing_0_m1_nativeaddress,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      clock_crossing_0_m1_writedata => clock_crossing_0_m1_writedata,
      outport_ap_s1_readdata => outport_ap_s1_readdata,
      reset_n => clk50Meg_reset_n
    );


  --the_outport_ap, which is an e_ptf_instance
  the_outport_ap : outport_ap
    port map(
      out_port => internal_out_port_from_the_outport_ap,
      readdata => outport_ap_s1_readdata,
      address => outport_ap_s1_address,
      chipselect => outport_ap_s1_chipselect,
      clk => internal_clk50Meg,
      reset_n => outport_ap_s1_reset_n,
      write_n => outport_ap_s1_write_n,
      writedata => outport_ap_s1_writedata
    );


  --the_spi_master_spi_control_port, which is an e_instance
  the_spi_master_spi_control_port : spi_master_spi_control_port_arbitrator
    port map(
      d1_spi_master_spi_control_port_end_xfer => d1_spi_master_spi_control_port_end_xfer,
      niosII_openMac_clock_1_out_granted_spi_master_spi_control_port => niosII_openMac_clock_1_out_granted_spi_master_spi_control_port,
      niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port => niosII_openMac_clock_1_out_qualified_request_spi_master_spi_control_port,
      niosII_openMac_clock_1_out_read_data_valid_spi_master_spi_control_port => niosII_openMac_clock_1_out_read_data_valid_spi_master_spi_control_port,
      niosII_openMac_clock_1_out_requests_spi_master_spi_control_port => niosII_openMac_clock_1_out_requests_spi_master_spi_control_port,
      spi_master_spi_control_port_address => spi_master_spi_control_port_address,
      spi_master_spi_control_port_chipselect => spi_master_spi_control_port_chipselect,
      spi_master_spi_control_port_dataavailable_from_sa => spi_master_spi_control_port_dataavailable_from_sa,
      spi_master_spi_control_port_endofpacket_from_sa => spi_master_spi_control_port_endofpacket_from_sa,
      spi_master_spi_control_port_irq_from_sa => spi_master_spi_control_port_irq_from_sa,
      spi_master_spi_control_port_read_n => spi_master_spi_control_port_read_n,
      spi_master_spi_control_port_readdata_from_sa => spi_master_spi_control_port_readdata_from_sa,
      spi_master_spi_control_port_readyfordata_from_sa => spi_master_spi_control_port_readyfordata_from_sa,
      spi_master_spi_control_port_reset_n => spi_master_spi_control_port_reset_n,
      spi_master_spi_control_port_write_n => spi_master_spi_control_port_write_n,
      spi_master_spi_control_port_writedata => spi_master_spi_control_port_writedata,
      clk => clk_0,
      niosII_openMac_clock_1_out_address_to_slave => niosII_openMac_clock_1_out_address_to_slave,
      niosII_openMac_clock_1_out_nativeaddress => niosII_openMac_clock_1_out_nativeaddress,
      niosII_openMac_clock_1_out_read => niosII_openMac_clock_1_out_read,
      niosII_openMac_clock_1_out_write => niosII_openMac_clock_1_out_write,
      niosII_openMac_clock_1_out_writedata => niosII_openMac_clock_1_out_writedata,
      reset_n => clk_0_reset_n,
      spi_master_spi_control_port_dataavailable => spi_master_spi_control_port_dataavailable,
      spi_master_spi_control_port_endofpacket => spi_master_spi_control_port_endofpacket,
      spi_master_spi_control_port_irq => spi_master_spi_control_port_irq,
      spi_master_spi_control_port_readdata => spi_master_spi_control_port_readdata,
      spi_master_spi_control_port_readyfordata => spi_master_spi_control_port_readyfordata
    );


  --the_spi_master, which is an e_ptf_instance
  the_spi_master : spi_master
    port map(
      MOSI => internal_MOSI_from_the_spi_master,
      SCLK => internal_SCLK_from_the_spi_master,
      SS_n => internal_SS_n_from_the_spi_master,
      data_to_cpu => spi_master_spi_control_port_readdata,
      dataavailable => spi_master_spi_control_port_dataavailable,
      endofpacket => spi_master_spi_control_port_endofpacket,
      irq => spi_master_spi_control_port_irq,
      readyfordata => spi_master_spi_control_port_readyfordata,
      MISO => MISO_to_the_spi_master,
      clk => clk_0,
      data_from_cpu => spi_master_spi_control_port_writedata,
      mem_addr => spi_master_spi_control_port_address,
      read_n => spi_master_spi_control_port_read_n,
      reset_n => spi_master_spi_control_port_reset_n,
      spi_select => spi_master_spi_control_port_chipselect,
      write_n => spi_master_spi_control_port_write_n
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


  --the_sync_irq_from_pcp_s1, which is an e_instance
  the_sync_irq_from_pcp_s1 : sync_irq_from_pcp_s1_arbitrator
    port map(
      clock_crossing_0_m1_granted_sync_irq_from_pcp_s1 => clock_crossing_0_m1_granted_sync_irq_from_pcp_s1,
      clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1 => clock_crossing_0_m1_qualified_request_sync_irq_from_pcp_s1,
      clock_crossing_0_m1_read_data_valid_sync_irq_from_pcp_s1 => clock_crossing_0_m1_read_data_valid_sync_irq_from_pcp_s1,
      clock_crossing_0_m1_requests_sync_irq_from_pcp_s1 => clock_crossing_0_m1_requests_sync_irq_from_pcp_s1,
      d1_sync_irq_from_pcp_s1_end_xfer => d1_sync_irq_from_pcp_s1_end_xfer,
      sync_irq_from_pcp_s1_address => sync_irq_from_pcp_s1_address,
      sync_irq_from_pcp_s1_chipselect => sync_irq_from_pcp_s1_chipselect,
      sync_irq_from_pcp_s1_irq_from_sa => sync_irq_from_pcp_s1_irq_from_sa,
      sync_irq_from_pcp_s1_readdata_from_sa => sync_irq_from_pcp_s1_readdata_from_sa,
      sync_irq_from_pcp_s1_reset_n => sync_irq_from_pcp_s1_reset_n,
      sync_irq_from_pcp_s1_write_n => sync_irq_from_pcp_s1_write_n,
      sync_irq_from_pcp_s1_writedata => sync_irq_from_pcp_s1_writedata,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_nativeaddress => clock_crossing_0_m1_nativeaddress,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      clock_crossing_0_m1_writedata => clock_crossing_0_m1_writedata,
      reset_n => clk50Meg_reset_n,
      sync_irq_from_pcp_s1_irq => sync_irq_from_pcp_s1_irq,
      sync_irq_from_pcp_s1_readdata => sync_irq_from_pcp_s1_readdata
    );


  --the_sync_irq_from_pcp, which is an e_ptf_instance
  the_sync_irq_from_pcp : sync_irq_from_pcp
    port map(
      irq => sync_irq_from_pcp_s1_irq,
      readdata => sync_irq_from_pcp_s1_readdata,
      address => sync_irq_from_pcp_s1_address,
      chipselect => sync_irq_from_pcp_s1_chipselect,
      clk => internal_clk50Meg,
      in_port => in_port_to_the_sync_irq_from_pcp,
      reset_n => sync_irq_from_pcp_s1_reset_n,
      write_n => sync_irq_from_pcp_s1_write_n,
      writedata => sync_irq_from_pcp_s1_writedata
    );


  --the_sysid_control_slave, which is an e_instance
  the_sysid_control_slave : sysid_control_slave_arbitrator
    port map(
      clock_crossing_0_m1_granted_sysid_control_slave => clock_crossing_0_m1_granted_sysid_control_slave,
      clock_crossing_0_m1_qualified_request_sysid_control_slave => clock_crossing_0_m1_qualified_request_sysid_control_slave,
      clock_crossing_0_m1_read_data_valid_sysid_control_slave => clock_crossing_0_m1_read_data_valid_sysid_control_slave,
      clock_crossing_0_m1_requests_sysid_control_slave => clock_crossing_0_m1_requests_sysid_control_slave,
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      sysid_control_slave_address => sysid_control_slave_address,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      sysid_control_slave_reset_n => sysid_control_slave_reset_n,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_nativeaddress => clock_crossing_0_m1_nativeaddress,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      reset_n => clk50Meg_reset_n,
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


  --the_system_timer_ap_s1, which is an e_instance
  the_system_timer_ap_s1 : system_timer_ap_s1_arbitrator
    port map(
      clock_crossing_0_m1_granted_system_timer_ap_s1 => clock_crossing_0_m1_granted_system_timer_ap_s1,
      clock_crossing_0_m1_qualified_request_system_timer_ap_s1 => clock_crossing_0_m1_qualified_request_system_timer_ap_s1,
      clock_crossing_0_m1_read_data_valid_system_timer_ap_s1 => clock_crossing_0_m1_read_data_valid_system_timer_ap_s1,
      clock_crossing_0_m1_requests_system_timer_ap_s1 => clock_crossing_0_m1_requests_system_timer_ap_s1,
      d1_system_timer_ap_s1_end_xfer => d1_system_timer_ap_s1_end_xfer,
      system_timer_ap_s1_address => system_timer_ap_s1_address,
      system_timer_ap_s1_chipselect => system_timer_ap_s1_chipselect,
      system_timer_ap_s1_irq_from_sa => system_timer_ap_s1_irq_from_sa,
      system_timer_ap_s1_readdata_from_sa => system_timer_ap_s1_readdata_from_sa,
      system_timer_ap_s1_reset_n => system_timer_ap_s1_reset_n,
      system_timer_ap_s1_write_n => system_timer_ap_s1_write_n,
      system_timer_ap_s1_writedata => system_timer_ap_s1_writedata,
      clk => internal_clk50Meg,
      clock_crossing_0_m1_address_to_slave => clock_crossing_0_m1_address_to_slave,
      clock_crossing_0_m1_latency_counter => clock_crossing_0_m1_latency_counter,
      clock_crossing_0_m1_nativeaddress => clock_crossing_0_m1_nativeaddress,
      clock_crossing_0_m1_read => clock_crossing_0_m1_read,
      clock_crossing_0_m1_write => clock_crossing_0_m1_write,
      clock_crossing_0_m1_writedata => clock_crossing_0_m1_writedata,
      reset_n => clk50Meg_reset_n,
      system_timer_ap_s1_irq => system_timer_ap_s1_irq,
      system_timer_ap_s1_readdata => system_timer_ap_s1_readdata
    );


  --the_system_timer_ap, which is an e_ptf_instance
  the_system_timer_ap : system_timer_ap
    port map(
      irq => system_timer_ap_s1_irq,
      readdata => system_timer_ap_s1_readdata,
      address => system_timer_ap_s1_address,
      chipselect => system_timer_ap_s1_chipselect,
      clk => internal_clk50Meg,
      reset_n => system_timer_ap_s1_reset_n,
      write_n => system_timer_ap_s1_write_n,
      writedata => system_timer_ap_s1_writedata
    );


  --the_tri_state_bridge_0_avalon_slave, which is an e_instance
  the_tri_state_bridge_0_avalon_slave : tri_state_bridge_0_avalon_slave_arbitrator
    port map(
      addr_to_the_SRAM_0 => internal_addr_to_the_SRAM_0,
      ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave => ap_cpu_data_master_granted_SRAM_0_avalon_tristate_slave,
      ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave => ap_cpu_data_master_qualified_request_SRAM_0_avalon_tristate_slave,
      ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave => ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave,
      ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave => ap_cpu_data_master_requests_SRAM_0_avalon_tristate_slave,
      ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave => ap_cpu_instruction_master_granted_SRAM_0_avalon_tristate_slave,
      ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave => ap_cpu_instruction_master_qualified_request_SRAM_0_avalon_tristate_slave,
      ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave => ap_cpu_instruction_master_read_data_valid_SRAM_0_avalon_tristate_slave,
      ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave => ap_cpu_instruction_master_requests_SRAM_0_avalon_tristate_slave,
      ben_to_the_SRAM_0 => internal_ben_to_the_SRAM_0,
      d1_tri_state_bridge_0_avalon_slave_end_xfer => d1_tri_state_bridge_0_avalon_slave_end_xfer,
      incoming_tri_state_bridge_0_data => incoming_tri_state_bridge_0_data,
      ncs_to_the_SRAM_0 => internal_ncs_to_the_SRAM_0,
      rdn_to_the_SRAM_0 => internal_rdn_to_the_SRAM_0,
      registered_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave => registered_ap_cpu_data_master_read_data_valid_SRAM_0_avalon_tristate_slave,
      tri_state_bridge_0_data => tri_state_bridge_0_data,
      wrn_to_the_SRAM_0 => internal_wrn_to_the_SRAM_0,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_byteenable => ap_cpu_data_master_byteenable,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      ap_cpu_instruction_master_address_to_slave => ap_cpu_instruction_master_address_to_slave,
      ap_cpu_instruction_master_latency_counter => ap_cpu_instruction_master_latency_counter,
      ap_cpu_instruction_master_read => ap_cpu_instruction_master_read,
      clk => internal_ap_clk,
      reset_n => ap_clk_reset_n
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
  reset_n_sources <= Vector_To_Std_Logic(NOT (((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT reset_n))) OR std_logic_vector'("00000000000000000000000000000000")) OR std_logic_vector'("00000000000000000000000000000000")) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_jtag_debug_module_resetrequest_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_jtag_debug_module_resetrequest_from_sa)))) OR std_logic_vector'("00000000000000000000000000000000"))));
  --reset is asserted asynchronously and deasserted synchronously
  niosII_openMac_reset_ap_clk_domain_synch : niosII_openMac_reset_ap_clk_domain_synch_module
    port map(
      data_out => ap_clk_reset_n,
      clk => internal_ap_clk,
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

  --niosII_openMac_clock_0_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  niosII_openMac_clock_0_out_endofpacket <= std_logic'('0');
  --sysid_control_slave_clock of type clock does not connect to anything so wire it to default (0)
  sysid_control_slave_clock <= std_logic'('0');
  --vhdl renameroo for output signals
  MOSI_from_the_spi_master <= internal_MOSI_from_the_spi_master;
  --vhdl renameroo for output signals
  SCLK_from_the_spi_master <= internal_SCLK_from_the_spi_master;
  --vhdl renameroo for output signals
  SS_n_from_the_spi_master <= internal_SS_n_from_the_spi_master;
  --vhdl renameroo for output signals
  addr_to_the_SRAM_0 <= internal_addr_to_the_SRAM_0;
  --vhdl renameroo for output signals
  ap_clk <= internal_ap_clk;
  --vhdl renameroo for output signals
  ben_to_the_SRAM_0 <= internal_ben_to_the_SRAM_0;
  --vhdl renameroo for output signals
  clk50Meg <= internal_clk50Meg;
  --vhdl renameroo for output signals
  dclk_from_the_epcs_flash_controller_0 <= internal_dclk_from_the_epcs_flash_controller_0;
  --vhdl renameroo for output signals
  locked_from_the_altpll_0 <= internal_locked_from_the_altpll_0;
  --vhdl renameroo for output signals
  ncs_to_the_SRAM_0 <= internal_ncs_to_the_SRAM_0;
  --vhdl renameroo for output signals
  out_port_from_the_outport_ap <= internal_out_port_from_the_outport_ap;
  --vhdl renameroo for output signals
  out_port_from_the_status_led_pio <= internal_out_port_from_the_status_led_pio;
  --vhdl renameroo for output signals
  phasedone_from_the_altpll_0 <= internal_phasedone_from_the_altpll_0;
  --vhdl renameroo for output signals
  rdn_to_the_SRAM_0 <= internal_rdn_to_the_SRAM_0;
  --vhdl renameroo for output signals
  sce_from_the_epcs_flash_controller_0 <= internal_sce_from_the_epcs_flash_controller_0;
  --vhdl renameroo for output signals
  sdo_from_the_epcs_flash_controller_0 <= internal_sdo_from_the_epcs_flash_controller_0;
  --vhdl renameroo for output signals
  wrn_to_the_SRAM_0 <= internal_wrn_to_the_SRAM_0;

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
                    signal ap_clkSDRAM : OUT STD_LOGIC;
                    signal clk100Meg : OUT STD_LOGIC;
                    signal clk25Meg : OUT STD_LOGIC;
                    signal clk50Meg : OUT STD_LOGIC;
                    signal clk_0 : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- the_altpll_0
                    signal locked_from_the_altpll_0 : OUT STD_LOGIC;
                    signal phasedone_from_the_altpll_0 : OUT STD_LOGIC;

                 -- the_epcs_flash_controller_0
                    signal data0_to_the_epcs_flash_controller_0 : IN STD_LOGIC;
                    signal dclk_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;
                    signal sce_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;
                    signal sdo_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;

                 -- the_inport_ap
                    signal in_port_to_the_inport_ap : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_outport_ap
                    signal out_port_from_the_outport_ap : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);

                 -- the_spi_master
                    signal MISO_to_the_spi_master : IN STD_LOGIC;
                    signal MOSI_from_the_spi_master : OUT STD_LOGIC;
                    signal SCLK_from_the_spi_master : OUT STD_LOGIC;
                    signal SS_n_from_the_spi_master : OUT STD_LOGIC;

                 -- the_status_led_pio
                    signal out_port_from_the_status_led_pio : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);

                 -- the_sync_irq_from_pcp
                    signal in_port_to_the_sync_irq_from_pcp : IN STD_LOGIC;

                 -- the_tri_state_bridge_0_avalon_slave
                    signal addr_to_the_SRAM_0 : OUT STD_LOGIC_VECTOR (20 DOWNTO 0);
                    signal ben_to_the_SRAM_0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ncs_to_the_SRAM_0 : OUT STD_LOGIC;
                    signal rdn_to_the_SRAM_0 : OUT STD_LOGIC;
                    signal tri_state_bridge_0_data : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal wrn_to_the_SRAM_0 : OUT STD_LOGIC
                 );
end component niosII_openMac;

                signal MISO_to_the_spi_master :  STD_LOGIC;
                signal MOSI_from_the_spi_master :  STD_LOGIC;
                signal SCLK_from_the_spi_master :  STD_LOGIC;
                signal SS_n_from_the_spi_master :  STD_LOGIC;
                signal addr_to_the_SRAM_0 :  STD_LOGIC_VECTOR (20 DOWNTO 0);
                signal ap_clk :  STD_LOGIC;
                signal ap_clkSDRAM :  STD_LOGIC;
                signal ben_to_the_SRAM_0 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal clk :  STD_LOGIC;
                signal clk100Meg :  STD_LOGIC;
                signal clk25Meg :  STD_LOGIC;
                signal clk50Meg :  STD_LOGIC;
                signal clk_0 :  STD_LOGIC;
                signal clock_crossing_0_s1_endofpacket_from_sa :  STD_LOGIC;
                signal data0_to_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal dclk_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa :  STD_LOGIC;
                signal in_port_to_the_inport_ap :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal in_port_to_the_sync_irq_from_pcp :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal locked_from_the_altpll_0 :  STD_LOGIC;
                signal ncs_to_the_SRAM_0 :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_nativeaddress :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal out_port_from_the_outport_ap :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal out_port_from_the_status_led_pio :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal phasedone_from_the_altpll_0 :  STD_LOGIC;
                signal rdn_to_the_SRAM_0 :  STD_LOGIC;
                signal reset_n :  STD_LOGIC;
                signal sce_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal sdo_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal spi_master_spi_control_port_dataavailable_from_sa :  STD_LOGIC;
                signal spi_master_spi_control_port_readyfordata_from_sa :  STD_LOGIC;
                signal sysid_control_slave_clock :  STD_LOGIC;
                signal tri_state_bridge_0_data :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal wrn_to_the_SRAM_0 :  STD_LOGIC;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your component and signal declaration here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


begin

  --Set us up the Dut
  DUT : niosII_openMac
    port map(
      MOSI_from_the_spi_master => MOSI_from_the_spi_master,
      SCLK_from_the_spi_master => SCLK_from_the_spi_master,
      SS_n_from_the_spi_master => SS_n_from_the_spi_master,
      addr_to_the_SRAM_0 => addr_to_the_SRAM_0,
      ap_clk => ap_clk,
      ap_clkSDRAM => ap_clkSDRAM,
      ben_to_the_SRAM_0 => ben_to_the_SRAM_0,
      clk100Meg => clk100Meg,
      clk25Meg => clk25Meg,
      clk50Meg => clk50Meg,
      dclk_from_the_epcs_flash_controller_0 => dclk_from_the_epcs_flash_controller_0,
      locked_from_the_altpll_0 => locked_from_the_altpll_0,
      ncs_to_the_SRAM_0 => ncs_to_the_SRAM_0,
      out_port_from_the_outport_ap => out_port_from_the_outport_ap,
      out_port_from_the_status_led_pio => out_port_from_the_status_led_pio,
      phasedone_from_the_altpll_0 => phasedone_from_the_altpll_0,
      rdn_to_the_SRAM_0 => rdn_to_the_SRAM_0,
      sce_from_the_epcs_flash_controller_0 => sce_from_the_epcs_flash_controller_0,
      sdo_from_the_epcs_flash_controller_0 => sdo_from_the_epcs_flash_controller_0,
      tri_state_bridge_0_data => tri_state_bridge_0_data,
      wrn_to_the_SRAM_0 => wrn_to_the_SRAM_0,
      MISO_to_the_spi_master => MISO_to_the_spi_master,
      clk_0 => clk_0,
      data0_to_the_epcs_flash_controller_0 => data0_to_the_epcs_flash_controller_0,
      in_port_to_the_inport_ap => in_port_to_the_inport_ap,
      in_port_to_the_sync_irq_from_pcp => in_port_to_the_sync_irq_from_pcp,
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
