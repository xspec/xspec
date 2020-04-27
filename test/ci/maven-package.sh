#! /bin/bash

echo "Maven package"

if [ "${DO_MAVEN_PACKAGE}" = true ]; then
	mvn package -P release "$@"
else
	echo "Skip Maven package"
fi
