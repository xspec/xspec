rem
rem Select the mainstream by default
rem
if not defined XSPEC_TEST_ENV set XSPEC_TEST_ENV=saxon-10
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
rem Saxon
rem
set "SAXON_JAR=%XSPEC_TEST_DEPS%\saxon-%SAXON_VERSION%"

rem Keep the original (not Maven) file name convention so that we can test SAXON_HOME properly
if "%SAXON_VERSION:~0,2%"=="9." (
    set "SAXON_JAR=%SAXON_JAR%\saxon9he.jar"
) else (
    set "SAXON_JAR=%SAXON_JAR%\saxon-he-%SAXON_VERSION%.jar"
)

rem
rem XML Resolver
rem
set "XML_RESOLVER_JAR=%XSPEC_TEST_DEPS%\xml-resolver-%XML_RESOLVER_VERSION%\resolver.jar"

rem
rem XML Calabash jar
rem
if defined XMLCALABASH_VERSION (
    rem Depends on the archive file structure
    set "XMLCALABASH_JAR=%XSPEC_TEST_DEPS%\xmlcalabash-%XMLCALABASH_VERSION%\xmlcalabash-%XMLCALABASH_VERSION%.jar"
) else (
    echo XML Calabash will not be installed
    set XMLCALABASH_JAR=
)

rem
rem Log4j
rem
if defined LOG4J_VERSION (
    set "LOG4J_DIR=%XSPEC_TEST_DEPS%\log4j-%LOG4J_VERSION%"
) else (
    echo Log4j will not be installed
    set LOG4J_DIR=
)

rem
rem XML Calabash classpath
rem
if defined XMLCALABASH_JAR (
    set "XMLCALABASH_CP=%XMLCALABASH_JAR%;%SAXON_JAR%"
) else (
    set XMLCALABASH_CP=
)
if defined XMLCALABASH_CP if defined LOG4J_DIR (
    set "XMLCALABASH_CP=%XMLCALABASH_CP%;%LOG4J_DIR%\*"
)

rem
rem BaseX
rem

rem BaseX 10 requires Java 11
java -version 2>&1 | "%SYSTEMROOT%\system32\find" " 1.8." > NUL
if not errorlevel 1 set BASEX_VERSION=

if defined BASEX_VERSION (
    rem Depends on the archive file structure
    set "BASEX_JAR=%XSPEC_TEST_DEPS%\basex-%BASEX_VERSION%\basex\BaseX.jar"
) else (
    echo BaseX will not be installed
    set BASEX_JAR=
)
