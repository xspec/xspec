#!/bin/bash
myname="${BASH_SOURCE:-$0}"
mydir=$(cd -P -- $(dirname -- "${myname}"); pwd)
ant -buildfile "${mydir}/ant/run-e2e-tests/build.xml" -lib "${SAXON_JAR}" "$@"
