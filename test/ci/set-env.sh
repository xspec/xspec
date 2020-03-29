#! /bin/bash

#
# Select the mainstream by default
#
if [ -z "${XSPEC_TEST_ENV}" ]; then
    XSPEC_TEST_ENV=saxon-9-9
fi
echo "Setting up ${XSPEC_TEST_ENV}"

#
# Load
#
myname="${BASH_SOURCE:-$0}"
mydir=$(cd -P -- $(dirname -- "${myname}"); pwd)

for f in \
    "${mydir}/env/global.env" \
    "${mydir}/env/${XSPEC_TEST_ENV}.env"
do
    # * "Set environment variables from file of key/value pairs": https://stackoverflow.com/a/49674707
    # * "Process substitution to 'source' do not work on Mac OS": https://stackoverflow.com/a/56060300
    declares=$(egrep -v '^#|^$' "${f}" | sed -e 's/.*/declare -x "&"/g')
    eval "${declares}"
done

#
# Root dir
#
if [ -z "${XSPEC_DEPS}" ]; then
    export XSPEC_DEPS=/tmp/xspec
fi

#
# Ant
#
export ANT_HOME="${XSPEC_DEPS}/ant/apache-ant-${ANT_VERSION}"
export PATH="${ANT_HOME}/bin:${PATH}"

#
# Saxon
#
SAXON_JAR="${XSPEC_DEPS}/saxon"

# Keep the original (not Maven) file name convention so that we can test SAXON_HOME properly
if [ "${SAXON_VERSION:0:2}" = "9." ]; then
    export SAXON_JAR="${SAXON_JAR}/saxon9he.jar"
else
    export SAXON_JAR="${SAXON_JAR}/saxon-he-${SAXON_VERSION}.jar"
fi

#
# XML Resolver
#
export XML_RESOLVER_JAR="${XSPEC_DEPS}/xml-resolver/resolver.jar"

#
# XML Calabash
#
if [ -n "${XMLCALABASH_VERSION}" ]; then
    # Depends on the zip file structure
    export XMLCALABASH_JAR="${XSPEC_DEPS}/xmlcalabash/xmlcalabash-${XMLCALABASH_VERSION}/xmlcalabash-${XMLCALABASH_VERSION}.jar"
else
    echo "XML Calabash will not be installed"
fi

#
# BaseX
#
if [ -n "${BASEX_VERSION}" ]; then
    # Depends on the zip file structure
    export BASEX_JAR="${XSPEC_DEPS}/basex/basex/BaseX.jar"
else
    echo "BaseX will not be installed"
fi
