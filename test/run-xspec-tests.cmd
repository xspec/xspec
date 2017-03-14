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
rem Is schema-aware processor?
rem
set IS_SCHEMA_AWARE=
for /f %%I in ('java -cp "%SAXON_CP%" net.sf.saxon.Transform -it:main -xsl:schema-aware\is-schema-aware.xsl 2^> NUL') do set IS_SCHEMA_AWARE=%%I

rem
rem Test files
rem
set XSPEC_FILES=*.xspec
if "%IS_SCHEMA_AWARE%"=="yes" set XSPEC_FILES=%XSPEC_FILES% schema-aware\*.xspec

rem
rem Result log
rem
set RESULT_FILE=result.log

rem
rem Run tests
rem
for %%I in (%XSPEC_FILES%) do (
    if /i "%APPVEYOR%"=="True" appveyor AddTest "%%~I" -Framework custom -Filename "%~nx0" -Outcome Running

    rem
    rem Run
    rem
    "%COMSPEC%" /c ..\bin\xspec.bat "%%~I" > "%RESULT_FILE%" 2>&1

    rem
    rem Inspect result
    rem
    findstr /r /c:".*failed: [1-9]" "%RESULT_FILE%" || findstr /r /c:"\*\** Error [a-z][a-z]*ing the test suite" "%RESULT_FILE%"
    if not errorlevel 1 (
        echo FAILED: %%~I
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
