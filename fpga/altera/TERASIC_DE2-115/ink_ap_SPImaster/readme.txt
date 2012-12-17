------------------------------------------------------------------------------
POWERLINK CN Development Kit (CNDK)
------------------------------------------------------------------------------
(C) Bernecker + Rainer, B & R Strasse 1, 5142 Eggelsberg, Austria
------------------------------------------------------------------------------

Quartus Reference Design for AP 
with External SPI (Serial Peripheral Interface)
==============================================================================

Contents
---------

- FPGA design with Nios II CPU: AP (Application Processor)
- SPI master to access the PCP DPRAM via its SPI slave


Requirements
-------------

- Development Board Terasic DE2-115 (INK Board)

- Altera Quartus II v10.1 SP1 (Web Edition is also possible)
  and Altera Nios II Embedded Design Suite v10.1 SP1
  (http://www.altera.com/support/software/download/nios2/dnl-nios2.jsp)

- Experiences with this development environment are required


How to build the design (generate the SOF file)
------------------------------------------------

These steps are only necessary if you want to change the FPGA design.
Otherwise you can use the supplied SOF file and go directly to step 7.

1. Open the Quartus project file nios_openMac.qpf with Altera Quartus II.

2. Open the SOPC Builder via menu "Tools -> SOPC Builder".

3. Press the button "Generate" in the SOPC Builder to regenerate the Nios II system.

4. Close the SOPC Builder when the generation has finished (shown as information output).

5. A message window will pop up. Choose "Update: All symbols or blocks in this file".

6. Start the compilation in the Quartus II window via menu "Processing" -> "Start Compilation".
   Choose "Yes" for saving all changed files.

7. Use the design with the supplied software demo project in the CNDK
   subdirectory "apps/ap_PDI"

   Please refer to the readme.txt in the subdirectory of the software demo project for
   further information.
