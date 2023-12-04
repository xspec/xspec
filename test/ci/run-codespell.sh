#!/bin/bash

echo "Install codespell"
pip3 install \
    --disable-pip-version-check \
    --user \
    --requirement requirements-dev.txt

echo "Run codespell with default dictionaries"
~/.local/bin/codespell "$@" || exit

echo "Run codespell with custom dictionary"
~/.local/bin/codespell --dictionary test/ci/codespell-dic.txt "$@"
