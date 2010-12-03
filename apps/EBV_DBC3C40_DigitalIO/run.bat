@ REM : SDK Shell Batch File for POWERLINK CNDK Build Targets
@ REM : --------------------------------------------------------
@ REM :  - Invokes bash, recompiles the BSP and application
@ REM :  - Programs the FPGA and invokes the nios2 terminal

@ goto start REM Temporary skip path choice

@ cls
@ echo ==================================================
@ echo  Run POWERLINK Communication Processor PDI Menu
@ echo ==================================================
@ echo .
@ echo  PCP with additional NIOS II as AP (in one FPGA)
@ echo  -----------------------------------------------
@ echo    Mercury Board (EBV DBC3C40)
@ echo      1: Avalon PDI
@ echo      2: SPI PDI
@ echo    INK Board (TERASIC DE2-115)
@ echo      3: Avalon PDI
@ echo      4: SPI PDI
@ echo . 
@ echo ==================================================



:user_entry
@ set /p choice= Enter design number [1-8]:
@ if /I "%choice%" == "1" ( goto EBV_PCP_AP_avalon )
@ if /I "%choice%" == "2" ( goto EBV_PCP_AP_SPI )
@ if /I "%choice%" == "3" ( goto INK_PCP_AP_avalon )
@ if /I "%choice%" == "4" ( goto INK_PCP_AP_SPI )
@ if /I "%choice%" == "5" ( goto EBV_PCP_SPI )
@ if /I "%choice%" == "6" ( goto EBV_PCP_16bitparallel )
@ if /I "%choice%" == "7" ( goto INK_PCP_SPI )
@ if /I "%choice%" == "8" ( goto INK_PCP_16bitparallel ) else (
@ set choice=
@ echo Invalid input!
@ goto user_entry )


@ REM ######################################
@ REM # SET PARAMETERS
@ REM It has to be "/", because it is a parameter passed to unix-bash!

:EBV_PCP_AP_avalon
@ set SOF_DIR=../../fpga/altera/EBV_DBC3C40/nios2_openmac_dpram_multinios
@ set DUAL_NIOS = "1"
@ goto start
:EBV_PCP_AP_SPI
@ set SOF_DIR=../../fpga/altera/EBV_DBC3C40/nios2_openmac_SPI_multinios
@ set DUAL_NIOS = "1"
@ goto start
:EBV_PCP_SPI
@ set SOF_DIR=../../fpga/altera/TERASIC_DE2-115/
@ goto start
:EBV_PCP_16bitparallel
@ set SOF_DIR=../../fpga/altera/EBV_DBC3C40/nios2_openmac_dpram_16bitprll
@ goto start
:INK_PCP_AP_avalon
@ set SOF_DIR=../../fpga/altera/TERASIC_DE2-115/nios2_openmac_dpram_multinios
@ set DUAL_NIOS = "1"
@ goto start
:INK_PCP_AP_SPI
@ set SOF_DIR=../../fpga/altera/TERASIC_DE2-115/
@ set DUAL_NIOS = "1"
@ goto start
:INK_PCP_SPI
@ set SOF_DIR=../../fpga/altera/TERASIC_DE2-115/
@ goto start
:INK_PCP_16bitparallel
@ set SOF_DIR=../../fpga/altera/TERASIC_DE2-115/
@ goto start

REM TODO: if @ if DUAL_NIOS == "1" goto run_ap

:start
@ REM ######################################
@ REM # Discover the root nios2eds directory
@ set SOPC_KIT_NIOS2=%SOPC_KIT_NIOS2%
@ REM ######################################


@ REM ######################################
@ REM # set root quartus directory to
@ REM # QUARTUS_ROOTDIR_OVERRIDE if the
@ REM # env var is set
@ if "%QUARTUS_ROOTDIR_OVERRIDE%"=="" goto set_default_quartus_root
@ set QUARTUS_ROOTDIR=%QUARTUS_ROOTDIR_OVERRIDE%
@ goto run_qreg
@ REM ######################################


@ REM ######################################
@ REM # Discover the root quartus directory
@ REM # when QUARTUS_ROOTDIR_OVERRIDE is not
@ REM # set
:set_default_quartus_root
@ set QUARTUS_ROOTDIR=%QUARTUS_ROOTDIR%
@ goto run_qreg
@ REM ######################################


@ REM ######################################
@ REM # Run qreg (if it exists) to setup
@ REM # cygwin and jtag services
:run_qreg
@ if not exist "%QUARTUS_ROOTDIR%\bin\qreg.exe" goto errorQ
@ %QUARTUS_ROOTDIR%\bin\qreg.exe
@ %QUARTUS_ROOTDIR%\bin\qreg.exe --jtag
@ REM ######################################

@ if not exist "%QUARTUS_ROOTDIR%\bin\cygwin\bin\bash.exe" goto errorQ
@
@ set SOPC_BUILDER_PATH_100=%SOPC_KIT_NIOS2%+%SOPC_BUILDER_PATH_100%
@ if not exist "%QUARTUS_ROOTDIR%\bin\cygwin\bin\bash.exe" goto errorQ
@ if not exist "%SOPC_KIT_NIOS2%\nios2_sdk_shell_bashrc" goto errorN
@ goto run_bash

:run_bash
REM @ echo . verifying path...: %~dp0%SOF_DIR%
REM @ if not exist "%~dp0%SOF_DIR%" goto errorSOPC
REM @ if not exist "%~dp0%SOF_DIR%\*.sof" goto errorSOF
REM @ echo . verifying path...OK
REM @ echo .
@ REM execute "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash" in every bash.exe call !
@ "%QUARTUS_ROOTDIR%\bin\cygwin\bin\bash.exe" ".\run.sh" --terminal --instance %CPU_NAME% --sopcdir %SOF_DIR%


@ pause
@ exit

:errorQ
@ echo . 
@ echo . Cannot locate Quartus installation (QUARTUS_ROOTDIR) at:
@ echo . 
@ echo .    %QUARTUS_ROOTDIR%
@ echo .    (specifically, the bin\cygwin\bin\bash.exe program within)
@ echo . 
@ echo . Please check your paths and try again (running Quartus from
@ echo . the Start Menu may update the paths and fix this problem).
@ echo . Your Quartus II installation may need to be repaired.
@ echo . 
@ pause
@ exit

:errorN
@ echo . 
@ echo . Cannot locate Nios II Development Kit (SOPC_KIT_NIOS2) at:
@ echo . 
@ echo .    %SOPC_KIT_NIOS2%
@ echo .    (specifically, the nios2_sdk_shell_bashrc file within)
@ echo . 
@ echo . Your Nios II installation may need to be repaired.
@ echo . 
@ pause
@ exit

:errorSOPC
@ echo . 
@ echo . Cannot locate SOF directory (SOF_DIR) at:
@ echo . 
@ echo .    %SOF_DIR%
@ echo .    (setting in run.bat)
@ echo . 
@ echo . Switch to existing path where the sof-file resides!
@ echo . 
@ pause
@ exit

:errorSOF
@ echo . 
@ echo . Missing SOF-file at:
@ echo . 
@ echo .    %SOF_DIR%
@ echo .    (setting in run.bat)
@ echo . 
@ echo . Generate sof with Quartus II or adjust path!
@ echo . 
@ pause
@ exit

@ REM : end of file