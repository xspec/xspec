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
rem XSpec output directory
rem
set TEST_DIR=%CASES_DIR%\expected

rem
rem Process .xspec files
rem
for %%I in ("%CASES_DIR%\*.xspec") do (
    echo:
    echo ----------
    echo Processing "%%~I"...

    rem
    rem Generate the report HTML
    rem
    "%COMSPEC%" /c ..\..\bin\xspec.bat "%%~I"

    rem
    rem Normalize the report HTML
    rem
    java -classpath "%SAXON_CP%" net.sf.saxon.Transform -o:"%TEST_DIR%\%%~nI-result-norm.html" -s:"%TEST_DIR%\%%~nI-result.html" -xsl:processor\normalize.xsl
)

rem
rem Go back to the initial directory
rem
popd
