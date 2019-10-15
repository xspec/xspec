#! /bin/bash

echo "Check git status"

output=$(git status --porcelain)
echo "${output}"
test -z "${output}"
