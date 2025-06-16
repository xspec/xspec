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

rem
rem XML Calabash jar for XProc 1
rem
if defined XMLCALABASH_VERSION (
    rem Depends on the archive file structure
    set "XMLCALABASH_JAR=%XSPEC_TEST_DEPS%\xmlcalabash-%XMLCALABASH_VERSION%\xmlcalabash-%XMLCALABASH_VERSION%.jar"
) else (
    echo XML Calabash will not be installed
    set XMLCALABASH_JAR=
)

rem
rem XML Calabash 3 jar for XProc 3
rem Requires Java 11 or later
rem
java -version 2>&1 | "%SYSTEMROOT%\system32\find" " 1.8." > NUL
if not errorlevel 1 set XMLCALABASH3_VERSION=

if defined XMLCALABASH3_VERSION (
    rem Depends on the archive file structure
    set "XMLCALABASH3_JAR=%XSPEC_TEST_DEPS%\xmlcalabash-%XMLCALABASH3_VERSION%\xmlcalabash-app-%XMLCALABASH3_VERSION%.jar"
) else (
    echo XML Calabash 3 will not be installed
    set XMLCALABASH3_JAR=
)

rem
rem SLF4J directory
rem
if defined SLF4J_VERSION (
    set "SLF4J_DIR=%XSPEC_TEST_DEPS%\slf4j-%SLF4J_VERSION%"
) else (
    echo SLF4J will not be installed
    set SLF4J_DIR=
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

rem
rem Classpath
rem

rem XMLResolver.org XML Resolver
set "XMLRESOLVERORG_XMLRESOLVER_CP=%XMLRESOLVERORG_XMLRESOLVER_LIB%\*"

rem XML Calabash for XProc 1
rem Do not include Saxon jar. Excluding Saxon jar from this classpath makes it easy to test with Saxon commercial versions.
set XMLCALABASH_CP=
if defined XMLCALABASH_JAR (
    set "XMLCALABASH_CP=%XMLCALABASH_JAR%;%XMLRESOLVERORG_XMLRESOLVER_CP%"
)
if defined XMLCALABASH_CP if defined SLF4J_DIR (
    set "XMLCALABASH_CP=%XMLCALABASH_CP%;%SLF4J_DIR%\*;%~dp0slf4j-simple"
)
