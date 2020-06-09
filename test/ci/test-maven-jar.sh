#! /bin/bash

echo "Test Maven jar"

if [ -z "${MAVEN_PACKAGE_VERSION}" ]; then
    echo "Skip Testing Maven jar"
    exit
fi

# Coverage HTML report file
actual_report_dir="${PWD}/test/end-to-end/cases/actual__/stylesheet"
if [ ! -d "${actual_report_dir}" ]; then
    mkdir "${actual_report_dir}" || exit
fi
export COVERAGE_HTML="${actual_report_dir}/coverage-tutorial-coverage.html"
rm -f "${COVERAGE_HTML}" || exit

# Replace *.class...
echo "Delete *.class"
find java/ -type f -name '*.class' -delete -print || exit

# ...with jar
export SAXON_CP="${SAXON_JAR}:target/xspec-${MAVEN_PACKAGE_VERSION}.jar"

# Run
bin/xspec.sh -c test/end-to-end/cases/coverage-tutorial.xspec \
    || exit

# Verify Coverage HTML report
java -jar "${SAXON_JAR}" \
    -s:"${COVERAGE_HTML}" \
    -xsl:test/end-to-end/processor/coverage/compare.xsl \
    EXPECTED-DOC-URI="file:${actual_report_dir}/../../expected/stylesheet/coverage-tutorial-coverage.html"
