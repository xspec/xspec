rem determine choco
set CHOCO=choco
if /i "%APPVEYOR%"=="True" set "CHOCO=call appveyor-retry %CHOCO%"

rem install
%CHOCO% install %*
echo on

rem clean up
set CHOCO=

rem reflect new environment variables such as ANT_HOME
if /i not "%APPVEYOR%"=="True" (
    call refreshenv.cmd
    echo on
)
