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

# Check capabilities
export XSLT_SUPPORTS_COVERAGE=1
if [ "${SAXON_VERSION:0:2}" != "9." ]; then
    unset export XSLT_SUPPORTS_COVERAGE
fi

export XSLT_SUPPORTS_THREADS=1
if ! java -cp "${SAXON_JAR}" net.sf.saxon.Version 2>&1 | grep -F -- "-EE " > /dev/null; then
    unset XSLT_SUPPORTS_THREADS
fi

export SAXON_BUG_4696_FIXED=1
case "${SAXON_VERSION}" in
    "10.0" | "10.1" | "10.2")
        unset SAXON_BUG_4696_FIXED
        ;;
esac

export XMLRESOLVERORG_XMLRESOLVER_BUG_117_FIXED=1
case "${XMLRESOLVERORG_XMLRESOLVER_VERSION}" in
    "4.5.0")
        unset XMLRESOLVERORG_XMLRESOLVER_BUG_117_FIXED
        ;;
esac

# TODO: Stop skipping these tests once Oxygen picks up Saxon 12.4+
export SAXON12_INITIAL_ISSUES_FIXED=1
if [ "${SAXON_VERSION}" == "12.3" ]; then
    unset SAXON12_INITIAL_ISSUES_FIXED
fi

# Unset JVM environment variables which make output line numbers unpredictable
unset _JAVA_OPTIONS
unset JAVA_TOOL_OPTIONS

# Unset Ant environment variables
unset ANT_ARGS
unset ANT_OPTS

# Unset XMLResolver.org XML Resolver environment variable
unset XMLRESOLVER_PROPERTIES

# Reset public environment variables
export SAXON_CP="${SAXON_JAR}:${XMLRESOLVERORG_XMLRESOLVER_CP}"
unset SAXON_CUSTOM_OPTIONS
unset SAXON_HOME
unset SCHEMATRON_XSLT_COMPILE
unset SCHEMATRON_XSLT_EXPAND
unset SCHEMATRON_XSLT_INCLUDE
unset TEST_DIR
unset XML_CATALOG
unset XSPEC_HOME

# Saxon path for Ant -lib command line option
#  Note: Ant -lib command line option doesn't seem to accept classpath wildcards.
export SAXON_ANT_LIB="${SAXON_JAR}:${XMLRESOLVERORG_XMLRESOLVER_LIB}"

# Run (in subshell for safer cd)
(cd "${mydir}" && bats --print-output-on-failure --trace "$@" xspec.bats)
