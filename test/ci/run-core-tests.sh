#! /bin/bash

echo "Execute Bats unit tests"
./test/run-bats.sh --tap || exit

echo "Execute XSpec unit tests"
./test/run-xspec-tests-ant.sh -silent || exit

echo "Execute XSpec end-to-end tests"
./test/end-to-end/run-e2e-tests.sh -silent || exit
