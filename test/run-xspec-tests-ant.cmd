@echo off
setlocal
set ANT_ARGS=-buildfile "%~dp0ant\build.xml" -lib "%SAXON_CP%" %*
if /i "%APPVEYOR%"=="True" set ANT_ARGS=%ANT_ARGS% -Dappveyor.filename="%~nx0"
call ant
