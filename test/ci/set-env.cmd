rem Select the mainstream by default
if not defined XSPEC_TEST_ENV set XSPEC_TEST_ENV=saxon-9-9
echo Setting up %XSPEC_TEST_ENV%

for /f "eol=# usebackq delims=" %%I in (
    "%~dp0env\global.env"
    "%~dp0env\%XSPEC_TEST_ENV%.env"
) do set "%%~I"
