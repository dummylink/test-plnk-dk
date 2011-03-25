@echo off
REM : SDK Shell Batch File for POWERLINK CNDK Build Targets
REM : --------------------------------------------------------
REM :  - Invokes bash, recompiles the BSP and application
REM : 

cls
echo ====================================================
echo  Rebuild POWERLINK Communication Processor PDI Menu
echo ====================================================
echo  Choose your desired PCP interface demo:
echo .
echo  PCP including an additional NIOS II as AP (in one FPGA)
echo  -----------------------------------------------
echo    Mercury Board (EBV DBC3C40)
echo      1: Avalon
echo      2: SPI
echo    INK Board (TERASIC DE2-115)
echo      3: Avalon
echo      4: SPI
echo . 
echo  Stand alone PCP with FPGA external MCU interface
echo  -----------------------------------------------
echo    Mercury Board (EBV DBC3C40)
echo      5: SPI
echo      6: 16 Bit parallel
echo    INK Board (TERASIC DE2-115)
echo      7: SPI
echo      8: 16 Bit parallel
echo .
echo ==================================================

:user_entry
set /p choice= Enter design number [1-8]:
if /I "%choice%" == "1" ( goto EBV_PCP_AP_avalon )
if /I "%choice%" == "2" ( goto EBV_PCP_AP_SPI )
if /I "%choice%" == "3" ( goto INK_PCP_AP_avalon )
if /I "%choice%" == "4" ( goto INK_PCP_AP_SPI )
if /I "%choice%" == "5" ( goto EBV_PCP_SPI )
if /I "%choice%" == "6" ( goto EBV_PCP_16bitparallel )
if /I "%choice%" == "7" ( goto INK_PCP_SPI )
if /I "%choice%" == "8" ( goto INK_PCP_16bitparallel )
if /I "%choice%" == "9" ( goto ECU_PCP_SPI ) else (
set choice=
echo Invalid input!
goto user_entry )


REM ######################################
REM # SET PARAMETERS

:EBV_PCP_AP_avalon
set SOPC_DIR=..\..\fpga\altera\EBV_DBC3C40\ebv_ap_pcp_intavalon
set DUAL_NIOS = "1"
goto start
:EBV_PCP_AP_SPI
set SOPC_DIR=..\..\fpga\altera\EBV_DBC3C40\ebv_ap_pcp_SPI
set DUAL_NIOS = "1"
goto start
:EBV_PCP_SPI
set SOPC_DIR=..\..\fpga\altera\EBV_DBC3C40\ebv_pcp_SPI
goto start
:EBV_PCP_16bitparallel
set SOPC_DIR=..\..\fpga\altera\EBV_DBC3C40\ebv_pcp_16bitprll
goto start
:INK_PCP_AP_avalon
set SOPC_DIR=..\..\fpga\altera\TERASIC_DE2-115\ink_ap_pcp_intavalon
set DUAL_NIOS = "1"
goto start
:INK_PCP_AP_SPI
set SOPC_DIR=..\..\fpga\altera\TERASIC_DE2-115\ink_ap_pcp_SPI
set DUAL_NIOS = "1"
goto start
:INK_PCP_SPI
set SOPC_DIR=..\..\fpga\altera\TERASIC_DE2-115\ink_pcp_SPI
goto start
:INK_PCP_16bitparallel
set SOPC_DIR=..\..\fpga\altera\TERASIC_DE2-115\ink_pcp_16bitprll
goto start
:ECU_PCP_SPI
set SOPC_DIR=..\..\fpga\altera\SYSTEC_ECUcore-EP3C\systec_pcp_SPI
goto start

:start

REM ######################################
REM # set root quartus directory to
REM # QUARTUS_ROOTDIR_OVERRIDE if the
REM # env var is set
if "%QUARTUS_ROOTDIR_OVERRIDE%"=="" goto set_default_quartus_root
set QUARTUS_ROOTDIR=%QUARTUS_ROOTDIR_OVERRIDE%
goto run_qreg
REM ######################################


REM ######################################
REM # Discover the root quartus directory
REM # when QUARTUS_ROOTDIR_OVERRIDE is not
REM # set
:set_default_quartus_root
set QUARTUS_ROOTDIR=%QUARTUS_ROOTDIR%
goto run_qreg
REM ######################################

REM ######################################
REM # Run qreg (if it exists) to setup
REM # cygwin and jtag services
:run_qreg
if not exist "%QUARTUS_ROOTDIR%\bin\qreg.exe" goto errorQ
%QUARTUS_ROOTDIR%\bin\qreg.exe
%QUARTUS_ROOTDIR%\bin\qreg.exe --jtag
REM ######################################

if not exist "%QUARTUS_ROOTDIR%\bin\cygwin\bin\bash.exe" goto errorQ

REM ######################################
REM # Discover the root nios2eds directory
set SOPC_KIT_NIOS2=%QUARTUS_ROOTDIR%\..\nios2eds
REM ######################################

set SOPC_BUILDER_PATH_101=%SOPC_KIT_NIOS2%+%SOPC_BUILDER_PATH_101%
if not exist "%QUARTUS_ROOTDIR%\bin\cygwin\bin\bash.exe" goto errorQ
if not exist "%SOPC_KIT_NIOS2%\nios2_sdk_shell_bashrc" goto errorN
goto run_bash

:run_bash
echo . verifying path...: %~dp0%SOPC_DIR%
if not exist "%~dp0%SOPC_DIR%" goto errorSOPC
echo . verifying path...OK
REM Now replace \ with / because we pass to bash...
set SOPC_DIR=%SOPC_DIR:\=/%
echo .
REM execute "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash" in every bash.exe call !
"%QUARTUS_ROOTDIR%\bin\cygwin\bin\bash.exe" ".\rebuild.sh" --sopcdir %SOPC_DIR%

pause
exit

:errorQ
echo . 
echo . Cannot locate Quartus installation (QUARTUS_ROOTDIR) at:
echo . 
echo .    %QUARTUS_ROOTDIR%
echo .    (specifically, the bin\cygwin\bin\bash.exe program within)
echo . 
echo . Please check your paths and try again (running Quartus from
echo . the Start Menu may update the paths and fix this problem).
echo . Your Quartus II installation may need to be repaired.
echo . 
pause
exit

:errorN
echo . 
echo . Cannot locate Nios II Development Kit (SOPC_KIT_NIOS2) at:
echo . 
echo .    %SOPC_KIT_NIOS2%
echo .    (specifically, the nios2_sdk_shell_bashrc file within)
echo . 
echo . Your Nios II installation may need to be repaired.
echo . 
pause
exit

:errorSOPC
echo . 
echo . Cannot locate SOPC directory (SOPC_DIR) at:
echo . 
echo .    %SOPC_DIR%
echo .    (setting in rebuild.bat)
echo . 
echo . Switch to existing path where the sopcinfo-file resides!
echo . 
pause
exit

REM : end of file