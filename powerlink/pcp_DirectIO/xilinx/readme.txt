------------------------------------------------------------------------------
POWERLINK CN Development Kit (CNDK)
------------------------------------------------------------------------------
(C) Bernecker + Rainer, B & R Strasse 1, 5142 Eggelsberg, Austria
------------------------------------------------------------------------------

Software Demo for PCP (Powerlink Communication Processor)
with Direct IO Interface
==============================================================================

1. Introduction
---------------
This demo implements the software for a Powerlink Communication Processor (PCP).
The PCP contains all Powerlink functionality of a POWERLINK CN node. It is
designed to be connected to devices through digital I/Os.

2. Contents
---------

- POWERLINK SW for DirectIO

3. Performance
-------------------
- Minimum cycle length: optimization dependent
- PReq-PRes Latency: 1 µs
- Process data: 4 bytes input and 4 bytes output
- There are 3 RPDOs and 1 TPDO available.
- The following 8 objects - each has the size 1 Byte - can be mapped:

  6000/01: not in use
  6000/02: not in use
  6000/03: not in use
  6000/04: not in use

  6200/01: digital output (LEDs)
  6200/02: not in use
  6200/03: not in use
  6200/04: not in use


4. Requirements
---------------
- Development Boards

  * Avnet Spartan-6 lx16 - Powerlink Evaluation Board (s6plkeb)
  * Avnet Spartan-6 lx150t - Industrial Ethernet Kit (IEK)
  * Avnet Spartan-6 lx9 - MicroBoard

- Xilinx ISE Design Suite 13.2

- Experiences with this development environment are required

- POWERLINK network with Configuration Manager.
  The corresponding XDD for this node can be found in the subdirectory
  ObjDicts\Direct_IO.


5.Configuration
----------------
Miscellaneous parameters of the openPOWERLINK stack and the PCP application
can be configured through defines in EplCfg.h.


6. How to run the demo
----------------------

A detailed description is available in the "User_Guide_Xilinx.pdf" document.

For Windows:

1. Open Xilinx Platform Studio (XPS) set the path to the powerlink IP-Core.
    Edit -> Preferences -> Application -> Global Peripheral Repository Search Path
    (e.g: C:\BR_POWERLINK-SLAVE_XILINX_VX.X.X\02_Reference_Sources\fpga\xilinx\ipcore)

2. Open a design from the FPGA directory (e.g: C:\BR_POWERLINK-SLAVE_XILINX_VX.X.X\02_Reference_Sources\fpga\xilinx\)
   and compile it. (Generate Bitstream)

3. Export the design to the SDK_Export directory (Export Hardware Design to SDK) without launching SDK.

4. Open the Xilinx Software Development Kit (SDK) with workspace on the CNDK root directory.
   (e.g: C:\BR_POWERLINK-SLAVE_XILINX_VX.X.X\02_Reference_Sources)

5. Create a "Hardware Platform" (e.g: hw_platform_lx150t_directIO) and a "Board Support Package"
   (e.g: standalone_bsp_lx150t_directIO) for your compiled FPGA design and your processor.

6. Import the pcp_DirectIO project into the SDK by using Import -> General -> Existing Project into Workspace.
   Set the root directory to search for to the CNDK root directory
   (e.g: C:\BR_POWERLINK-SLAVE_XILINX_VX.X.X\02_Reference_Sources) and select the found
   project pcp_DirectIO for import.

7. Adapt the file makefile.settings according to your needs.

8. Change the Referenced BSP to point to your previously created "Board Support Package"
   (e.g: standalone_bsp_lx150t_directIO).

9. Your pcp_DirectIO.elf should be compiled and linked by the SDK.

10. Download the bitstream with Xilinx Tools -> Program FPGA and download the .elf file with Run As -> Run on Hardware.

11. The printed output of the processor can be viewed by using a terminal program (tera term) or by using the built in SDK program.

12. Enjoy the terminal outputs and the running POWERLINK network.

