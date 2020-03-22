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

    # ".git" dir is not skipped by default: codespell-project/codespell#783
    # Skipping nested dirs needs "./": codespell-project/codespell#99
    ~/.local/bin/codespell \
        --check-filenames \
        --check-hidden \
        --quiet-level 6 \
        --skip=".git,./src/schematron/iso-schematron"
else
    echo "Skip codespell"
fi
