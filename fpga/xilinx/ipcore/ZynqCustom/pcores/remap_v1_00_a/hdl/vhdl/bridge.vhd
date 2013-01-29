------------------------------------------------------------------------------
-- bridge.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
-- Filename:          bridge.vhd
-- Version:           1.00.a
-- Description:       Top level design, instantiates library components and user logic.
-- Date:              Mon Mar 05 2012 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------

entity bridge is
  generic
  (

    ----------------------------
    -- AXI4 Master
    ----------------------------
    C_M_AXI_ADDR_WIDTH             : integer              := 32;
    C_M_AXI_DATA_WIDTH             : integer              := 32;
    C_M_AXI_ARUSER_WIDTH           : integer range 5 to 5 := 5;
    C_M_AXI_AWUSER_WIDTH           : integer range 5 to 5 := 5;


    ----------------------------
    -- AXI4 Slave
    ----------------------------
    C_S_AXI_DATA_WIDTH             : integer              := 32;
    C_S_AXI_ADDR_WIDTH             : integer              := 32;
    C_S_AXI_ID_WIDTH               : integer              := 4

  );
  port
  (

	AddrMSB_val                    : in  std_logic_vector(3 downto 0);
	arUser_val                     : in  std_logic_vector(4 downto 0);
	awUser_val                     : in  std_logic_vector(4 downto 0);

    ----------------------------
    -- AXI4 Master
    ----------------------------


    m_axi_aclk                     : in  std_logic;
    m_axi_aresetn                  : in  std_logic;
    md_error                       : out std_logic;
    m_axi_arready                  : in  std_logic;
    m_axi_arvalid                  : out std_logic;
    m_axi_araddr                   : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    m_axi_aruser                   : out std_logic_vector(4 downto 0)   ;
    m_axi_arlen                    : out std_logic_vector(7 downto 0);
    m_axi_arsize                   : out std_logic_vector(2 downto 0);
    m_axi_arburst                  : out std_logic_vector(1 downto 0);
    m_axi_arprot                   : out std_logic_vector(2 downto 0);
    m_axi_arcache                  : out std_logic_vector(3 downto 0);
    m_axi_rready                   : out std_logic;
    m_axi_rvalid                   : in  std_logic;
    m_axi_rdata                    : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    m_axi_rresp                    : in  std_logic_vector(1 downto 0);
    m_axi_rlast                    : in  std_logic;
    m_axi_awready                  : in  std_logic;
    m_axi_awvalid                  : out std_logic;
    m_axi_awaddr                   : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
    m_axi_awuser                   : out std_logic_vector(4 downto 0)   ;
    m_axi_awlen                    : out std_logic_vector(7 downto 0);
    m_axi_awsize                   : out std_logic_vector(2 downto 0);
    m_axi_awburst                  : out std_logic_vector(1 downto 0);
    m_axi_awprot                   : out std_logic_vector(2 downto 0);
    m_axi_awcache                  : out std_logic_vector(3 downto 0);
    m_axi_wready                   : in  std_logic;
    m_axi_wvalid                   : out std_logic;
    m_axi_wdata                    : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
    m_axi_wstrb                    : out std_logic_vector((C_M_AXI_DATA_WIDTH)/8 - 1 downto 0);
    m_axi_wlast                    : out std_logic;
    m_axi_bready                   : out std_logic;
    m_axi_bvalid                   : in  std_logic;
    m_axi_bresp                    : in  std_logic_vector(1 downto 0);


    ----------------------------
    -- AXI Slave burst
    ----------------------------
    S_AXI_ACLK                     : in  std_logic;
    S_AXI_ARESETN                  : in  std_logic;
    S_AXI_AWADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_AWVALID                  : in  std_logic;
    S_AXI_WDATA                    : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_WSTRB                    : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_WVALID                   : in  std_logic;
    S_AXI_BREADY                   : in  std_logic;
    S_AXI_ARADDR                   : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_ARVALID                  : in  std_logic;
    S_AXI_RREADY                   : in  std_logic;
    S_AXI_ARREADY                  : out std_logic;
    S_AXI_RDATA                    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_RRESP                    : out std_logic_vector(1 downto 0);
    S_AXI_RVALID                   : out std_logic;
    S_AXI_WREADY                   : out std_logic;
    S_AXI_BRESP                    : out std_logic_vector(1 downto 0);
    S_AXI_BVALID                   : out std_logic;
    S_AXI_AWREADY                  : out std_logic;
    S_AXI_AWID                     : in  std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
    S_AXI_AWLEN                    : in  std_logic_vector(7 downto 0);
    S_AXI_AWSIZE                   : in  std_logic_vector(2 downto 0);
    S_AXI_AWBURST                  : in  std_logic_vector(1 downto 0);
    S_AXI_AWLOCK                   : in  std_logic;
    S_AXI_AWCACHE                  : in  std_logic_vector(3 downto 0);
    S_AXI_AWPROT                   : in  std_logic_vector(2 downto 0);
    S_AXI_WLAST                    : in  std_logic;
    S_AXI_BID                      : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
    S_AXI_ARID                     : in  std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
    S_AXI_ARLEN                    : in  std_logic_vector(7 downto 0);
    S_AXI_ARSIZE                   : in  std_logic_vector(2 downto 0);
    S_AXI_ARBURST                  : in  std_logic_vector(1 downto 0);
    S_AXI_ARLOCK                   : in  std_logic;
    S_AXI_ARCACHE                  : in  std_logic_vector(3 downto 0);
    S_AXI_ARPROT                   : in  std_logic_vector(2 downto 0);
    S_AXI_RID                      : out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
    S_AXI_RLAST                    : out std_logic
  );

end entity bridge;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of bridge is

  -------------------------------------------------------------------------------
  -- Constant Declarations
  -------------------------------------------------------------------------------

  ------------------------------------------
  -- signal declarations
  ------------------------------------------
  signal araddr : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal awaddr : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal ridInIndex : integer;
  signal ridOutIndex : integer;
  signal widInIndex : integer;
  signal widOutIndex : integer;

  subtype id_type is std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
  type id_array is array(0 to 7) of id_type;
  signal rid_array : id_array;
  signal wid_array : id_array;
  signal rdBurst_array : std_logic_vector(0 to 7);
  
  signal S_AXI_ARREADY_i : std_logic;
  signal S_AXI_RVALID_i  : std_logic;
  signal S_AXI_AWREADY_i : std_logic;
  signal S_AXI_BVALID_i  : std_logic;
  signal S_AXI_RLAST_i   : std_logic;
  signal rdBurst         : std_logic;


begin

    araddr <= AddrMSB_val & S_AXI_ARADDR(27 downto 0);
    awaddr <= AddrMSB_val & S_AXI_AWADDR(27 downto 0);
    
    m_axi_aruser <= arUser_val;
    m_axi_awuser <= awUser_val;

    S_AXI_ARREADY <= S_AXI_ARREADY_i;
    S_AXI_RVALID  <= S_AXI_RVALID_i ;
    S_AXI_AWREADY <= S_AXI_AWREADY_i;
    S_AXI_BVALID  <= S_AXI_BVALID_i ;
    S_AXI_RLAST   <= S_AXI_RLAST_i  ;
    
    S_AXI_RID <= rid_array(ridOutIndex);
    S_AXI_BID <= wid_array(widOutIndex);

    rdBurst <= '0' when S_AXI_ARLEN = x"00" else
               '1';
               
   id_index_manager : process (m_axi_aclk) is
   begin
    if m_axi_aclk'event and m_axi_aclk = '1' then
      if m_axi_aresetn = '0' then               -- Synchronous reset (active low)
        ridInIndex  <= 0;
        ridOutIndex <= 0;
        widInIndex  <= 0;
        widOutIndex <= 0;
      else
        
        if(S_AXI_ARVALID='1' and S_AXI_ARREADY_i='1') then
          rid_array(ridInIndex) <= S_AXI_ARID;
          rdBurst_array(ridInIndex) <= rdBurst;
          ridInIndex <= ridInIndex + 1;
        end if;

        if(S_AXI_RVALID_i='1' and S_AXI_RREADY='1' and ((rdBurst_array(ridOutIndex)='0') or (rdBurst_array(ridOutIndex)='1' and S_AXI_RLAST_i='1'))) then
          ridOutIndex <= ridOutIndex + 1;
        end if;


        if(S_AXI_AWVALID='1' and S_AXI_AWREADY_i='1') then
          wid_array(widInIndex) <= S_AXI_AWID;
          widInIndex <= widInIndex + 1;
        end if;

        if(S_AXI_BVALID_i='1' and S_AXI_BREADY='1') then
          widOutIndex <= widOutIndex + 1;
        end if;

      end if;
    end if;
   end process id_index_manager;



  -------------------------------------------------------------------------------
  -- Master output connections
  -------------------------------------------------------------------------------
    md_error       <= '0'           ;
    m_axi_arvalid  <= S_AXI_ARVALID ;
    m_axi_araddr   <= araddr        ;
    m_axi_arlen    <= S_AXI_ARLEN   ;
    m_axi_arsize   <= S_AXI_ARSIZE  ;
    m_axi_arburst  <= S_AXI_ARBURST ;
    m_axi_arprot   <= S_AXI_ARPROT  ;
    m_axi_arcache  <= S_AXI_ARCACHE ;
    m_axi_rready   <= S_AXI_RREADY  ;
    m_axi_awvalid  <= S_AXI_AWVALID ;
    m_axi_awaddr   <= awaddr        ;
    m_axi_awlen    <= S_AXI_AWLEN   ;
    m_axi_awsize   <= S_AXI_AWSIZE  ;
    m_axi_awburst  <= S_AXI_AWBURST ;
    m_axi_awprot   <= S_AXI_AWPROT  ;
    m_axi_awcache  <= S_AXI_AWCACHE ;
    m_axi_wvalid   <= S_AXI_WVALID  ;
    m_axi_wdata    <= S_AXI_WDATA   ;
    m_axi_wstrb    <= S_AXI_WSTRB   ;
    m_axi_wlast    <= S_AXI_WLAST   ;
    m_axi_bready   <= S_AXI_BREADY  ;


    -- S_AXI_ACLK                     : in  std_logic;
    -- S_AXI_ARESETN                  : in  std_logic;
    
    -- S_AXI_AWLOCK                   : in  std_logic;
    -- S_AXI_ARLOCK                   : in  std_logic;
    
    

  -------------------------------------------------------------------------------
  -- Slave output connections
  -------------------------------------------------------------------------------
    S_AXI_ARREADY_i <= m_axi_arready ;
    S_AXI_RDATA   <= m_axi_rdata   ;
    S_AXI_RRESP   <= m_axi_rresp   ;
    S_AXI_RVALID_i  <= m_axi_rvalid  ;
    S_AXI_WREADY  <= m_axi_wready  ;
    S_AXI_BRESP   <= m_axi_bresp   ;
    S_AXI_BVALID_i  <= m_axi_bvalid  ;
    S_AXI_AWREADY_i <= m_axi_awready ;
    S_AXI_RLAST_i   <= m_axi_rlast   ;


    -- m_axi_aclk                     : in  std_logic;
    -- m_axi_aresetn                  : in  std_logic;
    

end IMP;
