#! /bin/bash

echo
echo "=== Print Java version"
java -version

echo
echo "=== Print Ant version"
ant -version

echo
echo "=== Print Saxon version"
java -cp "${SAXON_JAR}" net.sf.saxon.Version

echo
echo "=== Check XML Calabash"
java -jar "${XMLCALABASH_JAR}" 2> /dev/null

echo
echo "=== Print XML Resolver version"
java -cp "${XML_RESOLVER_JAR}" org.apache.xml.resolver.Version

echo
echo "=== Check Jing"
java -jar "${JING_JAR}"

echo
echo "=== Check BaseX"
java -cp "${BASEX_JAR}" org.basex.BaseX -h

echo
echo "=== Check BaseX server start and stop"
basex_home=$(dirname -- "${BASEX_JAR}")
"${basex_home}/bin/basexhttp" -S
"${basex_home}/bin/basexhttpstop"

echo
echo "=== Print Bats version"
bats --version

echo
echo "=== Print locale"
locale

echo
echo "=== Print environment variables"
printenv

