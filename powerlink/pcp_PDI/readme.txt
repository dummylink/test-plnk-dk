-------------------------------------------------------------------------------
POWERLINK CN Development Kit (CNDK)
-------------------------------------------------------------------------------
(C) Bernecker + Rainer, B & R Strasse 1, 5142 Eggelsberg, Austria
-------------------------------------------------------------------------------


	openPOWERLINK - Demo for EBV DBC3C40 and INK-Board
	===========================================================


Contents
---------

- POWERLINK SW for PCP (Powerlink Communication Processor).

Performance Data
-----------------

- Minimum cycle length: TBD
- PReq-PRes Latency: 1 µs
- Process data: 4 bytes input and 4 bytes output
- There are 3 RPDOs and 1 TPDO available.


Requirements
-------------

- Development Board EBV DBC3C40 (Mercury Board)

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

5. AFTER rebuilding, goto the "apps/ap_PDI" folder and rebuild
   the Application Processor SW. Choose the SAME platform and design as before!

6. Likewise, click on "run.bat" in "apps/ap_PDI"

5. Enjoy the terminal outputs and the running POWERLINK network.


