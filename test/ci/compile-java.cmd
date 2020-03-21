echo Compile Java

javac -version 2>&1 | %SYSTEMROOT%\system32\find " 1.8."
if errorlevel 1 (
    echo Skip compiling Java
    verify > NUL
) else (
    call ant -buildfile "%~dp0build_java.xml" %*
)
