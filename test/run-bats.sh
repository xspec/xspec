#!/bin/bash

# Get the directory where this script resides
myname="${BASH_SOURCE:-$0}"
mydir=$(cd -P -- $(dirname -- "${myname}"); pwd)

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
if java -jar "${SAXON_JAR}" -nogo -xsl:${mydir}/../src/reporter/coverage-report.xsl 2> /dev/null; then
    export XSLT_SUPPORTS_COVERAGE=1
fi

if java -jar "${SAXON_JAR}" -nogo -xsl:${mydir}/caps/v3-0.xsl 2> /dev/null; then
    export XSLT_SUPPORTS_3_0=1
fi

if java -cp "${SAXON_JAR}" net.sf.saxon.Query -q:${mydir}/caps/v3-1.xquery > /dev/null 2>&1; then
    export XQUERY_SUPPORTS_3_1_DEFAULT=1
fi

# Unset JVM environment variables which make output line numbers unpredictable
unset _JAVA_OPTIONS
unset JAVA_TOOL_OPTIONS

# Unset Ant environment variables
unset ANT_ARGS
unset ANT_OPTS

# Reset public environment variables
export SAXON_CP="${SAXON_JAR}"
unset SAXON_CUSTOM_OPTIONS
unset SAXON_HOME
unset SCHEMATRON_XSLT_COMPILE
unset SCHEMATRON_XSLT_EXPAND
unset SCHEMATRON_XSLT_INCLUDE
unset TEST_DIR
unset XML_CATALOG
unset XSPEC_HOME

# Run
(
    cd "${mydir}"
    bats "$@" xspec.bats
)
