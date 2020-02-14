#!/usr/bin/env bats
#===============================================================================
#
#         USAGE:  bats xspec.bats 
#         
#   DESCRIPTION:  Unit tests for script bin/xspec.sh 
#
#         INPUT:  N/A
#
#        OUTPUT:  Unit tests results
#
#  DEPENDENCIES:  This script requires bats (https://github.com/sstephenson/bats)
#
#        AUTHOR:  Sandro Cirulli, github.com/cirulls
#
#       LICENSE:  MIT License (https://opensource.org/licenses/MIT)
#
#===============================================================================

#
# Setup and teardown
#

setup() {
    work_dir="${BATS_TMPDIR}/xspec/bats_work"
    mkdir -p "${work_dir}"

    export TEST_DIR="${work_dir}/output_${RANDOM}"
    export ANT_ARGS="-Dxspec.dir=${TEST_DIR}"
}

teardown() {
    rm -r "${work_dir}"
}

#
# Usage (CLI)
#

@test "invoking xspec without arguments prints usage" {
    run ../bin/xspec.sh
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[2]}" = "Usage: xspec [-t|-q|-s|-c|-j|-catalog file|-h] file [coverage]" ]
}

@test "invoking xspec without arguments prints usage even if Saxon environment variables are not defined" {
    unset SAXON_CP
    run ../bin/xspec.sh
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "SAXON_CP and SAXON_HOME both not set!" ]
    [[ "${lines[4]}" =~ "Usage: xspec " ]]
}

@test "invoking xspec with -h prints usage and does so even when it is 11th argument" {
    run ../bin/xspec.sh -t -t -t -t -t -t -t -t -t -t -h
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "${lines[1]}" =~ "Usage: xspec " ]]
}

#
# Mutually exclusive test types (CLI)
#

@test "invoking xspec with -s and -t prints error message" {
    run ../bin/xspec.sh -s -t
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "-s and -t are mutually exclusive" ]
}

@test "invoking xspec with -s and -q prints error message" {
    run ../bin/xspec.sh -s -q
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "-s and -q are mutually exclusive" ]
}

@test "invoking xspec with -t and -q prints error message" {
    run ../bin/xspec.sh -t -q
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "-t and -q are mutually exclusive" ]
}

#
# Coverage and Saxon versions (CLI)
#

@test "invoking xspec -c with Saxon9HE returns error message" {
    export SAXON_CP=/path/to/saxon9he.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}

@test "invoking xspec -c with Saxon9SA returns error message" {
    export SAXON_CP=/path/to/saxon9sa.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}

@test "invoking xspec -c with Saxon9 returns error message" {
    export SAXON_CP=/path/to/saxon9.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}

@test "invoking xspec -c with Saxon8SA returns error message" {
    export SAXON_CP=/path/to/saxon8sa.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}

@test "invoking xspec -c with Saxon8 returns error message" {
    export SAXON_CP=/path/to/saxon8.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}

@test "invoking xspec -c with Saxon9EE creates test stylesheet" {
    # Append non-Saxon jar to see if SAXON_CP is parsed correctly
    export SAXON_CP="/path/to/saxon9ee.jar:/path/to/another.jar"

    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[2]}" = "Creating Test Stylesheet..." ]
}

@test "invoking xspec -c with Saxon9PE creates test stylesheet" {
    export SAXON_CP=/path/to/saxon9pe.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[2]}" = "Creating Test Stylesheet..." ]
}

#
# Coverage (CLI)
#

@test "invoking xspec -c creates report files" {
    if [ -z "${XSLT_SUPPORTS_COVERAGE}" ]; then
        skip "XSLT_SUPPORTS_COVERAGE is not defined"
    fi

    # Other stderr #204
    export JAVA_TOOL_OPTIONS=-Dfoo

    # Non alphanumeric path #208
    special_chars_dir="${work_dir}/up & down"
    mkdir "${special_chars_dir}"

    cp ../tutorial/coverage/demo* "${special_chars_dir}"
    unset TEST_DIR

    run ../bin/xspec.sh -c "${special_chars_dir}/demo.xspec"
    echo "$output"
    [ "$status" -eq 0 ]

    # XML and HTML report file
    [ -f "${special_chars_dir}/xspec/demo-result.xml" ]
    [ -f "${special_chars_dir}/xspec/demo-result.html" ]

    # Coverage report file is created and contains CSS inline #194
    unset JAVA_TOOL_OPTIONS
    run java -jar "${SAXON_JAR}" -s:"${special_chars_dir}/xspec/demo-coverage.html" -xsl:html-css.xsl
    echo "$output"
    [ "${lines[0]}" = "true" ]
}

@test "invoking xspec -c -q prints error message" {
    export SAXON_CP=/path/to/saxon9ee.jar
    run ../bin/xspec.sh -c -q ../tutorial/xquery-tutorial.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Coverage is supported only for XSLT" ]
}

@test "invoking xspec -c -s prints error message" {
    export SAXON_CP=/path/to/saxon9ee.jar
    run ../bin/xspec.sh -c -s ../tutorial/schematron/demo-01.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Coverage is supported only for XSLT" ]
}

#
# CLI without TEST_DIR
#

@test "invoking xspec without TEST_DIR set externally (XSLT)" {
    unset TEST_DIR

    # Delete default output dir if exists, to make the line numbers predictable
    rm -rf ../tutorial/xspec

    # Run
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 0 ]

    # Verify message
    [ "${lines[19]}" = "passed: 5 / pending: 0 / failed: 1 / total: 6" ]
    [ "${lines[20]}" = "Report available at ../tutorial/xspec/escape-for-regex-result.html" ]

    # Verify report files
    # * XML report file is created
    # * HTML report file is created
    # * Coverage is disabled by default
    # * JUnit is disabled by default
    run ls ../tutorial/xspec
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "escape-for-regex-compiled.xsl" ]
    [ "${lines[1]}" = "escape-for-regex-result.html" ]
    [ "${lines[2]}" = "escape-for-regex-result.xml" ]

    # HTML report file contains CSS inline #135
    run java -jar "${SAXON_JAR}" -s:../tutorial/xspec/escape-for-regex-result.html -xsl:html-css.xsl
    echo "$output"
    [ "${lines[0]}" = "true" ]

    # Cleanup
    rm -r ../tutorial/xspec
}

@test "invoking xspec without TEST_DIR set externally (XQuery)" {
    unset TEST_DIR

    # Delete default output dir if exists, to make the line numbers predictable
    rm -rf ../tutorial/xspec

    # Run
    run ../bin/xspec.sh -q ../tutorial/xquery-tutorial.xspec
    echo "$output"
    [ "$status" -eq 0 ]

    # Verify message
    [ "${lines[6]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
    [ "${lines[7]}" = "Report available at ../tutorial/xspec/xquery-tutorial-result.html" ]

    # Verify report files
    # * XML report file is created
    # * HTML report file is created
    # * JUnit is disabled by default
    run ls ../tutorial/xspec
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "xquery-tutorial-compiled.xq" ]
    [ "${lines[1]}" = "xquery-tutorial-result.html" ]
    [ "${lines[2]}" = "xquery-tutorial-result.xml" ]

    # Cleanup
    rm -r ../tutorial/xspec
}

@test "invoking xspec without TEST_DIR set externally (Schematron)" {
    unset TEST_DIR

    # Delete default output dir if exists, to make the line numbers predictable
    rm -rf ../tutorial/schematron/xspec

    # Run
    run ../bin/xspec.sh -s ../tutorial/schematron/demo-03.xspec
    echo "$output"
    [ "$status" -eq 0 ]

    # Verify message
    # * No Schematron warnings #129 #131
    [ "${lines[4]}"  = "Converting Schematron XSpec into XSLT XSpec..." ]
    [ "${lines[31]}" = "passed: 10 / pending: 1 / failed: 0 / total: 11" ]
    [ "${lines[32]}" = "Report available at ../tutorial/schematron/xspec/demo-03-result.html" ]

    # Verify report files
    # * XML report file is created
    # * HTML report file is created
    # * JUnit is disabled by default
    # * Schematron-specific temporary files are deleted
    run ls ../tutorial/schematron/xspec
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "demo-03-compiled.xsl" ]
    [ "${lines[1]}" = "demo-03-result.html" ]
    [ "${lines[2]}" = "demo-03-result.xml" ]

    # Cleanup
    rm -r ../tutorial/schematron/xspec
}

#
# JUnit and Saxon versions (CLI)
#

@test "invoking xspec with -j option with Saxon8 returns error message" {
    export SAXON_CP=/path/to/saxon8.jar
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Saxon8 detected. JUnit report requires Saxon9." ]
}

@test "invoking xspec with -j option with Saxon8-SA returns error message" {
    export SAXON_CP=/path/to/saxon8sa.jar
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Saxon8 detected. JUnit report requires Saxon9." ]
}

#
# JUnit (CLI)
#

@test "invoking xspec with -j option generates message with JUnit report location and creates report files" {
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[21]}" = "Report available at ${TEST_DIR}/escape-for-regex-junit.xml" ]

    # XML report file
    [ -f "${TEST_DIR}/escape-for-regex-result.xml" ]

    # HTML report file
    [ -f "${TEST_DIR}/escape-for-regex-result.html" ]

    # JUnit report file
    [ -f "${TEST_DIR}/escape-for-regex-junit.xml" ]
}

#
# Saxon-B (CLI)
#

@test "invoking xspec with Saxon-B-9-1-0-8 creates test stylesheet" {
    export SAXON_CP=/path/to/saxonb9-1-0-8.jar
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[2]}" = "Creating Test Stylesheet..." ]
}

#
# #46
#

@test "invoking xspec that passes a non xs:boolean does not raise a warning #46" {
    run ../bin/xspec.sh xspec-46.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "${lines[5]}" =~ "Testing with" ]]
}

#
# XProc (Saxon)
#

@test "XProc harness for Saxon (XSLT)" {
    if [ -z "${XMLCALABASH_JAR}" ]; then
        skip "XMLCALABASH_JAR is not defined"
    fi

    # HTML report file
    actual_report_dir="${PWD}/end-to-end/cases/actual__/stylesheet"
    mkdir -p "${actual_report_dir}"
    actual_report="${actual_report_dir}/xspec-serialize-result.html"

    # Run
    run java -jar "${XMLCALABASH_JAR}" \
        -i source=end-to-end/cases/xspec-serialize.xspec \
        -o result="file:${actual_report}" \
        -p xspec-home="file:${PWD}/../" \
        ../src/harnesses/saxon/saxon-xslt-harness.xproc
    echo "$output"
    [ "$status" -eq 0 ]

    # Verify HTML report including #72
    run java -jar "${SAXON_JAR}" \
        -s:"${actual_report}" \
        -xsl:end-to-end/processor/html/compare.xsl \
        EXPECTED-DOC-URI="file:${actual_report_dir}/../../expected/stylesheet/xspec-serialize-result.html" \
        NORMALIZE-HTML-DATETIME="2000-01-01T00:00:00Z"
    echo "$output"
    [ "$status" -eq 0 ]
}

@test "XProc harness for Saxon (XQuery)" {
    if [ -z "${XMLCALABASH_JAR}" ]; then
        skip "XMLCALABASH_JAR is not defined"
    fi

    # HTML report file
    actual_report_dir="${PWD}/end-to-end/cases/actual__/query"
    mkdir -p "${actual_report_dir}"
    actual_report="${actual_report_dir}/xspec-serialize-result.html"

    # Run
    run java -jar "${XMLCALABASH_JAR}" \
        -i source=end-to-end/cases/xspec-serialize.xspec \
        -o result="file:${actual_report}" \
        -p xspec-home="file:${PWD}/../" \
        ../src/harnesses/saxon/saxon-xquery-harness.xproc
    echo "$output"
    [ "$status" -eq 0 ]

    # Verify HTML report including #72
    run java -jar "${SAXON_JAR}" \
        -s:"${actual_report}" \
        -xsl:end-to-end/processor/html/compare.xsl \
        EXPECTED-DOC-URI="file:${actual_report_dir}/../../expected/query/xspec-serialize-result.html" \
        NORMALIZE-HTML-DATETIME="2000-01-01T00:00:00Z"
    echo "$output"
    [ "$status" -eq 0 ]
}

#
# Path containing special chars (CLI)
#

@test "invoking xspec with path containing special chars (#84 #119 #202 #716) runs and loads doc (#610) successfully and generates HTML report file (XSLT)" {
    special_chars_dir="${work_dir}/some'path (84) here & there"
    mkdir "${special_chars_dir}"
    cp do-nothing.xsl         "${special_chars_dir}"
    cp xspec-node-selection.* "${special_chars_dir}"

    unset TEST_DIR
    expected_report="${special_chars_dir}/xspec/xspec-node-selection-result.html"

    run ../bin/xspec.sh "${special_chars_dir}/xspec-node-selection.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[29]}" = "Report available at ${expected_report}" ]
    [ -f "${expected_report}" ]
}

@test "invoking xspec with path containing special chars (#84 #119 #202 #716) runs and loads doc (#610) successfully and generates HTML report file (XQuery)" {
    special_chars_dir="${work_dir}/some'path (84) here & there"
    mkdir "${special_chars_dir}"
    cp do-nothing.xquery      "${special_chars_dir}"
    cp xspec-node-selection.* "${special_chars_dir}"

    unset TEST_DIR
    expected_report="${special_chars_dir}/xspec/xspec-node-selection-result.html"

    run ../bin/xspec.sh -q "${special_chars_dir}/xspec-node-selection.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[7]}" = "Report available at ${expected_report}" ]
    [ -f "${expected_report}" ]
}

@test "invoking xspec with path containing special chars (#84 #119 #202 #716) runs and loads doc (#610) successfully and generates HTML report file (Schematron)" {
    special_chars_dir="${work_dir}/some'path (84) here & there"
    mkdir "${special_chars_dir}"
    cp ../tutorial/schematron/demo-03* "${special_chars_dir}"

    unset TEST_DIR
    expected_report="${special_chars_dir}/xspec/demo-03-result.html"

    run ../bin/xspec.sh -s "${special_chars_dir}/demo-03.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[32]}" = "Report available at ${expected_report}" ]
    [ -f "${expected_report}" ]
}

#
# saxon script
#

@test "invoking xspec with saxon script uses the saxon script #121 #122" {
    echo "echo 'Saxon script with EXPath Packaging System'" > "${work_dir}/saxon"
    chmod +x "${work_dir}/saxon"
    export PATH="$PATH:${work_dir}"
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Saxon script found, use it." ]
}

#
# Schematron phase/parameters
#

@test "Schematron phase/parameters are passed to Schematron compile (CLI)" {
    export SCHEMATRON_XSLT_COMPILE=schematron/schematron-param-001-step3.xsl
    run ../bin/xspec.sh -s schematron/schematron-param-001.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[20]}" = "passed: 9 / pending: 0 / failed: 0 / total: 9" ]
}

@test "Schematron phase/parameters are passed to Schematron compile (Ant)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=s \
        -Dxspec.schematron.preprocessor.step3="${PWD}/schematron/schematron-param-001-step3.xsl" \
        -Dxspec.xml="${PWD}/schematron/schematron-param-001.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 9 / pending: 0 / failed: 0 / total: 9" ]]
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]
}

#
# Schematron XSLTs provided externally
#

@test "invoking xspec with Schematron XSLTs provided externally uses provided XSLTs for Schematron compile (CLI)" {
    export SCHEMATRON_XSLT_INCLUDE=schematron/schematron-xslt-include.xsl
    export SCHEMATRON_XSLT_EXPAND=schematron/schematron-xslt-expand.xsl
    export SCHEMATRON_XSLT_COMPILE=schematron/schematron-xslt-compile.xsl

    run ../bin/xspec.sh -s ../tutorial/schematron/demo-01.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[4]}"  = "I am schematron-xslt-include.xsl!" ]
    [ "${lines[5]}"  = "I am schematron-xslt-expand.xsl!" ]
    [ "${lines[6]}"  = "I am schematron-xslt-compile.xsl!" ]
    [ "${lines[19]}" = "passed: 3 / pending: 0 / failed: 0 / total: 3" ]
}

@test "invoking xspec with Schematron XSLTs provided externally uses provided XSLTs for Schematron compile (Ant)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=s \
        -Dxspec.schematron.preprocessor.step1="${PWD}/schematron/schematron-xslt-include.xsl" \
        -Dxspec.schematron.preprocessor.step2="${PWD}/schematron/schematron-xslt-expand.xsl" \
        -Dxspec.schematron.preprocessor.step3="${PWD}/schematron/schematron-xslt-compile.xsl" \
        -Dxspec.xml="${PWD}/../tutorial/schematron/demo-01.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "I am schematron-xslt-include.xsl!" ]]
    [[ "${output}" =~ "I am schematron-xslt-expand.xsl!" ]]
    [[ "${output}" =~ "I am schematron-xslt-compile.xsl!" ]]
    [[ "${output}" =~ "passed: 3 / pending: 0 / failed: 0 / total: 3" ]]
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]
}

#
# CLI with TEST_DIR
#

@test "invoking xspec with TEST_DIR creates files in TEST_DIR (XSLT)" {
    # Delete default output dir if exists
    rm -rf ../tutorial/xspec

    # Run with absolute TEST_DIR
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[20]}" = "Report available at ${TEST_DIR}/escape-for-regex-result.html" ]

    # Verify files in specified TEST_DIR
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "escape-for-regex-compiled.xsl" ]
    [ "${lines[1]}" = "escape-for-regex-result.html" ]
    [ "${lines[2]}" = "escape-for-regex-result.xml" ]

    # Default output dir should not be created
    [ ! -d ../tutorial/xspec ]

    # Run with relative TEST_DIR
    export TEST_DIR=../tutorial/xspec
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[20]}" = "Report available at ${TEST_DIR}/escape-for-regex-result.html" ]

    # Verify files in specified TEST_DIR
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "escape-for-regex-compiled.xsl" ]
    [ "${lines[1]}" = "escape-for-regex-result.html" ]
    [ "${lines[2]}" = "escape-for-regex-result.xml" ]

    # Cleanup
    rm -r "${TEST_DIR}"
}

@test "invoking xspec with TEST_DIR creates files in TEST_DIR (XQuery)" {
    # Delete default output dir if exists
    rm -rf ../tutorial/xspec

    # Run with absolute TEST_DIR
    run ../bin/xspec.sh -q ../tutorial/xquery-tutorial.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[7]}" = "Report available at ${TEST_DIR}/xquery-tutorial-result.html" ]

    # Verify files in specified TEST_DIR
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "xquery-tutorial-compiled.xq" ]
    [ "${lines[1]}" = "xquery-tutorial-result.html" ]
    [ "${lines[2]}" = "xquery-tutorial-result.xml" ]

    # Default output dir should not be created
    [ ! -d ../tutorial/xspec ]

    # Run with relative TEST_DIR
    export TEST_DIR=../tutorial/xspec
    run ../bin/xspec.sh -q ../tutorial/xquery-tutorial.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[7]}" = "Report available at ${TEST_DIR}/xquery-tutorial-result.html" ]

    # Verify files in specified TEST_DIR
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "xquery-tutorial-compiled.xq" ]
    [ "${lines[1]}" = "xquery-tutorial-result.html" ]
    [ "${lines[2]}" = "xquery-tutorial-result.xml" ]

    # Cleanup
    rm -r "${TEST_DIR}"
}

@test "invoking xspec with TEST_DIR creates files in TEST_DIR (Schematron)" {
    # Delete default output dir if exists
    rm -rf ../test/xspec

    # Run with absolute TEST_DIR
    run ../bin/xspec.sh -s schematron-017.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[16]}" = "Report available at ${TEST_DIR}/schematron-017-result.html" ]

    # Verify files in specified TEST_DIR
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "schematron-017-compiled.xsl" ]
    [ "${lines[1]}" = "schematron-017-result.html" ]
    [ "${lines[2]}" = "schematron-017-result.xml" ]

    # Default output dir should not be created
    [ ! -d xspec ]

    # Run with relative TEST_DIR
    export TEST_DIR=../test/xspec
    run ../bin/xspec.sh -s schematron-017.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[16]}" = "Report available at ${TEST_DIR}/schematron-017-result.html" ]

    # Verify files in specified TEST_DIR
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "schematron-017-compiled.xsl" ]
    [ "${lines[1]}" = "schematron-017-result.html" ]
    [ "${lines[2]}" = "schematron-017-result.xml" ]

    # Cleanup
    rm -r "${TEST_DIR}"
}

#
# XProc (BaseX)
#

@test "XProc harness for BaseX (standalone)" {
    if [ -z "${BASEX_JAR}" ]; then
        skip "BASEX_JAR is not defined"
    fi
    if [ -z "${XMLCALABASH_JAR}" ]; then
        skip "XMLCALABASH_JAR is not defined"
    fi

    # Output files
    compiled_file="${work_dir}/compiled.xq"
    expected_report="${work_dir}/xquery-tutorial-result.html"

    # Run
    run java -jar "${XMLCALABASH_JAR}" \
        -i source=../tutorial/xquery-tutorial.xspec \
        -o result="file:${expected_report}" \
        -p basex-jar="${BASEX_JAR}" \
        -p compiled-file="file:${compiled_file}" \
        -p xspec-home="file:${PWD}/../" \
        ../src/harnesses/basex/basex-standalone-xquery-harness.xproc
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "${lines[${#lines[@]}-1]}" =~ ":passed: 1 / pending: 0 / failed: 0 / total: 1" ]]

    # Compiled file
    [ -f "${compiled_file}" ]

    # HTML report file should be created and its charset should be UTF-8 #72
    run java -jar "${SAXON_JAR}" -s:"${expected_report}" -xsl:html-charset.xsl
    echo "$output"
    [ "${lines[0]}" = "true" ]
}

@test "XProc harness for BaseX (server)" {
    if [ -z "${BASEX_JAR}" ]; then
        skip "BASEX_JAR is not defined"
    fi
    if [ -z "${XMLCALABASH_JAR}" ]; then
        skip "XMLCALABASH_JAR is not defined"
    fi

    # BaseX dir
    basex_home=$(dirname -- "${BASEX_JAR}")

    # Start BaseX server
    "${basex_home}/bin/basexhttp" -S

    # HTML report file
    expected_report="${work_dir}/xquery-tutorial-result.html"

    # Run
    run java -jar "${XMLCALABASH_JAR}" \
        -i source=../tutorial/xquery-tutorial.xspec \
        -o result="file:${expected_report}" \
        -p auth-method=Basic \
        -p endpoint=http://localhost:8984/rest \
        -p password=admin \
        -p username=admin \
        -p xspec-home="file:${PWD}/../" \
        ../src/harnesses/basex/basex-server-xquery-harness.xproc
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" = "2" ]
    [[ "${lines[1]}" =~ ":passed: 1 / pending: 0 / failed: 0 / total: 1" ]]

    # HTML report file should be created and its charset should be UTF-8 #72
    run java -jar "${SAXON_JAR}" -s:"${expected_report}" -xsl:html-charset.xsl
    echo "$output"
    [ "${lines[0]}" = "true" ]

    # Stop BaseX server
    "${basex_home}/bin/basexhttpstop"
}

#
# Ant with minimum properties
#

@test "Ant with minimum properties (XSLT)" {
    # Unset any preset args
    unset ANT_ARGS

    # Delete default output dir if exists
    rm -rf ../tutorial/xspec

    # Run
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.xml="${PWD}/../tutorial/escape-for-regex.xspec"
    echo "$output"

    # Default xspec.fail is true
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "passed: 5 / pending: 0 / failed: 1 / total: 6" ]]
    [ "${lines[${#lines[@]}-3]}" = "BUILD FAILED" ]

    # Verify default output dir
    # * Default clean.output.dir is false
    # * Default xspec.coverage.enabled is false
    # * Default xspec.junit.enabled is false
    run env LC_ALL=C ls ../tutorial/xspec
    echo "$output"
    [ "${#lines[@]}" = "4" ]
    [ "${lines[0]}" = "escape-for-regex-compiled.xsl" ]
    [ "${lines[1]}" = "escape-for-regex-result.html" ]
    [ "${lines[2]}" = "escape-for-regex-result.xml" ]
    [ "${lines[3]}" = "escape-for-regex_xml-to-properties.xml" ]

    # HTML report file contains CSS inline
    run java -jar "${SAXON_JAR}" -s:../tutorial/xspec/escape-for-regex-result.html -xsl:html-css.xsl
    echo "$output"
    [ "${lines[0]}" = "true" ]

    # Cleanup
    rm -r ../tutorial/xspec
}

@test "Ant with minimum properties (XQuery)" {
    # Unset any preset args
    unset ANT_ARGS

    # Delete default output dir if exists
    rm -rf ../tutorial/xspec

    # Run
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=q \
        -Dxspec.xml="${PWD}/../tutorial/xquery-tutorial.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 1 / pending: 0 / failed: 0 / total: 1" ]]
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    # Verify default output dir
    # * Default clean.output.dir is false
    # * Default xspec.junit.enabled is false
    run env LC_ALL=C ls ../tutorial/xspec
    echo "$output"
    [ "${#lines[@]}" = "4" ]
    [ "${lines[0]}" = "xquery-tutorial-compiled.xq" ]
    [ "${lines[1]}" = "xquery-tutorial-result.html" ]
    [ "${lines[2]}" = "xquery-tutorial-result.xml" ]
    [ "${lines[3]}" = "xquery-tutorial_xml-to-properties.xml" ]

    # Cleanup
    rm -r ../tutorial/xspec
}

@test "Ant with minimum properties (Schematron)" {
    # Unset any preset args
    unset ANT_ARGS

    # Delete default output dir if exists
    rm -rf ../tutorial/schematron/xspec

    # Run
    # * Should work without phase #168
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=s \
        -Dxspec.xml="${PWD}/../tutorial/schematron/demo-03.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 10 / pending: 1 / failed: 0 / total: 11" ]]
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    # Verify default output dir
    # * Default clean.output.dir is false
    # * Default xspec.junit.enabled is false
    run env LC_ALL=C ls ../tutorial/schematron/xspec
    echo "$output"
    [ "${#lines[@]}" = "9" ]
    [ "${lines[0]}" = "demo-03-compiled.xsl" ]
    [ "${lines[1]}" = "demo-03-result.html" ]
    [ "${lines[2]}" = "demo-03-result.xml" ]
    [ "${lines[3]}" = "demo-03-sch-preprocessed.xsl" ]
    [ "${lines[4]}" = "demo-03-sch-preprocessed.xspec" ]
    [ "${lines[5]}" = "demo-03-sch-step3-wrapper.xsl" ]
    [ "${lines[6]}" = "demo-03-step1.sch" ]
    [ "${lines[7]}" = "demo-03-step2.sch" ]
    [ "${lines[8]}" = "demo-03_xml-to-properties.xml" ]

    # Cleanup
    rm -r ../tutorial/schematron/xspec
}

#
# Catalog (Ant)
#

@test "Ant with catalog (XSLT)" {
    if [ -z "${XML_RESOLVER_JAR}" ]; then
        skip "XML_RESOLVER_JAR is not defined"
    fi

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -lib "${XML_RESOLVER_JAR}" \
        -Dcatalog="${PWD}/catalog/01/catalog.xml" \
        -Dxspec.xml="${PWD}/catalog/catalog-01_stylesheet.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-10]}" = "     [xslt] passed: 4 / pending: 0 / failed: 0 / total: 4" ]
    [ "${lines[${#lines[@]}-2]}"  = "BUILD SUCCESSFUL" ]
}

@test "Ant with catalog (XQuery)" {
    if [ -z "${XML_RESOLVER_JAR}" ]; then
        skip "XML_RESOLVER_JAR is not defined"
    fi

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -lib "${XML_RESOLVER_JAR}" \
        -Dcatalog="${PWD}/catalog/01/catalog.xml" \
        -Dtest.type=q \
        -Dxspec.xml="${PWD}/catalog/catalog-01_query.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-10]}" = "     [xslt] passed: 2 / pending: 0 / failed: 0 / total: 2" ]
    [ "${lines[${#lines[@]}-2]}"  = "BUILD SUCCESSFUL" ]
}

@test "Ant with catalog (Schematron)" {
    if [ -z "${XML_RESOLVER_JAR}" ]; then
        skip "XML_RESOLVER_JAR is not defined"
    fi

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -lib "${XML_RESOLVER_JAR}" \
        -Dcatalog="${PWD}/catalog/01/catalog.xml" \
        -Dtest.type=s \
        -Dxspec.xml="${PWD}/catalog/catalog-01_schematron.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-10]}" = "     [xslt] passed: 4 / pending: 0 / failed: 0 / total: 4" ]
    [ "${lines[${#lines[@]}-2]}"  = "BUILD SUCCESSFUL" ]
}

#
# xspec.fail (Ant)
#

@test "Ant with xspec.fail=false continues on test failure (XSLT)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.fail=false \
        -Dxspec.xml="${PWD}/../tutorial/escape-for-regex.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 5 / pending: 0 / failed: 1 / total: 6" ]]
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]
}

@test "Ant with xspec.fail=true makes the build fail on test failure before cleanup (XSLT)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dclean.output.dir=true \
        -Dxspec.fail=true \
        -Dxspec.xml="${PWD}/../tutorial/escape-for-regex.xspec"
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "passed: 5 / pending: 0 / failed: 1 / total: 6" ]]
    [ "${lines[${#lines[@]}-3]}" = "BUILD FAILED" ]

    # Verify the build fails before cleanup
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "4" ]
}

#
# Ant verbose test.type
#	Last char is capitalized to verify case-insensitiveness
#

@test "Ant verbose test.type (XSLT)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=xslT \
        -Dxspec.xml="${PWD}/../tutorial/escape-for-regex.xspec"
    echo "$output"
    [[ "${output}" =~ "passed: 5 / pending: 0 / failed: 1 / total: 6" ]]
}

@test "Ant verbose test.type (XQuery)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=xquerY \
        -Dxspec.xml="${PWD}/../tutorial/xquery-tutorial.xspec"
    echo "$output"
    [[ "${output}" =~ "passed: 1 / pending: 0 / failed: 0 / total: 1" ]]
}

@test "Ant verbose test.type (Schematron)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dclean.output.dir=true \
        -Dtest.type=schematroN \
        -Dxspec.xml="${PWD}/../tutorial/schematron/demo-01.xspec"
    echo "$output"
    [[ "${output}" =~ "passed: 3 / pending: 0 / failed: 0 / total: 3" ]]
}

#
# Ant various properties
#

@test "Ant for Schematron with various properties except catalog and xspec.fail" {
    build_xml="${work_dir}/build.xml"

    # For testing -Dxspec.project.dir
    cp ../build.xml "${build_xml}"

    # Delete default output dir if exists
    rm -rf ../tutorial/schematron/xspec

    # Run
    run ant \
        -buildfile "${build_xml}" \
        -lib "${SAXON_JAR}" \
        -Dclean.output.dir=true \
        -Dxspec.project.dir="${PWD}/.." \
        -Dxspec.properties="${PWD}/schematron.properties" \
        -Dxspec.xml="${PWD}/../tutorial/schematron/demo-03.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 10 / pending: 1 / failed: 0 / total: 11" ]]
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    # Verify that -Dxspec.dir was honored and the default output dir was not created
    [ ! -d ../tutorial/schematron/xspec ]

    # Verify clean.output.dir=true
    [ ! -d "${TEST_DIR}" ]
}

#
# Catalog (CLI) (-catalog)
#

@test "CLI with -catalog uses XML Catalog resolver and does so even with spaces in file path (XSLT)" {
    if [ -z "${XML_RESOLVER_JAR}" ]; then
        skip "XML_RESOLVER_JAR is not defined"
    fi

    space_dir="${work_dir}/cat a log"
    mkdir -p "${space_dir}/01"
    cp catalog/catalog-01* "${space_dir}"
    cp catalog/01/*        "${space_dir}/01"

    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    run ../bin/xspec.sh -catalog "${space_dir}/01/catalog.xml" "${space_dir}/catalog-01_stylesheet.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[15]}" = "passed: 4 / pending: 0 / failed: 0 / total: 4" ]
}

@test "CLI with -catalog uses XML Catalog resolver (XQuery)" {
    if [ -z "${XML_RESOLVER_JAR}" ]; then
        skip "XML_RESOLVER_JAR is not defined"
    fi

    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    run ../bin/xspec.sh -catalog catalog/01/catalog.xml -q catalog/catalog-01_query.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[6]}" = "passed: 2 / pending: 0 / failed: 0 / total: 2" ]
}

@test "CLI with -catalog uses XML Catalog resolver (Schematron)" {
    if [ -z "${XML_RESOLVER_JAR}" ]; then
        skip "XML_RESOLVER_JAR is not defined"
    fi

    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    run ../bin/xspec.sh -catalog catalog/01/catalog.xml -s catalog/catalog-01_schematron.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[18]}" = "passed: 4 / pending: 0 / failed: 0 / total: 4" ]
}

#
# Catalog (CLI) (XML_CATALOG)
#

@test "CLI with XML_CATALOG set uses XML Catalog resolver and does so even with spaces in file path (XSLT)" {
    if [ -z "${XML_RESOLVER_JAR}" ]; then
        skip "XML_RESOLVER_JAR is not defined"
    fi

    space_dir="${work_dir}/cat a log"
    mkdir -p "${space_dir}/01"
    cp catalog/catalog-01* "${space_dir}"
    cp catalog/01/*        "${space_dir}/01"

    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    export XML_CATALOG="${space_dir}/01/catalog.xml"

    run ../bin/xspec.sh "${space_dir}/catalog-01_stylesheet.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[15]}" = "passed: 4 / pending: 0 / failed: 0 / total: 4" ]
}

#
# Catalog resolver and SAXON_HOME (CLI)
#

@test "invoking xspec using SAXON_HOME finds Saxon jar and XML Catalog Resolver jar" {
    if [ -z "${XML_RESOLVER_JAR}" ]; then
        skip "XML_RESOLVER_JAR is not defined"
    fi

    export SAXON_HOME="${work_dir}/saxon"
    mkdir "${SAXON_HOME}"
    cp "${SAXON_JAR}"        "${SAXON_HOME}"
    cp "${XML_RESOLVER_JAR}" "${SAXON_HOME}/xml-resolver-1.2.jar"
    unset SAXON_CP

    # To avoid "No license file found" warning on commercial Saxon
    saxon_license="$(dirname -- "${SAXON_JAR}")/saxon-license.lic"
    if [ -f "${saxon_license}" ]; then
        cp "${saxon_license}" "${SAXON_HOME}"
    fi

    run ../bin/xspec.sh -catalog catalog/01/catalog.xml catalog/catalog-01_stylesheet.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[15]}" = "passed: 4 / pending: 0 / failed: 0 / total: 4" ]
}

#
# RelaxNG Schema
#

@test "Schema detects no error in known good .xspec files" {
    if [ -z "${JING_JAR}" ]; then
        skip "JING_JAR is not defined"
    fi

    run ant -buildfile schema/build.xml -lib "${JING_JAR}"
    echo "$output"
    [ "$status" -eq 0 ]

    # Verify that the fileset includes test and tutorial files recursively
    [[ "${output}" =~ "/test/catalog/" ]]
    [[ "${output}" =~ "/tutorial/coverage/" ]]
}

@test "Schema detects errors in node-selection test" {
    if [ -z "${JING_JAR}" ]; then
        skip "JING_JAR is not defined"
    fi

    # '-t' for identifying the last line
    run java -jar "${JING_JAR}" -c -t ../src/schemas/xspec.rnc \
        xspec-node-selection.xspec \
        xspec-node-selection_stylesheet.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${lines[0]}" =~ "-child-not-allowed" ]]
    [[ "${lines[1]}" =~ "-child-not-allowed" ]]
    [[ "${lines[2]}" =~ "-child-not-allowed" ]]
    [[ "${lines[3]}" =~ "-child-not-allowed" ]]
    [[ "${lines[4]}" =~ "-child-not-allowed" ]]
    [[ "${lines[5]}" =~ "-child-not-allowed" ]]
    [[ "${lines[6]}" =~ "-child-not-allowed" ]]
    [[ "${lines[7]}" =~ "Elapsed time" ]]
}

#
# saxon.custom.options (Ant)
#

@test "Ant for XSLT with saxon.custom.options" {
    # Test with a space in file name
    saxon_config="${work_dir}/saxon config.xml"
    cp saxon-custom-options/config.xml "${saxon_config}"

    # via properties file, to convey the options in a stable manner...
    xspec_properties="${work_dir}/xspec.properties"
    echo "saxon.custom.options=-config:\"${saxon_config}\" -t" > "${xspec_properties}"

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.properties="${xspec_properties}" \
        -Dxspec.xml="${PWD}/saxon-custom-options/test.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 3 / pending: 0 / failed: 0 / total: 3" ]]
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    # Verify '-t'
    [[ "${output}" =~ "Memory used:" ]]
}

@test "Ant for XQuery with saxon.custom.options" {
    # Test with a space in file name
    saxon_config="${work_dir}/saxon config.xml"
    cp saxon-custom-options/config.xml "${saxon_config}"

    # via properties file, to convey the options in a stable manner...
    xspec_properties="${work_dir}/xspec.properties"
    echo "saxon.custom.options=-config:\"${saxon_config}\" -t" > "${xspec_properties}"

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=q \
        -Dxspec.properties="${xspec_properties}" \
        -Dxspec.xml="${PWD}/saxon-custom-options/test.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 3 / pending: 0 / failed: 0 / total: 3" ]]
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    # Verify '-t'
    [[ "${output}" =~ "Memory used:" ]]
}

#
# SAXON_CUSTOM_OPTIONS (CLI)
#

@test "invoking xspec for XSLT with SAXON_CUSTOM_OPTIONS" {
    # Test with a space in file name
    saxon_config="${work_dir}/saxon config.xml"
    cp saxon-custom-options/config.xml "${saxon_config}"

    export SAXON_CUSTOM_OPTIONS="\"-config:${saxon_config}\" -t"
    run ../bin/xspec.sh saxon-custom-options/test.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-3]}" = "passed: 3 / pending: 0 / failed: 0 / total: 3" ]

    # Verify '-t'
    [[ "${output}" =~ "Memory used:" ]]
}

@test "invoking xspec for XQuery with SAXON_CUSTOM_OPTIONS" {
    # Test with a space in file name
    saxon_config="${work_dir}/saxon config.xml"
    cp saxon-custom-options/config.xml "${saxon_config}"

    export SAXON_CUSTOM_OPTIONS="\"-config:${saxon_config}\" -t"
    run ../bin/xspec.sh -q saxon-custom-options/test.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-3]}" = "passed: 3 / pending: 0 / failed: 0 / total: 3" ]

    # Verify '-t'
    [[ "${output}" =~ "Memory used:" ]]
}

#
# Coverage (Ant)
#

@test "Ant for XSLT with coverage creates report files" {
    if [ -z "${XSLT_SUPPORTS_COVERAGE}" ]; then
        skip "XSLT_SUPPORTS_COVERAGE is not defined"
    fi

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.coverage.enabled=true \
        -Dxspec.xml="${PWD}/../tutorial/coverage/demo.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 1 / pending: 0 / failed: 0 / total: 1" ]]
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    # XML and HTML report file
    [ -f "${TEST_DIR}/demo-result.xml" ]
    [ -f "${TEST_DIR}/demo-result.html" ]

    # Coverage report file is created and contains CSS inline
    run java -jar "${SAXON_JAR}" -s:"${TEST_DIR}/demo-coverage.html" -xsl:html-css.xsl
    echo "$output"
    [ "${lines[0]}" = "true" ]
}

@test "Ant for XQuery with coverage fails" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=q \
        -Dxspec.coverage.enabled=true \
        -Dxspec.xml="${PWD}/../tutorial/xquery-tutorial.xspec"
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[${#lines[@]}-3]}" = "BUILD FAILED" ]
    [[ "${lines[${#lines[@]}-2]}" =~ "Coverage is supported only for XSLT" ]]
}

@test "Ant for Schematron with coverage fails" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=s \
        -Dxspec.coverage.enabled=true \
        -Dxspec.xml="${PWD}/../tutorial/schematron/demo-01.xspec"
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[${#lines[@]}-3]}" = "BUILD FAILED" ]
    [[ "${lines[${#lines[@]}-2]}" =~ "Coverage is supported only for XSLT" ]]
}

#
# JUnit (Ant)
#

@test "Ant for XSLT with JUnit creates report files" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.junit.enabled=true \
        -Dxspec.xml="${PWD}/../tutorial/escape-for-regex.xspec"
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "passed: 5 / pending: 0 / failed: 1 / total: 6" ]]
    [ "${lines[${#lines[@]}-3]}" = "BUILD FAILED" ]

    # XML report file
    [ -f "${TEST_DIR}/escape-for-regex-result.xml" ]

    # HTML report file
    [ -f "${TEST_DIR}/escape-for-regex-result.html" ]

    # JUnit report file
    [ -f "${TEST_DIR}/escape-for-regex-junit.xml" ]
}

#
# #185
#

@test "Import order #185" {
    run ../bin/xspec.sh xspec-185/import-1.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[6]}"  = "Scenario 1-1" ]
    [ "${lines[7]}"  = "Scenario 1-2" ]
    [ "${lines[8]}"  = "Scenario 1-3" ]
    [ "${lines[9]}"  = "Scenario 2a-1" ]
    [ "${lines[10]}" = "Scenario 2a-2" ]
    [ "${lines[11]}" = "Scenario 2b-1" ]
    [ "${lines[12]}" = "Scenario 2b-2" ]
    [ "${lines[13]}" = "Scenario 3" ]
    [ "${lines[14]}" = "Formatting Report..." ]
}

@test "Import order with Ant #185" {
    ant_log="${work_dir}/ant.log"

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -logfile "${ant_log}" \
        -Dxspec.xml="${PWD}/xspec-185/import-1.xspec"
    echo "$output"
    [ "$status" -eq 0 ]

    run grep " Scenario " "${ant_log}"
    echo "$output"
    [ "${#lines[@]}" = "8" ]
    [ "${lines[0]}" = "     [java] Scenario 1-1" ]
    [ "${lines[1]}" = "     [java] Scenario 1-2" ]
    [ "${lines[2]}" = "     [java] Scenario 1-3" ]
    [ "${lines[3]}" = "     [java] Scenario 2a-1" ]
    [ "${lines[4]}" = "     [java] Scenario 2a-2" ]
    [ "${lines[5]}" = "     [java] Scenario 2b-1" ]
    [ "${lines[6]}" = "     [java] Scenario 2b-2" ]
    [ "${lines[7]}" = "     [java] Scenario 3" ]
}

#
# Ambiguous x:expect
#

@test "Ambiguous x:expect generates warning" {
    run ../bin/xspec.sh end-to-end/cases/xspec-ambiguous-expect.xspec
    echo "$output"
    [[ "${lines[11]}" =~ "WARNING: x:expect has boolean @test" ]]
    [[ "${lines[16]}" =~ "WARNING: x:expect has boolean @test" ]]
    [[ "${lines[23]}" =~ "WARNING: x:expect has boolean @test" ]]
    [  "${lines[32]}" =  "Formatting Report..." ]
}

#
# Obsolete x:space
#

@test "Obsolete x:space" {
    run ../bin/xspec.sh obsolete-space/test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "x:space is obsolete. Use x:text instead." ]]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

#
# #423
#

@test "XSLT selecting nodes without context should be error (XProc) #423" {
    if [ -z "${XMLCALABASH_JAR}" ]; then
        skip "XMLCALABASH_JAR is not defined"
    fi

    run java -jar "${XMLCALABASH_JAR}" \
        -i source=xspec-423/test.xspec \
        -p xspec-home="file:${PWD}/../" \
        ../src/harnesses/saxon/saxon-xslt-harness.xproc
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${lines[${#lines[@]}-3]}" =~ "err:XPDY0002:" ]]
    [[ "${lines[${#lines[@]}-1]}" =~ "ERROR:" ]]
}

@test "XQuery selecting nodes without context should be error (XProc) #423" {
    if [ -z "${XMLCALABASH_JAR}" ]; then
        skip "XMLCALABASH_JAR is not defined"
    fi

    run java -jar "${XMLCALABASH_JAR}" \
        -i source=xspec-423/test.xspec \
        -p xspec-home="file:${PWD}/../" \
        ../src/harnesses/saxon/saxon-xquery-harness.xproc
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${lines[${#lines[@]}-3]}" =~ "err:XPDY0002:" ]]
    [[ "${lines[${#lines[@]}-1]}" =~ "ERROR:" ]]
}

@test "XSLT selecting nodes without context should be error (Ant) #423" {
    # Should be error even when xspec.fail=false
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.fail=false \
        -Dxspec.xml="${PWD}/../test/xspec-423/test.xspec"
    echo "$output"
    [ "$status" -eq 2 ]
    [[ "${output}" =~ "  XPDY0002:" ]]
    [ "${lines[${#lines[@]}-3]}" = "BUILD FAILED" ]
}

@test "XSLT selecting nodes without context should be error (CLI) #423" {
    run ../bin/xspec.sh xspec-423/test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "  XPDY0002:" ]]
    [ "${lines[${#lines[@]}-1]}" = "*** Error running the test suite" ]
}

@test "XSLT selecting nodes without context should be error (CLI -c) #423" {
    if [ -z "${XSLT_SUPPORTS_COVERAGE}" ]; then
        skip "XSLT_SUPPORTS_COVERAGE is not defined"
    fi

    run ../bin/xspec.sh -c xspec-423/test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "  XPDY0002:" ]]
    [ "${lines[${#lines[@]}-1]}" = "*** Error collecting test coverage data" ]
}

@test "XQuery selecting nodes without context should be error (CLI) #423" {
    run ../bin/xspec.sh -q xspec-423/test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "  XPDY0002:" ]]
    [ "${lines[${#lines[@]}-1]}" = "*** Error running the test suite" ]
}

#
# Invalid @xquery-version
#

@test "Invalid @xquery-version should be error" {
    run ../bin/xspec.sh -q xquery-version/invalid.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    regex="XQST0031.+InVaLiD"
    [[ "${output}" =~ ${regex} ]]
    [ "${lines[${#lines[@]}-1]}" = "*** Error running the test suite" ]
}

#
# report-css-uri
#

@test "report-css-uri for HTML report file" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.fail=false \
        -Dxspec.result.html.css="${PWD}/html-css.css" \
        -Dxspec.xml="${PWD}/../tutorial/escape-for-regex.xspec"
    echo "$output"
    [ "$status" -eq 0 ]

    run java -jar "${SAXON_JAR}" \
        -s:"${TEST_DIR}/escape-for-regex-result.html" \
        -xsl:html-css.xsl \
        STYLE-CONTAINS="This CSS file is for testing report-css-uri parameter"
    echo "$output"
    [ "${lines[0]}" = "true" ]
}

@test "report-css-uri for coverage report file" {
    if [ -z "${XSLT_SUPPORTS_COVERAGE}" ]; then
        skip "XSLT_SUPPORTS_COVERAGE is not defined"
    fi

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.coverage.enabled=true \
        -Dxspec.coverage.html.css="${PWD}/html-css.css" \
        -Dxspec.xml="${PWD}/../tutorial/coverage/demo.xspec"
    echo "$output"
    [ "$status" -eq 0 ]

    run java -jar "${SAXON_JAR}" \
        -s:"${TEST_DIR}/demo-coverage.html" \
        -xsl:html-css.xsl \
        STYLE-CONTAINS="This CSS file is for testing report-css-uri parameter"
    echo "$output"
    [ "${lines[0]}" = "true" ]
}

#
# #522
#

@test "Error message when source is not XSpec #522" {
    run ../bin/xspec.sh do-nothing.xsl
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${lines[4]}" =~ "Source document is not XSpec" ]]
}

#
# User-defined variable in XSpec namespace
#

@test "Error on user-defined variable in XSpec namespace" {
    run ../bin/xspec.sh variable/reserved-name.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${lines[5]}" =~ "x:XSPEC008:" ]]
}

#
# Deprecated Saxon version
#

@test "Deprecated Saxon version" {
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 0 ]

    if ! java -cp "${SAXON_JAR}" net.sf.saxon.Version 2>&1 | grep -F " 9.7."; then
        [ "${lines[3]}" = " " ]
    else
        [[ "${lines[3]}" =~ "WARNING: Saxon version " ]]
    fi
}

#
# No warning on Ant
#

@test "No warning on Ant (XSLT) #633" {
    if java -cp "${SAXON_JAR}" net.sf.saxon.Version 2>&1 | grep -F " 9.7."; then
        skip "Always expect a deprecation warning on Saxon 9.7"
    fi

    ant_log="${work_dir}/ant.log"

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -logfile "${ant_log}" \
        -verbose \
        -Dtest.type=t \
        -Dxspec.xml="${PWD}/xspec-uri.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ -f "${ant_log}" ]

    run grep -F -i "warning" "${ant_log}"
    echo "$output"
    [ "$status" -eq 1 ]
}

@test "No warning on Ant (XQuery) #633" {
    if java -cp "${SAXON_JAR}" net.sf.saxon.Version 2>&1 | grep -F " 9.7."; then
        skip "Always expect a deprecation warning on Saxon 9.7"
    fi

    ant_log="${work_dir}/ant.log"

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -logfile "${ant_log}" \
        -verbose \
        -Dtest.type=q \
        -Dxspec.xml="${PWD}/xspec-uri.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ -f "${ant_log}" ]

    run grep -F -i "warning" "${ant_log}"
    echo "$output"
    [ "$status" -eq 1 ]
}

@test "No warning on Ant (Schematron) #633" {
    if java -cp "${SAXON_JAR}" net.sf.saxon.Version 2>&1 | grep -F " 9.7."; then
        skip "Always expect a deprecation warning on Saxon 9.7"
    fi

    ant_log="${work_dir}/ant.log"

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -logfile "${ant_log}" \
        -verbose \
        -Dtest.type=s \
        -Dxspec.xml="${PWD}/xspec-uri.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ -f "${ant_log}" ]

    run grep -F -i "warning" "${ant_log}"
    echo "$output"
    [ "$status" -eq 1 ]

    # Verify Ant makepath task
    run cat "${ant_log}"
    echo "$output"
    [[ "${output}" =~ " [makepath] Setting xspec.schematron.file to file path ${PWD}/do-nothing.sch" ]]
}

#
# @catch should not catch error outside SUT
#

@test "@catch should not catch error outside SUT (XSLT)" {
    if [ -z "${XSLT_SUPPORTS_3_0}" ]; then
        skip "XSLT_SUPPORTS_3_0 is not defined"
    fi

    run ../bin/xspec.sh catch/compiler-error.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "ERROR in scenario " ]]

    run ../bin/xspec.sh catch/error-in-context-avt-for-template-call.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "  error-code-of-my-context-avt-for-template-call: Error signalled " ]]

    run ../bin/xspec.sh catch/error-in-context-param-for-matching-template.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "  error-code-of-my-context-param-for-matching-template: Error signalled " ]]

    run ../bin/xspec.sh catch/error-in-function-call-param.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "  error-code-of-my-function-call-param: Error signalled " ]]

    run ../bin/xspec.sh catch/error-in-template-call-param.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "  error-code-of-my-template-call-param: Error signalled " ]]

    run ../bin/xspec.sh catch/error-in-variable.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "  error-code-of-my-variable: Error signalled " ]]

    run ../bin/xspec.sh catch/static-error-in-compiled-test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "XPST0017:" ]]
}

@test "@catch should not catch error outside SUT (XQuery)" {
    if [ -z "${XQUERY_SUPPORTS_3_1_DEFAULT}" ]; then
        skip "XQUERY_SUPPORTS_3_1_DEFAULT is not defined"
    fi

    run ../bin/xspec.sh -q catch/compiler-error.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "x:XSPEC005:" ]]

    run ../bin/xspec.sh -q catch/error-in-function-call-param.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "  error-code-of-my-function-call-param: Error signalled " ]]

    run ../bin/xspec.sh -q catch/error-in-variable.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "  error-code-of-my-variable: Error signalled " ]]

    run ../bin/xspec.sh -q catch/static-error-in-compiled-test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "XPST0017:" ]]
}

#
# Error in SUT should not be caught by default
#

@test "Error in SUT should not be caught by default (XSLT)" {
    run ../bin/xspec.sh catch/no-by-default.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "  my-error-code: Error signalled " ]]
}

@test "Error in SUT should not be caught by default (XQuery)" {
    run ../bin/xspec.sh -q catch/no-by-default.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "  my-error-code: Error signalled " ]]
}

#
# Importing Ant build file
#

@test "Importing Ant build file" {
    run ant \
        -buildfile ant-import/build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.xml="${PWD}/../tutorial/escape-for-regex.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-9]}" = "     [xslt] passed: 5 / pending: 0 / failed: 1 / total: 6" ]
    [ "${lines[${#lines[@]}-5]}" = "     [echo] Target overridden!" ]
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]
}

#
# #655
#

@test "Trace listener should not hardcode output dir #655" {
    if [ -z "${XSLT_SUPPORTS_COVERAGE}" ]; then
        skip "XSLT_SUPPORTS_COVERAGE is not defined"
    fi

    # TEST_DIR should not contain "xspec"
    export "TEST_DIR=/tmp/XSpec-655"

    run ../bin/xspec.sh -c ../tutorial/coverage/demo.xspec
    echo "$output"
    [ "$status" -eq 0 ]

    run grep -F "<pre>01:" "${TEST_DIR}/demo-coverage.html"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" = "2" ]

    rm -r "${TEST_DIR}"
}

#
# x:like errors
#

@test "x:like errors" {
    run ../bin/xspec.sh like/none.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[5]}" = "  x:XSPEC009: x:like: Scenario not found: none" ]

    run ../bin/xspec.sh like/multiple.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "  x:XSPEC010: x:like: 2 scenarios found with same label: shared scenario" ]

    run ../bin/xspec.sh like/loop.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "  x:XSPEC011: x:like: Reference to ancestor scenario creates infinite loop: parent scenario" ]
}

#
# Override ID generation templates
#

@test "Override ID generation" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.compiler.xsl="${PWD}/override-id/generate-xspec-tests.xsl" \
        -Dxspec.fail=false \
        -Dxspec.xml="${PWD}/../tutorial/escape-for-regex.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 5 / pending: 0 / failed: 1 / total: 6" ]]
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    run cat "${TEST_DIR}/escape-for-regex-compiled.xsl"
    echo "$output"
    [[ "${output}" =~ "x:overridden-scenario-id-" ]]
    [[ "${output}" =~ "x:overridden-expect-id" ]]
}


