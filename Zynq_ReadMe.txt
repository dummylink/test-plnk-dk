**************************************************************************************
Quick Start for Powerlink on Zynq Board 
**************************************************************************************
**************************************************************************************
Requirements
**************************************************************************************
Zynq 702 Eval board KIT
Avnet FMC Ethernet Connector [Connect this to FMC 1 of Board]

Xilinx ISE/EDK Embeded Edition 14.4 or higher
**************************************************************************************
How to Do
**************************************************************************************
- Implement the hardware design
  - open suitable design from 'fpga/xilinx/Xilinx_Z702' in xps
  - xps: 
    - hardware->generateBitstream
    - project->exportHardwareDesignToSDK
      - don't check 'include bitstream and BMM file'
      - select 'Export Only'
      - system.xml file will be copied to "SDK/SDKExport" folder
- SDK: 
  - enter workspace location <rootDir>/
  - set repositories
      - select xilinx tools->repositories
      - select New for Local repositories
      - browse to and select <rootDir>/tools/xilinx/zyna_fsbl_repo
      - browse to and select <rootDir>/fpga/xilinx/ipcore
      - Click Ok

- Creating Hardware Platform & BSP for the design
  - Open Workspace
  - Select file->new-> Board support package
  - Its will have for hardware platform file (Please make sure that there wont be any hardware platform open on the worksapce)
  - Please select system.xml file from SDK/SDKExport
  - Please modify the hardware platform name as "hw_platform_zynq_directIO-axi" for Digital IO design
     or
  - Please modify the hardware platform name as "hw_platform_zynq_intaxi-axi" for dual processor design
  - It will ask for creating board support package
  - For digitalIO design create "standalone_bsp_zynq_directIO-axi" for "PCP" processor and "standalone_bsp_zynq-ap" for ps7_cortexa9_0 processor

  - For dual Processor design create "standalone_bsp_zynq_intaxi-pcp-axi" for "PCP" processor and "standalone_bsp_zynq_intaxi-ap-axi" for ps7_cortexa9_0 processor


- Creating First stage Boot loader
    - select file->new->xilinx C project
      - Give the name as 'zynq_fsbl_digitalIO' for DigitalIO design or 'zynq_fsbl_dualProcessor' for Dual processor design  
      - change processor to 'ps7_cortexa9_0'
      - select 'Zynq FSBL for AMP'. Verify the description starts with 'AMP Modified'
      - Next
      - Finish

-- Import Powerlink Applications
  -  Click On File->Import
  -  Browse to CNDK root directory, this will list down all the projects in CNDK directory
  -  Choose 'pcp_DirectIO' and 'DigitalIO-Init' projects for Digital IO project
     or
  -  Choose 'pcp_PDI' and 'ap_PDI' projects for Dual processor (AP-PCP) project
  -  Click Ok
  -  Build projects

- Create the BOOT.BIN file that contains the bit file, FSBL, cpu0 bootloop elf, and microblaze elf
  - open an ISE Design Suite Command prompt
  - cd <rootDir>/tools/xilinx/zynq_sdcard
  - run the command 'createBoot_DirectIO.bat for Digital IO design or createBoot_PDI.bat' for Dual processor design
  - copy the generated BOOT.BIN file to the SD card
- Board Usage
  - plug the SD card into the zc702 then power up the board.
  - Powerlink will start executes :-) 
 **************************************************************************************          


Aditional Notes:
 For Dual processor design Node Switches are not present FPGA design due to board limitation, Application engineer has to Set the NodeID in Application processor

        