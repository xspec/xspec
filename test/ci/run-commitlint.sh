#!/bin/bash

echo "Run commitlint"

# Install dependencies, otherwise fail
npm ci || exit

# Check PR title
echo "${PR_TITLE}" | npx commitlint --help-url 'https://github.com/xspec/xspec/blob/master/CONTRIBUTING.md#code-conventions' --verbose
