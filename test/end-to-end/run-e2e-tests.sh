#!/bin/bash

if [ "${TRAVIS_OS_NAME}" = "linux" ]; then
    # Run with a single thread in hopes of stabilizing Travis CI
    thread_count=1
    echo "Setting thread.count=${thread_count}"
fi

myname="${BASH_SOURCE:-$0}"
mydirname=$(dirname -- "${myname}")
mydir=$(cd -P -- "${mydirname}" && pwd)
ant -buildfile "${mydir}/ant/run-e2e-tests/build.xml" -lib "${SAXON_JAR}" ${thread_count:+-Dthread.count=$thread_count} "$@"
