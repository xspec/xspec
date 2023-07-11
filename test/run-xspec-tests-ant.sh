#!/bin/bash
myname="${BASH_SOURCE:-$0}"
mydirname=$(dirname -- "${myname}")
mydir=$(cd -P -- "${mydirname}" && pwd)
ant -buildfile "${mydir}/ant/build.xml" -lib "${SAXON_JAR}:${XMLRESOLVERORG_XMLRESOLVER_LIB}" "$@"
