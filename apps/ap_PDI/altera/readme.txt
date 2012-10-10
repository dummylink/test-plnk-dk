------------------------------------------------------------------------------
POWERLINK CN Development Kit (CNDK)
------------------------------------------------------------------------------
(C) Bernecker + Rainer, B & R Strasse 1, 5142 Eggelsberg, Austria
------------------------------------------------------------------------------

Software Demo for AP (Application Processor)
with SPI/Parallel or Internal FPGA Interface
==============================================================================

Contents
---------

- POWERLINK SW for AP (Application Processor).

Performance 
-----------------

- The following 8 objects - each has the size 1 Byte - can be mapped:

  6000/01: not in use
  6000/02: not in use
  6000/03: digital input (buttons and switches) -> meant for TPDO
  6000/04: not in use

  6200/01: digital output (LEDs) -> meant for RPDO
  6200/02: digital output (LEDs) -> meant for RPDO
  6200/03: not in use
  6200/04: digital output (Hex Digits) -> meant for RPDO

Requirements
-------------

- Development Boards

  * TERASIC DE2-115 (INK Board)

- Altera Quartus II v10.1 SP1 or newer (Web Edition is also possible)

- Altera Nios II Embedded Design Suite v10.1 SP1 or newer

- Experiences with this development environment are required

- POWERLINK network with Configuration Manager.
  The corresponding XDD for this node can be found in the subdirectory
  ObjDicts\PDI.


How to run the demo
--------------------

For Windows:

1. Click on "rebuild.bat" AFTER the PCP SW rebuild is finished (please refer to "pcp_PDI/readme.txt")

2. Choose the same platform and design as the PCP SW by entering a number

3. A bash script will be invoked, which rebuild the SW.

4. Click on "run.bat" - the HW configuration and the AP SW will be downloaded to the FPGA

5. Enjoy the terminal outputs and the running POWERLINK network.


