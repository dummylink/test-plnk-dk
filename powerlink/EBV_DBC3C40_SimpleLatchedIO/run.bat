@ REM : SDK Shell Batch File for POWERLINK CNDK Build Targets
@ REM : --------------------------------------------------------
@ REM :  - Invokes bash, recompiles the BSP and application
@ REM :  - Programs the FPGA and invokes the nios2 terminal

@ REM ######################################
@ REM # Discover the root nios2eds directory
@ set SOPC_KIT_NIOS2=%SOPC_KIT_NIOS2%
rem echo SOPC_KIT_NIOS2 directory is set to: "%SOPC_KIT_NIOS2%"
rem pause
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
rem echo Quartus root directory is set to: "%QUARTUS_ROOTDIR%"
rem pause
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
@ if "%WIN32_SDK_SHELL_PROJECT_PATH%" == "" goto cd_to_examples
@ cd /D %WIN32_SDK_SHELL_PROJECT_PATH%
@ goto run_bash
:cd_to_examples
@ if exist "examples" cd examples
@ REM We dont need this...

:run_bash
@ REM execute "$QUARTUS_ROOTDIR/sopc_builder/bin/nios_bash" in every bash.exe call !
@ "%QUARTUS_ROOTDIR%\bin\cygwin\bin\bash.exe" --rcfile ".\BuildandRun_SimpleLatchedIO.sh"
@ REM "%QUARTUS_ROOTDIR%\bin\cygwin\bin\bash.exe" --rcfile ".\nios2-terminal.sh"
@ REM %QUARTUS_ROOTDIR%\\bin\\quartus_pgm.exe -m jtag -c USB-Blaster[USB-0] -o "p;DE2_115_Audio.sof"

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

@ REM : end of file