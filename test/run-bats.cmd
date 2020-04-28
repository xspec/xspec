@echo off

setlocal

rem Check prerequisites
where ant > NUL 2>&1
if errorlevel 1 (
    echo Ant is not found in path >&2
    exit /b %ERRORLEVEL%
)

if not exist "%SAXON_JAR%" (
    echo SAXON_JAR is not found >&2
    exit /b 1
)

rem Check capabilities
java -cp "%SAXON_JAR%" net.sf.saxon.Version 2>&1 | "%SYSTEMROOT%\system32\find" " 9." > NUL
if not errorlevel 1 set XSLT_SUPPORTS_COVERAGE=1

rem Unset Ant environment variables
set ANT_ARGS=
set ANT_OPTS=

rem Reset public environment variables
set "SAXON_CP=%SAXON_JAR%"
set SAXON_CUSTOM_OPTIONS=
set SAXON_HOME=
set SCHEMATRON_XSLT_COMPILE=
set SCHEMATRON_XSLT_EXPAND=
set SCHEMATRON_XSLT_INCLUDE=
set TEST_DIR=
set XML_CATALOG=
set XSPEC_HOME=

rem Full path
set "MERGED_BAT=%~dpn0~TEMP~.cmd"
set "BAT_SOURCES=%~dp0win-bats"

rem Copy stub
copy "%BAT_SOURCES%\stub.cmd" "%MERGED_BAT%" > NUL
if errorlevel 1 exit /b 1

rem Append
java -jar "%SAXON_JAR%" -s:"%BAT_SOURCES%\collection.xml" -xsl:"%BAT_SOURCES%\generate.xsl" >> "%MERGED_BAT%"
if errorlevel 1 exit /b 1

rem Run
rem  Launch a child process in order to protect environment from broken test script
"%COMSPEC%" /s /c "%MERGED_BAT%" %*
