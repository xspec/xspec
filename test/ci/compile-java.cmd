echo Compile Java

javac -version 2>&1 | %SYSTEMROOT%\system32\find " 1.8."
if errorlevel 1 (
    echo Skip compiling with incompatible JDK
    verify > NUL
    goto :EOF
)

if not "%SAXON_VERSION:~0,2%"=="9." (
    echo Skip compiling with incompatible Saxon
    goto :EOF
)

call ant -buildfile "%~dp0build_java.xml" %*
