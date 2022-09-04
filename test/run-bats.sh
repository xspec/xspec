#!/bin/bash

# Get the directory where this script resides
myname="${BASH_SOURCE:-$0}"
mydirname=$(dirname -- "${myname}")
mydir=$(cd -P -- "${mydirname}" && pwd)

# Check prerequisites
if ! command -v ant > /dev/null 2>&1; then
    echo "Ant is not found in path" >&2
    exit 1
fi

if [ ! -f "${SAXON_JAR}" ]; then
    echo "SAXON_JAR is not found" >&2
    exit 1
fi

# If Java 8, unset BASEX_JAR because Java 8 is incompatible with BaseX 10
if java -version 2>&1 | grep -F " 1.8." > /dev/null; then
    export BASEX_JAR=
fi

# Check capabilities
if java -cp "${SAXON_JAR}" net.sf.saxon.Version 2>&1 | grep -F " 9." > /dev/null; then
    export XSLT_SUPPORTS_COVERAGE=1
fi

export SAXON_BUG_4696_FIXED=1
case "${SAXON_VERSION}" in
    "10.0" | "10.1" | "10.2")
        unset SAXON_BUG_4696_FIXED
        ;;
esac

if java -cp "${SAXON_JAR}" net.sf.saxon.Version 2>&1 | grep -F "SAXON-EE " > /dev/null; then
    export XSLT_SUPPORTS_THREADS=1
fi

# Unset JVM environment variables which make output line numbers unpredictable
unset _JAVA_OPTIONS
unset JAVA_TOOL_OPTIONS

# Unset Ant environment variables
unset ANT_ARGS
unset ANT_OPTS

# Unset XML Resolver (of XML Calabash) environment variable
unset XMLRESOLVER_PROPERTIES

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

# Run (in subshell for safer cd)
(cd "${mydir}" && bats --print-output-on-failure --trace "$@" xspec.bats)
