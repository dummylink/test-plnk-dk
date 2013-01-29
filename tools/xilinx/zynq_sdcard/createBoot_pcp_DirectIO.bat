cp ../../../fpga/xilinx/Xilinx_Z702/Zynq_pcp_DirectIO/implementation/system.bit .
cp ../../../fpga/xilinx/Xilinx_Z702/Zynq_pcp_DirectIO/SDK/Workspace/ap_cpu/Debug/ap_cpu.elf .
cp ../../../fpga/xilinx/Xilinx_Z702/Zynq_pcp_DirectIO/SDK/Workspace/zynq_fsbl_0/Debug/zynq_fsbl_0.elf .
cp ../../../powerlink/pcp_DirectIO/directIO.elf .
arm-xilinx-eabi-objcopy -I elf32-little -O binary directIO.elf directIO.bin
bootgen -image bootimage_pcp_DirectIO.bif -o i BOOT.BIN -w on 