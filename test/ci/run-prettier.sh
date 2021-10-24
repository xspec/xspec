#! /bin/bash

echo "Run prettier"

# Check by prettier. Exit if fine.
npm run prettier:check && exit

# Write by prettier
npm run prettier:write

# Print diff
git --no-pager diff --color | perl /usr/share/doc/git/contrib/diff-highlight/diff-highlight

# Fail
false
