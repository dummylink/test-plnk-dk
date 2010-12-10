@ REM : SDK Shell Batch File for POWERLINK CNDK Build Targets
@ REM : --------------------------------------------------------
@ REM :  
@ REM :  - Programs the FPGA and invokes the nios2 terminal

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
@ REM execute "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash" in every bash.exe call !
@ "%QUARTUS_ROOTDIR%\bin\cygwin\bin\bash.exe" ".\run.sh" --terminal --instance

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