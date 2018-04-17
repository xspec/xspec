#!/bin/bash

# This script must be run from the script's directory

# .xspec files directory
CASES_DIR=cases

# XSpec output directory
export TEST_DIR=${CASES_DIR}/expected

# Process .xspec files
for CASE_FILEPATH in ${CASES_DIR}/*.xspec
do
    echo
    echo "----------"
    echo "Processing ${CASE_FILEPATH}..."

    CASE_FILENAME=${CASE_FILEPATH##*/}
    CASE_BASENAME=${CASE_FILENAME%.xspec}

    # Generate the report HTML
    if test "${CASE_FILENAME:0:10}" = "schematron"; then
        ../../bin/xspec.sh -s ${CASE_FILEPATH}
    elif test "${CASE_FILENAME:0:6}" = "xquery"; then
        ../../bin/xspec.sh -q ${CASE_FILEPATH}
    else
        ../../bin/xspec.sh ${CASE_FILEPATH}
    fi

    # Normalize the report HTML
    java -classpath ${SAXON_CP} net.sf.saxon.Transform -o:${TEST_DIR}/${CASE_BASENAME}-result-norm.html -s:${TEST_DIR}/${CASE_BASENAME}-result.html -xsl:processor/normalize.xsl
done
