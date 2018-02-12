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
rem Is schema-aware processor?
rem
set IS_SCHEMA_AWARE=
for /f %%I in ('java -cp "%SAXON_CP%" net.sf.saxon.Transform -it:main -xsl:..\schema-aware\is-schema-aware.xsl 2^> NUL') do set IS_SCHEMA_AWARE=%%I

rem
rem Test files
rem
set XSPEC_FILES="%CASES_DIR%\*.xspec"
if "%IS_SCHEMA_AWARE%"=="yes" set XSPEC_FILES=%XSPEC_FILES% "%CASES_DIR%\schema-aware\*.xspec"

rem
rem XSpec output directory
rem
set TEST_DIR=%CASES_DIR%\expected

rem
rem Process .xspec files
rem
for %%I in (%XSPEC_FILES%) do (
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
