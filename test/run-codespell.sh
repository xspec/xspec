#!/bin/bash
# This script runs codespell to find spelling mistakes in the source code
# it ignores specific directory and binary files
error=$(codespell * --skip="src/schematron,graphics" --quiet-level 2)

if [ -z "$error" ]
then
    printf "There are no spelling mistakes in the source code"
else
    printf "Spelling mistakes in the source code detected: \n$error"
    exit 1
fi
