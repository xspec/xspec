#!/bin/bash

# Check prerequisites
if ! which ant > /dev/null 2>&1; then
    echo "Ant is not found in path" >&2
    exit 1
fi

if [ ! -f "${SAXON_JAR}" ]; then
    echo "SAXON_JAR is not found" >&2
    exit 1
fi

# Check capabilities
if java -jar "${SAXON_JAR}" -nogo -xsl:../src/reporter/coverage-report.xsl 2> /dev/null; then
	export XSLT_SUPPORTS_COVERAGE=1
fi

# Reset public environment variables
export SAXON_CP="${SAXON_JAR}"
unset SAXON_HOME

# Run
bats "$@" xspec.bats
