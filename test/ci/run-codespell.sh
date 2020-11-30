#!/bin/bash

echo "Install codespell"
pip install \
    --disable-pip-version-check \
    --user \
    --requirement requirements-dev.txt

echo "Run codespell"
~/.local/bin/codespell
