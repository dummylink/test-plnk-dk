------------------------------------------------------------------------------
-- remap.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
------------------------------------------------------------------------------
-- Filename:          remap.vhd
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library proc_common_v3_00_a;
use proc_common_v3_00_a.proc_common_pkg.all;
use proc_common_v3_00_a.ipif_pkg.all;

library axi_lite_ipif_v1_01_a;
use axi_lite_ipif_v1_01_a.axi_lite_ipif;

--library axi_master_burst_v1_00_a;
--use axi_master_burst_v1_00_a.axi_master_burst;
--
--library axi_slave_burst_v1_00_a;
--use axi_slave_burst_v1_00_a.axi_slave_burst;

library remap_v1_00_a;
use remap_v1_00_a.all;

------------------------------------------------------------------------------
-- Entity section
------------------------------------------------------------------------------

entity remap is
  generic
  (
    C_FAMILY                       : string               := "virtex6";
    C_ADDR_REMAP_DEFAULT           : std_logic_vector     := X"3";

    ----------------------------
    -- AXI4 Master
    ----------------------------
    C_M_AXI_ADDR_WIDTH             : integer              := 32;
    C_M_AXI_DATA_WIDTH             : integer              := 32;
    C_M_AXI_ARUSER_WIDTH           : integer range 5 to 5 := 5;
    C_M_AXI_AWUSER_WIDTH           : integer range 5 to 5 := 5;
    C_MAX_BURST_LEN                : integer              := 16;
    C_NATIVE_DATA_WIDTH            : integer              := 32;
    C_LENGTH_WIDTH                 : integer              := 12;
    C_ADDR_PIPE_DEPTH              : integer              := 1;


    ----------------------------
    -- AXI4 Slave
    ----------------------------
    C_S_AXI_DATA_WIDTH             : integer              := 32;
    C_S_AXI_ADDR_WIDTH             : integer              := 32;
    C_S_AXI_ID_WIDTH               : integer              := 4;
    C_RDATA_FIFO_DEPTH             : integer              := 0;
    C_INCLUDE_TIMEOUT_CNT          : integer              := 1;
    C_TIMEOUT_CNTR_VAL             : integer              := 8;
    C_ALIGN_BE_RDADDR              : integer              := 0;
    C_S_AXI_SUPPORTS_WRITE         : integer              := 1;
    C_S_AXI_SUPPORTS_READ          : integer              := 1;
    C_S_AXI_BRIDGE_BASEADDR          : std_logic_vector     := X"FFFFFFFF";
    C_S_AXI_BRIDGE_HIGHADDR          : std_logic_vector     := X"00000000";

    ----------------------------
    -- AXI-Lite
    ----------------------------
    C_S_AXILITE_DATA_WIDTH         : integer range 32 to 32 := 32;
    C_S_AXILITE_ADDR_WIDTH         : integer range 32 to 32 := 32;
    C_S_AXILITE_MIN_SIZE           : std_logic_vector       := X"000001FF";
    C_USE_WSTRB                    : integer                := 0;
    C_DPHASE_TIMEOUT               : integer                := 8;
    C_BASEADDR                     : std_logic_vector       := X"FFFFFFFF";
    C_HIGHADDR                     : std_logic_vector       := X"00000000";
    
    ----------------------------
    -- Debug
    ----------------------------
    C_DBGWIDTH                     : integer   := 1
    
  );
  port
  (
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
    S_AXI_RLAST                    : out std_logic;

    ----------------------------
    -- AXI-Lite
    ----------------------------
    S_AXILITE_ACLK                     : in  std_logic;
    S_AXILITE_ARESETN                  : in  std_logic;
    S_AXILITE_AWADDR                   : in  std_logic_vector(C_S_AXILITE_ADDR_WIDTH-1 downto 0);
    S_AXILITE_AWVALID                  : in  std_logic;
    S_AXILITE_WDATA                    : in  std_logic_vector(C_S_AXILITE_DATA_WIDTH-1 downto 0);
    S_AXILITE_WSTRB                    : in  std_logic_vector((C_S_AXILITE_DATA_WIDTH/8)-1 downto 0);
    S_AXILITE_WVALID                   : in  std_logic;
    S_AXILITE_BREADY                   : in  std_logic;
    S_AXILITE_ARADDR                   : in  std_logic_vector(C_S_AXILITE_ADDR_WIDTH-1 downto 0);
    S_AXILITE_ARVALID                  : in  std_logic;
    S_AXILITE_RREADY                   : in  std_logic;
    S_AXILITE_ARREADY                  : out std_logic;
    S_AXILITE_RDATA                    : out std_logic_vector(C_S_AXILITE_DATA_WIDTH-1 downto 0);
    S_AXILITE_RRESP                    : out std_logic_vector(1 downto 0);
    S_AXILITE_RVALID                   : out std_logic;
    S_AXILITE_WREADY                   : out std_logic;
    S_AXILITE_BRESP                    : out std_logic_vector(1 downto 0);
    S_AXILITE_BVALID                   : out std_logic;
    S_AXILITE_AWREADY                  : out std_logic;

  	----------------------------
    -- Error signals
    ----------------------------
    DEBUG             : out std_logic_vector(C_DBGWIDTH-1 downto 0)
  );

  attribute MAX_FANOUT : string;
  attribute MAX_FANOUT of S_AXI_ACLK        : signal is "10000";
  attribute MAX_FANOUT of M_AXI_ACLK        : signal is "10000";
  attribute MAX_FANOUT of S_AXILITE_ACLK    : signal is "10000";
  attribute MAX_FANOUT of S_AXILITE_ARESETN : signal is "10000";
  attribute MAX_FANOUT of S_AXI_ARESETN     : signal is "10000";
  attribute MAX_FANOUT of M_AXI_ARESETN     : signal is "10000";
  attribute SIGIS : string;
  attribute SIGIS of S_AXI_ACLK             : signal is "Clk";
  attribute SIGIS of M_AXI_ACLK             : signal is "Clk";
  attribute SIGIS of S_AXILITE_ACLK         : signal is "Clk";
  attribute SIGIS of S_AXILITE_ARESETN      : signal is "Rst";
  attribute SIGIS of S_AXI_ARESETN          : signal is "Rst";
  attribute SIGIS of M_AXI_ARESETN          : signal is "Rst";
end entity remap;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of remap is

  -------------------------------------------------------------------------------
  -- Constant Declarations
  -------------------------------------------------------------------------------

  constant ZERO_ADDR_PAD                  : std_logic_vector(0 to 31) := (others => '0');
  constant USER_SLV_BASEADDR              : std_logic_vector     := C_BASEADDR;
  constant USER_SLV_HIGHADDR              : std_logic_vector     := C_HIGHADDR;

  constant IPIF_ARD_ADDR_RANGE_ARRAY      : SLV64_ARRAY_TYPE     := 
    (
      ZERO_ADDR_PAD & USER_SLV_BASEADDR,  -- user logic slave space base address
      ZERO_ADDR_PAD & USER_SLV_HIGHADDR   -- user logic slave space high address
    );

  constant USER_NUM_REG                   : integer              := 4;

  constant IPIF_ARD_NUM_CE_ARRAY          : INTEGER_ARRAY_TYPE   := 
    (
      0  => USER_NUM_REG              -- number of ce for user logic slave space
    );

  ------------------------------------------
  -- Index for CS/CE
  ------------------------------------------
  constant USER_SLV_CS_INDEX    : integer              := 0;
  constant USER_SLV_CE_INDEX    : integer              := calc_start_ce_index(IPIF_ARD_NUM_CE_ARRAY, USER_SLV_CS_INDEX);

  constant USER_CE_INDEX        : integer              := USER_SLV_CE_INDEX;

  ------------------------------------------
  -- IP Interconnect (IPIC) signal declarations
  ------------------------------------------
  signal ipif_Bus2IP_Clk        : std_logic;
  signal ipif_Bus2IP_Resetn     : std_logic;
  signal ipif_Bus2IP_Addr       : std_logic_vector(C_S_AXILITE_ADDR_WIDTH-1 downto 0);
  signal ipif_Bus2IP_RNW        : std_logic;
  signal ipif_Bus2IP_BE         : std_logic_vector(C_S_AXILITE_DATA_WIDTH/8-1 downto 0);
  signal ipif_Bus2IP_CS         : std_logic_vector((IPIF_ARD_ADDR_RANGE_ARRAY'LENGTH)/2-1 downto 0);
  signal ipif_Bus2IP_RdCE       : std_logic_vector(calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1 downto 0);
  signal ipif_Bus2IP_WrCE       : std_logic_vector(calc_num_ce(IPIF_ARD_NUM_CE_ARRAY)-1 downto 0);
  signal ipif_Bus2IP_Data       : std_logic_vector(C_S_AXILITE_DATA_WIDTH-1 downto 0);
  signal ipif_IP2Bus_WrAck      : std_logic;
  signal ipif_IP2Bus_RdAck      : std_logic;
  signal ipif_IP2Bus_Error      : std_logic;
  signal ipif_IP2Bus_Data       : std_logic_vector(C_S_AXILITE_DATA_WIDTH-1 downto 0);

  ------------------------------------------
  -- Other signal declarations
  ------------------------------------------

  signal arUser_val             : std_logic_vector(4 downto 0);
  signal awUser_val             : std_logic_vector(4 downto 0);
  signal AddrMSB_val            : std_logic_vector(3 downto 0);
  
  signal S_AXILITE_ARESETN_i    : std_logic;


  signal dbg_sigs               : std_logic_vector(C_DBGWIDTH-1 downto 0);
begin

  S_AXILITE_ARESETN_i <= S_AXILITE_ARESETN and M_AXI_ARESETN and S_AXI_ARESETN;


  BRIDGE_I : entity remap_v1_00_a.bridge
  generic map
  (
    C_M_AXI_ADDR_WIDTH => C_M_AXI_ADDR_WIDTH,
    C_M_AXI_DATA_WIDTH => C_M_AXI_DATA_WIDTH,
    C_M_AXI_AWUSER_WIDTH => C_M_AXI_AWUSER_WIDTH,
    C_M_AXI_ARUSER_WIDTH => C_M_AXI_ARUSER_WIDTH,
    C_S_AXI_DATA_WIDTH => C_S_AXI_DATA_WIDTH,
    C_S_AXI_ADDR_WIDTH => C_S_AXI_ADDR_WIDTH,
    C_S_AXI_ID_WIDTH   => C_S_AXI_ID_WIDTH
  )
  port map
  (
    AddrMSB_val      => AddrMSB_val   ,
    arUser_val       => arUser_val    ,
    awUser_val       => awUser_val    ,
    
    -- AXI4 Master
    m_axi_aclk       => m_axi_aclk    ,
    m_axi_aresetn    => m_axi_aresetn ,
    md_error         => md_error      ,
    m_axi_arready    => m_axi_arready ,
    m_axi_arvalid    => m_axi_arvalid ,
    m_axi_araddr     => m_axi_araddr  ,
    m_axi_aruser     => m_axi_aruser  ,
    m_axi_arlen      => m_axi_arlen   ,
    m_axi_arsize     => m_axi_arsize  ,
    m_axi_arburst    => m_axi_arburst ,
    m_axi_arprot     => m_axi_arprot  ,
    m_axi_arcache    => m_axi_arcache ,
    m_axi_rready     => m_axi_rready  ,
    m_axi_rvalid     => m_axi_rvalid  ,
    m_axi_rdata      => m_axi_rdata   ,
    m_axi_rresp      => m_axi_rresp   ,
    m_axi_rlast      => m_axi_rlast   ,
    m_axi_awready    => m_axi_awready ,
    m_axi_awvalid    => m_axi_awvalid ,
    m_axi_awaddr     => m_axi_awaddr  ,
    m_axi_awuser     => m_axi_awuser  ,
    m_axi_awlen      => m_axi_awlen   ,
    m_axi_awsize     => m_axi_awsize  ,
    m_axi_awburst    => m_axi_awburst ,
    m_axi_awprot     => m_axi_awprot  ,
    m_axi_awcache    => m_axi_awcache ,
    m_axi_wready     => m_axi_wready  ,
    m_axi_wvalid     => m_axi_wvalid  ,
    m_axi_wdata      => m_axi_wdata   ,
    m_axi_wstrb      => m_axi_wstrb   ,
    m_axi_wlast      => m_axi_wlast   ,
    m_axi_bready     => m_axi_bready  ,
    m_axi_bvalid     => m_axi_bvalid  ,
    m_axi_bresp      => m_axi_bresp   ,

    -- AXI Slave burst
    S_AXI_ACLK       => S_AXI_ACLK    ,
    S_AXI_ARESETN    => S_AXI_ARESETN ,
    S_AXI_AWADDR     => S_AXI_AWADDR  ,
    S_AXI_AWVALID    => S_AXI_AWVALID ,
    S_AXI_WDATA      => S_AXI_WDATA   ,
    S_AXI_WSTRB      => S_AXI_WSTRB   ,
    S_AXI_WVALID     => S_AXI_WVALID  ,
    S_AXI_BREADY     => S_AXI_BREADY  ,
    S_AXI_ARADDR     => S_AXI_ARADDR  ,
    S_AXI_ARVALID    => S_AXI_ARVALID ,
    S_AXI_RREADY     => S_AXI_RREADY  ,
    S_AXI_ARREADY    => S_AXI_ARREADY ,
    S_AXI_RDATA      => S_AXI_RDATA   ,
    S_AXI_RRESP      => S_AXI_RRESP   ,
    S_AXI_RVALID     => S_AXI_RVALID  ,
    S_AXI_WREADY     => S_AXI_WREADY  ,
    S_AXI_BRESP      => S_AXI_BRESP   ,
    S_AXI_BVALID     => S_AXI_BVALID  ,
    S_AXI_AWREADY    => S_AXI_AWREADY ,
    S_AXI_AWID       => S_AXI_AWID    ,
    S_AXI_AWLEN      => S_AXI_AWLEN   ,
    S_AXI_AWSIZE     => S_AXI_AWSIZE  ,
    S_AXI_AWBURST    => S_AXI_AWBURST ,
    S_AXI_AWLOCK     => S_AXI_AWLOCK  ,
    S_AXI_AWCACHE    => S_AXI_AWCACHE ,
    S_AXI_AWPROT     => S_AXI_AWPROT  ,
    S_AXI_WLAST      => S_AXI_WLAST   ,
    S_AXI_BID        => S_AXI_BID     ,
    S_AXI_ARID       => S_AXI_ARID    ,
    S_AXI_ARLEN      => S_AXI_ARLEN   ,
    S_AXI_ARSIZE     => S_AXI_ARSIZE  ,
    S_AXI_ARBURST    => S_AXI_ARBURST ,
    S_AXI_ARLOCK     => S_AXI_ARLOCK  ,
    S_AXI_ARCACHE    => S_AXI_ARCACHE ,
    S_AXI_ARPROT     => S_AXI_ARPROT  ,
    S_AXI_RID        => S_AXI_RID     ,
    S_AXI_RLAST      => S_AXI_RLAST   
  );

  ------------------------------------------
  -- instantiate axi_lite_ipif
  ------------------------------------------
  AXI_LITE_IPIF_I : entity axi_lite_ipif_v1_01_a.axi_lite_ipif
    generic map
    (
      C_S_AXI_DATA_WIDTH             => C_S_AXILITE_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH             => C_S_AXILITE_ADDR_WIDTH,
      C_S_AXI_MIN_SIZE               => C_S_AXILITE_MIN_SIZE,
      C_USE_WSTRB                    => C_USE_WSTRB,
      C_DPHASE_TIMEOUT               => C_DPHASE_TIMEOUT,
      C_ARD_ADDR_RANGE_ARRAY         => IPIF_ARD_ADDR_RANGE_ARRAY,
      C_ARD_NUM_CE_ARRAY             => IPIF_ARD_NUM_CE_ARRAY,
      C_FAMILY                       => C_FAMILY
    )
    port map
    (
      S_AXI_ACLK                     => S_AXILITE_ACLK,
      S_AXI_ARESETN                  => S_AXILITE_ARESETN,
      S_AXI_AWADDR                   => S_AXILITE_AWADDR,
      S_AXI_AWVALID                  => S_AXILITE_AWVALID,
      S_AXI_WDATA                    => S_AXILITE_WDATA,
      S_AXI_WSTRB                    => S_AXILITE_WSTRB,
      S_AXI_WVALID                   => S_AXILITE_WVALID,
      S_AXI_BREADY                   => S_AXILITE_BREADY,
      S_AXI_ARADDR                   => S_AXILITE_ARADDR,
      S_AXI_ARVALID                  => S_AXILITE_ARVALID,
      S_AXI_RREADY                   => S_AXILITE_RREADY,
      S_AXI_ARREADY                  => S_AXILITE_ARREADY,
      S_AXI_RDATA                    => S_AXILITE_RDATA,
      S_AXI_RRESP                    => S_AXILITE_RRESP,
      S_AXI_RVALID                   => S_AXILITE_RVALID,
      S_AXI_WREADY                   => S_AXILITE_WREADY,
      S_AXI_BRESP                    => S_AXILITE_BRESP,
      S_AXI_BVALID                   => S_AXILITE_BVALID,
      S_AXI_AWREADY                  => S_AXILITE_AWREADY,
      Bus2IP_Clk                     => ipif_Bus2IP_Clk,
      Bus2IP_Resetn                  => ipif_Bus2IP_Resetn,
      Bus2IP_Addr                    => ipif_Bus2IP_Addr,
      Bus2IP_RNW                     => ipif_Bus2IP_RNW,
      Bus2IP_BE                      => ipif_Bus2IP_BE,
      Bus2IP_CS                      => ipif_Bus2IP_CS,
      Bus2IP_RdCE                    => ipif_Bus2IP_RdCE,
      Bus2IP_WrCE                    => ipif_Bus2IP_WrCE,
      Bus2IP_Data                    => ipif_Bus2IP_Data,
      IP2Bus_WrAck                   => ipif_IP2Bus_WrAck,
      IP2Bus_RdAck                   => ipif_IP2Bus_RdAck,
      IP2Bus_Error                   => ipif_IP2Bus_Error,
      IP2Bus_Data                    => ipif_IP2Bus_Data
    );



  ------------------------------------------
  -- instantiate User Logic
  ------------------------------------------
  REG_FILE_I : entity remap_v1_00_a.register_file
    generic map
    (                                                  
      C_M_AXI_ADDR_WIDTH             => C_M_AXI_ADDR_WIDTH,
      C_S_AXI_ADDR_WIDTH             => C_S_AXILITE_ADDR_WIDTH,
      C_SLV_DWIDTH                   => C_S_AXILITE_DATA_WIDTH,
      C_NUM_REG                      => USER_NUM_REG,
      C_ADDR_REMAP_DEFAULT           => C_ADDR_REMAP_DEFAULT
    )
    port map
    (
      arUser_val                     => arUser_val        ,
      AwUser_val                     => awUser_val        ,
      AddrMSB_val                    => AddrMSB_val       ,
                                                          
      Bus2IP_Clk                     => ipif_Bus2IP_Clk   ,
      Bus2IP_Resetn                  => ipif_Bus2IP_Resetn,
      Bus2IP_Addr                    => ipif_Bus2IP_Addr  ,
      Bus2IP_Data                    => ipif_Bus2IP_Data  ,
      Bus2IP_BE                      => ipif_Bus2IP_BE    ,
      Bus2IP_RdCE                    => ipif_Bus2IP_RdCE(USER_NUM_REG-1 downto 0)  ,
      Bus2IP_WrCE                    => ipif_Bus2IP_WrCE(USER_NUM_REG-1 downto 0)  ,
      IP2Bus_Data                    => ipif_IP2Bus_Data  ,
      IP2Bus_RdAck                   => ipif_IP2Bus_RdAck ,
      IP2Bus_WrAck                   => ipif_IP2Bus_WrAck ,
      IP2Bus_Error                   => ipif_IP2Bus_Error
      
    );


-- Chipscope DEBUG bus alias

DEBUG <=   dbg_sigs;

end IMP;
