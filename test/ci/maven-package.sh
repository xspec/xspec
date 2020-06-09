#! /bin/bash

echo "Maven package"

if [ "${DO_MAVEN_PACKAGE}" = true ]; then
    if [ "${GITHUB_ACTIONS}" = true ]; then
        # Propagate the project version as an environment variable to any actions running next in a job
        echo "::set-env name=MAVEN_PACKAGE_VERSION::$(mvn help:evaluate --quiet -Dexpression=project.version -DforceStdout)"

        # And also Saxon for testing
        echo "::set-env name=SAXON_JAR::${SAXON_JAR}"
    fi

    mvn package -P release "$@"
else
    echo "Skip Maven package"
fi
