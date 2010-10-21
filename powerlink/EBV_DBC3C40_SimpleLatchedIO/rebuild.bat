@ REM : SDK Shell Batch File for POWERLINK CNDK Build Targets
@ REM : --------------------------------------------------------
@ REM :  - Invokes bash, recompiles the BSP and application
@ REM :  - Programs the FPGA and invokes the nios2 terminal

@ REM ######################################
@ REM # SET PARAMETERS
@ REM It has to be "/", because it is a parameter passed to unix-bash!
@ set SOPC_DIR=../../fpga/altera/EBV_DBC3C40/nios2_openmac_SimpleLatchedIO
@ set SOPC_DIR=../../fpga/altera/TERASIC_DE2-115/nios2_openmac_SimpleLatchedIO

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
@ echo . verifying path...: %~dp0%SOPC_DIR%
@ if not exist "%~dp0%SOPC_DIR%" goto errorSOPC
@ echo . verifying path...OK
@ echo .
@ REM execute "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash" in every bash.exe call !
@ "%QUARTUS_ROOTDIR%\bin\cygwin\bin\bash.exe" ".\rebuild_SimpleLatchedIO.sh" --sopcdir %SOPC_DIR%

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
@ echo . Cannot locate SOPC directory (SOPC_DIR) at:
@ echo . 
@ echo .    %SOPC_DIR%
@ echo .    (setting in rebuild.bat)
@ echo . 
@ echo . Switch to existing path where the sopcinfo-file resides!
@ echo . 
@ pause
@ exit

@ REM : end of file