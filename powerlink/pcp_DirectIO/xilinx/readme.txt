------------------------------------------------------------------------------
POWERLINK CN Development Kit (CNDK)
------------------------------------------------------------------------------
(C) Bernecker + Rainer, B & R Strasse 1, 5142 Eggelsberg, Austria
------------------------------------------------------------------------------

Software Demo for PCP (Powerlink Communication Processor)
with Direct IO Interface
==============================================================================

Introduction
---------------
This demo implements the software for a POWERLINK Communication Processor (PCP).
The PCP is designed to be connected to devices through Digital I/Os.


Contents
---------
- POWERLINK SW for PCP (Powerlink Communication Processor)


Properties
-------------------
- Minimum cycle length: 400µs (depends on configuration e.g. optimization level)
- PReq-PRes Latency: 960ns
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

- Software footprint for release is apprx.:
               Code+Data=206 KByte, Heap=140 KByte, Stack=50 KByte
               => 396 KByte (rough estimation)
  (Measured with -O3, DBG_MODE=NDEBUG, RX packets external, TX in BRAM)

- Software footprint for debug is apprx.:
               Code+Data=306 KByte, Heap=140 KByte, Stack=50 KByte
               => 496 KByte (rough estimation)
  (Measured with -O0, DBG_MODE=_DEBUG, RX packets external, TX in BRAM)

Requirements
---------------
- Development Boards

  * Avnet Spartan-6 lx16 - Powerlink Evaluation Board (s6plkeb)
  * Avnet Spartan-6 lx150t - Industrial Ethernet Kit (IEK)
  * Avnet Spartan-6 lx9 - MicroBoard

- Xilinx ISE Design Suite 13.2

- Experience with this development environment is required

Configuration
----------------
Miscellaneous parameters of the openPOWERLINK stack and the PCP application
can be configured through defines in EplCfg.h.

The network can be configured by using the corresponding XDD and objdict.h for this node
which can be found in the subdirectory objDicts\Direct_IO.

How to run the demo
----------------------
A detailed description is available in the "MAN_OAT113110_11_Vxxx - Getting Started.pdf" document.

Build flow for Windows:

1. Open Xilinx Platform Studio (XPS) set the path to the POWERLINK IP-core.
    Edit -> Preferences -> Application -> Global Peripheral Repository Search Path
    (e.g: C:\BR_POWERLINK-SLAVE_XILINX_VX.X.X\02_Reference_Sources\fpga\xilinx\ipcore)

2. If you don't want to build the FPGA configuration you can use the precompiled bitstream
   in this package and continue with step 5.

3. To build the FPGA configuration, open a design from the FPGA directory
  (e.g: C:\BR_POWERLINK-SLAVE_XILINX_VX.X.X\02_Reference_Sources\fpga\xilinx\) and build it. (Generate Bitstream)

4. Export the design to the SDK_Export directory (Export Hardware Design to SDK) without launching SDK.

5. Open the Xilinx Software Development Kit (SDK) with workspace on the CNDK root directory.
   (e.g: C:\BR_POWERLINK-SLAVE_XILINX_VX.X.X\02_Reference_Sources)

6. Create a "Hardware Platform" (e.g: hw_platform_lx150t_directIO) and a "Board Support Package"
   (e.g: standalone_bsp_lx150t_directIO) for your compiled FPGA design and your processor.

7. Import the pcp_DirectIO project into the SDK by using Import -> General -> Existing Project into Workspace.
   Set the root directory to search for to the CNDK root directory
   (e.g: C:\BR_POWERLINK-SLAVE_XILINX_VX.X.X\02_Reference_Sources) and select the found
   project pcp_DirectIO for import.

8. Adapt the file makefile.settings according to your needs.

9. Change the Referenced BSP to point to your previously created "Board Support Package"
   (e.g: standalone_bsp_lx150t_directIO).

10. Your pcp_DirectIO.elf should be compiled and linked by the SDK.

11. Download the bitstream with Xilinx Tools -> Program FPGA and download the .elf file with Run As -> Run on Hardware.

12. The printed output of the processor can be viewed by using a terminal program (tera term) or by using the built in SDK program.

13. Enjoy the terminal outputs and the running POWERLINK network.

