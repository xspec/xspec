#! /bin/bash

echo "Compile Java"

if javac -version 2>&1 | grep -F ' 11.'; then
    echo "Skip compiling with incompatible JDK"
    exit
fi

if [ "${SAXON_VERSION:0:3}" = "10." ]; then
    echo "Skip compiling with incompatible Saxon"
    exit
fi

myname="${BASH_SOURCE:-$0}"
mydirname=$(dirname -- "${myname}")
mydir=$(cd -P -- "${mydirname}" && pwd)
ant -buildfile "${mydir}/build_java.xml" "$@"
