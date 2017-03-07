@echo off

rem
rem ##############################################################################
rem ##
rem ## This script is used to compile a test suite to XSLT, run it, format
rem ## the report and open it in a browser.
rem ##
rem ## It relies on the environment variable SAXON_HOME to be set to the
rem ## dir Saxon has been installed to (i.e. the containing the Saxon JAR
rem ## file), or on SAXON_CP to be set to a full classpath containing
rem ## Saxon (and maybe more).  The latter has precedence over the former.
rem ##
rem ## It also uses the environment variable XSPEC_HOME.  It must be set
rem ## to the XSpec install directory.  By default, it uses this script's
rem ## parent dir.
rem ##
rem ## TODO: Not aware of the EXPath Packaging System
rem ##
rem ##############################################################################
rem
rem Comments (rem)
rem    Comments starting with '#' are derived from xspec.sh (possibly with
rem    some modifications).
rem
rem Environment variables (%FOO%)
rem    Environment variables are tried to be on parity with xspec.sh,
rem    except that those starting with 'WIN_' are only for this batch
rem    file.
rem
rem Labels (:foo)
rem    Labels are tried to be on parity with functions in xspec.sh, except
rem    that those starting with 'win_' are only for this batch file.
rem

rem
rem Skip over "utility functions"
rem
goto :win_main_enter

rem ##
rem ## utility functions #########################################################
rem ##

:usage
    if not "%~1"=="" (
        echo %~1
        echo:
    )
    echo Usage: xspec [-t^|-q^|-c^|-j^|-h] filename [coverage]
    echo:
    echo   filename   the XSpec document
    echo   -t         test an XSLT stylesheet (the default)
    echo   -q         test an XQuery module (mutually exclusive with -t)
    echo   -c         output test coverage report
    echo   -j         output JUnit report
    echo   -h         display this help message
    echo   coverage   deprecated, use -c instead
    goto :EOF

:die
    echo:
    echo *** %~1 >&2
    rem
    rem Now, to exit the batch file, you must go to :win_main_error_exit from
    rem the main code flow.
    rem
    goto :EOF

:xslt
    java -cp "%CP%" net.sf.saxon.Transform %*
    goto :EOF

:win_xslt_trace
    rem
    rem Inner Redirect:
    rem    By swapping stdout and stderr, send stderr to pipe (as stdout)
    rem    while allowing original stdout to survive (as stderr)
    rem
    rem Pipe:
    rem    To keep the output XML well-formed, remove the stdout lines
    rem    that don't look like XML element, assuming %COVERAGE_CLASS%
    rem    emits every required line in this format
    rem
    rem Outer Redirect:
    rem    To restore the original direction, swap stdout and stderr again 
    rem
    ( java -cp "%CP%" net.sf.saxon.Transform %* 3>&2 2>&1 1>&3 | findstr /r /c:"^<..*>$" ) 3>&2 2>&1 1>&3
    goto :EOF

:xquery
    java -cp "%CP%" net.sf.saxon.Query %*
    goto :EOF

:win_xquery_trace
    rem
    rem As for redirect and pipe, see :win_xslt_trace
    rem
    ( java -cp "%CP%" net.sf.saxon.Query %* 3>&2 2>&1 1>&3 | findstr /r /c:"^<..*>$" ) 3>&2 2>&1 1>&3
    goto :EOF

:win_reset_options
    set XSLT=
    set XQUERY=
    set COVERAGE=
    set JUNIT=
    set WIN_HELP=
    set WIN_UNKNOWN_OPTION=
    set WIN_DEPRECATED_COVERAGE=
    set WIN_EXTRA_OPTION=
    set XSPEC=
    goto :EOF

:win_get_options
    set WIN_ARGV=%~1

    if not defined WIN_ARGV (
        goto :EOF
    ) else if "%WIN_ARGV%"=="-t" (
        set XSLT=1
    ) else if "%WIN_ARGV%"=="-q" (
        set XQUERY=1
    ) else if "%WIN_ARGV%"=="-c" (
        set COVERAGE=1
    ) else if "%WIN_ARGV%"=="-j" (
        set JUNIT=1
    ) else if "%WIN_ARGV%"=="-h" (
        set WIN_HELP=1
    ) else if "%WIN_ARGV:~0,1%"=="-" (
        set WIN_UNKNOWN_OPTION=%WIN_ARGV%
    ) else if defined XSPEC (
        if "%WIN_ARGV%"=="coverage" (
            set WIN_DEPRECATED_COVERAGE=1
        ) else (
            set WIN_EXTRA_OPTION=%WIN_ARGV%
            goto :EOF
        )
    ) else (
        set XSPEC=%WIN_ARGV%
    )

    shift

    rem
    rem %* doesn't reflect shift. Pass %n individually.
    rem
    call :win_get_options %1 %2 %3 %4 %5 %6 %7 %8 %9
    goto :EOF

rem
rem Main #########################################################################
rem
:win_main_enter

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
rem To be compatible with xspec.sh, do not omit this message. It makes the
rem test automation easier.
rem
echo Saxon script not found, invoking JVM directly instead.
echo:

rem
rem ##
rem ## some variables ############################################################
rem ##
rem

rem
rem # the command to use to open the final HTML report
rem
rem Include the command line options (and consequently the double quotes)
rem if necessary.
rem
set OPEN=start "XSpec Report"

rem
rem # set XSPEC_HOME if it has not been set by the user (set it to the
rem # parent dir of this script)
rem
if not defined XSPEC_HOME set XSPEC_HOME=%~dp0..

rem
rem # safety checks
rem
for %%I in ("%XSPEC_HOME%") do echo "%%~aI" | find "d" > NUL
if errorlevel 1 (
    echo ERROR: XSPEC_HOME is not a directory: %XSPEC_HOME%
    exit /b 1
)
if not exist "%XSPEC_HOME%\src\compiler\generate-common-tests.xsl" (
    echo ERROR: XSPEC_HOME seems to be corrupted: %XSPEC_HOME%
    exit /b 1
)

rem
rem # set SAXON_CP (either it has been by the user, or set it from SAXON_HOME)
rem

rem
rem # Set this variable in your environment or here, if you don't set SAXON_CP
rem # set SAXON_HOME=C:\path\to\saxon\dir
rem
rem Since we don't use the delayed environment variable expansion,
rem SAXON_HOME must be set outside 'if' scope.
rem

if not defined SAXON_CP (
    if not defined SAXON_HOME (
        echo SAXON_CP and SAXON_HOME both not set!
    )
    if        exist "%SAXON_HOME%\saxon9ee.jar" (
        set SAXON_CP=%SAXON_HOME%\saxon9ee.jar
    ) else if exist "%SAXON_HOME%\saxon9pe.jar" (
        set SAXON_CP=%SAXON_HOME%\saxon9pe.jar
    ) else if exist "%SAXON_HOME%\saxon9he.jar" (
        set SAXON_CP=%SAXON_HOME%\saxon9he.jar
    ) else if exist "%SAXON_HOME%\saxon9sa.jar" (
        set SAXON_CP=%SAXON_HOME%\saxon9sa.jar
    ) else if exist "%SAXON_HOME%\saxon9.jar" (
        set SAXON_CP=%SAXON_HOME%\saxon9.jar
    ) else if exist "%SAXON_HOME%\saxonb9-1-0-8.jar" (
        set SAXON_CP=%SAXON_HOME%\saxonb9-1-0-8.jar
    ) else if exist "%SAXON_HOME%\saxon8sa.jar" (
        set SAXON_CP=%SAXON_HOME%\saxon8sa.jar
    ) else if exist "%SAXON_HOME%\saxon8.jar" (
        set SAXON_CP=%SAXON_HOME%\saxon8.jar
    ) else (
        echo Saxon jar cannot be found in SAXON_HOME: %SAXON_HOME%
    )
)

set CP=%SAXON_CP%;%XSPEC_HOME%\java

rem
rem ##
rem ## options ###################################################################
rem ##
rem

rem
rem JAR filename
rem
for %%I in ("%SAXON_CP%") do set WIN_SAXON_CP_N=%%~nI

rem
rem Parse command line
rem
call :win_reset_options
call :win_get_options %*

rem
rem # XSLT
rem # XQuery
rem
if defined XSLT if defined XQUERY (
    call :usage "-t and -q are mutually exclusive"
    exit /b 1
)

rem
rem # Coverage
rem
if defined COVERAGE (
    if /i not "%WIN_SAXON_CP_N%"=="saxon9pe" if /i not "%WIN_SAXON_CP_N%"=="saxon9ee" (
        echo Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE.
        exit /b 1
    )
)

rem
rem # JUnit report
rem
if defined JUNIT (
    if /i "%WIN_SAXON_CP_N:~0,6%"=="saxon8" (
        echo Saxon8 detected. JUnit report requires Saxon9.
        exit /b 1
    )
)

rem
rem # Help!
rem
if defined WIN_HELP (
    call :usage
    exit /b 0
)

rem
rem # Unknown option!
rem
if defined WIN_UNKNOWN_OPTION (
    call :usage "Error: Unknown option: %WIN_UNKNOWN_OPTION%"
    exit /b 1
)

rem
rem # set XSLT if XQuery has not been set (that's the default)
rem
if not defined XSLT if not defined XQUERY set XSLT=1

if not exist "%XSPEC%" (
    call :usage "Error: File not found."
    exit /b 1
)

rem
rem Extra option
rem
if defined WIN_EXTRA_OPTION (
    call :usage "Error: Extra option: %WIN_EXTRA_OPTION%"
    exit /b 1
)

rem
rem Deprecated 'coverage' option
rem
if defined WIN_DEPRECATED_COVERAGE (
    echo Long-form option 'coverage' deprecated, use '-c' instead.
    if /i not "%WIN_SAXON_CP_N%"=="saxon9pe" if /i not "%WIN_SAXON_CP_N%"=="saxon9ee" (
        echo Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE.
        exit /b 1
    )
    set COVERAGE=1
)

rem
rem Env var no longer necessary
rem
set WIN_SAXON_CP_N=

rem
rem ##
rem ## files and dirs ############################################################
rem ##
rem

if not defined TEST_DIR for %%I in ("%XSPEC%") do set TEST_DIR=%%~dpIxspec
for %%I in ("%XSPEC%") do set TARGET_FILE_NAME=%%~nI

if defined XSLT (
    set COMPILED=%TEST_DIR%\%TARGET_FILE_NAME%.xsl
) else (
    set COMPILED=%TEST_DIR%\%TARGET_FILE_NAME%.xq
)
set COVERAGE_XML=%TEST_DIR%\%TARGET_FILE_NAME%-coverage.xml
set COVERAGE_HTML=%TEST_DIR%\%TARGET_FILE_NAME%-coverage.html
set RESULT=%TEST_DIR%\%TARGET_FILE_NAME%-result.xml
set HTML=%TEST_DIR%\%TARGET_FILE_NAME%-result.html
set JUNIT_RESULT=%TEST_DIR%\%TARGET_FILE_NAME%-junit.xml
set COVERAGE_CLASS=com.jenitennison.xslt.tests.XSLTCoverageTraceListener

if not exist "%TEST_DIR%" (
    echo Creating XSpec Directory at %TEST_DIR%...
    mkdir "%TEST_DIR%"
    echo:
)

rem
rem ##
rem ## compile the suite #########################################################
rem ##
rem

if defined XSLT (
    set COMPILE_SHEET=generate-xspec-tests.xsl
) else (
    set COMPILE_SHEET=generate-query-tests.xsl
)
echo Creating Test Stylesheet...
call :xslt -o:"%COMPILED%" -s:"%XSPEC%" ^
    -xsl:"%XSPEC_HOME%\src\compiler\%COMPILE_SHEET%" ^
    || ( call :die "Error compiling the test suite" & goto :win_main_error_exit )
echo:

rem
rem ##
rem ## run the suite #############################################################
rem ##
rem

echo Running Tests...
if defined XSLT (
    rem
    rem # for XSLT
    rem
    if defined COVERAGE (
        echo Collecting test coverage data; suppressing progress report...
        call :win_xslt_trace -T:%COVERAGE_CLASS% ^
            -o:"%RESULT%" -s:"%XSPEC%" -xsl:"%COMPILED%" ^
            -it:{http://www.jenitennison.com/xslt/xspec}main 2> "%COVERAGE_XML%" ^
            || ( call :die "Error collecting test coverage data" & goto :win_main_error_exit )
    ) else (
        call :xslt -o:"%RESULT%" -s:"%XSPEC%" -xsl:"%COMPILED%" ^
            -it:{http://www.jenitennison.com/xslt/xspec}main ^
            || ( call :die "Error running the test suite" & goto :win_main_error_exit )
    )
) else (
    rem
    rem # for XQuery
    rem
    if defined COVERAGE (
        echo Collecting test coverage data; suppressing progress report...
        call :win_xquery_trace -T:%COVERAGE_CLASS% ^
            -o:"%RESULT%" -s:"%XSPEC%" "%COMPILED%" 2> "%COVERAGE_XML%" ^
            || ( call :die "Error collecting test coverage data" & goto :win_main_error_exit )
    ) else (
        call :xquery -o:"%RESULT%" -s:"%XSPEC%" "%COMPILED%" ^
            || ( call :die "Error running the test suite" & goto :win_main_error_exit )
    )
)

rem
rem ##
rem ## format the report #########################################################
rem ##
rem

echo:
echo Formatting Report...
call :xslt -o:"%HTML%" ^
    -s:"%RESULT%" ^
    -xsl:"%XSPEC_HOME%\src\reporter\format-xspec-report.xsl" ^
    || ( call :die "Error formatting the report" & goto :win_main_error_exit )

rem
rem Absolute path of the XSPEC env var
rem
for %%I in ("%XSPEC%") do set WIN_XSPEC_ABS=%%~fI

if defined COVERAGE (
    rem
    rem For $tests and $pwd, convert the native file path to a wannabe-
    rem URI. The peculiar implementation of Java prefers the following
    rem forms (if it's absolute).
    rem
    rem    For drive: file:/c:/dir/file
    rem    For UNC:   file:////host/share/dir/file
    rem
    rem Note that in terms of the native file path, coverage-report.xsl
    rem handles $tests and $pwd differently.
    rem
    rem    Scheme ('file:')
    rem
    rem        $tests
    rem            The XSPEC env var may be absolute or relative. If
    rem            relative, we need to omit 'file:' from $tests.
    rem            For simplicity, we always obtain the absolute path of
    rem            the XSPEC env var and prefix it with 'file:'.
    rem
    rem        $pwd
    rem            The CD env var is always absolute. So we always prefix
    rem            it with 'file:'.
    rem
    rem    '\' character
    rem
    rem        $tests
    rem            coverage-report.xsl replaces '\' with '/'. You can
    rem            leave '\' intact here.
    rem
    rem        $pwd
    rem            coverage-report.xsl does nothing. You have to replace
    rem            '\' with '/' here.
    rem
    rem    UNC
    rem
    rem        $tests
    rem            You have to care about UNC.
    rem
    rem        $pwd
    rem            You don't have to care about UNC. By default CMD.EXE
    rem            does not accept UNC as the current directory.
    rem
    rem We don't escape any characters here. Too much for this simple
    rem batch script. Fortunately Saxon 9.7 seems to be more tolerant of
    rem space chars than 9.6.
    rem
    call :xslt -l:on ^
        -o:"%COVERAGE_HTML%" ^
        -s:"%COVERAGE_XML%" ^
        -xsl:"%XSPEC_HOME%\src\reporter\coverage-report.xsl" ^
        tests="file:/%WIN_XSPEC_ABS:\\=/\\%" ^
        pwd="file:/%CD:\=/%/" ^
        || ( call :die "Error formating the coverage report" & goto :win_main_error_exit )
    echo Report available at %COVERAGE_HTML%
    rem %OPEN% "%COVERAGE_HTML%"
) else if defined JUNIT (
    call :xslt -o:"%JUNIT_RESULT%" ^
        -s:"%RESULT%" ^
        -xsl:"%XSPEC_HOME%\src\reporter\junit-report.xsl" ^
        || ( call :die "Error formating the JUnit report" & goto :win_main_error_exit )
    echo Report available at %JUNIT_RESULT%
) else (
    echo Report available at %HTML%
    rem %OPEN% "%HTML%"
)

echo Done.
exit /b

rem 
rem Error exit ###################################################################
rem 
:win_main_error_exit
if errorlevel 1 (
    exit /b %ERRORLEVEL%
) else (
    exit /b 1
)
