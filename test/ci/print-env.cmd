@echo off

setlocal

echo:
echo === Print JRE version
java -version

echo:
echo === Print JDK version
javac -version

echo:
echo === Print Maven version
call mvn --version

echo:
echo === Print Ant version
call ant -version

echo:
echo === Print Saxon version
java -cp "%SAXON_JAR%" net.sf.saxon.Version

echo:
echo === Check XML Calabash
java -cp "%XMLCALABASH_CP%" com.xmlcalabash.drivers.Main 2> NUL

echo:
echo === Print XML Resolver version
java -cp "%XML_RESOLVER_JAR%" org.apache.xml.resolver.Version

echo:
echo === Check BaseX
java -cp "%BASEX_JAR%" org.basex.BaseX -h 2> NUL

echo:
echo === Check BaseX server start and stop
call "%BASEX_JAR%\..\bin\basexhttp.bat" -S 2> NUL
call "%BASEX_JAR%\..\bin\basexhttpstop.bat" 2> NUL

echo:
echo === Print environment variables
set

