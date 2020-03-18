#! /bin/bash

# root dir
if [ -z ${XSPEC_DEPS} ]; then
    export XSPEC_DEPS=/tmp/xspec
fi

# install Saxon
SAXON_JAR="${XSPEC_DEPS}/saxon"
# Keep the original (not Maven) file name convention so that we can test SAXON_HOME properly
if [ "${SAXON_VERSION:0:2}" = "9." ]; then
    export SAXON_JAR="${SAXON_JAR}/saxon9he.jar"
else
    export SAXON_JAR="${SAXON_JAR}/saxon-he-${SAXON_VERSION}.jar"
fi
curl -fsSL --create-dirs --retry 5 -o ${SAXON_JAR} https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/${SAXON_VERSION}/Saxon-HE-${SAXON_VERSION}.jar

# install XML Calabash
if [ -z ${XMLCALABASH_VERSION} ]; then
    echo "XML Calabash will not be installed";
else
    curl -fsSL --create-dirs --retry 5 -o ${XSPEC_DEPS}/xmlcalabash/xmlcalabash.zip https://github.com/ndw/xmlcalabash1/releases/download/${XMLCALABASH_VERSION}/xmlcalabash-${XMLCALABASH_VERSION}.zip;
    unzip -q ${XSPEC_DEPS}/xmlcalabash/xmlcalabash.zip -d ${XSPEC_DEPS}/xmlcalabash;
    export XMLCALABASH_JAR=${XSPEC_DEPS}/xmlcalabash/xmlcalabash-${XMLCALABASH_VERSION}/xmlcalabash-${XMLCALABASH_VERSION}.jar;
fi

# install BaseX
if [ -z ${BASEX_VERSION} ]; then
    echo "BaseX will not be installed";
else
    curl -fsSL --create-dirs --retry 5 -o ${XSPEC_DEPS}/basex/basex.zip http://files.basex.org/releases/${BASEX_VERSION}/BaseX${BASEX_VERSION//./}.zip;
    unzip -q ${XSPEC_DEPS}/basex/basex.zip -d ${XSPEC_DEPS}/basex;
    export BASEX_JAR=${XSPEC_DEPS}/basex/basex/BaseX.jar;
fi

# install Ant
curl -fsSL --create-dirs --retry 5 -o ${XSPEC_DEPS}/ant/ant.tar.gz http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz
tar -xf ${XSPEC_DEPS}/ant/ant.tar.gz -C ${XSPEC_DEPS}/ant;
export ANT_HOME=${XSPEC_DEPS}/ant/apache-ant-${ANT_VERSION}
if [ ! -d "${ANT_HOME}" ] ; then
    # Create dir to invalidate any preinstalled Ant
    mkdir -p "${ANT_HOME}"
fi
export PATH=${ANT_HOME}/bin:${PATH}

# install XML Resolver
export XML_RESOLVER_JAR=${XSPEC_DEPS}/xml-resolver/resolver.jar
curl -fsSL --create-dirs --retry 5 -o ${XML_RESOLVER_JAR} https://repo1.maven.org/maven2/xml-resolver/xml-resolver/1.2/xml-resolver-1.2.jar

#install Jing
if [ -z ${JING_VERSION} ]; then
    echo "Jing will not be installed";
else
    export JING_JAR=${XSPEC_DEPS}/jing/jing.jar;
    curl -fsSL --create-dirs --retry 5 -o ${JING_JAR} https://repo1.maven.org/maven2/org/relaxng/jing/${JING_VERSION}/jing-${JING_VERSION}.jar;
fi
