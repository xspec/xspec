@echo off

rem
rem Set environment variables
rem
call "%~dp0set-env.cmd"

rem
rem Determine curl
rem
set "CURL=%SYSTEMROOT%\system32\curl.exe"
if not exist "%CURL%" set CURL=curl
set "CURL=%CURL% -fsSL --create-dirs --retry 5"

rem
rem Saxon
rem
echo Install Saxon %SAXON_VERSION%
%CURL% -o "%SAXON_JAR%" "https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/%SAXON_VERSION%/Saxon-HE-%SAXON_VERSION%.jar"

rem
rem XML Calabash
rem
if defined XMLCALABASH_VERSION (
    echo Install XML Calabash %XMLCALABASH_VERSION%
    %CURL% -o "%XSPEC_DEPS%\xmlcalabash\xmlcalabash.zip" "https://github.com/ndw/xmlcalabash1/releases/download/%XMLCALABASH_VERSION%/xmlcalabash-%XMLCALABASH_VERSION%.zip"
    call "%~dp0extract-zip.cmd" "%XSPEC_DEPS%\xmlcalabash\xmlcalabash.zip" "%XSPEC_DEPS%\xmlcalabash"
)

rem
rem BaseX
rem
if defined BASEX_VERSION (
    echo Install BaseX %BASEX_VERSION%
    %CURL% -o "%XSPEC_DEPS%\basex\basex.zip" "http://files.basex.org/releases/%BASEX_VERSION%/BaseX%BASEX_VERSION:.=%.zip"
    call "%~dp0extract-zip.cmd" "%XSPEC_DEPS%\basex\basex.zip" "%XSPEC_DEPS%\basex"
)

rem
rem Ant
rem
echo Install Ant %ANT_VERSION%
%CURL% -o "%XSPEC_DEPS%\ant\ant.tar.gz" "http://archive.apache.org/dist/ant/binaries/apache-ant-%ANT_VERSION%-bin.tar.gz"
call "%~dp0extract-tgz.cmd" "%XSPEC_DEPS%\ant\ant.tar.gz" "%XSPEC_DEPS%\ant"
if not exist "%ANT_HOME%" (
    rem Create dir to invalidate any preinstalled Ant
    mkdir "%ANT_HOME%"
)

rem
rem XML Resolver
rem
echo Install XML Resolver 1.2
%CURL% -o "%XML_RESOLVER_JAR%" "https://repo1.maven.org/maven2/xml-resolver/xml-resolver/1.2/xml-resolver-1.2.jar"

rem
rem Clean up
rem
set CURL=
