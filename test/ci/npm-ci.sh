#! /bin/bash

#
# This script is executed as 'source'. Do not do 'exit'.
#

echo "Clean install npm packages"

npm ci || return

npmprefix="$(npm prefix)" || return
export PATH="${npmprefix}/node_modules/.bin:${PATH}"
