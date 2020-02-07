@echo off

setlocal

echo:
echo === Print Java version
java -version

echo:
echo === Print Ant version
call ant -version

echo:
echo === Print Saxon version
java -cp "%SAXON_JAR%" net.sf.saxon.Version

echo:
echo === Check XML Calabash
java -jar "%XMLCALABASH_JAR%" 2> NUL

echo:
echo === Print XML Resolver version
java -cp "%XML_RESOLVER_JAR%" org.apache.xml.resolver.Version

echo:
echo === Check Jing
java -jar "%JING_JAR%"

echo:
echo === Check BaseX
java -cp "%BASEX_JAR%" org.basex.BaseX -h

echo:
echo === Check BaseX server start and stop
call "%BASEX_JAR%\..\bin\basexhttp.bat" -S
call "%BASEX_JAR%\..\bin\basexhttpstop.bat"

echo:
echo === Print environment variables
set

