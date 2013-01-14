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
accesses a POWERLINK Communictaion Processor (PCP) via a certain hardware
interface connected to the PCP DPRAM.
It utilizes a driver library (cnApiLib) to access and communicate with the
PCP. The PCP can be implemented on a second Microblaze processor in the same FPGA
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
  6000/03: not in use
  6000/04: not in use

  6200/01: digital output (LEDs)
  6200/02: not in use
  6200/03: not in use
  6200/04: not in use

- Software footprint is apprx.: Code+Data=133 KByte, Heap=10 KByte, Stack=50 KByte
                                => 193 KByte (rough estimation)
  (Measured with -O3)

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

A detailed description is available in the "MAN_OAT113110_11_Vxxx - Getting Started.pdf" document.

Build flow for Windows:

1. Open the Xilinx Software Development Kit (SDK) with workspace on the CNDK root directory.
   (e.g: C:\BR_POWERLINK-SLAVE_XILINX_VX.X.X\02_Reference_Sources\) Do all steps explained in the
   powerlink/pcp_PDI/readme.txt file.

2. The following procedure depends on the example. If the design has two processors in one bitstream
   there is no need to build an FPGA configuration for the AP processor. Then you can continue with step
   5.
   If you are using a design where the AP processor is on an other FPGA you can use the provided bitstream
   (continue with step 5) or start building it by yourself.

3. To build the FPGA configuration, open a design from the FPGA directory 
  (e.g: C:\BR_POWERLINK-SLAVE_XILINX_VX.X.X\02_Reference_Sources\fpga\xilinx\) and build it. (Generate Bitstream)

4. Export the design to the SDK_Export directory (Export Hardware Design to SDK) without launching SDK.

5. Create a "Board Support Package" (e.g: standalone_bsp_lx150t_intplb_ap-plb) for your AP processor
   by using the previously created hardware platform.

6. Import the ap_PDI project into the SDK by using Import -> General -> Existing Project into Workspace.
   Set the root directory to search for to the CNDK root directory
   (e.g: C:\BR_POWERLINK-SLAVE_XILINX_VX.X.X\02_Reference_Sources) and select the found
   project ap_PDI for import.

7. Adapt the file makefile.settings according to your needs.

8. Change the Referenced BSP to point to your previously created "Board Support Package"
   (e.g: standalone_bsp_lx150t_intplb_ap-plb).

9. Your ap_PDI.elf can be compiled in the ap_PDI project. (It also builds the API library called "libCnApi")
   Download the .elf file. (Run As -> Run on Hardware)

10. The printed output of the processor can be viewed by using a terminal program (tera term)
    or by using the built in SDK program.

11. Enjoy the terminal outputs and the running POWERLINK network.

