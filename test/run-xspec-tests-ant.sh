#!/bin/bash
myname="${BASH_SOURCE:-$0}"
mydir=$(cd -P -- $(dirname -- "${myname}"); pwd)
ant -buildfile "${mydir}/ant/build.xml" -lib "${SAXON_JAR}" "$@"
