#!/bin/bash

echo "Run commitlint"

# Check PR title
echo "${PR_TITLE}" | commitlint --help-url 'https://github.com/xspec/xspec/blob/master/CONTRIBUTING.md#code-conventions' --verbose
