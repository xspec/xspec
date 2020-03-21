#! /bin/bash

echo "Compile Java"

if javac -version 2>&1 | grep -F ' 1.8.'; then
	myname="${BASH_SOURCE:-$0}"
	mydir=$(cd -P -- $(dirname -- "${myname}"); pwd)
	ant -buildfile "${mydir}/build_java.xml" "$@"
else
	echo "Skip compiling Java"
fi
