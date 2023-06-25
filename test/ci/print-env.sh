#! /bin/bash

echo
echo "=== Print JRE version"
java -version

echo
echo "=== Print JDK version"
javac -version

echo
echo "=== Print Maven version"
mvn --version

echo
echo "=== Print Ant version"
ant -version

echo
echo "=== Print Saxon version"
java -cp "${SAXON_JAR}" net.sf.saxon.Version

echo
echo "=== Check XML Calabash"
java -cp "${XMLCALABASH_CP}" com.xmlcalabash.drivers.Main 2> /dev/null

echo
echo "=== Print Apache XML Resolver version"
java -cp "${APACHE_XMLRESOLVER_JAR}" org.apache.xml.resolver.Version

echo
echo "=== Check BaseX"
java -cp "${BASEX_JAR}" org.basex.BaseX -h

echo
echo "=== Check BaseX server start and stop"
basex_home=$(dirname -- "${BASEX_JAR}")
"${basex_home}/bin/basexhttp" -S
sleep 5
"${basex_home}/bin/basexhttpstop"

echo
echo "=== Print Bats version"
bats --version

echo
echo "=== Print locale"
locale

echo
echo "=== Print the number of logical processors"
if command -v nproc > /dev/null 2>&1; then
    # Linux
    echo "$(nproc) / $(nproc --all)"
else
    # macOS
    echo "$(sysctl -n hw.logicalcpu) / $(sysctl -n hw.logicalcpu_max)"
fi

echo
echo "=== Print environment variables"
printenv
