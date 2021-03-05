#!/bin/bash

echo "Install codespell"
pip3 install \
    --disable-pip-version-check \
    --user \
    --requirement requirements-dev.txt

echo "Run codespell"
~/.local/bin/codespell "$@"
