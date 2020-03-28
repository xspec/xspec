rem root dir
if not defined XSPEC_DEPS set "XSPEC_DEPS=%TEMP%\xspec"

rem determine curl
set "CURL=%SYSTEMROOT%\system32\curl.exe"
if not exist "%CURL%" set CURL=curl
set "CURL=%CURL% -fsSL --create-dirs --retry 5"

echo Install Saxon
set "SAXON_JAR=%XSPEC_DEPS%\saxon"
rem Keep the original (not Maven) file name convention so that we can test SAXON_HOME properly
if "%SAXON_VERSION:~0,2%"=="9." (
    set "SAXON_JAR=%SAXON_JAR%\saxon9he.jar"
) else (
    set "SAXON_JAR=%SAXON_JAR%\saxon-he-%SAXON_VERSION%.jar"
)
%CURL% -o "%SAXON_JAR%" "https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/%SAXON_VERSION%/Saxon-HE-%SAXON_VERSION%.jar"

echo Install XML Calabash
if not defined XMLCALABASH_VERSION (
    echo XML Calabash will not be installed
) else (
    %CURL% -o "%XSPEC_DEPS%\xmlcalabash\xmlcalabash.zip" "https://github.com/ndw/xmlcalabash1/releases/download/%XMLCALABASH_VERSION%/xmlcalabash-%XMLCALABASH_VERSION%.zip"
    call "%~dp0extract-zip.cmd" "%XSPEC_DEPS%\xmlcalabash\xmlcalabash.zip" "%XSPEC_DEPS%\xmlcalabash"
    set "XMLCALABASH_JAR=%XSPEC_DEPS%\xmlcalabash\xmlcalabash-%XMLCALABASH_VERSION%\xmlcalabash-%XMLCALABASH_VERSION%.jar"
)

echo Install BaseX
if not defined BASEX_VERSION (
    echo BaseX will not be installed
) else (
    %CURL% -o "%XSPEC_DEPS%\basex\basex.zip" "http://files.basex.org/releases/%BASEX_VERSION%/BaseX%BASEX_VERSION:.=%.zip"
    call "%~dp0extract-zip.cmd" "%XSPEC_DEPS%\basex\basex.zip" "%XSPEC_DEPS%\basex"
    set "BASEX_JAR=%XSPEC_DEPS%\basex\basex\BaseX.jar"
)

echo Install Ant without installing JDK
rem call "%~dp0choco-install.cmd" ant --allow-downgrade --ignore-dependencies --no-progress --version "%ANT_VERSION%"
%CURL% -o "%XSPEC_DEPS%\ant\ant.tar.gz" "http://archive.apache.org/dist/ant/binaries/apache-ant-%ANT_VERSION%-bin.tar.gz"
call "%~dp0extract-tgz.cmd" "%XSPEC_DEPS%\ant\ant.tar.gz" "%XSPEC_DEPS%\ant"
set "ANT_HOME=%XSPEC_DEPS%\ant\apache-ant-%ANT_VERSION%"
if not exist "%ANT_HOME%" (
    rem Create dir to invalidate any preinstalled Ant
    mkdir "%ANT_HOME%"
)
path %ANT_HOME%\bin;%PATH%

echo Install XML Resolver
set "XML_RESOLVER_JAR=%XSPEC_DEPS%\xml-resolver\resolver.jar"
%CURL% -o "%XML_RESOLVER_JAR%" "https://repo1.maven.org/maven2/xml-resolver/xml-resolver/1.2/xml-resolver-1.2.jar"

rem clean up
set CURL=
