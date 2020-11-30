echo Install codespell
pip install ^
    --disable-pip-version-check ^
    --requirement requirements-dev.txt

echo Run codespell
codespell
