-------------------------------------------------------------------------------
POWERLINK CN Development Kit (CNDK)
-------------------------------------------------------------------------------
(C) Bernecker + Rainer, B & R Strasse 1, 5142 Eggelsberg, Austria
-------------------------------------------------------------------------------


Tools and Utilities for Altera Platform
=======================================

1. Introduction
---------------
This directory contains tools and utilites for the Altera platform

3. Requirements
---------------
To compile the tools the following Altera development tools must be installed
on your system:

- Altera Quartus II v10.1 SP1 or newer (Web Edition is also possible)

- Altera Nios II Embedded Design Suite v10.1 SP1 or newer


4. Tools
--------
Firmware creation tools:

mkfirmware	        - creates a firmware file by concatenation of binary files and
                      creation of the firmware file header
create-firmware.sh	- main shell script to create a firmware file from FPGA
                      configuration in .sof format, PCP software in .elf format
                      and AP software in binary format (uses mkfirmware)

mkiib               - creates a image information block header
progimage.sh        - shell script to programm a firmware image into flash memory
                      using the JTAG interface. It creates the image information
                      block using mkiib and programs the FPGA configuration, PCP
                      software, AP software and IIB into flash memory.

4. Building
-----------
To build the tools implemented in C, go into the tools/altera directory and
type make from a NIOS2 command shell.

