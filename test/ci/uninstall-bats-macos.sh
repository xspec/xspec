#! /bin/bash

if brew list bats; then
    brew uninstall bats
else
    true
fi
