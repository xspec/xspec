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

if [ -z "${MORGANAXPROC_CP}" ]; then
    echo "MORGANAXPROC_CP is not set" >&2
    exit 1
fi

if [ ! -d "${MORGANAXPROC_HOME}" ]; then
    echo "MORGANAXPROC_HOME is not found" >&2
    exit 1
fi

if [ -z "${MORGANAXPROC_INIT}" ]; then
    echo "MORGANAXPROC_INIT is not set" >&2
    exit 1
fi

if [ -z "${MORGANAXPROC_XSLT_CONNECTOR}" ]; then
    echo "MORGANAXPROC_XSLT_CONNECTOR is not set" >&2
    exit 1
fi

export XPROC_PROCESSOR=morganaxproc

# Check capabilities
export SAXON_BUG_7127_FIXED=1
case "${SAXON_VERSION}" in
    "13.0")
        unset SAXON_BUG_7127_FIXED
        ;;
esac

# Unset JVM environment variables which make output line numbers unpredictable
unset _JAVA_OPTIONS
unset JAVA_TOOL_OPTIONS

# Unset Ant environment variables
unset ANT_ARGS
unset ANT_OPTS

# Unset XMLResolver.org XML Resolver environment variable
unset XMLRESOLVER_PROPERTIES

# Reset public environment variables
unset MORGANAXPROC_CONFIG
export SAXON_CP="${SAXON_JAR}:${XMLRESOLVERORG_XMLRESOLVER_CP}"
unset SAXON_CUSTOM_OPTIONS
unset SAXON_HOME
unset TEST_DIR
unset XML_CATALOG
unset XSPEC_HOME
unset XSPEC_HTML_REPORT_THEME

# Set a certain XML Resolver property that MorganaXProc-III needs.
# MorganaXProc-III normally sets it via xmlresolver.properties, but
# the run-bats machinery uses its own xmlresolver.properties file.
# Here, use an environment variable here so that the settings get pooled.
# Reference: https://www.xmlresolver.org/ResolverFeature/CLASSPATH_CATALOGS.html
export XML_CATALOG_CLASSPATH_CATALOGS=false

# Saxon path for Ant -lib command line option
#  Note: Ant -lib command line option doesn't seem to accept classpath wildcards.
export SAXON_ANT_LIB="${SAXON_JAR}:${XMLRESOLVERORG_XMLRESOLVER_LIB}"

# Run (in subshell for safer cd)
(cd "${mydir}" && bats --print-output-on-failure --trace "$@" morganaxproc.bats)
