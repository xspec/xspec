#!/bin/bash
myname="${BASH_SOURCE:-$0}"
mydirname=$(dirname -- "${myname}")
mydir=$(cd -P -- "${mydirname}" && pwd)
ant -buildfile "${mydir}/ant/run-e2e-tests/build.xml" -lib "${SAXON_JAR}:${XMLRESOLVERORG_XMLRESOLVER_LIB}" "$@"
