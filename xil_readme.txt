------------------------------------------------------------------------------
POWERLINK CN Development Kit (CNDK) - Xilinx 
------------------------------------------------------------------------------
(C) Bernecker + Rainer, B & R Strasse 1, 5142 Eggelsberg, Austria
------------------------------------------------------------------------------

Reference Designs
==============================================================================

Directory Structure
-------------------- 
apps                Example user applications (AP)
fpga                FPGA projects
fpga/xilinx/IP-core POWERLINK IP-Cores for PLB and AXI bus
libCnApi            openPOWERLINK CN API SW library (= "PCP driver") provided for the AP
objDicts            Example object dictionary files for openPOWERLINK (PCP) and
                    corresponding XDD file for Automation Studio import
powerlink           Example openPOWERLINK applications (PCP)
                    also contains the openPOWERLINK stack
tools               additional tools e.g. for firmware upgrade                

Reference Boards
------------------  

    1. Avnet Spartan-6 lx16 - Powerlink Evaluation Board (s6plkeb)
    
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Dual Processor - PCP with Application Processor (AP) 
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        - FPGA Internal PLB/AXI Interface
          * XPS Project:    fpga/xilinx/Avnet_s6plkeb/s6plkeb_ap_pcp_intplb-plb
          * AP software:    apps/ap_PDI
          * PCP software:   powerlink/pcp_PDI
          
          The design includes two micrblaze processors, one for processing openPOWERLINK and the other for
          processing the application. A dual ported RAM called Process Data Interface (PDI) serves as 
          communication interface between them. One part of this DPRAM is used for channeling PDOs.
          One TPDO, and 3 RPDOs are supported.
        
        - SPI Interface
          * XPS Project:    fpga/xilinx/Avnet_s6plkeb/s6plkeb_ap_pcp_SPI-plb
          * AP software:    apps/ap_PDI
          * PCP software:   powerlink/pcp_PDI
          
          Same design as obove, but uses and external SPI interface for DPRAM access. The AP has an SPI master,
          the PCP is a SPI slave. Both processors are connected inside the FPGA by using SPI.
            
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Single Processor - PCP standalone
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        - Direct IO
          * XPS Project:    fpga/xilinx/Avnet_s6plkeb/s6plkeb_pcp_DirectIO-plb
          * PCP software:   powerlink/pcp_DirectIO       
                
           The design offers 32 latched digital IO pins, grouped in 4 * 8 pins with a latch signal for each group.
           According to the level of the direction configuration pins, each group can be configured as input or output.
           A latch signal determines when the data is being sampled (input) or when the data has been updated (output).
           Therefore DAC's or ADC's might use these latch signals in order to avoid corrupted data.

    2. Avnet Spartan-6 lx150t - Industrial Ethernet Kit (IEK)

        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Dual Processor - PCP with Application Processor (AP) 
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
        - FPGA Internal PLB/AXI Interface
          * XPS Project:    fpga/xilinx/Avnet_lx150t/iek_ap_pcp_intplb-[plb,axi]
          * AP software:    apps/ap_PDI
          * PCP software:   powerlink/pcp_PDI
          
          The design includes two micrblaze processors, one for processing openPOWERLINK and the other for
          processing the application. A dual ported RAM called Process Data Interface (PDI) serves as 
          communication interface between them. One part of this DPRAM is used for channeling PDOs.
          One TPDO, and 3 RPDOs are supported.
        
        - SPI Interface
          * XPS Project:    fpga/xilinx/Avnet_lx150t/iek_ap_pcp_SPI-plb
          * AP software:    apps/ap_PDI
          * PCP software:   powerlink/pcp_PDI
          
          Same design as obove, but uses and external SPI interface for DPRAM access. The AP has an SPI master,
          the PCP is a SPI slave. Both processors are connected inside the FPGA by using SPI.
            
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Single Processor - PCP standalone
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        - Direct IO
          * XPS Project:    fpga/xilinx/Avnet_lx150t/iek_pcp_DirectIO-plb
          * PCP software:   powerlink/pcp_DirectIO       
                
           The design offers 32 latched digital IO pins, grouped in 4 * 8 pins with a latch signal for each group.
           According to the level of the direction configuration pins, each group can be configured as input or output.
           A latch signal determines when the data is being sampled (input) or when the data has been updated (output).
           Therefore DAC's or ADC's might use these latch signals in order to avoid corrupted data.
            
    3. Avnet Spartan-6 lx9 - MicroBoard
    
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Single Processor - PCP standalone
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        - Direct IO
          * XPS Project:    fpga/xilinx/Avnet_lx9t/micro_pcp_DirectIO-[plb,axi]
          * PCP software:   powerlink/pcp_DirectIO       
                
           The design offers 32 latched digital IO pins, grouped in 4 * 8 pins with a latch signal for each group.
           According to the level of the direction configuration pins, each group can be configured as input or output.
           A latch signal determines when the data is being sampled (input) or when the data has been updated (output).
           Therefore DAC's or ADC's might use these latch signals in order to avoid corrupted data.    
