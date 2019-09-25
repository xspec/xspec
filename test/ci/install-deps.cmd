echo on

rem root dir
if not defined XSPEC_DEPS set "XSPEC_DEPS=%TEMP%\xspec"

rem determine curl
set "CURL=%SYSTEMROOT%\system32\curl.exe"
if not exist "%CURL%" set CURL=curl
set "CURL=%CURL% -fsSL --create-dirs --retry 5"

rem determine tar
set "TAR=%SYSTEMROOT%\system32\tar.exe"
if not exist "%TAR%" set TAR=tar

rem install Saxon
set "SAXON_JAR=%XSPEC_DEPS%\saxon\saxon9he.jar"
%CURL% -o "%SAXON_JAR%" "http://central.maven.org/maven2/net/sf/saxon/Saxon-HE/%SAXON_VERSION%/Saxon-HE-%SAXON_VERSION%.jar"

rem install XML Calabash
if not defined XMLCALABASH_VERSION (
    echo XMLCalabash will not be installed as it uses a higher version of Saxon
) else (
    %CURL% -o "%XSPEC_DEPS%\xmlcalabash\xmlcalabash.zip" "https://github.com/ndw/xmlcalabash1/releases/download/%XMLCALABASH_VERSION%/xmlcalabash-%XMLCALABASH_VERSION%.zip"
    %TAR% -xf "%XSPEC_DEPS%\xmlcalabash\xmlcalabash.zip" -C "%XSPEC_DEPS%\xmlcalabash"
    set "XMLCALABASH_JAR=%XSPEC_DEPS%\xmlcalabash\xmlcalabash-%XMLCALABASH_VERSION%\xmlcalabash-%XMLCALABASH_VERSION%.jar"
)

rem install BaseX
if not defined BASEX_VERSION (
    echo BaseX will not be installed as it requires to run XMLCalabash with a higher version of Saxon
) else (
    %CURL% -o "%XSPEC_DEPS%\basex\basex.zip" "http://files.basex.org/releases/%BASEX_VERSION%/BaseX%BASEX_VERSION:.=%.zip"
    %TAR% -xf "%XSPEC_DEPS%\basex\basex.zip" -C "%XSPEC_DEPS%\basex"
    set "BASEX_JAR=%XSPEC_DEPS%\basex\basex\BaseX.jar"
)

rem install Ant without installing JDK
rem call "%~dp0choco-install.cmd" ant --allow-downgrade --ignore-dependencies --no-progress --version "%ANT_VERSION%"
%CURL% -o "%TEMP%\xspec\ant\ant.tar.gz" "http://archive.apache.org/dist/ant/binaries/apache-ant-%ANT_VERSION%-bin.tar.gz"
%TAR% -xf "%TEMP%\xspec\ant\ant.tar.gz" -C "%TEMP%\xspec\ant"
set "ANT_HOME=%TEMP%\xspec\ant\apache-ant-%ANT_VERSION%"
path %ANT_HOME%\bin;%PATH%

rem install XML Resolver
set "XML_RESOLVER_JAR=%XSPEC_DEPS%\xml-resolver\resolver.jar"
%CURL% -o "%XML_RESOLVER_JAR%" "http://central.maven.org/maven2/xml-resolver/xml-resolver/1.2/xml-resolver-1.2.jar"

rem install Jing
if not defined JING_VERSION (
    echo Jing will not be installed
) else (
    set "JING_JAR=%XSPEC_DEPS%\jing\jing.jar"
)
if defined JING_JAR %CURL% -o "%JING_JAR%" "http://central.maven.org/maven2/org/relaxng/jing/%JING_VERSION%/jing-%JING_VERSION%.jar"

rem clean up
set CURL=
set TAR=
