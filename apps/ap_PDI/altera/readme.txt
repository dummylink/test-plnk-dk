------------------------------------------------------------------------------
POWERLINK CN Development Kit (CNDK)
------------------------------------------------------------------------------
(C) Bernecker + Rainer, B & R Strasse 1, 5142 Eggelsberg, Austria
------------------------------------------------------------------------------

Software Demo for AP (Application Processor)
with SPI/Parallel or Internal FPGA Interface
==============================================================================

Introduction
---------------
This demo implements the software for a Application Processor (AP) which
accesses a POWERLINK Communictaion Processor (PCP) via a ceratin hardware
interface connected to the PCP DPRAM.
It utilizes a driver library (cnApiLib) to access and communicate with the
PCP. The PCP can be implemented on a second NIOS2 processor in the same FPGA
as the PCP or on in an external FPGA device connected to the AP through an
SPI or parallel interface.


Contents
---------

- POWERLINK SW for AP (Application Processor).


Properties 
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

1. You may take some previous action e.g. rebuild the Quartus project.
   Therefore go to your desired Quartus reference design in
   fpga/altera/<evalboard>/<reference design>/
   and read the contained "readme.txt". 

2. Click on "rebuild.bat" AFTER the PCP SW rebuild is finished (please refer to "pcp_PDI/readme.txt")

3. Choose the a reference desing with the same interface type that you used for the PCP by entering a number

4. If your chosen desing is not a joint FPGA desing with an included PCP processor (i.e. a stand alone AP design),
   you will be asked if the Quartus desing should be generated from command line - without
   opening the Quartus toolchain manually.

5. Choose the build option   
    - [1] debug: Has the most debug information. Additional printouts can be
                 enabled by modifying "DEF_DEBUG_LVL" in "create-this-app".
    - [2] debug with reduced printouts: Has only basic debug information.
    - [3] release: Compiles with best optimization concerning processing time
                   and disables all printf-outputs. Use this option for the
                   final product.

6. A bash script will be invoked, which rebuilds the SW

7. Install the driver and etablish the connection of your USB-Blaster if not done yet,
   according to your evaluation board manual.

8. Click on "run.bat" - the HW configuration and the AP SW will be downloaded to the FPGA

9. Enjoy the terminal outputs and the running POWERLINK network


