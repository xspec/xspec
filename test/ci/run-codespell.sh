#!/bin/bash
# This script runs codespell to find spelling mistakes in the source code
# it ignores specific directory and binary files

echo "find spelling mistakes in source code"

if [ "${DO_CODESPELL}" = true ] ; then
    pip install \
        --disable-pip-version-check \
        --quiet \
        --user \
        codespell

    codespell \
        --check-filenames \
        --check-hidden \
        --quiet-level 2 \
        --skip="./src/schematron/iso-schematron"
else
    echo "Skip codespell"
fi
