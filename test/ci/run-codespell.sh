#!/bin/bash

echo "Run codespell"

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
