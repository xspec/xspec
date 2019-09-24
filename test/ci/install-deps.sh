#! /bin/bash

# install Saxon
export SAXON_JAR=/tmp/xspec/saxon/saxon9he.jar
curl -fsSL --create-dirs --retry 5 -o ${SAXON_JAR} http://central.maven.org/maven2/net/sf/saxon/Saxon-HE/${SAXON_VERSION}/Saxon-HE-${SAXON_VERSION}.jar

# install XML Calabash
if [ -z ${XMLCALABASH_VERSION} ]; then
    echo "XMLCalabash will not be installed as it uses a higher version of Saxon";
else
    curl -fsSL --create-dirs --retry 5 -o /tmp/xspec/xmlcalabash/xmlcalabash.zip https://github.com/ndw/xmlcalabash1/releases/download/${XMLCALABASH_VERSION}/xmlcalabash-${XMLCALABASH_VERSION}.zip;
    unzip /tmp/xspec/xmlcalabash/xmlcalabash.zip -d /tmp/xspec/xmlcalabash;
    export XMLCALABASH_JAR=/tmp/xspec/xmlcalabash/xmlcalabash-${XMLCALABASH_VERSION}/xmlcalabash-${XMLCALABASH_VERSION}.jar;
fi

# install BaseX
if [[ -z ${XMLCALABASH_VERSION} && -z ${BASEX_VERSION} ]]; then
    echo "BaseX will not be installed as it requires to run XMLCalabash with a higher version of Saxon";
else
    curl -fsSL --create-dirs --retry 5 -o /tmp/xspec/basex/basex.zip http://files.basex.org/releases/${BASEX_VERSION}/BaseX${BASEX_VERSION//./}.zip;
    unzip /tmp/xspec/basex/basex.zip -d /tmp/xspec/basex;
    export BASEX_JAR=/tmp/xspec/basex/basex/BaseX.jar;
fi

# install Ant
curl -fsSL --create-dirs --retry 5 -o /tmp/xspec/ant/ant.tar.gz http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz
tar xf /tmp/xspec/ant/ant.tar.gz -C /tmp/xspec/ant;
export ANT_HOME=/tmp/xspec/ant/apache-ant-${ANT_VERSION}
export PATH=${ANT_HOME}/bin:${PATH}

# install XML Resolver
export XML_RESOLVER_JAR=/tmp/xspec/xml-resolver/resolver.jar
curl -fsSL --create-dirs --retry 5 -o ${XML_RESOLVER_JAR} http://central.maven.org/maven2/xml-resolver/xml-resolver/1.2/xml-resolver-1.2.jar

#install Jing
if [ -z ${JING_VERSION} ]; then
    echo "Jing will not be installed";
else
    export JING_JAR=/tmp/xspec/jing/jing.jar;
    curl -fsSL --create-dirs --retry 5 -o ${JING_JAR} http://central.maven.org/maven2/org/relaxng/jing/${JING_VERSION}/jing-${JING_VERSION}.jar;
fi
