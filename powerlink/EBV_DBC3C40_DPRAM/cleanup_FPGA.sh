#!/bin/bash
###########################################################################################
# This script creates the openPOWERLINK Digital I/O Interface application in this directory.
###########################################################################################

###############################################################################
# include project configuration
#
#  TODO: Copy this file to the PCP directory (powerlink/DPRAM)
#
#
 
FPGADESIGN=../../fpga/altera/EBV_DBC3C40/nios2_openmac_dpram_multinios

# cp ${FPGADESIGN}/*.bdf		${FPGADESIGN}/EPL 		# top level schematic
# cp ${FPGADESIGN}/*.ptf		${FPGADESIGN}/EPL		# SOPC Builder system description for generation (peripheral template file)
# cp ${FPGADESIGN}/*.sopc 		${FPGADESIGN}/EPL		# SOPC Builder design file
# cp ${FPGADESIGN}/*.sopcinfo 	${FPGADESIGN}/EPL		# SOPC Builder report file
# cp ${FPGADESIGN}/*.qpf		${FPGADESIGN}/EPL		# Quartus project file
# cp ${FPGADESIGN}/*.qsf		${FPGADESIGN}/EPL		# Quartus settings file

# User added files

cp ${FPGADESIGN}/niosII_openMac_generation_script		${FPGADESIGN}/EPL
cp ${FPGADESIGN}/digital_io.bdf                     	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/nios_pll.bdf                       	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/altpll0.bsf                        	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/digital_io.bsf                     	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_bustri0.bsf                    	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_constant0.bsf						${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_ff0.bsf                        	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_inv0.bsf                       	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/niosII_openMac.bsf                 	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/sevsegdec.bsf                      	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/nios_openMac.cdf                   	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/altpll0.cmp							${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_bustri0.cmp                    	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_constant0.cmp                  	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_inv0.cmp                       	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/nios_openMac.dpf                   	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/nios_openMac.pin                   	${FPGADESIGN}/EPL
cp ${FPGADESIGN}/altpll0.ppf							${FPGADESIGN}/EPL
cp ${FPGADESIGN}/niosII_openMac.ptf                     ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/nios_openMac_assignment_defaults.qdf   ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/altpll0.qip                            ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_bustri0.qip                        ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_constant0.qip                      ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_ff0.qip							${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_inv0.qip                           ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/niosII_openMac.qip                     ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/nios_openMac.qpf                       ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/nios_openMac.qsf                       ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/nios_openMac.qws                       ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/niosII_openMac.sopc					${FPGADESIGN}/EPL
cp ${FPGADESIGN}/niosII_openMac.sopcinfo                ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/readme.txt                             ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/altpll0.vhd                            ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_bustri0.vhd                        ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_constant0.vhd                      ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_ff0.vhd							${FPGADESIGN}/EPL
cp ${FPGADESIGN}/lpm_inv0.vhd                           ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/niosII_openMac.vhd                     ${FPGADESIGN}/EPL
cp ${FPGADESIGN}/sevsegEncode.vhd                       ${FPGADESIGN}/EPL
                                                      
													  
mv ${FPGADESIGN}/EPL ./ 							# save FPGA desing

rm -r ${FPGADESIGN}/*.*								# clean all generated files of FPGA design
rm -r ${FPGADESIGN}/db
rm -r ${FPGADESIGN}/.sopc_builder
rm -r ${FPGADESIGN}/incremental_db
rm -r ${FPGADESIGN}/incremental_dbniosII_openMac_sim

mv ./EPL ${FPGADESIGN}								# restore basic files


# mv ${FPGADESIGN}/EPL/*.bdf		${FPGADESIGN}		# move desing files to right place
# mv ${FPGADESIGN}/EPL/*.ptf		${FPGADESIGN}
# mv ${FPGADESIGN}/EPL/*.sopc 	${FPGADESIGN}
# mv ${FPGADESIGN}/EPL/*.sopcinfo ${FPGADESIGN}
# mv ${FPGADESIGN}/EPL/*.qpf		${FPGADESIGN}
# mv ${FPGADESIGN}/EPL/*.qsf		${FPGADESIGN}

mv ${FPGADESIGN}/EPL/niosII_openMac_generation_script	  ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/digital_io.bdf                       ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/nios_pll.bdf                         ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/altpll0.bsf                          ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/digital_io.bsf                       ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_bustri0.bsf                      ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_constant0.bsf                    ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_ff0.bsf                          ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_inv0.bsf                         ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/niosII_openMac.bsf                   ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/sevsegdec.bsf                        ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/nios_openMac.cdf                     ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/altpll0.cmp                          ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_bustri0.cmp                      ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_constant0.cmp                    ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_inv0.cmp                         ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/nios_openMac.dpf                     ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/nios_openMac.pin                     ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/altpll0.ppf                          ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/niosII_openMac.ptf                   ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/nios_openMac_assignment_defaults.qdf ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/altpll0.qip                          ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_bustri0.qip                      ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_constant0.qip                    ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_ff0.qip                          ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_inv0.qip                         ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/niosII_openMac.qip                   ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/nios_openMac.qpf                     ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/nios_openMac.qsf                     ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/nios_openMac.qws                     ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/niosII_openMac.sopc                  ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/niosII_openMac.sopcinfo              ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/readme.txt                           ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/altpll0.vhd                          ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_bustri0.vhd                      ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_constant0.vhd                    ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_ff0.vhd                          ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/lpm_inv0.vhd                         ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/niosII_openMac.vhd                   ${FPGADESIGN}    
mv ${FPGADESIGN}/EPL/sevsegEncode.vhd                     ${FPGADESIGN}    
                                                      
	echo " "                                         
	echo " "                                          
	echo "FPGA design has been cleand up! "          
	echo " "


exit 0

#EOF
