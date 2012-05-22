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
fpga                FPGA projects
fpga/altera/IP-core POWERLINK IP cores
libCnApi            openPOWERLINK CN API SW library (= "PCP driver") provided for the AP
objDicts            Example object dictionary files for openPOWERLINK (PCP) and
                    corresponding XDD file for Automation Studio import
powerlink           Example openPOWERLINK applications (PCP)
                    also contains the openPOWERLINK stack
tools               additional tools e.g. for firmware upgrade                

Reference Boards
------------------  

    1. Terasic DE2-115 (INK) Board

        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         PCP with Application Processor (AP) 
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        - FPGA Internal Avalon Interface
          * Quartus:        fpga/altera/TERASIC_DE2-115/ink_ap_pcp_intavalon
          * AP software:    apps/ap_PDI
          * PCP software:   powerlink/pcp_PDI
          
          The design includes two NIOS II CPUs, one for processing openPOWERLINK and the other for
          processing the application. A dual ported RAM (DPRAM) serves as communication interface
          between them. One part of this DPRAM is used for channeling PDOs.
          One TPDO, and 3 RPDOs are supported.
        
        - SPI Interface
          * Quartus:        fpga/altera/TERASIC_DE2-115/ink_ap_pcp_SPI
          * AP software:    apps/ap_PDI
          * PCP software:   powerlink/pcp_PDI
          
          Same design as above, but uses and external SPI interface for DPRAM access. The AP has an SPI master,
          the PCP is a SPI slave. The connection between them takes place at the INK evaluation board with jumpers
          by connecting some JP 5 pins like shown in "User_Guide_Altera".
          0-1, 2-3, 4-5, 6-7, 8-9.
          The last jumper is for the synchronization IR, and is not necessary when using polling mode.
            
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
            
    2. Other Boards TBD   
