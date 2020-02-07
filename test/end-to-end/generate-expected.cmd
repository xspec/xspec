@echo off
setlocal
call ant -buildfile "%~dp0ant\generate-expected\build.xml" -lib "%SAXON_JAR%" %*
