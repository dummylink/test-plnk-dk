------------------------------------------------------------------------------
POWERLINK CN Development Kit (CNDK)
------------------------------------------------------------------------------
(C) Bernecker + Rainer, B & R Strasse 1, 5142 Eggelsberg, Austria
------------------------------------------------------------------------------

Software Demo for PCP (Powerlink Communication Processor)
with SPI/Parallel or internal FPGA Interface
==============================================================================

1. Introduction
---------------
This demo implements the software for a Powerlink Communication Processor (PCP).
The PCP contains all Powerlink functionality of a POWERLINK CN node. It is
designed to be connected to an Application Processor (AP) which contains the
application code. The AP can be implemented on a second Microblaze processor in the
same FPGA as the PCP or on an external microprocessor connected to the PCP
through a SPI or parallel interface.


2. Performance
-------------------
- Minimum cycle length: optimization dependent
- PReq-PRes Latency: 1 µs
- Process data: 4 bytes input and 4 bytes output
- There are 3 RPDOs and 1 TPDO available.


3. Requirements
---------------
- Development Boards

  * Avnet Spartan-6 lx16 - Powerlink Evaluation Board (s6plkeb)
  * Avnet Spartan-6 lx150t - Industrial Ethernet Kit (IEK)
  * Avnet Spartan-6 lx9 - MicroBoard

- Xilinx ISE Design Suite 13.2

- Experiences with this development environment are required

- POWERLINK network with Configuration Manager.
  The corresponding XDD for this node can be found in the subdirectory
  ObjDicts\PDI.


4.Configuration
----------------
Miscellaneous parameters of the openPOWERLINK stack and the PCP application
can be configured through defines in EplCfg.h. 

5. How to run the demo
----------------------

A detailed description is available in the "User_Guide_Xilinx.pdf" document.

For Windows:

1. Open Xilinx Platform Studio (XPS) set the path to the powerlink IP-Core.
    Edit -> Preferences -> Application -> Global Peripheral Repository Search Path (e.g: C:\openPOWERLINK_CNDK\fpga\xilinx\IP-Core)
     
2. Open a aesign from the FPGA directory (e.g: C:\openPOWERLINK_CNDK\fpga\xilinx\) and compile it. (Generate Bitstream)

3. Export the design to the SDK_Export directory (Export Hardware Design to SDK) without launching SDK.
    
4. Open the Xilinx Software Development Kit (SDK) with workspace on the CNDK root directory. (e.g: C:\openPOWERLINK_CNDK\)

5. Create a "Hardware Platform" (e.g: hw_platform_lx150t_intplb) and a "Board Support Package" (e.g: standalone_bsp_lx150t_intplb_pcp) 
   for your compiled FPGA design and your processor.

6. Import the pcp_PDI project into the SDK by using Import -> C/C++ -> Existing Code as Makefile Project.
   Give a Project name, existing code location (e.g: C:\openPOWERLINK_CNDK\powerlink\pcp_PDI), select C for your language 
   and use the "Xilinx Microblaze GNU Toolchain".

7. Adapt the file makefile.settings according to your needs.

8. Change the Referenced BSP to point to your previously created "Board Support Package" (e.g: standalone_bsp_lx150t_intplb_pcp).

9. Your pcp_PDI.elf should be compiled and linked by the SDK.

10. Download the bitstream with Xilinx Tools -> Program FPGA and download the .elf file with Run As -> Run on Hardware.

11. Compile the libCnApi library and the ap_PDI program by using the readme.txt files in the corresponding diretories.
    Download the ap_PDI program to the AP processor. (Run As -> Run on Hardware)

12. The printed output of the processor can be viewed by using a terminal program (tera term) or by using the built in SDK program.

13. Enjoy the terminal outputs and the running POWERLINK network.

For Linux:

Should be very similar to the windows way.
