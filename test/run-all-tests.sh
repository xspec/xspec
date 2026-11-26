#!/bin/bash
ant -version
echo "execute bats unit tests"
./run-bats.sh --tap
echo "execute XSpec unit tests"
./run-xspec-tests-ant.sh -silent
echo "execute XSpec end-to-end tests"
cd ..
./test/end-to-end/run-e2e-tests.sh -silent
echo "compile java"
javac -cp "${SAXON_JAR}" java/com/jenitennison/xslt/tests/XSLTCoverageTraceListener.java
echo "check git status"
output=$(git status --porcelain); echo "${output}"; test -z "${output}"
