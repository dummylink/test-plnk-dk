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
Hot to Do
**************************************************************************************
- Implement the hardware design
  - open suitable design from 'fpga/xilinx/Xilinx_Z702' in xps
  - xps: 
    - hardware->generateBitstream
    - project->exportHardwareDesignToSDK
      - don't check 'include bitstream and BMM file'
      - select 'Export & Launch SDK'
- SDK: 
  - enter workspace location <rootDir>/fpga/xilinx/Xilinx_Z702/*/SDK/Workspace
  - set repositoary for powerlink IP

- Creating First stage Boot loader
  - Create the custom FSBL that supports multiple elf files
    - select xilinx tools->repositories
      - select New for Local repositories
        - browse to and select <rootDir>/tools/xilinx/zyna_fsbl_repo
      - OK
    - select file->new->xilinx C project    
      - change processor to 'ps7_cortexa9_0'
      - select 'Zynq FSBL'. Verify the description starts with 'AMP Modified'
      - Next
      - Finish

-- Import Powerlink Applications
  - create bsp for ARM (standalone_bsp_ap) and Microblaze (standalone_bsp_pcp) 
  - import powerlink Application PCP_DigitalIO (or pcp_PDI and ap_PDI) as make file project
  - while importing ap_PDI please select xilinx ARM GNU tool chain as tool chain
  - Incase of Digital Io & pcp_PDI select xilinx Microblaze GNU as tool chain

-- For Digital IO Design
  - Create bootloop application for A9 cpu0
    - select file->new->xilinx C project
      - change processor to 'ps7_cortexa9_0'
      - select 'Empty Application'
      - change project name to 'app_cpu0'
      - select 'next'
      - change project name to 'bsp_cpu0'
      - select 'finish'
    - In the project explorer window, right click on app_cpu0 src folder
      - select import
      - select general->fileSystem, next
      - browse to <rootDir>/apps/app_cpu0, OK
      - select all files in the right window. Do not select the folder in the left window
      - click 'Finish'
      - select 'Yes' to overwrite lscript.ld


- Create the BOOT.BIN file that contains the bit file, FSBL, cpu0 bootloop elf, and microblaze elf
  - open an ISE Design Suite Command prompt
  - cd <rootDir>/tools/xilinx/zynq_sdcard
  - run the command 'createBoot_DirectIO.bat for Digital IO design or createBoot_PDI.bat' for Dual processor design
  - copy the generated BOOT.BIN file to the SD card
- Board Usage
  - plug the SD card into the zc702 then power up the board.
  - Powerlink will start executes :-) 
 **************************************************************************************          
        