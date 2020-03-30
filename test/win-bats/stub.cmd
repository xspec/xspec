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
set "RESULTS_FILE=%TEMP%\%~n0_results.log"
if exist "%RESULTS_FILE%" call :del "%RESULTS_FILE%"

rem
rem Work directory
rem  - Created at :setup
rem  - Removed recursively at :teardown
rem
set "WORK_DIR=%TEMP%\%~n0_work"

rem
rem Output log files for :run
rem
set "OUTPUT_RAW=%WORK_DIR%\run_raw.log"
set "OUTPUT_FILTERED=%WORK_DIR%\run_filtered.log"
set "OUTPUT_LINENUM=%WORK_DIR%\run_linenum.log"

rem
rem Name and extension of this file
rem
set "THIS_FILE_NX=%~nx0"

rem
rem Go to the directory where this script resides
rem
pushd "%~dp0"

rem
rem Full path to the parent directory
rem
for %%I in (..) do set "PARENT_DIR_ABS=%%~fI"

rem
rem Run tests
rem
echo === START TEST CASES ================================================
set CASE_NUM=1
if not "%~1"=="" set "CASE_NUM=%~1"
call :run-test-cases
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
    echo ---------- "%RESULTS_FILE%"
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

:echo
    rem
    rem Prints a message removing its surrounding quotes (")
    rem
    set "ECHO_LINE=%~1"
    setlocal enabledelayedexpansion
    echo !ECHO_LINE!
    goto :EOF

:copy
    copy %1 %2 > NUL
    if errorlevel 1 call :failed "Failed to copy: %~1 to %~2"
    goto :EOF

:del
    if exist %1 (
        rem DEL returns 0 as long as the parameter is valid
        del %1
        if exist %1 call :failed "Failed to del: %~1"
    ) else (
        call :failed "File not found for del: %~1"
    )
    goto :EOF

:mkdir
    mkdir %1
    if errorlevel 1 call :failed "Failed to mkdir: %~1"
    goto :EOF

:mkdir-if-not-exist
    if not exist %1 call :mkdir %1
    goto :EOF

:rmdir
    if exist %1 (
        rem DEL and RMDIR return 0 as long as the parameter is valid
        del /q "%~1\*"
        rmdir %1
        if exist %1 call :failed "Failed to rmdir: %~1"
    ) else (
        call :failed "Dir not found for rmdir: %~1"
    )
    goto :EOF

:rmdir-if-exist
    if exist %1 call :rmdir %1
    goto :EOF

:rmdir-s
    if exist %1 (
        rem RMDIR returns 0 as long as the parameter is valid
        rmdir /s /q %1
        if exist %1 call :failed "Failed to rmdir /s: %~1"
    ) else (
        call :failed "Dir not found for rmdir /s: %~1"
    )
    goto :EOF

:appveyor
    if /i "%APPVEYOR%"=="True" appveyor %*
    goto :EOF

:setup
    rem
    rem Report 'Running'
    rem
    set "CASE_NAME=%~1"
    call :appveyor AddTest "%CASE_NAME%" -Framework custom -Filename "%THIS_FILE_NX%" -Outcome Running
    call :echo "CASE #%CASE_NUM%: %CASE_NAME%"
    (echo # %CASE_NUM%: "%CASE_NAME%") >> "%RESULTS_FILE%"

    rem
    rem Create the work directory
    rem
    call :mkdir "%WORK_DIR%"

    rem
    rem Set TEST_DIR and xspec.dir within the work directory so that it's cleaned up by teardown
    rem
    set "TEST_DIR=%WORK_DIR%\output_%RANDOM%"
    set ANT_ARGS=-Dxspec.dir="%TEST_DIR%"

    goto :EOF

:teardown
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
    call :echo "...Verified: %~1"
    if not defined CASE_RESULT set CASE_RESULT=0
    goto :EOF

:failed
    call :echo "[91m...FAIL: %~1[0m"
    set CASE_RESULT=1
    (echo %CASE_RESULT%) >> "%RESULTS_FILE%"
    if defined CASE_NAME call :appveyor UpdateTest "%CASE_NAME%" -Framework custom -Filename "%THIS_FILE_NX%" -Outcome Failed -Duration 0 -ErrorMessage %1
    goto :EOF

:skip
    call :echo "[33m...SKIP: %~1[0m"
    set CASE_RESULT=2
    (echo # %1) >> "%RESULTS_FILE%"
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
    rem    Launch a child process in order to localize various environment changes.
    rem    Note that for CMD's /C option, the first parameter starting with a quote char may have a special meaning.
    rem
    "%COMSPEC%" /c %* > "%OUTPUT_RAW%" 2>&1
    set RETVAL=%ERRORLEVEL%

    rem
    rem Normalize CR LF.
    rem Remove the JAVA_TOOL_OPTIONS output, to keep the line numbers predictable.
    rem Remove the empty lines, to be compatible with Bats $lines.
    rem
    type "%OUTPUT_RAW%" | %SYSTEMROOT%\system32\find /v "" | findstr /b /l /v /c:"Picked up JAVA_TOOL_OPTIONS:" | findstr /r /v /c:"^$" > "%OUTPUT_FILTERED%"

    rem
    rem Prefix each line with its line number.
    rem
    type "%OUTPUT_FILTERED%" | %SYSTEMROOT%\system32\find /v /n "" > "%OUTPUT_LINENUM%"

    goto :EOF

:verify_retval
    if %RETVAL% EQU %1 (
        call :verified "Return value: %RETVAL%"
    ) else (
        call :failed "Return value is %RETVAL%. Expected %~1."
        echo ---------- "%OUTPUT_RAW%"
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
    rem Checks to see if the specified line of the output log file matches the specified string
    rem
    rem Parameters:
    rem    1: Line number. Starts with 1, unlike Bats $lines which starts with 0.
    rem        Negative value : Indicates the reverse order. -1 is the last line. -2 is the line before the last line, and so on.
    rem        * : Don't care. Any line.
    rem    2: Operator
    rem        x : Exact match ("=" on Bats)
    rem        r : Compare with regular expression ("=~" on Bats)
    rem    3: Expected string
    rem        For 'r' operator, always evaluated as if the expression started with "^".
    rem

    set LINE_NUMBER=%~1
    if not %LINE_NUMBER%==* if %LINE_NUMBER% LSS 0 for /f %%I in ('type "%OUTPUT_LINENUM%" ^| %SYSTEMROOT%\system32\find /v /c ""') do set /a LINE_NUMBER+=%%I+1

                        set "FIND_STRING=[%LINE_NUMBER%]%~3"
    if /i "%~2"=="r"    set "FIND_STRING=\[%LINE_NUMBER%\]%~3"
    if %LINE_NUMBER%==* set "FIND_STRING=%~3"

                        set "FIND_FILE=%OUTPUT_LINENUM%"
    if %LINE_NUMBER%==* set "FIND_FILE=%OUTPUT_FILTERED%"

    rem
    rem Search the output log file
    rem
    if        /i "%~2"=="x" (
        findstr /l /x /c:"%FIND_STRING%" "%FIND_FILE%" > NUL
    ) else if /i "%~2"=="r" (
        findstr /b /r /c:"%FIND_STRING%" "%FIND_FILE%" > NUL
    ) else (
        call :failed "Bad operator: %~2"
        goto :EOF
    )
    if errorlevel 1 (
        call :failed "Line %LINE_NUMBER% does not match the expected string"
        echo Expected:
        call :echo "%FIND_STRING%"
        echo Actual:
        echo ---------- "%OUTPUT_LINENUM%"
        type "%OUTPUT_LINENUM%"
        echo ----------
    ) else (
        call :verified "Line %LINE_NUMBER%"
    )
    goto :EOF

:verify_line_count
    for /f %%I in ('type "%OUTPUT_LINENUM%" ^| %SYSTEMROOT%\system32\find /v /c ""') do set LINE_COUNT=%%I
    if %LINE_COUNT% EQU %~1 (
        call :verified "Line count: %~1"
    ) else (
        call :failed "Line count %LINE_COUNT% does not match the expected count %~1"
        echo ---------- "%OUTPUT_LINENUM%"
        type "%OUTPUT_LINENUM%"
        echo ----------
    )
    goto :EOF

:verify_exist
    if exist %1 (
        call :verified "Exist: %~1"
    ) else (
        call :failed "Not exist (Expected to exist): %~1"
    )
    goto :EOF

:verify_not_exist
    if exist %1 (
        call :failed "Exist (Expected not to exist): %~1"
    ) else (
        call :verified "Not exist: %~1"
    )
    goto :EOF

rem
rem Test cases
rem
:run-test-cases
    call :get-num-cases
    if %CASE_NUM% GTR %NUM_CASES% goto :EOF

    rem Failsafe
    if %CASE_NUM% GEQ 100 goto :EOF
    if not defined NUM_CASES goto :EOF

    rem Run
    setlocal
    pushd .
    call :case_%CASE_NUM%
    popd
    call :teardown
    endlocal

    rem Next case
    set /a CASE_NUM+=1
    goto :run-test-cases

    rem
    rem Actual test cases will follow
    rem
