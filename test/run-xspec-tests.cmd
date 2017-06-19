@echo off

rem ============================================================================
rem
rem    DESCRIPTION:  This script is a Windows version of run-xspec-tests.sh
rem                  See run-xspec-tests.sh for details
rem
rem   DEPENDENCIES:  This script does *not* need to be run from the current directory (i.e. the test directory)
rem
rem ============================================================================

rem
rem Begin localization of environment changes.
rem Also make sure the command processor extensions are enabled.
rem
verify other 2> NUL
setlocal enableextensions
if errorlevel 1 (
    echo Unable to enable extensions
    exit /b %ERRORLEVEL%
)

rem
rem Go to the directory where this script resides
rem
pushd "%~dp0"

rem
rem Result log
rem
set RESULT_FILE=result.log

rem
rem Run tests
rem
for %%I in (*.xspec) do (
    if /i "%APPVEYOR%"=="True" appveyor AddTest "%%~I" -Framework custom -Filename "%~nx0" -Outcome Running

    rem
    rem Run
    rem
    call :is_schematron "%%~nI"
    if errorlevel 1 (
        "%COMSPEC%" /c ..\bin\xspec.bat -s "%%~I" > "%RESULT_FILE%" 2>&1
    ) else (
        "%COMSPEC%" /c ..\bin\xspec.bat "%%~I" > "%RESULT_FILE%" 2>&1
    )

    rem
    rem Inspect result
    rem
    ( findstr /r /c:".*failed: [1-9]" "%RESULT_FILE%" || findstr /r /c:"\*\** Error [a-z][a-z]*ing the test suite" "%RESULT_FILE%" || findstr /r /c:"\*\** Error .*Schematron" "%RESULT_FILE%" ) > NUL
    if not errorlevel 1 (
        echo FAILED: %%~I
        echo ---------- "%RESULT_FILE%"
        type "%RESULT_FILE%"
        echo ----------
        if /i "%APPVEYOR%"=="True" appveyor UpdateTest "%%~I" -Framework custom -Filename "%~nx0" -Outcome Failed -Duration 0
        exit /b 1
    ) else (
        echo OK: %%~I
        if /i "%APPVEYOR%"=="True" appveyor UpdateTest "%%~I" -Framework custom -Filename "%~nx0" -Outcome Passed -Duration 0
    )
)

rem
rem Go back to the initial directory
rem
popd

rem
rem Exit as success
rem
exit /b 0

:is_schematron
    set var=%~1
    if "%var:~0,10%"=="schematron" (
        set IS_SCHEMATRON=1
    ) else (
        set IS_SCHEMATRON=0
    )
    exit /b %IS_SCHEMATRON%
