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
echo === Check XML Calabash for XProc 3
java -jar "%XMLCALABASH3_JAR%" info version

echo:
echo === Print Apache XML Resolver version
java -cp "%APACHE_XMLRESOLVER_JAR%" org.apache.xml.resolver.Version

echo:
echo === Print XMLResolver.org XML Resolver files
where $XMLRESOLVERORG_XMLRESOLVER_LIB:*

echo:
echo === Check BaseX
java -cp "%BASEX_JAR%" org.basex.BaseX -h

echo:
echo === Print environment variables
set

