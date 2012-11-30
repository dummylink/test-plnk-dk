--megafunction wizard: %Altera SOPC Builder%
--GENERATION: STANDARD
--VERSION: WM1.0


--Legal Notice: (C)2012 Altera Corporation. All rights reserved.  Your
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
                 signal niosII_openMac_clock_4_out_address_to_slave : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_4_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_4_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_4_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal altpll_0_pll_slave_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal altpll_0_pll_slave_read : OUT STD_LOGIC;
                 signal altpll_0_pll_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal altpll_0_pll_slave_reset : OUT STD_LOGIC;
                 signal altpll_0_pll_slave_write : OUT STD_LOGIC;
                 signal altpll_0_pll_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_altpll_0_pll_slave_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_4_out_granted_altpll_0_pll_slave : OUT STD_LOGIC;
                 signal niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave : OUT STD_LOGIC;
                 signal niosII_openMac_clock_4_out_read_data_valid_altpll_0_pll_slave : OUT STD_LOGIC;
                 signal niosII_openMac_clock_4_out_requests_altpll_0_pll_slave : OUT STD_LOGIC
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
                signal internal_niosII_openMac_clock_4_out_granted_altpll_0_pll_slave :  STD_LOGIC;
                signal internal_niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave :  STD_LOGIC;
                signal internal_niosII_openMac_clock_4_out_requests_altpll_0_pll_slave :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_arbiterlock :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_arbiterlock2 :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_saved_grant_altpll_0_pll_slave :  STD_LOGIC;
                signal shifted_address_to_altpll_0_pll_slave_from_niosII_openMac_clock_4_out :  STD_LOGIC_VECTOR (3 DOWNTO 0);
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

  altpll_0_pll_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave);
  --assign altpll_0_pll_slave_readdata_from_sa = altpll_0_pll_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  altpll_0_pll_slave_readdata_from_sa <= altpll_0_pll_slave_readdata;
  internal_niosII_openMac_clock_4_out_requests_altpll_0_pll_slave <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_4_out_read OR niosII_openMac_clock_4_out_write)))))));
  --altpll_0_pll_slave_arb_share_counter set values, which is an e_mux
  altpll_0_pll_slave_arb_share_set_values <= std_logic'('1');
  --altpll_0_pll_slave_non_bursting_master_requests mux, which is an e_mux
  altpll_0_pll_slave_non_bursting_master_requests <= internal_niosII_openMac_clock_4_out_requests_altpll_0_pll_slave;
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

  --niosII_openMac_clock_4/out altpll_0/pll_slave arbiterlock, which is an e_assign
  niosII_openMac_clock_4_out_arbiterlock <= altpll_0_pll_slave_slavearbiterlockenable AND niosII_openMac_clock_4_out_continuerequest;
  --altpll_0_pll_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  altpll_0_pll_slave_slavearbiterlockenable2 <= altpll_0_pll_slave_arb_share_counter_next_value;
  --niosII_openMac_clock_4/out altpll_0/pll_slave arbiterlock2, which is an e_assign
  niosII_openMac_clock_4_out_arbiterlock2 <= altpll_0_pll_slave_slavearbiterlockenable2 AND niosII_openMac_clock_4_out_continuerequest;
  --altpll_0_pll_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  altpll_0_pll_slave_any_continuerequest <= std_logic'('1');
  --niosII_openMac_clock_4_out_continuerequest continued request, which is an e_assign
  niosII_openMac_clock_4_out_continuerequest <= std_logic'('1');
  internal_niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave <= internal_niosII_openMac_clock_4_out_requests_altpll_0_pll_slave;
  --altpll_0_pll_slave_writedata mux, which is an e_mux
  altpll_0_pll_slave_writedata <= niosII_openMac_clock_4_out_writedata;
  --master is always granted when requested
  internal_niosII_openMac_clock_4_out_granted_altpll_0_pll_slave <= internal_niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave;
  --niosII_openMac_clock_4/out saved-grant altpll_0/pll_slave, which is an e_assign
  niosII_openMac_clock_4_out_saved_grant_altpll_0_pll_slave <= internal_niosII_openMac_clock_4_out_requests_altpll_0_pll_slave;
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
  altpll_0_pll_slave_read <= internal_niosII_openMac_clock_4_out_granted_altpll_0_pll_slave AND niosII_openMac_clock_4_out_read;
  --altpll_0_pll_slave_write assignment, which is an e_mux
  altpll_0_pll_slave_write <= internal_niosII_openMac_clock_4_out_granted_altpll_0_pll_slave AND niosII_openMac_clock_4_out_write;
  shifted_address_to_altpll_0_pll_slave_from_niosII_openMac_clock_4_out <= niosII_openMac_clock_4_out_address_to_slave;
  --altpll_0_pll_slave_address mux, which is an e_mux
  altpll_0_pll_slave_address <= A_EXT (A_SRL(shifted_address_to_altpll_0_pll_slave_from_niosII_openMac_clock_4_out,std_logic_vector'("00000000000000000000000000000010")), 2);
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
  altpll_0_pll_slave_in_a_read_cycle <= internal_niosII_openMac_clock_4_out_granted_altpll_0_pll_slave AND niosII_openMac_clock_4_out_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= altpll_0_pll_slave_in_a_read_cycle;
  --altpll_0_pll_slave_waits_for_write in a cycle, which is an e_mux
  altpll_0_pll_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(altpll_0_pll_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --altpll_0_pll_slave_in_a_write_cycle assignment, which is an e_assign
  altpll_0_pll_slave_in_a_write_cycle <= internal_niosII_openMac_clock_4_out_granted_altpll_0_pll_slave AND niosII_openMac_clock_4_out_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= altpll_0_pll_slave_in_a_write_cycle;
  wait_for_altpll_0_pll_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  niosII_openMac_clock_4_out_granted_altpll_0_pll_slave <= internal_niosII_openMac_clock_4_out_granted_altpll_0_pll_slave;
  --vhdl renameroo for output signals
  niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave <= internal_niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave;
  --vhdl renameroo for output signals
  niosII_openMac_clock_4_out_requests_altpll_0_pll_slave <= internal_niosII_openMac_clock_4_out_requests_altpll_0_pll_slave;
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
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ap_cpu_data_master_debugaccess : IN STD_LOGIC;
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC;
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
                signal ap_cpu_jtag_debug_module_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_jtag_debug_module_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_jtag_debug_module_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
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
                signal shifted_address_to_ap_cpu_jtag_debug_module_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal shifted_address_to_ap_cpu_jtag_debug_module_from_ap_cpu_instruction_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
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
  internal_ap_cpu_data_master_requests_ap_cpu_jtag_debug_module <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0000000000000001100000000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --ap_cpu_jtag_debug_module_arb_share_counter set values, which is an e_mux
  ap_cpu_jtag_debug_module_arb_share_set_values <= std_logic_vector'("01");
  --ap_cpu_jtag_debug_module_non_bursting_master_requests mux, which is an e_mux
  ap_cpu_jtag_debug_module_non_bursting_master_requests <= ((internal_ap_cpu_data_master_requests_ap_cpu_jtag_debug_module OR internal_ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module) OR internal_ap_cpu_data_master_requests_ap_cpu_jtag_debug_module) OR internal_ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module;
  --ap_cpu_jtag_debug_module_any_bursting_master_saved_grant mux, which is an e_mux
  ap_cpu_jtag_debug_module_any_bursting_master_saved_grant <= std_logic'('0');
  --ap_cpu_jtag_debug_module_arb_share_counter_next_value assignment, which is an e_assign
  ap_cpu_jtag_debug_module_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(ap_cpu_jtag_debug_module_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (ap_cpu_jtag_debug_module_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(ap_cpu_jtag_debug_module_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (ap_cpu_jtag_debug_module_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
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
      ap_cpu_jtag_debug_module_arb_share_counter <= std_logic_vector'("00");
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
        ap_cpu_jtag_debug_module_slavearbiterlockenable <= or_reduce(ap_cpu_jtag_debug_module_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --ap_cpu/data_master ap_cpu/jtag_debug_module arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= ap_cpu_jtag_debug_module_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --ap_cpu_jtag_debug_module_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  ap_cpu_jtag_debug_module_slavearbiterlockenable2 <= or_reduce(ap_cpu_jtag_debug_module_arb_share_counter_next_value);
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
  internal_ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module <= ((to_std_logic(((Std_Logic_Vector'(ap_cpu_instruction_master_address_to_slave(27 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0000000000000001100000000000")))) AND (ap_cpu_instruction_master_read))) AND ap_cpu_instruction_master_read;
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
  internal_ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module <= internal_ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module AND NOT ((((ap_cpu_instruction_master_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000")))))) OR ap_cpu_data_master_arbiterlock));
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
  ap_cpu_jtag_debug_module_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_ap_cpu_jtag_debug_module)) = '1'), (A_SRL(shifted_address_to_ap_cpu_jtag_debug_module_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_ap_cpu_jtag_debug_module_from_ap_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 9);
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

entity ap_cpu_data_master_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_data_master_address : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ap_cpu_data_master_granted_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_async_irq_from_pcp_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_benchmark_ap_pio_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_inport_ap_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_niosII_openMac_clock_1_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_niosII_openMac_clock_2_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_niosII_openMac_clock_3_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_niosII_openMac_clock_4_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_outport_ap_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_granted_system_timer_ap_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_inport_ap_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_outport_ap_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_system_timer_ap_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_async_irq_from_pcp_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_benchmark_ap_pio_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_inport_ap_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_2_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_3_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_4_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_outport_ap_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_system_timer_ap_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_async_irq_from_pcp_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_benchmark_ap_pio_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_inport_ap_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_niosII_openMac_clock_1_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_niosII_openMac_clock_2_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_niosII_openMac_clock_3_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_niosII_openMac_clock_4_in : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_outport_ap_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                 signal ap_cpu_data_master_requests_system_timer_ap_s1 : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal async_irq_from_pcp_s1_irq_from_sa : IN STD_LOGIC;
                 signal async_irq_from_pcp_s1_readdata_from_sa : IN STD_LOGIC;
                 signal benchmark_ap_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal d1_ap_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_async_irq_from_pcp_s1_end_xfer : IN STD_LOGIC;
                 signal d1_benchmark_ap_pio_s1_end_xfer : IN STD_LOGIC;
                 signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : IN STD_LOGIC;
                 signal d1_inport_ap_s1_end_xfer : IN STD_LOGIC;
                 signal d1_jtag_uart_1_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                 signal d1_niosII_openMac_clock_1_in_end_xfer : IN STD_LOGIC;
                 signal d1_niosII_openMac_clock_2_in_end_xfer : IN STD_LOGIC;
                 signal d1_niosII_openMac_clock_3_in_end_xfer : IN STD_LOGIC;
                 signal d1_niosII_openMac_clock_4_in_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_memory2_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_outport_ap_s1_end_xfer : IN STD_LOGIC;
                 signal d1_sync_irq_from_pcp_s1_end_xfer : IN STD_LOGIC;
                 signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                 signal d1_system_timer_ap_s1_end_xfer : IN STD_LOGIC;
                 signal d1_tri_state_bridge_0_avalon_slave_end_xfer : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal incoming_data_to_and_from_the_par_pdi_master_0 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal inport_ap_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal jtag_uart_1_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal niosII_openMac_clock_2_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_2_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal niosII_openMac_clock_3_in_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_3_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal niosII_openMac_clock_4_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_4_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal onchip_memory2_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal outport_ap_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0 : IN STD_LOGIC;
                 signal par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_1 : IN STD_LOGIC;
                 signal registered_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal registered_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_irq_from_pcp_s1_irq_from_sa : IN STD_LOGIC;
                 signal sync_irq_from_pcp_s1_readdata_from_sa : IN STD_LOGIC;
                 signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal system_timer_ap_s1_irq_from_sa : IN STD_LOGIC;
                 signal system_timer_ap_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal ap_cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ap_cpu_data_master_dbs_write_16 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ap_cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_data_master_no_byte_enables_and_last_term : OUT STD_LOGIC;
                 signal ap_cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_data_master_waitrequest : OUT STD_LOGIC
              );
end entity ap_cpu_data_master_arbitrator;


architecture europa of ap_cpu_data_master_arbitrator is
                signal ap_cpu_data_master_dbs_increment :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_data_master_run :  STD_LOGIC;
                signal dbs_16_reg_segment_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal dbs_count_enable :  STD_LOGIC;
                signal dbs_counter_overflow :  STD_LOGIC;
                signal internal_ap_cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal internal_ap_cpu_data_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_ap_cpu_data_master_no_byte_enables_and_last_term :  STD_LOGIC;
                signal internal_ap_cpu_data_master_waitrequest :  STD_LOGIC;
                signal last_dbs_term_and_run :  STD_LOGIC;
                signal next_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_dbs_16_reg_segment_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal p1_registered_ap_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal pre_dbs_count_enable :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal r_2 :  STD_LOGIC;
                signal r_3 :  STD_LOGIC;
                signal registered_ap_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module OR NOT ap_cpu_data_master_requests_ap_cpu_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_granted_ap_cpu_jtag_debug_module OR NOT ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module OR NOT ap_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module OR NOT ap_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1 OR NOT ap_cpu_data_master_requests_async_irq_from_pcp_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1 OR NOT ap_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1 OR NOT ap_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1 OR NOT ap_cpu_data_master_requests_benchmark_ap_pio_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1 OR NOT ap_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1 OR NOT ap_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port OR NOT ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_inport_ap_s1 OR NOT ap_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_read)))))))));
  --cascaded wait assignment, which is an e_assign
  ap_cpu_data_master_run <= ((r_0 AND r_1) AND r_2) AND r_3;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((((((((((((((((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_inport_ap_s1 OR NOT ap_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_write))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave OR NOT ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in OR NOT ap_cpu_data_master_requests_niosII_openMac_clock_1_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_1_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_1_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in OR NOT ap_cpu_data_master_requests_niosII_openMac_clock_2_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_2_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_2_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in OR NOT ap_cpu_data_master_requests_niosII_openMac_clock_3_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_3_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_3_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in OR NOT ap_cpu_data_master_requests_niosII_openMac_clock_4_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_4_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))));
  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic(((((((((((((((((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_4_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 OR registered_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1) OR NOT ap_cpu_data_master_requests_onchip_memory2_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_granted_onchip_memory2_0_s1 OR NOT ap_cpu_data_master_qualified_request_onchip_memory2_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 OR NOT ap_cpu_data_master_read) OR ((registered_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 AND ap_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 OR NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_read OR ap_cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_outport_ap_s1 OR NOT ap_cpu_data_master_requests_outport_ap_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_outport_ap_s1 OR NOT ap_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_outport_ap_s1 OR NOT ap_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1 OR NOT ap_cpu_data_master_requests_sync_irq_from_pcp_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1 OR NOT ap_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1 OR NOT ap_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_sysid_control_slave OR NOT ap_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_sysid_control_slave OR NOT ap_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_qualified_request_system_timer_ap_s1 OR NOT ap_cpu_data_master_requests_system_timer_ap_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_system_timer_ap_s1 OR NOT ap_cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_read)))))))));
  --r_3 master_run cascaded wait assignment, which is an e_assign
  r_3 <= Vector_To_Std_Logic((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_system_timer_ap_s1 OR NOT ap_cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_write))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((((ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave OR ((registered_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave AND internal_ap_cpu_data_master_dbs_address(1)))) OR (((ap_cpu_data_master_write AND NOT(or_reduce(ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave))) AND internal_ap_cpu_data_master_dbs_address(1)))) OR NOT ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave OR NOT ap_cpu_data_master_read) OR (((registered_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave AND (internal_ap_cpu_data_master_dbs_address(1))) AND ap_cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave OR NOT ap_cpu_data_master_write)))) OR ((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_1)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((internal_ap_cpu_data_master_dbs_address(1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_write)))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_ap_cpu_data_master_address_to_slave <= ap_cpu_data_master_address(27 DOWNTO 0);
  --ap_cpu/data_master readdata mux, which is an e_mux
  ap_cpu_data_master_readdata <= ((((((((((((((((A_REP(NOT ap_cpu_data_master_requests_ap_cpu_jtag_debug_module, 32) OR ap_cpu_jtag_debug_module_readdata_from_sa)) AND ((A_REP(NOT ap_cpu_data_master_requests_async_irq_from_pcp_s1, 32) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(async_irq_from_pcp_s1_readdata_from_sa)))))) AND ((A_REP(NOT ap_cpu_data_master_requests_benchmark_ap_pio_s1, 32) OR (std_logic_vector'("000000000000000000000000") & (benchmark_ap_pio_s1_readdata_from_sa))))) AND ((A_REP(NOT ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port, 32) OR epcs_flash_controller_0_epcs_control_port_readdata_from_sa))) AND ((A_REP(NOT ap_cpu_data_master_requests_inport_ap_s1, 32) OR (std_logic_vector'("000000000000000000000000") & (inport_ap_s1_readdata_from_sa))))) AND ((A_REP(NOT ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave, 32) OR registered_ap_cpu_data_master_readdata))) AND ((A_REP(NOT ap_cpu_data_master_requests_niosII_openMac_clock_1_in, 32) OR registered_ap_cpu_data_master_readdata))) AND ((A_REP(NOT ap_cpu_data_master_requests_niosII_openMac_clock_2_in, 32) OR registered_ap_cpu_data_master_readdata))) AND ((A_REP(NOT ap_cpu_data_master_requests_niosII_openMac_clock_3_in, 32) OR registered_ap_cpu_data_master_readdata))) AND ((A_REP(NOT ap_cpu_data_master_requests_niosII_openMac_clock_4_in, 32) OR registered_ap_cpu_data_master_readdata))) AND ((A_REP(NOT ap_cpu_data_master_requests_onchip_memory2_0_s1, 32) OR onchip_memory2_0_s1_readdata_from_sa))) AND ((A_REP(NOT ap_cpu_data_master_requests_outport_ap_s1, 32) OR (std_logic_vector'("00000000") & (outport_ap_s1_readdata_from_sa))))) AND ((A_REP(NOT ap_cpu_data_master_requests_sync_irq_from_pcp_s1, 32) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sync_irq_from_pcp_s1_readdata_from_sa)))))) AND ((A_REP(NOT ap_cpu_data_master_requests_sysid_control_slave, 32) OR sysid_control_slave_readdata_from_sa))) AND ((A_REP(NOT ap_cpu_data_master_requests_system_timer_ap_s1, 32) OR (std_logic_vector'("0000000000000000") & (system_timer_ap_s1_readdata_from_sa))))) AND ((A_REP(NOT ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave, 32) OR Std_Logic_Vector'(incoming_data_to_and_from_the_par_pdi_master_0(15 DOWNTO 0) & dbs_16_reg_segment_0)));
  --actual waitrequest port, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_ap_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      internal_ap_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT (A_WE_StdLogicVector((std_logic'((NOT ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_data_master_run AND internal_ap_cpu_data_master_waitrequest))))))));
    end if;

  end process;

  --irq assign, which is an e_assign
  ap_cpu_data_master_irq <= Std_Logic_Vector'(A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(jtag_uart_1_avalon_jtag_slave_irq_from_sa) & A_ToStdLogicVector(system_timer_ap_s1_irq_from_sa) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(async_irq_from_pcp_s1_irq_from_sa) & A_ToStdLogicVector(sync_irq_from_pcp_s1_irq_from_sa) & A_ToStdLogicVector(std_logic'('0')));
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
  p1_registered_ap_cpu_data_master_readdata <= (((((A_REP(NOT ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave, 32) OR jtag_uart_1_avalon_jtag_slave_readdata_from_sa)) AND ((A_REP(NOT ap_cpu_data_master_requests_niosII_openMac_clock_1_in, 32) OR niosII_openMac_clock_1_in_readdata_from_sa))) AND ((A_REP(NOT ap_cpu_data_master_requests_niosII_openMac_clock_2_in, 32) OR niosII_openMac_clock_2_in_readdata_from_sa))) AND ((A_REP(NOT ap_cpu_data_master_requests_niosII_openMac_clock_3_in, 32) OR (std_logic_vector'("000000000000000000000000") & (niosII_openMac_clock_3_in_readdata_from_sa))))) AND ((A_REP(NOT ap_cpu_data_master_requests_niosII_openMac_clock_4_in, 32) OR niosII_openMac_clock_4_in_readdata_from_sa));
  --no_byte_enables_and_last_term, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_ap_cpu_data_master_no_byte_enables_and_last_term <= std_logic'('0');
    elsif clk'event and clk = '1' then
      internal_ap_cpu_data_master_no_byte_enables_and_last_term <= last_dbs_term_and_run;
    end if;

  end process;

  --compute the last dbs term, which is an e_mux
  last_dbs_term_and_run <= (to_std_logic(((internal_ap_cpu_data_master_dbs_address = std_logic_vector'("10")))) AND ap_cpu_data_master_write) AND NOT(or_reduce(ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave));
  --pre dbs count enable, which is an e_mux
  pre_dbs_count_enable <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((((((NOT internal_ap_cpu_data_master_no_byte_enables_and_last_term) AND ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave) AND ap_cpu_data_master_write) AND NOT(or_reduce(ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave)))) OR ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave)))) OR (((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave AND ap_cpu_data_master_write)))) AND std_logic_vector'("00000000000000000000000000000001")) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0 AND NOT d1_tri_state_bridge_0_avalon_slave_end_xfer)))))))));
  --input to dbs-16 stored 0, which is an e_mux
  p1_dbs_16_reg_segment_0 <= incoming_data_to_and_from_the_par_pdi_master_0;
  --dbs register for dbs-16 segment 0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      dbs_16_reg_segment_0 <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      if std_logic'((dbs_count_enable AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((internal_ap_cpu_data_master_dbs_address(1))))) = std_logic_vector'("00000000000000000000000000000000")))))) = '1' then 
        dbs_16_reg_segment_0 <= p1_dbs_16_reg_segment_0;
      end if;
    end if;

  end process;

  --mux write dbs 1, which is an e_mux
  ap_cpu_data_master_dbs_write_16 <= A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_dbs_address(1))) = '1'), ap_cpu_data_master_writedata(31 DOWNTO 16), ap_cpu_data_master_writedata(15 DOWNTO 0));
  --dbs count increment, which is an e_mux
  ap_cpu_data_master_dbs_increment <= A_EXT (A_WE_StdLogicVector((std_logic'((ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave)) = '1'), std_logic_vector'("00000000000000000000000000000010"), std_logic_vector'("00000000000000000000000000000000")), 2);
  --dbs counter overflow, which is an e_assign
  dbs_counter_overflow <= internal_ap_cpu_data_master_dbs_address(1) AND NOT((next_dbs_address(1)));
  --next master address, which is an e_assign
  next_dbs_address <= A_EXT (((std_logic_vector'("0") & (internal_ap_cpu_data_master_dbs_address)) + (std_logic_vector'("0") & (ap_cpu_data_master_dbs_increment))), 2);
  --dbs count enable, which is an e_mux
  dbs_count_enable <= pre_dbs_count_enable;
  --dbs counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_ap_cpu_data_master_dbs_address <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(dbs_count_enable) = '1' then 
        internal_ap_cpu_data_master_dbs_address <= next_dbs_address;
      end if;
    end if;

  end process;

  --vhdl renameroo for output signals
  ap_cpu_data_master_address_to_slave <= internal_ap_cpu_data_master_address_to_slave;
  --vhdl renameroo for output signals
  ap_cpu_data_master_dbs_address <= internal_ap_cpu_data_master_dbs_address;
  --vhdl renameroo for output signals
  ap_cpu_data_master_no_byte_enables_and_last_term <= internal_ap_cpu_data_master_no_byte_enables_and_last_term;
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
                 signal ap_cpu_instruction_master_address : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_granted_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_niosII_openMac_clock_0_in : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal ap_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal d1_ap_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : IN STD_LOGIC;
                 signal d1_niosII_openMac_clock_0_in_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_memory2_0_s1_end_xfer : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_waitrequest_from_sa : IN STD_LOGIC;
                 signal onchip_memory2_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_instruction_master_latency_counter : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_instruction_master_readdatavalid : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_waitrequest : OUT STD_LOGIC
              );
end entity ap_cpu_instruction_master_arbitrator;


architecture europa of ap_cpu_instruction_master_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal ap_cpu_instruction_master_address_last_time :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal ap_cpu_instruction_master_is_granted_some_slave :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_but_no_slave_selected :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_last_time :  STD_LOGIC;
                signal ap_cpu_instruction_master_run :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal internal_ap_cpu_instruction_master_latency_counter :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_waitrequest :  STD_LOGIC;
                signal latency_load_value :  STD_LOGIC;
                signal p1_ap_cpu_instruction_master_latency_counter :  STD_LOGIC;
                signal pre_flush_ap_cpu_instruction_master_readdatavalid :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal r_2 :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module OR NOT ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module OR NOT ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module OR NOT ap_cpu_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_ap_cpu_jtag_debug_module_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_read)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port OR NOT ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port OR NOT (ap_cpu_instruction_master_read))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_epcs_flash_controller_0_epcs_control_port_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((ap_cpu_instruction_master_read))))))))));
  --cascaded wait assignment, which is an e_assign
  ap_cpu_instruction_master_run <= (r_0 AND r_1) AND r_2;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in OR NOT ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in OR NOT (ap_cpu_instruction_master_read))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT niosII_openMac_clock_0_in_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((ap_cpu_instruction_master_read))))))))));
  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1 OR NOT ap_cpu_instruction_master_requests_onchip_memory2_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((ap_cpu_instruction_master_granted_onchip_memory2_0_s1 OR NOT ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1 OR NOT ap_cpu_instruction_master_read)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_read)))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_ap_cpu_instruction_master_address_to_slave <= ap_cpu_instruction_master_address(27 DOWNTO 0);
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
  ap_cpu_instruction_master_is_granted_some_slave <= ((ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module OR ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port) OR ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in) OR ap_cpu_instruction_master_granted_onchip_memory2_0_s1;
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_ap_cpu_instruction_master_readdatavalid <= ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1;
  --latent slave read data valid which is not flushed, which is an e_mux
  ap_cpu_instruction_master_readdatavalid <= (((((((((ap_cpu_instruction_master_read_but_no_slave_selected OR pre_flush_ap_cpu_instruction_master_readdatavalid) OR ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module) OR ap_cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_ap_cpu_instruction_master_readdatavalid) OR ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port) OR ap_cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_ap_cpu_instruction_master_readdatavalid) OR ap_cpu_instruction_master_read_data_valid_niosII_openMac_clock_0_in) OR ap_cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_ap_cpu_instruction_master_readdatavalid;
  --ap_cpu/instruction_master readdata mux, which is an e_mux
  ap_cpu_instruction_master_readdata <= ((((A_REP(NOT ((ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module AND ap_cpu_instruction_master_read)) , 32) OR ap_cpu_jtag_debug_module_readdata_from_sa)) AND ((A_REP(NOT ((ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port AND ap_cpu_instruction_master_read)) , 32) OR epcs_flash_controller_0_epcs_control_port_readdata_from_sa))) AND ((A_REP(NOT ((ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in AND ap_cpu_instruction_master_read)) , 32) OR niosII_openMac_clock_0_in_readdata_from_sa))) AND ((A_REP(NOT ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1, 32) OR onchip_memory2_0_s1_readdata_from_sa));
  --actual waitrequest port, which is an e_assign
  internal_ap_cpu_instruction_master_waitrequest <= NOT ap_cpu_instruction_master_run;
  --latent max counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_ap_cpu_instruction_master_latency_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      internal_ap_cpu_instruction_master_latency_counter <= p1_ap_cpu_instruction_master_latency_counter;
    end if;

  end process;

  --latency counter load mux, which is an e_mux
  p1_ap_cpu_instruction_master_latency_counter <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(((ap_cpu_instruction_master_run AND ap_cpu_instruction_master_read))) = '1'), (std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(latency_load_value))), A_WE_StdLogicVector((std_logic'((internal_ap_cpu_instruction_master_latency_counter)) = '1'), ((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(internal_ap_cpu_instruction_master_latency_counter))) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))));
  --read latency load values, which is an e_mux
  latency_load_value <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_requests_onchip_memory2_0_s1))) AND std_logic_vector'("00000000000000000000000000000001")));
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
        ap_cpu_instruction_master_address_last_time <= std_logic_vector'("0000000000000000000000000000");
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

entity async_irq_from_pcp_s1_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal async_irq_from_pcp_s1_irq : IN STD_LOGIC;
                 signal async_irq_from_pcp_s1_readdata : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_async_irq_from_pcp_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_async_irq_from_pcp_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_async_irq_from_pcp_s1 : OUT STD_LOGIC;
                 signal async_irq_from_pcp_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal async_irq_from_pcp_s1_chipselect : OUT STD_LOGIC;
                 signal async_irq_from_pcp_s1_irq_from_sa : OUT STD_LOGIC;
                 signal async_irq_from_pcp_s1_readdata_from_sa : OUT STD_LOGIC;
                 signal async_irq_from_pcp_s1_reset_n : OUT STD_LOGIC;
                 signal async_irq_from_pcp_s1_write_n : OUT STD_LOGIC;
                 signal async_irq_from_pcp_s1_writedata : OUT STD_LOGIC;
                 signal d1_async_irq_from_pcp_s1_end_xfer : OUT STD_LOGIC
              );
end entity async_irq_from_pcp_s1_arbitrator;


architecture europa of async_irq_from_pcp_s1_arbitrator is
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_async_irq_from_pcp_s1 :  STD_LOGIC;
                signal async_irq_from_pcp_s1_allgrants :  STD_LOGIC;
                signal async_irq_from_pcp_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal async_irq_from_pcp_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal async_irq_from_pcp_s1_any_continuerequest :  STD_LOGIC;
                signal async_irq_from_pcp_s1_arb_counter_enable :  STD_LOGIC;
                signal async_irq_from_pcp_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal async_irq_from_pcp_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal async_irq_from_pcp_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal async_irq_from_pcp_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal async_irq_from_pcp_s1_begins_xfer :  STD_LOGIC;
                signal async_irq_from_pcp_s1_end_xfer :  STD_LOGIC;
                signal async_irq_from_pcp_s1_firsttransfer :  STD_LOGIC;
                signal async_irq_from_pcp_s1_grant_vector :  STD_LOGIC;
                signal async_irq_from_pcp_s1_in_a_read_cycle :  STD_LOGIC;
                signal async_irq_from_pcp_s1_in_a_write_cycle :  STD_LOGIC;
                signal async_irq_from_pcp_s1_master_qreq_vector :  STD_LOGIC;
                signal async_irq_from_pcp_s1_non_bursting_master_requests :  STD_LOGIC;
                signal async_irq_from_pcp_s1_reg_firsttransfer :  STD_LOGIC;
                signal async_irq_from_pcp_s1_slavearbiterlockenable :  STD_LOGIC;
                signal async_irq_from_pcp_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal async_irq_from_pcp_s1_unreg_firsttransfer :  STD_LOGIC;
                signal async_irq_from_pcp_s1_waits_for_read :  STD_LOGIC;
                signal async_irq_from_pcp_s1_waits_for_write :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_async_irq_from_pcp_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_async_irq_from_pcp_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_async_irq_from_pcp_s1 :  STD_LOGIC;
                signal shifted_address_to_async_irq_from_pcp_s1_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal wait_for_async_irq_from_pcp_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT async_irq_from_pcp_s1_end_xfer;
    end if;

  end process;

  async_irq_from_pcp_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1);
  --assign async_irq_from_pcp_s1_readdata_from_sa = async_irq_from_pcp_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  async_irq_from_pcp_s1_readdata_from_sa <= async_irq_from_pcp_s1_readdata;
  internal_ap_cpu_data_master_requests_async_irq_from_pcp_s1 <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000000100110010000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --async_irq_from_pcp_s1_arb_share_counter set values, which is an e_mux
  async_irq_from_pcp_s1_arb_share_set_values <= std_logic_vector'("01");
  --async_irq_from_pcp_s1_non_bursting_master_requests mux, which is an e_mux
  async_irq_from_pcp_s1_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_async_irq_from_pcp_s1;
  --async_irq_from_pcp_s1_any_bursting_master_saved_grant mux, which is an e_mux
  async_irq_from_pcp_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --async_irq_from_pcp_s1_arb_share_counter_next_value assignment, which is an e_assign
  async_irq_from_pcp_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(async_irq_from_pcp_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (async_irq_from_pcp_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(async_irq_from_pcp_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (async_irq_from_pcp_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --async_irq_from_pcp_s1_allgrants all slave grants, which is an e_mux
  async_irq_from_pcp_s1_allgrants <= async_irq_from_pcp_s1_grant_vector;
  --async_irq_from_pcp_s1_end_xfer assignment, which is an e_assign
  async_irq_from_pcp_s1_end_xfer <= NOT ((async_irq_from_pcp_s1_waits_for_read OR async_irq_from_pcp_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_async_irq_from_pcp_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_async_irq_from_pcp_s1 <= async_irq_from_pcp_s1_end_xfer AND (((NOT async_irq_from_pcp_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --async_irq_from_pcp_s1_arb_share_counter arbitration counter enable, which is an e_assign
  async_irq_from_pcp_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_async_irq_from_pcp_s1 AND async_irq_from_pcp_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_async_irq_from_pcp_s1 AND NOT async_irq_from_pcp_s1_non_bursting_master_requests));
  --async_irq_from_pcp_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      async_irq_from_pcp_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(async_irq_from_pcp_s1_arb_counter_enable) = '1' then 
        async_irq_from_pcp_s1_arb_share_counter <= async_irq_from_pcp_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --async_irq_from_pcp_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      async_irq_from_pcp_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((async_irq_from_pcp_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_async_irq_from_pcp_s1)) OR ((end_xfer_arb_share_counter_term_async_irq_from_pcp_s1 AND NOT async_irq_from_pcp_s1_non_bursting_master_requests)))) = '1' then 
        async_irq_from_pcp_s1_slavearbiterlockenable <= or_reduce(async_irq_from_pcp_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --ap_cpu/data_master async_irq_from_pcp/s1 arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= async_irq_from_pcp_s1_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --async_irq_from_pcp_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  async_irq_from_pcp_s1_slavearbiterlockenable2 <= or_reduce(async_irq_from_pcp_s1_arb_share_counter_next_value);
  --ap_cpu/data_master async_irq_from_pcp/s1 arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= async_irq_from_pcp_s1_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --async_irq_from_pcp_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  async_irq_from_pcp_s1_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1 <= internal_ap_cpu_data_master_requests_async_irq_from_pcp_s1 AND NOT (((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write));
  --async_irq_from_pcp_s1_writedata mux, which is an e_mux
  async_irq_from_pcp_s1_writedata <= ap_cpu_data_master_writedata(0);
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_async_irq_from_pcp_s1 <= internal_ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1;
  --ap_cpu/data_master saved-grant async_irq_from_pcp/s1, which is an e_assign
  ap_cpu_data_master_saved_grant_async_irq_from_pcp_s1 <= internal_ap_cpu_data_master_requests_async_irq_from_pcp_s1;
  --allow new arb cycle for async_irq_from_pcp/s1, which is an e_assign
  async_irq_from_pcp_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  async_irq_from_pcp_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  async_irq_from_pcp_s1_master_qreq_vector <= std_logic'('1');
  --async_irq_from_pcp_s1_reset_n assignment, which is an e_assign
  async_irq_from_pcp_s1_reset_n <= reset_n;
  async_irq_from_pcp_s1_chipselect <= internal_ap_cpu_data_master_granted_async_irq_from_pcp_s1;
  --async_irq_from_pcp_s1_firsttransfer first transaction, which is an e_assign
  async_irq_from_pcp_s1_firsttransfer <= A_WE_StdLogic((std_logic'(async_irq_from_pcp_s1_begins_xfer) = '1'), async_irq_from_pcp_s1_unreg_firsttransfer, async_irq_from_pcp_s1_reg_firsttransfer);
  --async_irq_from_pcp_s1_unreg_firsttransfer first transaction, which is an e_assign
  async_irq_from_pcp_s1_unreg_firsttransfer <= NOT ((async_irq_from_pcp_s1_slavearbiterlockenable AND async_irq_from_pcp_s1_any_continuerequest));
  --async_irq_from_pcp_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      async_irq_from_pcp_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(async_irq_from_pcp_s1_begins_xfer) = '1' then 
        async_irq_from_pcp_s1_reg_firsttransfer <= async_irq_from_pcp_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --async_irq_from_pcp_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  async_irq_from_pcp_s1_beginbursttransfer_internal <= async_irq_from_pcp_s1_begins_xfer;
  --~async_irq_from_pcp_s1_write_n assignment, which is an e_mux
  async_irq_from_pcp_s1_write_n <= NOT ((internal_ap_cpu_data_master_granted_async_irq_from_pcp_s1 AND ap_cpu_data_master_write));
  shifted_address_to_async_irq_from_pcp_s1_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --async_irq_from_pcp_s1_address mux, which is an e_mux
  async_irq_from_pcp_s1_address <= A_EXT (A_SRL(shifted_address_to_async_irq_from_pcp_s1_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_async_irq_from_pcp_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_async_irq_from_pcp_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_async_irq_from_pcp_s1_end_xfer <= async_irq_from_pcp_s1_end_xfer;
    end if;

  end process;

  --async_irq_from_pcp_s1_waits_for_read in a cycle, which is an e_mux
  async_irq_from_pcp_s1_waits_for_read <= async_irq_from_pcp_s1_in_a_read_cycle AND async_irq_from_pcp_s1_begins_xfer;
  --async_irq_from_pcp_s1_in_a_read_cycle assignment, which is an e_assign
  async_irq_from_pcp_s1_in_a_read_cycle <= internal_ap_cpu_data_master_granted_async_irq_from_pcp_s1 AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= async_irq_from_pcp_s1_in_a_read_cycle;
  --async_irq_from_pcp_s1_waits_for_write in a cycle, which is an e_mux
  async_irq_from_pcp_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(async_irq_from_pcp_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --async_irq_from_pcp_s1_in_a_write_cycle assignment, which is an e_assign
  async_irq_from_pcp_s1_in_a_write_cycle <= internal_ap_cpu_data_master_granted_async_irq_from_pcp_s1 AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= async_irq_from_pcp_s1_in_a_write_cycle;
  wait_for_async_irq_from_pcp_s1_counter <= std_logic'('0');
  --assign async_irq_from_pcp_s1_irq_from_sa = async_irq_from_pcp_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  async_irq_from_pcp_s1_irq_from_sa <= async_irq_from_pcp_s1_irq;
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_async_irq_from_pcp_s1 <= internal_ap_cpu_data_master_granted_async_irq_from_pcp_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1 <= internal_ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_async_irq_from_pcp_s1 <= internal_ap_cpu_data_master_requests_async_irq_from_pcp_s1;
--synthesis translate_off
    --async_irq_from_pcp/s1 enable non-zero assertions, which is an e_register
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

entity benchmark_ap_pio_s1_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal benchmark_ap_pio_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_benchmark_ap_pio_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_benchmark_ap_pio_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_benchmark_ap_pio_s1 : OUT STD_LOGIC;
                 signal benchmark_ap_pio_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal benchmark_ap_pio_s1_chipselect : OUT STD_LOGIC;
                 signal benchmark_ap_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal benchmark_ap_pio_s1_reset_n : OUT STD_LOGIC;
                 signal benchmark_ap_pio_s1_write_n : OUT STD_LOGIC;
                 signal benchmark_ap_pio_s1_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal d1_benchmark_ap_pio_s1_end_xfer : OUT STD_LOGIC
              );
end entity benchmark_ap_pio_s1_arbitrator;


architecture europa of benchmark_ap_pio_s1_arbitrator is
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_benchmark_ap_pio_s1 :  STD_LOGIC;
                signal benchmark_ap_pio_s1_allgrants :  STD_LOGIC;
                signal benchmark_ap_pio_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal benchmark_ap_pio_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal benchmark_ap_pio_s1_any_continuerequest :  STD_LOGIC;
                signal benchmark_ap_pio_s1_arb_counter_enable :  STD_LOGIC;
                signal benchmark_ap_pio_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal benchmark_ap_pio_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal benchmark_ap_pio_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal benchmark_ap_pio_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal benchmark_ap_pio_s1_begins_xfer :  STD_LOGIC;
                signal benchmark_ap_pio_s1_end_xfer :  STD_LOGIC;
                signal benchmark_ap_pio_s1_firsttransfer :  STD_LOGIC;
                signal benchmark_ap_pio_s1_grant_vector :  STD_LOGIC;
                signal benchmark_ap_pio_s1_in_a_read_cycle :  STD_LOGIC;
                signal benchmark_ap_pio_s1_in_a_write_cycle :  STD_LOGIC;
                signal benchmark_ap_pio_s1_master_qreq_vector :  STD_LOGIC;
                signal benchmark_ap_pio_s1_non_bursting_master_requests :  STD_LOGIC;
                signal benchmark_ap_pio_s1_pretend_byte_enable :  STD_LOGIC;
                signal benchmark_ap_pio_s1_reg_firsttransfer :  STD_LOGIC;
                signal benchmark_ap_pio_s1_slavearbiterlockenable :  STD_LOGIC;
                signal benchmark_ap_pio_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal benchmark_ap_pio_s1_unreg_firsttransfer :  STD_LOGIC;
                signal benchmark_ap_pio_s1_waits_for_read :  STD_LOGIC;
                signal benchmark_ap_pio_s1_waits_for_write :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_benchmark_ap_pio_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_benchmark_ap_pio_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_benchmark_ap_pio_s1 :  STD_LOGIC;
                signal shifted_address_to_benchmark_ap_pio_s1_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal wait_for_benchmark_ap_pio_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT benchmark_ap_pio_s1_end_xfer;
    end if;

  end process;

  benchmark_ap_pio_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1);
  --assign benchmark_ap_pio_s1_readdata_from_sa = benchmark_ap_pio_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  benchmark_ap_pio_s1_readdata_from_sa <= benchmark_ap_pio_s1_readdata;
  internal_ap_cpu_data_master_requests_benchmark_ap_pio_s1 <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("0000000000000000100100100000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --benchmark_ap_pio_s1_arb_share_counter set values, which is an e_mux
  benchmark_ap_pio_s1_arb_share_set_values <= std_logic_vector'("01");
  --benchmark_ap_pio_s1_non_bursting_master_requests mux, which is an e_mux
  benchmark_ap_pio_s1_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_benchmark_ap_pio_s1;
  --benchmark_ap_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  benchmark_ap_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --benchmark_ap_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  benchmark_ap_pio_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(benchmark_ap_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (benchmark_ap_pio_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(benchmark_ap_pio_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (benchmark_ap_pio_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --benchmark_ap_pio_s1_allgrants all slave grants, which is an e_mux
  benchmark_ap_pio_s1_allgrants <= benchmark_ap_pio_s1_grant_vector;
  --benchmark_ap_pio_s1_end_xfer assignment, which is an e_assign
  benchmark_ap_pio_s1_end_xfer <= NOT ((benchmark_ap_pio_s1_waits_for_read OR benchmark_ap_pio_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_benchmark_ap_pio_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_benchmark_ap_pio_s1 <= benchmark_ap_pio_s1_end_xfer AND (((NOT benchmark_ap_pio_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --benchmark_ap_pio_s1_arb_share_counter arbitration counter enable, which is an e_assign
  benchmark_ap_pio_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_benchmark_ap_pio_s1 AND benchmark_ap_pio_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_benchmark_ap_pio_s1 AND NOT benchmark_ap_pio_s1_non_bursting_master_requests));
  --benchmark_ap_pio_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      benchmark_ap_pio_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(benchmark_ap_pio_s1_arb_counter_enable) = '1' then 
        benchmark_ap_pio_s1_arb_share_counter <= benchmark_ap_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --benchmark_ap_pio_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      benchmark_ap_pio_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((benchmark_ap_pio_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_benchmark_ap_pio_s1)) OR ((end_xfer_arb_share_counter_term_benchmark_ap_pio_s1 AND NOT benchmark_ap_pio_s1_non_bursting_master_requests)))) = '1' then 
        benchmark_ap_pio_s1_slavearbiterlockenable <= or_reduce(benchmark_ap_pio_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --ap_cpu/data_master benchmark_ap_pio/s1 arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= benchmark_ap_pio_s1_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --benchmark_ap_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  benchmark_ap_pio_s1_slavearbiterlockenable2 <= or_reduce(benchmark_ap_pio_s1_arb_share_counter_next_value);
  --ap_cpu/data_master benchmark_ap_pio/s1 arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= benchmark_ap_pio_s1_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --benchmark_ap_pio_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  benchmark_ap_pio_s1_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1 <= internal_ap_cpu_data_master_requests_benchmark_ap_pio_s1 AND NOT (((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write));
  --benchmark_ap_pio_s1_writedata mux, which is an e_mux
  benchmark_ap_pio_s1_writedata <= ap_cpu_data_master_writedata (7 DOWNTO 0);
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_benchmark_ap_pio_s1 <= internal_ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1;
  --ap_cpu/data_master saved-grant benchmark_ap_pio/s1, which is an e_assign
  ap_cpu_data_master_saved_grant_benchmark_ap_pio_s1 <= internal_ap_cpu_data_master_requests_benchmark_ap_pio_s1;
  --allow new arb cycle for benchmark_ap_pio/s1, which is an e_assign
  benchmark_ap_pio_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  benchmark_ap_pio_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  benchmark_ap_pio_s1_master_qreq_vector <= std_logic'('1');
  --benchmark_ap_pio_s1_reset_n assignment, which is an e_assign
  benchmark_ap_pio_s1_reset_n <= reset_n;
  benchmark_ap_pio_s1_chipselect <= internal_ap_cpu_data_master_granted_benchmark_ap_pio_s1;
  --benchmark_ap_pio_s1_firsttransfer first transaction, which is an e_assign
  benchmark_ap_pio_s1_firsttransfer <= A_WE_StdLogic((std_logic'(benchmark_ap_pio_s1_begins_xfer) = '1'), benchmark_ap_pio_s1_unreg_firsttransfer, benchmark_ap_pio_s1_reg_firsttransfer);
  --benchmark_ap_pio_s1_unreg_firsttransfer first transaction, which is an e_assign
  benchmark_ap_pio_s1_unreg_firsttransfer <= NOT ((benchmark_ap_pio_s1_slavearbiterlockenable AND benchmark_ap_pio_s1_any_continuerequest));
  --benchmark_ap_pio_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      benchmark_ap_pio_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(benchmark_ap_pio_s1_begins_xfer) = '1' then 
        benchmark_ap_pio_s1_reg_firsttransfer <= benchmark_ap_pio_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --benchmark_ap_pio_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  benchmark_ap_pio_s1_beginbursttransfer_internal <= benchmark_ap_pio_s1_begins_xfer;
  --~benchmark_ap_pio_s1_write_n assignment, which is an e_mux
  benchmark_ap_pio_s1_write_n <= NOT ((((internal_ap_cpu_data_master_granted_benchmark_ap_pio_s1 AND ap_cpu_data_master_write)) AND benchmark_ap_pio_s1_pretend_byte_enable));
  shifted_address_to_benchmark_ap_pio_s1_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --benchmark_ap_pio_s1_address mux, which is an e_mux
  benchmark_ap_pio_s1_address <= A_EXT (A_SRL(shifted_address_to_benchmark_ap_pio_s1_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_benchmark_ap_pio_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_benchmark_ap_pio_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_benchmark_ap_pio_s1_end_xfer <= benchmark_ap_pio_s1_end_xfer;
    end if;

  end process;

  --benchmark_ap_pio_s1_waits_for_read in a cycle, which is an e_mux
  benchmark_ap_pio_s1_waits_for_read <= benchmark_ap_pio_s1_in_a_read_cycle AND benchmark_ap_pio_s1_begins_xfer;
  --benchmark_ap_pio_s1_in_a_read_cycle assignment, which is an e_assign
  benchmark_ap_pio_s1_in_a_read_cycle <= internal_ap_cpu_data_master_granted_benchmark_ap_pio_s1 AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= benchmark_ap_pio_s1_in_a_read_cycle;
  --benchmark_ap_pio_s1_waits_for_write in a cycle, which is an e_mux
  benchmark_ap_pio_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(benchmark_ap_pio_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --benchmark_ap_pio_s1_in_a_write_cycle assignment, which is an e_assign
  benchmark_ap_pio_s1_in_a_write_cycle <= internal_ap_cpu_data_master_granted_benchmark_ap_pio_s1 AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= benchmark_ap_pio_s1_in_a_write_cycle;
  wait_for_benchmark_ap_pio_s1_counter <= std_logic'('0');
  --benchmark_ap_pio_s1_pretend_byte_enable byte enable port mux, which is an e_mux
  benchmark_ap_pio_s1_pretend_byte_enable <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_benchmark_ap_pio_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ap_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))));
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_benchmark_ap_pio_s1 <= internal_ap_cpu_data_master_granted_benchmark_ap_pio_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1 <= internal_ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_benchmark_ap_pio_s1 <= internal_ap_cpu_data_master_requests_benchmark_ap_pio_s1;
--synthesis translate_off
    --benchmark_ap_pio/s1 enable non-zero assertions, which is an e_register
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

entity epcs_flash_controller_0_epcs_control_port_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_dataavailable : IN STD_LOGIC;
                 signal epcs_flash_controller_0_epcs_control_port_endofpacket : IN STD_LOGIC;
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
                signal internal_ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal last_cycle_ap_cpu_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal last_cycle_ap_cpu_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_ap_cpu_instruction_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
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
  internal_ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0000000000000000000000000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --assign epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa = epcs_flash_controller_0_epcs_control_port_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa <= epcs_flash_controller_0_epcs_control_port_dataavailable;
  --assign epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa = epcs_flash_controller_0_epcs_control_port_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa <= epcs_flash_controller_0_epcs_control_port_readyfordata;
  --epcs_flash_controller_0_epcs_control_port_arb_share_counter set values, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_arb_share_set_values <= std_logic_vector'("01");
  --epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests mux, which is an e_mux
  epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests <= ((internal_ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port OR internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port) OR internal_ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port) OR internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;
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

  --ap_cpu/data_master epcs_flash_controller_0/epcs_control_port arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 <= or_reduce(epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value);
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
  internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port <= ((to_std_logic(((Std_Logic_Vector'(ap_cpu_instruction_master_address_to_slave(27 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("0000000000000000000000000000")))) AND (ap_cpu_instruction_master_read))) AND ap_cpu_instruction_master_read;
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
  internal_ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port <= internal_ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port AND NOT ((((ap_cpu_instruction_master_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000")))))) OR ap_cpu_data_master_arbiterlock));
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
  epcs_flash_controller_0_epcs_control_port_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port)) = '1'), (A_SRL(shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_ap_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 9);
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
    VARIABLE write_line4 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line4, now);
          write(write_line4, string'(": "));
          write(write_line4, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line4.all);
          deallocate (write_line4);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line5 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_saved_grant_epcs_flash_controller_0_epcs_control_port))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_saved_grant_epcs_flash_controller_0_epcs_control_port))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line5, now);
          write(write_line5, string'(": "));
          write(write_line5, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line5.all);
          deallocate (write_line5);
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
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal inport_ap_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_inport_ap_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_inport_ap_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_inport_ap_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_inport_ap_s1 : OUT STD_LOGIC;
                 signal d1_inport_ap_s1_end_xfer : OUT STD_LOGIC;
                 signal inport_ap_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal inport_ap_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal inport_ap_s1_reset_n : OUT STD_LOGIC
              );
end entity inport_ap_s1_arbitrator;


architecture europa of inport_ap_s1_arbitrator is
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_inport_ap_s1 :  STD_LOGIC;
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
                signal inport_ap_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal inport_ap_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal inport_ap_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
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
                signal internal_ap_cpu_data_master_granted_inport_ap_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_inport_ap_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_inport_ap_s1 :  STD_LOGIC;
                signal shifted_address_to_inport_ap_s1_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
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

  inport_ap_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_inport_ap_s1);
  --assign inport_ap_s1_readdata_from_sa = inport_ap_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  inport_ap_s1_readdata_from_sa <= inport_ap_s1_readdata;
  internal_ap_cpu_data_master_requests_inport_ap_s1 <= ((to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000000100101010000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))) AND ap_cpu_data_master_read;
  --inport_ap_s1_arb_share_counter set values, which is an e_mux
  inport_ap_s1_arb_share_set_values <= std_logic_vector'("01");
  --inport_ap_s1_non_bursting_master_requests mux, which is an e_mux
  inport_ap_s1_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_inport_ap_s1;
  --inport_ap_s1_any_bursting_master_saved_grant mux, which is an e_mux
  inport_ap_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --inport_ap_s1_arb_share_counter_next_value assignment, which is an e_assign
  inport_ap_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(inport_ap_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (inport_ap_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(inport_ap_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (inport_ap_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
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
      inport_ap_s1_arb_share_counter <= std_logic_vector'("00");
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
        inport_ap_s1_slavearbiterlockenable <= or_reduce(inport_ap_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --ap_cpu/data_master inport_ap/s1 arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= inport_ap_s1_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --inport_ap_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  inport_ap_s1_slavearbiterlockenable2 <= or_reduce(inport_ap_s1_arb_share_counter_next_value);
  --ap_cpu/data_master inport_ap/s1 arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= inport_ap_s1_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --inport_ap_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  inport_ap_s1_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_inport_ap_s1 <= internal_ap_cpu_data_master_requests_inport_ap_s1;
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_inport_ap_s1 <= internal_ap_cpu_data_master_qualified_request_inport_ap_s1;
  --ap_cpu/data_master saved-grant inport_ap/s1, which is an e_assign
  ap_cpu_data_master_saved_grant_inport_ap_s1 <= internal_ap_cpu_data_master_requests_inport_ap_s1;
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
  shifted_address_to_inport_ap_s1_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --inport_ap_s1_address mux, which is an e_mux
  inport_ap_s1_address <= A_EXT (A_SRL(shifted_address_to_inport_ap_s1_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
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
  inport_ap_s1_in_a_read_cycle <= internal_ap_cpu_data_master_granted_inport_ap_s1 AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= inport_ap_s1_in_a_read_cycle;
  --inport_ap_s1_waits_for_write in a cycle, which is an e_mux
  inport_ap_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(inport_ap_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --inport_ap_s1_in_a_write_cycle assignment, which is an e_assign
  inport_ap_s1_in_a_write_cycle <= internal_ap_cpu_data_master_granted_inport_ap_s1 AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= inport_ap_s1_in_a_write_cycle;
  wait_for_inport_ap_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_inport_ap_s1 <= internal_ap_cpu_data_master_granted_inport_ap_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_inport_ap_s1 <= internal_ap_cpu_data_master_qualified_request_inport_ap_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_inport_ap_s1 <= internal_ap_cpu_data_master_requests_inport_ap_s1;
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
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_irq : IN STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_1_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                 signal jtag_uart_1_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
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
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal internal_jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_allgrants :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_any_continuerequest :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_arb_counter_enable :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal jtag_uart_1_avalon_jtag_slave_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
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
                signal shifted_address_to_jtag_uart_1_avalon_jtag_slave_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
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

  jtag_uart_1_avalon_jtag_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave);
  --assign jtag_uart_1_avalon_jtag_slave_readdata_from_sa = jtag_uart_1_avalon_jtag_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_readdata_from_sa <= jtag_uart_1_avalon_jtag_slave_readdata;
  internal_ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("0000000000000000100110100000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --assign jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_1_avalon_jtag_slave_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa <= jtag_uart_1_avalon_jtag_slave_dataavailable;
  --assign jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_1_avalon_jtag_slave_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa <= jtag_uart_1_avalon_jtag_slave_readyfordata;
  --assign jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_1_avalon_jtag_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa <= jtag_uart_1_avalon_jtag_slave_waitrequest;
  --jtag_uart_1_avalon_jtag_slave_arb_share_counter set values, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_arb_share_set_values <= std_logic_vector'("01");
  --jtag_uart_1_avalon_jtag_slave_non_bursting_master_requests mux, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave;
  --jtag_uart_1_avalon_jtag_slave_any_bursting_master_saved_grant mux, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value assignment, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(jtag_uart_1_avalon_jtag_slave_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (jtag_uart_1_avalon_jtag_slave_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(jtag_uart_1_avalon_jtag_slave_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (jtag_uart_1_avalon_jtag_slave_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
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
      jtag_uart_1_avalon_jtag_slave_arb_share_counter <= std_logic_vector'("00");
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
        jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable <= or_reduce(jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --ap_cpu/data_master jtag_uart_1/avalon_jtag_slave arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable2 <= or_reduce(jtag_uart_1_avalon_jtag_slave_arb_share_counter_next_value);
  --ap_cpu/data_master jtag_uart_1/avalon_jtag_slave arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= jtag_uart_1_avalon_jtag_slave_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --jtag_uart_1_avalon_jtag_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave <= internal_ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave AND NOT ((((ap_cpu_data_master_read AND (NOT ap_cpu_data_master_waitrequest))) OR (((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write))));
  --jtag_uart_1_avalon_jtag_slave_writedata mux, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_writedata <= ap_cpu_data_master_writedata;
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave <= internal_ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave;
  --ap_cpu/data_master saved-grant jtag_uart_1/avalon_jtag_slave, which is an e_assign
  ap_cpu_data_master_saved_grant_jtag_uart_1_avalon_jtag_slave <= internal_ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave;
  --allow new arb cycle for jtag_uart_1/avalon_jtag_slave, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  jtag_uart_1_avalon_jtag_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  jtag_uart_1_avalon_jtag_slave_master_qreq_vector <= std_logic'('1');
  --jtag_uart_1_avalon_jtag_slave_reset_n assignment, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_reset_n <= reset_n;
  jtag_uart_1_avalon_jtag_slave_chipselect <= internal_ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave;
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
  jtag_uart_1_avalon_jtag_slave_read_n <= NOT ((internal_ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave AND ap_cpu_data_master_read));
  --~jtag_uart_1_avalon_jtag_slave_write_n assignment, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_write_n <= NOT ((internal_ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave AND ap_cpu_data_master_write));
  shifted_address_to_jtag_uart_1_avalon_jtag_slave_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --jtag_uart_1_avalon_jtag_slave_address mux, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_jtag_uart_1_avalon_jtag_slave_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")));
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
  jtag_uart_1_avalon_jtag_slave_in_a_read_cycle <= internal_ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= jtag_uart_1_avalon_jtag_slave_in_a_read_cycle;
  --jtag_uart_1_avalon_jtag_slave_waits_for_write in a cycle, which is an e_mux
  jtag_uart_1_avalon_jtag_slave_waits_for_write <= jtag_uart_1_avalon_jtag_slave_in_a_write_cycle AND internal_jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_1_avalon_jtag_slave_in_a_write_cycle assignment, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_in_a_write_cycle <= internal_ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= jtag_uart_1_avalon_jtag_slave_in_a_write_cycle;
  wait_for_jtag_uart_1_avalon_jtag_slave_counter <= std_logic'('0');
  --assign jtag_uart_1_avalon_jtag_slave_irq_from_sa = jtag_uart_1_avalon_jtag_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_1_avalon_jtag_slave_irq_from_sa <= jtag_uart_1_avalon_jtag_slave_irq;
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave <= internal_ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave <= internal_ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave <= internal_ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave;
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

entity lcd_control_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal lcd_control_slave_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_3_out_address_to_slave : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal niosII_openMac_clock_3_out_nativeaddress : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal niosII_openMac_clock_3_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_3_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_3_out_writedata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_lcd_control_slave_end_xfer : OUT STD_LOGIC;
                 signal lcd_control_slave_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal lcd_control_slave_begintransfer : OUT STD_LOGIC;
                 signal lcd_control_slave_read : OUT STD_LOGIC;
                 signal lcd_control_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal lcd_control_slave_wait_counter_eq_0 : OUT STD_LOGIC;
                 signal lcd_control_slave_write : OUT STD_LOGIC;
                 signal lcd_control_slave_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_3_out_granted_lcd_control_slave : OUT STD_LOGIC;
                 signal niosII_openMac_clock_3_out_qualified_request_lcd_control_slave : OUT STD_LOGIC;
                 signal niosII_openMac_clock_3_out_read_data_valid_lcd_control_slave : OUT STD_LOGIC;
                 signal niosII_openMac_clock_3_out_requests_lcd_control_slave : OUT STD_LOGIC
              );
end entity lcd_control_slave_arbitrator;


architecture europa of lcd_control_slave_arbitrator is
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_lcd_control_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_lcd_control_slave_wait_counter_eq_0 :  STD_LOGIC;
                signal internal_niosII_openMac_clock_3_out_granted_lcd_control_slave :  STD_LOGIC;
                signal internal_niosII_openMac_clock_3_out_qualified_request_lcd_control_slave :  STD_LOGIC;
                signal internal_niosII_openMac_clock_3_out_requests_lcd_control_slave :  STD_LOGIC;
                signal lcd_control_slave_allgrants :  STD_LOGIC;
                signal lcd_control_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal lcd_control_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal lcd_control_slave_any_continuerequest :  STD_LOGIC;
                signal lcd_control_slave_arb_counter_enable :  STD_LOGIC;
                signal lcd_control_slave_arb_share_counter :  STD_LOGIC;
                signal lcd_control_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal lcd_control_slave_arb_share_set_values :  STD_LOGIC;
                signal lcd_control_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal lcd_control_slave_begins_xfer :  STD_LOGIC;
                signal lcd_control_slave_counter_load_value :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal lcd_control_slave_end_xfer :  STD_LOGIC;
                signal lcd_control_slave_firsttransfer :  STD_LOGIC;
                signal lcd_control_slave_grant_vector :  STD_LOGIC;
                signal lcd_control_slave_in_a_read_cycle :  STD_LOGIC;
                signal lcd_control_slave_in_a_write_cycle :  STD_LOGIC;
                signal lcd_control_slave_master_qreq_vector :  STD_LOGIC;
                signal lcd_control_slave_non_bursting_master_requests :  STD_LOGIC;
                signal lcd_control_slave_pretend_byte_enable :  STD_LOGIC;
                signal lcd_control_slave_reg_firsttransfer :  STD_LOGIC;
                signal lcd_control_slave_slavearbiterlockenable :  STD_LOGIC;
                signal lcd_control_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal lcd_control_slave_unreg_firsttransfer :  STD_LOGIC;
                signal lcd_control_slave_wait_counter :  STD_LOGIC_VECTOR (4 DOWNTO 0);
                signal lcd_control_slave_waits_for_read :  STD_LOGIC;
                signal lcd_control_slave_waits_for_write :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_arbiterlock :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_arbiterlock2 :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_saved_grant_lcd_control_slave :  STD_LOGIC;
                signal wait_for_lcd_control_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT lcd_control_slave_end_xfer;
    end if;

  end process;

  lcd_control_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_niosII_openMac_clock_3_out_qualified_request_lcd_control_slave);
  --assign lcd_control_slave_readdata_from_sa = lcd_control_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  lcd_control_slave_readdata_from_sa <= lcd_control_slave_readdata;
  internal_niosII_openMac_clock_3_out_requests_lcd_control_slave <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_3_out_read OR niosII_openMac_clock_3_out_write)))))));
  --lcd_control_slave_arb_share_counter set values, which is an e_mux
  lcd_control_slave_arb_share_set_values <= std_logic'('1');
  --lcd_control_slave_non_bursting_master_requests mux, which is an e_mux
  lcd_control_slave_non_bursting_master_requests <= internal_niosII_openMac_clock_3_out_requests_lcd_control_slave;
  --lcd_control_slave_any_bursting_master_saved_grant mux, which is an e_mux
  lcd_control_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --lcd_control_slave_arb_share_counter_next_value assignment, which is an e_assign
  lcd_control_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(lcd_control_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(lcd_control_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(lcd_control_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(lcd_control_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --lcd_control_slave_allgrants all slave grants, which is an e_mux
  lcd_control_slave_allgrants <= lcd_control_slave_grant_vector;
  --lcd_control_slave_end_xfer assignment, which is an e_assign
  lcd_control_slave_end_xfer <= NOT ((lcd_control_slave_waits_for_read OR lcd_control_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_lcd_control_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_lcd_control_slave <= lcd_control_slave_end_xfer AND (((NOT lcd_control_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --lcd_control_slave_arb_share_counter arbitration counter enable, which is an e_assign
  lcd_control_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_lcd_control_slave AND lcd_control_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_lcd_control_slave AND NOT lcd_control_slave_non_bursting_master_requests));
  --lcd_control_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      lcd_control_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(lcd_control_slave_arb_counter_enable) = '1' then 
        lcd_control_slave_arb_share_counter <= lcd_control_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --lcd_control_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      lcd_control_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((lcd_control_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_lcd_control_slave)) OR ((end_xfer_arb_share_counter_term_lcd_control_slave AND NOT lcd_control_slave_non_bursting_master_requests)))) = '1' then 
        lcd_control_slave_slavearbiterlockenable <= lcd_control_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_3/out lcd/control_slave arbiterlock, which is an e_assign
  niosII_openMac_clock_3_out_arbiterlock <= lcd_control_slave_slavearbiterlockenable AND niosII_openMac_clock_3_out_continuerequest;
  --lcd_control_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  lcd_control_slave_slavearbiterlockenable2 <= lcd_control_slave_arb_share_counter_next_value;
  --niosII_openMac_clock_3/out lcd/control_slave arbiterlock2, which is an e_assign
  niosII_openMac_clock_3_out_arbiterlock2 <= lcd_control_slave_slavearbiterlockenable2 AND niosII_openMac_clock_3_out_continuerequest;
  --lcd_control_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  lcd_control_slave_any_continuerequest <= std_logic'('1');
  --niosII_openMac_clock_3_out_continuerequest continued request, which is an e_assign
  niosII_openMac_clock_3_out_continuerequest <= std_logic'('1');
  internal_niosII_openMac_clock_3_out_qualified_request_lcd_control_slave <= internal_niosII_openMac_clock_3_out_requests_lcd_control_slave;
  --lcd_control_slave_writedata mux, which is an e_mux
  lcd_control_slave_writedata <= niosII_openMac_clock_3_out_writedata;
  --master is always granted when requested
  internal_niosII_openMac_clock_3_out_granted_lcd_control_slave <= internal_niosII_openMac_clock_3_out_qualified_request_lcd_control_slave;
  --niosII_openMac_clock_3/out saved-grant lcd/control_slave, which is an e_assign
  niosII_openMac_clock_3_out_saved_grant_lcd_control_slave <= internal_niosII_openMac_clock_3_out_requests_lcd_control_slave;
  --allow new arb cycle for lcd/control_slave, which is an e_assign
  lcd_control_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  lcd_control_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  lcd_control_slave_master_qreq_vector <= std_logic'('1');
  lcd_control_slave_begintransfer <= lcd_control_slave_begins_xfer;
  --lcd_control_slave_firsttransfer first transaction, which is an e_assign
  lcd_control_slave_firsttransfer <= A_WE_StdLogic((std_logic'(lcd_control_slave_begins_xfer) = '1'), lcd_control_slave_unreg_firsttransfer, lcd_control_slave_reg_firsttransfer);
  --lcd_control_slave_unreg_firsttransfer first transaction, which is an e_assign
  lcd_control_slave_unreg_firsttransfer <= NOT ((lcd_control_slave_slavearbiterlockenable AND lcd_control_slave_any_continuerequest));
  --lcd_control_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      lcd_control_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(lcd_control_slave_begins_xfer) = '1' then 
        lcd_control_slave_reg_firsttransfer <= lcd_control_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --lcd_control_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  lcd_control_slave_beginbursttransfer_internal <= lcd_control_slave_begins_xfer;
  --lcd_control_slave_read assignment, which is an e_mux
  lcd_control_slave_read <= (((internal_niosII_openMac_clock_3_out_granted_lcd_control_slave AND niosII_openMac_clock_3_out_read)) AND NOT lcd_control_slave_begins_xfer) AND to_std_logic((((std_logic_vector'("000000000000000000000000000") & (lcd_control_slave_wait_counter))<std_logic_vector'("00000000000000000000000000000111"))));
  --lcd_control_slave_write assignment, which is an e_mux
  lcd_control_slave_write <= (((((internal_niosII_openMac_clock_3_out_granted_lcd_control_slave AND niosII_openMac_clock_3_out_write)) AND NOT lcd_control_slave_begins_xfer) AND to_std_logic((((std_logic_vector'("000000000000000000000000000") & (lcd_control_slave_wait_counter))>=std_logic_vector'("00000000000000000000000000000111"))))) AND to_std_logic((((std_logic_vector'("000000000000000000000000000") & (lcd_control_slave_wait_counter))<std_logic_vector'("00000000000000000000000000001110"))))) AND lcd_control_slave_pretend_byte_enable;
  --lcd_control_slave_address mux, which is an e_mux
  lcd_control_slave_address <= niosII_openMac_clock_3_out_nativeaddress;
  --d1_lcd_control_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_lcd_control_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_lcd_control_slave_end_xfer <= lcd_control_slave_end_xfer;
    end if;

  end process;

  --lcd_control_slave_waits_for_read in a cycle, which is an e_mux
  lcd_control_slave_waits_for_read <= lcd_control_slave_in_a_read_cycle AND wait_for_lcd_control_slave_counter;
  --lcd_control_slave_in_a_read_cycle assignment, which is an e_assign
  lcd_control_slave_in_a_read_cycle <= internal_niosII_openMac_clock_3_out_granted_lcd_control_slave AND niosII_openMac_clock_3_out_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= lcd_control_slave_in_a_read_cycle;
  --lcd_control_slave_waits_for_write in a cycle, which is an e_mux
  lcd_control_slave_waits_for_write <= lcd_control_slave_in_a_write_cycle AND wait_for_lcd_control_slave_counter;
  --lcd_control_slave_in_a_write_cycle assignment, which is an e_assign
  lcd_control_slave_in_a_write_cycle <= internal_niosII_openMac_clock_3_out_granted_lcd_control_slave AND niosII_openMac_clock_3_out_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= lcd_control_slave_in_a_write_cycle;
  internal_lcd_control_slave_wait_counter_eq_0 <= to_std_logic(((std_logic_vector'("000000000000000000000000000") & (lcd_control_slave_wait_counter)) = std_logic_vector'("00000000000000000000000000000000")));
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      lcd_control_slave_wait_counter <= std_logic_vector'("00000");
    elsif clk'event and clk = '1' then
      lcd_control_slave_wait_counter <= lcd_control_slave_counter_load_value;
    end if;

  end process;

  lcd_control_slave_counter_load_value <= A_EXT (A_WE_StdLogicVector((std_logic'(((lcd_control_slave_in_a_read_cycle AND lcd_control_slave_begins_xfer))) = '1'), std_logic_vector'("000000000000000000000000000001100"), A_WE_StdLogicVector((std_logic'(((lcd_control_slave_in_a_write_cycle AND lcd_control_slave_begins_xfer))) = '1'), std_logic_vector'("000000000000000000000000000010011"), A_WE_StdLogicVector((std_logic'((NOT internal_lcd_control_slave_wait_counter_eq_0)) = '1'), ((std_logic_vector'("0000000000000000000000000000") & (lcd_control_slave_wait_counter)) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000")))), 5);
  wait_for_lcd_control_slave_counter <= lcd_control_slave_begins_xfer OR NOT internal_lcd_control_slave_wait_counter_eq_0;
  --lcd_control_slave_pretend_byte_enable byte enable port mux, which is an e_mux
  lcd_control_slave_pretend_byte_enable <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_niosII_openMac_clock_3_out_granted_lcd_control_slave)) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(std_logic'('1')))), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))));
  --vhdl renameroo for output signals
  lcd_control_slave_wait_counter_eq_0 <= internal_lcd_control_slave_wait_counter_eq_0;
  --vhdl renameroo for output signals
  niosII_openMac_clock_3_out_granted_lcd_control_slave <= internal_niosII_openMac_clock_3_out_granted_lcd_control_slave;
  --vhdl renameroo for output signals
  niosII_openMac_clock_3_out_qualified_request_lcd_control_slave <= internal_niosII_openMac_clock_3_out_qualified_request_lcd_control_slave;
  --vhdl renameroo for output signals
  niosII_openMac_clock_3_out_requests_lcd_control_slave <= internal_niosII_openMac_clock_3_out_requests_lcd_control_slave;
--synthesis translate_off
    --lcd/control_slave enable non-zero assertions, which is an e_register
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
                 signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_in_endofpacket : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                 signal d1_niosII_openMac_clock_0_in_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_in_address : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_in_nativeaddress : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_read : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_0_in_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_in_write : OUT STD_LOGIC
              );
end entity niosII_openMac_clock_0_in_arbitrator;


architecture europa of niosII_openMac_clock_0_in_arbitrator is
                signal ap_cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_instruction_master_saved_grant_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in :  STD_LOGIC;
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

  niosII_openMac_clock_0_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in);
  --assign niosII_openMac_clock_0_in_readdata_from_sa = niosII_openMac_clock_0_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_0_in_readdata_from_sa <= niosII_openMac_clock_0_in_readdata;
  internal_ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in <= ((to_std_logic(((Std_Logic_Vector'(A_ToStdLogicVector(ap_cpu_instruction_master_address_to_slave(27)) & std_logic_vector'("000000000000000000000000000")) = std_logic_vector'("1000000000000000000000000000")))) AND (ap_cpu_instruction_master_read))) AND ap_cpu_instruction_master_read;
  --assign niosII_openMac_clock_0_in_waitrequest_from_sa = niosII_openMac_clock_0_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_niosII_openMac_clock_0_in_waitrequest_from_sa <= niosII_openMac_clock_0_in_waitrequest;
  --niosII_openMac_clock_0_in_arb_share_counter set values, which is an e_mux
  niosII_openMac_clock_0_in_arb_share_set_values <= std_logic'('1');
  --niosII_openMac_clock_0_in_non_bursting_master_requests mux, which is an e_mux
  niosII_openMac_clock_0_in_non_bursting_master_requests <= internal_ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in;
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

  --ap_cpu/instruction_master niosII_openMac_clock_0/in arbiterlock, which is an e_assign
  ap_cpu_instruction_master_arbiterlock <= niosII_openMac_clock_0_in_slavearbiterlockenable AND ap_cpu_instruction_master_continuerequest;
  --niosII_openMac_clock_0_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  niosII_openMac_clock_0_in_slavearbiterlockenable2 <= niosII_openMac_clock_0_in_arb_share_counter_next_value;
  --ap_cpu/instruction_master niosII_openMac_clock_0/in arbiterlock2, which is an e_assign
  ap_cpu_instruction_master_arbiterlock2 <= niosII_openMac_clock_0_in_slavearbiterlockenable2 AND ap_cpu_instruction_master_continuerequest;
  --niosII_openMac_clock_0_in_any_continuerequest at least one master continues requesting, which is an e_assign
  niosII_openMac_clock_0_in_any_continuerequest <= std_logic'('1');
  --ap_cpu_instruction_master_continuerequest continued request, which is an e_assign
  ap_cpu_instruction_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in <= internal_ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in AND NOT ((ap_cpu_instruction_master_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000"))))));
  --local readdatavalid ap_cpu_instruction_master_read_data_valid_niosII_openMac_clock_0_in, which is an e_mux
  ap_cpu_instruction_master_read_data_valid_niosII_openMac_clock_0_in <= (internal_ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in AND ap_cpu_instruction_master_read) AND NOT niosII_openMac_clock_0_in_waits_for_read;
  --assign niosII_openMac_clock_0_in_endofpacket_from_sa = niosII_openMac_clock_0_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_0_in_endofpacket_from_sa <= niosII_openMac_clock_0_in_endofpacket;
  --master is always granted when requested
  internal_ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in <= internal_ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in;
  --ap_cpu/instruction_master saved-grant niosII_openMac_clock_0/in, which is an e_assign
  ap_cpu_instruction_master_saved_grant_niosII_openMac_clock_0_in <= internal_ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in;
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
  niosII_openMac_clock_0_in_read <= internal_ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in AND ap_cpu_instruction_master_read;
  --niosII_openMac_clock_0_in_write assignment, which is an e_mux
  niosII_openMac_clock_0_in_write <= std_logic'('0');
  --niosII_openMac_clock_0_in_address mux, which is an e_mux
  niosII_openMac_clock_0_in_address <= ap_cpu_instruction_master_address_to_slave (26 DOWNTO 0);
  --slaveid niosII_openMac_clock_0_in_nativeaddress nativeaddress mux, which is an e_mux
  niosII_openMac_clock_0_in_nativeaddress <= A_EXT (A_SRL(ap_cpu_instruction_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 25);
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
  niosII_openMac_clock_0_in_in_a_read_cycle <= internal_ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in AND ap_cpu_instruction_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= niosII_openMac_clock_0_in_in_a_read_cycle;
  --niosII_openMac_clock_0_in_waits_for_write in a cycle, which is an e_mux
  niosII_openMac_clock_0_in_waits_for_write <= niosII_openMac_clock_0_in_in_a_write_cycle AND internal_niosII_openMac_clock_0_in_waitrequest_from_sa;
  --niosII_openMac_clock_0_in_in_a_write_cycle assignment, which is an e_assign
  niosII_openMac_clock_0_in_in_a_write_cycle <= std_logic'('0');
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= niosII_openMac_clock_0_in_in_a_write_cycle;
  wait_for_niosII_openMac_clock_0_in_counter <= std_logic'('0');
  --niosII_openMac_clock_0_in_byteenable byte enable port mux, which is an e_mux
  niosII_openMac_clock_0_in_byteenable <= A_EXT (-SIGNED(std_logic_vector'("00000000000000000000000000000001")), 4);
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in <= internal_ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in <= internal_ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in <= internal_ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in;
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
                 signal clk : IN STD_LOGIC;
                 signal d1_sdram_0_s1_end_xfer : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal niosII_openMac_clock_0_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_0_out_granted_sdram_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_requests_sdram_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal sdram_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal sdram_0_s1_waitrequest_from_sa : IN STD_LOGIC;

              -- outputs:
                 signal niosII_openMac_clock_0_out_address_to_slave : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal niosII_openMac_clock_0_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_0_out_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_out_waitrequest : OUT STD_LOGIC
              );
end entity niosII_openMac_clock_0_out_arbitrator;


architecture europa of niosII_openMac_clock_0_out_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_niosII_openMac_clock_0_out_address_to_slave :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal internal_niosII_openMac_clock_0_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_address_last_time :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal niosII_openMac_clock_0_out_byteenable_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_0_out_read_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_run :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_write_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_writedata_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal r_2 :  STD_LOGIC;

begin

  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic(((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 OR niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1) OR NOT niosII_openMac_clock_0_out_requests_sdram_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_0_out_granted_sdram_0_s1 OR NOT niosII_openMac_clock_0_out_qualified_request_sdram_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 OR NOT niosII_openMac_clock_0_out_read) OR ((niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1 AND niosII_openMac_clock_0_out_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 OR NOT ((niosII_openMac_clock_0_out_read OR niosII_openMac_clock_0_out_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT sdram_0_s1_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_0_out_read OR niosII_openMac_clock_0_out_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  niosII_openMac_clock_0_out_run <= r_2;
  --optimize select-logic by passing only those address bits which matter.
  internal_niosII_openMac_clock_0_out_address_to_slave <= niosII_openMac_clock_0_out_address;
  --niosII_openMac_clock_0/out readdata mux, which is an e_mux
  niosII_openMac_clock_0_out_readdata <= sdram_0_s1_readdata_from_sa;
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
        niosII_openMac_clock_0_out_address_last_time <= std_logic_vector'("000000000000000000000000000");
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
    VARIABLE write_line6 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_0_out_address /= niosII_openMac_clock_0_out_address_last_time))))) = '1' then 
          write(write_line6, now);
          write(write_line6, string'(": "));
          write(write_line6, string'("niosII_openMac_clock_0_out_address did not heed wait!!!"));
          write(output, write_line6.all);
          deallocate (write_line6);
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
    VARIABLE write_line7 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_0_out_byteenable /= niosII_openMac_clock_0_out_byteenable_last_time))))) = '1' then 
          write(write_line7, now);
          write(write_line7, string'(": "));
          write(write_line7, string'("niosII_openMac_clock_0_out_byteenable did not heed wait!!!"));
          write(output, write_line7.all);
          deallocate (write_line7);
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
    VARIABLE write_line8 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_0_out_read) /= std_logic'(niosII_openMac_clock_0_out_read_last_time)))))) = '1' then 
          write(write_line8, now);
          write(write_line8, string'(": "));
          write(write_line8, string'("niosII_openMac_clock_0_out_read did not heed wait!!!"));
          write(output, write_line8.all);
          deallocate (write_line8);
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
    VARIABLE write_line9 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_0_out_write) /= std_logic'(niosII_openMac_clock_0_out_write_last_time)))))) = '1' then 
          write(write_line9, now);
          write(write_line9, string'(": "));
          write(write_line9, string'("niosII_openMac_clock_0_out_write did not heed wait!!!"));
          write(output, write_line9.all);
          deallocate (write_line9);
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
    VARIABLE write_line10 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_0_out_writedata /= niosII_openMac_clock_0_out_writedata_last_time)))) AND niosII_openMac_clock_0_out_write)) = '1' then 
          write(write_line10, now);
          write(write_line10, string'(": "));
          write(write_line10, string'("niosII_openMac_clock_0_out_writedata did not heed wait!!!"));
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

entity niosII_openMac_clock_1_in_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_in_endofpacket : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                 signal d1_niosII_openMac_clock_1_in_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_address : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_nativeaddress : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_read : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_1_in_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_write : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity niosII_openMac_clock_1_in_arbitrator;


architecture europa of niosII_openMac_clock_1_in_arbitrator is
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_in_waitrequest_from_sa :  STD_LOGIC;
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

  niosII_openMac_clock_1_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in);
  --assign niosII_openMac_clock_1_in_readdata_from_sa = niosII_openMac_clock_1_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_1_in_readdata_from_sa <= niosII_openMac_clock_1_in_readdata;
  internal_ap_cpu_data_master_requests_niosII_openMac_clock_1_in <= to_std_logic(((Std_Logic_Vector'(A_ToStdLogicVector(ap_cpu_data_master_address_to_slave(27)) & std_logic_vector'("000000000000000000000000000")) = std_logic_vector'("1000000000000000000000000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --assign niosII_openMac_clock_1_in_waitrequest_from_sa = niosII_openMac_clock_1_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_niosII_openMac_clock_1_in_waitrequest_from_sa <= niosII_openMac_clock_1_in_waitrequest;
  --niosII_openMac_clock_1_in_arb_share_counter set values, which is an e_mux
  niosII_openMac_clock_1_in_arb_share_set_values <= std_logic_vector'("01");
  --niosII_openMac_clock_1_in_non_bursting_master_requests mux, which is an e_mux
  niosII_openMac_clock_1_in_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_1_in;
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

  --ap_cpu/data_master niosII_openMac_clock_1/in arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= niosII_openMac_clock_1_in_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --niosII_openMac_clock_1_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  niosII_openMac_clock_1_in_slavearbiterlockenable2 <= or_reduce(niosII_openMac_clock_1_in_arb_share_counter_next_value);
  --ap_cpu/data_master niosII_openMac_clock_1/in arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= niosII_openMac_clock_1_in_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --niosII_openMac_clock_1_in_any_continuerequest at least one master continues requesting, which is an e_assign
  niosII_openMac_clock_1_in_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_1_in AND NOT ((((ap_cpu_data_master_read AND (NOT ap_cpu_data_master_waitrequest))) OR (((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write))));
  --niosII_openMac_clock_1_in_writedata mux, which is an e_mux
  niosII_openMac_clock_1_in_writedata <= ap_cpu_data_master_writedata;
  --assign niosII_openMac_clock_1_in_endofpacket_from_sa = niosII_openMac_clock_1_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_1_in_endofpacket_from_sa <= niosII_openMac_clock_1_in_endofpacket;
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_niosII_openMac_clock_1_in <= internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in;
  --ap_cpu/data_master saved-grant niosII_openMac_clock_1/in, which is an e_assign
  ap_cpu_data_master_saved_grant_niosII_openMac_clock_1_in <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_1_in;
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
  niosII_openMac_clock_1_in_read <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_1_in AND ap_cpu_data_master_read;
  --niosII_openMac_clock_1_in_write assignment, which is an e_mux
  niosII_openMac_clock_1_in_write <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_1_in AND ap_cpu_data_master_write;
  --niosII_openMac_clock_1_in_address mux, which is an e_mux
  niosII_openMac_clock_1_in_address <= ap_cpu_data_master_address_to_slave (26 DOWNTO 0);
  --slaveid niosII_openMac_clock_1_in_nativeaddress nativeaddress mux, which is an e_mux
  niosII_openMac_clock_1_in_nativeaddress <= A_EXT (A_SRL(ap_cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 25);
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
  niosII_openMac_clock_1_in_in_a_read_cycle <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_1_in AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= niosII_openMac_clock_1_in_in_a_read_cycle;
  --niosII_openMac_clock_1_in_waits_for_write in a cycle, which is an e_mux
  niosII_openMac_clock_1_in_waits_for_write <= niosII_openMac_clock_1_in_in_a_write_cycle AND internal_niosII_openMac_clock_1_in_waitrequest_from_sa;
  --niosII_openMac_clock_1_in_in_a_write_cycle assignment, which is an e_assign
  niosII_openMac_clock_1_in_in_a_write_cycle <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_1_in AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= niosII_openMac_clock_1_in_in_a_write_cycle;
  wait_for_niosII_openMac_clock_1_in_counter <= std_logic'('0');
  --niosII_openMac_clock_1_in_byteenable byte enable port mux, which is an e_mux
  niosII_openMac_clock_1_in_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_niosII_openMac_clock_1_in)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ap_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_niosII_openMac_clock_1_in <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_1_in;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in <= internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_niosII_openMac_clock_1_in <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_1_in;
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
                 signal d1_sdram_0_s1_end_xfer : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_granted_sdram_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_qualified_request_sdram_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_requests_sdram_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal sdram_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal sdram_0_s1_waitrequest_from_sa : IN STD_LOGIC;

              -- outputs:
                 signal niosII_openMac_clock_1_out_address_to_slave : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_waitrequest : OUT STD_LOGIC
              );
end entity niosII_openMac_clock_1_out_arbitrator;


architecture europa of niosII_openMac_clock_1_out_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_out_address_to_slave :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal internal_niosII_openMac_clock_1_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_address_last_time :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal niosII_openMac_clock_1_out_byteenable_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_1_out_read_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_run :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_write_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_writedata_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal r_2 :  STD_LOGIC;

begin

  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic(((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((niosII_openMac_clock_1_out_qualified_request_sdram_0_s1 OR niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1) OR NOT niosII_openMac_clock_1_out_requests_sdram_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_1_out_granted_sdram_0_s1 OR NOT niosII_openMac_clock_1_out_qualified_request_sdram_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT niosII_openMac_clock_1_out_qualified_request_sdram_0_s1 OR NOT niosII_openMac_clock_1_out_read) OR ((niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1 AND niosII_openMac_clock_1_out_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT niosII_openMac_clock_1_out_qualified_request_sdram_0_s1 OR NOT ((niosII_openMac_clock_1_out_read OR niosII_openMac_clock_1_out_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT sdram_0_s1_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_1_out_read OR niosII_openMac_clock_1_out_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  niosII_openMac_clock_1_out_run <= r_2;
  --optimize select-logic by passing only those address bits which matter.
  internal_niosII_openMac_clock_1_out_address_to_slave <= niosII_openMac_clock_1_out_address;
  --niosII_openMac_clock_1/out readdata mux, which is an e_mux
  niosII_openMac_clock_1_out_readdata <= sdram_0_s1_readdata_from_sa;
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
        niosII_openMac_clock_1_out_address_last_time <= std_logic_vector'("000000000000000000000000000");
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
    VARIABLE write_line11 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_1_out_address /= niosII_openMac_clock_1_out_address_last_time))))) = '1' then 
          write(write_line11, now);
          write(write_line11, string'(": "));
          write(write_line11, string'("niosII_openMac_clock_1_out_address did not heed wait!!!"));
          write(output, write_line11.all);
          deallocate (write_line11);
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
    VARIABLE write_line12 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_1_out_byteenable /= niosII_openMac_clock_1_out_byteenable_last_time))))) = '1' then 
          write(write_line12, now);
          write(write_line12, string'(": "));
          write(write_line12, string'("niosII_openMac_clock_1_out_byteenable did not heed wait!!!"));
          write(output, write_line12.all);
          deallocate (write_line12);
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
    VARIABLE write_line13 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_1_out_read) /= std_logic'(niosII_openMac_clock_1_out_read_last_time)))))) = '1' then 
          write(write_line13, now);
          write(write_line13, string'(": "));
          write(write_line13, string'("niosII_openMac_clock_1_out_read did not heed wait!!!"));
          write(output, write_line13.all);
          deallocate (write_line13);
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
    VARIABLE write_line14 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_1_out_write) /= std_logic'(niosII_openMac_clock_1_out_write_last_time)))))) = '1' then 
          write(write_line14, now);
          write(write_line14, string'(": "));
          write(write_line14, string'("niosII_openMac_clock_1_out_write did not heed wait!!!"));
          write(output, write_line14.all);
          deallocate (write_line14);
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
    VARIABLE write_line15 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_1_out_writedata /= niosII_openMac_clock_1_out_writedata_last_time)))) AND niosII_openMac_clock_1_out_write)) = '1' then 
          write(write_line15, now);
          write(write_line15, string'(": "));
          write(write_line15, string'("niosII_openMac_clock_1_out_writedata did not heed wait!!!"));
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

entity niosII_openMac_clock_2_in_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal niosII_openMac_clock_2_in_endofpacket : IN STD_LOGIC;
                 signal niosII_openMac_clock_2_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_2_in_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_niosII_openMac_clock_2_in : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_2_in : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_niosII_openMac_clock_2_in : OUT STD_LOGIC;
                 signal d1_niosII_openMac_clock_2_in_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_2_in_address : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_2_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_2_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_2_in_nativeaddress : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal niosII_openMac_clock_2_in_read : OUT STD_LOGIC;
                 signal niosII_openMac_clock_2_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_2_in_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_2_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_2_in_write : OUT STD_LOGIC;
                 signal niosII_openMac_clock_2_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity niosII_openMac_clock_2_in_arbitrator;


architecture europa of niosII_openMac_clock_2_in_arbitrator is
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_niosII_openMac_clock_2_in :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_niosII_openMac_clock_2_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_niosII_openMac_clock_2_in :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_niosII_openMac_clock_2_in :  STD_LOGIC;
                signal internal_niosII_openMac_clock_2_in_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_allgrants :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_allow_new_arb_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_any_bursting_master_saved_grant :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_any_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_arb_counter_enable :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_2_in_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_2_in_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_2_in_beginbursttransfer_internal :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_begins_xfer :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_end_xfer :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_grant_vector :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_in_a_read_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_in_a_write_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_master_qreq_vector :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_non_bursting_master_requests :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_reg_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_slavearbiterlockenable :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_slavearbiterlockenable2 :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_unreg_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_waits_for_read :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_niosII_openMac_clock_2_in_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal wait_for_niosII_openMac_clock_2_in_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT niosII_openMac_clock_2_in_end_xfer;
    end if;

  end process;

  niosII_openMac_clock_2_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in);
  --assign niosII_openMac_clock_2_in_readdata_from_sa = niosII_openMac_clock_2_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_2_in_readdata_from_sa <= niosII_openMac_clock_2_in_readdata;
  internal_ap_cpu_data_master_requests_niosII_openMac_clock_2_in <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 8) & std_logic_vector'("00000000")) = std_logic_vector'("0000000000000000100000000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --assign niosII_openMac_clock_2_in_waitrequest_from_sa = niosII_openMac_clock_2_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_niosII_openMac_clock_2_in_waitrequest_from_sa <= niosII_openMac_clock_2_in_waitrequest;
  --niosII_openMac_clock_2_in_arb_share_counter set values, which is an e_mux
  niosII_openMac_clock_2_in_arb_share_set_values <= std_logic_vector'("01");
  --niosII_openMac_clock_2_in_non_bursting_master_requests mux, which is an e_mux
  niosII_openMac_clock_2_in_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_2_in;
  --niosII_openMac_clock_2_in_any_bursting_master_saved_grant mux, which is an e_mux
  niosII_openMac_clock_2_in_any_bursting_master_saved_grant <= std_logic'('0');
  --niosII_openMac_clock_2_in_arb_share_counter_next_value assignment, which is an e_assign
  niosII_openMac_clock_2_in_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(niosII_openMac_clock_2_in_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (niosII_openMac_clock_2_in_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(niosII_openMac_clock_2_in_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (niosII_openMac_clock_2_in_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --niosII_openMac_clock_2_in_allgrants all slave grants, which is an e_mux
  niosII_openMac_clock_2_in_allgrants <= niosII_openMac_clock_2_in_grant_vector;
  --niosII_openMac_clock_2_in_end_xfer assignment, which is an e_assign
  niosII_openMac_clock_2_in_end_xfer <= NOT ((niosII_openMac_clock_2_in_waits_for_read OR niosII_openMac_clock_2_in_waits_for_write));
  --end_xfer_arb_share_counter_term_niosII_openMac_clock_2_in arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_niosII_openMac_clock_2_in <= niosII_openMac_clock_2_in_end_xfer AND (((NOT niosII_openMac_clock_2_in_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --niosII_openMac_clock_2_in_arb_share_counter arbitration counter enable, which is an e_assign
  niosII_openMac_clock_2_in_arb_counter_enable <= ((end_xfer_arb_share_counter_term_niosII_openMac_clock_2_in AND niosII_openMac_clock_2_in_allgrants)) OR ((end_xfer_arb_share_counter_term_niosII_openMac_clock_2_in AND NOT niosII_openMac_clock_2_in_non_bursting_master_requests));
  --niosII_openMac_clock_2_in_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_2_in_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(niosII_openMac_clock_2_in_arb_counter_enable) = '1' then 
        niosII_openMac_clock_2_in_arb_share_counter <= niosII_openMac_clock_2_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_2_in_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_2_in_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((niosII_openMac_clock_2_in_master_qreq_vector AND end_xfer_arb_share_counter_term_niosII_openMac_clock_2_in)) OR ((end_xfer_arb_share_counter_term_niosII_openMac_clock_2_in AND NOT niosII_openMac_clock_2_in_non_bursting_master_requests)))) = '1' then 
        niosII_openMac_clock_2_in_slavearbiterlockenable <= or_reduce(niosII_openMac_clock_2_in_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --ap_cpu/data_master niosII_openMac_clock_2/in arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= niosII_openMac_clock_2_in_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --niosII_openMac_clock_2_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  niosII_openMac_clock_2_in_slavearbiterlockenable2 <= or_reduce(niosII_openMac_clock_2_in_arb_share_counter_next_value);
  --ap_cpu/data_master niosII_openMac_clock_2/in arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= niosII_openMac_clock_2_in_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --niosII_openMac_clock_2_in_any_continuerequest at least one master continues requesting, which is an e_assign
  niosII_openMac_clock_2_in_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_2_in AND NOT ((((ap_cpu_data_master_read AND (NOT ap_cpu_data_master_waitrequest))) OR (((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write))));
  --niosII_openMac_clock_2_in_writedata mux, which is an e_mux
  niosII_openMac_clock_2_in_writedata <= ap_cpu_data_master_writedata;
  --assign niosII_openMac_clock_2_in_endofpacket_from_sa = niosII_openMac_clock_2_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_2_in_endofpacket_from_sa <= niosII_openMac_clock_2_in_endofpacket;
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_niosII_openMac_clock_2_in <= internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in;
  --ap_cpu/data_master saved-grant niosII_openMac_clock_2/in, which is an e_assign
  ap_cpu_data_master_saved_grant_niosII_openMac_clock_2_in <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_2_in;
  --allow new arb cycle for niosII_openMac_clock_2/in, which is an e_assign
  niosII_openMac_clock_2_in_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  niosII_openMac_clock_2_in_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  niosII_openMac_clock_2_in_master_qreq_vector <= std_logic'('1');
  --niosII_openMac_clock_2_in_reset_n assignment, which is an e_assign
  niosII_openMac_clock_2_in_reset_n <= reset_n;
  --niosII_openMac_clock_2_in_firsttransfer first transaction, which is an e_assign
  niosII_openMac_clock_2_in_firsttransfer <= A_WE_StdLogic((std_logic'(niosII_openMac_clock_2_in_begins_xfer) = '1'), niosII_openMac_clock_2_in_unreg_firsttransfer, niosII_openMac_clock_2_in_reg_firsttransfer);
  --niosII_openMac_clock_2_in_unreg_firsttransfer first transaction, which is an e_assign
  niosII_openMac_clock_2_in_unreg_firsttransfer <= NOT ((niosII_openMac_clock_2_in_slavearbiterlockenable AND niosII_openMac_clock_2_in_any_continuerequest));
  --niosII_openMac_clock_2_in_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_2_in_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(niosII_openMac_clock_2_in_begins_xfer) = '1' then 
        niosII_openMac_clock_2_in_reg_firsttransfer <= niosII_openMac_clock_2_in_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_2_in_beginbursttransfer_internal begin burst transfer, which is an e_assign
  niosII_openMac_clock_2_in_beginbursttransfer_internal <= niosII_openMac_clock_2_in_begins_xfer;
  --niosII_openMac_clock_2_in_read assignment, which is an e_mux
  niosII_openMac_clock_2_in_read <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_2_in AND ap_cpu_data_master_read;
  --niosII_openMac_clock_2_in_write assignment, which is an e_mux
  niosII_openMac_clock_2_in_write <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_2_in AND ap_cpu_data_master_write;
  shifted_address_to_niosII_openMac_clock_2_in_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --niosII_openMac_clock_2_in_address mux, which is an e_mux
  niosII_openMac_clock_2_in_address <= A_EXT (A_SRL(shifted_address_to_niosII_openMac_clock_2_in_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 8);
  --slaveid niosII_openMac_clock_2_in_nativeaddress nativeaddress mux, which is an e_mux
  niosII_openMac_clock_2_in_nativeaddress <= A_EXT (A_SRL(ap_cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 6);
  --d1_niosII_openMac_clock_2_in_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_niosII_openMac_clock_2_in_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_niosII_openMac_clock_2_in_end_xfer <= niosII_openMac_clock_2_in_end_xfer;
    end if;

  end process;

  --niosII_openMac_clock_2_in_waits_for_read in a cycle, which is an e_mux
  niosII_openMac_clock_2_in_waits_for_read <= niosII_openMac_clock_2_in_in_a_read_cycle AND internal_niosII_openMac_clock_2_in_waitrequest_from_sa;
  --niosII_openMac_clock_2_in_in_a_read_cycle assignment, which is an e_assign
  niosII_openMac_clock_2_in_in_a_read_cycle <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_2_in AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= niosII_openMac_clock_2_in_in_a_read_cycle;
  --niosII_openMac_clock_2_in_waits_for_write in a cycle, which is an e_mux
  niosII_openMac_clock_2_in_waits_for_write <= niosII_openMac_clock_2_in_in_a_write_cycle AND internal_niosII_openMac_clock_2_in_waitrequest_from_sa;
  --niosII_openMac_clock_2_in_in_a_write_cycle assignment, which is an e_assign
  niosII_openMac_clock_2_in_in_a_write_cycle <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_2_in AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= niosII_openMac_clock_2_in_in_a_write_cycle;
  wait_for_niosII_openMac_clock_2_in_counter <= std_logic'('0');
  --niosII_openMac_clock_2_in_byteenable byte enable port mux, which is an e_mux
  niosII_openMac_clock_2_in_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_niosII_openMac_clock_2_in)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ap_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_niosII_openMac_clock_2_in <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_2_in;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in <= internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_niosII_openMac_clock_2_in <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_2_in;
  --vhdl renameroo for output signals
  niosII_openMac_clock_2_in_waitrequest_from_sa <= internal_niosII_openMac_clock_2_in_waitrequest_from_sa;
--synthesis translate_off
    --niosII_openMac_clock_2/in enable non-zero assertions, which is an e_register
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

entity niosII_openMac_clock_2_out_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal d1_remote_update_cycloneiii_0_s1_end_xfer : IN STD_LOGIC;
                 signal niosII_openMac_clock_2_out_address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_2_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_2_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                 signal niosII_openMac_clock_2_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_2_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal remote_update_cycloneiii_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal remote_update_cycloneiii_0_s1_waitrequest_from_sa : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal niosII_openMac_clock_2_out_address_to_slave : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_2_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_2_out_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_2_out_waitrequest : OUT STD_LOGIC
              );
end entity niosII_openMac_clock_2_out_arbitrator;


architecture europa of niosII_openMac_clock_2_out_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_niosII_openMac_clock_2_out_address_to_slave :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_niosII_openMac_clock_2_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_address_last_time :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal niosII_openMac_clock_2_out_byteenable_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_2_out_read_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_run :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_write_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_writedata_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal r_2 :  STD_LOGIC;

begin

  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1 OR niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1) OR NOT niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1 OR NOT niosII_openMac_clock_2_out_read) OR ((niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1 AND niosII_openMac_clock_2_out_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1 OR NOT ((niosII_openMac_clock_2_out_read OR niosII_openMac_clock_2_out_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT remote_update_cycloneiii_0_s1_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_2_out_read OR niosII_openMac_clock_2_out_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  niosII_openMac_clock_2_out_run <= r_2;
  --optimize select-logic by passing only those address bits which matter.
  internal_niosII_openMac_clock_2_out_address_to_slave <= niosII_openMac_clock_2_out_address;
  --niosII_openMac_clock_2/out readdata mux, which is an e_mux
  niosII_openMac_clock_2_out_readdata <= remote_update_cycloneiii_0_s1_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_niosII_openMac_clock_2_out_waitrequest <= NOT niosII_openMac_clock_2_out_run;
  --niosII_openMac_clock_2_out_reset_n assignment, which is an e_assign
  niosII_openMac_clock_2_out_reset_n <= reset_n;
  --vhdl renameroo for output signals
  niosII_openMac_clock_2_out_address_to_slave <= internal_niosII_openMac_clock_2_out_address_to_slave;
  --vhdl renameroo for output signals
  niosII_openMac_clock_2_out_waitrequest <= internal_niosII_openMac_clock_2_out_waitrequest;
--synthesis translate_off
    --niosII_openMac_clock_2_out_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_2_out_address_last_time <= std_logic_vector'("00000000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_2_out_address_last_time <= niosII_openMac_clock_2_out_address;
      end if;

    end process;

    --niosII_openMac_clock_2/out waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_niosII_openMac_clock_2_out_waitrequest AND ((niosII_openMac_clock_2_out_read OR niosII_openMac_clock_2_out_write));
      end if;

    end process;

    --niosII_openMac_clock_2_out_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line16 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_2_out_address /= niosII_openMac_clock_2_out_address_last_time))))) = '1' then 
          write(write_line16, now);
          write(write_line16, string'(": "));
          write(write_line16, string'("niosII_openMac_clock_2_out_address did not heed wait!!!"));
          write(output, write_line16.all);
          deallocate (write_line16);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_2_out_byteenable check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_2_out_byteenable_last_time <= std_logic_vector'("0000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_2_out_byteenable_last_time <= niosII_openMac_clock_2_out_byteenable;
      end if;

    end process;

    --niosII_openMac_clock_2_out_byteenable matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line17 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_2_out_byteenable /= niosII_openMac_clock_2_out_byteenable_last_time))))) = '1' then 
          write(write_line17, now);
          write(write_line17, string'(": "));
          write(write_line17, string'("niosII_openMac_clock_2_out_byteenable did not heed wait!!!"));
          write(output, write_line17.all);
          deallocate (write_line17);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_2_out_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_2_out_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_2_out_read_last_time <= niosII_openMac_clock_2_out_read;
      end if;

    end process;

    --niosII_openMac_clock_2_out_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line18 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_2_out_read) /= std_logic'(niosII_openMac_clock_2_out_read_last_time)))))) = '1' then 
          write(write_line18, now);
          write(write_line18, string'(": "));
          write(write_line18, string'("niosII_openMac_clock_2_out_read did not heed wait!!!"));
          write(output, write_line18.all);
          deallocate (write_line18);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_2_out_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_2_out_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_2_out_write_last_time <= niosII_openMac_clock_2_out_write;
      end if;

    end process;

    --niosII_openMac_clock_2_out_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line19 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_2_out_write) /= std_logic'(niosII_openMac_clock_2_out_write_last_time)))))) = '1' then 
          write(write_line19, now);
          write(write_line19, string'(": "));
          write(write_line19, string'("niosII_openMac_clock_2_out_write did not heed wait!!!"));
          write(output, write_line19.all);
          deallocate (write_line19);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_2_out_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_2_out_writedata_last_time <= std_logic_vector'("00000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_2_out_writedata_last_time <= niosII_openMac_clock_2_out_writedata;
      end if;

    end process;

    --niosII_openMac_clock_2_out_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line20 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_2_out_writedata /= niosII_openMac_clock_2_out_writedata_last_time)))) AND niosII_openMac_clock_2_out_write)) = '1' then 
          write(write_line20, now);
          write(write_line20, string'(": "));
          write(write_line20, string'("niosII_openMac_clock_2_out_writedata did not heed wait!!!"));
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

entity niosII_openMac_clock_3_in_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal niosII_openMac_clock_3_in_endofpacket : IN STD_LOGIC;
                 signal niosII_openMac_clock_3_in_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_3_in_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_niosII_openMac_clock_3_in : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_3_in : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_niosII_openMac_clock_3_in : OUT STD_LOGIC;
                 signal d1_niosII_openMac_clock_3_in_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_3_in_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal niosII_openMac_clock_3_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_3_in_nativeaddress : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal niosII_openMac_clock_3_in_read : OUT STD_LOGIC;
                 signal niosII_openMac_clock_3_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_3_in_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_3_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_3_in_write : OUT STD_LOGIC;
                 signal niosII_openMac_clock_3_in_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
              );
end entity niosII_openMac_clock_3_in_arbitrator;


architecture europa of niosII_openMac_clock_3_in_arbitrator is
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_niosII_openMac_clock_3_in :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_niosII_openMac_clock_3_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_niosII_openMac_clock_3_in :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_niosII_openMac_clock_3_in :  STD_LOGIC;
                signal internal_niosII_openMac_clock_3_in_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_allgrants :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_allow_new_arb_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_any_bursting_master_saved_grant :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_any_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_arb_counter_enable :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_3_in_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_3_in_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_3_in_beginbursttransfer_internal :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_begins_xfer :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_end_xfer :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_grant_vector :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_in_a_read_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_in_a_write_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_master_qreq_vector :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_non_bursting_master_requests :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_pretend_byte_enable :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_reg_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_slavearbiterlockenable :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_slavearbiterlockenable2 :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_unreg_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_waits_for_read :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_niosII_openMac_clock_3_in_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal wait_for_niosII_openMac_clock_3_in_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT niosII_openMac_clock_3_in_end_xfer;
    end if;

  end process;

  niosII_openMac_clock_3_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in);
  --assign niosII_openMac_clock_3_in_readdata_from_sa = niosII_openMac_clock_3_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_3_in_readdata_from_sa <= niosII_openMac_clock_3_in_readdata;
  internal_ap_cpu_data_master_requests_niosII_openMac_clock_3_in <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000000100101110000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --assign niosII_openMac_clock_3_in_waitrequest_from_sa = niosII_openMac_clock_3_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_niosII_openMac_clock_3_in_waitrequest_from_sa <= niosII_openMac_clock_3_in_waitrequest;
  --niosII_openMac_clock_3_in_arb_share_counter set values, which is an e_mux
  niosII_openMac_clock_3_in_arb_share_set_values <= std_logic_vector'("01");
  --niosII_openMac_clock_3_in_non_bursting_master_requests mux, which is an e_mux
  niosII_openMac_clock_3_in_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_3_in;
  --niosII_openMac_clock_3_in_any_bursting_master_saved_grant mux, which is an e_mux
  niosII_openMac_clock_3_in_any_bursting_master_saved_grant <= std_logic'('0');
  --niosII_openMac_clock_3_in_arb_share_counter_next_value assignment, which is an e_assign
  niosII_openMac_clock_3_in_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(niosII_openMac_clock_3_in_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (niosII_openMac_clock_3_in_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(niosII_openMac_clock_3_in_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (niosII_openMac_clock_3_in_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --niosII_openMac_clock_3_in_allgrants all slave grants, which is an e_mux
  niosII_openMac_clock_3_in_allgrants <= niosII_openMac_clock_3_in_grant_vector;
  --niosII_openMac_clock_3_in_end_xfer assignment, which is an e_assign
  niosII_openMac_clock_3_in_end_xfer <= NOT ((niosII_openMac_clock_3_in_waits_for_read OR niosII_openMac_clock_3_in_waits_for_write));
  --end_xfer_arb_share_counter_term_niosII_openMac_clock_3_in arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_niosII_openMac_clock_3_in <= niosII_openMac_clock_3_in_end_xfer AND (((NOT niosII_openMac_clock_3_in_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --niosII_openMac_clock_3_in_arb_share_counter arbitration counter enable, which is an e_assign
  niosII_openMac_clock_3_in_arb_counter_enable <= ((end_xfer_arb_share_counter_term_niosII_openMac_clock_3_in AND niosII_openMac_clock_3_in_allgrants)) OR ((end_xfer_arb_share_counter_term_niosII_openMac_clock_3_in AND NOT niosII_openMac_clock_3_in_non_bursting_master_requests));
  --niosII_openMac_clock_3_in_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_3_in_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(niosII_openMac_clock_3_in_arb_counter_enable) = '1' then 
        niosII_openMac_clock_3_in_arb_share_counter <= niosII_openMac_clock_3_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_3_in_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_3_in_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((niosII_openMac_clock_3_in_master_qreq_vector AND end_xfer_arb_share_counter_term_niosII_openMac_clock_3_in)) OR ((end_xfer_arb_share_counter_term_niosII_openMac_clock_3_in AND NOT niosII_openMac_clock_3_in_non_bursting_master_requests)))) = '1' then 
        niosII_openMac_clock_3_in_slavearbiterlockenable <= or_reduce(niosII_openMac_clock_3_in_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --ap_cpu/data_master niosII_openMac_clock_3/in arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= niosII_openMac_clock_3_in_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --niosII_openMac_clock_3_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  niosII_openMac_clock_3_in_slavearbiterlockenable2 <= or_reduce(niosII_openMac_clock_3_in_arb_share_counter_next_value);
  --ap_cpu/data_master niosII_openMac_clock_3/in arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= niosII_openMac_clock_3_in_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --niosII_openMac_clock_3_in_any_continuerequest at least one master continues requesting, which is an e_assign
  niosII_openMac_clock_3_in_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_3_in AND NOT ((((ap_cpu_data_master_read AND (NOT ap_cpu_data_master_waitrequest))) OR (((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write))));
  --niosII_openMac_clock_3_in_writedata mux, which is an e_mux
  niosII_openMac_clock_3_in_writedata <= ap_cpu_data_master_writedata (7 DOWNTO 0);
  --assign niosII_openMac_clock_3_in_endofpacket_from_sa = niosII_openMac_clock_3_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_3_in_endofpacket_from_sa <= niosII_openMac_clock_3_in_endofpacket;
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_niosII_openMac_clock_3_in <= internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in;
  --ap_cpu/data_master saved-grant niosII_openMac_clock_3/in, which is an e_assign
  ap_cpu_data_master_saved_grant_niosII_openMac_clock_3_in <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_3_in;
  --allow new arb cycle for niosII_openMac_clock_3/in, which is an e_assign
  niosII_openMac_clock_3_in_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  niosII_openMac_clock_3_in_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  niosII_openMac_clock_3_in_master_qreq_vector <= std_logic'('1');
  --niosII_openMac_clock_3_in_reset_n assignment, which is an e_assign
  niosII_openMac_clock_3_in_reset_n <= reset_n;
  --niosII_openMac_clock_3_in_firsttransfer first transaction, which is an e_assign
  niosII_openMac_clock_3_in_firsttransfer <= A_WE_StdLogic((std_logic'(niosII_openMac_clock_3_in_begins_xfer) = '1'), niosII_openMac_clock_3_in_unreg_firsttransfer, niosII_openMac_clock_3_in_reg_firsttransfer);
  --niosII_openMac_clock_3_in_unreg_firsttransfer first transaction, which is an e_assign
  niosII_openMac_clock_3_in_unreg_firsttransfer <= NOT ((niosII_openMac_clock_3_in_slavearbiterlockenable AND niosII_openMac_clock_3_in_any_continuerequest));
  --niosII_openMac_clock_3_in_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_3_in_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(niosII_openMac_clock_3_in_begins_xfer) = '1' then 
        niosII_openMac_clock_3_in_reg_firsttransfer <= niosII_openMac_clock_3_in_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_3_in_beginbursttransfer_internal begin burst transfer, which is an e_assign
  niosII_openMac_clock_3_in_beginbursttransfer_internal <= niosII_openMac_clock_3_in_begins_xfer;
  --niosII_openMac_clock_3_in_read assignment, which is an e_mux
  niosII_openMac_clock_3_in_read <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_3_in AND ap_cpu_data_master_read;
  --niosII_openMac_clock_3_in_write assignment, which is an e_mux
  niosII_openMac_clock_3_in_write <= ((internal_ap_cpu_data_master_granted_niosII_openMac_clock_3_in AND ap_cpu_data_master_write)) AND niosII_openMac_clock_3_in_pretend_byte_enable;
  shifted_address_to_niosII_openMac_clock_3_in_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --niosII_openMac_clock_3_in_address mux, which is an e_mux
  niosII_openMac_clock_3_in_address <= A_EXT (A_SRL(shifted_address_to_niosII_openMac_clock_3_in_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --slaveid niosII_openMac_clock_3_in_nativeaddress nativeaddress mux, which is an e_mux
  niosII_openMac_clock_3_in_nativeaddress <= A_EXT (A_SRL(ap_cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_niosII_openMac_clock_3_in_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_niosII_openMac_clock_3_in_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_niosII_openMac_clock_3_in_end_xfer <= niosII_openMac_clock_3_in_end_xfer;
    end if;

  end process;

  --niosII_openMac_clock_3_in_waits_for_read in a cycle, which is an e_mux
  niosII_openMac_clock_3_in_waits_for_read <= niosII_openMac_clock_3_in_in_a_read_cycle AND internal_niosII_openMac_clock_3_in_waitrequest_from_sa;
  --niosII_openMac_clock_3_in_in_a_read_cycle assignment, which is an e_assign
  niosII_openMac_clock_3_in_in_a_read_cycle <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_3_in AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= niosII_openMac_clock_3_in_in_a_read_cycle;
  --niosII_openMac_clock_3_in_waits_for_write in a cycle, which is an e_mux
  niosII_openMac_clock_3_in_waits_for_write <= niosII_openMac_clock_3_in_in_a_write_cycle AND internal_niosII_openMac_clock_3_in_waitrequest_from_sa;
  --niosII_openMac_clock_3_in_in_a_write_cycle assignment, which is an e_assign
  niosII_openMac_clock_3_in_in_a_write_cycle <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_3_in AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= niosII_openMac_clock_3_in_in_a_write_cycle;
  wait_for_niosII_openMac_clock_3_in_counter <= std_logic'('0');
  --niosII_openMac_clock_3_in_pretend_byte_enable byte enable port mux, which is an e_mux
  niosII_openMac_clock_3_in_pretend_byte_enable <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_niosII_openMac_clock_3_in)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ap_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))));
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_niosII_openMac_clock_3_in <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_3_in;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in <= internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_niosII_openMac_clock_3_in <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_3_in;
  --vhdl renameroo for output signals
  niosII_openMac_clock_3_in_waitrequest_from_sa <= internal_niosII_openMac_clock_3_in_waitrequest_from_sa;
--synthesis translate_off
    --niosII_openMac_clock_3/in enable non-zero assertions, which is an e_register
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

entity niosII_openMac_clock_3_out_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal d1_lcd_control_slave_end_xfer : IN STD_LOGIC;
                 signal lcd_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal lcd_control_slave_wait_counter_eq_0 : IN STD_LOGIC;
                 signal niosII_openMac_clock_3_out_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal niosII_openMac_clock_3_out_granted_lcd_control_slave : IN STD_LOGIC;
                 signal niosII_openMac_clock_3_out_qualified_request_lcd_control_slave : IN STD_LOGIC;
                 signal niosII_openMac_clock_3_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_3_out_read_data_valid_lcd_control_slave : IN STD_LOGIC;
                 signal niosII_openMac_clock_3_out_requests_lcd_control_slave : IN STD_LOGIC;
                 signal niosII_openMac_clock_3_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_3_out_writedata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal niosII_openMac_clock_3_out_address_to_slave : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal niosII_openMac_clock_3_out_readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_3_out_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_3_out_waitrequest : OUT STD_LOGIC
              );
end entity niosII_openMac_clock_3_out_arbitrator;


architecture europa of niosII_openMac_clock_3_out_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_niosII_openMac_clock_3_out_address_to_slave :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_niosII_openMac_clock_3_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_address_last_time :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_3_out_read_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_run :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_write_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_writedata_last_time :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal r_1 :  STD_LOGIC;

begin

  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001") AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT niosII_openMac_clock_3_out_qualified_request_lcd_control_slave OR NOT niosII_openMac_clock_3_out_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((lcd_control_slave_wait_counter_eq_0 AND NOT d1_lcd_control_slave_end_xfer)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(niosII_openMac_clock_3_out_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT niosII_openMac_clock_3_out_qualified_request_lcd_control_slave OR NOT niosII_openMac_clock_3_out_write)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((lcd_control_slave_wait_counter_eq_0 AND NOT d1_lcd_control_slave_end_xfer)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(niosII_openMac_clock_3_out_write)))))))));
  --cascaded wait assignment, which is an e_assign
  niosII_openMac_clock_3_out_run <= r_1;
  --optimize select-logic by passing only those address bits which matter.
  internal_niosII_openMac_clock_3_out_address_to_slave <= niosII_openMac_clock_3_out_address;
  --niosII_openMac_clock_3/out readdata mux, which is an e_mux
  niosII_openMac_clock_3_out_readdata <= lcd_control_slave_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_niosII_openMac_clock_3_out_waitrequest <= NOT niosII_openMac_clock_3_out_run;
  --niosII_openMac_clock_3_out_reset_n assignment, which is an e_assign
  niosII_openMac_clock_3_out_reset_n <= reset_n;
  --vhdl renameroo for output signals
  niosII_openMac_clock_3_out_address_to_slave <= internal_niosII_openMac_clock_3_out_address_to_slave;
  --vhdl renameroo for output signals
  niosII_openMac_clock_3_out_waitrequest <= internal_niosII_openMac_clock_3_out_waitrequest;
--synthesis translate_off
    --niosII_openMac_clock_3_out_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_3_out_address_last_time <= std_logic_vector'("00");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_3_out_address_last_time <= niosII_openMac_clock_3_out_address;
      end if;

    end process;

    --niosII_openMac_clock_3/out waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_niosII_openMac_clock_3_out_waitrequest AND ((niosII_openMac_clock_3_out_read OR niosII_openMac_clock_3_out_write));
      end if;

    end process;

    --niosII_openMac_clock_3_out_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line21 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_3_out_address /= niosII_openMac_clock_3_out_address_last_time))))) = '1' then 
          write(write_line21, now);
          write(write_line21, string'(": "));
          write(write_line21, string'("niosII_openMac_clock_3_out_address did not heed wait!!!"));
          write(output, write_line21.all);
          deallocate (write_line21);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_3_out_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_3_out_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_3_out_read_last_time <= niosII_openMac_clock_3_out_read;
      end if;

    end process;

    --niosII_openMac_clock_3_out_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line22 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_3_out_read) /= std_logic'(niosII_openMac_clock_3_out_read_last_time)))))) = '1' then 
          write(write_line22, now);
          write(write_line22, string'(": "));
          write(write_line22, string'("niosII_openMac_clock_3_out_read did not heed wait!!!"));
          write(output, write_line22.all);
          deallocate (write_line22);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_3_out_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_3_out_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_3_out_write_last_time <= niosII_openMac_clock_3_out_write;
      end if;

    end process;

    --niosII_openMac_clock_3_out_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line23 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_3_out_write) /= std_logic'(niosII_openMac_clock_3_out_write_last_time)))))) = '1' then 
          write(write_line23, now);
          write(write_line23, string'(": "));
          write(write_line23, string'("niosII_openMac_clock_3_out_write did not heed wait!!!"));
          write(output, write_line23.all);
          deallocate (write_line23);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_3_out_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_3_out_writedata_last_time <= std_logic_vector'("00000000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_3_out_writedata_last_time <= niosII_openMac_clock_3_out_writedata;
      end if;

    end process;

    --niosII_openMac_clock_3_out_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line24 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_3_out_writedata /= niosII_openMac_clock_3_out_writedata_last_time)))) AND niosII_openMac_clock_3_out_write)) = '1' then 
          write(write_line24, now);
          write(write_line24, string'(": "));
          write(write_line24, string'("niosII_openMac_clock_3_out_writedata did not heed wait!!!"));
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

entity niosII_openMac_clock_4_in_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal niosII_openMac_clock_4_in_endofpacket : IN STD_LOGIC;
                 signal niosII_openMac_clock_4_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_4_in_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_niosII_openMac_clock_4_in : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_4_in : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_niosII_openMac_clock_4_in : OUT STD_LOGIC;
                 signal d1_niosII_openMac_clock_4_in_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_4_in_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_4_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_4_in_endofpacket_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_4_in_nativeaddress : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal niosII_openMac_clock_4_in_read : OUT STD_LOGIC;
                 signal niosII_openMac_clock_4_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_4_in_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_4_in_waitrequest_from_sa : OUT STD_LOGIC;
                 signal niosII_openMac_clock_4_in_write : OUT STD_LOGIC;
                 signal niosII_openMac_clock_4_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity niosII_openMac_clock_4_in_arbitrator;


architecture europa of niosII_openMac_clock_4_in_arbitrator is
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_niosII_openMac_clock_4_in :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_niosII_openMac_clock_4_in :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_niosII_openMac_clock_4_in :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_niosII_openMac_clock_4_in :  STD_LOGIC;
                signal internal_niosII_openMac_clock_4_in_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_allgrants :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_allow_new_arb_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_any_bursting_master_saved_grant :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_any_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_arb_counter_enable :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_4_in_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_4_in_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_4_in_beginbursttransfer_internal :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_begins_xfer :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_end_xfer :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_grant_vector :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_in_a_read_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_in_a_write_cycle :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_master_qreq_vector :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_non_bursting_master_requests :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_reg_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_slavearbiterlockenable :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_slavearbiterlockenable2 :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_unreg_firsttransfer :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_waits_for_read :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_waits_for_write :  STD_LOGIC;
                signal wait_for_niosII_openMac_clock_4_in_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT niosII_openMac_clock_4_in_end_xfer;
    end if;

  end process;

  niosII_openMac_clock_4_in_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in);
  --assign niosII_openMac_clock_4_in_readdata_from_sa = niosII_openMac_clock_4_in_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_4_in_readdata_from_sa <= niosII_openMac_clock_4_in_readdata;
  internal_ap_cpu_data_master_requests_niosII_openMac_clock_4_in <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000000100110000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --assign niosII_openMac_clock_4_in_waitrequest_from_sa = niosII_openMac_clock_4_in_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_niosII_openMac_clock_4_in_waitrequest_from_sa <= niosII_openMac_clock_4_in_waitrequest;
  --niosII_openMac_clock_4_in_arb_share_counter set values, which is an e_mux
  niosII_openMac_clock_4_in_arb_share_set_values <= std_logic_vector'("01");
  --niosII_openMac_clock_4_in_non_bursting_master_requests mux, which is an e_mux
  niosII_openMac_clock_4_in_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_4_in;
  --niosII_openMac_clock_4_in_any_bursting_master_saved_grant mux, which is an e_mux
  niosII_openMac_clock_4_in_any_bursting_master_saved_grant <= std_logic'('0');
  --niosII_openMac_clock_4_in_arb_share_counter_next_value assignment, which is an e_assign
  niosII_openMac_clock_4_in_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(niosII_openMac_clock_4_in_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (niosII_openMac_clock_4_in_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(niosII_openMac_clock_4_in_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (niosII_openMac_clock_4_in_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --niosII_openMac_clock_4_in_allgrants all slave grants, which is an e_mux
  niosII_openMac_clock_4_in_allgrants <= niosII_openMac_clock_4_in_grant_vector;
  --niosII_openMac_clock_4_in_end_xfer assignment, which is an e_assign
  niosII_openMac_clock_4_in_end_xfer <= NOT ((niosII_openMac_clock_4_in_waits_for_read OR niosII_openMac_clock_4_in_waits_for_write));
  --end_xfer_arb_share_counter_term_niosII_openMac_clock_4_in arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_niosII_openMac_clock_4_in <= niosII_openMac_clock_4_in_end_xfer AND (((NOT niosII_openMac_clock_4_in_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --niosII_openMac_clock_4_in_arb_share_counter arbitration counter enable, which is an e_assign
  niosII_openMac_clock_4_in_arb_counter_enable <= ((end_xfer_arb_share_counter_term_niosII_openMac_clock_4_in AND niosII_openMac_clock_4_in_allgrants)) OR ((end_xfer_arb_share_counter_term_niosII_openMac_clock_4_in AND NOT niosII_openMac_clock_4_in_non_bursting_master_requests));
  --niosII_openMac_clock_4_in_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_4_in_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(niosII_openMac_clock_4_in_arb_counter_enable) = '1' then 
        niosII_openMac_clock_4_in_arb_share_counter <= niosII_openMac_clock_4_in_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_4_in_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_4_in_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((niosII_openMac_clock_4_in_master_qreq_vector AND end_xfer_arb_share_counter_term_niosII_openMac_clock_4_in)) OR ((end_xfer_arb_share_counter_term_niosII_openMac_clock_4_in AND NOT niosII_openMac_clock_4_in_non_bursting_master_requests)))) = '1' then 
        niosII_openMac_clock_4_in_slavearbiterlockenable <= or_reduce(niosII_openMac_clock_4_in_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --ap_cpu/data_master niosII_openMac_clock_4/in arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= niosII_openMac_clock_4_in_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --niosII_openMac_clock_4_in_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  niosII_openMac_clock_4_in_slavearbiterlockenable2 <= or_reduce(niosII_openMac_clock_4_in_arb_share_counter_next_value);
  --ap_cpu/data_master niosII_openMac_clock_4/in arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= niosII_openMac_clock_4_in_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --niosII_openMac_clock_4_in_any_continuerequest at least one master continues requesting, which is an e_assign
  niosII_openMac_clock_4_in_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_4_in AND NOT ((((ap_cpu_data_master_read AND (NOT ap_cpu_data_master_waitrequest))) OR (((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write))));
  --niosII_openMac_clock_4_in_writedata mux, which is an e_mux
  niosII_openMac_clock_4_in_writedata <= ap_cpu_data_master_writedata;
  --assign niosII_openMac_clock_4_in_endofpacket_from_sa = niosII_openMac_clock_4_in_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  niosII_openMac_clock_4_in_endofpacket_from_sa <= niosII_openMac_clock_4_in_endofpacket;
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_niosII_openMac_clock_4_in <= internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in;
  --ap_cpu/data_master saved-grant niosII_openMac_clock_4/in, which is an e_assign
  ap_cpu_data_master_saved_grant_niosII_openMac_clock_4_in <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_4_in;
  --allow new arb cycle for niosII_openMac_clock_4/in, which is an e_assign
  niosII_openMac_clock_4_in_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  niosII_openMac_clock_4_in_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  niosII_openMac_clock_4_in_master_qreq_vector <= std_logic'('1');
  --niosII_openMac_clock_4_in_reset_n assignment, which is an e_assign
  niosII_openMac_clock_4_in_reset_n <= reset_n;
  --niosII_openMac_clock_4_in_firsttransfer first transaction, which is an e_assign
  niosII_openMac_clock_4_in_firsttransfer <= A_WE_StdLogic((std_logic'(niosII_openMac_clock_4_in_begins_xfer) = '1'), niosII_openMac_clock_4_in_unreg_firsttransfer, niosII_openMac_clock_4_in_reg_firsttransfer);
  --niosII_openMac_clock_4_in_unreg_firsttransfer first transaction, which is an e_assign
  niosII_openMac_clock_4_in_unreg_firsttransfer <= NOT ((niosII_openMac_clock_4_in_slavearbiterlockenable AND niosII_openMac_clock_4_in_any_continuerequest));
  --niosII_openMac_clock_4_in_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_4_in_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(niosII_openMac_clock_4_in_begins_xfer) = '1' then 
        niosII_openMac_clock_4_in_reg_firsttransfer <= niosII_openMac_clock_4_in_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_4_in_beginbursttransfer_internal begin burst transfer, which is an e_assign
  niosII_openMac_clock_4_in_beginbursttransfer_internal <= niosII_openMac_clock_4_in_begins_xfer;
  --niosII_openMac_clock_4_in_read assignment, which is an e_mux
  niosII_openMac_clock_4_in_read <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_4_in AND ap_cpu_data_master_read;
  --niosII_openMac_clock_4_in_write assignment, which is an e_mux
  niosII_openMac_clock_4_in_write <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_4_in AND ap_cpu_data_master_write;
  --niosII_openMac_clock_4_in_address mux, which is an e_mux
  niosII_openMac_clock_4_in_address <= ap_cpu_data_master_address_to_slave (3 DOWNTO 0);
  --slaveid niosII_openMac_clock_4_in_nativeaddress nativeaddress mux, which is an e_mux
  niosII_openMac_clock_4_in_nativeaddress <= A_EXT (A_SRL(ap_cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_niosII_openMac_clock_4_in_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_niosII_openMac_clock_4_in_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_niosII_openMac_clock_4_in_end_xfer <= niosII_openMac_clock_4_in_end_xfer;
    end if;

  end process;

  --niosII_openMac_clock_4_in_waits_for_read in a cycle, which is an e_mux
  niosII_openMac_clock_4_in_waits_for_read <= niosII_openMac_clock_4_in_in_a_read_cycle AND internal_niosII_openMac_clock_4_in_waitrequest_from_sa;
  --niosII_openMac_clock_4_in_in_a_read_cycle assignment, which is an e_assign
  niosII_openMac_clock_4_in_in_a_read_cycle <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_4_in AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= niosII_openMac_clock_4_in_in_a_read_cycle;
  --niosII_openMac_clock_4_in_waits_for_write in a cycle, which is an e_mux
  niosII_openMac_clock_4_in_waits_for_write <= niosII_openMac_clock_4_in_in_a_write_cycle AND internal_niosII_openMac_clock_4_in_waitrequest_from_sa;
  --niosII_openMac_clock_4_in_in_a_write_cycle assignment, which is an e_assign
  niosII_openMac_clock_4_in_in_a_write_cycle <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_4_in AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= niosII_openMac_clock_4_in_in_a_write_cycle;
  wait_for_niosII_openMac_clock_4_in_counter <= std_logic'('0');
  --niosII_openMac_clock_4_in_byteenable byte enable port mux, which is an e_mux
  niosII_openMac_clock_4_in_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_niosII_openMac_clock_4_in)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ap_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_niosII_openMac_clock_4_in <= internal_ap_cpu_data_master_granted_niosII_openMac_clock_4_in;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in <= internal_ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_niosII_openMac_clock_4_in <= internal_ap_cpu_data_master_requests_niosII_openMac_clock_4_in;
  --vhdl renameroo for output signals
  niosII_openMac_clock_4_in_waitrequest_from_sa <= internal_niosII_openMac_clock_4_in_waitrequest_from_sa;
--synthesis translate_off
    --niosII_openMac_clock_4/in enable non-zero assertions, which is an e_register
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

entity niosII_openMac_clock_4_out_arbitrator is 
        port (
              -- inputs:
                 signal altpll_0_pll_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal d1_altpll_0_pll_slave_end_xfer : IN STD_LOGIC;
                 signal niosII_openMac_clock_4_out_address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_4_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_4_out_granted_altpll_0_pll_slave : IN STD_LOGIC;
                 signal niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave : IN STD_LOGIC;
                 signal niosII_openMac_clock_4_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_4_out_read_data_valid_altpll_0_pll_slave : IN STD_LOGIC;
                 signal niosII_openMac_clock_4_out_requests_altpll_0_pll_slave : IN STD_LOGIC;
                 signal niosII_openMac_clock_4_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_4_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal niosII_openMac_clock_4_out_address_to_slave : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_4_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_4_out_reset_n : OUT STD_LOGIC;
                 signal niosII_openMac_clock_4_out_waitrequest : OUT STD_LOGIC
              );
end entity niosII_openMac_clock_4_out_arbitrator;


architecture europa of niosII_openMac_clock_4_out_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal internal_niosII_openMac_clock_4_out_address_to_slave :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_niosII_openMac_clock_4_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_address_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_4_out_byteenable_last_time :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_4_out_read_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_run :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_write_last_time :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_writedata_last_time :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal r_0 :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001") AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave OR NOT ((niosII_openMac_clock_4_out_read OR niosII_openMac_clock_4_out_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_4_out_read OR niosII_openMac_clock_4_out_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave OR NOT ((niosII_openMac_clock_4_out_read OR niosII_openMac_clock_4_out_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_4_out_read OR niosII_openMac_clock_4_out_write)))))))))));
  --cascaded wait assignment, which is an e_assign
  niosII_openMac_clock_4_out_run <= r_0;
  --optimize select-logic by passing only those address bits which matter.
  internal_niosII_openMac_clock_4_out_address_to_slave <= niosII_openMac_clock_4_out_address;
  --niosII_openMac_clock_4/out readdata mux, which is an e_mux
  niosII_openMac_clock_4_out_readdata <= altpll_0_pll_slave_readdata_from_sa;
  --actual waitrequest port, which is an e_assign
  internal_niosII_openMac_clock_4_out_waitrequest <= NOT niosII_openMac_clock_4_out_run;
  --niosII_openMac_clock_4_out_reset_n assignment, which is an e_assign
  niosII_openMac_clock_4_out_reset_n <= reset_n;
  --vhdl renameroo for output signals
  niosII_openMac_clock_4_out_address_to_slave <= internal_niosII_openMac_clock_4_out_address_to_slave;
  --vhdl renameroo for output signals
  niosII_openMac_clock_4_out_waitrequest <= internal_niosII_openMac_clock_4_out_waitrequest;
--synthesis translate_off
    --niosII_openMac_clock_4_out_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_4_out_address_last_time <= std_logic_vector'("0000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_4_out_address_last_time <= niosII_openMac_clock_4_out_address;
      end if;

    end process;

    --niosII_openMac_clock_4/out waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_niosII_openMac_clock_4_out_waitrequest AND ((niosII_openMac_clock_4_out_read OR niosII_openMac_clock_4_out_write));
      end if;

    end process;

    --niosII_openMac_clock_4_out_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line25 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_4_out_address /= niosII_openMac_clock_4_out_address_last_time))))) = '1' then 
          write(write_line25, now);
          write(write_line25, string'(": "));
          write(write_line25, string'("niosII_openMac_clock_4_out_address did not heed wait!!!"));
          write(output, write_line25.all);
          deallocate (write_line25);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_4_out_byteenable check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_4_out_byteenable_last_time <= std_logic_vector'("0000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_4_out_byteenable_last_time <= niosII_openMac_clock_4_out_byteenable;
      end if;

    end process;

    --niosII_openMac_clock_4_out_byteenable matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line26 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_4_out_byteenable /= niosII_openMac_clock_4_out_byteenable_last_time))))) = '1' then 
          write(write_line26, now);
          write(write_line26, string'(": "));
          write(write_line26, string'("niosII_openMac_clock_4_out_byteenable did not heed wait!!!"));
          write(output, write_line26.all);
          deallocate (write_line26);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_4_out_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_4_out_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_4_out_read_last_time <= niosII_openMac_clock_4_out_read;
      end if;

    end process;

    --niosII_openMac_clock_4_out_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line27 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_4_out_read) /= std_logic'(niosII_openMac_clock_4_out_read_last_time)))))) = '1' then 
          write(write_line27, now);
          write(write_line27, string'(": "));
          write(write_line27, string'("niosII_openMac_clock_4_out_read did not heed wait!!!"));
          write(output, write_line27.all);
          deallocate (write_line27);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_4_out_write check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_4_out_write_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_4_out_write_last_time <= niosII_openMac_clock_4_out_write;
      end if;

    end process;

    --niosII_openMac_clock_4_out_write matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line28 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(niosII_openMac_clock_4_out_write) /= std_logic'(niosII_openMac_clock_4_out_write_last_time)))))) = '1' then 
          write(write_line28, now);
          write(write_line28, string'(": "));
          write(write_line28, string'("niosII_openMac_clock_4_out_write did not heed wait!!!"));
          write(output, write_line28.all);
          deallocate (write_line28);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --niosII_openMac_clock_4_out_writedata check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        niosII_openMac_clock_4_out_writedata_last_time <= std_logic_vector'("00000000000000000000000000000000");
      elsif clk'event and clk = '1' then
        niosII_openMac_clock_4_out_writedata_last_time <= niosII_openMac_clock_4_out_writedata;
      end if;

    end process;

    --niosII_openMac_clock_4_out_writedata matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line29 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'(((active_and_waiting_last_time AND to_std_logic(((niosII_openMac_clock_4_out_writedata /= niosII_openMac_clock_4_out_writedata_last_time)))) AND niosII_openMac_clock_4_out_write)) = '1' then 
          write(write_line29, now);
          write(write_line29, string'(": "));
          write(write_line29, string'("niosII_openMac_clock_4_out_writedata did not heed wait!!!"));
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

library std;
use std.textio.all;

entity onchip_memory2_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC;
                 signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal onchip_memory2_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_granted_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal ap_cpu_instruction_master_requests_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal d1_onchip_memory2_0_s1_end_xfer : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_address : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal onchip_memory2_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal onchip_memory2_0_s1_chipselect : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_clken : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal onchip_memory2_0_s1_reset : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_write : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal registered_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC
              );
end entity onchip_memory2_0_s1_arbitrator;


architecture europa of onchip_memory2_0_s1_arbitrator is
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_onchip_memory2_0_s1 :  STD_LOGIC;
                signal ap_cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register_in :  STD_LOGIC;
                signal ap_cpu_instruction_master_saved_grant_onchip_memory2_0_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_onchip_memory2_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_granted_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_ap_cpu_instruction_master_requests_onchip_memory2_0_s1 :  STD_LOGIC;
                signal last_cycle_ap_cpu_data_master_granted_slave_onchip_memory2_0_s1 :  STD_LOGIC;
                signal last_cycle_ap_cpu_instruction_master_granted_slave_onchip_memory2_0_s1 :  STD_LOGIC;
                signal onchip_memory2_0_s1_allgrants :  STD_LOGIC;
                signal onchip_memory2_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal onchip_memory2_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal onchip_memory2_0_s1_any_continuerequest :  STD_LOGIC;
                signal onchip_memory2_0_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_arb_counter_enable :  STD_LOGIC;
                signal onchip_memory2_0_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_arbitration_holdoff_internal :  STD_LOGIC;
                signal onchip_memory2_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal onchip_memory2_0_s1_begins_xfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal onchip_memory2_0_s1_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_end_xfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_firsttransfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal onchip_memory2_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal onchip_memory2_0_s1_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal onchip_memory2_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal onchip_memory2_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal onchip_memory2_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_waits_for_read :  STD_LOGIC;
                signal onchip_memory2_0_s1_waits_for_write :  STD_LOGIC;
                signal p1_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register :  STD_LOGIC;
                signal p1_ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register :  STD_LOGIC;
                signal shifted_address_to_onchip_memory2_0_s1_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal shifted_address_to_onchip_memory2_0_s1_from_ap_cpu_instruction_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal wait_for_onchip_memory2_0_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT onchip_memory2_0_s1_end_xfer;
    end if;

  end process;

  onchip_memory2_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 OR internal_ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1));
  --assign onchip_memory2_0_s1_readdata_from_sa = onchip_memory2_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  onchip_memory2_0_s1_readdata_from_sa <= onchip_memory2_0_s1_readdata;
  internal_ap_cpu_data_master_requests_onchip_memory2_0_s1 <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 10) & std_logic_vector'("0000000000")) = std_logic_vector'("0000000000000010000000000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --registered rdv signal_name registered_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 assignment, which is an e_assign
  registered_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 <= ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in;
  --onchip_memory2_0_s1_arb_share_counter set values, which is an e_mux
  onchip_memory2_0_s1_arb_share_set_values <= std_logic_vector'("01");
  --onchip_memory2_0_s1_non_bursting_master_requests mux, which is an e_mux
  onchip_memory2_0_s1_non_bursting_master_requests <= ((internal_ap_cpu_data_master_requests_onchip_memory2_0_s1 OR internal_ap_cpu_instruction_master_requests_onchip_memory2_0_s1) OR internal_ap_cpu_data_master_requests_onchip_memory2_0_s1) OR internal_ap_cpu_instruction_master_requests_onchip_memory2_0_s1;
  --onchip_memory2_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  onchip_memory2_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --onchip_memory2_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  onchip_memory2_0_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(onchip_memory2_0_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (onchip_memory2_0_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(onchip_memory2_0_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (onchip_memory2_0_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --onchip_memory2_0_s1_allgrants all slave grants, which is an e_mux
  onchip_memory2_0_s1_allgrants <= (((or_reduce(onchip_memory2_0_s1_grant_vector)) OR (or_reduce(onchip_memory2_0_s1_grant_vector))) OR (or_reduce(onchip_memory2_0_s1_grant_vector))) OR (or_reduce(onchip_memory2_0_s1_grant_vector));
  --onchip_memory2_0_s1_end_xfer assignment, which is an e_assign
  onchip_memory2_0_s1_end_xfer <= NOT ((onchip_memory2_0_s1_waits_for_read OR onchip_memory2_0_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_onchip_memory2_0_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_onchip_memory2_0_s1 <= onchip_memory2_0_s1_end_xfer AND (((NOT onchip_memory2_0_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --onchip_memory2_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  onchip_memory2_0_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_onchip_memory2_0_s1 AND onchip_memory2_0_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_onchip_memory2_0_s1 AND NOT onchip_memory2_0_s1_non_bursting_master_requests));
  --onchip_memory2_0_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_arb_share_counter <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_memory2_0_s1_arb_counter_enable) = '1' then 
        onchip_memory2_0_s1_arb_share_counter <= onchip_memory2_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --onchip_memory2_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(onchip_memory2_0_s1_master_qreq_vector) AND end_xfer_arb_share_counter_term_onchip_memory2_0_s1)) OR ((end_xfer_arb_share_counter_term_onchip_memory2_0_s1 AND NOT onchip_memory2_0_s1_non_bursting_master_requests)))) = '1' then 
        onchip_memory2_0_s1_slavearbiterlockenable <= or_reduce(onchip_memory2_0_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --ap_cpu/data_master onchip_memory2_0/s1 arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= onchip_memory2_0_s1_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --onchip_memory2_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  onchip_memory2_0_s1_slavearbiterlockenable2 <= or_reduce(onchip_memory2_0_s1_arb_share_counter_next_value);
  --ap_cpu/data_master onchip_memory2_0/s1 arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= onchip_memory2_0_s1_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --ap_cpu/instruction_master onchip_memory2_0/s1 arbiterlock, which is an e_assign
  ap_cpu_instruction_master_arbiterlock <= onchip_memory2_0_s1_slavearbiterlockenable AND ap_cpu_instruction_master_continuerequest;
  --ap_cpu/instruction_master onchip_memory2_0/s1 arbiterlock2, which is an e_assign
  ap_cpu_instruction_master_arbiterlock2 <= onchip_memory2_0_s1_slavearbiterlockenable2 AND ap_cpu_instruction_master_continuerequest;
  --ap_cpu/instruction_master granted onchip_memory2_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ap_cpu_instruction_master_granted_slave_onchip_memory2_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_ap_cpu_instruction_master_granted_slave_onchip_memory2_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ap_cpu_instruction_master_saved_grant_onchip_memory2_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_memory2_0_s1_arbitration_holdoff_internal OR NOT internal_ap_cpu_instruction_master_requests_onchip_memory2_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ap_cpu_instruction_master_granted_slave_onchip_memory2_0_s1))))));
    end if;

  end process;

  --ap_cpu_instruction_master_continuerequest continued request, which is an e_mux
  ap_cpu_instruction_master_continuerequest <= last_cycle_ap_cpu_instruction_master_granted_slave_onchip_memory2_0_s1 AND internal_ap_cpu_instruction_master_requests_onchip_memory2_0_s1;
  --onchip_memory2_0_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  onchip_memory2_0_s1_any_continuerequest <= ap_cpu_instruction_master_continuerequest OR ap_cpu_data_master_continuerequest;
  internal_ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 <= internal_ap_cpu_data_master_requests_onchip_memory2_0_s1 AND NOT (((((ap_cpu_data_master_read AND (ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register))) OR (((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write))) OR ap_cpu_instruction_master_arbiterlock));
  --ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in <= ((internal_ap_cpu_data_master_granted_onchip_memory2_0_s1 AND ap_cpu_data_master_read) AND NOT onchip_memory2_0_s1_waits_for_read) AND NOT (ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register);
  --shift register p1 ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register) & A_ToStdLogicVector(ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in)));
  --ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register <= p1_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register;
    end if;

  end process;

  --local readdatavalid ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1, which is an e_mux
  ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 <= ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1_shift_register;
  --onchip_memory2_0_s1_writedata mux, which is an e_mux
  onchip_memory2_0_s1_writedata <= ap_cpu_data_master_writedata;
  --mux onchip_memory2_0_s1_clken, which is an e_mux
  onchip_memory2_0_s1_clken <= std_logic'('1');
  internal_ap_cpu_instruction_master_requests_onchip_memory2_0_s1 <= ((to_std_logic(((Std_Logic_Vector'(ap_cpu_instruction_master_address_to_slave(27 DOWNTO 10) & std_logic_vector'("0000000000")) = std_logic_vector'("0000000000000010000000000000")))) AND (ap_cpu_instruction_master_read))) AND ap_cpu_instruction_master_read;
  --ap_cpu/data_master granted onchip_memory2_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_ap_cpu_data_master_granted_slave_onchip_memory2_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_ap_cpu_data_master_granted_slave_onchip_memory2_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ap_cpu_data_master_saved_grant_onchip_memory2_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_memory2_0_s1_arbitration_holdoff_internal OR NOT internal_ap_cpu_data_master_requests_onchip_memory2_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_ap_cpu_data_master_granted_slave_onchip_memory2_0_s1))))));
    end if;

  end process;

  --ap_cpu_data_master_continuerequest continued request, which is an e_mux
  ap_cpu_data_master_continuerequest <= last_cycle_ap_cpu_data_master_granted_slave_onchip_memory2_0_s1 AND internal_ap_cpu_data_master_requests_onchip_memory2_0_s1;
  internal_ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1 <= internal_ap_cpu_instruction_master_requests_onchip_memory2_0_s1 AND NOT ((((ap_cpu_instruction_master_read AND to_std_logic(((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_latency_counter)))))))) OR ap_cpu_data_master_arbiterlock));
  --ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register_in <= (internal_ap_cpu_instruction_master_granted_onchip_memory2_0_s1 AND ap_cpu_instruction_master_read) AND NOT onchip_memory2_0_s1_waits_for_read;
  --shift register p1 ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register) & A_ToStdLogicVector(ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register_in)));
  --ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register <= p1_ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register;
    end if;

  end process;

  --local readdatavalid ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1, which is an e_mux
  ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1 <= ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register;
  --allow new arb cycle for onchip_memory2_0/s1, which is an e_assign
  onchip_memory2_0_s1_allow_new_arb_cycle <= NOT ap_cpu_data_master_arbiterlock AND NOT ap_cpu_instruction_master_arbiterlock;
  --ap_cpu/instruction_master assignment into master qualified-requests vector for onchip_memory2_0/s1, which is an e_assign
  onchip_memory2_0_s1_master_qreq_vector(0) <= internal_ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1;
  --ap_cpu/instruction_master grant onchip_memory2_0/s1, which is an e_assign
  internal_ap_cpu_instruction_master_granted_onchip_memory2_0_s1 <= onchip_memory2_0_s1_grant_vector(0);
  --ap_cpu/instruction_master saved-grant onchip_memory2_0/s1, which is an e_assign
  ap_cpu_instruction_master_saved_grant_onchip_memory2_0_s1 <= onchip_memory2_0_s1_arb_winner(0) AND internal_ap_cpu_instruction_master_requests_onchip_memory2_0_s1;
  --ap_cpu/data_master assignment into master qualified-requests vector for onchip_memory2_0/s1, which is an e_assign
  onchip_memory2_0_s1_master_qreq_vector(1) <= internal_ap_cpu_data_master_qualified_request_onchip_memory2_0_s1;
  --ap_cpu/data_master grant onchip_memory2_0/s1, which is an e_assign
  internal_ap_cpu_data_master_granted_onchip_memory2_0_s1 <= onchip_memory2_0_s1_grant_vector(1);
  --ap_cpu/data_master saved-grant onchip_memory2_0/s1, which is an e_assign
  ap_cpu_data_master_saved_grant_onchip_memory2_0_s1 <= onchip_memory2_0_s1_arb_winner(1) AND internal_ap_cpu_data_master_requests_onchip_memory2_0_s1;
  --onchip_memory2_0/s1 chosen-master double-vector, which is an e_assign
  onchip_memory2_0_s1_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((onchip_memory2_0_s1_master_qreq_vector & onchip_memory2_0_s1_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT onchip_memory2_0_s1_master_qreq_vector & NOT onchip_memory2_0_s1_master_qreq_vector))) + (std_logic_vector'("000") & (onchip_memory2_0_s1_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  onchip_memory2_0_s1_arb_winner <= A_WE_StdLogicVector((std_logic'(((onchip_memory2_0_s1_allow_new_arb_cycle AND or_reduce(onchip_memory2_0_s1_grant_vector)))) = '1'), onchip_memory2_0_s1_grant_vector, onchip_memory2_0_s1_saved_chosen_master_vector);
  --saved onchip_memory2_0_s1_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_memory2_0_s1_allow_new_arb_cycle) = '1' then 
        onchip_memory2_0_s1_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(onchip_memory2_0_s1_grant_vector)) = '1'), onchip_memory2_0_s1_grant_vector, onchip_memory2_0_s1_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  onchip_memory2_0_s1_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((onchip_memory2_0_s1_chosen_master_double_vector(1) OR onchip_memory2_0_s1_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((onchip_memory2_0_s1_chosen_master_double_vector(0) OR onchip_memory2_0_s1_chosen_master_double_vector(2)))));
  --onchip_memory2_0/s1 chosen master rotated left, which is an e_assign
  onchip_memory2_0_s1_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(onchip_memory2_0_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(onchip_memory2_0_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --onchip_memory2_0/s1's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(onchip_memory2_0_s1_grant_vector)) = '1' then 
        onchip_memory2_0_s1_arb_addend <= A_WE_StdLogicVector((std_logic'(onchip_memory2_0_s1_end_xfer) = '1'), onchip_memory2_0_s1_chosen_master_rot_left, onchip_memory2_0_s1_grant_vector);
      end if;
    end if;

  end process;

  --~onchip_memory2_0_s1_reset assignment, which is an e_assign
  onchip_memory2_0_s1_reset <= NOT reset_n;
  onchip_memory2_0_s1_chipselect <= internal_ap_cpu_data_master_granted_onchip_memory2_0_s1 OR internal_ap_cpu_instruction_master_granted_onchip_memory2_0_s1;
  --onchip_memory2_0_s1_firsttransfer first transaction, which is an e_assign
  onchip_memory2_0_s1_firsttransfer <= A_WE_StdLogic((std_logic'(onchip_memory2_0_s1_begins_xfer) = '1'), onchip_memory2_0_s1_unreg_firsttransfer, onchip_memory2_0_s1_reg_firsttransfer);
  --onchip_memory2_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  onchip_memory2_0_s1_unreg_firsttransfer <= NOT ((onchip_memory2_0_s1_slavearbiterlockenable AND onchip_memory2_0_s1_any_continuerequest));
  --onchip_memory2_0_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_memory2_0_s1_begins_xfer) = '1' then 
        onchip_memory2_0_s1_reg_firsttransfer <= onchip_memory2_0_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --onchip_memory2_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  onchip_memory2_0_s1_beginbursttransfer_internal <= onchip_memory2_0_s1_begins_xfer;
  --onchip_memory2_0_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  onchip_memory2_0_s1_arbitration_holdoff_internal <= onchip_memory2_0_s1_begins_xfer AND onchip_memory2_0_s1_firsttransfer;
  --onchip_memory2_0_s1_write assignment, which is an e_mux
  onchip_memory2_0_s1_write <= internal_ap_cpu_data_master_granted_onchip_memory2_0_s1 AND ap_cpu_data_master_write;
  shifted_address_to_onchip_memory2_0_s1_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --onchip_memory2_0_s1_address mux, which is an e_mux
  onchip_memory2_0_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_onchip_memory2_0_s1)) = '1'), (A_SRL(shifted_address_to_onchip_memory2_0_s1_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_onchip_memory2_0_s1_from_ap_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 8);
  shifted_address_to_onchip_memory2_0_s1_from_ap_cpu_instruction_master <= ap_cpu_instruction_master_address_to_slave;
  --d1_onchip_memory2_0_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_onchip_memory2_0_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_onchip_memory2_0_s1_end_xfer <= onchip_memory2_0_s1_end_xfer;
    end if;

  end process;

  --onchip_memory2_0_s1_waits_for_read in a cycle, which is an e_mux
  onchip_memory2_0_s1_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_memory2_0_s1_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_memory2_0_s1_in_a_read_cycle assignment, which is an e_assign
  onchip_memory2_0_s1_in_a_read_cycle <= ((internal_ap_cpu_data_master_granted_onchip_memory2_0_s1 AND ap_cpu_data_master_read)) OR ((internal_ap_cpu_instruction_master_granted_onchip_memory2_0_s1 AND ap_cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= onchip_memory2_0_s1_in_a_read_cycle;
  --onchip_memory2_0_s1_waits_for_write in a cycle, which is an e_mux
  onchip_memory2_0_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_memory2_0_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_memory2_0_s1_in_a_write_cycle assignment, which is an e_assign
  onchip_memory2_0_s1_in_a_write_cycle <= internal_ap_cpu_data_master_granted_onchip_memory2_0_s1 AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= onchip_memory2_0_s1_in_a_write_cycle;
  wait_for_onchip_memory2_0_s1_counter <= std_logic'('0');
  --onchip_memory2_0_s1_byteenable byte enable port mux, which is an e_mux
  onchip_memory2_0_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_onchip_memory2_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (ap_cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_onchip_memory2_0_s1 <= internal_ap_cpu_data_master_granted_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 <= internal_ap_cpu_data_master_qualified_request_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_onchip_memory2_0_s1 <= internal_ap_cpu_data_master_requests_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_granted_onchip_memory2_0_s1 <= internal_ap_cpu_instruction_master_granted_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1 <= internal_ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  ap_cpu_instruction_master_requests_onchip_memory2_0_s1 <= internal_ap_cpu_instruction_master_requests_onchip_memory2_0_s1;
--synthesis translate_off
    --onchip_memory2_0/s1 enable non-zero assertions, which is an e_register
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
    VARIABLE write_line30 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ap_cpu_data_master_granted_onchip_memory2_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_ap_cpu_instruction_master_granted_onchip_memory2_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line30, now);
          write(write_line30, string'(": "));
          write(write_line30, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line30.all);
          deallocate (write_line30);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line31 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_saved_grant_onchip_memory2_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(ap_cpu_instruction_master_saved_grant_onchip_memory2_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line31, now);
          write(write_line31, string'(": "));
          write(write_line31, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line31.all);
          deallocate (write_line31);
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
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal outport_ap_s1_readdata : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_outport_ap_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_outport_ap_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_outport_ap_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_outport_ap_s1 : OUT STD_LOGIC;
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
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_outport_ap_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_outport_ap_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_outport_ap_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_outport_ap_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_outport_ap_s1 :  STD_LOGIC;
                signal outport_ap_s1_allgrants :  STD_LOGIC;
                signal outport_ap_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal outport_ap_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal outport_ap_s1_any_continuerequest :  STD_LOGIC;
                signal outport_ap_s1_arb_counter_enable :  STD_LOGIC;
                signal outport_ap_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal outport_ap_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal outport_ap_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
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
                signal shifted_address_to_outport_ap_s1_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
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

  outport_ap_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_outport_ap_s1);
  --assign outport_ap_s1_readdata_from_sa = outport_ap_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  outport_ap_s1_readdata_from_sa <= outport_ap_s1_readdata;
  internal_ap_cpu_data_master_requests_outport_ap_s1 <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000000100101000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --outport_ap_s1_arb_share_counter set values, which is an e_mux
  outport_ap_s1_arb_share_set_values <= std_logic_vector'("01");
  --outport_ap_s1_non_bursting_master_requests mux, which is an e_mux
  outport_ap_s1_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_outport_ap_s1;
  --outport_ap_s1_any_bursting_master_saved_grant mux, which is an e_mux
  outport_ap_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --outport_ap_s1_arb_share_counter_next_value assignment, which is an e_assign
  outport_ap_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(outport_ap_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (outport_ap_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(outport_ap_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (outport_ap_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
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
      outport_ap_s1_arb_share_counter <= std_logic_vector'("00");
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
        outport_ap_s1_slavearbiterlockenable <= or_reduce(outport_ap_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --ap_cpu/data_master outport_ap/s1 arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= outport_ap_s1_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --outport_ap_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  outport_ap_s1_slavearbiterlockenable2 <= or_reduce(outport_ap_s1_arb_share_counter_next_value);
  --ap_cpu/data_master outport_ap/s1 arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= outport_ap_s1_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --outport_ap_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  outport_ap_s1_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_outport_ap_s1 <= internal_ap_cpu_data_master_requests_outport_ap_s1 AND NOT (((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write));
  --outport_ap_s1_writedata mux, which is an e_mux
  outport_ap_s1_writedata <= ap_cpu_data_master_writedata (23 DOWNTO 0);
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_outport_ap_s1 <= internal_ap_cpu_data_master_qualified_request_outport_ap_s1;
  --ap_cpu/data_master saved-grant outport_ap/s1, which is an e_assign
  ap_cpu_data_master_saved_grant_outport_ap_s1 <= internal_ap_cpu_data_master_requests_outport_ap_s1;
  --allow new arb cycle for outport_ap/s1, which is an e_assign
  outport_ap_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  outport_ap_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  outport_ap_s1_master_qreq_vector <= std_logic'('1');
  --outport_ap_s1_reset_n assignment, which is an e_assign
  outport_ap_s1_reset_n <= reset_n;
  outport_ap_s1_chipselect <= internal_ap_cpu_data_master_granted_outport_ap_s1;
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
  outport_ap_s1_write_n <= NOT ((internal_ap_cpu_data_master_granted_outport_ap_s1 AND ap_cpu_data_master_write));
  shifted_address_to_outport_ap_s1_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --outport_ap_s1_address mux, which is an e_mux
  outport_ap_s1_address <= A_EXT (A_SRL(shifted_address_to_outport_ap_s1_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
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
  outport_ap_s1_in_a_read_cycle <= internal_ap_cpu_data_master_granted_outport_ap_s1 AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= outport_ap_s1_in_a_read_cycle;
  --outport_ap_s1_waits_for_write in a cycle, which is an e_mux
  outport_ap_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(outport_ap_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --outport_ap_s1_in_a_write_cycle assignment, which is an e_assign
  outport_ap_s1_in_a_write_cycle <= internal_ap_cpu_data_master_granted_outport_ap_s1 AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= outport_ap_s1_in_a_write_cycle;
  wait_for_outport_ap_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_outport_ap_s1 <= internal_ap_cpu_data_master_granted_outport_ap_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_outport_ap_s1 <= internal_ap_cpu_data_master_qualified_request_outport_ap_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_outport_ap_s1 <= internal_ap_cpu_data_master_requests_outport_ap_s1;
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

entity remote_update_cycloneiii_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal niosII_openMac_clock_2_out_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal niosII_openMac_clock_2_out_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                 signal niosII_openMac_clock_2_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_2_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_2_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal remote_update_cycloneiii_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal remote_update_cycloneiii_0_s1_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal d1_remote_update_cycloneiii_0_s1_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                 signal niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                 signal niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                 signal niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
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
                signal internal_niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal internal_niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal internal_niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal internal_remote_update_cycloneiii_0_s1_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_arbiterlock :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_arbiterlock2 :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register_in :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_saved_grant_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal p1_niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
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

  remote_update_cycloneiii_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1);
  --assign remote_update_cycloneiii_0_s1_readdata_from_sa = remote_update_cycloneiii_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  remote_update_cycloneiii_0_s1_readdata_from_sa <= remote_update_cycloneiii_0_s1_readdata;
  internal_niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_2_out_read OR niosII_openMac_clock_2_out_write)))))));
  --assign remote_update_cycloneiii_0_s1_waitrequest_from_sa = remote_update_cycloneiii_0_s1_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_remote_update_cycloneiii_0_s1_waitrequest_from_sa <= remote_update_cycloneiii_0_s1_waitrequest;
  --remote_update_cycloneiii_0_s1_arb_share_counter set values, which is an e_mux
  remote_update_cycloneiii_0_s1_arb_share_set_values <= std_logic'('1');
  --remote_update_cycloneiii_0_s1_non_bursting_master_requests mux, which is an e_mux
  remote_update_cycloneiii_0_s1_non_bursting_master_requests <= internal_niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1;
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

  --niosII_openMac_clock_2/out remote_update_cycloneiii_0/s1 arbiterlock, which is an e_assign
  niosII_openMac_clock_2_out_arbiterlock <= remote_update_cycloneiii_0_s1_slavearbiterlockenable AND niosII_openMac_clock_2_out_continuerequest;
  --remote_update_cycloneiii_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  remote_update_cycloneiii_0_s1_slavearbiterlockenable2 <= remote_update_cycloneiii_0_s1_arb_share_counter_next_value;
  --niosII_openMac_clock_2/out remote_update_cycloneiii_0/s1 arbiterlock2, which is an e_assign
  niosII_openMac_clock_2_out_arbiterlock2 <= remote_update_cycloneiii_0_s1_slavearbiterlockenable2 AND niosII_openMac_clock_2_out_continuerequest;
  --remote_update_cycloneiii_0_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  remote_update_cycloneiii_0_s1_any_continuerequest <= std_logic'('1');
  --niosII_openMac_clock_2_out_continuerequest continued request, which is an e_assign
  niosII_openMac_clock_2_out_continuerequest <= std_logic'('1');
  internal_niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1 <= internal_niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1 AND NOT ((niosII_openMac_clock_2_out_read AND (or_reduce(niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register))));
  --niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register_in <= ((internal_niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 AND niosII_openMac_clock_2_out_read) AND NOT remote_update_cycloneiii_0_s1_waits_for_read) AND NOT (or_reduce(niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register));
  --shift register p1 niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register <= A_EXT ((niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register & A_ToStdLogicVector(niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register_in)), 2);
  --niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register <= p1_niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register;
    end if;

  end process;

  --local readdatavalid niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1, which is an e_mux
  niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1 <= niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1_shift_register(1);
  --remote_update_cycloneiii_0_s1_writedata mux, which is an e_mux
  remote_update_cycloneiii_0_s1_writedata <= niosII_openMac_clock_2_out_writedata;
  --master is always granted when requested
  internal_niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 <= internal_niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1;
  --niosII_openMac_clock_2/out saved-grant remote_update_cycloneiii_0/s1, which is an e_assign
  niosII_openMac_clock_2_out_saved_grant_remote_update_cycloneiii_0_s1 <= internal_niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1;
  --allow new arb cycle for remote_update_cycloneiii_0/s1, which is an e_assign
  remote_update_cycloneiii_0_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  remote_update_cycloneiii_0_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  remote_update_cycloneiii_0_s1_master_qreq_vector <= std_logic'('1');
  --~remote_update_cycloneiii_0_s1_reset assignment, which is an e_assign
  remote_update_cycloneiii_0_s1_reset <= NOT reset_n;
  remote_update_cycloneiii_0_s1_chipselect <= internal_niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1;
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
  remote_update_cycloneiii_0_s1_read <= internal_niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 AND niosII_openMac_clock_2_out_read;
  --remote_update_cycloneiii_0_s1_write assignment, which is an e_mux
  remote_update_cycloneiii_0_s1_write <= internal_niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 AND niosII_openMac_clock_2_out_write;
  --remote_update_cycloneiii_0_s1_address mux, which is an e_mux
  remote_update_cycloneiii_0_s1_address <= niosII_openMac_clock_2_out_nativeaddress;
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
  remote_update_cycloneiii_0_s1_in_a_read_cycle <= internal_niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 AND niosII_openMac_clock_2_out_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= remote_update_cycloneiii_0_s1_in_a_read_cycle;
  --remote_update_cycloneiii_0_s1_waits_for_write in a cycle, which is an e_mux
  remote_update_cycloneiii_0_s1_waits_for_write <= remote_update_cycloneiii_0_s1_in_a_write_cycle AND internal_remote_update_cycloneiii_0_s1_waitrequest_from_sa;
  --remote_update_cycloneiii_0_s1_in_a_write_cycle assignment, which is an e_assign
  remote_update_cycloneiii_0_s1_in_a_write_cycle <= internal_niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 AND niosII_openMac_clock_2_out_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= remote_update_cycloneiii_0_s1_in_a_write_cycle;
  wait_for_remote_update_cycloneiii_0_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 <= internal_niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1;
  --vhdl renameroo for output signals
  niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1 <= internal_niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1;
  --vhdl renameroo for output signals
  niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1 <= internal_niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1;
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

entity rdv_fifo_for_niosII_openMac_clock_0_out_to_sdram_0_s1_module is 
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
end entity rdv_fifo_for_niosII_openMac_clock_0_out_to_sdram_0_s1_module;


architecture europa of rdv_fifo_for_niosII_openMac_clock_0_out_to_sdram_0_s1_module is
                signal full_0 :  STD_LOGIC;
                signal full_1 :  STD_LOGIC;
                signal full_2 :  STD_LOGIC;
                signal full_3 :  STD_LOGIC;
                signal full_4 :  STD_LOGIC;
                signal full_5 :  STD_LOGIC;
                signal full_6 :  STD_LOGIC;
                signal how_many_ones :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal one_count_minus_one :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal one_count_plus_one :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal p0_full_0 :  STD_LOGIC;
                signal p0_stage_0 :  STD_LOGIC;
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC;
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC;
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC;
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC;
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC;
                signal stage_0 :  STD_LOGIC;
                signal stage_1 :  STD_LOGIC;
                signal stage_2 :  STD_LOGIC;
                signal stage_3 :  STD_LOGIC;
                signal stage_4 :  STD_LOGIC;
                signal stage_5 :  STD_LOGIC;
                signal updated_one_count :  STD_LOGIC_VECTOR (3 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_5;
  empty <= NOT(full_0);
  full_6 <= std_logic'('0');
  --data_5, which is an e_mux
  p5_stage_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
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
  p5_full_5 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))), std_logic_vector'("00000000000000000000000000000000")));
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

  one_count_plus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000000") & (how_many_ones)) + std_logic_vector'("000000000000000000000000000000001")), 4);
  one_count_minus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000000") & (how_many_ones)) - std_logic_vector'("000000000000000000000000000000001")), 4);
  --updated_one_count, which is an e_mux
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000") & (A_TOSTDLOGICVECTOR(data_in))), A_WE_StdLogicVector((std_logic'(((((read AND (data_in)) AND write) AND (stage_0)))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (data_in)))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (stage_0)))) = '1'), one_count_minus_one, how_many_ones))))))), 4);
  --counts how many ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      how_many_ones <= std_logic_vector'("0000");
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

entity rdv_fifo_for_niosII_openMac_clock_1_out_to_sdram_0_s1_module is 
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
end entity rdv_fifo_for_niosII_openMac_clock_1_out_to_sdram_0_s1_module;


architecture europa of rdv_fifo_for_niosII_openMac_clock_1_out_to_sdram_0_s1_module is
                signal full_0 :  STD_LOGIC;
                signal full_1 :  STD_LOGIC;
                signal full_2 :  STD_LOGIC;
                signal full_3 :  STD_LOGIC;
                signal full_4 :  STD_LOGIC;
                signal full_5 :  STD_LOGIC;
                signal full_6 :  STD_LOGIC;
                signal how_many_ones :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal one_count_minus_one :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal one_count_plus_one :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal p0_full_0 :  STD_LOGIC;
                signal p0_stage_0 :  STD_LOGIC;
                signal p1_full_1 :  STD_LOGIC;
                signal p1_stage_1 :  STD_LOGIC;
                signal p2_full_2 :  STD_LOGIC;
                signal p2_stage_2 :  STD_LOGIC;
                signal p3_full_3 :  STD_LOGIC;
                signal p3_stage_3 :  STD_LOGIC;
                signal p4_full_4 :  STD_LOGIC;
                signal p4_stage_4 :  STD_LOGIC;
                signal p5_full_5 :  STD_LOGIC;
                signal p5_stage_5 :  STD_LOGIC;
                signal stage_0 :  STD_LOGIC;
                signal stage_1 :  STD_LOGIC;
                signal stage_2 :  STD_LOGIC;
                signal stage_3 :  STD_LOGIC;
                signal stage_4 :  STD_LOGIC;
                signal stage_5 :  STD_LOGIC;
                signal updated_one_count :  STD_LOGIC_VECTOR (3 DOWNTO 0);

begin

  data_out <= stage_0;
  full <= full_5;
  empty <= NOT(full_0);
  full_6 <= std_logic'('0');
  --data_5, which is an e_mux
  p5_stage_5 <= A_WE_StdLogic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((full_6 AND NOT clear_fifo))))) = std_logic_vector'("00000000000000000000000000000000"))), data_in, data_in);
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
  p5_full_5 <= Vector_To_Std_Logic(A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((read AND NOT(write)))))) = std_logic_vector'("00000000000000000000000000000000"))), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(full_4))), std_logic_vector'("00000000000000000000000000000000")));
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

  one_count_plus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000000") & (how_many_ones)) + std_logic_vector'("000000000000000000000000000000001")), 4);
  one_count_minus_one <= A_EXT (((std_logic_vector'("00000000000000000000000000000") & (how_many_ones)) - std_logic_vector'("000000000000000000000000000000001")), 4);
  --updated_one_count, which is an e_mux
  updated_one_count <= A_EXT (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND NOT(write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000") & (A_WE_StdLogicVector((std_logic'(((((clear_fifo OR sync_reset)) AND write))) = '1'), (std_logic_vector'("000") & (A_TOSTDLOGICVECTOR(data_in))), A_WE_StdLogicVector((std_logic'(((((read AND (data_in)) AND write) AND (stage_0)))) = '1'), how_many_ones, A_WE_StdLogicVector((std_logic'(((write AND (data_in)))) = '1'), one_count_plus_one, A_WE_StdLogicVector((std_logic'(((read AND (stage_0)))) = '1'), one_count_minus_one, how_many_ones))))))), 4);
  --counts how many ones in the data pipeline, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      how_many_ones <= std_logic_vector'("0000");
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

library std;
use std.textio.all;

entity sdram_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal niosII_openMac_clock_0_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_0_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_0_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal niosII_openMac_clock_1_out_read : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_write : IN STD_LOGIC;
                 signal niosII_openMac_clock_1_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal sdram_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal sdram_0_s1_readdatavalid : IN STD_LOGIC;
                 signal sdram_0_s1_waitrequest : IN STD_LOGIC;

              -- outputs:
                 signal d1_sdram_0_s1_end_xfer : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_out_granted_sdram_0_s1 : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1 : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register : OUT STD_LOGIC;
                 signal niosII_openMac_clock_0_out_requests_sdram_0_s1 : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_granted_sdram_0_s1 : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_qualified_request_sdram_0_s1 : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1 : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register : OUT STD_LOGIC;
                 signal niosII_openMac_clock_1_out_requests_sdram_0_s1 : OUT STD_LOGIC;
                 signal sdram_0_s1_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                 signal sdram_0_s1_byteenable_n : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal sdram_0_s1_chipselect : OUT STD_LOGIC;
                 signal sdram_0_s1_read_n : OUT STD_LOGIC;
                 signal sdram_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal sdram_0_s1_reset_n : OUT STD_LOGIC;
                 signal sdram_0_s1_waitrequest_from_sa : OUT STD_LOGIC;
                 signal sdram_0_s1_write_n : OUT STD_LOGIC;
                 signal sdram_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity sdram_0_s1_arbitrator;


architecture europa of sdram_0_s1_arbitrator is
component rdv_fifo_for_niosII_openMac_clock_0_out_to_sdram_0_s1_module is 
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
end component rdv_fifo_for_niosII_openMac_clock_0_out_to_sdram_0_s1_module;

component rdv_fifo_for_niosII_openMac_clock_1_out_to_sdram_0_s1_module is 
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
end component rdv_fifo_for_niosII_openMac_clock_1_out_to_sdram_0_s1_module;

                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_sdram_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_niosII_openMac_clock_0_out_granted_sdram_0_s1 :  STD_LOGIC;
                signal internal_niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 :  STD_LOGIC;
                signal internal_niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register :  STD_LOGIC;
                signal internal_niosII_openMac_clock_0_out_requests_sdram_0_s1 :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_out_granted_sdram_0_s1 :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_out_qualified_request_sdram_0_s1 :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register :  STD_LOGIC;
                signal internal_niosII_openMac_clock_1_out_requests_sdram_0_s1 :  STD_LOGIC;
                signal internal_sdram_0_s1_waitrequest_from_sa :  STD_LOGIC;
                signal last_cycle_niosII_openMac_clock_0_out_granted_slave_sdram_0_s1 :  STD_LOGIC;
                signal last_cycle_niosII_openMac_clock_1_out_granted_slave_sdram_0_s1 :  STD_LOGIC;
                signal module_input :  STD_LOGIC;
                signal module_input1 :  STD_LOGIC;
                signal module_input2 :  STD_LOGIC;
                signal module_input3 :  STD_LOGIC;
                signal module_input4 :  STD_LOGIC;
                signal module_input5 :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_arbiterlock :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_arbiterlock2 :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_rdv_fifo_empty_sdram_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_rdv_fifo_output_from_sdram_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_saved_grant_sdram_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_arbiterlock :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_arbiterlock2 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_continuerequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_rdv_fifo_empty_sdram_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_rdv_fifo_output_from_sdram_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_saved_grant_sdram_0_s1 :  STD_LOGIC;
                signal sdram_0_s1_allgrants :  STD_LOGIC;
                signal sdram_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal sdram_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal sdram_0_s1_any_continuerequest :  STD_LOGIC;
                signal sdram_0_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sdram_0_s1_arb_counter_enable :  STD_LOGIC;
                signal sdram_0_s1_arb_share_counter :  STD_LOGIC;
                signal sdram_0_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal sdram_0_s1_arb_share_set_values :  STD_LOGIC;
                signal sdram_0_s1_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sdram_0_s1_arbitration_holdoff_internal :  STD_LOGIC;
                signal sdram_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal sdram_0_s1_begins_xfer :  STD_LOGIC;
                signal sdram_0_s1_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal sdram_0_s1_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sdram_0_s1_end_xfer :  STD_LOGIC;
                signal sdram_0_s1_firsttransfer :  STD_LOGIC;
                signal sdram_0_s1_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sdram_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal sdram_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal sdram_0_s1_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sdram_0_s1_move_on_to_next_transaction :  STD_LOGIC;
                signal sdram_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal sdram_0_s1_readdatavalid_from_sa :  STD_LOGIC;
                signal sdram_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal sdram_0_s1_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sdram_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal sdram_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal sdram_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal sdram_0_s1_waits_for_read :  STD_LOGIC;
                signal sdram_0_s1_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_sdram_0_s1_from_niosII_openMac_clock_0_out :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal shifted_address_to_sdram_0_s1_from_niosII_openMac_clock_1_out :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal wait_for_sdram_0_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT sdram_0_s1_end_xfer;
    end if;

  end process;

  sdram_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 OR internal_niosII_openMac_clock_1_out_qualified_request_sdram_0_s1));
  --assign sdram_0_s1_readdata_from_sa = sdram_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  sdram_0_s1_readdata_from_sa <= sdram_0_s1_readdata;
  internal_niosII_openMac_clock_0_out_requests_sdram_0_s1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_0_out_read OR niosII_openMac_clock_0_out_write)))))));
  --assign sdram_0_s1_waitrequest_from_sa = sdram_0_s1_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_sdram_0_s1_waitrequest_from_sa <= sdram_0_s1_waitrequest;
  --assign sdram_0_s1_readdatavalid_from_sa = sdram_0_s1_readdatavalid so that symbol knows where to group signals which may go to master only, which is an e_assign
  sdram_0_s1_readdatavalid_from_sa <= sdram_0_s1_readdatavalid;
  --sdram_0_s1_arb_share_counter set values, which is an e_mux
  sdram_0_s1_arb_share_set_values <= std_logic'('1');
  --sdram_0_s1_non_bursting_master_requests mux, which is an e_mux
  sdram_0_s1_non_bursting_master_requests <= ((internal_niosII_openMac_clock_0_out_requests_sdram_0_s1 OR internal_niosII_openMac_clock_1_out_requests_sdram_0_s1) OR internal_niosII_openMac_clock_0_out_requests_sdram_0_s1) OR internal_niosII_openMac_clock_1_out_requests_sdram_0_s1;
  --sdram_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  sdram_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --sdram_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  sdram_0_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(sdram_0_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sdram_0_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(sdram_0_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sdram_0_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --sdram_0_s1_allgrants all slave grants, which is an e_mux
  sdram_0_s1_allgrants <= (((or_reduce(sdram_0_s1_grant_vector)) OR (or_reduce(sdram_0_s1_grant_vector))) OR (or_reduce(sdram_0_s1_grant_vector))) OR (or_reduce(sdram_0_s1_grant_vector));
  --sdram_0_s1_end_xfer assignment, which is an e_assign
  sdram_0_s1_end_xfer <= NOT ((sdram_0_s1_waits_for_read OR sdram_0_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_sdram_0_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_sdram_0_s1 <= sdram_0_s1_end_xfer AND (((NOT sdram_0_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --sdram_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  sdram_0_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_sdram_0_s1 AND sdram_0_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_sdram_0_s1 AND NOT sdram_0_s1_non_bursting_master_requests));
  --sdram_0_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sdram_0_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(sdram_0_s1_arb_counter_enable) = '1' then 
        sdram_0_s1_arb_share_counter <= sdram_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --sdram_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sdram_0_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(sdram_0_s1_master_qreq_vector) AND end_xfer_arb_share_counter_term_sdram_0_s1)) OR ((end_xfer_arb_share_counter_term_sdram_0_s1 AND NOT sdram_0_s1_non_bursting_master_requests)))) = '1' then 
        sdram_0_s1_slavearbiterlockenable <= sdram_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --niosII_openMac_clock_0/out sdram_0/s1 arbiterlock, which is an e_assign
  niosII_openMac_clock_0_out_arbiterlock <= sdram_0_s1_slavearbiterlockenable AND niosII_openMac_clock_0_out_continuerequest;
  --sdram_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  sdram_0_s1_slavearbiterlockenable2 <= sdram_0_s1_arb_share_counter_next_value;
  --niosII_openMac_clock_0/out sdram_0/s1 arbiterlock2, which is an e_assign
  niosII_openMac_clock_0_out_arbiterlock2 <= sdram_0_s1_slavearbiterlockenable2 AND niosII_openMac_clock_0_out_continuerequest;
  --niosII_openMac_clock_1/out sdram_0/s1 arbiterlock, which is an e_assign
  niosII_openMac_clock_1_out_arbiterlock <= sdram_0_s1_slavearbiterlockenable AND niosII_openMac_clock_1_out_continuerequest;
  --niosII_openMac_clock_1/out sdram_0/s1 arbiterlock2, which is an e_assign
  niosII_openMac_clock_1_out_arbiterlock2 <= sdram_0_s1_slavearbiterlockenable2 AND niosII_openMac_clock_1_out_continuerequest;
  --niosII_openMac_clock_1/out granted sdram_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_niosII_openMac_clock_1_out_granted_slave_sdram_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_niosII_openMac_clock_1_out_granted_slave_sdram_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(niosII_openMac_clock_1_out_saved_grant_sdram_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((sdram_0_s1_arbitration_holdoff_internal OR NOT internal_niosII_openMac_clock_1_out_requests_sdram_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_niosII_openMac_clock_1_out_granted_slave_sdram_0_s1))))));
    end if;

  end process;

  --niosII_openMac_clock_1_out_continuerequest continued request, which is an e_mux
  niosII_openMac_clock_1_out_continuerequest <= last_cycle_niosII_openMac_clock_1_out_granted_slave_sdram_0_s1 AND internal_niosII_openMac_clock_1_out_requests_sdram_0_s1;
  --sdram_0_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  sdram_0_s1_any_continuerequest <= niosII_openMac_clock_1_out_continuerequest OR niosII_openMac_clock_0_out_continuerequest;
  internal_niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 <= internal_niosII_openMac_clock_0_out_requests_sdram_0_s1 AND NOT ((((niosII_openMac_clock_0_out_read AND (internal_niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register))) OR niosII_openMac_clock_1_out_arbiterlock));
  --unique name for sdram_0_s1_move_on_to_next_transaction, which is an e_assign
  sdram_0_s1_move_on_to_next_transaction <= sdram_0_s1_readdatavalid_from_sa;
  --rdv_fifo_for_niosII_openMac_clock_0_out_to_sdram_0_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_niosII_openMac_clock_0_out_to_sdram_0_s1 : rdv_fifo_for_niosII_openMac_clock_0_out_to_sdram_0_s1_module
    port map(
      data_out => niosII_openMac_clock_0_out_rdv_fifo_output_from_sdram_0_s1,
      empty => open,
      fifo_contains_ones_n => niosII_openMac_clock_0_out_rdv_fifo_empty_sdram_0_s1,
      full => open,
      clear_fifo => module_input,
      clk => clk,
      data_in => internal_niosII_openMac_clock_0_out_granted_sdram_0_s1,
      read => sdram_0_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input1,
      write => module_input2
    );

  module_input <= std_logic'('0');
  module_input1 <= std_logic'('0');
  module_input2 <= in_a_read_cycle AND NOT sdram_0_s1_waits_for_read;

  internal_niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register <= NOT niosII_openMac_clock_0_out_rdv_fifo_empty_sdram_0_s1;
  --local readdatavalid niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1, which is an e_mux
  niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1 <= ((sdram_0_s1_readdatavalid_from_sa AND niosII_openMac_clock_0_out_rdv_fifo_output_from_sdram_0_s1)) AND NOT niosII_openMac_clock_0_out_rdv_fifo_empty_sdram_0_s1;
  --sdram_0_s1_writedata mux, which is an e_mux
  sdram_0_s1_writedata <= A_WE_StdLogicVector((std_logic'((internal_niosII_openMac_clock_0_out_granted_sdram_0_s1)) = '1'), niosII_openMac_clock_0_out_writedata, niosII_openMac_clock_1_out_writedata);
  internal_niosII_openMac_clock_1_out_requests_sdram_0_s1 <= Vector_To_Std_Logic(((std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((niosII_openMac_clock_1_out_read OR niosII_openMac_clock_1_out_write)))))));
  --niosII_openMac_clock_0/out granted sdram_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_niosII_openMac_clock_0_out_granted_slave_sdram_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_niosII_openMac_clock_0_out_granted_slave_sdram_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(niosII_openMac_clock_0_out_saved_grant_sdram_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((sdram_0_s1_arbitration_holdoff_internal OR NOT internal_niosII_openMac_clock_0_out_requests_sdram_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_niosII_openMac_clock_0_out_granted_slave_sdram_0_s1))))));
    end if;

  end process;

  --niosII_openMac_clock_0_out_continuerequest continued request, which is an e_mux
  niosII_openMac_clock_0_out_continuerequest <= last_cycle_niosII_openMac_clock_0_out_granted_slave_sdram_0_s1 AND internal_niosII_openMac_clock_0_out_requests_sdram_0_s1;
  internal_niosII_openMac_clock_1_out_qualified_request_sdram_0_s1 <= internal_niosII_openMac_clock_1_out_requests_sdram_0_s1 AND NOT ((((niosII_openMac_clock_1_out_read AND (internal_niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register))) OR niosII_openMac_clock_0_out_arbiterlock));
  --rdv_fifo_for_niosII_openMac_clock_1_out_to_sdram_0_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_niosII_openMac_clock_1_out_to_sdram_0_s1 : rdv_fifo_for_niosII_openMac_clock_1_out_to_sdram_0_s1_module
    port map(
      data_out => niosII_openMac_clock_1_out_rdv_fifo_output_from_sdram_0_s1,
      empty => open,
      fifo_contains_ones_n => niosII_openMac_clock_1_out_rdv_fifo_empty_sdram_0_s1,
      full => open,
      clear_fifo => module_input3,
      clk => clk,
      data_in => internal_niosII_openMac_clock_1_out_granted_sdram_0_s1,
      read => sdram_0_s1_move_on_to_next_transaction,
      reset_n => reset_n,
      sync_reset => module_input4,
      write => module_input5
    );

  module_input3 <= std_logic'('0');
  module_input4 <= std_logic'('0');
  module_input5 <= in_a_read_cycle AND NOT sdram_0_s1_waits_for_read;

  internal_niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register <= NOT niosII_openMac_clock_1_out_rdv_fifo_empty_sdram_0_s1;
  --local readdatavalid niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1, which is an e_mux
  niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1 <= ((sdram_0_s1_readdatavalid_from_sa AND niosII_openMac_clock_1_out_rdv_fifo_output_from_sdram_0_s1)) AND NOT niosII_openMac_clock_1_out_rdv_fifo_empty_sdram_0_s1;
  --allow new arb cycle for sdram_0/s1, which is an e_assign
  sdram_0_s1_allow_new_arb_cycle <= NOT niosII_openMac_clock_0_out_arbiterlock AND NOT niosII_openMac_clock_1_out_arbiterlock;
  --niosII_openMac_clock_1/out assignment into master qualified-requests vector for sdram_0/s1, which is an e_assign
  sdram_0_s1_master_qreq_vector(0) <= internal_niosII_openMac_clock_1_out_qualified_request_sdram_0_s1;
  --niosII_openMac_clock_1/out grant sdram_0/s1, which is an e_assign
  internal_niosII_openMac_clock_1_out_granted_sdram_0_s1 <= sdram_0_s1_grant_vector(0);
  --niosII_openMac_clock_1/out saved-grant sdram_0/s1, which is an e_assign
  niosII_openMac_clock_1_out_saved_grant_sdram_0_s1 <= sdram_0_s1_arb_winner(0) AND internal_niosII_openMac_clock_1_out_requests_sdram_0_s1;
  --niosII_openMac_clock_0/out assignment into master qualified-requests vector for sdram_0/s1, which is an e_assign
  sdram_0_s1_master_qreq_vector(1) <= internal_niosII_openMac_clock_0_out_qualified_request_sdram_0_s1;
  --niosII_openMac_clock_0/out grant sdram_0/s1, which is an e_assign
  internal_niosII_openMac_clock_0_out_granted_sdram_0_s1 <= sdram_0_s1_grant_vector(1);
  --niosII_openMac_clock_0/out saved-grant sdram_0/s1, which is an e_assign
  niosII_openMac_clock_0_out_saved_grant_sdram_0_s1 <= sdram_0_s1_arb_winner(1) AND internal_niosII_openMac_clock_0_out_requests_sdram_0_s1;
  --sdram_0/s1 chosen-master double-vector, which is an e_assign
  sdram_0_s1_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((sdram_0_s1_master_qreq_vector & sdram_0_s1_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT sdram_0_s1_master_qreq_vector & NOT sdram_0_s1_master_qreq_vector))) + (std_logic_vector'("000") & (sdram_0_s1_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  sdram_0_s1_arb_winner <= A_WE_StdLogicVector((std_logic'(((sdram_0_s1_allow_new_arb_cycle AND or_reduce(sdram_0_s1_grant_vector)))) = '1'), sdram_0_s1_grant_vector, sdram_0_s1_saved_chosen_master_vector);
  --saved sdram_0_s1_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sdram_0_s1_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(sdram_0_s1_allow_new_arb_cycle) = '1' then 
        sdram_0_s1_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(sdram_0_s1_grant_vector)) = '1'), sdram_0_s1_grant_vector, sdram_0_s1_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  sdram_0_s1_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((sdram_0_s1_chosen_master_double_vector(1) OR sdram_0_s1_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((sdram_0_s1_chosen_master_double_vector(0) OR sdram_0_s1_chosen_master_double_vector(2)))));
  --sdram_0/s1 chosen master rotated left, which is an e_assign
  sdram_0_s1_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(sdram_0_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(sdram_0_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --sdram_0/s1's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sdram_0_s1_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(sdram_0_s1_grant_vector)) = '1' then 
        sdram_0_s1_arb_addend <= A_WE_StdLogicVector((std_logic'(sdram_0_s1_end_xfer) = '1'), sdram_0_s1_chosen_master_rot_left, sdram_0_s1_grant_vector);
      end if;
    end if;

  end process;

  --sdram_0_s1_reset_n assignment, which is an e_assign
  sdram_0_s1_reset_n <= reset_n;
  sdram_0_s1_chipselect <= internal_niosII_openMac_clock_0_out_granted_sdram_0_s1 OR internal_niosII_openMac_clock_1_out_granted_sdram_0_s1;
  --sdram_0_s1_firsttransfer first transaction, which is an e_assign
  sdram_0_s1_firsttransfer <= A_WE_StdLogic((std_logic'(sdram_0_s1_begins_xfer) = '1'), sdram_0_s1_unreg_firsttransfer, sdram_0_s1_reg_firsttransfer);
  --sdram_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  sdram_0_s1_unreg_firsttransfer <= NOT ((sdram_0_s1_slavearbiterlockenable AND sdram_0_s1_any_continuerequest));
  --sdram_0_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sdram_0_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(sdram_0_s1_begins_xfer) = '1' then 
        sdram_0_s1_reg_firsttransfer <= sdram_0_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --sdram_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  sdram_0_s1_beginbursttransfer_internal <= sdram_0_s1_begins_xfer;
  --sdram_0_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  sdram_0_s1_arbitration_holdoff_internal <= sdram_0_s1_begins_xfer AND sdram_0_s1_firsttransfer;
  --~sdram_0_s1_read_n assignment, which is an e_mux
  sdram_0_s1_read_n <= NOT ((((internal_niosII_openMac_clock_0_out_granted_sdram_0_s1 AND niosII_openMac_clock_0_out_read)) OR ((internal_niosII_openMac_clock_1_out_granted_sdram_0_s1 AND niosII_openMac_clock_1_out_read))));
  --~sdram_0_s1_write_n assignment, which is an e_mux
  sdram_0_s1_write_n <= NOT ((((internal_niosII_openMac_clock_0_out_granted_sdram_0_s1 AND niosII_openMac_clock_0_out_write)) OR ((internal_niosII_openMac_clock_1_out_granted_sdram_0_s1 AND niosII_openMac_clock_1_out_write))));
  shifted_address_to_sdram_0_s1_from_niosII_openMac_clock_0_out <= niosII_openMac_clock_0_out_address_to_slave;
  --sdram_0_s1_address mux, which is an e_mux
  sdram_0_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_niosII_openMac_clock_0_out_granted_sdram_0_s1)) = '1'), (A_SRL(shifted_address_to_sdram_0_s1_from_niosII_openMac_clock_0_out,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_sdram_0_s1_from_niosII_openMac_clock_1_out,std_logic_vector'("00000000000000000000000000000010")))), 25);
  shifted_address_to_sdram_0_s1_from_niosII_openMac_clock_1_out <= niosII_openMac_clock_1_out_address_to_slave;
  --d1_sdram_0_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_sdram_0_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_sdram_0_s1_end_xfer <= sdram_0_s1_end_xfer;
    end if;

  end process;

  --sdram_0_s1_waits_for_read in a cycle, which is an e_mux
  sdram_0_s1_waits_for_read <= sdram_0_s1_in_a_read_cycle AND internal_sdram_0_s1_waitrequest_from_sa;
  --sdram_0_s1_in_a_read_cycle assignment, which is an e_assign
  sdram_0_s1_in_a_read_cycle <= ((internal_niosII_openMac_clock_0_out_granted_sdram_0_s1 AND niosII_openMac_clock_0_out_read)) OR ((internal_niosII_openMac_clock_1_out_granted_sdram_0_s1 AND niosII_openMac_clock_1_out_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= sdram_0_s1_in_a_read_cycle;
  --sdram_0_s1_waits_for_write in a cycle, which is an e_mux
  sdram_0_s1_waits_for_write <= sdram_0_s1_in_a_write_cycle AND internal_sdram_0_s1_waitrequest_from_sa;
  --sdram_0_s1_in_a_write_cycle assignment, which is an e_assign
  sdram_0_s1_in_a_write_cycle <= ((internal_niosII_openMac_clock_0_out_granted_sdram_0_s1 AND niosII_openMac_clock_0_out_write)) OR ((internal_niosII_openMac_clock_1_out_granted_sdram_0_s1 AND niosII_openMac_clock_1_out_write));
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= sdram_0_s1_in_a_write_cycle;
  wait_for_sdram_0_s1_counter <= std_logic'('0');
  --~sdram_0_s1_byteenable_n byte enable port mux, which is an e_mux
  sdram_0_s1_byteenable_n <= A_EXT (NOT (A_WE_StdLogicVector((std_logic'((internal_niosII_openMac_clock_0_out_granted_sdram_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (niosII_openMac_clock_0_out_byteenable)), A_WE_StdLogicVector((std_logic'((internal_niosII_openMac_clock_1_out_granted_sdram_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (niosII_openMac_clock_1_out_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))))), 4);
  --vhdl renameroo for output signals
  niosII_openMac_clock_0_out_granted_sdram_0_s1 <= internal_niosII_openMac_clock_0_out_granted_sdram_0_s1;
  --vhdl renameroo for output signals
  niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 <= internal_niosII_openMac_clock_0_out_qualified_request_sdram_0_s1;
  --vhdl renameroo for output signals
  niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register <= internal_niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register;
  --vhdl renameroo for output signals
  niosII_openMac_clock_0_out_requests_sdram_0_s1 <= internal_niosII_openMac_clock_0_out_requests_sdram_0_s1;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_granted_sdram_0_s1 <= internal_niosII_openMac_clock_1_out_granted_sdram_0_s1;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_qualified_request_sdram_0_s1 <= internal_niosII_openMac_clock_1_out_qualified_request_sdram_0_s1;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register <= internal_niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register;
  --vhdl renameroo for output signals
  niosII_openMac_clock_1_out_requests_sdram_0_s1 <= internal_niosII_openMac_clock_1_out_requests_sdram_0_s1;
  --vhdl renameroo for output signals
  sdram_0_s1_waitrequest_from_sa <= internal_sdram_0_s1_waitrequest_from_sa;
--synthesis translate_off
    --sdram_0/s1 enable non-zero assertions, which is an e_register
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
    VARIABLE write_line32 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_niosII_openMac_clock_0_out_granted_sdram_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_niosII_openMac_clock_1_out_granted_sdram_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line32, now);
          write(write_line32, string'(": "));
          write(write_line32, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line32.all);
          deallocate (write_line32);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line33 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(niosII_openMac_clock_0_out_saved_grant_sdram_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(niosII_openMac_clock_1_out_saved_grant_sdram_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line33, now);
          write(write_line33, string'(": "));
          write(write_line33, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line33.all);
          deallocate (write_line33);
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

entity sync_irq_from_pcp_s1_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sync_irq_from_pcp_s1_irq : IN STD_LOGIC;
                 signal sync_irq_from_pcp_s1_readdata : IN STD_LOGIC;

              -- outputs:
                 signal ap_cpu_data_master_granted_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
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
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal shifted_address_to_sync_irq_from_pcp_s1_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal sync_irq_from_pcp_s1_allgrants :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_any_continuerequest :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_arb_counter_enable :  STD_LOGIC;
                signal sync_irq_from_pcp_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sync_irq_from_pcp_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal sync_irq_from_pcp_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
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

  sync_irq_from_pcp_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1);
  --assign sync_irq_from_pcp_s1_readdata_from_sa = sync_irq_from_pcp_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  sync_irq_from_pcp_s1_readdata_from_sa <= sync_irq_from_pcp_s1_readdata;
  internal_ap_cpu_data_master_requests_sync_irq_from_pcp_s1 <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("0000000000000000100101100000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --sync_irq_from_pcp_s1_arb_share_counter set values, which is an e_mux
  sync_irq_from_pcp_s1_arb_share_set_values <= std_logic_vector'("01");
  --sync_irq_from_pcp_s1_non_bursting_master_requests mux, which is an e_mux
  sync_irq_from_pcp_s1_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_sync_irq_from_pcp_s1;
  --sync_irq_from_pcp_s1_any_bursting_master_saved_grant mux, which is an e_mux
  sync_irq_from_pcp_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --sync_irq_from_pcp_s1_arb_share_counter_next_value assignment, which is an e_assign
  sync_irq_from_pcp_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(sync_irq_from_pcp_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (sync_irq_from_pcp_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(sync_irq_from_pcp_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (sync_irq_from_pcp_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
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
      sync_irq_from_pcp_s1_arb_share_counter <= std_logic_vector'("00");
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
        sync_irq_from_pcp_s1_slavearbiterlockenable <= or_reduce(sync_irq_from_pcp_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --ap_cpu/data_master sync_irq_from_pcp/s1 arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= sync_irq_from_pcp_s1_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --sync_irq_from_pcp_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  sync_irq_from_pcp_s1_slavearbiterlockenable2 <= or_reduce(sync_irq_from_pcp_s1_arb_share_counter_next_value);
  --ap_cpu/data_master sync_irq_from_pcp/s1 arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= sync_irq_from_pcp_s1_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --sync_irq_from_pcp_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  sync_irq_from_pcp_s1_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1 <= internal_ap_cpu_data_master_requests_sync_irq_from_pcp_s1 AND NOT (((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write));
  --sync_irq_from_pcp_s1_writedata mux, which is an e_mux
  sync_irq_from_pcp_s1_writedata <= ap_cpu_data_master_writedata(0);
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_sync_irq_from_pcp_s1 <= internal_ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1;
  --ap_cpu/data_master saved-grant sync_irq_from_pcp/s1, which is an e_assign
  ap_cpu_data_master_saved_grant_sync_irq_from_pcp_s1 <= internal_ap_cpu_data_master_requests_sync_irq_from_pcp_s1;
  --allow new arb cycle for sync_irq_from_pcp/s1, which is an e_assign
  sync_irq_from_pcp_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  sync_irq_from_pcp_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  sync_irq_from_pcp_s1_master_qreq_vector <= std_logic'('1');
  --sync_irq_from_pcp_s1_reset_n assignment, which is an e_assign
  sync_irq_from_pcp_s1_reset_n <= reset_n;
  sync_irq_from_pcp_s1_chipselect <= internal_ap_cpu_data_master_granted_sync_irq_from_pcp_s1;
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
  sync_irq_from_pcp_s1_write_n <= NOT ((internal_ap_cpu_data_master_granted_sync_irq_from_pcp_s1 AND ap_cpu_data_master_write));
  shifted_address_to_sync_irq_from_pcp_s1_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --sync_irq_from_pcp_s1_address mux, which is an e_mux
  sync_irq_from_pcp_s1_address <= A_EXT (A_SRL(shifted_address_to_sync_irq_from_pcp_s1_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
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
  sync_irq_from_pcp_s1_in_a_read_cycle <= internal_ap_cpu_data_master_granted_sync_irq_from_pcp_s1 AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= sync_irq_from_pcp_s1_in_a_read_cycle;
  --sync_irq_from_pcp_s1_waits_for_write in a cycle, which is an e_mux
  sync_irq_from_pcp_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sync_irq_from_pcp_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --sync_irq_from_pcp_s1_in_a_write_cycle assignment, which is an e_assign
  sync_irq_from_pcp_s1_in_a_write_cycle <= internal_ap_cpu_data_master_granted_sync_irq_from_pcp_s1 AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= sync_irq_from_pcp_s1_in_a_write_cycle;
  wait_for_sync_irq_from_pcp_s1_counter <= std_logic'('0');
  --assign sync_irq_from_pcp_s1_irq_from_sa = sync_irq_from_pcp_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  sync_irq_from_pcp_s1_irq_from_sa <= sync_irq_from_pcp_s1_irq;
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_sync_irq_from_pcp_s1 <= internal_ap_cpu_data_master_granted_sync_irq_from_pcp_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1 <= internal_ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_sync_irq_from_pcp_s1 <= internal_ap_cpu_data_master_requests_sync_irq_from_pcp_s1;
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
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- outputs:
                 signal ap_cpu_data_master_granted_sysid_control_slave : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_sysid_control_slave : OUT STD_LOGIC;
                 signal d1_sysid_control_slave_end_xfer : OUT STD_LOGIC;
                 signal sysid_control_slave_address : OUT STD_LOGIC;
                 signal sysid_control_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal sysid_control_slave_reset_n : OUT STD_LOGIC
              );
end entity sysid_control_slave_arbitrator;


architecture europa of sysid_control_slave_arbitrator is
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_sysid_control_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_sysid_control_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_sysid_control_slave :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_sysid_control_slave :  STD_LOGIC;
                signal shifted_address_to_sysid_control_slave_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
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

  sysid_control_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_sysid_control_slave);
  --assign sysid_control_slave_readdata_from_sa = sysid_control_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  sysid_control_slave_readdata_from_sa <= sysid_control_slave_readdata;
  internal_ap_cpu_data_master_requests_sysid_control_slave <= ((to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("0000000000000000100110101000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write)))) AND ap_cpu_data_master_read;
  --sysid_control_slave_arb_share_counter set values, which is an e_mux
  sysid_control_slave_arb_share_set_values <= std_logic_vector'("01");
  --sysid_control_slave_non_bursting_master_requests mux, which is an e_mux
  sysid_control_slave_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_sysid_control_slave;
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

  --ap_cpu/data_master sysid/control_slave arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= sysid_control_slave_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --sysid_control_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  sysid_control_slave_slavearbiterlockenable2 <= or_reduce(sysid_control_slave_arb_share_counter_next_value);
  --ap_cpu/data_master sysid/control_slave arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= sysid_control_slave_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --sysid_control_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  sysid_control_slave_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_sysid_control_slave <= internal_ap_cpu_data_master_requests_sysid_control_slave;
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_sysid_control_slave <= internal_ap_cpu_data_master_qualified_request_sysid_control_slave;
  --ap_cpu/data_master saved-grant sysid/control_slave, which is an e_assign
  ap_cpu_data_master_saved_grant_sysid_control_slave <= internal_ap_cpu_data_master_requests_sysid_control_slave;
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
  shifted_address_to_sysid_control_slave_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --sysid_control_slave_address mux, which is an e_mux
  sysid_control_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_sysid_control_slave_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")));
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
  sysid_control_slave_in_a_read_cycle <= internal_ap_cpu_data_master_granted_sysid_control_slave AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= sysid_control_slave_in_a_read_cycle;
  --sysid_control_slave_waits_for_write in a cycle, which is an e_mux
  sysid_control_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sysid_control_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --sysid_control_slave_in_a_write_cycle assignment, which is an e_assign
  sysid_control_slave_in_a_write_cycle <= internal_ap_cpu_data_master_granted_sysid_control_slave AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= sysid_control_slave_in_a_write_cycle;
  wait_for_sysid_control_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_sysid_control_slave <= internal_ap_cpu_data_master_granted_sysid_control_slave;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_sysid_control_slave <= internal_ap_cpu_data_master_qualified_request_sysid_control_slave;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_sysid_control_slave <= internal_ap_cpu_data_master_requests_sysid_control_slave;
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
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal system_timer_ap_s1_irq : IN STD_LOGIC;
                 signal system_timer_ap_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal ap_cpu_data_master_granted_system_timer_ap_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_system_timer_ap_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_system_timer_ap_s1 : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_system_timer_ap_s1 : OUT STD_LOGIC;
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
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_system_timer_ap_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_system_timer_ap_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_granted_system_timer_ap_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_system_timer_ap_s1 :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_system_timer_ap_s1 :  STD_LOGIC;
                signal shifted_address_to_system_timer_ap_s1_from_ap_cpu_data_master :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal system_timer_ap_s1_allgrants :  STD_LOGIC;
                signal system_timer_ap_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal system_timer_ap_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal system_timer_ap_s1_any_continuerequest :  STD_LOGIC;
                signal system_timer_ap_s1_arb_counter_enable :  STD_LOGIC;
                signal system_timer_ap_s1_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal system_timer_ap_s1_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal system_timer_ap_s1_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
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

  system_timer_ap_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_system_timer_ap_s1);
  --assign system_timer_ap_s1_readdata_from_sa = system_timer_ap_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  system_timer_ap_s1_readdata_from_sa <= system_timer_ap_s1_readdata;
  internal_ap_cpu_data_master_requests_system_timer_ap_s1 <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("0000000000000000100100000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --system_timer_ap_s1_arb_share_counter set values, which is an e_mux
  system_timer_ap_s1_arb_share_set_values <= std_logic_vector'("01");
  --system_timer_ap_s1_non_bursting_master_requests mux, which is an e_mux
  system_timer_ap_s1_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_system_timer_ap_s1;
  --system_timer_ap_s1_any_bursting_master_saved_grant mux, which is an e_mux
  system_timer_ap_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --system_timer_ap_s1_arb_share_counter_next_value assignment, which is an e_assign
  system_timer_ap_s1_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(system_timer_ap_s1_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (system_timer_ap_s1_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(system_timer_ap_s1_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (system_timer_ap_s1_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
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
      system_timer_ap_s1_arb_share_counter <= std_logic_vector'("00");
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
        system_timer_ap_s1_slavearbiterlockenable <= or_reduce(system_timer_ap_s1_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --ap_cpu/data_master system_timer_ap/s1 arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= system_timer_ap_s1_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --system_timer_ap_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  system_timer_ap_s1_slavearbiterlockenable2 <= or_reduce(system_timer_ap_s1_arb_share_counter_next_value);
  --ap_cpu/data_master system_timer_ap/s1 arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= system_timer_ap_s1_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --system_timer_ap_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  system_timer_ap_s1_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_system_timer_ap_s1 <= internal_ap_cpu_data_master_requests_system_timer_ap_s1 AND NOT (((NOT ap_cpu_data_master_waitrequest) AND ap_cpu_data_master_write));
  --system_timer_ap_s1_writedata mux, which is an e_mux
  system_timer_ap_s1_writedata <= ap_cpu_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_system_timer_ap_s1 <= internal_ap_cpu_data_master_qualified_request_system_timer_ap_s1;
  --ap_cpu/data_master saved-grant system_timer_ap/s1, which is an e_assign
  ap_cpu_data_master_saved_grant_system_timer_ap_s1 <= internal_ap_cpu_data_master_requests_system_timer_ap_s1;
  --allow new arb cycle for system_timer_ap/s1, which is an e_assign
  system_timer_ap_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  system_timer_ap_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  system_timer_ap_s1_master_qreq_vector <= std_logic'('1');
  --system_timer_ap_s1_reset_n assignment, which is an e_assign
  system_timer_ap_s1_reset_n <= reset_n;
  system_timer_ap_s1_chipselect <= internal_ap_cpu_data_master_granted_system_timer_ap_s1;
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
  system_timer_ap_s1_write_n <= NOT ((internal_ap_cpu_data_master_granted_system_timer_ap_s1 AND ap_cpu_data_master_write));
  shifted_address_to_system_timer_ap_s1_from_ap_cpu_data_master <= ap_cpu_data_master_address_to_slave;
  --system_timer_ap_s1_address mux, which is an e_mux
  system_timer_ap_s1_address <= A_EXT (A_SRL(shifted_address_to_system_timer_ap_s1_from_ap_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
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
  system_timer_ap_s1_in_a_read_cycle <= internal_ap_cpu_data_master_granted_system_timer_ap_s1 AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= system_timer_ap_s1_in_a_read_cycle;
  --system_timer_ap_s1_waits_for_write in a cycle, which is an e_mux
  system_timer_ap_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(system_timer_ap_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --system_timer_ap_s1_in_a_write_cycle assignment, which is an e_assign
  system_timer_ap_s1_in_a_write_cycle <= internal_ap_cpu_data_master_granted_system_timer_ap_s1 AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= system_timer_ap_s1_in_a_write_cycle;
  wait_for_system_timer_ap_s1_counter <= std_logic'('0');
  --assign system_timer_ap_s1_irq_from_sa = system_timer_ap_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  system_timer_ap_s1_irq_from_sa <= system_timer_ap_s1_irq;
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_system_timer_ap_s1 <= internal_ap_cpu_data_master_granted_system_timer_ap_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_system_timer_ap_s1 <= internal_ap_cpu_data_master_qualified_request_system_timer_ap_s1;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_system_timer_ap_s1 <= internal_ap_cpu_data_master_requests_system_timer_ap_s1;
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

entity tri_state_bridge_0_avalon_slave_arbitrator is 
        port (
              -- inputs:
                 signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ap_cpu_data_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ap_cpu_data_master_dbs_write_16 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ap_cpu_data_master_no_byte_enables_and_last_term : IN STD_LOGIC;
                 signal ap_cpu_data_master_read : IN STD_LOGIC;
                 signal ap_cpu_data_master_write : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal addr_to_the_par_pdi_master_0 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal ben_to_the_par_pdi_master_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal csn_to_the_par_pdi_master_0 : OUT STD_LOGIC;
                 signal d1_tri_state_bridge_0_avalon_slave_end_xfer : OUT STD_LOGIC;
                 signal data_to_and_from_the_par_pdi_master_0 : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal incoming_data_to_and_from_the_par_pdi_master_0 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0 : OUT STD_LOGIC;
                 signal par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_1 : OUT STD_LOGIC;
                 signal rdn_to_the_par_pdi_master_0 : OUT STD_LOGIC;
                 signal registered_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave : OUT STD_LOGIC;
                 signal wrn_to_the_par_pdi_master_0 : OUT STD_LOGIC
              );
end entity tri_state_bridge_0_avalon_slave_arbitrator;


architecture europa of tri_state_bridge_0_avalon_slave_arbitrator is
                signal ap_cpu_data_master_arbiterlock :  STD_LOGIC;
                signal ap_cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave_segment_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave_segment_1 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_data_master_continuerequest :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register_in :  STD_LOGIC;
                signal ap_cpu_data_master_saved_grant_par_pdi_master_0_avalon_tristate_slave :  STD_LOGIC;
                signal d1_in_a_write_cycle :  STD_LOGIC;
                signal d1_outgoing_data_to_and_from_the_par_pdi_master_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave :  STD_LOGIC;
                signal internal_ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave :  STD_LOGIC;
                signal internal_ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave :  STD_LOGIC;
                signal internal_par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0 :  STD_LOGIC;
                signal outgoing_data_to_and_from_the_par_pdi_master_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal p1_addr_to_the_par_pdi_master_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal p1_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_ben_to_the_par_pdi_master_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal p1_csn_to_the_par_pdi_master_0 :  STD_LOGIC;
                signal p1_rdn_to_the_par_pdi_master_0 :  STD_LOGIC;
                signal p1_wrn_to_the_par_pdi_master_0 :  STD_LOGIC;
                signal par_pdi_master_0_avalon_tristate_slave_counter_load_value :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal par_pdi_master_0_avalon_tristate_slave_in_a_read_cycle :  STD_LOGIC;
                signal par_pdi_master_0_avalon_tristate_slave_in_a_write_cycle :  STD_LOGIC;
                signal par_pdi_master_0_avalon_tristate_slave_wait_counter :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal par_pdi_master_0_avalon_tristate_slave_waits_for_read :  STD_LOGIC;
                signal par_pdi_master_0_avalon_tristate_slave_waits_for_write :  STD_LOGIC;
                signal par_pdi_master_0_avalon_tristate_slave_with_write_latency :  STD_LOGIC;
                signal time_to_write :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_allgrants :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_any_continuerequest :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_arb_counter_enable :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_arb_share_counter :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_arb_share_counter_next_value :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_arb_share_set_values :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal tri_state_bridge_0_avalon_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_begins_xfer :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_end_xfer :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_firsttransfer :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_grant_vector :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_master_qreq_vector :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_non_bursting_master_requests :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_read_pending :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_reg_firsttransfer :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_slavearbiterlockenable :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_unreg_firsttransfer :  STD_LOGIC;
                signal tri_state_bridge_0_avalon_slave_write_pending :  STD_LOGIC;
                signal wait_for_par_pdi_master_0_avalon_tristate_slave_counter :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of addr_to_the_par_pdi_master_0 : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of ben_to_the_par_pdi_master_0 : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of csn_to_the_par_pdi_master_0 : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of d1_in_a_write_cycle : signal is "FAST_OUTPUT_ENABLE_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of d1_outgoing_data_to_and_from_the_par_pdi_master_0 : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of incoming_data_to_and_from_the_par_pdi_master_0 : signal is "FAST_INPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of rdn_to_the_par_pdi_master_0 : signal is "FAST_OUTPUT_REGISTER=ON";
attribute ALTERA_ATTRIBUTE of wrn_to_the_par_pdi_master_0 : signal is "FAST_OUTPUT_REGISTER=ON";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT tri_state_bridge_0_avalon_slave_end_xfer;
    end if;

  end process;

  tri_state_bridge_0_avalon_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave);
  internal_ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave <= to_std_logic(((Std_Logic_Vector'(ap_cpu_data_master_address_to_slave(27 DOWNTO 16) & std_logic_vector'("0000000000000000")) = std_logic_vector'("0000000000010000000000000000")))) AND ((ap_cpu_data_master_read OR ap_cpu_data_master_write));
  --~csn_to_the_par_pdi_master_0 of type chipselect to ~p1_csn_to_the_par_pdi_master_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      csn_to_the_par_pdi_master_0 <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      csn_to_the_par_pdi_master_0 <= p1_csn_to_the_par_pdi_master_0;
    end if;

  end process;

  tri_state_bridge_0_avalon_slave_write_pending <= std_logic'('0');
  --tri_state_bridge_0/avalon_slave read pending calc, which is an e_assign
  tri_state_bridge_0_avalon_slave_read_pending <= std_logic'('0');
  --registered rdv signal_name registered_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave assignment, which is an e_assign
  registered_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave <= ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register(0);
  --tri_state_bridge_0_avalon_slave_arb_share_counter set values, which is an e_mux
  tri_state_bridge_0_avalon_slave_arb_share_set_values <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave)) = '1'), std_logic_vector'("00000000000000000000000000000010"), std_logic_vector'("00000000000000000000000000000001")), 2);
  --tri_state_bridge_0_avalon_slave_non_bursting_master_requests mux, which is an e_mux
  tri_state_bridge_0_avalon_slave_non_bursting_master_requests <= internal_ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave;
  --tri_state_bridge_0_avalon_slave_any_bursting_master_saved_grant mux, which is an e_mux
  tri_state_bridge_0_avalon_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --tri_state_bridge_0_avalon_slave_arb_share_counter_next_value assignment, which is an e_assign
  tri_state_bridge_0_avalon_slave_arb_share_counter_next_value <= A_EXT (A_WE_StdLogicVector((std_logic'(tri_state_bridge_0_avalon_slave_firsttransfer) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (tri_state_bridge_0_avalon_slave_arb_share_set_values)) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(or_reduce(tri_state_bridge_0_avalon_slave_arb_share_counter)) = '1'), (((std_logic_vector'("0000000000000000000000000000000") & (tri_state_bridge_0_avalon_slave_arb_share_counter)) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))), 2);
  --tri_state_bridge_0_avalon_slave_allgrants all slave grants, which is an e_mux
  tri_state_bridge_0_avalon_slave_allgrants <= tri_state_bridge_0_avalon_slave_grant_vector;
  --tri_state_bridge_0_avalon_slave_end_xfer assignment, which is an e_assign
  tri_state_bridge_0_avalon_slave_end_xfer <= NOT ((par_pdi_master_0_avalon_tristate_slave_waits_for_read OR par_pdi_master_0_avalon_tristate_slave_waits_for_write));
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
      if std_logic'((((tri_state_bridge_0_avalon_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave)) OR ((end_xfer_arb_share_counter_term_tri_state_bridge_0_avalon_slave AND NOT tri_state_bridge_0_avalon_slave_non_bursting_master_requests)))) = '1' then 
        tri_state_bridge_0_avalon_slave_slavearbiterlockenable <= or_reduce(tri_state_bridge_0_avalon_slave_arb_share_counter_next_value);
      end if;
    end if;

  end process;

  --ap_cpu/data_master tri_state_bridge_0/avalon_slave arbiterlock, which is an e_assign
  ap_cpu_data_master_arbiterlock <= tri_state_bridge_0_avalon_slave_slavearbiterlockenable AND ap_cpu_data_master_continuerequest;
  --tri_state_bridge_0_avalon_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  tri_state_bridge_0_avalon_slave_slavearbiterlockenable2 <= or_reduce(tri_state_bridge_0_avalon_slave_arb_share_counter_next_value);
  --ap_cpu/data_master tri_state_bridge_0/avalon_slave arbiterlock2, which is an e_assign
  ap_cpu_data_master_arbiterlock2 <= tri_state_bridge_0_avalon_slave_slavearbiterlockenable2 AND ap_cpu_data_master_continuerequest;
  --tri_state_bridge_0_avalon_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  tri_state_bridge_0_avalon_slave_any_continuerequest <= std_logic'('1');
  --ap_cpu_data_master_continuerequest continued request, which is an e_assign
  ap_cpu_data_master_continuerequest <= std_logic'('1');
  internal_ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave <= internal_ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave AND NOT ((((ap_cpu_data_master_read AND (((tri_state_bridge_0_avalon_slave_write_pending OR (tri_state_bridge_0_avalon_slave_read_pending)) OR (or_reduce(ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register)))))) OR (((((tri_state_bridge_0_avalon_slave_read_pending OR ap_cpu_data_master_no_byte_enables_and_last_term) OR NOT(or_reduce(internal_ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave)))) AND ap_cpu_data_master_write))));
  --ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register_in <= ((internal_ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave AND ap_cpu_data_master_read) AND NOT par_pdi_master_0_avalon_tristate_slave_waits_for_read) AND NOT (or_reduce(ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register));
  --shift register p1 ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register <= A_EXT ((ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register & A_ToStdLogicVector(ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register_in)), 2);
  --ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register <= p1_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register;
    end if;

  end process;

  --local readdatavalid ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave, which is an e_mux
  ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave <= ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave_shift_register(1);
  --data_to_and_from_the_par_pdi_master_0 register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      incoming_data_to_and_from_the_par_pdi_master_0 <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      incoming_data_to_and_from_the_par_pdi_master_0 <= data_to_and_from_the_par_pdi_master_0;
    end if;

  end process;

  --par_pdi_master_0_avalon_tristate_slave_with_write_latency assignment, which is an e_assign
  par_pdi_master_0_avalon_tristate_slave_with_write_latency <= in_a_write_cycle AND (internal_ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave);
  --time to write the data, which is an e_mux
  time_to_write <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((par_pdi_master_0_avalon_tristate_slave_with_write_latency)) = '1'), std_logic_vector'("00000000000000000000000000000001"), std_logic_vector'("00000000000000000000000000000000")));
  --d1_outgoing_data_to_and_from_the_par_pdi_master_0 register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_outgoing_data_to_and_from_the_par_pdi_master_0 <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      d1_outgoing_data_to_and_from_the_par_pdi_master_0 <= outgoing_data_to_and_from_the_par_pdi_master_0;
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

  --d1_outgoing_data_to_and_from_the_par_pdi_master_0 tristate driver, which is an e_assign
  data_to_and_from_the_par_pdi_master_0 <= A_WE_StdLogicVector((std_logic'((d1_in_a_write_cycle)) = '1'), d1_outgoing_data_to_and_from_the_par_pdi_master_0, A_REP(std_logic'('Z'), 16));
  --outgoing_data_to_and_from_the_par_pdi_master_0 mux, which is an e_mux
  outgoing_data_to_and_from_the_par_pdi_master_0 <= ap_cpu_data_master_dbs_write_16;
  --master is always granted when requested
  internal_ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave <= internal_ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave;
  --ap_cpu/data_master saved-grant par_pdi_master_0/avalon_tristate_slave, which is an e_assign
  ap_cpu_data_master_saved_grant_par_pdi_master_0_avalon_tristate_slave <= internal_ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave;
  --allow new arb cycle for tri_state_bridge_0/avalon_slave, which is an e_assign
  tri_state_bridge_0_avalon_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  tri_state_bridge_0_avalon_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  tri_state_bridge_0_avalon_slave_master_qreq_vector <= std_logic'('1');
  p1_csn_to_the_par_pdi_master_0 <= NOT internal_ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave;
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
  --~rdn_to_the_par_pdi_master_0 of type read to ~p1_rdn_to_the_par_pdi_master_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      rdn_to_the_par_pdi_master_0 <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      rdn_to_the_par_pdi_master_0 <= p1_rdn_to_the_par_pdi_master_0;
    end if;

  end process;

  --~p1_rdn_to_the_par_pdi_master_0 assignment, which is an e_mux
  p1_rdn_to_the_par_pdi_master_0 <= NOT ((internal_ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave AND ap_cpu_data_master_read));
  --~wrn_to_the_par_pdi_master_0 of type write to ~p1_wrn_to_the_par_pdi_master_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      wrn_to_the_par_pdi_master_0 <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      wrn_to_the_par_pdi_master_0 <= p1_wrn_to_the_par_pdi_master_0;
    end if;

  end process;

  --~ben_to_the_par_pdi_master_0 of type byteenable to ~p1_ben_to_the_par_pdi_master_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ben_to_the_par_pdi_master_0 <= A_EXT (NOT std_logic_vector'("00000000000000000000000000000000"), 2);
    elsif clk'event and clk = '1' then
      ben_to_the_par_pdi_master_0 <= p1_ben_to_the_par_pdi_master_0;
    end if;

  end process;

  --~p1_wrn_to_the_par_pdi_master_0 assignment, which is an e_mux
  p1_wrn_to_the_par_pdi_master_0 <= NOT ((((internal_ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave AND ap_cpu_data_master_write)) AND ((tri_state_bridge_0_avalon_slave_begins_xfer OR to_std_logic((((std_logic_vector'("00000000000000000000000000000") & (par_pdi_master_0_avalon_tristate_slave_wait_counter))>=std_logic_vector'("00000000000000000000000000000010"))))))));
  --addr_to_the_par_pdi_master_0 of type address to p1_addr_to_the_par_pdi_master_0, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      addr_to_the_par_pdi_master_0 <= std_logic_vector'("0000000000000000");
    elsif clk'event and clk = '1' then
      addr_to_the_par_pdi_master_0 <= p1_addr_to_the_par_pdi_master_0;
    end if;

  end process;

  --p1_addr_to_the_par_pdi_master_0 mux, which is an e_mux
  p1_addr_to_the_par_pdi_master_0 <= A_EXT (Std_Logic_Vector'(A_SRL(ap_cpu_data_master_address_to_slave,std_logic_vector'("00000000000000000000000000000010")) & A_ToStdLogicVector(ap_cpu_data_master_dbs_address(1)) & A_ToStdLogicVector(std_logic'('0'))), 16);
  --d1_tri_state_bridge_0_avalon_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_tri_state_bridge_0_avalon_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_tri_state_bridge_0_avalon_slave_end_xfer <= tri_state_bridge_0_avalon_slave_end_xfer;
    end if;

  end process;

  --par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_1 assignment, which is an e_assign
  par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_1 <= to_std_logic(((std_logic_vector'("00000000000000000000000000000") & (par_pdi_master_0_avalon_tristate_slave_wait_counter)) = std_logic_vector'("00000000000000000000000000000001")));
  --par_pdi_master_0_avalon_tristate_slave_waits_for_read in a cycle, which is an e_mux
  par_pdi_master_0_avalon_tristate_slave_waits_for_read <= par_pdi_master_0_avalon_tristate_slave_in_a_read_cycle AND wait_for_par_pdi_master_0_avalon_tristate_slave_counter;
  --par_pdi_master_0_avalon_tristate_slave_in_a_read_cycle assignment, which is an e_assign
  par_pdi_master_0_avalon_tristate_slave_in_a_read_cycle <= internal_ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave AND ap_cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= par_pdi_master_0_avalon_tristate_slave_in_a_read_cycle;
  --par_pdi_master_0_avalon_tristate_slave_waits_for_write in a cycle, which is an e_mux
  par_pdi_master_0_avalon_tristate_slave_waits_for_write <= par_pdi_master_0_avalon_tristate_slave_in_a_write_cycle AND wait_for_par_pdi_master_0_avalon_tristate_slave_counter;
  --par_pdi_master_0_avalon_tristate_slave_in_a_write_cycle assignment, which is an e_assign
  par_pdi_master_0_avalon_tristate_slave_in_a_write_cycle <= internal_ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave AND ap_cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= par_pdi_master_0_avalon_tristate_slave_in_a_write_cycle;
  internal_par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0 <= to_std_logic(((std_logic_vector'("00000000000000000000000000000") & (par_pdi_master_0_avalon_tristate_slave_wait_counter)) = std_logic_vector'("00000000000000000000000000000000")));
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      par_pdi_master_0_avalon_tristate_slave_wait_counter <= std_logic_vector'("000");
    elsif clk'event and clk = '1' then
      par_pdi_master_0_avalon_tristate_slave_wait_counter <= par_pdi_master_0_avalon_tristate_slave_counter_load_value;
    end if;

  end process;

  par_pdi_master_0_avalon_tristate_slave_counter_load_value <= A_EXT (A_WE_StdLogicVector((std_logic'(((par_pdi_master_0_avalon_tristate_slave_in_a_write_cycle AND tri_state_bridge_0_avalon_slave_begins_xfer))) = '1'), std_logic_vector'("000000000000000000000000000000010"), A_WE_StdLogicVector((std_logic'(((par_pdi_master_0_avalon_tristate_slave_in_a_read_cycle AND tri_state_bridge_0_avalon_slave_begins_xfer))) = '1'), std_logic_vector'("000000000000000000000000000000100"), A_WE_StdLogicVector((std_logic'((NOT internal_par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0)) = '1'), ((std_logic_vector'("000000000000000000000000000000") & (par_pdi_master_0_avalon_tristate_slave_wait_counter)) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000")))), 3);
  wait_for_par_pdi_master_0_avalon_tristate_slave_counter <= tri_state_bridge_0_avalon_slave_begins_xfer OR NOT internal_par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0;
  --~p1_ben_to_the_par_pdi_master_0 byte enable port mux, which is an e_mux
  p1_ben_to_the_par_pdi_master_0 <= A_EXT (NOT (A_WE_StdLogicVector((std_logic'((internal_ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave)) = '1'), (std_logic_vector'("000000000000000000000000000000") & (internal_ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave)), -SIGNED(std_logic_vector'("00000000000000000000000000000001")))), 2);
  (ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave_segment_1(1), ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave_segment_1(0), ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave_segment_0(1), ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave_segment_0(0)) <= ap_cpu_data_master_byteenable;
  internal_ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave <= A_WE_StdLogicVector((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_data_master_dbs_address(1)))) = std_logic_vector'("00000000000000000000000000000000"))), ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave_segment_0, ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave_segment_1);
  --vhdl renameroo for output signals
  ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave <= internal_ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave <= internal_ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave <= internal_ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave <= internal_ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave;
  --vhdl renameroo for output signals
  par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0 <= internal_par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0;
--synthesis translate_off
    --par_pdi_master_0/avalon_tristate_slave enable non-zero assertions, which is an e_register
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

entity niosII_openMac_reset_clk50_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity niosII_openMac_reset_clk50_domain_synch_module;


architecture europa of niosII_openMac_reset_clk50_domain_synch_module is
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

entity niosII_openMac_reset_clk25_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity niosII_openMac_reset_clk25_domain_synch_module;


architecture europa of niosII_openMac_reset_clk25_domain_synch_module is
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

entity niosII_openMac_reset_clkAp_SDRAM_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity niosII_openMac_reset_clkAp_SDRAM_domain_synch_module;


architecture europa of niosII_openMac_reset_clkAp_SDRAM_domain_synch_module is
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
                 signal clk100 : OUT STD_LOGIC;
                 signal clk25 : OUT STD_LOGIC;
                 signal clk50 : OUT STD_LOGIC;
                 signal clkAp_SDRAM : OUT STD_LOGIC;
                 signal clk_0 : IN STD_LOGIC;
                 signal clkpcp : OUT STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- the_altpll_0
                 signal locked_from_the_altpll_0 : OUT STD_LOGIC;
                 signal phasedone_from_the_altpll_0 : OUT STD_LOGIC;

              -- the_async_irq_from_pcp
                 signal in_port_to_the_async_irq_from_pcp : IN STD_LOGIC;

              -- the_benchmark_ap_pio
                 signal out_port_from_the_benchmark_ap_pio : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_epcs_flash_controller_0
                 signal data0_to_the_epcs_flash_controller_0 : IN STD_LOGIC;
                 signal dclk_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;
                 signal sce_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;
                 signal sdo_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;

              -- the_inport_ap
                 signal in_port_to_the_inport_ap : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_lcd
                 signal LCD_E_from_the_lcd : OUT STD_LOGIC;
                 signal LCD_RS_from_the_lcd : OUT STD_LOGIC;
                 signal LCD_RW_from_the_lcd : OUT STD_LOGIC;
                 signal LCD_data_to_and_from_the_lcd : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_outport_ap
                 signal out_port_from_the_outport_ap : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);

              -- the_sdram_0
                 signal zs_addr_from_the_sdram_0 : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                 signal zs_ba_from_the_sdram_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal zs_cas_n_from_the_sdram_0 : OUT STD_LOGIC;
                 signal zs_cke_from_the_sdram_0 : OUT STD_LOGIC;
                 signal zs_cs_n_from_the_sdram_0 : OUT STD_LOGIC;
                 signal zs_dq_to_and_from_the_sdram_0 : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal zs_dqm_from_the_sdram_0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal zs_ras_n_from_the_sdram_0 : OUT STD_LOGIC;
                 signal zs_we_n_from_the_sdram_0 : OUT STD_LOGIC;

              -- the_sync_irq_from_pcp
                 signal in_port_to_the_sync_irq_from_pcp : IN STD_LOGIC;

              -- the_tri_state_bridge_0_avalon_slave
                 signal addr_to_the_par_pdi_master_0 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal ben_to_the_par_pdi_master_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal csn_to_the_par_pdi_master_0 : OUT STD_LOGIC;
                 signal data_to_and_from_the_par_pdi_master_0 : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal rdn_to_the_par_pdi_master_0 : OUT STD_LOGIC;
                 signal wrn_to_the_par_pdi_master_0 : OUT STD_LOGIC
              );
end entity niosII_openMac;


architecture europa of niosII_openMac is
component altpll_0_pll_slave_arbitrator is 
           port (
                 -- inputs:
                    signal altpll_0_pll_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal niosII_openMac_clock_4_out_address_to_slave : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_4_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_4_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_4_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal altpll_0_pll_slave_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal altpll_0_pll_slave_read : OUT STD_LOGIC;
                    signal altpll_0_pll_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal altpll_0_pll_slave_reset : OUT STD_LOGIC;
                    signal altpll_0_pll_slave_write : OUT STD_LOGIC;
                    signal altpll_0_pll_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_altpll_0_pll_slave_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_4_out_granted_altpll_0_pll_slave : OUT STD_LOGIC;
                    signal niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave : OUT STD_LOGIC;
                    signal niosII_openMac_clock_4_out_read_data_valid_altpll_0_pll_slave : OUT STD_LOGIC;
                    signal niosII_openMac_clock_4_out_requests_altpll_0_pll_slave : OUT STD_LOGIC
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
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_cpu_data_master_debugaccess : IN STD_LOGIC;
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC;
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
                    signal ap_cpu_data_master_address : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ap_cpu_data_master_granted_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_async_irq_from_pcp_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_benchmark_ap_pio_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_inport_ap_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_niosII_openMac_clock_1_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_niosII_openMac_clock_2_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_niosII_openMac_clock_3_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_niosII_openMac_clock_4_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_outport_ap_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_granted_system_timer_ap_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_inport_ap_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_outport_ap_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_system_timer_ap_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_async_irq_from_pcp_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_benchmark_ap_pio_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_inport_ap_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_2_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_3_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_4_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_outport_ap_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_system_timer_ap_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_async_irq_from_pcp_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_benchmark_ap_pio_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_inport_ap_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_niosII_openMac_clock_1_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_niosII_openMac_clock_2_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_niosII_openMac_clock_3_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_niosII_openMac_clock_4_in : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_outport_ap_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_sync_irq_from_pcp_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                    signal ap_cpu_data_master_requests_system_timer_ap_s1 : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal async_irq_from_pcp_s1_irq_from_sa : IN STD_LOGIC;
                    signal async_irq_from_pcp_s1_readdata_from_sa : IN STD_LOGIC;
                    signal benchmark_ap_pio_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal d1_ap_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_async_irq_from_pcp_s1_end_xfer : IN STD_LOGIC;
                    signal d1_benchmark_ap_pio_s1_end_xfer : IN STD_LOGIC;
                    signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : IN STD_LOGIC;
                    signal d1_inport_ap_s1_end_xfer : IN STD_LOGIC;
                    signal d1_jtag_uart_1_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                    signal d1_niosII_openMac_clock_1_in_end_xfer : IN STD_LOGIC;
                    signal d1_niosII_openMac_clock_2_in_end_xfer : IN STD_LOGIC;
                    signal d1_niosII_openMac_clock_3_in_end_xfer : IN STD_LOGIC;
                    signal d1_niosII_openMac_clock_4_in_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_memory2_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_outport_ap_s1_end_xfer : IN STD_LOGIC;
                    signal d1_sync_irq_from_pcp_s1_end_xfer : IN STD_LOGIC;
                    signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                    signal d1_system_timer_ap_s1_end_xfer : IN STD_LOGIC;
                    signal d1_tri_state_bridge_0_avalon_slave_end_xfer : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal incoming_data_to_and_from_the_par_pdi_master_0 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal inport_ap_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal jtag_uart_1_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal niosII_openMac_clock_2_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_2_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal niosII_openMac_clock_3_in_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_3_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal niosII_openMac_clock_4_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_4_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal onchip_memory2_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal outport_ap_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0 : IN STD_LOGIC;
                    signal par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_1 : IN STD_LOGIC;
                    signal registered_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal registered_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_irq_from_pcp_s1_irq_from_sa : IN STD_LOGIC;
                    signal sync_irq_from_pcp_s1_readdata_from_sa : IN STD_LOGIC;
                    signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal system_timer_ap_s1_irq_from_sa : IN STD_LOGIC;
                    signal system_timer_ap_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal ap_cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_dbs_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ap_cpu_data_master_dbs_write_16 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ap_cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_data_master_no_byte_enables_and_last_term : OUT STD_LOGIC;
                    signal ap_cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_data_master_waitrequest : OUT STD_LOGIC
                 );
end component ap_cpu_data_master_arbitrator;

component ap_cpu_instruction_master_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_instruction_master_address : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_granted_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_niosII_openMac_clock_0_in : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal ap_cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal d1_ap_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer : IN STD_LOGIC;
                    signal d1_niosII_openMac_clock_0_in_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_memory2_0_s1_end_xfer : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_waitrequest_from_sa : IN STD_LOGIC;
                    signal onchip_memory2_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_instruction_master_latency_counter : OUT STD_LOGIC;
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
                    signal d_address : OUT STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal d_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal d_read : OUT STD_LOGIC;
                    signal d_write : OUT STD_LOGIC;
                    signal d_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_address : OUT STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal i_read : OUT STD_LOGIC;
                    signal jtag_debug_module_debugaccess_to_roms : OUT STD_LOGIC;
                    signal jtag_debug_module_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_debug_module_resetrequest : OUT STD_LOGIC
                 );
end component ap_cpu;

component async_irq_from_pcp_s1_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal async_irq_from_pcp_s1_irq : IN STD_LOGIC;
                    signal async_irq_from_pcp_s1_readdata : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_async_irq_from_pcp_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_async_irq_from_pcp_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_async_irq_from_pcp_s1 : OUT STD_LOGIC;
                    signal async_irq_from_pcp_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal async_irq_from_pcp_s1_chipselect : OUT STD_LOGIC;
                    signal async_irq_from_pcp_s1_irq_from_sa : OUT STD_LOGIC;
                    signal async_irq_from_pcp_s1_readdata_from_sa : OUT STD_LOGIC;
                    signal async_irq_from_pcp_s1_reset_n : OUT STD_LOGIC;
                    signal async_irq_from_pcp_s1_write_n : OUT STD_LOGIC;
                    signal async_irq_from_pcp_s1_writedata : OUT STD_LOGIC;
                    signal d1_async_irq_from_pcp_s1_end_xfer : OUT STD_LOGIC
                 );
end component async_irq_from_pcp_s1_arbitrator;

component async_irq_from_pcp is 
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
end component async_irq_from_pcp;

component benchmark_ap_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal benchmark_ap_pio_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_benchmark_ap_pio_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_benchmark_ap_pio_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_benchmark_ap_pio_s1 : OUT STD_LOGIC;
                    signal benchmark_ap_pio_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal benchmark_ap_pio_s1_chipselect : OUT STD_LOGIC;
                    signal benchmark_ap_pio_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal benchmark_ap_pio_s1_reset_n : OUT STD_LOGIC;
                    signal benchmark_ap_pio_s1_write_n : OUT STD_LOGIC;
                    signal benchmark_ap_pio_s1_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal d1_benchmark_ap_pio_s1_end_xfer : OUT STD_LOGIC
                 );
end component benchmark_ap_pio_s1_arbitrator;

component benchmark_ap_pio is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component benchmark_ap_pio;

component epcs_flash_controller_0_epcs_control_port_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_dataavailable : IN STD_LOGIC;
                    signal epcs_flash_controller_0_epcs_control_port_endofpacket : IN STD_LOGIC;
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
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal inport_ap_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_inport_ap_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_inport_ap_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_inport_ap_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_inport_ap_s1 : OUT STD_LOGIC;
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
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_irq : IN STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_1_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                    signal jtag_uart_1_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave : OUT STD_LOGIC;
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

component lcd_control_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal lcd_control_slave_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_3_out_address_to_slave : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal niosII_openMac_clock_3_out_nativeaddress : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal niosII_openMac_clock_3_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_3_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_3_out_writedata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_lcd_control_slave_end_xfer : OUT STD_LOGIC;
                    signal lcd_control_slave_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal lcd_control_slave_begintransfer : OUT STD_LOGIC;
                    signal lcd_control_slave_read : OUT STD_LOGIC;
                    signal lcd_control_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal lcd_control_slave_wait_counter_eq_0 : OUT STD_LOGIC;
                    signal lcd_control_slave_write : OUT STD_LOGIC;
                    signal lcd_control_slave_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_3_out_granted_lcd_control_slave : OUT STD_LOGIC;
                    signal niosII_openMac_clock_3_out_qualified_request_lcd_control_slave : OUT STD_LOGIC;
                    signal niosII_openMac_clock_3_out_read_data_valid_lcd_control_slave : OUT STD_LOGIC;
                    signal niosII_openMac_clock_3_out_requests_lcd_control_slave : OUT STD_LOGIC
                 );
end component lcd_control_slave_arbitrator;

component lcd is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal begintransfer : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- outputs:
                    signal LCD_E : OUT STD_LOGIC;
                    signal LCD_RS : OUT STD_LOGIC;
                    signal LCD_RW : OUT STD_LOGIC;
                    signal LCD_data : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component lcd;

component niosII_openMac_clock_0_in_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_in_endofpacket : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in : OUT STD_LOGIC;
                    signal d1_niosII_openMac_clock_0_in_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_in_address : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_in_nativeaddress : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_read : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_0_in_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_in_write : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_0_in_arbitrator;

component niosII_openMac_clock_0_out_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d1_sdram_0_s1_end_xfer : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal niosII_openMac_clock_0_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_0_out_granted_sdram_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_requests_sdram_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal sdram_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal sdram_0_s1_waitrequest_from_sa : IN STD_LOGIC;

                 -- outputs:
                    signal niosII_openMac_clock_0_out_address_to_slave : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
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
                    signal slave_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal slave_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_nativeaddress : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;
                    signal slave_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal master_address : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal master_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal master_nativeaddress : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
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
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_in_endofpacket : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_niosII_openMac_clock_1_in : OUT STD_LOGIC;
                    signal d1_niosII_openMac_clock_1_in_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_address : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_nativeaddress : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_read : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_1_in_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_write : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component niosII_openMac_clock_1_in_arbitrator;

component niosII_openMac_clock_1_out_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d1_sdram_0_s1_end_xfer : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_granted_sdram_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_qualified_request_sdram_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_requests_sdram_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal sdram_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal sdram_0_s1_waitrequest_from_sa : IN STD_LOGIC;

                 -- outputs:
                    signal niosII_openMac_clock_1_out_address_to_slave : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
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
                    signal slave_address : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal slave_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_nativeaddress : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;
                    signal slave_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal master_address : OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal master_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal master_nativeaddress : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal master_read : OUT STD_LOGIC;
                    signal master_write : OUT STD_LOGIC;
                    signal master_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal slave_endofpacket : OUT STD_LOGIC;
                    signal slave_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal slave_waitrequest : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_1;

component niosII_openMac_clock_2_in_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal niosII_openMac_clock_2_in_endofpacket : IN STD_LOGIC;
                    signal niosII_openMac_clock_2_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_2_in_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_niosII_openMac_clock_2_in : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_2_in : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_niosII_openMac_clock_2_in : OUT STD_LOGIC;
                    signal d1_niosII_openMac_clock_2_in_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_2_in_address : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_2_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_2_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_2_in_nativeaddress : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal niosII_openMac_clock_2_in_read : OUT STD_LOGIC;
                    signal niosII_openMac_clock_2_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_2_in_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_2_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_2_in_write : OUT STD_LOGIC;
                    signal niosII_openMac_clock_2_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component niosII_openMac_clock_2_in_arbitrator;

component niosII_openMac_clock_2_out_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d1_remote_update_cycloneiii_0_s1_end_xfer : IN STD_LOGIC;
                    signal niosII_openMac_clock_2_out_address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_2_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_2_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1 : IN STD_LOGIC;
                    signal niosII_openMac_clock_2_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_2_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal remote_update_cycloneiii_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal remote_update_cycloneiii_0_s1_waitrequest_from_sa : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal niosII_openMac_clock_2_out_address_to_slave : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_2_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_2_out_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_2_out_waitrequest : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_2_out_arbitrator;

component niosII_openMac_clock_2 is 
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
end component niosII_openMac_clock_2;

component niosII_openMac_clock_3_in_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal niosII_openMac_clock_3_in_endofpacket : IN STD_LOGIC;
                    signal niosII_openMac_clock_3_in_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_3_in_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_niosII_openMac_clock_3_in : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_3_in : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_niosII_openMac_clock_3_in : OUT STD_LOGIC;
                    signal d1_niosII_openMac_clock_3_in_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_3_in_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal niosII_openMac_clock_3_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_3_in_nativeaddress : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal niosII_openMac_clock_3_in_read : OUT STD_LOGIC;
                    signal niosII_openMac_clock_3_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_3_in_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_3_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_3_in_write : OUT STD_LOGIC;
                    signal niosII_openMac_clock_3_in_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component niosII_openMac_clock_3_in_arbitrator;

component niosII_openMac_clock_3_out_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d1_lcd_control_slave_end_xfer : IN STD_LOGIC;
                    signal lcd_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal lcd_control_slave_wait_counter_eq_0 : IN STD_LOGIC;
                    signal niosII_openMac_clock_3_out_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal niosII_openMac_clock_3_out_granted_lcd_control_slave : IN STD_LOGIC;
                    signal niosII_openMac_clock_3_out_qualified_request_lcd_control_slave : IN STD_LOGIC;
                    signal niosII_openMac_clock_3_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_3_out_read_data_valid_lcd_control_slave : IN STD_LOGIC;
                    signal niosII_openMac_clock_3_out_requests_lcd_control_slave : IN STD_LOGIC;
                    signal niosII_openMac_clock_3_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_3_out_writedata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal niosII_openMac_clock_3_out_address_to_slave : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal niosII_openMac_clock_3_out_readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_3_out_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_3_out_waitrequest : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_3_out_arbitrator;

component niosII_openMac_clock_3 is 
           port (
                 -- inputs:
                    signal master_clk : IN STD_LOGIC;
                    signal master_endofpacket : IN STD_LOGIC;
                    signal master_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal master_reset_n : IN STD_LOGIC;
                    signal master_waitrequest : IN STD_LOGIC;
                    signal slave_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal slave_clk : IN STD_LOGIC;
                    signal slave_nativeaddress : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal slave_read : IN STD_LOGIC;
                    signal slave_reset_n : IN STD_LOGIC;
                    signal slave_write : IN STD_LOGIC;
                    signal slave_writedata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- outputs:
                    signal master_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal master_nativeaddress : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal master_read : OUT STD_LOGIC;
                    signal master_write : OUT STD_LOGIC;
                    signal master_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal slave_endofpacket : OUT STD_LOGIC;
                    signal slave_readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal slave_waitrequest : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_3;

component niosII_openMac_clock_4_in_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal niosII_openMac_clock_4_in_endofpacket : IN STD_LOGIC;
                    signal niosII_openMac_clock_4_in_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_4_in_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_niosII_openMac_clock_4_in : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_4_in : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_niosII_openMac_clock_4_in : OUT STD_LOGIC;
                    signal d1_niosII_openMac_clock_4_in_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_4_in_address : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_4_in_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_4_in_endofpacket_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_4_in_nativeaddress : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal niosII_openMac_clock_4_in_read : OUT STD_LOGIC;
                    signal niosII_openMac_clock_4_in_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_4_in_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_4_in_waitrequest_from_sa : OUT STD_LOGIC;
                    signal niosII_openMac_clock_4_in_write : OUT STD_LOGIC;
                    signal niosII_openMac_clock_4_in_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component niosII_openMac_clock_4_in_arbitrator;

component niosII_openMac_clock_4_out_arbitrator is 
           port (
                 -- inputs:
                    signal altpll_0_pll_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal d1_altpll_0_pll_slave_end_xfer : IN STD_LOGIC;
                    signal niosII_openMac_clock_4_out_address : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_4_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_4_out_granted_altpll_0_pll_slave : IN STD_LOGIC;
                    signal niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave : IN STD_LOGIC;
                    signal niosII_openMac_clock_4_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_4_out_read_data_valid_altpll_0_pll_slave : IN STD_LOGIC;
                    signal niosII_openMac_clock_4_out_requests_altpll_0_pll_slave : IN STD_LOGIC;
                    signal niosII_openMac_clock_4_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_4_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal niosII_openMac_clock_4_out_address_to_slave : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_4_out_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_4_out_reset_n : OUT STD_LOGIC;
                    signal niosII_openMac_clock_4_out_waitrequest : OUT STD_LOGIC
                 );
end component niosII_openMac_clock_4_out_arbitrator;

component niosII_openMac_clock_4 is 
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
end component niosII_openMac_clock_4;

component onchip_memory2_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ap_cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_instruction_master_latency_counter : IN STD_LOGIC;
                    signal ap_cpu_instruction_master_read : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal onchip_memory2_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_granted_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal ap_cpu_instruction_master_requests_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal d1_onchip_memory2_0_s1_end_xfer : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_address : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal onchip_memory2_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal onchip_memory2_0_s1_chipselect : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_clken : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal onchip_memory2_0_s1_reset : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_write : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal registered_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC
                 );
end component onchip_memory2_0_s1_arbitrator;

component onchip_memory2_0 is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal clken : IN STD_LOGIC;
                    signal reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component onchip_memory2_0;

component outport_ap_s1_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal outport_ap_s1_readdata : IN STD_LOGIC_VECTOR (23 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_outport_ap_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_outport_ap_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_outport_ap_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_outport_ap_s1 : OUT STD_LOGIC;
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

component remote_update_cycloneiii_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal niosII_openMac_clock_2_out_address_to_slave : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal niosII_openMac_clock_2_out_nativeaddress : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
                    signal niosII_openMac_clock_2_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_2_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_2_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal remote_update_cycloneiii_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal remote_update_cycloneiii_0_s1_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d1_remote_update_cycloneiii_0_s1_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                    signal niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                    signal niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
                    signal niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1 : OUT STD_LOGIC;
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

component sdram_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal niosII_openMac_clock_0_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_0_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_0_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_address_to_slave : IN STD_LOGIC_VECTOR (26 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal niosII_openMac_clock_1_out_read : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_write : IN STD_LOGIC;
                    signal niosII_openMac_clock_1_out_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal sdram_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal sdram_0_s1_readdatavalid : IN STD_LOGIC;
                    signal sdram_0_s1_waitrequest : IN STD_LOGIC;

                 -- outputs:
                    signal d1_sdram_0_s1_end_xfer : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_out_granted_sdram_0_s1 : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1 : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register : OUT STD_LOGIC;
                    signal niosII_openMac_clock_0_out_requests_sdram_0_s1 : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_granted_sdram_0_s1 : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_qualified_request_sdram_0_s1 : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1 : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register : OUT STD_LOGIC;
                    signal niosII_openMac_clock_1_out_requests_sdram_0_s1 : OUT STD_LOGIC;
                    signal sdram_0_s1_address : OUT STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal sdram_0_s1_byteenable_n : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal sdram_0_s1_chipselect : OUT STD_LOGIC;
                    signal sdram_0_s1_read_n : OUT STD_LOGIC;
                    signal sdram_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal sdram_0_s1_reset_n : OUT STD_LOGIC;
                    signal sdram_0_s1_waitrequest_from_sa : OUT STD_LOGIC;
                    signal sdram_0_s1_write_n : OUT STD_LOGIC;
                    signal sdram_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component sdram_0_s1_arbitrator;

component sdram_0 is 
           port (
                 -- inputs:
                    signal az_addr : IN STD_LOGIC_VECTOR (24 DOWNTO 0);
                    signal az_be_n : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal az_cs : IN STD_LOGIC;
                    signal az_data : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal az_rd_n : IN STD_LOGIC;
                    signal az_wr_n : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal za_data : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal za_valid : OUT STD_LOGIC;
                    signal za_waitrequest : OUT STD_LOGIC;
                    signal zs_addr : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal zs_ba : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal zs_cas_n : OUT STD_LOGIC;
                    signal zs_cke : OUT STD_LOGIC;
                    signal zs_cs_n : OUT STD_LOGIC;
                    signal zs_dq : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal zs_dqm : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal zs_ras_n : OUT STD_LOGIC;
                    signal zs_we_n : OUT STD_LOGIC
                 );
end component sdram_0;

component sync_irq_from_pcp_s1_arbitrator is 
           port (
                 -- inputs:
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sync_irq_from_pcp_s1_irq : IN STD_LOGIC;
                    signal sync_irq_from_pcp_s1_readdata : IN STD_LOGIC;

                 -- outputs:
                    signal ap_cpu_data_master_granted_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_sync_irq_from_pcp_s1 : OUT STD_LOGIC;
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
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal ap_cpu_data_master_granted_sysid_control_slave : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_sysid_control_slave : OUT STD_LOGIC;
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
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal ap_cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal system_timer_ap_s1_irq : IN STD_LOGIC;
                    signal system_timer_ap_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal ap_cpu_data_master_granted_system_timer_ap_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_system_timer_ap_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_system_timer_ap_s1 : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_system_timer_ap_s1 : OUT STD_LOGIC;
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
                    signal ap_cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (27 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ap_cpu_data_master_dbs_address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ap_cpu_data_master_dbs_write_16 : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ap_cpu_data_master_no_byte_enables_and_last_term : IN STD_LOGIC;
                    signal ap_cpu_data_master_read : IN STD_LOGIC;
                    signal ap_cpu_data_master_write : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal addr_to_the_par_pdi_master_0 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal ben_to_the_par_pdi_master_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal csn_to_the_par_pdi_master_0 : OUT STD_LOGIC;
                    signal d1_tri_state_bridge_0_avalon_slave_end_xfer : OUT STD_LOGIC;
                    signal data_to_and_from_the_par_pdi_master_0 : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal incoming_data_to_and_from_the_par_pdi_master_0 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0 : OUT STD_LOGIC;
                    signal par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_1 : OUT STD_LOGIC;
                    signal rdn_to_the_par_pdi_master_0 : OUT STD_LOGIC;
                    signal registered_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave : OUT STD_LOGIC;
                    signal wrn_to_the_par_pdi_master_0 : OUT STD_LOGIC
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

component niosII_openMac_reset_clk50_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component niosII_openMac_reset_clk50_domain_synch_module;

component niosII_openMac_reset_clk25_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component niosII_openMac_reset_clk25_domain_synch_module;

component niosII_openMac_reset_clkAp_SDRAM_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component niosII_openMac_reset_clkAp_SDRAM_domain_synch_module;

                signal altpll_0_pll_slave_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal altpll_0_pll_slave_read :  STD_LOGIC;
                signal altpll_0_pll_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal altpll_0_pll_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal altpll_0_pll_slave_reset :  STD_LOGIC;
                signal altpll_0_pll_slave_write :  STD_LOGIC;
                signal altpll_0_pll_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ap_cpu_data_master_address :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal ap_cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal ap_cpu_data_master_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_data_master_dbs_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ap_cpu_data_master_dbs_write_16 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ap_cpu_data_master_debugaccess :  STD_LOGIC;
                signal ap_cpu_data_master_granted_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_data_master_granted_async_irq_from_pcp_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_granted_benchmark_ap_pio_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_data_master_granted_inport_ap_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal ap_cpu_data_master_granted_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal ap_cpu_data_master_granted_niosII_openMac_clock_2_in :  STD_LOGIC;
                signal ap_cpu_data_master_granted_niosII_openMac_clock_3_in :  STD_LOGIC;
                signal ap_cpu_data_master_granted_niosII_openMac_clock_4_in :  STD_LOGIC;
                signal ap_cpu_data_master_granted_onchip_memory2_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_granted_outport_ap_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave :  STD_LOGIC;
                signal ap_cpu_data_master_granted_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_granted_sysid_control_slave :  STD_LOGIC;
                signal ap_cpu_data_master_granted_system_timer_ap_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_irq :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ap_cpu_data_master_no_byte_enables_and_last_term :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_inport_ap_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_outport_ap_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal ap_cpu_data_master_qualified_request_system_timer_ap_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_read :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_async_irq_from_pcp_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_benchmark_ap_pio_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_inport_ap_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_2_in :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_3_in :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_niosII_openMac_clock_4_in :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_outport_ap_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_sysid_control_slave :  STD_LOGIC;
                signal ap_cpu_data_master_read_data_valid_system_timer_ap_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ap_cpu_data_master_requests_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_data_master_requests_async_irq_from_pcp_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_requests_benchmark_ap_pio_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_data_master_requests_inport_ap_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave :  STD_LOGIC;
                signal ap_cpu_data_master_requests_niosII_openMac_clock_1_in :  STD_LOGIC;
                signal ap_cpu_data_master_requests_niosII_openMac_clock_2_in :  STD_LOGIC;
                signal ap_cpu_data_master_requests_niosII_openMac_clock_3_in :  STD_LOGIC;
                signal ap_cpu_data_master_requests_niosII_openMac_clock_4_in :  STD_LOGIC;
                signal ap_cpu_data_master_requests_onchip_memory2_0_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_requests_outport_ap_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave :  STD_LOGIC;
                signal ap_cpu_data_master_requests_sync_irq_from_pcp_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_requests_sysid_control_slave :  STD_LOGIC;
                signal ap_cpu_data_master_requests_system_timer_ap_s1 :  STD_LOGIC;
                signal ap_cpu_data_master_waitrequest :  STD_LOGIC;
                signal ap_cpu_data_master_write :  STD_LOGIC;
                signal ap_cpu_data_master_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ap_cpu_instruction_master_address :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal ap_cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (27 DOWNTO 0);
                signal ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal ap_cpu_instruction_master_granted_onchip_memory2_0_s1 :  STD_LOGIC;
                signal ap_cpu_instruction_master_latency_counter :  STD_LOGIC;
                signal ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1 :  STD_LOGIC;
                signal ap_cpu_instruction_master_read :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_data_valid_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1 :  STD_LOGIC;
                signal ap_cpu_instruction_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ap_cpu_instruction_master_readdatavalid :  STD_LOGIC;
                signal ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module :  STD_LOGIC;
                signal ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port :  STD_LOGIC;
                signal ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in :  STD_LOGIC;
                signal ap_cpu_instruction_master_requests_onchip_memory2_0_s1 :  STD_LOGIC;
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
                signal async_irq_from_pcp_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal async_irq_from_pcp_s1_chipselect :  STD_LOGIC;
                signal async_irq_from_pcp_s1_irq :  STD_LOGIC;
                signal async_irq_from_pcp_s1_irq_from_sa :  STD_LOGIC;
                signal async_irq_from_pcp_s1_readdata :  STD_LOGIC;
                signal async_irq_from_pcp_s1_readdata_from_sa :  STD_LOGIC;
                signal async_irq_from_pcp_s1_reset_n :  STD_LOGIC;
                signal async_irq_from_pcp_s1_write_n :  STD_LOGIC;
                signal async_irq_from_pcp_s1_writedata :  STD_LOGIC;
                signal benchmark_ap_pio_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal benchmark_ap_pio_s1_chipselect :  STD_LOGIC;
                signal benchmark_ap_pio_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal benchmark_ap_pio_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal benchmark_ap_pio_s1_reset_n :  STD_LOGIC;
                signal benchmark_ap_pio_s1_write_n :  STD_LOGIC;
                signal benchmark_ap_pio_s1_writedata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal clk25_reset_n :  STD_LOGIC;
                signal clk50_reset_n :  STD_LOGIC;
                signal clkAp_SDRAM_reset_n :  STD_LOGIC;
                signal clk_0_reset_n :  STD_LOGIC;
                signal d1_altpll_0_pll_slave_end_xfer :  STD_LOGIC;
                signal d1_ap_cpu_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal d1_async_irq_from_pcp_s1_end_xfer :  STD_LOGIC;
                signal d1_benchmark_ap_pio_s1_end_xfer :  STD_LOGIC;
                signal d1_epcs_flash_controller_0_epcs_control_port_end_xfer :  STD_LOGIC;
                signal d1_inport_ap_s1_end_xfer :  STD_LOGIC;
                signal d1_jtag_uart_1_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal d1_lcd_control_slave_end_xfer :  STD_LOGIC;
                signal d1_niosII_openMac_clock_0_in_end_xfer :  STD_LOGIC;
                signal d1_niosII_openMac_clock_1_in_end_xfer :  STD_LOGIC;
                signal d1_niosII_openMac_clock_2_in_end_xfer :  STD_LOGIC;
                signal d1_niosII_openMac_clock_3_in_end_xfer :  STD_LOGIC;
                signal d1_niosII_openMac_clock_4_in_end_xfer :  STD_LOGIC;
                signal d1_onchip_memory2_0_s1_end_xfer :  STD_LOGIC;
                signal d1_outport_ap_s1_end_xfer :  STD_LOGIC;
                signal d1_remote_update_cycloneiii_0_s1_end_xfer :  STD_LOGIC;
                signal d1_sdram_0_s1_end_xfer :  STD_LOGIC;
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
                signal epcs_flash_controller_0_epcs_control_port_read_n :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal epcs_flash_controller_0_epcs_control_port_readyfordata :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_reset_n :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_write_n :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal incoming_data_to_and_from_the_par_pdi_master_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal inport_ap_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal inport_ap_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal inport_ap_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal inport_ap_s1_reset_n :  STD_LOGIC;
                signal internal_LCD_E_from_the_lcd :  STD_LOGIC;
                signal internal_LCD_RS_from_the_lcd :  STD_LOGIC;
                signal internal_LCD_RW_from_the_lcd :  STD_LOGIC;
                signal internal_addr_to_the_par_pdi_master_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_ben_to_the_par_pdi_master_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_clk25 :  STD_LOGIC;
                signal internal_clk50 :  STD_LOGIC;
                signal internal_clkAp_SDRAM :  STD_LOGIC;
                signal internal_csn_to_the_par_pdi_master_0 :  STD_LOGIC;
                signal internal_dclk_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal internal_locked_from_the_altpll_0 :  STD_LOGIC;
                signal internal_out_port_from_the_benchmark_ap_pio :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal internal_out_port_from_the_outport_ap :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal internal_phasedone_from_the_altpll_0 :  STD_LOGIC;
                signal internal_rdn_to_the_par_pdi_master_0 :  STD_LOGIC;
                signal internal_sce_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal internal_sdo_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal internal_wrn_to_the_par_pdi_master_0 :  STD_LOGIC;
                signal internal_zs_addr_from_the_sdram_0 :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal internal_zs_ba_from_the_sdram_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal internal_zs_cas_n_from_the_sdram_0 :  STD_LOGIC;
                signal internal_zs_cke_from_the_sdram_0 :  STD_LOGIC;
                signal internal_zs_cs_n_from_the_sdram_0 :  STD_LOGIC;
                signal internal_zs_dqm_from_the_sdram_0 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal internal_zs_ras_n_from_the_sdram_0 :  STD_LOGIC;
                signal internal_zs_we_n_from_the_sdram_0 :  STD_LOGIC;
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
                signal lcd_control_slave_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal lcd_control_slave_begintransfer :  STD_LOGIC;
                signal lcd_control_slave_read :  STD_LOGIC;
                signal lcd_control_slave_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal lcd_control_slave_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal lcd_control_slave_wait_counter_eq_0 :  STD_LOGIC;
                signal lcd_control_slave_write :  STD_LOGIC;
                signal lcd_control_slave_writedata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal module_input6 :  STD_LOGIC;
                signal module_input7 :  STD_LOGIC;
                signal module_input8 :  STD_LOGIC;
                signal module_input9 :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_address :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal niosII_openMac_clock_0_in_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_0_in_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_nativeaddress :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal niosII_openMac_clock_0_in_read :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_0_in_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_0_in_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_write :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_0_out_address :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal niosII_openMac_clock_0_out_address_to_slave :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal niosII_openMac_clock_0_out_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_0_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_granted_sdram_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_nativeaddress :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_read :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_0_out_requests_sdram_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_write :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_1_in_address :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal niosII_openMac_clock_1_in_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_1_in_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_nativeaddress :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal niosII_openMac_clock_1_in_read :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_1_in_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_1_in_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_write :  STD_LOGIC;
                signal niosII_openMac_clock_1_in_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_1_out_address :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal niosII_openMac_clock_1_out_address_to_slave :  STD_LOGIC_VECTOR (26 DOWNTO 0);
                signal niosII_openMac_clock_1_out_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_1_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_granted_sdram_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_nativeaddress :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal niosII_openMac_clock_1_out_qualified_request_sdram_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_read :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_1_out_requests_sdram_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_write :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_2_in_address :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal niosII_openMac_clock_2_in_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_2_in_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_nativeaddress :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal niosII_openMac_clock_2_in_read :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_2_in_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_2_in_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_write :  STD_LOGIC;
                signal niosII_openMac_clock_2_in_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_2_out_address :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal niosII_openMac_clock_2_out_address_to_slave :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal niosII_openMac_clock_2_out_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_2_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_nativeaddress :  STD_LOGIC_VECTOR (5 DOWNTO 0);
                signal niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_read :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1 :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_write :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_3_in_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_3_in_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_nativeaddress :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_3_in_read :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal niosII_openMac_clock_3_in_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal niosII_openMac_clock_3_in_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_write :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_writedata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal niosII_openMac_clock_3_out_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_3_out_address_to_slave :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_3_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_granted_lcd_control_slave :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_nativeaddress :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_3_out_qualified_request_lcd_control_slave :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_read :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_read_data_valid_lcd_control_slave :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal niosII_openMac_clock_3_out_requests_lcd_control_slave :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_write :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_writedata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal niosII_openMac_clock_4_in_address :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_4_in_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_4_in_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_nativeaddress :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_4_in_read :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_4_in_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_4_in_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_waitrequest_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_write :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_4_out_address :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_4_out_address_to_slave :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_4_out_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal niosII_openMac_clock_4_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_granted_altpll_0_pll_slave :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_nativeaddress :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_read :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_read_data_valid_altpll_0_pll_slave :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_4_out_requests_altpll_0_pll_slave :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_reset_n :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_waitrequest :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_write :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_memory2_0_s1_address :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal onchip_memory2_0_s1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal onchip_memory2_0_s1_chipselect :  STD_LOGIC;
                signal onchip_memory2_0_s1_clken :  STD_LOGIC;
                signal onchip_memory2_0_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_memory2_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_memory2_0_s1_reset :  STD_LOGIC;
                signal onchip_memory2_0_s1_write :  STD_LOGIC;
                signal onchip_memory2_0_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
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
                signal par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0 :  STD_LOGIC;
                signal par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_1 :  STD_LOGIC;
                signal registered_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 :  STD_LOGIC;
                signal registered_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave :  STD_LOGIC;
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
                signal sdram_0_s1_address :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal sdram_0_s1_byteenable_n :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal sdram_0_s1_chipselect :  STD_LOGIC;
                signal sdram_0_s1_read_n :  STD_LOGIC;
                signal sdram_0_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal sdram_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal sdram_0_s1_readdatavalid :  STD_LOGIC;
                signal sdram_0_s1_reset_n :  STD_LOGIC;
                signal sdram_0_s1_waitrequest :  STD_LOGIC;
                signal sdram_0_s1_waitrequest_from_sa :  STD_LOGIC;
                signal sdram_0_s1_write_n :  STD_LOGIC;
                signal sdram_0_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
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
      niosII_openMac_clock_4_out_granted_altpll_0_pll_slave => niosII_openMac_clock_4_out_granted_altpll_0_pll_slave,
      niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave => niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave,
      niosII_openMac_clock_4_out_read_data_valid_altpll_0_pll_slave => niosII_openMac_clock_4_out_read_data_valid_altpll_0_pll_slave,
      niosII_openMac_clock_4_out_requests_altpll_0_pll_slave => niosII_openMac_clock_4_out_requests_altpll_0_pll_slave,
      altpll_0_pll_slave_readdata => altpll_0_pll_slave_readdata,
      clk => clk_0,
      niosII_openMac_clock_4_out_address_to_slave => niosII_openMac_clock_4_out_address_to_slave,
      niosII_openMac_clock_4_out_read => niosII_openMac_clock_4_out_read,
      niosII_openMac_clock_4_out_write => niosII_openMac_clock_4_out_write,
      niosII_openMac_clock_4_out_writedata => niosII_openMac_clock_4_out_writedata,
      reset_n => clk_0_reset_n
    );


  --clk50 out_clk assignment, which is an e_assign
  internal_clk50 <= out_clk_altpll_0_c0;
  --clkpcp out_clk assignment, which is an e_assign
  clkpcp <= out_clk_altpll_0_c1;
  --clk100 out_clk assignment, which is an e_assign
  clk100 <= out_clk_altpll_0_c2;
  --clkAp_SDRAM out_clk assignment, which is an e_assign
  internal_clkAp_SDRAM <= out_clk_altpll_0_c3;
  --clk25 out_clk assignment, which is an e_assign
  internal_clk25 <= out_clk_altpll_0_c4;
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
      clk => internal_clk50,
      reset_n => clk50_reset_n
    );


  --the_ap_cpu_data_master, which is an e_instance
  the_ap_cpu_data_master : ap_cpu_data_master_arbitrator
    port map(
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_dbs_address => ap_cpu_data_master_dbs_address,
      ap_cpu_data_master_dbs_write_16 => ap_cpu_data_master_dbs_write_16,
      ap_cpu_data_master_irq => ap_cpu_data_master_irq,
      ap_cpu_data_master_no_byte_enables_and_last_term => ap_cpu_data_master_no_byte_enables_and_last_term,
      ap_cpu_data_master_readdata => ap_cpu_data_master_readdata,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_address => ap_cpu_data_master_address,
      ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave => ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave,
      ap_cpu_data_master_granted_ap_cpu_jtag_debug_module => ap_cpu_data_master_granted_ap_cpu_jtag_debug_module,
      ap_cpu_data_master_granted_async_irq_from_pcp_s1 => ap_cpu_data_master_granted_async_irq_from_pcp_s1,
      ap_cpu_data_master_granted_benchmark_ap_pio_s1 => ap_cpu_data_master_granted_benchmark_ap_pio_s1,
      ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port => ap_cpu_data_master_granted_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_data_master_granted_inport_ap_s1 => ap_cpu_data_master_granted_inport_ap_s1,
      ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave => ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave,
      ap_cpu_data_master_granted_niosII_openMac_clock_1_in => ap_cpu_data_master_granted_niosII_openMac_clock_1_in,
      ap_cpu_data_master_granted_niosII_openMac_clock_2_in => ap_cpu_data_master_granted_niosII_openMac_clock_2_in,
      ap_cpu_data_master_granted_niosII_openMac_clock_3_in => ap_cpu_data_master_granted_niosII_openMac_clock_3_in,
      ap_cpu_data_master_granted_niosII_openMac_clock_4_in => ap_cpu_data_master_granted_niosII_openMac_clock_4_in,
      ap_cpu_data_master_granted_onchip_memory2_0_s1 => ap_cpu_data_master_granted_onchip_memory2_0_s1,
      ap_cpu_data_master_granted_outport_ap_s1 => ap_cpu_data_master_granted_outport_ap_s1,
      ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave => ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave,
      ap_cpu_data_master_granted_sync_irq_from_pcp_s1 => ap_cpu_data_master_granted_sync_irq_from_pcp_s1,
      ap_cpu_data_master_granted_sysid_control_slave => ap_cpu_data_master_granted_sysid_control_slave,
      ap_cpu_data_master_granted_system_timer_ap_s1 => ap_cpu_data_master_granted_system_timer_ap_s1,
      ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module => ap_cpu_data_master_qualified_request_ap_cpu_jtag_debug_module,
      ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1 => ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1,
      ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1 => ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1,
      ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port => ap_cpu_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_data_master_qualified_request_inport_ap_s1 => ap_cpu_data_master_qualified_request_inport_ap_s1,
      ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave => ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave,
      ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in => ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in,
      ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in => ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in,
      ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in => ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in,
      ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in => ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in,
      ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 => ap_cpu_data_master_qualified_request_onchip_memory2_0_s1,
      ap_cpu_data_master_qualified_request_outport_ap_s1 => ap_cpu_data_master_qualified_request_outport_ap_s1,
      ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave => ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave,
      ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1 => ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1,
      ap_cpu_data_master_qualified_request_sysid_control_slave => ap_cpu_data_master_qualified_request_sysid_control_slave,
      ap_cpu_data_master_qualified_request_system_timer_ap_s1 => ap_cpu_data_master_qualified_request_system_timer_ap_s1,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module => ap_cpu_data_master_read_data_valid_ap_cpu_jtag_debug_module,
      ap_cpu_data_master_read_data_valid_async_irq_from_pcp_s1 => ap_cpu_data_master_read_data_valid_async_irq_from_pcp_s1,
      ap_cpu_data_master_read_data_valid_benchmark_ap_pio_s1 => ap_cpu_data_master_read_data_valid_benchmark_ap_pio_s1,
      ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port => ap_cpu_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_data_master_read_data_valid_inport_ap_s1 => ap_cpu_data_master_read_data_valid_inport_ap_s1,
      ap_cpu_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave => ap_cpu_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave,
      ap_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in => ap_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in,
      ap_cpu_data_master_read_data_valid_niosII_openMac_clock_2_in => ap_cpu_data_master_read_data_valid_niosII_openMac_clock_2_in,
      ap_cpu_data_master_read_data_valid_niosII_openMac_clock_3_in => ap_cpu_data_master_read_data_valid_niosII_openMac_clock_3_in,
      ap_cpu_data_master_read_data_valid_niosII_openMac_clock_4_in => ap_cpu_data_master_read_data_valid_niosII_openMac_clock_4_in,
      ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 => ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1,
      ap_cpu_data_master_read_data_valid_outport_ap_s1 => ap_cpu_data_master_read_data_valid_outport_ap_s1,
      ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave => ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave,
      ap_cpu_data_master_read_data_valid_sync_irq_from_pcp_s1 => ap_cpu_data_master_read_data_valid_sync_irq_from_pcp_s1,
      ap_cpu_data_master_read_data_valid_sysid_control_slave => ap_cpu_data_master_read_data_valid_sysid_control_slave,
      ap_cpu_data_master_read_data_valid_system_timer_ap_s1 => ap_cpu_data_master_read_data_valid_system_timer_ap_s1,
      ap_cpu_data_master_requests_ap_cpu_jtag_debug_module => ap_cpu_data_master_requests_ap_cpu_jtag_debug_module,
      ap_cpu_data_master_requests_async_irq_from_pcp_s1 => ap_cpu_data_master_requests_async_irq_from_pcp_s1,
      ap_cpu_data_master_requests_benchmark_ap_pio_s1 => ap_cpu_data_master_requests_benchmark_ap_pio_s1,
      ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port => ap_cpu_data_master_requests_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_data_master_requests_inport_ap_s1 => ap_cpu_data_master_requests_inport_ap_s1,
      ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave => ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave,
      ap_cpu_data_master_requests_niosII_openMac_clock_1_in => ap_cpu_data_master_requests_niosII_openMac_clock_1_in,
      ap_cpu_data_master_requests_niosII_openMac_clock_2_in => ap_cpu_data_master_requests_niosII_openMac_clock_2_in,
      ap_cpu_data_master_requests_niosII_openMac_clock_3_in => ap_cpu_data_master_requests_niosII_openMac_clock_3_in,
      ap_cpu_data_master_requests_niosII_openMac_clock_4_in => ap_cpu_data_master_requests_niosII_openMac_clock_4_in,
      ap_cpu_data_master_requests_onchip_memory2_0_s1 => ap_cpu_data_master_requests_onchip_memory2_0_s1,
      ap_cpu_data_master_requests_outport_ap_s1 => ap_cpu_data_master_requests_outport_ap_s1,
      ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave => ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave,
      ap_cpu_data_master_requests_sync_irq_from_pcp_s1 => ap_cpu_data_master_requests_sync_irq_from_pcp_s1,
      ap_cpu_data_master_requests_sysid_control_slave => ap_cpu_data_master_requests_sysid_control_slave,
      ap_cpu_data_master_requests_system_timer_ap_s1 => ap_cpu_data_master_requests_system_timer_ap_s1,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      ap_cpu_jtag_debug_module_readdata_from_sa => ap_cpu_jtag_debug_module_readdata_from_sa,
      async_irq_from_pcp_s1_irq_from_sa => async_irq_from_pcp_s1_irq_from_sa,
      async_irq_from_pcp_s1_readdata_from_sa => async_irq_from_pcp_s1_readdata_from_sa,
      benchmark_ap_pio_s1_readdata_from_sa => benchmark_ap_pio_s1_readdata_from_sa,
      clk => internal_clk50,
      d1_ap_cpu_jtag_debug_module_end_xfer => d1_ap_cpu_jtag_debug_module_end_xfer,
      d1_async_irq_from_pcp_s1_end_xfer => d1_async_irq_from_pcp_s1_end_xfer,
      d1_benchmark_ap_pio_s1_end_xfer => d1_benchmark_ap_pio_s1_end_xfer,
      d1_epcs_flash_controller_0_epcs_control_port_end_xfer => d1_epcs_flash_controller_0_epcs_control_port_end_xfer,
      d1_inport_ap_s1_end_xfer => d1_inport_ap_s1_end_xfer,
      d1_jtag_uart_1_avalon_jtag_slave_end_xfer => d1_jtag_uart_1_avalon_jtag_slave_end_xfer,
      d1_niosII_openMac_clock_1_in_end_xfer => d1_niosII_openMac_clock_1_in_end_xfer,
      d1_niosII_openMac_clock_2_in_end_xfer => d1_niosII_openMac_clock_2_in_end_xfer,
      d1_niosII_openMac_clock_3_in_end_xfer => d1_niosII_openMac_clock_3_in_end_xfer,
      d1_niosII_openMac_clock_4_in_end_xfer => d1_niosII_openMac_clock_4_in_end_xfer,
      d1_onchip_memory2_0_s1_end_xfer => d1_onchip_memory2_0_s1_end_xfer,
      d1_outport_ap_s1_end_xfer => d1_outport_ap_s1_end_xfer,
      d1_sync_irq_from_pcp_s1_end_xfer => d1_sync_irq_from_pcp_s1_end_xfer,
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      d1_system_timer_ap_s1_end_xfer => d1_system_timer_ap_s1_end_xfer,
      d1_tri_state_bridge_0_avalon_slave_end_xfer => d1_tri_state_bridge_0_avalon_slave_end_xfer,
      epcs_flash_controller_0_epcs_control_port_readdata_from_sa => epcs_flash_controller_0_epcs_control_port_readdata_from_sa,
      incoming_data_to_and_from_the_par_pdi_master_0 => incoming_data_to_and_from_the_par_pdi_master_0,
      inport_ap_s1_readdata_from_sa => inport_ap_s1_readdata_from_sa,
      jtag_uart_1_avalon_jtag_slave_irq_from_sa => jtag_uart_1_avalon_jtag_slave_irq_from_sa,
      jtag_uart_1_avalon_jtag_slave_readdata_from_sa => jtag_uart_1_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_1_avalon_jtag_slave_waitrequest_from_sa,
      niosII_openMac_clock_1_in_readdata_from_sa => niosII_openMac_clock_1_in_readdata_from_sa,
      niosII_openMac_clock_1_in_waitrequest_from_sa => niosII_openMac_clock_1_in_waitrequest_from_sa,
      niosII_openMac_clock_2_in_readdata_from_sa => niosII_openMac_clock_2_in_readdata_from_sa,
      niosII_openMac_clock_2_in_waitrequest_from_sa => niosII_openMac_clock_2_in_waitrequest_from_sa,
      niosII_openMac_clock_3_in_readdata_from_sa => niosII_openMac_clock_3_in_readdata_from_sa,
      niosII_openMac_clock_3_in_waitrequest_from_sa => niosII_openMac_clock_3_in_waitrequest_from_sa,
      niosII_openMac_clock_4_in_readdata_from_sa => niosII_openMac_clock_4_in_readdata_from_sa,
      niosII_openMac_clock_4_in_waitrequest_from_sa => niosII_openMac_clock_4_in_waitrequest_from_sa,
      onchip_memory2_0_s1_readdata_from_sa => onchip_memory2_0_s1_readdata_from_sa,
      outport_ap_s1_readdata_from_sa => outport_ap_s1_readdata_from_sa,
      par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0 => par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0,
      par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_1 => par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_1,
      registered_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 => registered_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1,
      registered_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave => registered_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave,
      reset_n => clk50_reset_n,
      sync_irq_from_pcp_s1_irq_from_sa => sync_irq_from_pcp_s1_irq_from_sa,
      sync_irq_from_pcp_s1_readdata_from_sa => sync_irq_from_pcp_s1_readdata_from_sa,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      system_timer_ap_s1_irq_from_sa => system_timer_ap_s1_irq_from_sa,
      system_timer_ap_s1_readdata_from_sa => system_timer_ap_s1_readdata_from_sa
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
      ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module => ap_cpu_instruction_master_granted_ap_cpu_jtag_debug_module,
      ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port => ap_cpu_instruction_master_granted_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in => ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in,
      ap_cpu_instruction_master_granted_onchip_memory2_0_s1 => ap_cpu_instruction_master_granted_onchip_memory2_0_s1,
      ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module => ap_cpu_instruction_master_qualified_request_ap_cpu_jtag_debug_module,
      ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port => ap_cpu_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in => ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in,
      ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1 => ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1,
      ap_cpu_instruction_master_read => ap_cpu_instruction_master_read,
      ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module => ap_cpu_instruction_master_read_data_valid_ap_cpu_jtag_debug_module,
      ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port => ap_cpu_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_instruction_master_read_data_valid_niosII_openMac_clock_0_in => ap_cpu_instruction_master_read_data_valid_niosII_openMac_clock_0_in,
      ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1 => ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1,
      ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module => ap_cpu_instruction_master_requests_ap_cpu_jtag_debug_module,
      ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port => ap_cpu_instruction_master_requests_epcs_flash_controller_0_epcs_control_port,
      ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in => ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in,
      ap_cpu_instruction_master_requests_onchip_memory2_0_s1 => ap_cpu_instruction_master_requests_onchip_memory2_0_s1,
      ap_cpu_jtag_debug_module_readdata_from_sa => ap_cpu_jtag_debug_module_readdata_from_sa,
      clk => internal_clk50,
      d1_ap_cpu_jtag_debug_module_end_xfer => d1_ap_cpu_jtag_debug_module_end_xfer,
      d1_epcs_flash_controller_0_epcs_control_port_end_xfer => d1_epcs_flash_controller_0_epcs_control_port_end_xfer,
      d1_niosII_openMac_clock_0_in_end_xfer => d1_niosII_openMac_clock_0_in_end_xfer,
      d1_onchip_memory2_0_s1_end_xfer => d1_onchip_memory2_0_s1_end_xfer,
      epcs_flash_controller_0_epcs_control_port_readdata_from_sa => epcs_flash_controller_0_epcs_control_port_readdata_from_sa,
      niosII_openMac_clock_0_in_readdata_from_sa => niosII_openMac_clock_0_in_readdata_from_sa,
      niosII_openMac_clock_0_in_waitrequest_from_sa => niosII_openMac_clock_0_in_waitrequest_from_sa,
      onchip_memory2_0_s1_readdata_from_sa => onchip_memory2_0_s1_readdata_from_sa,
      reset_n => clk50_reset_n
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
      clk => internal_clk50,
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


  --the_async_irq_from_pcp_s1, which is an e_instance
  the_async_irq_from_pcp_s1 : async_irq_from_pcp_s1_arbitrator
    port map(
      ap_cpu_data_master_granted_async_irq_from_pcp_s1 => ap_cpu_data_master_granted_async_irq_from_pcp_s1,
      ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1 => ap_cpu_data_master_qualified_request_async_irq_from_pcp_s1,
      ap_cpu_data_master_read_data_valid_async_irq_from_pcp_s1 => ap_cpu_data_master_read_data_valid_async_irq_from_pcp_s1,
      ap_cpu_data_master_requests_async_irq_from_pcp_s1 => ap_cpu_data_master_requests_async_irq_from_pcp_s1,
      async_irq_from_pcp_s1_address => async_irq_from_pcp_s1_address,
      async_irq_from_pcp_s1_chipselect => async_irq_from_pcp_s1_chipselect,
      async_irq_from_pcp_s1_irq_from_sa => async_irq_from_pcp_s1_irq_from_sa,
      async_irq_from_pcp_s1_readdata_from_sa => async_irq_from_pcp_s1_readdata_from_sa,
      async_irq_from_pcp_s1_reset_n => async_irq_from_pcp_s1_reset_n,
      async_irq_from_pcp_s1_write_n => async_irq_from_pcp_s1_write_n,
      async_irq_from_pcp_s1_writedata => async_irq_from_pcp_s1_writedata,
      d1_async_irq_from_pcp_s1_end_xfer => d1_async_irq_from_pcp_s1_end_xfer,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      async_irq_from_pcp_s1_irq => async_irq_from_pcp_s1_irq,
      async_irq_from_pcp_s1_readdata => async_irq_from_pcp_s1_readdata,
      clk => internal_clk50,
      reset_n => clk50_reset_n
    );


  --the_async_irq_from_pcp, which is an e_ptf_instance
  the_async_irq_from_pcp : async_irq_from_pcp
    port map(
      irq => async_irq_from_pcp_s1_irq,
      readdata => async_irq_from_pcp_s1_readdata,
      address => async_irq_from_pcp_s1_address,
      chipselect => async_irq_from_pcp_s1_chipselect,
      clk => internal_clk50,
      in_port => in_port_to_the_async_irq_from_pcp,
      reset_n => async_irq_from_pcp_s1_reset_n,
      write_n => async_irq_from_pcp_s1_write_n,
      writedata => async_irq_from_pcp_s1_writedata
    );


  --the_benchmark_ap_pio_s1, which is an e_instance
  the_benchmark_ap_pio_s1 : benchmark_ap_pio_s1_arbitrator
    port map(
      ap_cpu_data_master_granted_benchmark_ap_pio_s1 => ap_cpu_data_master_granted_benchmark_ap_pio_s1,
      ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1 => ap_cpu_data_master_qualified_request_benchmark_ap_pio_s1,
      ap_cpu_data_master_read_data_valid_benchmark_ap_pio_s1 => ap_cpu_data_master_read_data_valid_benchmark_ap_pio_s1,
      ap_cpu_data_master_requests_benchmark_ap_pio_s1 => ap_cpu_data_master_requests_benchmark_ap_pio_s1,
      benchmark_ap_pio_s1_address => benchmark_ap_pio_s1_address,
      benchmark_ap_pio_s1_chipselect => benchmark_ap_pio_s1_chipselect,
      benchmark_ap_pio_s1_readdata_from_sa => benchmark_ap_pio_s1_readdata_from_sa,
      benchmark_ap_pio_s1_reset_n => benchmark_ap_pio_s1_reset_n,
      benchmark_ap_pio_s1_write_n => benchmark_ap_pio_s1_write_n,
      benchmark_ap_pio_s1_writedata => benchmark_ap_pio_s1_writedata,
      d1_benchmark_ap_pio_s1_end_xfer => d1_benchmark_ap_pio_s1_end_xfer,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_byteenable => ap_cpu_data_master_byteenable,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      benchmark_ap_pio_s1_readdata => benchmark_ap_pio_s1_readdata,
      clk => internal_clk50,
      reset_n => clk50_reset_n
    );


  --the_benchmark_ap_pio, which is an e_ptf_instance
  the_benchmark_ap_pio : benchmark_ap_pio
    port map(
      out_port => internal_out_port_from_the_benchmark_ap_pio,
      readdata => benchmark_ap_pio_s1_readdata,
      address => benchmark_ap_pio_s1_address,
      chipselect => benchmark_ap_pio_s1_chipselect,
      clk => internal_clk50,
      reset_n => benchmark_ap_pio_s1_reset_n,
      write_n => benchmark_ap_pio_s1_write_n,
      writedata => benchmark_ap_pio_s1_writedata
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
      clk => internal_clk50,
      epcs_flash_controller_0_epcs_control_port_dataavailable => epcs_flash_controller_0_epcs_control_port_dataavailable,
      epcs_flash_controller_0_epcs_control_port_endofpacket => epcs_flash_controller_0_epcs_control_port_endofpacket,
      epcs_flash_controller_0_epcs_control_port_readdata => epcs_flash_controller_0_epcs_control_port_readdata,
      epcs_flash_controller_0_epcs_control_port_readyfordata => epcs_flash_controller_0_epcs_control_port_readyfordata,
      reset_n => clk50_reset_n
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
      clk => internal_clk50,
      data0 => data0_to_the_epcs_flash_controller_0,
      read_n => epcs_flash_controller_0_epcs_control_port_read_n,
      reset_n => epcs_flash_controller_0_epcs_control_port_reset_n,
      write_n => epcs_flash_controller_0_epcs_control_port_write_n,
      writedata => epcs_flash_controller_0_epcs_control_port_writedata
    );


  --the_inport_ap_s1, which is an e_instance
  the_inport_ap_s1 : inport_ap_s1_arbitrator
    port map(
      ap_cpu_data_master_granted_inport_ap_s1 => ap_cpu_data_master_granted_inport_ap_s1,
      ap_cpu_data_master_qualified_request_inport_ap_s1 => ap_cpu_data_master_qualified_request_inport_ap_s1,
      ap_cpu_data_master_read_data_valid_inport_ap_s1 => ap_cpu_data_master_read_data_valid_inport_ap_s1,
      ap_cpu_data_master_requests_inport_ap_s1 => ap_cpu_data_master_requests_inport_ap_s1,
      d1_inport_ap_s1_end_xfer => d1_inport_ap_s1_end_xfer,
      inport_ap_s1_address => inport_ap_s1_address,
      inport_ap_s1_readdata_from_sa => inport_ap_s1_readdata_from_sa,
      inport_ap_s1_reset_n => inport_ap_s1_reset_n,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      clk => internal_clk50,
      inport_ap_s1_readdata => inport_ap_s1_readdata,
      reset_n => clk50_reset_n
    );


  --the_inport_ap, which is an e_ptf_instance
  the_inport_ap : inport_ap
    port map(
      readdata => inport_ap_s1_readdata,
      address => inport_ap_s1_address,
      clk => internal_clk50,
      in_port => in_port_to_the_inport_ap,
      reset_n => inport_ap_s1_reset_n
    );


  --the_jtag_uart_1_avalon_jtag_slave, which is an e_instance
  the_jtag_uart_1_avalon_jtag_slave : jtag_uart_1_avalon_jtag_slave_arbitrator
    port map(
      ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave => ap_cpu_data_master_granted_jtag_uart_1_avalon_jtag_slave,
      ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave => ap_cpu_data_master_qualified_request_jtag_uart_1_avalon_jtag_slave,
      ap_cpu_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave => ap_cpu_data_master_read_data_valid_jtag_uart_1_avalon_jtag_slave,
      ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave => ap_cpu_data_master_requests_jtag_uart_1_avalon_jtag_slave,
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
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      clk => internal_clk50,
      jtag_uart_1_avalon_jtag_slave_dataavailable => jtag_uart_1_avalon_jtag_slave_dataavailable,
      jtag_uart_1_avalon_jtag_slave_irq => jtag_uart_1_avalon_jtag_slave_irq,
      jtag_uart_1_avalon_jtag_slave_readdata => jtag_uart_1_avalon_jtag_slave_readdata,
      jtag_uart_1_avalon_jtag_slave_readyfordata => jtag_uart_1_avalon_jtag_slave_readyfordata,
      jtag_uart_1_avalon_jtag_slave_waitrequest => jtag_uart_1_avalon_jtag_slave_waitrequest,
      reset_n => clk50_reset_n
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
      clk => internal_clk50,
      rst_n => jtag_uart_1_avalon_jtag_slave_reset_n
    );


  --the_lcd_control_slave, which is an e_instance
  the_lcd_control_slave : lcd_control_slave_arbitrator
    port map(
      d1_lcd_control_slave_end_xfer => d1_lcd_control_slave_end_xfer,
      lcd_control_slave_address => lcd_control_slave_address,
      lcd_control_slave_begintransfer => lcd_control_slave_begintransfer,
      lcd_control_slave_read => lcd_control_slave_read,
      lcd_control_slave_readdata_from_sa => lcd_control_slave_readdata_from_sa,
      lcd_control_slave_wait_counter_eq_0 => lcd_control_slave_wait_counter_eq_0,
      lcd_control_slave_write => lcd_control_slave_write,
      lcd_control_slave_writedata => lcd_control_slave_writedata,
      niosII_openMac_clock_3_out_granted_lcd_control_slave => niosII_openMac_clock_3_out_granted_lcd_control_slave,
      niosII_openMac_clock_3_out_qualified_request_lcd_control_slave => niosII_openMac_clock_3_out_qualified_request_lcd_control_slave,
      niosII_openMac_clock_3_out_read_data_valid_lcd_control_slave => niosII_openMac_clock_3_out_read_data_valid_lcd_control_slave,
      niosII_openMac_clock_3_out_requests_lcd_control_slave => niosII_openMac_clock_3_out_requests_lcd_control_slave,
      clk => internal_clk25,
      lcd_control_slave_readdata => lcd_control_slave_readdata,
      niosII_openMac_clock_3_out_address_to_slave => niosII_openMac_clock_3_out_address_to_slave,
      niosII_openMac_clock_3_out_nativeaddress => niosII_openMac_clock_3_out_nativeaddress,
      niosII_openMac_clock_3_out_read => niosII_openMac_clock_3_out_read,
      niosII_openMac_clock_3_out_write => niosII_openMac_clock_3_out_write,
      niosII_openMac_clock_3_out_writedata => niosII_openMac_clock_3_out_writedata,
      reset_n => clk25_reset_n
    );


  --the_lcd, which is an e_ptf_instance
  the_lcd : lcd
    port map(
      LCD_E => internal_LCD_E_from_the_lcd,
      LCD_RS => internal_LCD_RS_from_the_lcd,
      LCD_RW => internal_LCD_RW_from_the_lcd,
      LCD_data => LCD_data_to_and_from_the_lcd,
      readdata => lcd_control_slave_readdata,
      address => lcd_control_slave_address,
      begintransfer => lcd_control_slave_begintransfer,
      read => lcd_control_slave_read,
      write => lcd_control_slave_write,
      writedata => lcd_control_slave_writedata
    );


  --the_niosII_openMac_clock_0_in, which is an e_instance
  the_niosII_openMac_clock_0_in : niosII_openMac_clock_0_in_arbitrator
    port map(
      ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in => ap_cpu_instruction_master_granted_niosII_openMac_clock_0_in,
      ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in => ap_cpu_instruction_master_qualified_request_niosII_openMac_clock_0_in,
      ap_cpu_instruction_master_read_data_valid_niosII_openMac_clock_0_in => ap_cpu_instruction_master_read_data_valid_niosII_openMac_clock_0_in,
      ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in => ap_cpu_instruction_master_requests_niosII_openMac_clock_0_in,
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
      ap_cpu_instruction_master_address_to_slave => ap_cpu_instruction_master_address_to_slave,
      ap_cpu_instruction_master_latency_counter => ap_cpu_instruction_master_latency_counter,
      ap_cpu_instruction_master_read => ap_cpu_instruction_master_read,
      clk => internal_clk50,
      niosII_openMac_clock_0_in_endofpacket => niosII_openMac_clock_0_in_endofpacket,
      niosII_openMac_clock_0_in_readdata => niosII_openMac_clock_0_in_readdata,
      niosII_openMac_clock_0_in_waitrequest => niosII_openMac_clock_0_in_waitrequest,
      reset_n => clk50_reset_n
    );


  --the_niosII_openMac_clock_0_out, which is an e_instance
  the_niosII_openMac_clock_0_out : niosII_openMac_clock_0_out_arbitrator
    port map(
      niosII_openMac_clock_0_out_address_to_slave => niosII_openMac_clock_0_out_address_to_slave,
      niosII_openMac_clock_0_out_readdata => niosII_openMac_clock_0_out_readdata,
      niosII_openMac_clock_0_out_reset_n => niosII_openMac_clock_0_out_reset_n,
      niosII_openMac_clock_0_out_waitrequest => niosII_openMac_clock_0_out_waitrequest,
      clk => internal_clkAp_SDRAM,
      d1_sdram_0_s1_end_xfer => d1_sdram_0_s1_end_xfer,
      niosII_openMac_clock_0_out_address => niosII_openMac_clock_0_out_address,
      niosII_openMac_clock_0_out_byteenable => niosII_openMac_clock_0_out_byteenable,
      niosII_openMac_clock_0_out_granted_sdram_0_s1 => niosII_openMac_clock_0_out_granted_sdram_0_s1,
      niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 => niosII_openMac_clock_0_out_qualified_request_sdram_0_s1,
      niosII_openMac_clock_0_out_read => niosII_openMac_clock_0_out_read,
      niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1 => niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1,
      niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register => niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register,
      niosII_openMac_clock_0_out_requests_sdram_0_s1 => niosII_openMac_clock_0_out_requests_sdram_0_s1,
      niosII_openMac_clock_0_out_write => niosII_openMac_clock_0_out_write,
      niosII_openMac_clock_0_out_writedata => niosII_openMac_clock_0_out_writedata,
      reset_n => clkAp_SDRAM_reset_n,
      sdram_0_s1_readdata_from_sa => sdram_0_s1_readdata_from_sa,
      sdram_0_s1_waitrequest_from_sa => sdram_0_s1_waitrequest_from_sa
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
      master_clk => internal_clkAp_SDRAM,
      master_endofpacket => niosII_openMac_clock_0_out_endofpacket,
      master_readdata => niosII_openMac_clock_0_out_readdata,
      master_reset_n => niosII_openMac_clock_0_out_reset_n,
      master_waitrequest => niosII_openMac_clock_0_out_waitrequest,
      slave_address => niosII_openMac_clock_0_in_address,
      slave_byteenable => niosII_openMac_clock_0_in_byteenable,
      slave_clk => internal_clk50,
      slave_nativeaddress => niosII_openMac_clock_0_in_nativeaddress,
      slave_read => niosII_openMac_clock_0_in_read,
      slave_reset_n => niosII_openMac_clock_0_in_reset_n,
      slave_write => niosII_openMac_clock_0_in_write,
      slave_writedata => niosII_openMac_clock_0_in_writedata
    );


  --the_niosII_openMac_clock_1_in, which is an e_instance
  the_niosII_openMac_clock_1_in : niosII_openMac_clock_1_in_arbitrator
    port map(
      ap_cpu_data_master_granted_niosII_openMac_clock_1_in => ap_cpu_data_master_granted_niosII_openMac_clock_1_in,
      ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in => ap_cpu_data_master_qualified_request_niosII_openMac_clock_1_in,
      ap_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in => ap_cpu_data_master_read_data_valid_niosII_openMac_clock_1_in,
      ap_cpu_data_master_requests_niosII_openMac_clock_1_in => ap_cpu_data_master_requests_niosII_openMac_clock_1_in,
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
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_byteenable => ap_cpu_data_master_byteenable,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      clk => internal_clk50,
      niosII_openMac_clock_1_in_endofpacket => niosII_openMac_clock_1_in_endofpacket,
      niosII_openMac_clock_1_in_readdata => niosII_openMac_clock_1_in_readdata,
      niosII_openMac_clock_1_in_waitrequest => niosII_openMac_clock_1_in_waitrequest,
      reset_n => clk50_reset_n
    );


  --the_niosII_openMac_clock_1_out, which is an e_instance
  the_niosII_openMac_clock_1_out : niosII_openMac_clock_1_out_arbitrator
    port map(
      niosII_openMac_clock_1_out_address_to_slave => niosII_openMac_clock_1_out_address_to_slave,
      niosII_openMac_clock_1_out_readdata => niosII_openMac_clock_1_out_readdata,
      niosII_openMac_clock_1_out_reset_n => niosII_openMac_clock_1_out_reset_n,
      niosII_openMac_clock_1_out_waitrequest => niosII_openMac_clock_1_out_waitrequest,
      clk => internal_clkAp_SDRAM,
      d1_sdram_0_s1_end_xfer => d1_sdram_0_s1_end_xfer,
      niosII_openMac_clock_1_out_address => niosII_openMac_clock_1_out_address,
      niosII_openMac_clock_1_out_byteenable => niosII_openMac_clock_1_out_byteenable,
      niosII_openMac_clock_1_out_granted_sdram_0_s1 => niosII_openMac_clock_1_out_granted_sdram_0_s1,
      niosII_openMac_clock_1_out_qualified_request_sdram_0_s1 => niosII_openMac_clock_1_out_qualified_request_sdram_0_s1,
      niosII_openMac_clock_1_out_read => niosII_openMac_clock_1_out_read,
      niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1 => niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1,
      niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register => niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register,
      niosII_openMac_clock_1_out_requests_sdram_0_s1 => niosII_openMac_clock_1_out_requests_sdram_0_s1,
      niosII_openMac_clock_1_out_write => niosII_openMac_clock_1_out_write,
      niosII_openMac_clock_1_out_writedata => niosII_openMac_clock_1_out_writedata,
      reset_n => clkAp_SDRAM_reset_n,
      sdram_0_s1_readdata_from_sa => sdram_0_s1_readdata_from_sa,
      sdram_0_s1_waitrequest_from_sa => sdram_0_s1_waitrequest_from_sa
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
      master_clk => internal_clkAp_SDRAM,
      master_endofpacket => niosII_openMac_clock_1_out_endofpacket,
      master_readdata => niosII_openMac_clock_1_out_readdata,
      master_reset_n => niosII_openMac_clock_1_out_reset_n,
      master_waitrequest => niosII_openMac_clock_1_out_waitrequest,
      slave_address => niosII_openMac_clock_1_in_address,
      slave_byteenable => niosII_openMac_clock_1_in_byteenable,
      slave_clk => internal_clk50,
      slave_nativeaddress => niosII_openMac_clock_1_in_nativeaddress,
      slave_read => niosII_openMac_clock_1_in_read,
      slave_reset_n => niosII_openMac_clock_1_in_reset_n,
      slave_write => niosII_openMac_clock_1_in_write,
      slave_writedata => niosII_openMac_clock_1_in_writedata
    );


  --the_niosII_openMac_clock_2_in, which is an e_instance
  the_niosII_openMac_clock_2_in : niosII_openMac_clock_2_in_arbitrator
    port map(
      ap_cpu_data_master_granted_niosII_openMac_clock_2_in => ap_cpu_data_master_granted_niosII_openMac_clock_2_in,
      ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in => ap_cpu_data_master_qualified_request_niosII_openMac_clock_2_in,
      ap_cpu_data_master_read_data_valid_niosII_openMac_clock_2_in => ap_cpu_data_master_read_data_valid_niosII_openMac_clock_2_in,
      ap_cpu_data_master_requests_niosII_openMac_clock_2_in => ap_cpu_data_master_requests_niosII_openMac_clock_2_in,
      d1_niosII_openMac_clock_2_in_end_xfer => d1_niosII_openMac_clock_2_in_end_xfer,
      niosII_openMac_clock_2_in_address => niosII_openMac_clock_2_in_address,
      niosII_openMac_clock_2_in_byteenable => niosII_openMac_clock_2_in_byteenable,
      niosII_openMac_clock_2_in_endofpacket_from_sa => niosII_openMac_clock_2_in_endofpacket_from_sa,
      niosII_openMac_clock_2_in_nativeaddress => niosII_openMac_clock_2_in_nativeaddress,
      niosII_openMac_clock_2_in_read => niosII_openMac_clock_2_in_read,
      niosII_openMac_clock_2_in_readdata_from_sa => niosII_openMac_clock_2_in_readdata_from_sa,
      niosII_openMac_clock_2_in_reset_n => niosII_openMac_clock_2_in_reset_n,
      niosII_openMac_clock_2_in_waitrequest_from_sa => niosII_openMac_clock_2_in_waitrequest_from_sa,
      niosII_openMac_clock_2_in_write => niosII_openMac_clock_2_in_write,
      niosII_openMac_clock_2_in_writedata => niosII_openMac_clock_2_in_writedata,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_byteenable => ap_cpu_data_master_byteenable,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      clk => internal_clk50,
      niosII_openMac_clock_2_in_endofpacket => niosII_openMac_clock_2_in_endofpacket,
      niosII_openMac_clock_2_in_readdata => niosII_openMac_clock_2_in_readdata,
      niosII_openMac_clock_2_in_waitrequest => niosII_openMac_clock_2_in_waitrequest,
      reset_n => clk50_reset_n
    );


  --the_niosII_openMac_clock_2_out, which is an e_instance
  the_niosII_openMac_clock_2_out : niosII_openMac_clock_2_out_arbitrator
    port map(
      niosII_openMac_clock_2_out_address_to_slave => niosII_openMac_clock_2_out_address_to_slave,
      niosII_openMac_clock_2_out_readdata => niosII_openMac_clock_2_out_readdata,
      niosII_openMac_clock_2_out_reset_n => niosII_openMac_clock_2_out_reset_n,
      niosII_openMac_clock_2_out_waitrequest => niosII_openMac_clock_2_out_waitrequest,
      clk => internal_clk25,
      d1_remote_update_cycloneiii_0_s1_end_xfer => d1_remote_update_cycloneiii_0_s1_end_xfer,
      niosII_openMac_clock_2_out_address => niosII_openMac_clock_2_out_address,
      niosII_openMac_clock_2_out_byteenable => niosII_openMac_clock_2_out_byteenable,
      niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_2_out_read => niosII_openMac_clock_2_out_read,
      niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_2_out_write => niosII_openMac_clock_2_out_write,
      niosII_openMac_clock_2_out_writedata => niosII_openMac_clock_2_out_writedata,
      remote_update_cycloneiii_0_s1_readdata_from_sa => remote_update_cycloneiii_0_s1_readdata_from_sa,
      remote_update_cycloneiii_0_s1_waitrequest_from_sa => remote_update_cycloneiii_0_s1_waitrequest_from_sa,
      reset_n => clk25_reset_n
    );


  --the_niosII_openMac_clock_2, which is an e_ptf_instance
  the_niosII_openMac_clock_2 : niosII_openMac_clock_2
    port map(
      master_address => niosII_openMac_clock_2_out_address,
      master_byteenable => niosII_openMac_clock_2_out_byteenable,
      master_nativeaddress => niosII_openMac_clock_2_out_nativeaddress,
      master_read => niosII_openMac_clock_2_out_read,
      master_write => niosII_openMac_clock_2_out_write,
      master_writedata => niosII_openMac_clock_2_out_writedata,
      slave_endofpacket => niosII_openMac_clock_2_in_endofpacket,
      slave_readdata => niosII_openMac_clock_2_in_readdata,
      slave_waitrequest => niosII_openMac_clock_2_in_waitrequest,
      master_clk => internal_clk25,
      master_endofpacket => niosII_openMac_clock_2_out_endofpacket,
      master_readdata => niosII_openMac_clock_2_out_readdata,
      master_reset_n => niosII_openMac_clock_2_out_reset_n,
      master_waitrequest => niosII_openMac_clock_2_out_waitrequest,
      slave_address => niosII_openMac_clock_2_in_address,
      slave_byteenable => niosII_openMac_clock_2_in_byteenable,
      slave_clk => internal_clk50,
      slave_nativeaddress => niosII_openMac_clock_2_in_nativeaddress,
      slave_read => niosII_openMac_clock_2_in_read,
      slave_reset_n => niosII_openMac_clock_2_in_reset_n,
      slave_write => niosII_openMac_clock_2_in_write,
      slave_writedata => niosII_openMac_clock_2_in_writedata
    );


  --the_niosII_openMac_clock_3_in, which is an e_instance
  the_niosII_openMac_clock_3_in : niosII_openMac_clock_3_in_arbitrator
    port map(
      ap_cpu_data_master_granted_niosII_openMac_clock_3_in => ap_cpu_data_master_granted_niosII_openMac_clock_3_in,
      ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in => ap_cpu_data_master_qualified_request_niosII_openMac_clock_3_in,
      ap_cpu_data_master_read_data_valid_niosII_openMac_clock_3_in => ap_cpu_data_master_read_data_valid_niosII_openMac_clock_3_in,
      ap_cpu_data_master_requests_niosII_openMac_clock_3_in => ap_cpu_data_master_requests_niosII_openMac_clock_3_in,
      d1_niosII_openMac_clock_3_in_end_xfer => d1_niosII_openMac_clock_3_in_end_xfer,
      niosII_openMac_clock_3_in_address => niosII_openMac_clock_3_in_address,
      niosII_openMac_clock_3_in_endofpacket_from_sa => niosII_openMac_clock_3_in_endofpacket_from_sa,
      niosII_openMac_clock_3_in_nativeaddress => niosII_openMac_clock_3_in_nativeaddress,
      niosII_openMac_clock_3_in_read => niosII_openMac_clock_3_in_read,
      niosII_openMac_clock_3_in_readdata_from_sa => niosII_openMac_clock_3_in_readdata_from_sa,
      niosII_openMac_clock_3_in_reset_n => niosII_openMac_clock_3_in_reset_n,
      niosII_openMac_clock_3_in_waitrequest_from_sa => niosII_openMac_clock_3_in_waitrequest_from_sa,
      niosII_openMac_clock_3_in_write => niosII_openMac_clock_3_in_write,
      niosII_openMac_clock_3_in_writedata => niosII_openMac_clock_3_in_writedata,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_byteenable => ap_cpu_data_master_byteenable,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      clk => internal_clk50,
      niosII_openMac_clock_3_in_endofpacket => niosII_openMac_clock_3_in_endofpacket,
      niosII_openMac_clock_3_in_readdata => niosII_openMac_clock_3_in_readdata,
      niosII_openMac_clock_3_in_waitrequest => niosII_openMac_clock_3_in_waitrequest,
      reset_n => clk50_reset_n
    );


  --the_niosII_openMac_clock_3_out, which is an e_instance
  the_niosII_openMac_clock_3_out : niosII_openMac_clock_3_out_arbitrator
    port map(
      niosII_openMac_clock_3_out_address_to_slave => niosII_openMac_clock_3_out_address_to_slave,
      niosII_openMac_clock_3_out_readdata => niosII_openMac_clock_3_out_readdata,
      niosII_openMac_clock_3_out_reset_n => niosII_openMac_clock_3_out_reset_n,
      niosII_openMac_clock_3_out_waitrequest => niosII_openMac_clock_3_out_waitrequest,
      clk => internal_clk25,
      d1_lcd_control_slave_end_xfer => d1_lcd_control_slave_end_xfer,
      lcd_control_slave_readdata_from_sa => lcd_control_slave_readdata_from_sa,
      lcd_control_slave_wait_counter_eq_0 => lcd_control_slave_wait_counter_eq_0,
      niosII_openMac_clock_3_out_address => niosII_openMac_clock_3_out_address,
      niosII_openMac_clock_3_out_granted_lcd_control_slave => niosII_openMac_clock_3_out_granted_lcd_control_slave,
      niosII_openMac_clock_3_out_qualified_request_lcd_control_slave => niosII_openMac_clock_3_out_qualified_request_lcd_control_slave,
      niosII_openMac_clock_3_out_read => niosII_openMac_clock_3_out_read,
      niosII_openMac_clock_3_out_read_data_valid_lcd_control_slave => niosII_openMac_clock_3_out_read_data_valid_lcd_control_slave,
      niosII_openMac_clock_3_out_requests_lcd_control_slave => niosII_openMac_clock_3_out_requests_lcd_control_slave,
      niosII_openMac_clock_3_out_write => niosII_openMac_clock_3_out_write,
      niosII_openMac_clock_3_out_writedata => niosII_openMac_clock_3_out_writedata,
      reset_n => clk25_reset_n
    );


  --the_niosII_openMac_clock_3, which is an e_ptf_instance
  the_niosII_openMac_clock_3 : niosII_openMac_clock_3
    port map(
      master_address => niosII_openMac_clock_3_out_address,
      master_nativeaddress => niosII_openMac_clock_3_out_nativeaddress,
      master_read => niosII_openMac_clock_3_out_read,
      master_write => niosII_openMac_clock_3_out_write,
      master_writedata => niosII_openMac_clock_3_out_writedata,
      slave_endofpacket => niosII_openMac_clock_3_in_endofpacket,
      slave_readdata => niosII_openMac_clock_3_in_readdata,
      slave_waitrequest => niosII_openMac_clock_3_in_waitrequest,
      master_clk => internal_clk25,
      master_endofpacket => niosII_openMac_clock_3_out_endofpacket,
      master_readdata => niosII_openMac_clock_3_out_readdata,
      master_reset_n => niosII_openMac_clock_3_out_reset_n,
      master_waitrequest => niosII_openMac_clock_3_out_waitrequest,
      slave_address => niosII_openMac_clock_3_in_address,
      slave_clk => internal_clk50,
      slave_nativeaddress => niosII_openMac_clock_3_in_nativeaddress,
      slave_read => niosII_openMac_clock_3_in_read,
      slave_reset_n => niosII_openMac_clock_3_in_reset_n,
      slave_write => niosII_openMac_clock_3_in_write,
      slave_writedata => niosII_openMac_clock_3_in_writedata
    );


  --the_niosII_openMac_clock_4_in, which is an e_instance
  the_niosII_openMac_clock_4_in : niosII_openMac_clock_4_in_arbitrator
    port map(
      ap_cpu_data_master_granted_niosII_openMac_clock_4_in => ap_cpu_data_master_granted_niosII_openMac_clock_4_in,
      ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in => ap_cpu_data_master_qualified_request_niosII_openMac_clock_4_in,
      ap_cpu_data_master_read_data_valid_niosII_openMac_clock_4_in => ap_cpu_data_master_read_data_valid_niosII_openMac_clock_4_in,
      ap_cpu_data_master_requests_niosII_openMac_clock_4_in => ap_cpu_data_master_requests_niosII_openMac_clock_4_in,
      d1_niosII_openMac_clock_4_in_end_xfer => d1_niosII_openMac_clock_4_in_end_xfer,
      niosII_openMac_clock_4_in_address => niosII_openMac_clock_4_in_address,
      niosII_openMac_clock_4_in_byteenable => niosII_openMac_clock_4_in_byteenable,
      niosII_openMac_clock_4_in_endofpacket_from_sa => niosII_openMac_clock_4_in_endofpacket_from_sa,
      niosII_openMac_clock_4_in_nativeaddress => niosII_openMac_clock_4_in_nativeaddress,
      niosII_openMac_clock_4_in_read => niosII_openMac_clock_4_in_read,
      niosII_openMac_clock_4_in_readdata_from_sa => niosII_openMac_clock_4_in_readdata_from_sa,
      niosII_openMac_clock_4_in_reset_n => niosII_openMac_clock_4_in_reset_n,
      niosII_openMac_clock_4_in_waitrequest_from_sa => niosII_openMac_clock_4_in_waitrequest_from_sa,
      niosII_openMac_clock_4_in_write => niosII_openMac_clock_4_in_write,
      niosII_openMac_clock_4_in_writedata => niosII_openMac_clock_4_in_writedata,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_byteenable => ap_cpu_data_master_byteenable,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      clk => internal_clk50,
      niosII_openMac_clock_4_in_endofpacket => niosII_openMac_clock_4_in_endofpacket,
      niosII_openMac_clock_4_in_readdata => niosII_openMac_clock_4_in_readdata,
      niosII_openMac_clock_4_in_waitrequest => niosII_openMac_clock_4_in_waitrequest,
      reset_n => clk50_reset_n
    );


  --the_niosII_openMac_clock_4_out, which is an e_instance
  the_niosII_openMac_clock_4_out : niosII_openMac_clock_4_out_arbitrator
    port map(
      niosII_openMac_clock_4_out_address_to_slave => niosII_openMac_clock_4_out_address_to_slave,
      niosII_openMac_clock_4_out_readdata => niosII_openMac_clock_4_out_readdata,
      niosII_openMac_clock_4_out_reset_n => niosII_openMac_clock_4_out_reset_n,
      niosII_openMac_clock_4_out_waitrequest => niosII_openMac_clock_4_out_waitrequest,
      altpll_0_pll_slave_readdata_from_sa => altpll_0_pll_slave_readdata_from_sa,
      clk => clk_0,
      d1_altpll_0_pll_slave_end_xfer => d1_altpll_0_pll_slave_end_xfer,
      niosII_openMac_clock_4_out_address => niosII_openMac_clock_4_out_address,
      niosII_openMac_clock_4_out_byteenable => niosII_openMac_clock_4_out_byteenable,
      niosII_openMac_clock_4_out_granted_altpll_0_pll_slave => niosII_openMac_clock_4_out_granted_altpll_0_pll_slave,
      niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave => niosII_openMac_clock_4_out_qualified_request_altpll_0_pll_slave,
      niosII_openMac_clock_4_out_read => niosII_openMac_clock_4_out_read,
      niosII_openMac_clock_4_out_read_data_valid_altpll_0_pll_slave => niosII_openMac_clock_4_out_read_data_valid_altpll_0_pll_slave,
      niosII_openMac_clock_4_out_requests_altpll_0_pll_slave => niosII_openMac_clock_4_out_requests_altpll_0_pll_slave,
      niosII_openMac_clock_4_out_write => niosII_openMac_clock_4_out_write,
      niosII_openMac_clock_4_out_writedata => niosII_openMac_clock_4_out_writedata,
      reset_n => clk_0_reset_n
    );


  --the_niosII_openMac_clock_4, which is an e_ptf_instance
  the_niosII_openMac_clock_4 : niosII_openMac_clock_4
    port map(
      master_address => niosII_openMac_clock_4_out_address,
      master_byteenable => niosII_openMac_clock_4_out_byteenable,
      master_nativeaddress => niosII_openMac_clock_4_out_nativeaddress,
      master_read => niosII_openMac_clock_4_out_read,
      master_write => niosII_openMac_clock_4_out_write,
      master_writedata => niosII_openMac_clock_4_out_writedata,
      slave_endofpacket => niosII_openMac_clock_4_in_endofpacket,
      slave_readdata => niosII_openMac_clock_4_in_readdata,
      slave_waitrequest => niosII_openMac_clock_4_in_waitrequest,
      master_clk => clk_0,
      master_endofpacket => niosII_openMac_clock_4_out_endofpacket,
      master_readdata => niosII_openMac_clock_4_out_readdata,
      master_reset_n => niosII_openMac_clock_4_out_reset_n,
      master_waitrequest => niosII_openMac_clock_4_out_waitrequest,
      slave_address => niosII_openMac_clock_4_in_address,
      slave_byteenable => niosII_openMac_clock_4_in_byteenable,
      slave_clk => internal_clk50,
      slave_nativeaddress => niosII_openMac_clock_4_in_nativeaddress,
      slave_read => niosII_openMac_clock_4_in_read,
      slave_reset_n => niosII_openMac_clock_4_in_reset_n,
      slave_write => niosII_openMac_clock_4_in_write,
      slave_writedata => niosII_openMac_clock_4_in_writedata
    );


  --the_onchip_memory2_0_s1, which is an e_instance
  the_onchip_memory2_0_s1 : onchip_memory2_0_s1_arbitrator
    port map(
      ap_cpu_data_master_granted_onchip_memory2_0_s1 => ap_cpu_data_master_granted_onchip_memory2_0_s1,
      ap_cpu_data_master_qualified_request_onchip_memory2_0_s1 => ap_cpu_data_master_qualified_request_onchip_memory2_0_s1,
      ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 => ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1,
      ap_cpu_data_master_requests_onchip_memory2_0_s1 => ap_cpu_data_master_requests_onchip_memory2_0_s1,
      ap_cpu_instruction_master_granted_onchip_memory2_0_s1 => ap_cpu_instruction_master_granted_onchip_memory2_0_s1,
      ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1 => ap_cpu_instruction_master_qualified_request_onchip_memory2_0_s1,
      ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1 => ap_cpu_instruction_master_read_data_valid_onchip_memory2_0_s1,
      ap_cpu_instruction_master_requests_onchip_memory2_0_s1 => ap_cpu_instruction_master_requests_onchip_memory2_0_s1,
      d1_onchip_memory2_0_s1_end_xfer => d1_onchip_memory2_0_s1_end_xfer,
      onchip_memory2_0_s1_address => onchip_memory2_0_s1_address,
      onchip_memory2_0_s1_byteenable => onchip_memory2_0_s1_byteenable,
      onchip_memory2_0_s1_chipselect => onchip_memory2_0_s1_chipselect,
      onchip_memory2_0_s1_clken => onchip_memory2_0_s1_clken,
      onchip_memory2_0_s1_readdata_from_sa => onchip_memory2_0_s1_readdata_from_sa,
      onchip_memory2_0_s1_reset => onchip_memory2_0_s1_reset,
      onchip_memory2_0_s1_write => onchip_memory2_0_s1_write,
      onchip_memory2_0_s1_writedata => onchip_memory2_0_s1_writedata,
      registered_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1 => registered_ap_cpu_data_master_read_data_valid_onchip_memory2_0_s1,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_byteenable => ap_cpu_data_master_byteenable,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      ap_cpu_instruction_master_address_to_slave => ap_cpu_instruction_master_address_to_slave,
      ap_cpu_instruction_master_latency_counter => ap_cpu_instruction_master_latency_counter,
      ap_cpu_instruction_master_read => ap_cpu_instruction_master_read,
      clk => internal_clk50,
      onchip_memory2_0_s1_readdata => onchip_memory2_0_s1_readdata,
      reset_n => clk50_reset_n
    );


  --the_onchip_memory2_0, which is an e_ptf_instance
  the_onchip_memory2_0 : onchip_memory2_0
    port map(
      readdata => onchip_memory2_0_s1_readdata,
      address => onchip_memory2_0_s1_address,
      byteenable => onchip_memory2_0_s1_byteenable,
      chipselect => onchip_memory2_0_s1_chipselect,
      clk => internal_clk50,
      clken => onchip_memory2_0_s1_clken,
      reset => onchip_memory2_0_s1_reset,
      write => onchip_memory2_0_s1_write,
      writedata => onchip_memory2_0_s1_writedata
    );


  --the_outport_ap_s1, which is an e_instance
  the_outport_ap_s1 : outport_ap_s1_arbitrator
    port map(
      ap_cpu_data_master_granted_outport_ap_s1 => ap_cpu_data_master_granted_outport_ap_s1,
      ap_cpu_data_master_qualified_request_outport_ap_s1 => ap_cpu_data_master_qualified_request_outport_ap_s1,
      ap_cpu_data_master_read_data_valid_outport_ap_s1 => ap_cpu_data_master_read_data_valid_outport_ap_s1,
      ap_cpu_data_master_requests_outport_ap_s1 => ap_cpu_data_master_requests_outport_ap_s1,
      d1_outport_ap_s1_end_xfer => d1_outport_ap_s1_end_xfer,
      outport_ap_s1_address => outport_ap_s1_address,
      outport_ap_s1_chipselect => outport_ap_s1_chipselect,
      outport_ap_s1_readdata_from_sa => outport_ap_s1_readdata_from_sa,
      outport_ap_s1_reset_n => outport_ap_s1_reset_n,
      outport_ap_s1_write_n => outport_ap_s1_write_n,
      outport_ap_s1_writedata => outport_ap_s1_writedata,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      clk => internal_clk50,
      outport_ap_s1_readdata => outport_ap_s1_readdata,
      reset_n => clk50_reset_n
    );


  --the_outport_ap, which is an e_ptf_instance
  the_outport_ap : outport_ap
    port map(
      out_port => internal_out_port_from_the_outport_ap,
      readdata => outport_ap_s1_readdata,
      address => outport_ap_s1_address,
      chipselect => outport_ap_s1_chipselect,
      clk => internal_clk50,
      reset_n => outport_ap_s1_reset_n,
      write_n => outport_ap_s1_write_n,
      writedata => outport_ap_s1_writedata
    );


  --the_remote_update_cycloneiii_0_s1, which is an e_instance
  the_remote_update_cycloneiii_0_s1 : remote_update_cycloneiii_0_s1_arbitrator
    port map(
      d1_remote_update_cycloneiii_0_s1_end_xfer => d1_remote_update_cycloneiii_0_s1_end_xfer,
      niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_2_out_granted_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_2_out_qualified_request_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_2_out_read_data_valid_remote_update_cycloneiii_0_s1,
      niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1 => niosII_openMac_clock_2_out_requests_remote_update_cycloneiii_0_s1,
      remote_update_cycloneiii_0_s1_address => remote_update_cycloneiii_0_s1_address,
      remote_update_cycloneiii_0_s1_chipselect => remote_update_cycloneiii_0_s1_chipselect,
      remote_update_cycloneiii_0_s1_read => remote_update_cycloneiii_0_s1_read,
      remote_update_cycloneiii_0_s1_readdata_from_sa => remote_update_cycloneiii_0_s1_readdata_from_sa,
      remote_update_cycloneiii_0_s1_reset => remote_update_cycloneiii_0_s1_reset,
      remote_update_cycloneiii_0_s1_waitrequest_from_sa => remote_update_cycloneiii_0_s1_waitrequest_from_sa,
      remote_update_cycloneiii_0_s1_write => remote_update_cycloneiii_0_s1_write,
      remote_update_cycloneiii_0_s1_writedata => remote_update_cycloneiii_0_s1_writedata,
      clk => internal_clk25,
      niosII_openMac_clock_2_out_address_to_slave => niosII_openMac_clock_2_out_address_to_slave,
      niosII_openMac_clock_2_out_nativeaddress => niosII_openMac_clock_2_out_nativeaddress,
      niosII_openMac_clock_2_out_read => niosII_openMac_clock_2_out_read,
      niosII_openMac_clock_2_out_write => niosII_openMac_clock_2_out_write,
      niosII_openMac_clock_2_out_writedata => niosII_openMac_clock_2_out_writedata,
      remote_update_cycloneiii_0_s1_readdata => remote_update_cycloneiii_0_s1_readdata,
      remote_update_cycloneiii_0_s1_waitrequest => remote_update_cycloneiii_0_s1_waitrequest,
      reset_n => clk25_reset_n
    );


  --the_remote_update_cycloneiii_0, which is an e_ptf_instance
  the_remote_update_cycloneiii_0 : remote_update_cycloneiii_0
    port map(
      readdata => remote_update_cycloneiii_0_s1_readdata,
      waitrequest => remote_update_cycloneiii_0_s1_waitrequest,
      address => remote_update_cycloneiii_0_s1_address,
      chipselect => remote_update_cycloneiii_0_s1_chipselect,
      clk => internal_clk25,
      read => remote_update_cycloneiii_0_s1_read,
      reset => remote_update_cycloneiii_0_s1_reset,
      write => remote_update_cycloneiii_0_s1_write,
      writedata => remote_update_cycloneiii_0_s1_writedata
    );


  --the_sdram_0_s1, which is an e_instance
  the_sdram_0_s1 : sdram_0_s1_arbitrator
    port map(
      d1_sdram_0_s1_end_xfer => d1_sdram_0_s1_end_xfer,
      niosII_openMac_clock_0_out_granted_sdram_0_s1 => niosII_openMac_clock_0_out_granted_sdram_0_s1,
      niosII_openMac_clock_0_out_qualified_request_sdram_0_s1 => niosII_openMac_clock_0_out_qualified_request_sdram_0_s1,
      niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1 => niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1,
      niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register => niosII_openMac_clock_0_out_read_data_valid_sdram_0_s1_shift_register,
      niosII_openMac_clock_0_out_requests_sdram_0_s1 => niosII_openMac_clock_0_out_requests_sdram_0_s1,
      niosII_openMac_clock_1_out_granted_sdram_0_s1 => niosII_openMac_clock_1_out_granted_sdram_0_s1,
      niosII_openMac_clock_1_out_qualified_request_sdram_0_s1 => niosII_openMac_clock_1_out_qualified_request_sdram_0_s1,
      niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1 => niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1,
      niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register => niosII_openMac_clock_1_out_read_data_valid_sdram_0_s1_shift_register,
      niosII_openMac_clock_1_out_requests_sdram_0_s1 => niosII_openMac_clock_1_out_requests_sdram_0_s1,
      sdram_0_s1_address => sdram_0_s1_address,
      sdram_0_s1_byteenable_n => sdram_0_s1_byteenable_n,
      sdram_0_s1_chipselect => sdram_0_s1_chipselect,
      sdram_0_s1_read_n => sdram_0_s1_read_n,
      sdram_0_s1_readdata_from_sa => sdram_0_s1_readdata_from_sa,
      sdram_0_s1_reset_n => sdram_0_s1_reset_n,
      sdram_0_s1_waitrequest_from_sa => sdram_0_s1_waitrequest_from_sa,
      sdram_0_s1_write_n => sdram_0_s1_write_n,
      sdram_0_s1_writedata => sdram_0_s1_writedata,
      clk => internal_clkAp_SDRAM,
      niosII_openMac_clock_0_out_address_to_slave => niosII_openMac_clock_0_out_address_to_slave,
      niosII_openMac_clock_0_out_byteenable => niosII_openMac_clock_0_out_byteenable,
      niosII_openMac_clock_0_out_read => niosII_openMac_clock_0_out_read,
      niosII_openMac_clock_0_out_write => niosII_openMac_clock_0_out_write,
      niosII_openMac_clock_0_out_writedata => niosII_openMac_clock_0_out_writedata,
      niosII_openMac_clock_1_out_address_to_slave => niosII_openMac_clock_1_out_address_to_slave,
      niosII_openMac_clock_1_out_byteenable => niosII_openMac_clock_1_out_byteenable,
      niosII_openMac_clock_1_out_read => niosII_openMac_clock_1_out_read,
      niosII_openMac_clock_1_out_write => niosII_openMac_clock_1_out_write,
      niosII_openMac_clock_1_out_writedata => niosII_openMac_clock_1_out_writedata,
      reset_n => clkAp_SDRAM_reset_n,
      sdram_0_s1_readdata => sdram_0_s1_readdata,
      sdram_0_s1_readdatavalid => sdram_0_s1_readdatavalid,
      sdram_0_s1_waitrequest => sdram_0_s1_waitrequest
    );


  --the_sdram_0, which is an e_ptf_instance
  the_sdram_0 : sdram_0
    port map(
      za_data => sdram_0_s1_readdata,
      za_valid => sdram_0_s1_readdatavalid,
      za_waitrequest => sdram_0_s1_waitrequest,
      zs_addr => internal_zs_addr_from_the_sdram_0,
      zs_ba => internal_zs_ba_from_the_sdram_0,
      zs_cas_n => internal_zs_cas_n_from_the_sdram_0,
      zs_cke => internal_zs_cke_from_the_sdram_0,
      zs_cs_n => internal_zs_cs_n_from_the_sdram_0,
      zs_dq => zs_dq_to_and_from_the_sdram_0,
      zs_dqm => internal_zs_dqm_from_the_sdram_0,
      zs_ras_n => internal_zs_ras_n_from_the_sdram_0,
      zs_we_n => internal_zs_we_n_from_the_sdram_0,
      az_addr => sdram_0_s1_address,
      az_be_n => sdram_0_s1_byteenable_n,
      az_cs => sdram_0_s1_chipselect,
      az_data => sdram_0_s1_writedata,
      az_rd_n => sdram_0_s1_read_n,
      az_wr_n => sdram_0_s1_write_n,
      clk => internal_clkAp_SDRAM,
      reset_n => sdram_0_s1_reset_n
    );


  --the_sync_irq_from_pcp_s1, which is an e_instance
  the_sync_irq_from_pcp_s1 : sync_irq_from_pcp_s1_arbitrator
    port map(
      ap_cpu_data_master_granted_sync_irq_from_pcp_s1 => ap_cpu_data_master_granted_sync_irq_from_pcp_s1,
      ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1 => ap_cpu_data_master_qualified_request_sync_irq_from_pcp_s1,
      ap_cpu_data_master_read_data_valid_sync_irq_from_pcp_s1 => ap_cpu_data_master_read_data_valid_sync_irq_from_pcp_s1,
      ap_cpu_data_master_requests_sync_irq_from_pcp_s1 => ap_cpu_data_master_requests_sync_irq_from_pcp_s1,
      d1_sync_irq_from_pcp_s1_end_xfer => d1_sync_irq_from_pcp_s1_end_xfer,
      sync_irq_from_pcp_s1_address => sync_irq_from_pcp_s1_address,
      sync_irq_from_pcp_s1_chipselect => sync_irq_from_pcp_s1_chipselect,
      sync_irq_from_pcp_s1_irq_from_sa => sync_irq_from_pcp_s1_irq_from_sa,
      sync_irq_from_pcp_s1_readdata_from_sa => sync_irq_from_pcp_s1_readdata_from_sa,
      sync_irq_from_pcp_s1_reset_n => sync_irq_from_pcp_s1_reset_n,
      sync_irq_from_pcp_s1_write_n => sync_irq_from_pcp_s1_write_n,
      sync_irq_from_pcp_s1_writedata => sync_irq_from_pcp_s1_writedata,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      clk => internal_clk50,
      reset_n => clk50_reset_n,
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
      clk => internal_clk50,
      in_port => in_port_to_the_sync_irq_from_pcp,
      reset_n => sync_irq_from_pcp_s1_reset_n,
      write_n => sync_irq_from_pcp_s1_write_n,
      writedata => sync_irq_from_pcp_s1_writedata
    );


  --the_sysid_control_slave, which is an e_instance
  the_sysid_control_slave : sysid_control_slave_arbitrator
    port map(
      ap_cpu_data_master_granted_sysid_control_slave => ap_cpu_data_master_granted_sysid_control_slave,
      ap_cpu_data_master_qualified_request_sysid_control_slave => ap_cpu_data_master_qualified_request_sysid_control_slave,
      ap_cpu_data_master_read_data_valid_sysid_control_slave => ap_cpu_data_master_read_data_valid_sysid_control_slave,
      ap_cpu_data_master_requests_sysid_control_slave => ap_cpu_data_master_requests_sysid_control_slave,
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      sysid_control_slave_address => sysid_control_slave_address,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      sysid_control_slave_reset_n => sysid_control_slave_reset_n,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      clk => internal_clk50,
      reset_n => clk50_reset_n,
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
      ap_cpu_data_master_granted_system_timer_ap_s1 => ap_cpu_data_master_granted_system_timer_ap_s1,
      ap_cpu_data_master_qualified_request_system_timer_ap_s1 => ap_cpu_data_master_qualified_request_system_timer_ap_s1,
      ap_cpu_data_master_read_data_valid_system_timer_ap_s1 => ap_cpu_data_master_read_data_valid_system_timer_ap_s1,
      ap_cpu_data_master_requests_system_timer_ap_s1 => ap_cpu_data_master_requests_system_timer_ap_s1,
      d1_system_timer_ap_s1_end_xfer => d1_system_timer_ap_s1_end_xfer,
      system_timer_ap_s1_address => system_timer_ap_s1_address,
      system_timer_ap_s1_chipselect => system_timer_ap_s1_chipselect,
      system_timer_ap_s1_irq_from_sa => system_timer_ap_s1_irq_from_sa,
      system_timer_ap_s1_readdata_from_sa => system_timer_ap_s1_readdata_from_sa,
      system_timer_ap_s1_reset_n => system_timer_ap_s1_reset_n,
      system_timer_ap_s1_write_n => system_timer_ap_s1_write_n,
      system_timer_ap_s1_writedata => system_timer_ap_s1_writedata,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_waitrequest => ap_cpu_data_master_waitrequest,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      ap_cpu_data_master_writedata => ap_cpu_data_master_writedata,
      clk => internal_clk50,
      reset_n => clk50_reset_n,
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
      clk => internal_clk50,
      reset_n => system_timer_ap_s1_reset_n,
      write_n => system_timer_ap_s1_write_n,
      writedata => system_timer_ap_s1_writedata
    );


  --the_tri_state_bridge_0_avalon_slave, which is an e_instance
  the_tri_state_bridge_0_avalon_slave : tri_state_bridge_0_avalon_slave_arbitrator
    port map(
      addr_to_the_par_pdi_master_0 => internal_addr_to_the_par_pdi_master_0,
      ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave => ap_cpu_data_master_byteenable_par_pdi_master_0_avalon_tristate_slave,
      ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave => ap_cpu_data_master_granted_par_pdi_master_0_avalon_tristate_slave,
      ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave => ap_cpu_data_master_qualified_request_par_pdi_master_0_avalon_tristate_slave,
      ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave => ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave,
      ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave => ap_cpu_data_master_requests_par_pdi_master_0_avalon_tristate_slave,
      ben_to_the_par_pdi_master_0 => internal_ben_to_the_par_pdi_master_0,
      csn_to_the_par_pdi_master_0 => internal_csn_to_the_par_pdi_master_0,
      d1_tri_state_bridge_0_avalon_slave_end_xfer => d1_tri_state_bridge_0_avalon_slave_end_xfer,
      data_to_and_from_the_par_pdi_master_0 => data_to_and_from_the_par_pdi_master_0,
      incoming_data_to_and_from_the_par_pdi_master_0 => incoming_data_to_and_from_the_par_pdi_master_0,
      par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0 => par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_0,
      par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_1 => par_pdi_master_0_avalon_tristate_slave_wait_counter_eq_1,
      rdn_to_the_par_pdi_master_0 => internal_rdn_to_the_par_pdi_master_0,
      registered_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave => registered_ap_cpu_data_master_read_data_valid_par_pdi_master_0_avalon_tristate_slave,
      wrn_to_the_par_pdi_master_0 => internal_wrn_to_the_par_pdi_master_0,
      ap_cpu_data_master_address_to_slave => ap_cpu_data_master_address_to_slave,
      ap_cpu_data_master_byteenable => ap_cpu_data_master_byteenable,
      ap_cpu_data_master_dbs_address => ap_cpu_data_master_dbs_address,
      ap_cpu_data_master_dbs_write_16 => ap_cpu_data_master_dbs_write_16,
      ap_cpu_data_master_no_byte_enables_and_last_term => ap_cpu_data_master_no_byte_enables_and_last_term,
      ap_cpu_data_master_read => ap_cpu_data_master_read,
      ap_cpu_data_master_write => ap_cpu_data_master_write,
      clk => internal_clk50,
      reset_n => clk50_reset_n
    );


  --reset is asserted asynchronously and deasserted synchronously
  niosII_openMac_reset_clk_0_domain_synch : niosII_openMac_reset_clk_0_domain_synch_module
    port map(
      data_out => clk_0_reset_n,
      clk => clk_0,
      data_in => module_input6,
      reset_n => reset_n_sources
    );

  module_input6 <= std_logic'('1');

  --reset sources mux, which is an e_mux
  reset_n_sources <= Vector_To_Std_Logic(NOT ((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT reset_n))) OR std_logic_vector'("00000000000000000000000000000000")) OR std_logic_vector'("00000000000000000000000000000000")) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_jtag_debug_module_resetrequest_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ap_cpu_jtag_debug_module_resetrequest_from_sa)))) OR std_logic_vector'("00000000000000000000000000000000")) OR std_logic_vector'("00000000000000000000000000000000"))));
  --reset is asserted asynchronously and deasserted synchronously
  niosII_openMac_reset_clk50_domain_synch : niosII_openMac_reset_clk50_domain_synch_module
    port map(
      data_out => clk50_reset_n,
      clk => internal_clk50,
      data_in => module_input7,
      reset_n => reset_n_sources
    );

  module_input7 <= std_logic'('1');

  --reset is asserted asynchronously and deasserted synchronously
  niosII_openMac_reset_clk25_domain_synch : niosII_openMac_reset_clk25_domain_synch_module
    port map(
      data_out => clk25_reset_n,
      clk => internal_clk25,
      data_in => module_input8,
      reset_n => reset_n_sources
    );

  module_input8 <= std_logic'('1');

  --reset is asserted asynchronously and deasserted synchronously
  niosII_openMac_reset_clkAp_SDRAM_domain_synch : niosII_openMac_reset_clkAp_SDRAM_domain_synch_module
    port map(
      data_out => clkAp_SDRAM_reset_n,
      clk => internal_clkAp_SDRAM,
      data_in => module_input9,
      reset_n => reset_n_sources
    );

  module_input9 <= std_logic'('1');

  --niosII_openMac_clock_0_in_writedata of type writedata does not connect to anything so wire it to default (0)
  niosII_openMac_clock_0_in_writedata <= std_logic_vector'("00000000000000000000000000000000");
  --niosII_openMac_clock_0_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  niosII_openMac_clock_0_out_endofpacket <= std_logic'('0');
  --niosII_openMac_clock_1_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  niosII_openMac_clock_1_out_endofpacket <= std_logic'('0');
  --niosII_openMac_clock_2_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  niosII_openMac_clock_2_out_endofpacket <= std_logic'('0');
  --niosII_openMac_clock_3_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  niosII_openMac_clock_3_out_endofpacket <= std_logic'('0');
  --niosII_openMac_clock_4_out_endofpacket of type endofpacket does not connect to anything so wire it to default (0)
  niosII_openMac_clock_4_out_endofpacket <= std_logic'('0');
  --sysid_control_slave_clock of type clock does not connect to anything so wire it to default (0)
  sysid_control_slave_clock <= std_logic'('0');
  --vhdl renameroo for output signals
  LCD_E_from_the_lcd <= internal_LCD_E_from_the_lcd;
  --vhdl renameroo for output signals
  LCD_RS_from_the_lcd <= internal_LCD_RS_from_the_lcd;
  --vhdl renameroo for output signals
  LCD_RW_from_the_lcd <= internal_LCD_RW_from_the_lcd;
  --vhdl renameroo for output signals
  addr_to_the_par_pdi_master_0 <= internal_addr_to_the_par_pdi_master_0;
  --vhdl renameroo for output signals
  ben_to_the_par_pdi_master_0 <= internal_ben_to_the_par_pdi_master_0;
  --vhdl renameroo for output signals
  clk25 <= internal_clk25;
  --vhdl renameroo for output signals
  clk50 <= internal_clk50;
  --vhdl renameroo for output signals
  clkAp_SDRAM <= internal_clkAp_SDRAM;
  --vhdl renameroo for output signals
  csn_to_the_par_pdi_master_0 <= internal_csn_to_the_par_pdi_master_0;
  --vhdl renameroo for output signals
  dclk_from_the_epcs_flash_controller_0 <= internal_dclk_from_the_epcs_flash_controller_0;
  --vhdl renameroo for output signals
  locked_from_the_altpll_0 <= internal_locked_from_the_altpll_0;
  --vhdl renameroo for output signals
  out_port_from_the_benchmark_ap_pio <= internal_out_port_from_the_benchmark_ap_pio;
  --vhdl renameroo for output signals
  out_port_from_the_outport_ap <= internal_out_port_from_the_outport_ap;
  --vhdl renameroo for output signals
  phasedone_from_the_altpll_0 <= internal_phasedone_from_the_altpll_0;
  --vhdl renameroo for output signals
  rdn_to_the_par_pdi_master_0 <= internal_rdn_to_the_par_pdi_master_0;
  --vhdl renameroo for output signals
  sce_from_the_epcs_flash_controller_0 <= internal_sce_from_the_epcs_flash_controller_0;
  --vhdl renameroo for output signals
  sdo_from_the_epcs_flash_controller_0 <= internal_sdo_from_the_epcs_flash_controller_0;
  --vhdl renameroo for output signals
  wrn_to_the_par_pdi_master_0 <= internal_wrn_to_the_par_pdi_master_0;
  --vhdl renameroo for output signals
  zs_addr_from_the_sdram_0 <= internal_zs_addr_from_the_sdram_0;
  --vhdl renameroo for output signals
  zs_ba_from_the_sdram_0 <= internal_zs_ba_from_the_sdram_0;
  --vhdl renameroo for output signals
  zs_cas_n_from_the_sdram_0 <= internal_zs_cas_n_from_the_sdram_0;
  --vhdl renameroo for output signals
  zs_cke_from_the_sdram_0 <= internal_zs_cke_from_the_sdram_0;
  --vhdl renameroo for output signals
  zs_cs_n_from_the_sdram_0 <= internal_zs_cs_n_from_the_sdram_0;
  --vhdl renameroo for output signals
  zs_dqm_from_the_sdram_0 <= internal_zs_dqm_from_the_sdram_0;
  --vhdl renameroo for output signals
  zs_ras_n_from_the_sdram_0 <= internal_zs_ras_n_from_the_sdram_0;
  --vhdl renameroo for output signals
  zs_we_n_from_the_sdram_0 <= internal_zs_we_n_from_the_sdram_0;

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
                    signal clk100 : OUT STD_LOGIC;
                    signal clk25 : OUT STD_LOGIC;
                    signal clk50 : OUT STD_LOGIC;
                    signal clkAp_SDRAM : OUT STD_LOGIC;
                    signal clk_0 : IN STD_LOGIC;
                    signal clkpcp : OUT STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- the_altpll_0
                    signal locked_from_the_altpll_0 : OUT STD_LOGIC;
                    signal phasedone_from_the_altpll_0 : OUT STD_LOGIC;

                 -- the_async_irq_from_pcp
                    signal in_port_to_the_async_irq_from_pcp : IN STD_LOGIC;

                 -- the_benchmark_ap_pio
                    signal out_port_from_the_benchmark_ap_pio : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_epcs_flash_controller_0
                    signal data0_to_the_epcs_flash_controller_0 : IN STD_LOGIC;
                    signal dclk_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;
                    signal sce_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;
                    signal sdo_from_the_epcs_flash_controller_0 : OUT STD_LOGIC;

                 -- the_inport_ap
                    signal in_port_to_the_inport_ap : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_lcd
                    signal LCD_E_from_the_lcd : OUT STD_LOGIC;
                    signal LCD_RS_from_the_lcd : OUT STD_LOGIC;
                    signal LCD_RW_from_the_lcd : OUT STD_LOGIC;
                    signal LCD_data_to_and_from_the_lcd : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_outport_ap
                    signal out_port_from_the_outport_ap : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);

                 -- the_sdram_0
                    signal zs_addr_from_the_sdram_0 : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal zs_ba_from_the_sdram_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal zs_cas_n_from_the_sdram_0 : OUT STD_LOGIC;
                    signal zs_cke_from_the_sdram_0 : OUT STD_LOGIC;
                    signal zs_cs_n_from_the_sdram_0 : OUT STD_LOGIC;
                    signal zs_dq_to_and_from_the_sdram_0 : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal zs_dqm_from_the_sdram_0 : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal zs_ras_n_from_the_sdram_0 : OUT STD_LOGIC;
                    signal zs_we_n_from_the_sdram_0 : OUT STD_LOGIC;

                 -- the_sync_irq_from_pcp
                    signal in_port_to_the_sync_irq_from_pcp : IN STD_LOGIC;

                 -- the_tri_state_bridge_0_avalon_slave
                    signal addr_to_the_par_pdi_master_0 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal ben_to_the_par_pdi_master_0 : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal csn_to_the_par_pdi_master_0 : OUT STD_LOGIC;
                    signal data_to_and_from_the_par_pdi_master_0 : INOUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal rdn_to_the_par_pdi_master_0 : OUT STD_LOGIC;
                    signal wrn_to_the_par_pdi_master_0 : OUT STD_LOGIC
                 );
end component niosII_openMac;

component sdram_0_test_component is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal zs_addr : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
                    signal zs_ba : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal zs_cas_n : IN STD_LOGIC;
                    signal zs_cke : IN STD_LOGIC;
                    signal zs_cs_n : IN STD_LOGIC;
                    signal zs_dqm : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal zs_ras_n : IN STD_LOGIC;
                    signal zs_we_n : IN STD_LOGIC;

                 -- outputs:
                    signal zs_dq : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component sdram_0_test_component;

                signal LCD_E_from_the_lcd :  STD_LOGIC;
                signal LCD_RS_from_the_lcd :  STD_LOGIC;
                signal LCD_RW_from_the_lcd :  STD_LOGIC;
                signal LCD_data_to_and_from_the_lcd :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal addr_to_the_par_pdi_master_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal ben_to_the_par_pdi_master_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal clk :  STD_LOGIC;
                signal clk100 :  STD_LOGIC;
                signal clk25 :  STD_LOGIC;
                signal clk50 :  STD_LOGIC;
                signal clkAp_SDRAM :  STD_LOGIC;
                signal clk_0 :  STD_LOGIC;
                signal clkpcp :  STD_LOGIC;
                signal csn_to_the_par_pdi_master_0 :  STD_LOGIC;
                signal data0_to_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal data_to_and_from_the_par_pdi_master_0 :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal dclk_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_irq :  STD_LOGIC;
                signal epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa :  STD_LOGIC;
                signal in_port_to_the_async_irq_from_pcp :  STD_LOGIC;
                signal in_port_to_the_inport_ap :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal in_port_to_the_sync_irq_from_pcp :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_1_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal locked_from_the_altpll_0 :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_0_in_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal niosII_openMac_clock_0_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_0_out_nativeaddress :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal niosII_openMac_clock_1_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_1_out_nativeaddress :  STD_LOGIC_VECTOR (24 DOWNTO 0);
                signal niosII_openMac_clock_2_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_2_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_3_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_3_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_4_in_endofpacket_from_sa :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_endofpacket :  STD_LOGIC;
                signal niosII_openMac_clock_4_out_nativeaddress :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal out_port_from_the_benchmark_ap_pio :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal out_port_from_the_outport_ap :  STD_LOGIC_VECTOR (23 DOWNTO 0);
                signal phasedone_from_the_altpll_0 :  STD_LOGIC;
                signal rdn_to_the_par_pdi_master_0 :  STD_LOGIC;
                signal reset_n :  STD_LOGIC;
                signal sce_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal sdo_from_the_epcs_flash_controller_0 :  STD_LOGIC;
                signal sysid_control_slave_clock :  STD_LOGIC;
                signal wrn_to_the_par_pdi_master_0 :  STD_LOGIC;
                signal zs_addr_from_the_sdram_0 :  STD_LOGIC_VECTOR (12 DOWNTO 0);
                signal zs_ba_from_the_sdram_0 :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal zs_cas_n_from_the_sdram_0 :  STD_LOGIC;
                signal zs_cke_from_the_sdram_0 :  STD_LOGIC;
                signal zs_cs_n_from_the_sdram_0 :  STD_LOGIC;
                signal zs_dq_to_and_from_the_sdram_0 :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal zs_dqm_from_the_sdram_0 :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal zs_ras_n_from_the_sdram_0 :  STD_LOGIC;
                signal zs_we_n_from_the_sdram_0 :  STD_LOGIC;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your component and signal declaration here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


begin

  --Set us up the Dut
  DUT : niosII_openMac
    port map(
      LCD_E_from_the_lcd => LCD_E_from_the_lcd,
      LCD_RS_from_the_lcd => LCD_RS_from_the_lcd,
      LCD_RW_from_the_lcd => LCD_RW_from_the_lcd,
      LCD_data_to_and_from_the_lcd => LCD_data_to_and_from_the_lcd,
      addr_to_the_par_pdi_master_0 => addr_to_the_par_pdi_master_0,
      ben_to_the_par_pdi_master_0 => ben_to_the_par_pdi_master_0,
      clk100 => clk100,
      clk25 => clk25,
      clk50 => clk50,
      clkAp_SDRAM => clkAp_SDRAM,
      clkpcp => clkpcp,
      csn_to_the_par_pdi_master_0 => csn_to_the_par_pdi_master_0,
      data_to_and_from_the_par_pdi_master_0 => data_to_and_from_the_par_pdi_master_0,
      dclk_from_the_epcs_flash_controller_0 => dclk_from_the_epcs_flash_controller_0,
      locked_from_the_altpll_0 => locked_from_the_altpll_0,
      out_port_from_the_benchmark_ap_pio => out_port_from_the_benchmark_ap_pio,
      out_port_from_the_outport_ap => out_port_from_the_outport_ap,
      phasedone_from_the_altpll_0 => phasedone_from_the_altpll_0,
      rdn_to_the_par_pdi_master_0 => rdn_to_the_par_pdi_master_0,
      sce_from_the_epcs_flash_controller_0 => sce_from_the_epcs_flash_controller_0,
      sdo_from_the_epcs_flash_controller_0 => sdo_from_the_epcs_flash_controller_0,
      wrn_to_the_par_pdi_master_0 => wrn_to_the_par_pdi_master_0,
      zs_addr_from_the_sdram_0 => zs_addr_from_the_sdram_0,
      zs_ba_from_the_sdram_0 => zs_ba_from_the_sdram_0,
      zs_cas_n_from_the_sdram_0 => zs_cas_n_from_the_sdram_0,
      zs_cke_from_the_sdram_0 => zs_cke_from_the_sdram_0,
      zs_cs_n_from_the_sdram_0 => zs_cs_n_from_the_sdram_0,
      zs_dq_to_and_from_the_sdram_0 => zs_dq_to_and_from_the_sdram_0,
      zs_dqm_from_the_sdram_0 => zs_dqm_from_the_sdram_0,
      zs_ras_n_from_the_sdram_0 => zs_ras_n_from_the_sdram_0,
      zs_we_n_from_the_sdram_0 => zs_we_n_from_the_sdram_0,
      clk_0 => clk_0,
      data0_to_the_epcs_flash_controller_0 => data0_to_the_epcs_flash_controller_0,
      in_port_to_the_async_irq_from_pcp => in_port_to_the_async_irq_from_pcp,
      in_port_to_the_inport_ap => in_port_to_the_inport_ap,
      in_port_to_the_sync_irq_from_pcp => in_port_to_the_sync_irq_from_pcp,
      reset_n => reset_n
    );


  --the_sdram_0_test_component, which is an e_instance
  the_sdram_0_test_component : sdram_0_test_component
    port map(
      zs_dq => zs_dq_to_and_from_the_sdram_0,
      clk => clkAp_SDRAM,
      zs_addr => zs_addr_from_the_sdram_0,
      zs_ba => zs_ba_from_the_sdram_0,
      zs_cas_n => zs_cas_n_from_the_sdram_0,
      zs_cke => zs_cke_from_the_sdram_0,
      zs_cs_n => zs_cs_n_from_the_sdram_0,
      zs_dqm => zs_dqm_from_the_sdram_0,
      zs_ras_n => zs_ras_n_from_the_sdram_0,
      zs_we_n => zs_we_n_from_the_sdram_0
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
