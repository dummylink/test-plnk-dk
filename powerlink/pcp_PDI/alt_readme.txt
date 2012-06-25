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
application code. The AP can be implemented on a second NIOS2 processor in the
same FPGA as the PCP or on an external microprocessor connected to the PCP
through a SPI or parallel interface.


2. Performance
---------------
- Minimum cycle length: optimization dependent
- PReq-PRes Latency: 1 µs
- Process data: 4 bytes input and 4 bytes output
- There are 3 RPDOs and 1 TPDO available.


3. SW Build Proporties
-------------------
3.1 Build Options
    - [1] debug: Has the most debug information. Additional printouts can be
                 enabled by modifying "DEF_DEBUG_LVL" in "create-this-app".
    - [2] debug with reduced printouts: Has only basic debug information.
    - [3] release: Compiles with best optimization concerning processing time
                   and disables all printf-outputs. Use this option for the
                   final product.
                 
3.2 FPGA Onchip Memory Requirements
    - The build options [1] and [2] do not require special FPGA memory
      for the program code.
    - The build option "[3] release" requires at least 1556 Byte
      tightly-coupled-instruction memory, because certain functions are put
      into this memory.   
      

4. Requirements
---------------
- Development Boards

  * TERASIC DE2-115 (INK Board)

- Altera Quartus II v10.1 SP1 (Web Edition is also possible)

- Altera Nios II Embedded Design Suite v10.1 SP1 or newer

- Experiences with this development environment are required

- POWERLINK network with Configuration Manager.
  The corresponding XDD for this node can be found in the subdirectory
  ObjDicts\PDI.


5.Configuration
----------------
Miscellaneous parameters of the openPOWERLINK stack and the PCP application
can be configured through defines in EplCfg.h. The following section contains
a description of those parameters.

5.1 Firmware Update and Remote configuration
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


6. How to run the demo
----------------------

For Windows:

1. Browse to the directory of your desired Quartus reference design and read the contained
   "readme.txt". You may take some previous action e.g. rebuild the reference design. 
    
2. Click on "rebuild.bat"

3. Choose the desired platform and design by entering a number

4. A bash script will be invoked, which rebuild the SW.

5. Click on "run.bat" - the HW configuration and the PCP SW will be downloaded to the FPGA

6. AFTER rebuilding, goto the "apps/ap_PDI" folder and rebuild
   the Application Processor SW. Choose the SAME platform and design as before!

7. Likewise, click on "run.bat" in "apps/ap_PDI"

8. Enjoy the terminal outputs and the running POWERLINK network.


