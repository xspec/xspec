@echo off
setlocal
call ant -silent -buildfile "%~dp0ant\build.xml" -lib "%SAXON_CP%" %*
