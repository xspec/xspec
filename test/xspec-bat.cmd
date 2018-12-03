@echo off

setlocal

set "MERGED_BAT=%~dpn0~TEMP~.cmd"
set "BAT_SOURCES=%~dp0%~n0"

rem Copy stub
copy "%BAT_SOURCES%\stub.cmd" "%MERGED_BAT%" > NUL
if errorlevel 1 exit /b 1

rem Append
type "%BAT_SOURCES%\collection.cmd" >> "%MERGED_BAT%"
echo "goto :EOF" >> "%MERGED_BAT%"

rem Execute
rem  Launch a child process in order to protect environment from broken test script
"%COMSPEC%" /s /c "%MERGED_BAT%" %*
