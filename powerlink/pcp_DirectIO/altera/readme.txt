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
  6000/03: digital input (buttons and switches) -> meant for TPDO
  6000/04: not in use

  6200/01: digital output (LEDs) -> meant for RPDO
  6200/02: digital output (LEDs) -> meant for RPDO
  6200/03: not in use
  6200/04: digital output (Hex Digits) -> meant for RPDO

- Software footprint is apprx.: Code+Data=273 KByte, Heap=113 KByte, Stack=50 KByte
                                => 336 KByte (rough estimation)

SW Build Proporties
-------------------
1. Build Options
    - [1] debug: Has the most debug information. Additional printouts can be
                 enabled by modifying "DEF_DEBUG_LVL" in "create-this-app".
    - [2] debug with reduced printouts: Has only basic debug information.
    - [3] release: Compiles with best optimization concerning processing time
                   and disables all printf-outputs. Use this option for the
                   final product.
                 
2. FPGA Onchip Memory Requirements
    - The build options [1] and [2] do not require special FPGA memory
      for the program code.
    - The build option "[3] release" requires at least 4 kByte
      tightly-coupled-instruction memory, because certain functions are put
      into this memory.  


Requirements
---------------
- Development Boards

  * TERASIC DE2-115 (INK Board)

- Altera Quartus II v10.1 SP1 (Web Edition is also possible)

- Altera Nios II Embedded Design Suite v10.1 SP1 or newer

- Experience with this development environment is required

Configuration
----------------
Miscellaneous parameters of the openPOWERLINK stack and the PCP application
can be configured through defines in EplCfg.h.

The network can be configured by using the corresponding XDD and objdict.h for this node
which can be found in the subdirectory objDicts\Direct_IO.

How to run the demo
----------------------
A detailed description is available in the "MAN_OAT113110_10_Vxxx - Getting Started.pdf" document.

Build flow for Windows:

1. You may take some previous action e.g. rebuild the Quartus project.
   Therefore go to your desired Quartus reference design in
   fpga/altera/<evalboard>/<reference design>/
   and read the contained "readme.txt". 

2. Click on "rebuild.bat"

3. Choose the desired platform and design by entering a number

4. You will be asked if the Quartus desing should be generated from command line - without
   opening the Quartus toolchain manually.

5. Choose the desired build option (refer to "SW Build Proporties" above)

6. A bash script will be invoked, which rebuilds the SW.

7. Install the driver and etablish the connection of your USB-Blaster if not done yet,
   according to your evaluation board manual.

8. Click on "run.bat" - the HW configuration and the PCP SW will be downloaded to the FPGA

9. Enjoy the terminal outputs and the running POWERLINK network.


