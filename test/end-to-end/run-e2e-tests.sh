#!/bin/bash

# This script must be run from the script's directory

# .xspec files directory
CASES_DIR=cases

# XSpec output directory (same as default)
export TEST_DIR=${CASES_DIR}/xspec

# Run test cases
for CASE_FILEPATH in ${CASES_DIR}/*.xspec
do
    # Generate the report HTML
    ../../bin/xspec.sh ${CASE_FILEPATH} > /dev/null 2>&1

    # Compare with the expected HTML
    CASE_FILENAME=${CASE_FILEPATH##*/}
    CASE_BASENAME=${CASE_FILENAME%.xspec}
    if java -classpath ${SAXON_CP} net.sf.saxon.Transform -s:${TEST_DIR}/${CASE_BASENAME}-result.html -xsl:processor/compare.xsl | grep '^OK: Compared '
        then
            # OK, nothing to do
            :
        else
            echo "FAILED: ${CASE_FILEPATH}"
            exit 1
    fi
done
