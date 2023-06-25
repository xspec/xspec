#! /bin/bash

echo "Compile Java"

if javac -version 2>&1 | grep -F ' 17.'; then
    echo "Skip compiling with incompatible JDK"
    exit
fi

case "${SAXON_VERSION:0:3}" in
    "10." | "11." | "12.")
        echo "Skip compiling with incompatible Saxon"
        exit
        ;;
esac

myname="${BASH_SOURCE:-$0}"
mydirname=$(dirname -- "${myname}")
mydir=$(cd -P -- "${mydirname}" && pwd)
ant -buildfile "${mydir}/build_java.xml" "$@"
