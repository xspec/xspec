rem Latest Ant
set ANT_VERSION=1.10.7

rem Latest BaseX
set BASEX_VERSION=9.3.2

rem Select the mainstream by default
if not defined XSPEC_TEST_ENV set XSPEC_TEST_ENV=saxon-9-9
echo Setting up %XSPEC_TEST_ENV%

rem Note
rem * XML Calabash will use Saxon jar in its own lib directory.
rem * BaseX test requires XML Calabash.
rem * Oxygen is bundled with Ant.

if "%XSPEC_TEST_ENV%"=="saxon-10" (
    rem Latest Saxon 10
    set SAXON_VERSION=10.0
) else if "%XSPEC_TEST_ENV%"=="saxon-9-9" (
    rem Latest Saxon 9.9 and Jing
    set DO_MAVEN_PACKAGE=true
    set JING_VERSION=20181222
    set SAXON_VERSION=9.9.1-7
    set XMLCALABASH_VERSION=1.1.30-99
) else if "%XSPEC_TEST_ENV%"=="saxon-9-8" (
    rem Latest Saxon 9.8
    set SAXON_VERSION=9.8.0-15
    set XMLCALABASH_VERSION=1.1.30-98
) else if "%XSPEC_TEST_ENV%"=="oxygen" (
    rem Latest oXygen
    set ANT_VERSION=1.10.7
    set SAXON_VERSION=9.9.1-5
    set XMLCALABASH_VERSION=1.1.30-99
) else if "%XSPEC_TEST_ENV%"=="saxon-9-7" (
    rem Highest deprecated Saxon
    set SAXON_VERSION=9.7.0-21
) else (
    echo Unknown: %XSPEC_TEST_ENV%
    verify other 2> NUL
    goto :EOF
)
