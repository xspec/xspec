#!/bin/bash
myname="${BASH_SOURCE:-$0}"
mydirname=$(dirname -- "${myname}")
mydir=$(cd -P -- "${mydirname}" && pwd)
ant -buildfile "${mydir}/ant/generate-expected/build.xml" -lib "${SAXON_JAR}" "$@"
