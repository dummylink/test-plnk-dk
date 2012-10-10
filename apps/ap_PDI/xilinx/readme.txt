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
  6000/03: not in use
  6000/04: not in use

  6200/01: digital output (LEDs)
  6200/02: not in use
  6200/03: not in use
  6200/04: not in use

Requirements
-------------

- Development Boards

  * Avnet Spartan-6 lx16 - Powerlink Evaluation Board (s6plkeb)
  * Avnet Spartan-6 lx150t - Industrial Ethernet Kit (IEK)
  * Avnet Spartan-6 lx9 - MicroBoard

- Xilinx ISE Design Suite 13.2

- Experiences with this development environment are required

- POWERLINK network with Configuration Manager.
  The corresponding XDD for this node can be found in the subdirectory
  ObjDicts\PDI.


How to run the demo
--------------------

A detailed description is available in the "User_Guide_Xilinx.pdf" document.

For Windows:
    
4. Open the Xilinx Software Development Kit (SDK) with workspace on the CNDK root directory. (e.g: C:\openPOWERLINK_CNDK\)
   Do all steps explained in the powerlink/pcp_PDI/readme.txt file.

5. Create a "Board Support Package" (e.g: standalone_bsp_lx150t_intplb_ap) for your AP processor 
   by using the previously created hardware platform.

6. Import the ap_PDI project into the SDK by using Import -> C/C++ -> Existing Code as Makefile Project.
   Give a Project name, existing code location (e.g: C:\openPOWERLINK_CNDK\apps\ap_PDI), select C for your language 
   and use the "Xilinx Microblaze GNU Toolchain".

7. Adapt the file makefile.settings according to your needs.

8. Change the Referenced BSP to point to your previously created "Board Support Package" (e.g: standalone_bsp_lx150t_intplb_ap).

9. Import the libCnApi project into the SDK by using Import -> C/C++ -> Existing Code as Makefile Project.
   Give a Project name, existing code location (e.g: C:\openPOWERLINK_CNDK\libCnApi), select C for your language 
   and use the "Xilinx Microblaze GNU Toolchain".
   
10. Compile the libCnApi library by using the corresponding makefile. (Creates libCnApi.a)

11. Your ap_PDI.elf can be compiled in the ap_PDI project.
    Download the .elf file. (Run As -> Run on Hardware)

12. The printed output of the processor can be viewed by using a terminal program (tera term) or by using the built in SDK program.

13. Enjoy the terminal outputs and the running POWERLINK network.

For Linux:

Should be very similar to the windows way.


