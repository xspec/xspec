#! /bin/bash

echo "Install Jing"
jing_version=20181222
export JING_JAR="/tmp/xspec/jing/jing-${jing_version}.jar"
curl \
    -fsSL \
    --create-dirs \
    --retry 5 \
    --retry-connrefused \
    -o "${JING_JAR}" \
    https://repo1.maven.org/maven2/org/relaxng/jing/${jing_version}/jing-${jing_version}.jar
