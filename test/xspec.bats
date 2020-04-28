#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

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
    # Work directory
    work_dir="${BATS_TMPDIR}/xspec/bats_work"
    mkdir -p "${work_dir}"

    # Full path to the parent directory
    parent_dir_abs=$(cd ..; pwd)

    # Set TEST_DIR and xspec.dir within the work directory so that it's cleaned up by teardown
    export TEST_DIR="${work_dir}/output_${RANDOM}"
    export ANT_ARGS="-Dxspec.dir=${TEST_DIR}"
}

teardown() {
    # Remove the work directory
    rm -r "${work_dir}"
}

#
# Helper
#

load bats-helper

#
# Usage (CLI)
#

@test "invoking xspec without arguments prints usage" {
    run ../bin/xspec.sh
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[2]}" = "Usage: xspec [-t|-q|-s|-c|-j|-catalog file|-h] file" ]
}

@test "invoking xspec without arguments prints usage even if Saxon environment variables are not defined" {
    unset SAXON_CP
    run ../bin/xspec.sh
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "SAXON_CP and SAXON_HOME both not set!" ]
    assert_regex "${lines[3]}" '^Usage: xspec '
}

@test "invoking xspec with -h prints usage and does so even when it is 11th argument" {
    run ../bin/xspec.sh -t -t -t -t -t -t -t -t -t -t -h
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${lines[1]}" '^Usage: xspec '
}

@test "invoking xspec with unknown option prints usage" {
    run ../bin/xspec.sh -bogus ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Error: Unknown option: -bogus" ]
    assert_regex "${lines[2]}" '^Usage: xspec '
}

@test "invoking xspec with extra arguments prints usage" {
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec bogus
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Error: Extra option: bogus" ]
    assert_regex "${lines[2]}" '^Usage: xspec '
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
# XSPEC_HOME
#

@test "XSPEC_HOME" {
    export XSPEC_HOME="${parent_dir_abs}"

    cd "${work_dir}"

    cp "${XSPEC_HOME}/bin/xspec.sh" my-xspec.sh
    chmod +x my-xspec.sh

    run ./my-xspec.sh "${XSPEC_HOME}/tutorial/escape-for-regex.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[19]}" = "passed: 5 / pending: 0 / failed: 1 / total: 6" ]
    [ "${lines[20]}" = "Report available at ${TEST_DIR}/escape-for-regex-result.html" ]
}

@test "XSPEC_HOME is not a directory" {
    export XSPEC_HOME="${work_dir}/file ${RANDOM}"
    touch "${XSPEC_HOME}"

    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "ERROR: XSPEC_HOME is not a directory: ${XSPEC_HOME}" ]
}

@test "XSPEC_HOME seems to be corrupted" {
    export XSPEC_HOME="${work_dir}"

    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "ERROR: XSPEC_HOME seems to be corrupted: ${XSPEC_HOME}" ]
}

#
# SAXON_CP has precedence over SAXON_HOME
#

@test "SAXON_CP has precedence over SAXON_HOME" {
    export SAXON_HOME="${work_dir}/empty-saxon-home ${RANDOM}"
    mkdir "${SAXON_HOME}"

    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 0 ]
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
    special_chars_dir="${work_dir}/up & down ${RANDOM}"
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
    run ../bin/xspec.sh -c -q ../tutorial/xquery-tutorial.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Coverage is supported only for XSLT" ]
}

@test "invoking xspec -c -s prints error message" {
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

    # Use a fresh dir, to make the message line numbers predictable
    # and to avoid a residue of output files
    tutorial_copy="${work_dir}/tutorial ${RANDOM}"
    mkdir "${tutorial_copy}"
    cp ../tutorial/escape-for-regex.* "${tutorial_copy}"

    # Run
    run ../bin/xspec.sh "${tutorial_copy}/escape-for-regex.xspec"
    echo "$output"
    [ "$status" -eq 0 ]

    # Verify message
    [ "${lines[19]}" = "passed: 5 / pending: 0 / failed: 1 / total: 6" ]
    [ "${lines[20]}" = "Report available at ${tutorial_copy}/xspec/escape-for-regex-result.html" ]

    # Verify report files
    # * XML report file is created
    # * HTML report file is created
    # * Coverage is disabled by default
    # * JUnit is disabled by default
    run ls "${tutorial_copy}/xspec"
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "escape-for-regex-compiled.xsl" ]
    [ "${lines[1]}" = "escape-for-regex-result.html" ]
    [ "${lines[2]}" = "escape-for-regex-result.xml" ]

    # HTML report file contains CSS inline #135
    run java -jar "${SAXON_JAR}" \
        -s:"${tutorial_copy}/xspec/escape-for-regex-result.html" \
        -xsl:html-css.xsl
    echo "$output"
    [ "${lines[0]}" = "true" ]
}

@test "invoking xspec -c without TEST_DIR set externally" {
    if [ -z "${XSLT_SUPPORTS_COVERAGE}" ]; then
        skip "XSLT_SUPPORTS_COVERAGE is not defined"
    fi

    unset TEST_DIR

    # Use a fresh dir, to make the message line numbers predictable
    # and to avoid a residue of output files
    tutorial_copy="${work_dir}/tutorial ${RANDOM}"
    mkdir "${tutorial_copy}"
    cp ../tutorial/coverage/demo* "${tutorial_copy}"

    # Run
    run ../bin/xspec.sh -c "${tutorial_copy}/demo.xspec"
    echo "$output"
    [ "$status" -eq 0 ]

    # Verify message
    # Bats bug inserts garbages into $lines: bats-core/bats-core#151
    assert_regex "${output}" $'\n''passed: 1 / pending: 0 / failed: 0 / total: 1'$'\n'
    assert_regex "${output}" $'\n''Report available at '"${tutorial_copy}"'/xspec/demo-coverage\.html'$'\n'

    # Verify report files
    # * XML report file is created
    # * HTML report file is created
    # * Coverage XML report is created
    # * Coverage HTML report is created
    # * JUnit is disabled by default
    run ls "${tutorial_copy}/xspec"
    echo "$output"
    [ "${#lines[@]}" = "5" ]
    [ "${lines[0]}" = "demo-compiled.xsl" ]
    [ "${lines[1]}" = "demo-coverage.html" ]
    [ "${lines[2]}" = "demo-coverage.xml" ]
    [ "${lines[3]}" = "demo-result.html" ]
    [ "${lines[4]}" = "demo-result.xml" ]
}

@test "invoking xspec without TEST_DIR set externally (XQuery)" {
    unset TEST_DIR

    # Use a fresh dir, to make the message line numbers predictable
    # and to avoid a residue of output files
    tutorial_copy="${work_dir}/tutorial ${RANDOM}"
    mkdir "${tutorial_copy}"
    cp ../tutorial/xquery-tutorial.* "${tutorial_copy}"

    # Run
    run ../bin/xspec.sh -q "${tutorial_copy}/xquery-tutorial.xspec"
    echo "$output"
    [ "$status" -eq 0 ]

    # Verify message
    [ "${lines[6]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
    [ "${lines[7]}" = "Report available at ${tutorial_copy}/xspec/xquery-tutorial-result.html" ]

    # Verify report files
    # * XML report file is created
    # * HTML report file is created
    # * JUnit is disabled by default
    run ls "${tutorial_copy}/xspec"
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "xquery-tutorial-compiled.xq" ]
    [ "${lines[1]}" = "xquery-tutorial-result.html" ]
    [ "${lines[2]}" = "xquery-tutorial-result.xml" ]
}

@test "invoking xspec without TEST_DIR set externally (Schematron)" {
    unset TEST_DIR

    # Use a fresh dir, to make the message line numbers predictable
    # and to avoid a residue of output files
    tutorial_copy="${work_dir}/tutorial ${RANDOM}"
    mkdir "${tutorial_copy}"
    cp ../tutorial/schematron/demo-03* "${tutorial_copy}"

    # Run
    run ../bin/xspec.sh -s "${tutorial_copy}/demo-03.xspec"
    echo "$output"
    [ "$status" -eq 0 ]

    # Verify message
    # * No Schematron warnings #129 #131
    [ "${lines[4]}"  = "Converting Schematron XSpec into XSLT XSpec..." ]
    [ "${lines[31]}" = "passed: 10 / pending: 1 / failed: 0 / total: 11" ]
    [ "${lines[32]}" = "Report available at ${tutorial_copy}/xspec/demo-03-result.html" ]

    # Verify report files
    # * XML report file is created
    # * HTML report file is created
    # * JUnit is disabled by default
    # * Schematron-specific temporary files are deleted
    run ls "${tutorial_copy}/xspec"
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "demo-03-compiled.xsl" ]
    [ "${lines[1]}" = "demo-03-result.html" ]
    [ "${lines[2]}" = "demo-03-result.xml" ]
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
# Runtime warning
#

@test "invoking xspec that passes a non xs:boolean does not raise a warning #46" {
    run ../bin/xspec.sh xspec-46.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${lines[5]}" '^Testing with '
}

@test "x:resolve-EQName-ignoring-default-ns() with non-empty prefix does not raise a warning #826" {
    run ../bin/xspec.sh xspec-826.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${lines[5]}" '^Testing with '
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
        -p xspec-home="file:${parent_dir_abs}/" \
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
        -p xspec-home="file:${parent_dir_abs}/" \
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
    special_chars_dir="${work_dir}/some'path (84) here & there ${RANDOM}"
    mkdir "${special_chars_dir}"
    cp mirror.xsl             "${special_chars_dir}"
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
    special_chars_dir="${work_dir}/some'path (84) here & there ${RANDOM}"
    mkdir "${special_chars_dir}"
    cp mirror.xquery          "${special_chars_dir}"
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
    special_chars_dir="${work_dir}/some'path (84) here & there ${RANDOM}"
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
    assert_regex "${output}" $'\n''     \[xslt\] passed: 9 / pending: 0 / failed: 0 / total: 9'$'\n'
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]
}

#
# Schematron XSLTs provided externally
#

@test "invoking xspec with Schematron XSLTs provided externally uses provided XSLTs for Schematron compile (CLI)" {
    export SCHEMATRON_XSLT_INCLUDE=schematron/schematron-xslt-include.xsl
    export SCHEMATRON_XSLT_EXPAND=schematron/schematron-xslt-expand.xsl
    export SCHEMATRON_XSLT_COMPILE=schematron/schematron-xslt-compile.xsl

    run ../bin/xspec.sh -s schematron/schematron-xslt.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[12]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
}

@test "invoking xspec with Schematron XSLTs provided externally uses provided XSLTs for Schematron compile (Ant)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=s \
        -Dxspec.schematron.preprocessor.step1="${PWD}/schematron/schematron-xslt-include.xsl" \
        -Dxspec.schematron.preprocessor.step2="${PWD}/schematron/schematron-xslt-expand.xsl" \
        -Dxspec.schematron.preprocessor.step3="${PWD}/schematron/schematron-xslt-compile.xsl" \
        -Dxspec.xml="${PWD}/schematron/schematron-xslt.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-10]}" = "     [xslt] passed: 1 / pending: 0 / failed: 0 / total: 1" ]
    [ "${lines[${#lines[@]}-2]}"  = "BUILD SUCCESSFUL" ]
}

#
# CLI with TEST_DIR
#

@test "invoking xspec with TEST_DIR creates files in TEST_DIR (XSLT)" {
    # Use a fresh dir, to make the message line numbers predictable
    # and to avoid a residue of output files
    tutorial_copy="${work_dir}/tutorial ${RANDOM}"
    mkdir "${tutorial_copy}"
    cp ../tutorial/escape-for-regex.* "${tutorial_copy}"

    # Run with absolute TEST_DIR
    run ../bin/xspec.sh "${tutorial_copy}/escape-for-regex.xspec"
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
    assert_leaf_dir_not_exist "${tutorial_copy}/xspec"

    # Run with relative TEST_DIR
    cd "${work_dir}"
    export TEST_DIR="relative-test-dir ${RANDOM}"
    run "${parent_dir_abs}/bin/xspec.sh" "${tutorial_copy}/escape-for-regex.xspec"
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
}

@test "invoking xspec -c with TEST_DIR creates files in TEST_DIR" {
    if [ -z "${XSLT_SUPPORTS_COVERAGE}" ]; then
        skip "XSLT_SUPPORTS_COVERAGE is not defined"
    fi

    # Use a fresh dir, to make the message line numbers predictable
    # and to avoid a residue of output files
    tutorial_copy="${work_dir}/tutorial ${RANDOM}"
    mkdir "${tutorial_copy}"
    cp ../tutorial/coverage/demo* "${tutorial_copy}"

    # Run with absolute TEST_DIR
    run ../bin/xspec.sh -c "${tutorial_copy}/demo.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    # Bats bug inserts garbages into $lines: bats-core/bats-core#151
    assert_regex "${output}" $'\n''Report available at '"${TEST_DIR}"'/demo-coverage\.html'

    # Verify files in specified TEST_DIR
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "5" ]
    [ "${lines[0]}" = "demo-compiled.xsl" ]
    [ "${lines[1]}" = "demo-coverage.html" ]
    [ "${lines[2]}" = "demo-coverage.xml" ]
    [ "${lines[3]}" = "demo-result.html" ]
    [ "${lines[4]}" = "demo-result.xml" ]

    # Default output dir should not be created
    assert_leaf_dir_not_exist "${tutorial_copy}/xspec"

    # Run with relative TEST_DIR
    cd "${work_dir}"
    export TEST_DIR="relative-test-dir ${RANDOM}"
    run "${parent_dir_abs}/bin/xspec.sh" -c "${tutorial_copy}/demo.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    # Bats bug inserts garbages into $lines: bats-core/bats-core#151
    assert_regex "${output}" $'\n''Report available at '"${TEST_DIR}"'/demo-coverage\.html'

    # Verify files in specified TEST_DIR
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "5" ]
    [ "${lines[0]}" = "demo-compiled.xsl" ]
    [ "${lines[1]}" = "demo-coverage.html" ]
    [ "${lines[2]}" = "demo-coverage.xml" ]
    [ "${lines[3]}" = "demo-result.html" ]
    [ "${lines[4]}" = "demo-result.xml" ]
}

@test "invoking xspec with TEST_DIR creates files in TEST_DIR (XQuery)" {
    # Use a fresh dir, to make the message line numbers predictable
    # and to avoid a residue of output files
    tutorial_copy="${work_dir}/tutorial ${RANDOM}"
    mkdir "${tutorial_copy}"
    cp ../tutorial/xquery-tutorial.* "${tutorial_copy}"

    # Run with absolute TEST_DIR
    run ../bin/xspec.sh -q "${tutorial_copy}/xquery-tutorial.xspec"
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
    assert_leaf_dir_not_exist "${tutorial_copy}/xspec"

    # Run with relative TEST_DIR
    cd "${work_dir}"
    export TEST_DIR="relative-test-dir ${RANDOM}"
    run "${parent_dir_abs}/bin/xspec.sh" -q "${tutorial_copy}/xquery-tutorial.xspec"
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
}

@test "invoking xspec with TEST_DIR creates files in TEST_DIR (Schematron)" {
    # Test with x:context[node()] #322

    # Use a fresh dir, to make the message line numbers predictable
    # and to avoid a residue of output files
    tutorial_copy="${work_dir}/tutorial ${RANDOM}"
    mkdir "${tutorial_copy}"
    cp ../tutorial/schematron/demo-03* "${tutorial_copy}"

    # Run with absolute TEST_DIR
    run ../bin/xspec.sh -s "${tutorial_copy}/demo-03.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[32]}" = "Report available at ${TEST_DIR}/demo-03-result.html" ]

    # Verify files in specified TEST_DIR
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "demo-03-compiled.xsl" ]
    [ "${lines[1]}" = "demo-03-result.html" ]
    [ "${lines[2]}" = "demo-03-result.xml" ]

    # Default output dir should not be created
    assert_leaf_dir_not_exist "${tutorial_copy}/xspec"

    # Run with relative TEST_DIR
    cd "${work_dir}"
    export TEST_DIR="relative-test-dir ${RANDOM}"
    run "${parent_dir_abs}/bin/xspec.sh" -s "${tutorial_copy}/demo-03.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[32]}" = "Report available at ${TEST_DIR}/demo-03-result.html" ]

    # Verify files in specified TEST_DIR
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "demo-03-compiled.xsl" ]
    [ "${lines[1]}" = "demo-03-result.html" ]
    [ "${lines[2]}" = "demo-03-result.xml" ]
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
    compiled_file="${work_dir}/compiled_${RANDOM}.xq"
    expected_report="${work_dir}/xquery-tutorial-result_${RANDOM}.html"

    # Run
    run java -jar "${XMLCALABASH_JAR}" \
        -i source=../tutorial/xquery-tutorial.xspec \
        -o result="file:${expected_report}" \
        -p basex-jar="${BASEX_JAR}" \
        -p compiled-file="file:${compiled_file}" \
        -p xspec-home="file:${parent_dir_abs}/" \
        ../src/harnesses/basex/basex-standalone-xquery-harness.xproc
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${lines[${#lines[@]}-1]}" '.+:passed: 1 / pending: 0 / failed: 0 / total: 1'

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
    expected_report="${work_dir}/xquery-tutorial-result_${RANDOM}.html"

    # Run
    run java -jar "${XMLCALABASH_JAR}" \
        -i source=../tutorial/xquery-tutorial.xspec \
        -o result="file:${expected_report}" \
        -p auth-method=Basic \
        -p endpoint=http://localhost:8984/rest \
        -p password=admin \
        -p username=admin \
        -p xspec-home="file:${parent_dir_abs}/" \
        ../src/harnesses/basex/basex-server-xquery-harness.xproc
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" = "2" ]
    assert_regex "${lines[1]}" '.+:passed: 1 / pending: 0 / failed: 0 / total: 1'

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

    # Use a fresh dir, to avoid a residue of default output dir
    tutorial_copy="${work_dir}/tutorial ${RANDOM}"
    mkdir "${tutorial_copy}"
    cp ../tutorial/escape-for-regex.* "${tutorial_copy}"

    # Run
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.xml="${tutorial_copy}/escape-for-regex.xspec"
    echo "$output"

    # Default xspec.fail is true
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''     \[xslt\] passed: 5 / pending: 0 / failed: 1 / total: 6'$'\n'
    [ "${lines[${#lines[@]}-3]}" = "BUILD FAILED" ]

    # Verify default output dir
    # * Default clean.output.dir is false
    # * Default xspec.coverage.enabled is false
    # * Default xspec.junit.enabled is false
    run env LC_ALL=C ls "${tutorial_copy}/xspec"
    echo "$output"
    [ "${#lines[@]}" = "4" ]
    [ "${lines[0]}" = "escape-for-regex-compiled.xsl" ]
    [ "${lines[1]}" = "escape-for-regex-result.html" ]
    [ "${lines[2]}" = "escape-for-regex-result.xml" ]
    [ "${lines[3]}" = "escape-for-regex_xml-to-properties.xml" ]

    # HTML report file contains CSS inline
    run java -jar "${SAXON_JAR}" \
        -s:"${tutorial_copy}/xspec/escape-for-regex-result.html" \
        -xsl:html-css.xsl
    echo "$output"
    [ "${lines[0]}" = "true" ]
}

@test "Ant with minimum properties (XQuery)" {
    # Unset any preset args
    unset ANT_ARGS

    # Use a fresh dir, to avoid a residue of default output dir
    tutorial_copy="${work_dir}/tutorial ${RANDOM}"
    mkdir "${tutorial_copy}"
    cp ../tutorial/xquery-tutorial.* "${tutorial_copy}"

    # Run
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=q \
        -Dxspec.xml="${tutorial_copy}/xquery-tutorial.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${output}" $'\n''     \[xslt\] passed: 1 / pending: 0 / failed: 0 / total: 1'$'\n'
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    # Verify default output dir
    # * Default clean.output.dir is false
    # * Default xspec.junit.enabled is false
    run env LC_ALL=C ls "${tutorial_copy}/xspec"
    echo "$output"
    [ "${#lines[@]}" = "4" ]
    [ "${lines[0]}" = "xquery-tutorial-compiled.xq" ]
    [ "${lines[1]}" = "xquery-tutorial-result.html" ]
    [ "${lines[2]}" = "xquery-tutorial-result.xml" ]
    [ "${lines[3]}" = "xquery-tutorial_xml-to-properties.xml" ]
}

@test "Ant with minimum properties (Schematron)" {
    # Unset any preset args
    unset ANT_ARGS

    # Use a fresh dir, to avoid a residue of default output dir
    tutorial_copy="${work_dir}/tutorial ${RANDOM}"
    mkdir "${tutorial_copy}"
    cp ../tutorial/schematron/demo-03* "${tutorial_copy}"

    # Run
    # * Should work without phase #168
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=s \
        -Dxspec.xml="${tutorial_copy}/demo-03.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${output}" $'\n''     \[xslt\] passed: 10 / pending: 1 / failed: 0 / total: 11'$'\n'
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    # Verify default output dir
    # * Default clean.output.dir is false
    # * Default xspec.junit.enabled is false
    run env LC_ALL=C ls "${tutorial_copy}/xspec"
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
    assert_regex "${output}" $'\n''     \[xslt\] passed: 5 / pending: 0 / failed: 1 / total: 6'$'\n'
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
    assert_regex "${output}" $'\n''     \[xslt\] passed: 5 / pending: 0 / failed: 1 / total: 6'$'\n'
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
    assert_regex "${output}" $'\n''     \[xslt\] passed: 5 / pending: 0 / failed: 1 / total: 6'$'\n'
}

@test "Ant verbose test.type (XQuery)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=xquerY \
        -Dxspec.xml="${PWD}/../tutorial/xquery-tutorial.xspec"
    echo "$output"
    assert_regex "${output}" $'\n''     \[xslt\] passed: 1 / pending: 0 / failed: 0 / total: 1'$'\n'
}

@test "Ant verbose test.type (Schematron)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dclean.output.dir=true \
        -Dtest.type=schematroN \
        -Dxspec.xml="${PWD}/../tutorial/schematron/demo-01.xspec"
    echo "$output"
    assert_regex "${output}" $'\n''     \[xslt\] passed: 3 / pending: 0 / failed: 0 / total: 3'$'\n'
}

#
# Ant various properties
#

@test "Ant for Schematron with various properties except catalog and xspec.fail" {
    build_xml="${work_dir}/build ${RANDOM}.xml"

    # For testing -Dxspec.project.dir
    cp ../build.xml "${build_xml}"

    # Use a fresh dir, to avoid a residue of default output dir
    tutorial_copy="${work_dir}/tutorial ${RANDOM}"
    mkdir "${tutorial_copy}"
    cp ../tutorial/schematron/demo-03* "${tutorial_copy}"

    # Run
    run ant \
        -buildfile "${build_xml}" \
        -lib "${SAXON_JAR}" \
        -Dclean.output.dir=true \
        -Dxspec.project.dir="${PWD}/.." \
        -Dxspec.properties="${PWD}/schematron.properties" \
        -Dxspec.xml="${tutorial_copy}/demo-03.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${output}" $'\n''     \[xslt\] passed: 10 / pending: 1 / failed: 0 / total: 11'$'\n'
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    # Verify that -Dxspec.dir was honored and the default output dir was not created
    assert_leaf_dir_not_exist "${tutorial_copy}/xspec"

    # Verify clean.output.dir=true
    assert_leaf_dir_not_exist "${TEST_DIR}"
}

#
# Catalog (CLI) (-catalog)
#

@test "CLI with -catalog uses XML Catalog resolver and does so even with spaces in file path (XSLT)" {
    if [ -z "${XML_RESOLVER_JAR}" ]; then
        skip "XML_RESOLVER_JAR is not defined"
    fi

    space_dir="${work_dir}/cat a log ${RANDOM}"
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

    space_dir="${work_dir}/cat a log ${RANDOM}"
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

    export SAXON_HOME="${work_dir}/saxon ${RANDOM}"
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
# saxon.custom.options (Ant)
#

@test "Ant for XSLT with saxon.custom.options" {
    # Test with a space in file name
    saxon_config="${work_dir}/saxon config ${RANDOM}.xml"
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
    assert_regex "${output}" $'\n''     \[xslt\] passed: 3 / pending: 0 / failed: 0 / total: 3'$'\n'
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    # Verify '-t'
    assert_regex "${output}" $'\n''     \[java\] Memory used:'
}

@test "Ant for XQuery with saxon.custom.options" {
    # Test with a space in file name
    saxon_config="${work_dir}/saxon config ${RANDOM}.xml"
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
    assert_regex "${output}" $'\n''     \[xslt\] passed: 3 / pending: 0 / failed: 0 / total: 3'$'\n'
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    # Verify '-t'
    assert_regex "${output}" $'\n''     \[java\] Memory used:'
}

#
# SAXON_CUSTOM_OPTIONS (CLI)
#

@test "invoking xspec for XSLT with SAXON_CUSTOM_OPTIONS" {
    # Test with a space in file name
    saxon_config="${work_dir}/saxon config ${RANDOM}.xml"
    cp saxon-custom-options/config.xml "${saxon_config}"

    export SAXON_CUSTOM_OPTIONS="\"-config:${saxon_config}\" -t"
    run ../bin/xspec.sh saxon-custom-options/test.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-3]}" = "passed: 3 / pending: 0 / failed: 0 / total: 3" ]

    # Verify '-t'
    assert_regex "${output}" $'\n''Memory used:'
}

@test "invoking xspec for XQuery with SAXON_CUSTOM_OPTIONS" {
    # Test with a space in file name
    saxon_config="${work_dir}/saxon config ${RANDOM}.xml"
    cp saxon-custom-options/config.xml "${saxon_config}"

    export SAXON_CUSTOM_OPTIONS="\"-config:${saxon_config}\" -t"
    run ../bin/xspec.sh -q saxon-custom-options/test.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-3]}" = "passed: 3 / pending: 0 / failed: 0 / total: 3" ]

    # Verify '-t'
    assert_regex "${output}" $'\n''Memory used:'
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
    assert_regex "${output}" $'\n''     \[xslt\] passed: 1 / pending: 0 / failed: 0 / total: 1'$'\n'
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
    assert_regex "${lines[${#lines[@]}-2]}" 'Coverage is supported only for XSLT'
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
    assert_regex "${lines[${#lines[@]}-2]}" 'Coverage is supported only for XSLT'
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
    assert_regex "${output}" $'\n''     \[xslt\] passed: 5 / pending: 0 / failed: 1 / total: 6'$'\n'
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
    assert_regex "${lines[11]}" '^WARNING: x:expect has boolean @test'
    assert_regex "${lines[16]}" '^WARNING: x:expect has boolean @test'
    assert_regex "${lines[23]}" '^WARNING: x:expect has boolean @test'
    [  "${lines[32]}" =  "Formatting Report..." ]
}

#
# Obsolete x:space
#

@test "Obsolete x:space" {
    run ../bin/xspec.sh obsolete-space/test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''x:space is obsolete\. Use x:text instead\.'$'\n'
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
        -p xspec-home="file:${parent_dir_abs}/" \
        ../src/harnesses/saxon/saxon-xslt-harness.xproc
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${lines[${#lines[@]}-3]}" '.+err:XPDY0002:'
    assert_regex "${lines[${#lines[@]}-1]}" '^ERROR:'
}

@test "XQuery selecting nodes without context should be error (XProc) #423" {
    if [ -z "${XMLCALABASH_JAR}" ]; then
        skip "XMLCALABASH_JAR is not defined"
    fi

    run java -jar "${XMLCALABASH_JAR}" \
        -i source=xspec-423/test.xspec \
        -p xspec-home="file:${parent_dir_abs}/" \
        ../src/harnesses/saxon/saxon-xquery-harness.xproc
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${lines[${#lines[@]}-3]}" '.+err:XPDY0002:'
    assert_regex "${lines[${#lines[@]}-1]}" '^ERROR:'
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
    assert_regex "${output}" $'\n''     \[java\]   XPDY0002[: ]'
    [ "${lines[${#lines[@]}-3]}" = "BUILD FAILED" ]
}

@test "XSLT selecting nodes without context should be error (CLI) #423" {
    run ../bin/xspec.sh xspec-423/test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  XPDY0002[: ]'
    [ "${lines[${#lines[@]}-1]}" = "*** Error running the test suite" ]
}

@test "XSLT selecting nodes without context should be error (CLI -c) #423" {
    if [ -z "${XSLT_SUPPORTS_COVERAGE}" ]; then
        skip "XSLT_SUPPORTS_COVERAGE is not defined"
    fi

    run ../bin/xspec.sh -c xspec-423/test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  XPDY0002[: ]'
    [ "${lines[${#lines[@]}-1]}" = "*** Error collecting test coverage data" ]
}

@test "XQuery selecting nodes without context should be error (CLI) #423" {
    run ../bin/xspec.sh -q xspec-423/test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  XPDY0002[: ]'
    [ "${lines[${#lines[@]}-1]}" = "*** Error running the test suite" ]
}

#
# @xquery-version
#

@test "Default @xquery-version" {
    run ../bin/xspec.sh -q ../tutorial/xquery-tutorial.xspec
    echo "$output"
    [ "$status" -eq 0 ]

    run cat "${TEST_DIR}/xquery-tutorial-compiled.xq"
    [ "${lines[0]}" = 'xquery version "3.1";' ]
}

@test "Invalid @xquery-version should be error" {
    run ../bin/xspec.sh -q xquery-version/invalid.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" '.+XQST0031.+InVaLiD'
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
    assert_regex "${lines[4]}" '^Source document is not XSpec'
}

#
# User-defined variable in XSpec namespace
#

@test "Error on user-defined variable in XSpec namespace (URIQualifiedName in local variable)" {
    run ../bin/xspec.sh variable/reserved-eqname.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${lines[5]}" '^  x:XSPEC008[: ] User-defined XSpec variable, Q\{http://www\.jenitennison\.com/xslt/xspec\}foo,$'
    [ "${lines[6]}" = "  must not use the XSpec namespace." ]
}

@test "Error on user-defined variable in XSpec namespace (QName in global variable)" {
    run ../bin/xspec.sh variable/reserved-name.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${lines[5]}" '^  x:XSPEC008[: ] User-defined XSpec variable, u:foo, must not use the XSpec namespace\.$'
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
        assert_regex "${lines[3]}" '^WARNING: Saxon version .+'
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
    assert_regex "${output}" $'\n'' \[makepath\] Setting xspec\.schematron\.file to file path '"${PWD}"'/do-nothing\.sch'$'\n'
}

#
# @catch should not catch error outside SUT
#

@test "@catch should not catch error outside SUT (XSLT)" {
    run ../bin/xspec.sh catch/compiler-error.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''ERROR in scenario '

    run ../bin/xspec.sh catch/error-in-context-avt-for-template-call.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  error-code-of-my-context-avt-for-template-call[: ] Error signalled '

    run ../bin/xspec.sh catch/error-in-context-param-for-matching-template.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  error-code-of-my-context-param-for-matching-template[: ] Error signalled '

    run ../bin/xspec.sh catch/error-in-function-call-param.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  error-code-of-my-function-call-param[: ] Error signalled '

    run ../bin/xspec.sh catch/error-in-template-call-param.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  error-code-of-my-template-call-param[: ] Error signalled '

    run ../bin/xspec.sh catch/error-in-variable.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  error-code-of-my-variable[: ] Error signalled '

    run ../bin/xspec.sh catch/static-error-in-compiled-test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" 'XPST0017[: ]'
}

@test "@catch should not catch error outside SUT (XQuery)" {
    run ../bin/xspec.sh -q catch/compiler-error.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" 'x:XSPEC005[: ]'

    run ../bin/xspec.sh -q catch/error-in-function-call-param.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  error-code-of-my-function-call-param[: ] Error signalled '

    run ../bin/xspec.sh -q catch/error-in-variable.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  error-code-of-my-variable[: ] Error signalled '

    run ../bin/xspec.sh -q catch/static-error-in-compiled-test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" 'XPST0017[: ]'
}

#
# Error in SUT should not be caught by default
#

@test "Error in SUT should not be caught by default (XSLT)" {
    run ../bin/xspec.sh catch/no-by-default.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  my-error-code[: ] Error signalled '
}

@test "Error in SUT should not be caught by default (XQuery)" {
    run ../bin/xspec.sh -q catch/no-by-default.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  my-error-code[: ] Error signalled '
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
    export "TEST_DIR=/tmp/XSpec-655 ${RANDOM}"

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
    assert_regex "${lines[5]}" '^  x:XSPEC009[: ] x:like: Scenario not found: none$'

    run ../bin/xspec.sh like/multiple.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${lines[4]}" '^  x:XSPEC010[: ] x:like: 2 scenarios found with same label: shared scenario$'

    run ../bin/xspec.sh like/loop.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${lines[4]}" '^  x:XSPEC011[: ] x:like: Reference to ancestor scenario creates infinite loop: parent scenario$'
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
    assert_regex "${output}" $'\n''     \[xslt\] passed: 5 / pending: 0 / failed: 1 / total: 6'$'\n'
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    run cat "${TEST_DIR}/escape-for-regex-compiled.xsl"
    echo "$output"
    assert_regex "${output}" '.+x:overridden-scenario-id-'
    assert_regex "${output}" '.+x:overridden-expect-id'
}

#
# Custom HTML reporter (CLI)
#
#     Ant is tested by XSPEC_HOME/test/end-to-end/cases/format-xspec-report-folding.xspec
#

@test "Custom HTML reporter (CLI)" {
    export HTML_REPORTER_XSL=format-xspec-report-messaging.xsl
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-16]}" = "--- Actual Result ---" ]
    [ "${lines[${#lines[@]}-9]}"  = "--- Expected Result ---" ]
}

#
# Custom coverage reporter (CLI)
#
#     Ant is tested by XSPEC_HOME/test/end-to-end/cases/custom-coverage-report.xspec
#

@test "Custom coverage reporter (CLI)" {
    if [ -z "${XSLT_SUPPORTS_COVERAGE}" ]; then
        skip "XSLT_SUPPORTS_COVERAGE is not defined"
    fi

    export COVERAGE_REPORTER_XSL=custom-coverage-report.xsl
    run ../bin/xspec.sh -c ../tutorial/coverage/demo.xspec
    echo "$output"
    [ "$status" -eq 0 ]

    run cat "${TEST_DIR}/demo-coverage.html"
    echo "$output"
    assert_regex "${output}" '.+--Customized coverage report--.+'
}

#
# Broken x:import
#

@test "x:import with unreachable @href" {
    run ../bin/xspec.sh import/file-not-found.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  FODC0002[: ] I/O error reported by XML parser processing'$'\n'
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

@test "x:import without @href" {
    run ../bin/xspec.sh import/no-href.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  XPDY0050[: ] An empty sequence is not allowed as the value in '\''treat as'\'' expression'$'\n'
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}


