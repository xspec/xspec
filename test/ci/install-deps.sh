#! /bin/bash

#
# Set environment variables
#
myname="${BASH_SOURCE:-$0}"
mydir=$(cd -P -- $(dirname -- "${myname}"); pwd)
source "${mydir}/set-env.sh"

#
# Saxon
#
echo "Install Saxon ${SAXON_VERSION}"
curl -fsSL --create-dirs --retry 5 -o ${SAXON_JAR} https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/${SAXON_VERSION}/Saxon-HE-${SAXON_VERSION}.jar

#
# XML Calabash
#
if [ -n "${XMLCALABASH_VERSION}" ]; then
    echo "Install XML Calabash ${XMLCALABASH_VERSION}"
    curl -fsSL --create-dirs --retry 5 -o ${XSPEC_DEPS}/xmlcalabash/xmlcalabash.zip https://github.com/ndw/xmlcalabash1/releases/download/${XMLCALABASH_VERSION}/xmlcalabash-${XMLCALABASH_VERSION}.zip;
    unzip -q ${XSPEC_DEPS}/xmlcalabash/xmlcalabash.zip -d ${XSPEC_DEPS}/xmlcalabash;
fi

#
# BaseX
#
if [ -n "${BASEX_VERSION}" ]; then
    echo "Install BaseX ${BASEX_VERSION}"
    curl -fsSL --create-dirs --retry 5 -o ${XSPEC_DEPS}/basex/basex.zip http://files.basex.org/releases/${BASEX_VERSION}/BaseX${BASEX_VERSION//./}.zip;
    unzip -q ${XSPEC_DEPS}/basex/basex.zip -d ${XSPEC_DEPS}/basex;
fi

#
# Ant
#
echo "Install Ant ${ANT_VERSION}"
curl -fsSL --create-dirs --retry 5 -o ${XSPEC_DEPS}/ant/ant.tar.gz http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz
tar -xf ${XSPEC_DEPS}/ant/ant.tar.gz -C ${XSPEC_DEPS}/ant;
if [ ! -d "${ANT_HOME}" ] ; then
    # Create dir to invalidate any preinstalled Ant
    mkdir -p "${ANT_HOME}"
fi

#
# XML Resolver
#
echo "Install XML Resolver 1.2"
curl -fsSL --create-dirs --retry 5 -o ${XML_RESOLVER_JAR} https://repo1.maven.org/maven2/xml-resolver/xml-resolver/1.2/xml-resolver-1.2.jar

