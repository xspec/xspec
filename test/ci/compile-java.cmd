echo Compile Java

setlocal

javac -version 2>&1 | "%SYSTEMROOT%\system32\find" " 17."
if not errorlevel 1 (
    echo Skip compiling with incompatible JDK
    exit /b 0
)

for %%I in (9.9 10. 11.) do if "%SAXON_VERSION:~0,3%"=="%%I" (
    echo Skip compiling with incompatible Saxon
    exit /b 0
)

call ant -buildfile "%~dp0build_java.xml" %*
