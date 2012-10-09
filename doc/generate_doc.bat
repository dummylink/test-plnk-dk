@ REM : Batch File for generating POWERLINK CNDK Documentation with doxygen
@ REM : ---------------------------------------------------------------------
@ REM : 
@ REM : 

@ cls
@ echo =======================================================
@ echo  Generate SW Documentation for POWERLINK Slave Dev Kit
@ echo =======================================================
@ echo . Generating all available documentation...
@ echo ==================================================

@ REM ######################################
@ REM # SET PARAMETERS

:LIBRARY_DOC
@ set LIB_DOXYFILE=cnApi.doxyfile
@ set LIB_DOXYFILE_PATH=..\libCnApi

:AP_PDI_DOC
@ set AP_PDI_DOXYFILE=apPdi.doxyfile
@ set AP_PDI_DOXYFILE_PATH=..\apps\ap_PDI\


:start
@ REM ######################################
@ REM # Discover the root nios2eds directory
@ set DOXYGEN_KIT_PATH=C:\Program Files\doxygen
@ REM ######################################

@ REM ######################################
@ REM # Run qreg (if it exists) to setup
@ REM # cygwin and jtag services
:check_doxypackage
@ if not exist "%DOXYGEN_KIT_PATH%\bin\doxygen.exe" goto errorDoxygen
@ REM ######################################

:make_doc
@ cd %LIB_DOXYFILE_PATH%
@ doxygen %LIB_DOXYFILE%

@ cd %AP_PDI_DOXYFILE_PATH%
@ doxygen %AP_PDI_DOXYFILE%

@ echo.
@ echo Documentation generation finished!
@ echo.
@ pause
@ exit

:errorDoxygen
@ echo . 
@ echo . Cannot locate Doxygen installation (DOXYGEN_KIT_PATH) at:
@ echo . 
@ echo .    %DOXYGEN_KIT_PATH%
@ echo .    (specifically, the \bin\doxygen.exe program within)
@ echo . 
@ echo . Install Doxygen on you system in order to generate
@ echo . the documentation, or check you path settings.
@ echo . 
@ pause
@ exit

@ REM : end of file