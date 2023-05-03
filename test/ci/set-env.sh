#! /bin/bash

#
# This script is executed as 'source'. Do not do 'exit'.
#

#
# Select the mainstream by default
#
if [ -z "${XSPEC_TEST_ENV}" ]; then
    export XSPEC_TEST_ENV=saxon-10
fi
echo "Setting up ${XSPEC_TEST_ENV}"

#
# Load
#
myname="${BASH_SOURCE:-$0}"
mydirname=$(dirname -- "${myname}")
mydir=$(cd -P -- "${mydirname}" && pwd)

for f in \
    "${mydir}/env/global.env" \
    "${mydir}/env/${XSPEC_TEST_ENV}.env"; do
    # * "Set environment variables from file of key/value pairs": https://stackoverflow.com/a/49674707
    # * "Process substitution to 'source' do not work on Mac OS": https://stackoverflow.com/a/56060300
    declares=$(grep -E -v '^#|^$|^[^=]+=$' "${f}" | sed -e 's/.*/declare -x "&"/g')
    if [ -n "${declares}" ]; then
        echo "${declares}"
        eval "${declares}"
    fi

    unsets=$(grep -E -v '^#' "${f}" | grep -E '^[^=]+=$' | sed -e 's/=$//' -e 's/.*/unset &/')
    if [ -n "${unsets}" ]; then
        echo "${unsets}"
        eval "${unsets}"
    fi
done

#
# Root dir
#
if [ -z "${XSPEC_TEST_DEPS}" ]; then
    export XSPEC_TEST_DEPS=/tmp/xspec-test-deps
fi

#
# Ant
#

# Depends on the archive file structure
export ANT_HOME="${XSPEC_TEST_DEPS}/apache-ant-${ANT_VERSION}"

# Path component
ant_bin="${ANT_HOME}/bin"

# Remove from PATH
# https://unix.stackexchange.com/a/108933
PATH=":$PATH:"
PATH="${PATH//:${ant_bin}:/:}"
PATH="${PATH#:}"
PATH="${PATH%:}"

# Prepend to PATH
export PATH="${ant_bin}:${PATH}"

#
# Saxon
#
SAXON_JAR="${XSPEC_TEST_DEPS}/saxon-${SAXON_VERSION}"

# Keep the original (not Maven) file name convention so that we can test SAXON_HOME properly
if [ "${SAXON_VERSION:0:2}" = "9." ]; then
    export SAXON_JAR="${SAXON_JAR}/saxon9he.jar"
else
    export SAXON_JAR="${SAXON_JAR}/saxon-he-${SAXON_VERSION}.jar"
fi

#
# XML Resolver
#
export XML_RESOLVER_JAR="${XSPEC_TEST_DEPS}/xml-resolver-${XML_RESOLVER_VERSION}/resolver.jar"

#
# XML Calabash jar
#
if [ -n "${XMLCALABASH_VERSION}" ]; then
    # Depends on the archive file structure
    export XMLCALABASH_JAR="${XSPEC_TEST_DEPS}/xmlcalabash-${XMLCALABASH_VERSION}/xmlcalabash-${XMLCALABASH_VERSION}.jar"
else
    echo "XML Calabash will not be installed"
    unset XMLCALABASH_JAR
fi

#
# SLF4J
#
if [ -n "${SLF4J_VERSION}" ]; then
    export SLF4J_DIR="${XSPEC_TEST_DEPS}/slf4j-${SLF4J_VERSION}"
else
    echo "SLF4J will not be installed"
    unset SLF4J_DIR
fi

#
# XML Calabash classpath
#
if [ -n "${XMLCALABASH_JAR}" ]; then
    export XMLCALABASH_CP="${XMLCALABASH_JAR}:${SAXON_JAR}"
else
    unset XMLCALABASH_CP
fi
if [ -n "${XMLCALABASH_CP}" ] && [ -n "${SLF4J_DIR}" ]; then
    export XMLCALABASH_CP="${XMLCALABASH_CP}:${SLF4J_DIR}/*:${mydir}/slf4j-simple"
fi

#
# BaseX
#
if [ -n "${BASEX_VERSION}" ]; then
    # Depends on the archive file structure
    export BASEX_JAR="${XSPEC_TEST_DEPS}/basex-${BASEX_VERSION}/basex/BaseX.jar"
else
    echo "BaseX will not be installed"
    unset BASEX_JAR
fi
