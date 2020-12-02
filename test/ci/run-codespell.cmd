echo Install codespell
pip3 install ^
    --disable-pip-version-check ^
    --requirement requirements-dev.txt

echo Run codespell
codespell
