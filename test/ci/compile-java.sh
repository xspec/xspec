#! /bin/bash

echo "Compile Java"

if ! javac -version 2>&1 | grep -F ' 1.8.'; then
    echo "Skip compiling with incompatible JDK"
    exit
fi

if ! [ "${SAXON_VERSION:0:2}" = "9." ]; then
    echo "Skip compiling with incompatible Saxon"
    exit
fi

myname="${BASH_SOURCE:-$0}"
mydir=$(cd -P -- $(dirname -- "${myname}"); pwd)
ant -buildfile "${mydir}/build_java.xml" "$@"
