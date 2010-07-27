------------------------------------------------------------------------------------------------------------------------
-- Avalon Interface of OpenMAC to use with NIOSII
--
-- 	  Copyright (C) 2009 B&R
--
--    Redistribution and use in source and binary forms, with or without
--    modification, are permitted provided that the following conditions
--    are met:
--
--    1. Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--
--    3. Neither the name of B&R nor the names of its
--       contributors may be used to endorse or promote products derived
--       from this software without prior written permission. For written
--       permission, please contact office@br-automation.com
--
--    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
--    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
--    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
--    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
--    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
--    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--    POSSIBILITY OF SUCH DAMAGE.
--
------------------------------------------------------------------------------------------------------------------------
-- Version History
------------------------------------------------------------------------------------------------------------------------
-- 2009-05-20  V0.01        First version
-- 2009-06-04  V0.10        Implemented FIFO for Data-Queing form/to DMA
-- 2009-06-15  V0.11        Increased performance of FIFO
-- 2009-06-20  V0.20        New FIFO concept. (FIFO IP of Altera used)
-- 2009-06-26  V0.21        Little Bugfix of DMA -> Reset was handled wrong
-- 2009-08-07  V0.30        Converted to official version
-- 2009-08-21  V0.40		TX DMA run if fifo is not empty. Interface for Timer Cmp + IRQ
-- 2009-09-03  V0.50		RX FIFO is definitely empty when a new frame arrives (Fifo sclr is set for 1 cycle)
-- 2009-09-07  V0.60		Added openFilter and openHub. Some changes in Mii core map. Added 2nd RMii Port.
-- 2009-09-15  V0.61		Added ability to read the Mac Time over Time Cmp Slave Interface (32 bits).
-- 2009-09-18  V0.62		Deleted in Phy Mii core NodeNr port. 
-- 2010-04-01  V0.63		Added Timer triggered transmission ability
--							RXFifo Clr is done at end of RxFrame (not beginning! refer to V0.50)
--							Added "CrsDv Filter" (deletes CrsDv toggle)
-- 2010-04-26  V0.70		reduced to two Avalon Slave and one Avalon Master Interface
-- 2010-05-03  V0.71		omit Avalon Master Interface / use internal DPR
------------------------------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY AlteraOpenMACIF IS
   GENERIC( Simulate                    : IN    boolean := false;
			pBfSizeLOG2_g				: IN	integer := 11);
   PORT (   Reset_n						: IN    STD_LOGIC;
			Clk50                  		: IN    STD_LOGIC;
			ClkFaster					: IN	STD_LOGIC;
		-- Avalon Slave Interface 
            s_chipselect                : IN    STD_LOGIC;
            s_read_n					: IN    STD_LOGIC;
            s_write_n					: IN    STD_LOGIC;
            s_byteenable_n              : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
            s_address                   : IN    STD_LOGIC_VECTOR(11 DOWNTO 0);
            s_writedata                 : IN    STD_LOGIC_VECTOR(15 DOWNTO 0);
            s_readdata                  : OUT   STD_LOGIC_VECTOR(15 DOWNTO 0);
            s_IRQ						: OUT 	STD_LOGIC;
		-- Avalon Slave Interface to cmp unit 
            t_chipselect                : IN    STD_LOGIC;
            t_read_n					: IN    STD_LOGIC;
            t_write_n					: IN    STD_LOGIC;
            t_byteenable_n              : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
            t_address                   : IN    STD_LOGIC_VECTOR(0 DOWNTO 0);
            t_writedata                 : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
            t_readdata                  : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
            t_IRQ						: OUT 	STD_LOGIC;
        -- Avalon Slave Interface to packet buffer dpr
			iBuf_chipselect             : IN    STD_LOGIC;
            iBuf_read_n					: IN    STD_LOGIC;
            iBuf_write_n				: IN    STD_LOGIC;
            iBuf_byteenable             : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
            iBuf_address                : IN    STD_LOGIC_VECTOR(pBfSizeLOG2_g-3 DOWNTO 0);
            iBuf_writedata              : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
            iBuf_readdata               : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- RMII Port 0
            rRx_Dat_0                   : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);  -- RMII Rx Daten
            rCrs_Dv_0                   : IN    STD_LOGIC;                     -- RMII Carrier Sense / Data Valid
            rTx_Dat_0                   : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);  -- RMII Tx Daten
            rTx_En_0                    : OUT   STD_LOGIC;                     -- RMII Tx_Enable
		-- RMII Port 1
            rRx_Dat_1                   : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);  -- RMII Rx Daten
            rCrs_Dv_1                   : IN    STD_LOGIC;                     -- RMII Carrier Sense / Data Valid
            rTx_Dat_1                   : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);  -- RMII Tx Daten
            rTx_En_1                    : OUT   STD_LOGIC;                      -- RMII Tx_Enable
--		-- Serial Management Interface (the_Mii)	
			mii_Clk						: OUT	STD_LOGIC;
			mii_Di						: IN	STD_LOGIC;
			mii_Do						: OUT	STD_LOGIC;
			mii_Doe						: OUT	STD_LOGIC;
			mii_nResetOut				: OUT	STD_LOGIC
        );
END ENTITY AlteraOpenMACIF;

ARCHITECTURE struct OF AlteraOpenMACIF IS
-- Avalon Slave to openMAC
	SIGNAL mac_chipselect_ram           : STD_LOGIC;
	SIGNAL mac_chipselect_cont          : STD_LOGIC;
	SIGNAL mac_write_n					: STD_LOGIC;
	SIGNAL mac_byteenable_n             : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL mac_address                  : STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL mac_writedata                : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL mac_readdata                 : STD_LOGIC_VECTOR(15 DOWNTO 0);
-- Avalon Slave to Mii
	SIGNAL mii_chipselect               : STD_LOGIC;
	SIGNAL mii_write_n					: STD_LOGIC;
	SIGNAL mii_byteenable_n             : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL mii_address                  : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL mii_writedata                : STD_LOGIC_VECTOR(15 DOWNTO 0);
	SIGNAL mii_readdata                 : STD_LOGIC_VECTOR(15 DOWNTO 0);
-- IRQ vector
	SIGNAL tx_irq_n						: STD_LOGIC;
	SIGNAL rx_irq_n						: STD_LOGIC;
-- DMA Interface  
    SIGNAL  Dma_Req						: STD_LOGIC;
    SIGNAL  Dma_Rw						: STD_LOGIC;
    SIGNAL  Dma_Ack                     : STD_LOGIC;
    SIGNAL  Dma_Addr                    : STD_LOGIC_VECTOR(31 DOWNTO 1);
    SIGNAL  Dma_Dout                    : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL  Dma_Din                     : STD_LOGIC_VECTOR(15 DOWNTO 0);
---- Timer Interface
    SIGNAL  Mac_Zeit                    : STD_LOGIC_VECTOR(31 DOWNTO 0);
-- Mac RMii Signals to Filter
    SIGNAL  rTx_Eni						: STD_LOGIC;
	SIGNAL  rRx_Dati                   	: STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL  rCrs_Dvi                   	: STD_LOGIC;
	SIGNAL  rTx_Dati                   	: STD_LOGIC_VECTOR(1 DOWNTO 0);
-- Filter RMii Signals to Hub
    SIGNAL  rTx_Enii					: STD_LOGIC;
	SIGNAL  rRx_Datii                   : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL  rCrs_Dvii                   : STD_LOGIC;
	SIGNAL  rTx_Datii                   : STD_LOGIC_VECTOR(1 DOWNTO 0);
-- Hub Signals
	SIGNAL hubTxEn						: STD_LOGIC_VECTOR(3 downto 1);
	SIGNAL hubTxDat0					: STD_LOGIC_VECTOR(3 downto 1);
	SIGNAL hubTxDat1					: STD_LOGIC_VECTOR(3 downto 1);
	SIGNAL RxPortInt					: integer RANGE 0 TO 3; --0 is idle
	SIGNAL RxPort						: STD_LOGIC_VECTOR(1 downto 0);
-- Mii Signals
	SIGNAL mii_Doei						: STD_LOGIC;
BEGIN

	the_Mii : ENTITY work.OpenMAC_MII
		PORT MAP (  nRst => Reset_n,
					Clk  => Clk50,
				    --Slave IF
					Addr     => mii_address,
					Sel      => mii_chipselect,
					nBe      => mii_byteenable_n,
					nWr      => mii_write_n,
					Data_In  => mii_writedata,
					Data_Out => mii_readdata,
					--Export
					Mii_Clk   => mii_Clk,
					Mii_Di    => mii_Di,
					Mii_Do	  => mii_Do,
					Mii_Doe   => mii_Doei, -- '1' ... Input / '0' ... Output
					nResetOut => mii_nResetOut
				   );	
	mii_Doe <= not mii_Doei;

	the_Mac : ENTITY work.OpenMAC
		GENERIC MAP (	HighAdr  => Dma_Addr'HIGH,
						Simulate => Simulate,
						Timer    => TRUE,
						TxDel	 => TRUE
					)
		PORT MAP	(	nRes => Reset_n,
						Clk  => Clk50,
						--Export
						rRx_Dat  => rRx_Dati,
						rCrs_Dv  => rCrs_Dvi,
						rTx_Dat  => rTx_Dati,
						rTx_En   => rTx_Eni,
						Mac_Zeit => Mac_Zeit,
						--ir
						nTx_Int => tx_irq_n,
						nRx_Int => rx_irq_n,
						-- Slave Interface
						S_nBe    => mac_byteenable_n,
						s_nWr    => mac_write_n,
						Sel_Ram  => mac_chipselect_ram,
						Sel_Cont => mac_chipselect_cont,
						S_Adr    => mac_address(10 DOWNTO 1),
						S_Din    => mac_writedata,
						S_Dout   => mac_readdata,
						-- Master Interface
						Dma_Req  => Dma_Req,
						Dma_Rw   => Dma_Rw,
						Dma_Ack  => Dma_Ack,
						Dma_Addr => Dma_Addr,
						Dma_Dout => Dma_Dout,
						Dma_Din  => Dma_Din,
						-- Hub
						Hub_Rx => RxPort
					);

	the_Filter : entity work.OpenFILTER
		port map	(
						nRst => Reset_n,
						Clk => Clk50,
						nCheckShortFrames => '0',
						RxDvIn => rCrs_Dvii,
						RxDatIn => rRx_Datii,
						RxDvOut => rCrs_Dvi,
						RxDatOut => rRx_Dati,
						TxEnIn => rTx_Eni,
						TxDatIn => rTx_Dati,
						TxEnOut => rTx_Enii,
						TxDatOut => rTx_Datii
		);
	
	the_Hub : entity work.OpenHub
		generic map (	Ports => 3
		)
		port map 	(
						nRst 			=> 	Reset_n,
						Clk 			=> 	Clk50,
						RxDv 			=> 	rCrs_Dv_1 & rCrs_Dv_0 & rTx_Enii,
						RxDat0 			=> 	rRx_Dat_1(0) & rRx_Dat_0(0) & rTx_Datii(0),
						RxDat1 			=> 	rRx_Dat_1(1) & rRx_Dat_0(1) & rTx_Datii(1),
						TxEn 			=> 	hubTxEn,
						TxDat0 			=> 	hubTxDat0,
						TxDat1 			=> 	hubTxDat1,
						internPort 		=> 	1,
						TransmitMask 	=> 	(others => '1'),
						ReceivePort 	=> 	RxPortInt
		);
	RxPort <= conv_std_logic_vector(RxPortInt, RxPort'length);
	
	rTx_En_1 <= hubTxEn(3);
	rTx_En_0 <= hubTxEn(2);
	rCrs_Dvii <= hubTxEn(1);
	
	rTx_Dat_1(0) <= hubTxDat0(3);
	rTx_Dat_0(0) <= hubTxDat0(2);
	rRx_Datii(0) <= hubTxDat0(1);
	
	rTx_Dat_1(1) <= hubTxDat1(3);
	rTx_Dat_0(1) <= hubTxDat1(2);
	rRx_Datii(1) <= hubTxDat1(1);
	
	-----------------------------------------------------------------------
	-- Avalon Slave Interface <-> openMac
	-----------------------------------------------------------------------
	s_IRQ <= (not rx_irq_n) or (not tx_irq_n);
	
	the_addressDecoder: BLOCK
		SIGNAL SelShadow : STD_LOGIC;
		SIGNAL SelIrqTable : STD_LOGIC;
	BEGIN
		
		mac_chipselect_cont <= '1' 	WHEN ( s_chipselect = '1' AND s_address(11 DOWNTO  9) = "000" ) 		ELSE '0'; --0000 to 03ff
		mac_chipselect_ram  <= '1' 	WHEN ( s_chipselect = '1' AND s_address(11 DOWNTO 10) = "01" ) 			ELSE '0'; --0800 to 0fff
		SelShadow <= '1' 			WHEN ( s_chipselect = '1' AND s_address(11 DOWNTO  9) = "010" ) 		ELSE '0'; --0800 to 0bff
		mii_chipselect <= '1' 		WHEN ( s_chipselect = '1' AND s_address(11 DOWNTO  3) = "100000000" ) 	ELSE '0'; --1000 to 100f
		SelIrqTable <= '1' 			WHEN ( s_chipselect = '1' AND s_address(11 DOWNTO  3) = "100000001" ) 	ELSE '0'; --1010 to 101f
	
	
		mac_byteenable_n <= s_byteenable_n(0) & s_byteenable_n(1);
		mac_write_n <= s_write_n;
		mac_address(11 DOWNTO 1) <= s_address(10 DOWNTO 1) &     s_address(0) WHEN SelShadow = '1' ELSE 
									s_address(10 DOWNTO 1) & NOT s_address(0);
		mac_writedata <= s_writedata(15 DOWNTO 8)  & s_writedata(7 DOWNTO 0) WHEN s_byteenable_n = "00" ELSE
						 s_writedata(7 DOWNTO 0)   & s_writedata(15 DOWNTO 8);
		
		
		mii_byteenable_n <= s_byteenable_n;
		mii_write_n <= s_write_n;
		mii_writedata <= s_writedata;
		mii_address <= s_address(2 DOWNTO 0);
		
		
		s_readdata <= 	x"ADDE" WHEN SelShadow = '1' ELSE --when packet filters are selected
						mac_readdata(15 DOWNTO 8) & mac_readdata(7 DOWNTO 0)  WHEN ( ( mac_chipselect_ram = '1' OR mac_chipselect_cont = '1') AND s_byteenable_n = "00" ) ELSE
						mac_readdata(7 DOWNTO 0)  & mac_readdata(15 DOWNTO 8) WHEN ( mac_chipselect_ram = '1' OR mac_chipselect_cont = '1') ELSE
						mii_readdata WHEN mii_chipselect = '1' ELSE
						x"000" & "00" & (not rx_irq_n) & (not tx_irq_n) WHEN SelIrqTable = '1' ELSE
						(others => '0');
		
	END BLOCK the_addressDecoder;
	
	-----------------------------------------------------------------------
	-- openMAC internal packet buffer
	--------------------------------------
	--- PORT A => MAC
	--- PORT B => AVALON BUS
	-----------------------------------------------------------------------
	intPcktbfr: BLOCK
	signal Dma_Din_s : std_logic_vector(Dma_Din'range);
	BEGIN
	
	Dma_Din <= Dma_Din_s(7 downto 0) & Dma_Din_s(15 downto 8);
	
	genAck : process(Clk50)
	begin
		if Clk50 = '1' and Clk50'event then
			Dma_Ack <= '0';
			if Dma_Req = '1' then
				Dma_Ack <= '1';
			end if;
		end if;
	end process genAck;
	
	packetBuffer:	ENTITY	work.OpenMAC_DPRpackets
		GENERIC MAP(memSizeLOG2_g => pBfSizeLOG2_g)
		PORT MAP
		(	
			address_a => Dma_Addr(pBfSizeLOG2_g-1 downto 1),
			address_b => iBuf_address,
			byteena_a => "11",
			byteena_b => iBuf_byteenable,
			clock_a => Clk50,
			clock_b => ClkFaster,
			data_a => Dma_Dout(7 downto 0) & Dma_Dout(15 downto 8),
			data_b => iBuf_writedata,
			rden_a => Dma_Req and Dma_Rw,
			rden_b => not iBuf_read_n and iBuf_chipselect,
			wren_a => Dma_Req and not Dma_Rw,
			wren_b => not iBuf_write_n and iBuf_chipselect,
			q_a => Dma_Din_s,
			q_b => iBuf_readdata
		);
	END BLOCK intPcktbfr;

	-----------------------------------------------------------------------
	-- MAC-Time compare
	-- Mac Time output
	-----------------------------------------------------------------------
	the_cmpUnit : BLOCK
		SIGNAL Mac_Cmp_On : STD_LOGIC;
		SIGNAL Mac_Cmp_Wert : STD_LOGIC_VECTOR(Mac_Zeit'RANGE);
		SIGNAL Mac_Cmp_Irq : STD_LOGIC;
	BEGIN
		
		t_IRQ <= Mac_Cmp_Irq;
		
		p_MacCmp : PROCESS ( Reset_n, Clk50 )
		BEGIN
			IF ( Reset_n = '0' ) THEN
				Mac_Cmp_Irq  <= '0';
				Mac_Cmp_On   <= '0';
				Mac_Cmp_Wert <= (OTHERS => '0');
				t_readdata <= (OTHERS => '0');
			ELSIF rising_edge( Clk50 ) THEN
			
				IF ( t_chipselect = '1' AND t_write_n = '0' ) THEN
					Mac_Cmp_Irq <= '0';
					case t_address is
						when "0" => --0
							Mac_Cmp_Wert <= t_writedata;
						when "1" => --4
							Mac_Cmp_On <= t_writedata(0);
						when others =>
							-- do nothing
					end case;
				END IF;

				IF ( Mac_Cmp_On = '1' and Mac_Cmp_Wert( Mac_Zeit'RANGE ) = Mac_Zeit ) THEN
					Mac_Cmp_Irq <= '1';
				END IF;
				
				if ( t_chipselect = '1' and t_read_n = '0' ) then
					case t_address is
						when "0" => --0
							t_readdata <= Mac_Zeit(31 DOWNTO 0);
						when "1" => --4
							t_readdata <= x"0000000" & "00" & Mac_Cmp_Irq & Mac_Cmp_On;
						when others =>
							t_readdata <= (others => '0');
					end case;
				end if;

			END IF;
		END PROCESS p_MacCmp;
		
	END BLOCK the_cmpUnit;

END ARCHITECTURE struct;
