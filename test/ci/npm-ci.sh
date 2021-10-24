#! /bin/bash

#
# This script is executed as 'source'. Do not do 'exit'.
#

echo "Clean install npm packages"

npm ci || return

npmbin="$(npm bin)" || return
export PATH="${npmbin}:${PATH}"
