rem
rem Select the mainstream by default
rem
if not defined XSPEC_TEST_ENV set XSPEC_TEST_ENV=saxon-12
echo Setting up %XSPEC_TEST_ENV%

rem
rem Load
rem
for /f "eol=# usebackq delims=" %%I in (
    "%~dp0env\global.env"
    "%~dp0env\%XSPEC_TEST_ENV%.env"
) do (
    echo set "%%~I"
    set "%%~I"
)

rem
rem Root dir
rem
if not defined XSPEC_TEST_DEPS set "XSPEC_TEST_DEPS=%TEMP%\xspec-test-deps"

rem
rem Ant
rem

rem Depends on the archive file structure
set "ANT_HOME=%XSPEC_TEST_DEPS%\apache-ant-%ANT_VERSION%"

rem Path component
set "ANT_BIN=%ANT_HOME%\bin"

rem Remove from PATH
rem https://unix.stackexchange.com/a/108933
path ;%PATH%;
call path %%PATH:;%ANT_BIN%;=;%%
if "%PATH:~0,1%"==";" path %PATH:~1%
if "%PATH:~-1%" ==";" path %PATH:~0,-1%

rem Prepend to PATH
path %ANT_BIN%;%PATH%

rem Clean up
set ANT_BIN=

rem
rem Saxon jar
rem
set "SAXON_JAR=%XSPEC_TEST_DEPS%\saxon-%SAXON_VERSION%"

rem Keep the original (not Maven) file name convention so that we can test SAXON_HOME properly
set "SAXON_JAR=%SAXON_JAR%\saxon-he-%SAXON_VERSION%.jar"


rem
rem Apache XML Resolver jar
rem
set "APACHE_XMLRESOLVER_JAR=%XSPEC_TEST_DEPS%\apache-xmlresolver-%APACHE_XMLRESOLVER_VERSION%\resolver.jar"

rem
rem XMLResolver.org XML Resolver lib directory
rem
rem Depends on the archive file structure
set "XMLRESOLVERORG_XMLRESOLVER_LIB=%XSPEC_TEST_DEPS%\xmlresolver-%XMLRESOLVERORG_XMLRESOLVER_VERSION%\lib"

if defined XMLCALABASH3_VERSION (
    rem Depends on the archive file structure
    set "XMLCALABASH3_DIR=%XSPEC_TEST_DEPS%\xmlcalabash-%XMLCALABASH3_VERSION%"
) else (
    echo XML Calabash 3 will not be installed
    set XMLCALABASH3_DIR=
)
if defined XMLCALABASH3_VERSION if defined XMLCALABASH3_DIR (
    set "XMLCALABASH3_JAR=%XMLCALABASH3_DIR%\xmlcalabash-app-%XMLCALABASH3_VERSION%.jar"
) else (
    set XMLCALABASH3_JAR=
)

rem
rem BaseX
rem

if defined BASEX_VERSION (
    rem Depends on the archive file structure
    set "BASEX_JAR=%XSPEC_TEST_DEPS%\basex-%BASEX_VERSION%\basex\BaseX.jar"
) else (
    echo BaseX will not be installed
    set BASEX_JAR=
)

rem
rem Classpath
rem

rem XMLResolver.org XML Resolver
set "XMLRESOLVERORG_XMLRESOLVER_CP=%XMLRESOLVERORG_XMLRESOLVER_LIB%\*"
