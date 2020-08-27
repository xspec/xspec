#! /bin/bash

echo "Test Maven jar"

if [ "${DO_MAVEN_PACKAGE}" != true ]; then
    echo "Skip Testing Maven jar"
    exit
fi

maven_package_version=$(mvn help:evaluate --quiet -Dexpression=project.version -DforceStdout)

if [ "${GITHUB_ACTIONS}" = true ]; then
    # Propagate the project version as an environment variable to any actions running next in a job
    echo "::set-env name=MAVEN_PACKAGE_VERSION::${maven_package_version}"
fi

myname="${BASH_SOURCE:-$0}"
mydirname=$(dirname -- "${myname}")
mydir=$(cd -P -- "${mydirname}" && pwd)

xspec_maven_jar="${mydir}/../../target/xspec-${maven_package_version}.jar"

ant \
    -buildfile "${mydir}/build_test-maven-jar.xml" \
    -lib "${SAXON_JAR}" \
    -lib "${xspec_maven_jar}" \
    -Dtest-maven-jar.jar.file="${xspec_maven_jar}" \
    "$@"
