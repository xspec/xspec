#! /bin/bash

# Uninstall stale one
if brew list bats; then
    brew uninstall bats
fi

brew install bats-core
