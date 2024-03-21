#! /bin/bash

echo "Test Maven jar"

if [ "${DO_MAVEN_PACKAGE}" != true ]; then
    echo "Skip Testing Maven jar"
    exit
fi

maven_package_version=$(mvn help:evaluate --quiet -Dexpression=project.version -DforceStdout)

if [ "${GITHUB_ACTIONS}" = true ]; then
    # Propagate the project version as an environment variable to any actions running next in a job
    echo "MAVEN_PACKAGE_VERSION=${maven_package_version}" >> "${GITHUB_ENV}"
fi

myname="${BASH_SOURCE:-$0}"
mydirname=$(dirname -- "${myname}")
mydir=$(cd -P -- "${mydirname}" && pwd)

export XSPEC_MAVEN_JAR="${mydir}/../../target/xspec-${maven_package_version}.jar"

ant \
    -buildfile "${mydir}/build_test-maven-jar.xml" \
    -lib "${SAXON_JAR}:${XMLRESOLVERORG_XMLRESOLVER_LIB}" \
    -lib "${XSPEC_MAVEN_JAR}" \
    "$@"
