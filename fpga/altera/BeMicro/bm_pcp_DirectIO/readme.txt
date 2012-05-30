------------------------------------------------------------------------------
POWERLINK CN Development Kit (CNDK)
------------------------------------------------------------------------------
(C) Bernecker + Rainer, B & R Strasse 1, 5142 Eggelsberg, Austria
------------------------------------------------------------------------------

Quartus Reference Design for PCP 
with Direct IO Interface.
==============================================================================

Contents
---------

- FPGA design with Nios II CPU and openMAC: Nios II CPU for POWERLINK communication
- Digital IO interface of PCP (POWERLINK Communication Processor) 


Requirements
-------------

- Industrial Ethernet Board BeMicro RTE

- Altera Quartus II v10.1 SP1 (Web Edition is also possible)
  and Altera Nios II Embedded Design Suite v10.1 SP1
  (http://www.altera.com/support/software/download/nios2/dnl-nios2.jsp)

- Experiences with this development environment are required


How to build the design (generate the SOF file)
------------------------------------------------

These steps are only necessary if you want to change the FPGA design.
Otherwise you can use the supplied SOF file and go directly to step 8.

1. Open the Quartus project file nios_openMac.qpf with Altera Quartus II.

2. Open the SOPC Builder via menu "Tools -> SOPC Builder".

3. If you haven't specified the POWERLINK IP-core path yet, you need to specify
   a global search path in SOPC-Builder.
   
   Go to "Tools -> Options -> IP Search Path -> Add" 
   and browse to the POWERLINK IP-core folder e.g. in the CNDK reference design folder
   
   <your path>/fpga/altera/IP_core/POWERLINK

4. Press the button "Generate" in the SOPC Builder to regenerate the Nios II system.

5. Close the SOPC Builder when the generation has finished (shown as information output).

6. A message window will pop up. Choose "Update: All symbols or blocks in this file".

7. Start the compilation in the Quartus II window via menu "Processing" -> "Start Compilation".
   Choose "Yes" for saving all changed files.

8. Use the design with the supplied software demo project in the CNDK
   subdirectory "powerlink/pcp_DirectIO"

   Please refer to the readme.txt in the subdirectory of the software demo project for
   further information.
