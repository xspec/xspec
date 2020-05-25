echo Install codespell
pip install ^
    --disable-pip-version-check ^
    --requirement requirements-dev.txt

echo Run codespell
rem ".git" dir is not skipped by default: codespell-project/codespell#783
rem Skipping nested dirs needs "./": codespell-project/codespell#99
codespell ^
    --check-filenames ^
    --check-hidden ^
    --quiet-level 6 ^
    --skip=".git,./node_modules,./src/schematron/iso-schematron"
