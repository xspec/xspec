#! /bin/bash

echo "Install Jing"
jing_version=20181222
export JING_JAR="/tmp/xspec/jing/jing-${jing_version}.jar"

# --connect-timeout is for curl/curl#4461
curl \
    --fail \
    --connect-timeout 20 \
    --create-dirs \
    --location \
    --output "${JING_JAR}" \
    --retry 5 \
    --retry-connrefused \
    --silent \
    --show-error \
    https://repo1.maven.org/maven2/org/relaxng/jing/${jing_version}/jing-${jing_version}.jar
