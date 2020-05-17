if not defined AGENT_OSARCHITECTURE exit /b 1

rem "call" is to resolve the target environment variable such as JAVA_HOME_11_X64 dynamically
call set "JAVA_HOME=%%JAVA_HOME_%~1_%AGENT_OSARCHITECTURE%%%"

rem TODO: Remove this workaround. https://github.com/actions/virtual-environments/issues/885
if %~1 EQU 11 set "JAVA_HOME=%ProgramFiles%\Java\zulu-11-azure-jdk_11.33.15-11.0.4-win_%AGENT_OSARCHITECTURE%"

path %JAVA_HOME%\bin;%PATH%

rem Verify
javac -version 2>&1 | "%SYSTEMROOT%\system32\find" " %~1."
