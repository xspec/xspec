rem
rem Select the mainstream by default
rem
if not defined XSPEC_TEST_ENV set XSPEC_TEST_ENV=saxon-9-9
echo Setting up %XSPEC_TEST_ENV%

rem
rem Load
rem
for /f "eol=# usebackq delims=" %%I in (
    "%~dp0env\global.env"
    "%~dp0env\%XSPEC_TEST_ENV%.env"
) do set "%%~I"

rem
rem Root dir
rem
if not defined XSPEC_DEPS set "XSPEC_DEPS=%TEMP%\xspec"

rem
rem Ant
rem
set "ANT_HOME=%XSPEC_DEPS%\ant\apache-ant-%ANT_VERSION%"
path %ANT_HOME%\bin;%PATH%

rem
rem Saxon
rem
set "SAXON_JAR=%XSPEC_DEPS%\saxon"

rem Keep the original (not Maven) file name convention so that we can test SAXON_HOME properly
if "%SAXON_VERSION:~0,2%"=="9." (
    set "SAXON_JAR=%SAXON_JAR%\saxon9he.jar"
) else (
    set "SAXON_JAR=%SAXON_JAR%\saxon-he-%SAXON_VERSION%.jar"
)

rem
rem XML Resolver
rem
set "XML_RESOLVER_JAR=%XSPEC_DEPS%\xml-resolver\resolver.jar"

rem
rem XML Calabash
rem
if defined XMLCALABASH_VERSION (
    rem Depends on the zip file structure
    set "XMLCALABASH_JAR=%XSPEC_DEPS%\xmlcalabash\xmlcalabash-%XMLCALABASH_VERSION%\xmlcalabash-%XMLCALABASH_VERSION%.jar"
) else (
    echo XML Calabash will not be installed
)

rem
rem BaseX
rem
if defined BASEX_VERSION (
    rem Depends on the zip file structure
    set "BASEX_JAR=%XSPEC_DEPS%\basex\basex\BaseX.jar"
) else (
    echo BaseX will not be installed
)
