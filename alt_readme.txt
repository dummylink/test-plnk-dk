------------------------------------------------------------------------------
POWERLINK CN Development Kit (CNDK)
------------------------------------------------------------------------------
(C) Bernecker + Rainer, B & R Strasse 1, 5142 Eggelsberg, Austria
------------------------------------------------------------------------------

Reference Designs
==============================================================================

Directory Structure
--------------------
apps                Example user applications (AP)
common              Consists of source code used by both processors (PCP and AP)
fpga                FPGA projects
fpga/xilinx/ipcore  POWERLINK IP-cores
libCnApi            POWERLINK CN API SW library (= "PCP driver") provided for the AP
objDicts            Example object dictionary files for POWERLINK (PCP) and
                    corresponding XDD file for Automation Studio import
powerlink           Example POWERLINK applications (PCP)
                    also contains the POWERLINK stack
tools               additional tools e.g. for firmware upgrade

Reference Boards
------------------  

    1. Terasic DE2-115 (INK) Board

        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         PCP with Application Processor (AP) 
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        - FPGA Internal Avalon Interface AP + PCP
          * Quartus:        fpga/altera/TERASIC_DE2-115/ink_ap_pcp_intavalon
          * AP software:    apps/ap_PDI
          * PCP software:   powerlink/pcp_PDI
          
          The design includes two NIOS II CPUs, one for processing POWERLINK and the other for
          processing the application (AP). A dual ported RAM (DPRAM) serves as communication interface
          between them. One part of this DPRAM is used for channeling PDOs.
          One TPDO, and 3 RPDOs are supported.
          
        - 16bit parallel Interface PCP only

          * Quartus:        fpga/altera/TERASIC_DE2/ink_pcp_16bitprll
          * PCP software:   powerlink/pcp_PDI
          
          Same design as obove, but uses the external 16bit parallel interface for DPRAM access.
          No AP is included - the AP can accees the DPRAM over the external interface by connecting to the
          JP 5 pins like shown in "User_Guide_Altera".
        
        - 16bit parallel Interface AP only

          * Quartus:        fpga/altera/TERASIC_DE2/ink_ap_16bitprll
          * AP software:    apps/ap_PDI
          
          This desing can be used as an AP reference desing to access the "16bit parallel Interface PCP only"
          if you have 2 Terasic DE2-115 boards available. The connection is very simple in this case:
          All JP5 pins except the Vcc pins have to be connected one by one.

        - SPI Interface AP + PCP
          * Quartus:        fpga/altera/TERASIC_DE2-115/ink_ap_pcp_SPI
          * AP software:    apps/ap_PDI
          * PCP software:   powerlink/pcp_PDI

          Same design as "FPGA Internal Avalon Interface AP + PCP", but uses and external SPI interface for DPRAM access.
          The AP has an SPI master, the PCP is a SPI slave. The connection between them takes place at the INK evaluation
          board with jumpers by connecting some JP 5 pins like shown in "User_Guide_Altera": 0-1, 2-3, 4-5, 6-7, 8-9.
          The last jumper is for the synchronization IR, and is not necessary when using polling mode.

         It is also possible to have the same example as separate Quartus desings (and hardware platforms) for 2 INK boards
         (with the same connection pins as the joint design):
         
          * PCP only Quartus:   fpga/altera/TERASIC_DE2-115/ink_pcp_SPI
          * AP only Quartus:    fpga/altera/TERASIC_DE2-115/ink_ap_SPImaster

            
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         PCP standalone
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        - Direct IO
          * Quartus:        fpga/altera/TERASIC_DE2-115/ink_pcp_DirectIO
          * PCP software:   powerlink/pcp_DirectIO       
                
            The design offers 32 latched digital IO pins, grouped in 4 * 8 pins with a latch signal for each group.
            According to the level of the direction configuration pins, each group can be configured as input or output.
            A latch signal determines when the data is being sampled (input) or when the data has been updated (output).
            Therefore DAC's or ADC's might use these latch signals in order to avoid corrupted data.
            See also "User_Guide_Altera" for details.
            
    2. Arrow BeMicro RTE

        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         PCP standalone
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        - Direct IO
          * Quartus:        fpga/altera/BeMicro/bm_pcp_DirectIO
          * PCP software:   powerlink/pcp_DirectIO       
                
            The design offers 32 latched digital IO pins, grouped in 4 * 8 pins with a latch signal for each group.
            According to the level of the direction configuration pins, each group can be configured as input or output.
            A latch signal determines when the data is being sampled (input) or when the data has been updated (output).
            Therefore DAC's or ADC's might use these latch signals in order to avoid corrupted data.
            See also "User_Guide_Altera" for details.

