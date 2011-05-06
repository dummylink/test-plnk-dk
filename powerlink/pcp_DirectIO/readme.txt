-------------------------------------------------------------------------------
POWERLINK CN Development Kit (CNDK)
-------------------------------------------------------------------------------
(C) Bernecker + Rainer, B & R Strasse 1, 5142 Eggelsberg, Austria
-------------------------------------------------------------------------------


	openPOWERLINK - Direct IO Demo for INK Board 
	===============================================================

Contents
---------

- POWERLINK SW for PCP (Powerlink Communication Processor).

Performance Data
-----------------

- Minimum cycle length: TBD
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

Requirements
-------------

- Development Board TERASIC DE2-115 (INK-Board)

- Altera Quartus II v10.1 SP1 or newer (Web Edition is also possible)

- Altera Nios II Embedded Design Suite v10.1 SP1 or newer

- Experiences with this development environment are required

- POWERLINK network with Configuration Manager.
  The corresponding XDD for this node can be found in the subdirectory
  ObjDicts\PDI.


How to run the demo
--------------------

For Windows:

1. Click on "rebuild.bat"

2. Choose the desired platform and design by entering a number

3. A bash script will be invoked, which rebuild the SW.

4. Click on "run.bat" - the HW configuration and the PCP SW will be downloaded to the FPGA

5. Enjoy the terminal outputs and the running POWERLINK network.


