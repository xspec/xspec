@echo off
if defined DEBUG @echo on

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
rem Results log file
rem
set RESULTS_FILE=%TEMP%\%~n0_results.log
call :del "%RESULTS_FILE%"

rem
rem Work directory
rem  - Created at :setup
rem  - Removed recursively at :teardown
rem
set WORK_DIR=%TEMP%\%~n0_work

rem
rem Output log files for :run
rem
set OUTPUT_RAW=%WORK_DIR%\run_raw.log
set OUTPUT_LINENUM=%WORK_DIR%\run_linenum.log

rem
rem Name and extension of this file
rem
set THIS_FILE_NX=%~nx0

rem
rem Go to the directory where this script resides
rem
pushd "%~dp0"

rem
rem Full path to the parent directory
rem
for %%I in (..) do set PARENT_DIR_ABS=%%~fI

echo === START TEST CASES ================================================

setlocal
    call :setup "invoking xspec without arguments prints usage"

    call :run ..\bin\xspec.bat
    call :verify_retval 1
    call :verify_line 3 x "Usage: xspec [-t|-q|-s|-c|-j|-h] filename [coverage]"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -s and -t prints error message"

    call :run ..\bin\xspec.bat -s -t
    call :verify_retval 1
    call :verify_line 2 x "-s and -t are mutually exclusive"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -s and -q prints error message"

    call :run ..\bin\xspec.bat -s -q
    call :verify_retval 1
    call :verify_line 2 x "-s and -q are mutually exclusive"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -t and -q prints error message"

    call :run ..\bin\xspec.bat -t -q
    call :verify_retval 1
    call :verify_line 2 x "-t and -q are mutually exclusive"

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon9HE returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9he.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon9SA returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9sa.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon9 returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon8SA returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon8sa.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon8 returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon8.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon9EE creates test stylesheet"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9ee.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Creating Test Stylesheet..."

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon9PE creates test stylesheet"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9pe.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Creating Test Stylesheet..."

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec generates XML report file"

    call :run ..\bin\xspec.bat ..\tutorial\escape-for-regex.xspec
    call :verify_exist ..\tutorial\xspec\escape-for-regex-result.xml

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec generates HTML report file"

    call :run ..\bin\xspec.bat ..\tutorial\escape-for-regex.xspec
    call :verify_exist ..\tutorial\xspec\escape-for-regex-result.html

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -j option with Saxon8 returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon8.jar

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Saxon8 detected. JUnit report requires Saxon9."

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -j option with Saxon8-SA returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon8sa.jar

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Saxon8 detected. JUnit report requires Saxon9."

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -j option generates message with JUnit report location"

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_retval 0
    call :verify_line 19 x "Report available at %PARENT_DIR_ABS%\tutorial\xspec\escape-for-regex-junit.xml"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -j option generates XML report file"

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_exist ..\tutorial\xspec\escape-for-regex-result.xml

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -j option generates JUnit report file"

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_exist ..\tutorial\xspec\escape-for-regex-junit.xml

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with Saxon-B-9-1-0-8 creates test stylesheet"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxonb9-1-0-8.jar

    call :run ..\bin\xspec.bat ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Creating Test Stylesheet..."

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat with TEST_DIR already set externally generates files inside TEST_DIR"

    set TEST_DIR=%WORK_DIR%

    call :run ..\bin\xspec.bat ..\tutorial\escape-for-regex.xspec
    call :verify_retval 0
    call :verify_line 19 x "Report available at %TEST_DIR%\escape-for-regex-result.html"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat without TEST_DIR generates files in default location"

    call :run ..\bin\xspec.bat ..\tutorial\escape-for-regex.xspec
    call :verify_retval 0
    call :verify_line 19 x "Report available at %PARENT_DIR_ABS%\tutorial\xspec\escape-for-regex-result.html"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat that passes a non xs:boolean does not raise a warning #46"

    call :run ..\bin\xspec.bat ..\test\xspec-46.xspec
    call :verify_retval 0
    call :verify_line 4 r "Testing with"

    call :teardown
endlocal

setlocal
    call :setup "executing the Saxon XProc harness generates a report with UTF-8 encoding"

    if defined XMLCALABASH_CP (
        call :run java -Xmx1024m -cp "%XMLCALABASH_CP%" com.xmlcalabash.drivers.Main -isource=xspec-72.xspec -p xspec-home="file:/%PARENT_DIR_ABS:\=/%/" -oresult=xspec/xspec-72-result.html ..\src\harnesses\saxon\saxon-xslt-harness.xproc
        call :run java -cp "%SAXON_CP%" net.sf.saxon.Query -s:xspec\xspec-72-result.html -qs:"declare default element namespace 'http://www.w3.org/1999/xhtml'; concat(/html/head/meta[@http-equiv eq 'Content-Type']/@content = 'text/html; charset=UTF-8', '&#x0A;')" !method=text
        call :verify_line 1 x "true"
    ) else (
        call :skip "test for XProc skipped as XMLCalabash uses a higher version of Saxon"
    )

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat for parentheses dir generates HTML report file #84"

    set PARENTHESES_DIR=%WORK_DIR%\%~n0 (84)
    call :mkdir "%PARENTHESES_DIR%"
    copy ..\tutorial\escape-for-regex.* "%PARENTHESES_DIR%" > NUL

    set EXPECTED_REPORT=%PARENTHESES_DIR%\xspec\escape-for-regex-result.html

    call :run ..\bin\xspec.bat "%PARENTHESES_DIR%\escape-for-regex.xspec"
    call :verify_retval 0
    call :verify_line 20 x "Report available at %EXPECTED_REPORT%"
    call :verify_exist "%EXPECTED_REPORT%"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat with path containing an apostrophe runs successfully #119"

    set APOSTROPHE_DIR=%WORK_DIR%\some'path
    call :mkdir "%APOSTROPHE_DIR%"
    copy ..\tutorial\escape-for-regex.* "%APOSTROPHE_DIR%" > NUL

    call :run ..\bin\xspec.bat "%APOSTROPHE_DIR%\escape-for-regex.xspec"
    call :verify_retval 0
    call :verify_line 20 x "Report available at %APOSTROPHE_DIR%\xspec\escape-for-regex-result.html"

    call :teardown
endlocal

setlocal
    call :setup "Schematron phase/parameters are passed to Schematron compile"

    call :run ..\bin\xspec.bat -s ..\test\schematron-param-001.xspec
    call :verify_retval 0
    call :verify_line 3 x "Paramaters: phase=P1 ?selected=codepoints-to-string((80,49))"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.sh with the -s option does not display Schematron warnings #129 #131"

    call :run ..\bin\xspec.bat -s ..\tutorial\schematron\demo-01.xspec
    call :verify_retval 0
    call :verify_line 5 x "Compiling the Schematron tests..."

    call :teardown
endlocal

setlocal
    call :setup "Cleanup removes temporary files"

    call :run ..\bin\xspec.bat -s ..\tutorial\schematron\demo-03.xspec
    call :verify_retval 0
    call :verify_not_exist ..\tutorial\schematron\demo-03.xspec-compiled.xspec
    call :run dir /on ..\tutorial\schematron\xspec
    call :verify_line 9 r ".*3 File.*"
    call :verify_exist ..\tutorial\schematron\xspec\demo-03-result.html
    call :verify_exist ..\tutorial\schematron\xspec\demo-03-result.xml
    call :verify_exist ..\tutorial\schematron\xspec\demo-03.xsl

    call :teardown
endlocal

echo === END TEST CASES ==================================================

rem
rem Go back to the initial directory
rem
popd

rem
rem Retrieve the results and determine the exit code
rem
for /f "usebackq eol=# delims=" %%I in ("%RESULTS_FILE%") do if %%I EQU 0 set EXIT_CODE=%%I
for /f "usebackq eol=# delims=" %%I in ("%RESULTS_FILE%") do if %%I NEQ 0 set EXIT_CODE=%%I
if not defined EXIT_CODE (
    echo No test cases performed!
    set EXIT_CODE=1
)
if %EXIT_CODE% NEQ 0 (
    echo ---------- %RESULTS_FILE%
    type "%RESULTS_FILE%"
    echo ----------
)
call :del "%RESULTS_FILE%"

rem
rem Exit
rem
echo EXIT_CODE=%EXIT_CODE%
exit /b %EXIT_CODE%

rem
rem Subroutines
rem

:del
    if exist %1 (
        del /q %1
        if errorlevel 1 call :failed "Failed to del: %~1"
    )
    goto :EOF

:mkdir
    mkdir %1
    if errorlevel 1 call :failed "Failed to mkdir: %~1"
    goto :EOF

:rmdir
    if exist %1 (
        call :del "%~1\*"
        rmdir %1
        if errorlevel 1 call :failed "Failed to rmdir: %~1"
    )
    goto :EOF

:rmdir-s
    if exist %1 (
        rmdir /s /q %1
        if errorlevel 1 call :failed "Failed to rmdir /s: %~1"
    )
    goto :EOF

:appveyor
    if /i "%APPVEYOR%"=="True" appveyor %*
    goto :EOF

:setup
    rem
    rem Report 'Running'
    rem
    set CASE_NAME=%~1
    call :appveyor AddTest "%CASE_NAME%" -Framework custom -Filename "%THIS_FILE_NX%" -Outcome Running
    echo CASE: %CASE_NAME%
    (echo # %CASE_NAME%) >> "%RESULTS_FILE%"

    rem
    rem Create the work directory
    rem
    call :mkdir "%WORK_DIR%"

    rem
    rem Create the XSpec output directories
    rem
    call :mkdir ..\test\xspec
    call :mkdir ..\tutorial\xspec
    call :mkdir ..\tutorial\schematron\xspec

    goto :EOF

:teardown
    rem
    rem Remove the XSpec output directories
    rem
    call :rmdir ..\test\xspec
    call :rmdir ..\tutorial\xspec
    call :rmdir ..\tutorial\schematron\xspec

    rem
    rem Remove the work directory
    rem
    call :rmdir-s "%WORK_DIR%"

    rem
    rem Report 'Passed'
    rem
    if %CASE_RESULT% EQU 0 (
        echo ...PASS
        (echo %CASE_RESULT%) >> "%RESULTS_FILE%"
        call :appveyor UpdateTest "%CASE_NAME%" -Framework custom -Filename "%THIS_FILE_NX%" -Outcome Passed -Duration 0
    )
    goto :EOF

:verified
    echo ...Verified: %~1
    if not defined CASE_RESULT set CASE_RESULT=0
    goto :EOF

:failed
    echo ...FAIL: %~1
    set CASE_RESULT=1
    (echo %CASE_RESULT%) >> "%RESULTS_FILE%"
    if defined CASE_NAME call :appveyor UpdateTest "%CASE_NAME%" -Framework custom -Filename "%THIS_FILE_NX%" -Outcome Failed -Duration 0 -ErrorMessage %1
    goto :EOF

:skip
    echo ...SKIP: %~1
    set CASE_RESULT=2
    (echo # %~1) >> "%RESULTS_FILE%"
    call :appveyor UpdateTest "%CASE_NAME%" -Framework custom -Filename "%THIS_FILE_NX%" -Outcome Skipped -Duration 0
    goto :EOF

:run
    rem
    rem Executes the specified command line.
    rem Saves stdout and stderr in a single file.
    rem Saves the return value in RETVAL.
    rem

    rem
    rem Print parameters and env vars
    rem
    echo ...%0 @ %TIME%: %*
    rem set SAXON_
    rem set TEST_
    rem set XSPEC

    rem
    rem Run
    rem
    "%COMSPEC%" /c %* > "%OUTPUT_RAW%" 2>&1
    set RETVAL=%ERRORLEVEL%

    rem
    rem Remove the JAVA_TOOL_OPTIONS output, to keep the line numbers predictable.
    rem Remove the empty lines, to be compatible with Bats $lines.
    rem Prefix each line with its line number.
    rem
    findstr /b /l /v /c:"Picked up JAVA_TOOL_OPTIONS:" "%OUTPUT_RAW%" | findstr /r /v /c:"^$" | find /v /n "" > "%OUTPUT_LINENUM%"

    goto :EOF

:verify_retval
    if %RETVAL% EQU %1 (
        call :verified "Return value: %RETVAL%"
    ) else (
        call :failed "Return value is %RETVAL%. Expected %~1."
        echo ---------- %OUTPUT_RAW%
        type "%OUTPUT_RAW%"
        echo ----------
    )
    goto :EOF

:verify_line
    if defined DEBUG (
        echo *: %*
        echo 0: %0
        echo 1: %1
        echo 2: %2
        echo 3: %3
    )
    rem
    rem Checks to see if the specified line of the output log file matches exactly the specified string
    rem
    rem Parameters:
    rem    1: Line number. Starts with 1, unlike Bats $lines which starts with 0.
    rem    2: Operator
    rem        x : Exact match ("=" on Bats)
    rem        r : Compare with regular expression ("=~" on Bats)
    rem    3: Expected string
    rem        For 'r' operator, always evaluated as if the expression started with "^".
    rem

    rem
    rem Search the line-numbered output log file
    rem
    if        /i "%~2"=="x" (
        findstr /l /x /c:"[%~1]%~3" "%OUTPUT_LINENUM%" > NUL
    ) else if /i "%~2"=="r" (
        findstr /b /r /c:"\[%~1\]%~3" "%OUTPUT_LINENUM%" > NUL
    ) else (
        call :failed "Bad operator: %~2"
        goto :EOF
    )
    if errorlevel 1 (
        call :failed "Line %~1 does not match the expected string"
        echo ---------- %OUTPUT_LINENUM%
        type "%OUTPUT_LINENUM%"
        echo ----------
    ) else (
        call :verified "Line %~1"
    )
    goto :EOF

:verify_exist
    if exist %1 (
        call :verified "Exist: %~1"
    ) else (
        call :failed "Not exist: %~1"
    )
    goto :EOF

:verify_not_exist
    if exist %1 (
        call :failed "Exist: %~1"
    ) else (
        call :verified "Not exist: %~1"
    )
    goto :EOF