#! /bin/bash

echo "Check git status"

output=$(git status --porcelain 2>&1)
echo "${output}"
test -z "${output}"
