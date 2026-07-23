@echo off

setlocal

call :parse-arg %*

rem Check prerequisites
where ant > NUL 2>&1
if errorlevel 1 (
    echo Ant is not found in path >&2
    exit /b 1
)

if not exist "%SAXON_JAR%" (
    echo SAXON_JAR is not found >&2
    exit /b 1
)

if not defined MORGANAXPROC_CP (
    echo MORGANAXPROC_CP is not found >&2
    exit /b 1
)

if not defined MORGANAXPROC_HOME (
    echo MORGANAXPROC_HOME is not found >&2
    exit /b 1
)

if not defined MORGANAXPROC_XSLT_CONNECTOR (
    echo MORGANA_XPROC_XSLT_CONNECTOR is not found >&2
    exit /b 1
)

rem Unset Ant environment variables
set ANT_ARGS=
set ANT_OPTS=

rem Unset XMLResolver.org XML Resolver environment variable
set XMLRESOLVER_PROPERTIES=

rem Reset public environment variables
set "SAXON_CP=%SAXON_JAR%;%XMLRESOLVERORG_XMLRESOLVER_CP%"
set SAXON_CUSTOM_OPTIONS=
set SAXON_HOME=
set TEST_DIR=
set XML_CATALOG=
set XSPEC_HOME=
set XSPEC_HTML_REPORT_THEME=

rem Saxon path for Ant -lib command line option
rem  Note: Ant -lib command line option doesn't seem to accept classpath wildcards.
set "SAXON_ANT_LIB=%SAXON_JAR%;%XMLRESOLVERORG_XMLRESOLVER_LIB%"

rem Full path
set "MERGED_BAT=%TEMP%\%~n0_%RANDOM%.cmd"
set "BAT_SOURCES=%~dp0win-bats"

rem Copy stub
copy "%BAT_SOURCES%\stub.cmd" "%MERGED_BAT%" > NUL
if errorlevel 1 exit /b

rem Append
java -cp "%SAXON_CP%" net.sf.saxon.Transform ^
    -s:"%BAT_SOURCES%\collection-morganaxproc.xml" ^
    -xsl:"%BAT_SOURCES%\generate.xsl" ^
    filter="%FILTER%" ^
    >> "%MERGED_BAT%"
if errorlevel 1 exit /b

rem Run
rem  Launch a child process in order to protect environment from broken test script
"%COMSPEC%" /s /c "cd "%~dp0" && "%MERGED_BAT%""
set TEST_RESULT=%ERRORLEVEL%

rem Delete the generated test script
del "%MERGED_BAT%"
if errorlevel 1 exit /b

rem Exit
exit /b %TEST_RESULT%


rem Parse arg
:parse-arg
    if "%~1"=="" (
        goto :EOF
    ) else if "%~1"=="--filter" (
        set "FILTER=%~2"
        shift
    )

    shift
    goto :parse-arg
