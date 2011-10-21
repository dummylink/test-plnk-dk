-------------------------------------------------------------------------------
POWERLINK CN Development Kit (CNDK)
-------------------------------------------------------------------------------
(C) Bernecker + Rainer, B & R Strasse 1, 5142 Eggelsberg, Austria
-------------------------------------------------------------------------------


Demo for PCP (Powerlink Communication Processor) with SPI/Parallel Interface
============================================================================

1. Introduction
---------------
This demo implements the software for a Powerlink Communication Processor (PCP).
The PCP contains all Powerlink functionality of a POWERLINK CN node. It is
designed to be connected to an Application Processor (AP) which contains the
application code. The AP can be implemented on a second NIOS2 processor or on
an external microprocessor connected to the PCP through a SPI or parallel
interface.


2. Performance Data
-------------------
- Minimum cycle length: TBD
- PReq-PRes Latency: 1 µs
- Process data: 4 bytes input and 4 bytes output
- There are 3 RPDOs and 1 TPDO available.


3. Requirements
---------------
- Development Boards
  * EBV DBC3C40 (Mercury Board)
  * TERASIC DE2-115 (INK Board)

- Altera Quartus II v10.1 SP1 or newer (Web Edition is also possible)

- Altera Nios II Embedded Design Suite v10.1 SP1 or newer

- Experiences with this development environment are required

- POWERLINK network with Configuration Manager.
  The corresponding XDD for this node can be found in the subdirectory
  ObjDicts\PDI.


4.Configuration
---------------
Miscellaneous parameters of the openPOWERLINK stack and the PCP application
can be configured through defines in EplCfg.h. The following section contains
a desription of miscellaneous configuration parameters.

4.1 Firmware Update and Remote configuration
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


5. How to run the demo
----------------------

For Windows:

1. Click on "rebuild.bat"

2. Choose the desired platform and design by entering a number

3. A bash script will be invoked, which rebuild the SW.

4. Click on "run.bat" - the HW configuration and the PCP SW will be downloaded to the FPGA

5. AFTER rebuilding, goto the "apps/ap_PDI" folder and rebuild
   the Application Processor SW. Choose the SAME platform and design as before!

6. Likewise, click on "run.bat" in "apps/ap_PDI"

5. Enjoy the terminal outputs and the running POWERLINK network.


