echo on

rem root dir
if not defined XSPEC_DEPS set "XSPEC_DEPS=%TEMP%\xspec"

rem determine curl
set "CURL=%SYSTEMROOT%\system32\curl.exe"
if not exist "%CURL%" set CURL=curl
set "CURL=%CURL% -fsSL --create-dirs --retry 5"

rem install Saxon
set "SAXON_JAR=%XSPEC_DEPS%\saxon\saxon9he.jar"
%CURL% -o "%SAXON_JAR%" "https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/%SAXON_VERSION%/Saxon-HE-%SAXON_VERSION%.jar"

rem install XML Calabash
if not defined XMLCALABASH_VERSION (
    echo XML Calabash will not be installed
) else (
    %CURL% -o "%XSPEC_DEPS%\xmlcalabash\xmlcalabash.zip" "https://github.com/ndw/xmlcalabash1/releases/download/%XMLCALABASH_VERSION%/xmlcalabash-%XMLCALABASH_VERSION%.zip"
    call "%~dp0extract-zip.cmd" "%XSPEC_DEPS%\xmlcalabash\xmlcalabash.zip" "%XSPEC_DEPS%\xmlcalabash"
    set "XMLCALABASH_JAR=%XSPEC_DEPS%\xmlcalabash\xmlcalabash-%XMLCALABASH_VERSION%\xmlcalabash-%XMLCALABASH_VERSION%.jar"
)

rem install BaseX
if not defined BASEX_VERSION (
    echo BaseX will not be installed
) else (
    %CURL% -o "%XSPEC_DEPS%\basex\basex.zip" "http://files.basex.org/releases/%BASEX_VERSION%/BaseX%BASEX_VERSION:.=%.zip"
    call "%~dp0extract-zip.cmd" "%XSPEC_DEPS%\basex\basex.zip" "%XSPEC_DEPS%\basex"
    set "BASEX_JAR=%XSPEC_DEPS%\basex\basex\BaseX.jar"
)

rem install Ant without installing JDK
rem call "%~dp0choco-install.cmd" ant --allow-downgrade --ignore-dependencies --no-progress --version "%ANT_VERSION%"
%CURL% -o "%XSPEC_DEPS%\ant\ant.tar.gz" "http://archive.apache.org/dist/ant/binaries/apache-ant-%ANT_VERSION%-bin.tar.gz"
call "%~dp0extract-tgz.cmd" "%XSPEC_DEPS%\ant\ant.tar.gz" "%XSPEC_DEPS%\ant"
set "ANT_HOME=%XSPEC_DEPS%\ant\apache-ant-%ANT_VERSION%"
if not exist "%ANT_HOME%" (
    rem Create dir to invalidate any preinstalled Ant
    mkdir "%ANT_HOME%"
)
path %ANT_HOME%\bin;%PATH%

rem install XML Resolver
set "XML_RESOLVER_JAR=%XSPEC_DEPS%\xml-resolver\resolver.jar"
%CURL% -o "%XML_RESOLVER_JAR%" "https://repo1.maven.org/maven2/xml-resolver/xml-resolver/1.2/xml-resolver-1.2.jar"

rem install Jing
if not defined JING_VERSION (
    echo Jing will not be installed
) else (
    set "JING_JAR=%XSPEC_DEPS%\jing\jing.jar"
)
if defined JING_JAR %CURL% -o "%JING_JAR%" "https://repo1.maven.org/maven2/org/relaxng/jing/%JING_VERSION%/jing-%JING_VERSION%.jar"

rem clean up
set CURL=
