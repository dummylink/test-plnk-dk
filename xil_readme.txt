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

    1. Avnet Spartan-6 lx16 - Powerlink Evaluation Board (s6plkeb)

        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Dual Processor - PCP with Application Processor (AP)
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        - FPGA Internal PLB/AXI Interface
          * XPS Project:    fpga/xilinx/Avnet_s6plkeb/s6plkeb_ap_pcp_intplb-[plb,axi]
          * AP software:    apps/ap_PDI
          * PCP software:   powerlink/pcp_PDI

          The design includes two microblaze processors, one for processing POWERLINK (PCP) and the other for
          processing the application (AP). A dual ported RAM called Process Data Interface (PDI) serves as
          communication interface between them. One part of this DPRAM is used for channeling PDOs.
          One TPDO, and 3 RPDOs are supported.

        - 16bit parallel Interface
          * XPS Project:    fpga/xilinx/Avnet_s6plkeb/s6plkeb_pcp_16bitprll-axi
          * AP software:    apps/ap_PDI
          * PCP software:   powerlink/pcp_PDI

          Same design as obove, but uses the external 16bit parallel interface for DPRAM access.
          The AP has an external memory controler (emc) master in order to read/write to the DPRAM.

        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Single Processor - PCP standalone
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        - Direct IO
          * XPS Project:    fpga/xilinx/Avnet_s6plkeb/s6plkeb_pcp_DirectIO-[plb,axi]
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

          The design includes two microblaze processors, one for processing POWERLINK and the other for
          processing the application. A dual ported RAM called Process Data Interface (PDI) serves as
          communication interface between them. One part of this DPRAM is used for channeling PDOs.
          One TPDO, and 3 RPDOs are supported.

        - SPI Interface
          * XPS Project:    fpga/xilinx/Avnet_lx150t/iek_ap_pcp_SPI-plb
          * AP software:    apps/ap_PDI
          * PCP software:   powerlink/pcp_PDI

          Same design as obove, but uses an external SPI interface for DPRAM access. The AP has an SPI master,
          the PCP is a SPI slave. Due to a lack of GPIO pins both processors are connected inside the FPGA.

        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Single Processor - PCP standalone
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        - Direct IO
          * XPS Project:    fpga/xilinx/Avnet_lx150t/iek_pcp_DirectIO-[plb,axi]
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
