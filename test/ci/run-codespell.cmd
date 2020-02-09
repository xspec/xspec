pip install ^
    --disable-pip-version-check ^
    --quiet ^
    codespell

rem ".git" dir is not skipped by default: codespell-project/codespell#783
rem Skipping nested dirs needs "./": codespell-project/codespell#99
codespell ^
    --check-filenames ^
    --check-hidden ^
    --quiet-level 6 ^
    --skip=".git,./src/schematron/iso-schematron"
