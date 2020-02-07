pip install ^
    --disable-pip-version-check ^
    --quiet ^
    codespell

codespell ^
    --check-filenames ^
    --check-hidden ^
    --quiet-level 6 ^
    --skip="./src/schematron/iso-schematron"
