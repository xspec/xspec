@echo off

setlocal

set "MERGED_BAT=%~dpn0~TEMP~.cmd"
set "BAT_SOURCES=%~dp0%~n0"

rem Copy stub
copy "%BAT_SOURCES%\stub.cmd" "%MERGED_BAT%" > NUL
if errorlevel 1 exit /b 1

rem Append
java -cp "%SAXON_CP%" net.sf.saxon.Transform -s:"%BAT_SOURCES%\collection.xml" -xsl:"%BAT_SOURCES%\generate.xsl" >> "%MERGED_BAT%"
if errorlevel 1 exit /b 1

rem Execute
rem  Launch a child process in order to protect environment from broken test script
"%COMSPEC%" /s /c "%MERGED_BAT%" %*
