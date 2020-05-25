if not defined AGENT_OSARCHITECTURE exit /b 1

rem "call" is to resolve the target environment variable such as JAVA_HOME_11_X64 dynamically
call set "JAVA_HOME=%%JAVA_HOME_%~1_%AGENT_OSARCHITECTURE%%%"

path %JAVA_HOME%\bin;%PATH%

rem Verify
javac -version 2>&1 | "%SYSTEMROOT%\system32\find" " %~1."
