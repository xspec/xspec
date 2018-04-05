@echo off

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
rem .xspec files directory
rem
set CASES_DIR=cases

rem
rem XSpec output directory (same as default)
rem
set TEST_DIR=%CASES_DIR%\xspec

rem
rem Run test cases
rem
for %%I in ("%CASES_DIR%\*.xspec") do (
    if /i "%APPVEYOR%"=="True" appveyor AddTest "%%~I" -Framework custom -Filename "%~nx0" -Outcome Running

    rem
    rem Generate the report HTML
    rem
    call :check_test_type "%%~nI"
    if errorlevel 2 (
      "%COMSPEC%" /c ..\..\bin\xspec.bat -s "%%~I" > NUL 2>&1
    ) else if errorlevel 1 (
      "%COMSPEC%" /c ..\..\bin\xspec.bat -q "%%~I" > NUL 2>&1
    ) else (
      "%COMSPEC%" /c ..\..\bin\xspec.bat "%%~I" > NUL 2>&1
    )

    rem
    rem Compare with the expected HTML
    rem
    java -classpath "%SAXON_CP%" net.sf.saxon.Transform -s:"%TEST_DIR%\%%~nI-result.html" -xsl:processor\compare.xsl | findstr /b /l /c:"OK: Compared "
    if errorlevel 1 (
        echo FAILED: %%~I
        if /i "%APPVEYOR%"=="True" appveyor UpdateTest "%%~I" -Framework custom -Filename "%~nx0" -Outcome Failed -Duration 0
        exit /b 1
    )

    if /i "%APPVEYOR%"=="True" appveyor UpdateTest "%%~I" -Framework custom -Filename "%~nx0" -Outcome Passed -Duration 0
)

rem
rem Go back to the initial directory
rem
popd

rem
rem Exit as success
rem
exit /b 0

:check_test_type
    set var=%~1
    if "%var:~0,6%"=="xquery" (
        set TEST_TYPE=1
    ) else if "%var:~0,10%"=="schematron" (
        set TEST_TYPE=2
    ) else (
        set TEST_TYPE=0
    )
    exit /b %TEST_TYPE%

