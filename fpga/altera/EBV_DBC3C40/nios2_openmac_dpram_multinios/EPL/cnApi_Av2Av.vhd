------------------------------------------------------------------------------------------------------------------------
-- Process Data Interface (PDI) for
--	POWERLINK Communication Processor (PCP): Avalon
--	Application Processor (AP): Avalon
--
-- 	  Copyright (C) 2010 B&R
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
-- 2009-06-28  V0.01        First version
------------------------------------------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;

ENTITY cnApi_Av2Av IS
	GENERIC(
			--implement triple buffer (is true every time)
			bUseTripleBuffer            : IN    boolean := true;
			--PDO buffer size *3 if triple buffer used
			iTpdoBufSize_g				: IN	integer := 100;
			iRpdoBufSize_g				: IN	integer := 100;
			--PD-objects
			iTpdoObjNumber_g			: IN	integer := 10;
			iRpdoObjNumber_g			: IN	integer := 10;
			--asynchronous TX and RX buffer size
			iAsyTxBufSize_g				: IN	integer := 1500;
			iAsyRxBufSize_g				: IN	integer := 1500
	);
			
	PORT (   
			pcp_Reset					: IN    STD_LOGIC;
			pcp_Clk                  	: IN    STD_LOGIC;
			ap_Reset					: IN    STD_LOGIC;
			ap_Clk						: IN	STD_LOGIC;
		-- Avalon Slave Interface for PCP
            pcp_chipselect              : IN    STD_LOGIC;
            pcp_read					: IN    STD_LOGIC;
            pcp_write					: IN    STD_LOGIC;
            pcp_byteenable	            : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
            pcp_address                 : IN    STD_LOGIC_VECTOR(14 DOWNTO 0);
            pcp_writedata               : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
            pcp_readdata                : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
		-- Avalon Slave Interface for AP
            ap_chipselect               : IN    STD_LOGIC;
            ap_read						: IN    STD_LOGIC;
            ap_write					: IN    STD_LOGIC;
            ap_byteenable             	: IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
            ap_address                  : IN    STD_LOGIC_VECTOR(14 DOWNTO 0);
            ap_writedata                : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
            ap_readdata                 : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END ENTITY cnApi_Av2Av;

ARCHITECTURE rtl OF cnApi_Av2Av IS
------------------------------------------------------------------------------------------------------------------------
--CONSTANTS
	--external memory map offset 
	CONSTANT iCtrlStatAddr_c			:		INTEGER := 16#00000000#;
	CONSTANT iTxPdoBufAddr_c			:		INTEGER := 16#00001000#;
	CONSTANT iRxPdoBufAddr_c			:		INTEGER := 16#00002000#;
	CONSTANT iTxPdoDesAddr_c			:		INTEGER := 16#00003000#;
	CONSTANT iRxPdoDesAddr_c			:		INTEGER := 16#00004000#;
	CONSTANT iAsyTxBufAddr_c			:		INTEGER := 16#00005000#;
	CONSTANT iAsyRxBufAddr_c			:		INTEGER := 16#00006000#;

	--external memory map span
	CONSTANT iCtrlStatSpan_c			:		INTEGER := 16#34#;
	CONSTANT iTxPdoBufSpan_c			:		INTEGER := iTpdoBufSize_g + 0;
	CONSTANT iRxPdoBufSpan_c			:		INTEGER := iRpdoBufSize_g + 16;
	CONSTANT iTxPdoDesSpan_c			:		INTEGER := iTpdoObjNumber_g * 8;
	CONSTANT iRxPdoDesSpan_c			:		INTEGER := iRpdoObjNumber_g * 8;
	CONSTANT iAsyTxBufSpan_c			:		INTEGER := iAsyTxBufSize_g + 4;
	CONSTANT iAsyRxBufSpan_c			:		INTEGER := iAsyRxBufSize_g + 4;

	--internal memory map span (aligned)
	CONSTANT alignMASK_c				:		STD_LOGIC_VECTOR(31 DOWNTO 0) := x"00000003";
	CONSTANT iIntCtrlStatSpan_c			:		INTEGER := 16#0C#; --only 0x04 to 0x10
	CONSTANT iIntTxPdoBufSpan_c			:		INTEGER 
								:= conv_integer(conv_std_logic_vector(iTxPdoBufSpan_c, 32) + alignMASK_c AND NOT alignMASK_c);
	CONSTANT iIntRxPdoBufSpan_c			:		INTEGER 
								:= conv_integer(conv_std_logic_vector(iRxPdoBufSpan_c, 32) + alignMASK_c AND NOT alignMASK_c);
	CONSTANT iIntTxPdoDesSpan_c			:		INTEGER 
								:= conv_integer(conv_std_logic_vector(iTxPdoDesSpan_c, 32) + alignMASK_c AND NOT alignMASK_c);
	CONSTANT iIntRxPdoDesSpan_c			:		INTEGER 
								:= conv_integer(conv_std_logic_vector(iRxPdoDesSpan_c, 32) + alignMASK_c AND NOT alignMASK_c);
	CONSTANT iIntAsyTxBufSpan_c			:		INTEGER 
								:= conv_integer(conv_std_logic_vector(iAsyTxBufSpan_c, 32) + alignMASK_c AND NOT alignMASK_c);
	CONSTANT iIntAsyRxBufSpan_c			:		INTEGER 
								:= conv_integer(conv_std_logic_vector(iAsyRxBufSpan_c, 32) + alignMASK_c AND NOT alignMASK_c);

	--necessary address width
	CONSTANT iDprAddrWidth_g			:		INTEGER
		:= INTEGER(CEIL(LOG2(REAL(
			iIntCtrlStatSpan_c +
			iIntTxPdoBufSpan_c*3 +
			iIntRxPdoBufSpan_c*3 +
			iIntTxPdoDesSpan_c +
			iIntRxPdoDesSpan_c +
			iIntAsyTxBufSpan_c +
			iIntAsyRxBufSpan_c
		))));

	--internal memory map offset
	CONSTANT iIntCtrlStatAddr_c			:		INTEGER := 0;
	
	CONSTANT iIntTxPdoBufAddr0_c		:		INTEGER := iIntCtrlStatAddr_c + iIntCtrlStatSpan_c;
	CONSTANT iIntTxPdoBufAddr1_c		:		INTEGER := iIntTxPdoBufAddr0_c + iIntTxPdoBufSpan_c;
	CONSTANT iIntTxPdoBufAddr2_c		:		INTEGER := iIntTxPdoBufAddr1_c + iIntTxPdoBufSpan_c;
	
	CONSTANT iIntRxPdoBufAddr0_c		:		INTEGER := iIntTxPdoBufAddr2_c + iIntTxPdoBufSpan_c;
	CONSTANT iIntRxPdoBufAddr1_c		:		INTEGER := iIntRxPdoBufAddr0_c + iIntRxPdoBufSpan_c;
	CONSTANT iIntRxPdoBufAddr2_c		:		INTEGER := iIntRxPdoBufAddr1_c + iIntRxPdoBufSpan_c;
	
	CONSTANT iIntTxPdoDesAddr_c			:		INTEGER := iIntRxPdoBufAddr2_c + iIntRxPdoBufSpan_c;
	CONSTANT iIntRxPdoDesAddr_c			:		INTEGER := iIntTxPdoDesAddr_c + iIntTxPdoDesSpan_c;
	CONSTANT iIntAsyTxBufAddr_c			:		INTEGER := iIntRxPdoDesAddr_c + iIntRxPdoDesSpan_c;
	CONSTANT iIntAsyRxBufAddr_c			:		INTEGER := iIntAsyTxBufAddr_c + iIntAsyTxBufSpan_c;
	
	--magic number
	CONSTANT MagicNumber_c				:		INTEGER
		:= 16#50435000#;
	
------------------------------------------------------------------------------------------------------------------------
--SIGNALS
	--to port A of dpr
	SIGNAL dprA_addr					:		STD_LOGIC_VECTOR(iDprAddrWidth_g-2-1 DOWNTO 0);
	SIGNAL dprA_din						:		STD_LOGIC_VECTOR(pcp_writedata'range);
	SIGNAL dprA_dout					:		STD_LOGIC_VECTOR(pcp_readdata'range);
	SIGNAL dprA_ben						:		STD_LOGIC_VECTOR(pcp_byteenable'range);
	SIGNAL dprA_cs						:		STD_LOGIC;
	SIGNAL dprA_rd						:		STD_LOGIC;
	SIGNAL dprA_wr						:		STD_LOGIC;
	
	--to port B of dpr
	SIGNAL dprB_addr					:		STD_LOGIC_VECTOR(iDprAddrWidth_g-2-1 DOWNTO 0);
	SIGNAL dprB_din						:		STD_LOGIC_VECTOR(ap_writedata'range);
	SIGNAL dprB_dout					:		STD_LOGIC_VECTOR(ap_readdata'range);
	SIGNAL dprB_ben						:		STD_LOGIC_VECTOR(ap_byteenable'range);
	SIGNAL dprB_cs						:		STD_LOGIC;
	SIGNAL dprB_rd						:		STD_LOGIC;
	SIGNAL dprB_wr						:		STD_LOGIC;
	
	--memory mapping signals
	SIGNAL selConstA					:		STD_LOGIC; --if non DPR content is selected
	SIGNAL selConstB					:		STD_LOGIC; --if non DPR content is selected
	SIGNAL constA_dout					:		STD_LOGIC_VECTOR(pcp_readdata'range);
	SIGNAL constB_dout					:		STD_LOGIC_VECTOR(ap_readdata'range);
	---select memory content in dprA
	SIGNAL selDprACSBuf					:		STD_LOGIC; --control and status (0x4 to 0xf)
	SIGNAL selDprATPBuf					:		STD_LOGIC; --tx pdo buffer
	SIGNAL selDprARPBuf					:		STD_LOGIC; --rx pdo buffer
	SIGNAL selDprATPDes					:		STD_LOGIC; --tx pdo descriptor
	SIGNAL selDprARPDes					:		STD_LOGIC; --tx pdo descriptor
	SIGNAL selDprATABuf					:		STD_LOGIC; --async tx buffer
	SIGNAL selDprARABuf					:		STD_LOGIC; --async rx buffer
	---select memory content in dprB
	SIGNAL selDprBCSBuf					:		STD_LOGIC; --control and status (0x4 to 0xf)
	SIGNAL selDprBTPBuf					:		STD_LOGIC; --tx pdo buffer
	SIGNAL selDprBRPBuf					:		STD_LOGIC; --rx pdo buffer
	SIGNAL selDprBTPDes					:		STD_LOGIC; --tx pdo descriptor
	SIGNAL selDprBRPDes					:		STD_LOGIC; --tx pdo descriptor
	SIGNAL selDprBTABuf					:		STD_LOGIC; --async tx buffer
	SIGNAL selDprBRABuf					:		STD_LOGIC; --async rx buffer

	--triple buffer mechanism signals
	TYPE tripleBuf_type IS (b0, b1, b2); --identifies the virtual buffers
	---TPDO
	SIGNAL pcp_selTpdoBuf 				: 		tripleBuf_type; --identifies the selected triple buffer by pcp
	SIGNAL pcp_selTpdo					:		STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pcp_trigTpdoBufChange 		: 		STD_LOGIC; --trigger buffer change
	SIGNAL ap_selTpdoBuf 				: 		tripleBuf_type; --identifies the selected triple buffer by ap
	SIGNAL ap_selTpdo					:		STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ap_trigTpdoBufChange 		: 		STD_LOGIC; --trigger buffer change
	---RPDO
	SIGNAL pcp_selRpdoBuf 				: 		tripleBuf_type; --identifies the selected triple buffer by pcp
	SIGNAL pcp_selRpdo					:		STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL pcp_trigRpdoBufChange 		: 		STD_LOGIC; --trigger buffer change
	SIGNAL ap_selRpdoBuf 				: 		tripleBuf_type; --identifies the selected triple buffer by ap
	SIGNAL ap_selRpdo					:		STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ap_trigRpdoBufChange 		: 		STD_LOGIC; --trigger buffer change
	
BEGIN
		
	--convert states to codes for software interface
	pcp_selTpdo	<=	x"00000000"	WHEN	pcp_selTpdoBuf = b0	ELSE
					x"11111111"	WHEN	pcp_selTpdoBuf = b1	ELSE
					x"22222222"	WHEN	pcp_selTpdoBuf = b2 ELSE
					(others => '0');
	ap_selTpdo	<=	x"00000000"	WHEN	ap_selTpdoBuf = b0	ELSE
					x"11111111"	WHEN	ap_selTpdoBuf = b1	ELSE
					x"22222222"	WHEN	ap_selTpdoBuf = b2 	ELSE
					(others => '0');
	
	pcp_selRpdo	<=	x"00000000"	WHEN	pcp_selRpdoBuf = b0	ELSE
					x"11111111"	WHEN	pcp_selRpdoBuf = b1	ELSE
					x"22222222"	WHEN	pcp_selRpdoBuf = b2 ELSE
					(others => '0');
	ap_selRpdo	<=	x"00000000"	WHEN	ap_selRpdoBuf = b0	ELSE
					x"11111111"	WHEN	ap_selRpdoBuf = b1	ELSE
					x"22222222"	WHEN	ap_selRpdoBuf = b2 	ELSE
					(others => '0');
	
	theRpdoTripleBuffer : BLOCK
	--controls the RPDO triple buffer
		
		--signals for synchronization
		SIGNAL ap_trigRpdoBufChangeL : STD_LOGIC;
		SIGNAL ap_trigRpdoBufChangeLL : STD_LOGIC;
		SIGNAL ap_selRpdoBufL : tripleBuf_type;
		SIGNAL ap_selRpdoBufLL : tripleBuf_type;
	BEGIN
		
		process(ap_Clk)
		begin
			if ap_Clk = '1' and ap_Clk'event then
				if ap_reset = '1' then
					--AP starts with b2 (however it is invalid!)
					ap_selRpdoBuf <= b2;
					ap_selRpdoBufL <= b2;
					--ap_selRpdoBufLL <= b2;
				else
					--synchronize select signal to AP clk domain (2x delay) 
					ap_selRpdoBufL <= ap_selRpdoBufLL; --LL comes from PCP clk domain
					ap_selRpdoBuf <= ap_selRpdoBufL; --ap_selRpdoBuf goes to AP clk domain
					
				end if;
			end if;
		end process;
		
		process(pcp_Clk)
			--these variables allow to overcome race conditions (PCP and AP changes buffer in same pcp_Clk cycle...)
			variable validRpdo_v, lockedRpdo_v : tripleBuf_type;
			variable invalidRpdo_v : tripleBuf_type; --this variable contains the next buffer for the PCP
			
			--verify if Rpdo Buffer Change trigger has changed
			variable lastAp_trigRpdoBufChangeLL : std_logic;
		begin
			if pcp_Clk = '1' and pcp_Clk'event then
				if pcp_reset = '1' then
					validRpdo_v := b1; --after reset b1 buffer is "valid" - thus PCP starts at b0
					lockedRpdo_v := b2; --AP starts at b2
					pcp_selRpdoBuf <= b0; --PCP starts at b0
					
					ap_selRpdoBufLL <= b2;
					--ap_trigRpdoBufChange <= '0';
					ap_trigRpdoBufChangeL <= '0';
					ap_trigRpdoBufChangeLL <= '0';
					
					lastAp_trigRpdoBufChangeLL := '0';
				else
					--synchronize trigger signal to PCP clk domain (2x delay)
					ap_trigRpdoBufChangeL <= ap_trigRpdoBufChange;
					ap_trigRpdoBufChangeLL <= ap_trigRpdoBufChangeL;
					
					--check trigger signals
					---first check PCP
					if pcp_trigRpdoBufChange = '1' then
						validRpdo_v := pcp_selRpdoBuf; --current pcp buffer is next valid buffer
						
						--find invalid buffer for PCP
						case validRpdo_v is
							when b0 =>
								if lockedRpdo_v = b1 then
									invalidRpdo_v := b2;
								else
									invalidRpdo_v := b1;
								end if;
							when b1 =>
								if lockedRpdo_v = b2 then
									invalidRpdo_v := b0;
								else
									invalidRpdo_v := b2;
								end if;
							when b2 =>
								if lockedRpdo_v = b0 then
									invalidRpdo_v := b1;
								else
									invalidRpdo_v := b0;
								end if;
							when others =>
						end case;
						pcp_selRpdoBuf <= invalidRpdo_v; --invalid buffer (not valid and locked) is next buffer for PCP
					end if;
												
					---second check AP
					---trigger event is posted by level change!
					if ap_trigRpdoBufChangeLL /= lastAp_trigRpdoBufChangeLL then
						ap_selRpdoBufLL <= validRpdo_v; --valid buffer is assigned to AP
						lockedRpdo_v := validRpdo_v; --assigned buffer is locked by AP
					end if;					
					lastAp_trigRpdoBufChangeLL := ap_trigRpdoBufChangeLL;
					
				end if;
			end if;
		end process;
		
	END BLOCK theRpdoTripleBuffer;
	
	theTpdoTripleBuffer : BLOCK
	--controls the TPDO triple buffer
		
		--signals for synchronization
		SIGNAL ap_trigTpdoBufChangeL : STD_LOGIC;
		SIGNAL ap_trigTpdoBufChangeLL : STD_LOGIC;
		SIGNAL ap_selTpdoBufL : tripleBuf_type;
		SIGNAL ap_selTpdoBufLL : tripleBuf_type;
	BEGIN
		
		process(ap_Clk)
		begin
			if ap_Clk = '1' and ap_Clk'event then
				if ap_reset = '1' then
					--AP starts with b2 (however it is invalid!)
					ap_selTpdoBuf <= b0;
					ap_selTpdoBufL <= b0;
					
				else
					--synchronize select signal to AP clk domain (2x delay) 
					ap_selTpdoBufL <= ap_selTpdoBufLL; --LL comes from PCP clk domain
					ap_selTpdoBuf <= ap_selTpdoBufL; --ap_selTpdoBuf goes to AP clk domain
					
				end if;
			end if;
		end process;
		
		process(pcp_Clk)
			--these variables allow to overcome race conditions (PCP and AP changes buffer in same pcp_Clk cycle...)
			variable validTpdo_v, lockedTpdo_v : tripleBuf_type;
			variable invalidTpdo_v : tripleBuf_type; --this variable contains the next buffer for the PCP
			
			--verify if Tpdo Buffer Change trigger has changed
			variable lastAp_trigTpdoBufChangeLL : std_logic;
		begin
			if pcp_Clk = '1' and pcp_Clk'event then
				if pcp_reset = '1' then
					validTpdo_v := b1; --after reset b1 buffer is "valid" - thus AP starts at b0
					lockedTpdo_v := b2; --PCP starts at b2
					pcp_selTpdoBuf <= b2;
					ap_selTpdoBufLL <= b0; --AP starts at b0
					
					ap_trigTpdoBufChangeL <= '0';
					ap_trigTpdoBufChangeLL <= '0';
					
					lastAp_trigTpdoBufChangeLL := '0';
				else
					--synchronize trigger signal to PCP clk domain (2x delay)
					ap_trigTpdoBufChangeL <= ap_trigTpdoBufChange;
					ap_trigTpdoBufChangeLL <= ap_trigTpdoBufChangeL;
					
					--check trigger signals
					---first check PCP
					if pcp_trigTpdoBufChange = '1' then
						pcp_selTpdoBuf <= validTpdo_v; --valid buffer is assigned to PCP
						lockedTpdo_v := validTpdo_v; --assigned buffer is locked by PCP
					end if;
												
					---second check AP
					---trigger event is posted by level change!
					if ap_trigTpdoBufChangeLL /= lastAp_trigTpdoBufChangeLL then
						validTpdo_v := ap_selTpdoBufLL; --current ap buffer is next valid
						
						--find invalid buffer for AP
						case validTpdo_v is
							when b0 =>
								if lockedTpdo_v = b1 then
									invalidTpdo_v := b2;
								else
									invalidTpdo_v := b1;
								end if;
							when b1 =>
								if lockedTpdo_v = b2 then
									invalidTpdo_v := b0;
								else
									invalidTpdo_v := b2;
								end if;
							when b2 =>
								if lockedTpdo_v = b0 then
									invalidTpdo_v := b1;
								else
									invalidTpdo_v := b0;
								end if;
							when others =>
						end case;
						ap_selTpdoBufLL <= invalidTpdo_v; --invalid buffer (not valid and locked) is next buffer for AP
					end if;					
					lastAp_trigTpdoBufChangeLL := ap_trigTpdoBufChangeLL;
					
				end if;
			end if;
		end process;
		
	END BLOCK theTpdoTripleBuffer;
	
	theAddressDecoder : BLOCK
	--generate select signals for DPR and non-DPR content
	BEGIN
		--generate selConstA signal for constant values only
		selConstA	<=	'1'	WHEN	pcp_chipselect = '1' AND pcp_address = conv_std_logic_vector(0, pcp_address'length) ELSE
						'1'	WHEN	pcp_chipselect = '1' AND
									(pcp_address >= conv_std_logic_vector(iCtrlStatAddr_c + 16#04#, pcp_address'length) AND
									 pcp_address <  conv_std_logic_vector(iCtrlStatAddr_c + iCtrlStatSpan_c, pcp_address'length)) ELSE
						'0';

		--generate selConstB signal for constant values only
		selConstB	<=	'1'	WHEN	ap_chipselect = '1' AND ap_address = conv_std_logic_vector(0, ap_address'length) ELSE
						'1'	WHEN	ap_chipselect = '1' AND
									(ap_address >= conv_std_logic_vector(iCtrlStatAddr_c + 16#04#, ap_address'length) AND
									 ap_address <  conv_std_logic_vector(iCtrlStatAddr_c + iCtrlStatSpan_c, ap_address'length)) ELSE
						'0';
		
		--generate selDprA*** signals
		selDprACSBuf <= '1'	WHEN	pcp_chipselect = '1' AND
									((pcp_address(pcp_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iCtrlStatAddr_c + 16#04#, pcp_address'length) AND
									(pcp_address(pcp_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iCtrlStatAddr_c + 16#10#, pcp_address'length)) ELSE
						'0'; --selects only addr range 0x4 to 0xf in control/status register
		
		selDprATPBuf <= '1'	WHEN	pcp_chipselect = '1' AND
									((pcp_address(pcp_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iTxPdoBufAddr_c, pcp_address'length) AND
									(pcp_address(pcp_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iTxPdoBufAddr_c + iIntTxPdoBufSpan_c, pcp_address'length)) ELSE
						'0'; --selects the TPDO buffer range
		
		selDprARPBuf <= '1'	WHEN	pcp_chipselect = '1' AND
									((pcp_address(pcp_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iRxPdoBufAddr_c, pcp_address'length) AND
									(pcp_address(pcp_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iRxPdoBufAddr_c + iIntRxPdoBufSpan_c, pcp_address'length)) ELSE
						'0'; --selects the RPDO buffer range
		
		selDprATPDes <= '1'	WHEN	pcp_chipselect = '1' AND
									((pcp_address(pcp_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iTxPdoDesAddr_c, pcp_address'length) AND
									(pcp_address(pcp_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iTxPdoDesAddr_c + iIntTxPdoDesSpan_c, pcp_address'length)) ELSE
						'0'; --selects the TPDO descriptor range
		
		selDprARPDes <= '1'	WHEN	pcp_chipselect = '1' AND
									((pcp_address(pcp_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iRxPdoDesAddr_c, pcp_address'length) AND
									(pcp_address(pcp_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iRxPdoDesAddr_c + iIntRxPdoDesSpan_c, pcp_address'length)) ELSE
						'0'; --selects the TPDO descriptor range
		
		selDprATABuf <= '1'	WHEN	pcp_chipselect = '1' AND
									((pcp_address(pcp_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iAsyTxBufAddr_c, pcp_address'length) AND
									(pcp_address(pcp_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iAsyTxBufAddr_c + iIntAsyTxBufSpan_c, pcp_address'length)) ELSE
						'0'; --selects the async tx buffer range
		
		selDprARABuf <= '1'	WHEN	pcp_chipselect = '1' AND
									((pcp_address(pcp_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iAsyRxBufAddr_c, pcp_address'length) AND
									(pcp_address(pcp_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iAsyRxBufAddr_c + iIntAsyRxBufSpan_c, pcp_address'length)) ELSE
						'0'; --selects the async rx buffer range
		
		--generate selDprB*** signals
		selDprBCSBuf <= '1'	WHEN	ap_chipselect = '1' AND
									((ap_address(ap_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iCtrlStatAddr_c + 16#04#, ap_address'length) AND
									(ap_address(ap_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iCtrlStatAddr_c + 16#10#, ap_address'length)) ELSE
						'0'; --selects only addr range 0x4 to 0xf in control/status register
		
		selDprBTPBuf <= '1'	WHEN	ap_chipselect = '1' AND
									((ap_address(ap_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iTxPdoBufAddr_c, ap_address'length) AND
									(ap_address(ap_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iTxPdoBufAddr_c + iIntTxPdoBufSpan_c, ap_address'length)) ELSE
						'0'; --selects the TPDO buffer range
		
		selDprBRPBuf <= '1'	WHEN	ap_chipselect = '1' AND
									((ap_address(ap_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iRxPdoBufAddr_c, ap_address'length) AND
									(ap_address(ap_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iRxPdoBufAddr_c + iIntRxPdoBufSpan_c, ap_address'length)) ELSE
						'0'; --selects the RPDO buffer range
		
		selDprBTPDes <= '1'	WHEN	ap_chipselect = '1' AND
									((ap_address(ap_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iTxPdoDesAddr_c, ap_address'length) AND
									(ap_address(ap_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iTxPdoDesAddr_c + iIntTxPdoDesSpan_c, ap_address'length)) ELSE
						'0'; --selects the TPDO descriptor range
		
		selDprBRPDes <= '1'	WHEN	ap_chipselect = '1' AND
									((ap_address(ap_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iRxPdoDesAddr_c, ap_address'length) AND
									(ap_address(ap_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iRxPdoDesAddr_c + iIntRxPdoDesSpan_c, ap_address'length)) ELSE
						'0'; --selects the TPDO descriptor range
		
		selDprBTABuf <= '1'	WHEN	ap_chipselect = '1' AND
									((ap_address(ap_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iAsyTxBufAddr_c, ap_address'length) AND
									(ap_address(ap_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iAsyTxBufAddr_c + iIntAsyTxBufSpan_c, ap_address'length)) ELSE
						'0'; --selects the async tx buffer range
		
		selDprBRABuf <= '1'	WHEN	ap_chipselect = '1' AND
									((ap_address(ap_address'left-2 DOWNTO 0) & "00") >= conv_std_logic_vector(iAsyRxBufAddr_c, ap_address'length) AND
									(ap_address(ap_address'left-2 DOWNTO 0) & "00") < conv_std_logic_vector(iAsyRxBufAddr_c + iIntAsyRxBufSpan_c, ap_address'length)) ELSE
						'0'; --selects the async rx buffer range
	END BLOCK theAddressDecoder;
	
	theAddressTranslator : BLOCK
	--a simple adder that calculates the appropriate address inside the DPR
		--tmp signals
		SIGNAL pcp_addr : STD_LOGIC_VECTOR(dprA_addr'left+2 DOWNTO 0);
		SIGNAL ap_addr : STD_LOGIC_VECTOR(dprB_addr'left+2 DOWNTO 0);
		
		--adder signals
		SIGNAL dprAsum : STD_LOGIC_VECTOR(dprA_addr'left+2 DOWNTO 0); --add one bit for sign
		SIGNAL dprAin1 : STD_LOGIC_VECTOR(dprA_addr'left+2 DOWNTO 0);
		SIGNAL dprAin2 : STD_LOGIC_VECTOR(dprA_addr'left+2 DOWNTO 0);
		SIGNAL dprBsum : STD_LOGIC_VECTOR(dprB_addr'left+2 DOWNTO 0); --add one bit for sign
		SIGNAL dprBin1 : STD_LOGIC_VECTOR(dprA_addr'left+2 DOWNTO 0);
		SIGNAL dprBin2 : STD_LOGIC_VECTOR(dprA_addr'left+2 DOWNTO 0);
		
	BEGIN
		--32bit addresses from Avalon converted into 8bit addresses
		pcp_addr <= pcp_address(pcp_addr'left-2 DOWNTO 0) & "00";
		ap_addr <= ap_address(ap_addr'left-2 DOWNTO 0) & "00";
		
		--DPR A
		---select base address
		dprAin1		<=	conv_std_logic_vector(iIntCtrlStatAddr_c-4, dprAin1'length)
										WHEN selDprACSBuf = '1' AND selConstA = '0' ELSE
						--base address of virtual TPDO buffer
						conv_std_logic_vector(iIntTxPdoBufAddr0_c, dprAin1'length)
										WHEN selDprATPBuf = '1' AND pcp_selTpdoBuf = b0 ELSE
						conv_std_logic_vector(iIntTxPdoBufAddr1_c, dprAin1'length)
										WHEN selDprATPBuf = '1' AND pcp_selTpdoBuf = b1 ELSE
						conv_std_logic_vector(iIntTxPdoBufAddr2_c, dprAin1'length)
										WHEN selDprATPBuf = '1' AND pcp_selTpdoBuf = b2 ELSE
						--base address of virtual RPDO buffer
						conv_std_logic_vector(iIntRxPdoBufAddr0_c, dprAin1'length)
										WHEN selDprARPBuf = '1' AND pcp_selRpdoBuf = b0 ELSE
						conv_std_logic_vector(iIntRxPdoBufAddr1_c, dprAin1'length)
										WHEN selDprARPBuf = '1' AND pcp_selRpdoBuf = b1 ELSE
						conv_std_logic_vector(iIntRxPdoBufAddr2_c, dprAin1'length)
										WHEN selDprARPBuf = '1' AND pcp_selRpdoBuf = b2 ELSE
						--base address of TPDO descriptor
						conv_std_logic_vector(iIntTxPdoDesAddr_c, dprAin1'length)
										WHEN selDprATPDes = '1' ELSE
						--base address of RPDO descriptor
						conv_std_logic_vector(iIntRxPdoDesAddr_c, dprAin1'length)
										WHEN selDprARPDes = '1' ELSE
						--base address of async TX buffer
						conv_std_logic_vector(iIntAsyTxBufAddr_c, dprAin1'length)
										WHEN selDprATABuf = '1' ELSE
						--base address of async RX buffer
						conv_std_logic_vector(iIntAsyRxBufAddr_c, dprAin1'length)
										WHEN selDprARABuf = '1' ELSE
						(others => '0');
		---get avalon's address
		dprAin2		<=	pcp_addr;
		---obtain dpr offset
		dprAsum		<=	dprAin1 + dprAin2;
		---assign dprA address
		dprA_addr	<=	dprAsum(dprAsum'left DOWNTO 2); --convert back to double word address
		
		--DPR B
		---select base address
		dprBin1		<=	conv_std_logic_vector(iIntCtrlStatAddr_c-4, dprBin1'length)
										WHEN selDprBCSBuf = '1' AND selConstB = '0' ELSE
						--base address of virtual TPDO buffer
						conv_std_logic_vector(iIntTxPdoBufAddr0_c, dprBin1'length)
										WHEN selDprBTPBuf = '1' AND ap_selTpdoBuf = b0 ELSE
						conv_std_logic_vector(iIntTxPdoBufAddr1_c, dprBin1'length)
										WHEN selDprBTPBuf = '1' AND ap_selTpdoBuf = b1 ELSE
						conv_std_logic_vector(iIntTxPdoBufAddr2_c, dprBin1'length)
										WHEN selDprBTPBuf = '1' AND ap_selTpdoBuf = b2 ELSE
						--base address of virtual RPDO buffer
						conv_std_logic_vector(iIntRxPdoBufAddr0_c, dprBin1'length)
										WHEN selDprBRPBuf = '1' AND ap_selRpdoBuf = b0 ELSE
						conv_std_logic_vector(iIntRxPdoBufAddr1_c, dprBin1'length)
										WHEN selDprBRPBuf = '1' AND ap_selRpdoBuf = b1 ELSE
						conv_std_logic_vector(iIntRxPdoBufAddr2_c, dprBin1'length)
										WHEN selDprBRPBuf = '1' AND ap_selRpdoBuf = b2 ELSE
						--base address of TPDO descriptor
						conv_std_logic_vector(iIntTxPdoDesAddr_c, dprBin1'length)
										WHEN selDprBTPDes = '1' ELSE
						--base address of RPDO descriptor
						conv_std_logic_vector(iIntRxPdoDesAddr_c, dprBin1'length)
										WHEN selDprBRPDes = '1' ELSE
						--base address of async TX buffer
						conv_std_logic_vector(iIntAsyTxBufAddr_c, dprBin1'length)
										WHEN selDprBTABuf = '1' ELSE
						--base address of async RX buffer
						conv_std_logic_vector(iIntAsyRxBufAddr_c, dprBin1'length)
										WHEN selDprBRABuf = '1' ELSE
						(others => '0');
		---get avalon's address
		dprBin2		<=	ap_addr;
		---obtain dpr offset
		dprBsum		<=	dprBin1 + dprBin2;
		---assign dprB address
		dprB_addr	<=	dprBsum(dprBsum'left DOWNTO 2); --convert back to double word address
		
	END BLOCK theAddressTranslator;
	
	theDpr : ENTITY work.cnApi_Av2Av_DPR
	GENERIC MAP
	(
		NUM_WORDS		=>		2**(iDprAddrWidth_g-2),
		LOG2_NUM_WORDS	=>		iDprAddrWidth_g-2
	)
	PORT MAP
	(
		address_a		=>		dprA_addr,
		address_b		=>		dprB_addr,
		byteena_a		=>		dprA_ben,
		byteena_b		=>		dprB_ben,
		clock_a			=>		pcp_Clk,
		clock_b			=>		ap_Clk,
		data_a			=>		dprA_din,
		data_b			=>		dprB_din,
		wren_a			=>		dprA_wr,
		wren_b			=>		dprB_wr,
		q_a				=>		dprA_dout,
		q_b				=>		dprB_dout
	);
	
	dprA_ben		<=	pcp_byteenable;
	dprA_wr			<=	'0'				WHEN pcp_write = '0' 	ELSE --gets zero if no write access
						'1'				WHEN selDprACSBuf = '1'	ELSE --gets here if write access
						'1'				WHEN selDprATPBuf = '1' ELSE
						'1'				WHEN selDprARPBuf = '1' ELSE
						'1'				WHEN selDprATPDes = '1' ELSE
						'1'				WHEN selDprARPDes = '1' ELSE
						'1'				WHEN selDprATABuf = '1' ELSE
						'1'				WHEN selDprARABuf = '1' ELSE
						'0'; --gets here if write but no dpr write
	
	dprB_ben		<=	ap_byteenable;
	dprB_wr			<=	'0'				WHEN ap_write = '0' 	ELSE --gets zero if no write access
						'1'				WHEN selDprBCSBuf = '1'	ELSE --gets here if write access
						'1'				WHEN selDprBTPBuf = '1' ELSE
						'1'				WHEN selDprBRPBuf = '1' ELSE
						'1'				WHEN selDprBTPDes = '1' ELSE
						'1'				WHEN selDprBRPDes = '1' ELSE
						'1'				WHEN selDprBTABuf = '1' ELSE
						'1'				WHEN selDprBRABuf = '1' ELSE
						'0'; --gets here if write but no dpr write
						
	dprA_din		<=	pcp_writedata;
	pcp_readdata	<=	constA_dout		WHEN selConstA = '1' 	ELSE
						dprA_dout		WHEN selDprACSBuf = '1'	ELSE
						dprA_dout		WHEN selDprATPBuf = '1' ELSE
						dprA_dout		WHEN selDprARPBuf = '1' ELSE
						dprA_dout		WHEN selDprATPDes = '1' ELSE
						dprA_dout		WHEN selDprARPDes = '1' ELSE
						dprA_dout		WHEN selDprATABuf = '1' ELSE
						dprA_dout		WHEN selDprARABuf = '1' ELSE
						x"DEADC0DE";
	
	dprB_din		<=	ap_writedata;
	ap_readdata		<=	constB_dout		WHEN selConstB = '1' 	ELSE
						dprB_dout		WHEN selDprBCSBuf = '1'	ELSE
						dprB_dout		WHEN selDprBTPBuf = '1' ELSE
						dprB_dout		WHEN selDprBRPBuf = '1' ELSE
						dprB_dout		WHEN selDprBTPDes = '1' ELSE
						dprB_dout		WHEN selDprBRPDes = '1' ELSE
						dprB_dout		WHEN selDprBTABuf = '1' ELSE
						dprB_dout		WHEN selDprBRABuf = '1' ELSE
						x"DEADC0DE";
	
	thePcpMemoryMapping : BLOCK
	--includes SIGNAL output to avalon bus, buffer switch over triggered by avalon bus and irq
		SIGNAL pcp_irq_eventL : STD_LOGIC;
		SIGNAL pcp_irq_s : STD_LOGIC; --internal signal to read back
	BEGIN
		process(pcp_Clk)
		begin
			if pcp_Clk = '1' and pcp_Clk'event then
				if pcp_Reset = '1' then
					pcp_trigRpdoBufChange <= '0';
					pcp_trigTpdoBufChange <= '0';
					pcp_irq_eventL <= '0';
					pcp_irq_s <= '0';
				else
					case conv_integer(pcp_address) is
						when 16#00# =>
							constA_dout <=	conv_std_logic_vector(MagicNumber_c, 32);
						when 16#04# =>
							constA_dout <= conv_std_logic_vector(iTxPdoBufAddr_c, 16) & conv_std_logic_vector(iTxPdoBufSpan_c, 16);
						when 16#05# =>
							constA_dout <= conv_std_logic_vector(iRxPdoBufAddr_c, 16) & conv_std_logic_vector(iRxPdoBufSpan_c, 16);
						when 16#06# =>
							constA_dout <= conv_std_logic_vector(iTxPdoDesAddr_c, 16) & conv_std_logic_vector(iTxPdoDesSpan_c, 16);
						when 16#07# =>
							constA_dout <= conv_std_logic_vector(iRxPdoDesAddr_c, 16) & conv_std_logic_vector(iRxPdoDesSpan_c, 16);
						when 16#08# =>
							constA_dout <= conv_std_logic_vector(iAsyTxBufAddr_c, 16) & conv_std_logic_vector(iAsyTxBufSpan_c, 16);
						when 16#09# =>
							constA_dout <= conv_std_logic_vector(iAsyRxBufAddr_c, 16) & conv_std_logic_vector(iAsyRxBufSpan_c, 16);
						when 16#0A# =>
							constA_dout <= pcp_selTpdo;
						when 16#0B# =>
							constA_dout <= pcp_selRpdo;
						when 16#0C# =>
							constA_dout <= (others => pcp_irq_s);
						when others =>
							constA_dout <= x"DEADC0DE";
					end case;
					
					--memory map write to Rpdo trigger buffer change
					pcp_trigRpdoBufChange <= '0';
					if selConstA = '1' and pcp_write = '1' and conv_integer(pcp_address) = 16#0B# then
						pcp_trigRpdoBufChange <= '1';
					end if;
					--memory map write to Tpdo trigger buffer change
					pcp_trigTpdoBufChange <= '0';
					if selConstA = '1' and pcp_write = '1' and conv_integer(pcp_address) = 16#0A# then
						pcp_trigTpdoBufChange <= '1';
					end if;
				end if;
			end if;
		end process;
		
	END BLOCK thePcpMemoryMapping;
	
	theApMemoryMapping : BLOCK
	--includes SIGNAL output to avalon bus, buffer switch over triggered by avalon bus and irq
	-- irq event comes from other clk domain => sync with two flip flops (L and LL) and egde detection (LL and LLL)
		SIGNAL ap_irq_eventL : STD_LOGIC;
		SIGNAL ap_irq_eventLL : STD_LOGIC;
		SIGNAL ap_irq_eventLLL : STD_LOGIC;
		SIGNAL ap_irq_s : STD_LOGIC; --internal signal to read back
	BEGIN
		process(ap_Clk)
		begin
			if ap_Clk = '1' and ap_Clk'event then
				if ap_Reset = '1' then
					ap_trigRpdoBufChange <= '0';
					ap_trigTpdoBufChange <= '0';
					ap_irq_eventL <= '0';
					ap_irq_eventLL <= '0';
					ap_irq_eventLLL <= '0';
					ap_irq_s <= '0';
				else
					case conv_integer(ap_address) is
						when 16#00# =>
							constB_dout <=	conv_std_logic_vector(MagicNumber_c, 32);
						when 16#04# =>
							constB_dout <= conv_std_logic_vector(iTxPdoBufAddr_c, 16) & conv_std_logic_vector(iTxPdoBufSpan_c, 16);
						when 16#05# =>
							constB_dout <= conv_std_logic_vector(iRxPdoBufAddr_c, 16) & conv_std_logic_vector(iRxPdoBufSpan_c, 16);
						when 16#06#  =>
							constB_dout <= conv_std_logic_vector(iTxPdoDesAddr_c, 16) & conv_std_logic_vector(iTxPdoDesSpan_c, 16);
						when 16#07# =>
							constB_dout <= conv_std_logic_vector(iRxPdoDesAddr_c, 16) & conv_std_logic_vector(iRxPdoDesSpan_c, 16);
						when 16#08# =>
							constB_dout <= conv_std_logic_vector(iAsyTxBufAddr_c, 16) & conv_std_logic_vector(iAsyTxBufSpan_c, 16);
						when 16#09# =>
							constB_dout <= conv_std_logic_vector(iAsyRxBufAddr_c, 16) & conv_std_logic_vector(iAsyRxBufSpan_c, 16);
						when 16#0A# =>
							constB_dout <= ap_selTpdo;
						when 16#0B# =>
							constB_dout <= ap_selRpdo;
						when 16#0C# =>
							constB_dout <= (others => ap_irq_s);
						when others =>
							constB_dout <= x"DEADC0DE";
					end case;
					
					--memory map write to Rpdo trigger buffer change
					if selConstB = '1' and ap_write = '1' and conv_integer(ap_address) = 16#0B# then
						ap_trigRpdoBufChange <= not ap_trigRpdoBufChange;
					end if;
					--memory map write to Rpdo trigger buffer change
					if selConstB = '1' and ap_write = '1' and conv_integer(ap_address) = 16#0A# then
						ap_trigTpdoBufChange <= not ap_trigTpdoBufChange;
					end if;
				end if;
			end if;
		end process;
	END BLOCK theApMemoryMapping;
	

END ARCHITECTURE rtl;
