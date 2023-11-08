echo Install codespell
pip3 install ^
    --disable-pip-version-check ^
    --requirement requirements-dev.txt

echo Run codespell with default dictionaries
codespell %* || goto :EOF

echo Run codespell with custom dictionary
codespell --dictionary test\ci\codespell-dic.txt %*
