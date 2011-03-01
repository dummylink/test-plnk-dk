  (c) SYSTEC electronic GmbH, D-07973 Greiz, August-Bebel-Str. 29
        www.systec-electronic.com
	openPOWERLINK.sourceforge.net


	openPOWERLINK - FPGA design for EBV DBC3C40 with openMAC
	=========================================================


Contents
---------

- FPGA design with Nios II CPU and openMAC: 2 Nios CPU's - one for POWERLINK communication, one for application.
- PCP (POWERLINK Communication Processor) and AP (Application Processor) are connected via DPRAM accessed by Avalon Bus (Altera FPGA internal bus).


RRequirements
-------------

- Development Board EBV DBC3C40 (Mercury Board)

- Altera Quartus II v10.0 SP1 or newer (Web Edition is also possible)
  and Altera Nios II Embedded Design Suite v10.0 SP1 or newer
  (http://www.altera.com/support/software/download/nios2/dnl-nios2.jsp )

- Experiences with this development environment are required


How to build the design (generate the SOF file)
------------------------------------------------

These steps are only necessary if you want to change the FPGA design.
Otherwise you can use the supplied SOF file and go directly to step 6.

1. Open the Quartus project file nios_openMac.qpf with Altera Quartus II.

2. Open the SOPC Builder via menu "Tools" -> "SOPC Builder".

3. Press the button "Generate" in the SOPC Builder to regenerate the Nios II system.

4. Close the SOPC Builder when the generation has finished (shown as information output).

5. A message window will pop up. Choose "Update: All symbols or blocks in this file".

5. Start the compilation in the Quartus II window via menu "Processing" -> "Start Compilation". Choose "Yes" for saving all changed files.

6. Use the design with the supplied demo projects in the openPOWERLINK_CNDK
   subdirectory "powerlink" and "apps"

   Please refer to the readme.txt in the subdirectory of the demo project for
   further information.
