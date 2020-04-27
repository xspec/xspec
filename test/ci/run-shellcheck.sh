#!/bin/bash

echo "Run shellcheck"

shellcheck --version

# https://github.com/koalaman/shellcheck/wiki/Recursiveness
# -print0 and -0 for https://github.com/koalaman/shellcheck/wiki/SC2038
find . \
    \( -type d -name .git -prune \) \
    -or \
    \( -type f \( -name '*.bash' -or  -name '*.bats' -or -name '*.sh' \) -print0 \) \
| xargs -0 -t shellcheck
