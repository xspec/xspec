#! /bin/bash

# Latest Ant
export ANT_VERSION=1.10.7

# Latest BaseX
export BASEX_VERSION=9.3.2

# Select the mainstream by default
if [ -z "${XSPEC_TEST_ENV}" ]; then
    XSPEC_TEST_ENV=saxon-9-9
fi
echo "Setting up ${XSPEC_TEST_ENV}"

# Note
# * XML Calabash will use Saxon jar in its own lib directory.
# * BaseX test requires XML Calabash.
# * Oxygen is bundled with Ant.

case "${XSPEC_TEST_ENV}" in
    # Latest Saxon 10
    "saxon-10" )
        export SAXON_VERSION=10.0
        ;;

    # Latest Saxon 9.9 and Jing
    "saxon-9-9" )
        export DO_MAVEN_PACKAGE=true
        export JING_VERSION=20181222
        export SAXON_VERSION=9.9.1-7
        export XMLCALABASH_VERSION=1.1.30-99
        ;;

    # Latest Saxon 9.8
    "saxon-9-8" )
        export SAXON_VERSION=9.8.0-15
        export XMLCALABASH_VERSION=1.1.30-98
        ;;

    # Latest oXygen
    "oxygen" )
        export ANT_VERSION=1.10.7
        export SAXON_VERSION=9.9.1-5
        export XMLCALABASH_VERSION=1.1.30-99
        ;;

    # Highest deprecated Saxon
    "saxon-9-7" )
        export SAXON_VERSION=9.7.0-21
        ;;

    * )
        echo "Unknown: ${XSPEC_TEST_ENV}"
        exit 1
        ;;
esac
