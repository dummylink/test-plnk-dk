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

- POWERLINK SW for PCP (Powerlink Communication Processor).

3. Performance
-------------------
- Minimum cycle length: optimization dependent
- PReq-PRes Latency: 1 µs
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
  
4. SW Build Proporties
-------------------
4.1 Build Options
    - [1] debug: Has the most debug information. Additional printouts can be
                 enabled by modifying "DEF_DEBUG_LVL" in "create-this-app".
    - [2] debug with reduced printouts: Has only basic debug information.
    - [3] release: Compiles with best optimization concerning processing time
                   and disables all printf-outputs. Use this option for the
                   final product.
                 
4.2 FPGA Onchip Memory Requirements
    - The build options [1] and [2] do not require special FPGA memory
      for the program code.
    - The build option "[3] release" requires at least 3460 Byte
      tightly-coupled-instruction memory, because certain functions are put
      into this memory.  


5. Requirements
---------------
- Development Boards

  * TERASIC DE2-115 (INK Board)

- Altera Quartus II v10.1 SP1 (Web Edition is also possible)

- Altera Nios II Embedded Design Suite v10.1 SP1 or newer

- Experiences with this development environment are required

- POWERLINK network with Configuration Manager.
  The corresponding XDD for this node can be found in the subdirectory
  ObjDicts\Direct_IO.

 
6.Configuration
----------------
Miscellaneous parameters of the openPOWERLINK stack and the PCP application
can be configured through defines in EplCfg.h. The following section contains
a description of those parameters.

6.1 Firmware Update and Remote configuration
  The PCP contains support for a safe firmware update feature through POWERLINK.
  The following options could be configured

  CONFIG_FACTORY_IIB_FLASH_ADRS
    Specifies at which address in flash memory the Factory Image Information
    Block(IIB) is located.

  CONFIG_USER_IIB_FLASH_ADRS
    Specifies at which address in flash memory the User Image Information
    Block(IIB) is located.

  CONFIG_USER_IMAGE_FLASH_ADRS
    The address in flash memory where the user image is located.

  CONFIG_USER_IIB_VERSION
    The version of the used IIB.

  CONFIG_DISABLE_WATCHDOG
    Disable watchdog provided by the remote update core.

  CONFIG_USER_IMAGE_IN_FLASH
    Specifies if a user image is located in flash. Should be disabled if
    image is loaded through JTAG interface for development.


7. How to run the demo
----------------------

For Windows:

1. Browse to the directory of your desired Quartus reference design and read the contained
   "readme.txt". You may take some previous action e.g. rebuild the reference design. 
    
2. Click on "rebuild.bat"

3. Choose the desired platform and design by entering a number

4. A bash script will be invoked, which rebuild the SW.

5. Click on "run.bat" - the HW configuration and the PCP SW will be downloaded to the FPGA

6. Enjoy the terminal outputs and the running POWERLINK network.