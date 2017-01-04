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
rem Output log files
rem
set OUTPUT_RAW=%TEMP%\%~n0_raw.log
call :del "%OUTPUT_RAW%"
set OUTPUT_LINENUM=%TEMP%\%~n0_linenum.log
call :del "%OUTPUT_LINENUM%"

rem
rem Result log file
rem
set RESULTS_FILE=%TEMP%\%~n0_result.log
call :del "%RESULTS_FILE%"

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
    call :begin "invoking xspec without arguments prints usage"

    call :run ..\bin\xspec.bat
    call :verify_retval 1
    call :verify_line 3 "Usage: xspec [-t|-q|-c|-j|-h] filename [coverage]"

    call :end
endlocal

setlocal
    call :begin "invoking code coverage with Saxon9HE returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9he.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :end
endlocal

setlocal
    call :begin "invoking code coverage with Saxon9SA returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9sa.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :end
endlocal

setlocal
    call :begin "invoking code coverage with Saxon9 returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :end
endlocal

setlocal
    call :begin "invoking code coverage with Saxon8SA returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon8sa.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :end
endlocal

setlocal
    call :begin "invoking code coverage with Saxon8 returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon8.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :end
endlocal

rem
rem this test must run first to create xspec directory
rem
setlocal
    call :begin "invoking code coverage with Saxon9EE creates test stylesheet"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9ee.jar

    rem
    rem Clear the residue of xspec directory
    rem
    call :del ..\tutorial\xspec\*
    if exist ..\tutorial\xspec\ rmdir ..\tutorial\xspec\

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 3 "Creating Test Stylesheet..."

    call :end
endlocal

setlocal
    call :begin "invoking code coverage with Saxon9PE creates test stylesheet"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9pe.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 "Creating Test Stylesheet..."

    call :end
endlocal

setlocal
    call :begin "invoking xspec generates XML report file"

    set EXPECTED_REPORT=..\tutorial\xspec\escape-for-regex-result.xml
    call :del "%EXPECTED_REPORT%"

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_exist "%EXPECTED_REPORT%"

    call :end
endlocal

setlocal
    call :begin "invoking xspec generates HTML report file"

    set EXPECTED_REPORT=..\tutorial\xspec\escape-for-regex-result.html
    call :del "%EXPECTED_REPORT%"

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_exist "%EXPECTED_REPORT%"

    call :end
endlocal

setlocal
    call :begin "invoking xspec with -j option with Saxon8 returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon8.jar

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 "Saxon8 detected. JUnit report requires Saxon9."

    call :end
endlocal

setlocal
    call :begin "invoking xspec with -j option with Saxon8-SA returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon8sa.jar

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 "Saxon8 detected. JUnit report requires Saxon9."

    call :end
endlocal

setlocal
    call :begin "invoking xspec with -j option generates message with JUnit report location"

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_retval 0
    call :verify_line 19 "Report available at %PARENT_DIR_ABS%\tutorial\xspec\escape-for-regex-junit.xml"

    call :end
endlocal

setlocal
    call :begin "invoking xspec with -j option generates XML report file"

    set EXPECTED_REPORT=..\tutorial\xspec\escape-for-regex-junit.xml
    call :del "%EXPECTED_REPORT%"

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_exist "%EXPECTED_REPORT%"

    call :end
endlocal

setlocal
    call :begin "invoking xspec with -j option generates JUnit report file"

    set EXPECTED_REPORT=..\tutorial\xspec\escape-for-regex-junit.xml
    call :del "%EXPECTED_REPORT%"

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_exist "%EXPECTED_REPORT%"

    call :end
endlocal

setlocal
    call :begin "invoking xspec with Saxon-B-9-1-0-8 creates test stylesheet"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxonb9-1-0-8.jar

    call :run ..\bin\xspec.bat ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 "Creating Test Stylesheet..."

    call :end
endlocal

setlocal
    call :begin "invoking xspec.bat with TEST_DIR already set externally generates files inside TEST_DIR"

    set TEST_DIR=%TEMP%\%~n0
    if not exist "%TEST_DIR%" mkdir "%TEST_DIR%"

    call :run ..\bin\xspec.bat ..\tutorial\escape-for-regex.xspec
    call :verify_retval 0
    call :verify_line 19 "Report available at %TEST_DIR%\escape-for-regex-result.html"

    call :end
endlocal

setlocal
    call :begin "invoking xspec.bat without TEST_DIR generates files in default location"

    call :run ..\bin\xspec.bat ..\tutorial\escape-for-regex.xspec
    call :verify_retval 0
    call :verify_line 19 "Report available at %PARENT_DIR_ABS%\tutorial\xspec\escape-for-regex-result.html"

    call :end
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
    if exist %1 del /q %1
    goto :EOF

:begin
    set CASE_NAME=%~1

    if /i "%APPVEYOR%"=="True" appveyor AddTest "%CASE_NAME%" -Framework custom -Filename "%THIS_FILE_NX%" -Outcome Running

    echo CASE: %CASE_NAME%

    (echo # %CASE_NAME%) >> "%RESULTS_FILE%"
    goto :EOF

:end
    if %CASE_RESULT% EQU 0 (
        echo ...PASS
        (echo %CASE_RESULT%) >> "%RESULTS_FILE%"
        if /i "%APPVEYOR%"=="True" appveyor UpdateTest "%CASE_NAME%" -Framework custom -Filename "%THIS_FILE_NX%" -Outcome Passed -Duration 0
    )

    rem
    rem Delete the output log files if any
    rem
    call :del "%OUTPUT_RAW%"
    call :del "%OUTPUT_LINENUM%"
    goto :EOF

:verified
    echo ...Verified: %~1
    if not defined CASE_RESULT set CASE_RESULT=0
    goto :EOF

:failed
    echo ...FAIL: %~1
    set CASE_RESULT=1
    (echo %CASE_RESULT%) >> "%RESULTS_FILE%"
    if /i "%APPVEYOR%"=="True" appveyor UpdateTest "%CASE_NAME%" -Framework custom -Filename "%THIS_FILE_NX%" -Outcome Failed -Duration 0 -ErrorMessage %1
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
    rem
    rem Checks to see if the specified line of the output log file matches exactly the specified string
    rem
    rem Parameters:
    rem    1: Line number. Starts with 1, unlike Bats $lines which starts with 0.
    rem    2: Expected string
    rem

    rem
    rem Search the line-numbered output log file
    rem
    findstr /l /x /c:"[%~1]%~2" "%OUTPUT_LINENUM%" > NUL
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
