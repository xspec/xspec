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

    unset JAVA_TOOL_OPTIONS

    # XML and HTML report file
    [ -f "${special_chars_dir}/xspec/demo-result.xml" ]
    [ -f "${special_chars_dir}/xspec/demo-result.html" ]

    # Check the coverage trace XML file contents
    run java -jar "${SAXON_JAR}" \
        -s:"${special_chars_dir}/xspec/demo-coverage.xml" \
        -xsl:check-coverage-xml.xsl
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "true" ]

    # Coverage report HTML file is created and contains CSS inline #194
    run java -jar "${SAXON_JAR}" -s:"${special_chars_dir}/xspec/demo-coverage.html" -xsl:check-html-css.xsl
    echo "$output"
    [ "$status" -eq 0 ]
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
        -xsl:check-html-css.xsl
    echo "$output"
    [ "$status" -eq 0 ]
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
    [ "${lines[3]}"  = "Converting Schematron XSpec into XSLT XSpec..." ]
    [ "${lines[30]}" = "passed: 10 / pending: 1 / failed: 0 / total: 11" ]
    [ "${lines[31]}" = "Report available at ${tutorial_copy}/xspec/demo-03-result.html" ]

    # Verify report files
    # * XML report file is created
    # * HTML report file is created
    # * JUnit is disabled by default
    run ls "${tutorial_copy}/xspec"
    echo "$output"
    [ "${#lines[@]}" = "5" ]
    [ "${lines[0]}" = "demo-03-compiled.xsl" ]
    [ "${lines[1]}" = "demo-03-result.html" ]
    [ "${lines[2]}" = "demo-03-result.xml" ]
    [ "${lines[3]}" = "demo-03-sch-preprocessed.xsl" ]
    [ "${lines[4]}" = "demo-03-sch-preprocessed.xspec" ]
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
    run ../bin/xspec.sh issue-46.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${lines[5]}" '^Testing with '
}

@test "x:resolve-EQName-ignoring-default-ns() with non-empty prefix does not raise a warning #826" {
    run ../bin/xspec.sh issue-826.xspec
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
    actual_report="${actual_report_dir}/serialize-result.html"

    # Run
    run java -cp "${XMLCALABASH_JAR}:${SAXON_JAR}" com.xmlcalabash.drivers.Main \
        -i source=end-to-end/cases/serialize.xspec \
        -o result="file:${actual_report}" \
        -p xspec-home="file:${parent_dir_abs}/" \
        ../src/harnesses/saxon/saxon-xslt-harness.xproc
    echo "$output"
    [ "$status" -eq 0 ]

    # Verify HTML report including #72
    run java -jar "${SAXON_JAR}" \
        -s:"${actual_report}" \
        -xsl:end-to-end/processor/html/compare.xsl \
        EXPECTED-DOC-URI="file:${actual_report_dir}/../../expected/stylesheet/serialize-result.html" \
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
    actual_report="${actual_report_dir}/serialize-result.html"

    # Run
    run java -cp "${XMLCALABASH_JAR}:${SAXON_JAR}" com.xmlcalabash.drivers.Main \
        -i source=end-to-end/cases/serialize.xspec \
        -o result="file:${actual_report}" \
        -p xspec-home="file:${parent_dir_abs}/" \
        ../src/harnesses/saxon/saxon-xquery-harness.xproc
    echo "$output"
    [ "$status" -eq 0 ]

    # Verify HTML report including #72
    run java -jar "${SAXON_JAR}" \
        -s:"${actual_report}" \
        -xsl:end-to-end/processor/html/compare.xsl \
        EXPECTED-DOC-URI="file:${actual_report_dir}/../../expected/query/serialize-result.html" \
        NORMALIZE-HTML-DATETIME="2000-01-01T00:00:00Z"
    echo "$output"
    [ "$status" -eq 0 ]
}

@test "XProc harness for Saxon (XQuery with special characters in expression #1020)" {
    if [ -z "${XMLCALABASH_JAR}" ]; then
        skip "XMLCALABASH_JAR is not defined"
    fi

    run java -cp "${XMLCALABASH_JAR}:${SAXON_JAR}" com.xmlcalabash.drivers.Main \
        -i source=issue-1020.xspec \
        -o result="file:${work_dir}/issue-1020-result_${RANDOM}.html" \
        -p xspec-home="file:${parent_dir_abs}/" \
        ../src/harnesses/saxon/saxon-xquery-harness.xproc
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${#lines[@]}" = "2" ]
    assert_regex "${lines[1]}" '.+:passed: 15 / pending: 0 / failed: 0 / total: 15'
}

#
# Path containing special chars (CLI)
#

@test "invoking xspec with path containing special chars (#84 #119 #202 #716) runs and loads doc (#610) successfully and generates HTML report file (XSLT)" {
    special_chars_dir="${work_dir}/some'path (84) here & there ${RANDOM}"
    mkdir "${special_chars_dir}"
    cp mirror.xsl       "${special_chars_dir}"
    cp node-selection.* "${special_chars_dir}"

    unset TEST_DIR
    expected_report="${special_chars_dir}/xspec/node-selection-result.html"

    run ../bin/xspec.sh "${special_chars_dir}/node-selection.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[29]}" = "Report available at ${expected_report}" ]
    [ -f "${expected_report}" ]
}

@test "invoking xspec with path containing special chars (#84 #119 #202 #716) runs and loads doc (#610) successfully and generates HTML report file (XQuery)" {
    special_chars_dir="${work_dir}/some'path (84) here & there ${RANDOM}"
    mkdir "${special_chars_dir}"
    cp mirror.xqm       "${special_chars_dir}"
    cp node-selection.* "${special_chars_dir}"

    unset TEST_DIR
    expected_report="${special_chars_dir}/xspec/node-selection-result.html"

    run ../bin/xspec.sh -q "${special_chars_dir}/node-selection.xspec"
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
    [ "${lines[31]}" = "Report available at ${expected_report}" ]
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
    [ "${lines[19]}" = "passed: 9 / pending: 0 / failed: 0 / total: 9" ]
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
    [ "${lines[11]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
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
    [ "${lines[31]}" = "Report available at ${TEST_DIR}/demo-03-result.html" ]

    # Verify files in specified TEST_DIR
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "5" ]
    [ "${lines[0]}" = "demo-03-compiled.xsl" ]
    [ "${lines[1]}" = "demo-03-result.html" ]
    [ "${lines[2]}" = "demo-03-result.xml" ]
    [ "${lines[3]}" = "demo-03-sch-preprocessed.xsl" ]
    [ "${lines[4]}" = "demo-03-sch-preprocessed.xspec" ]

    # Default output dir should not be created
    assert_leaf_dir_not_exist "${tutorial_copy}/xspec"

    # Run with relative TEST_DIR
    cd "${work_dir}"
    export TEST_DIR="relative-test-dir ${RANDOM}"
    run "${parent_dir_abs}/bin/xspec.sh" -s "${tutorial_copy}/demo-03.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[31]}" = "Report available at ${TEST_DIR}/demo-03-result.html" ]

    # Verify files in specified TEST_DIR
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "5" ]
    [ "${lines[0]}" = "demo-03-compiled.xsl" ]
    [ "${lines[1]}" = "demo-03-result.html" ]
    [ "${lines[2]}" = "demo-03-result.xml" ]
    [ "${lines[3]}" = "demo-03-sch-preprocessed.xsl" ]
    [ "${lines[4]}" = "demo-03-sch-preprocessed.xspec" ]
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
    expected_report="${work_dir}/issue-1020-result_${RANDOM}.html"

    # Run (also test with special characters in expression #1020)
    run java -cp "${XMLCALABASH_JAR}:${SAXON_JAR}" com.xmlcalabash.drivers.Main \
        -i source=issue-1020.xspec \
        -o result="file:${expected_report}" \
        -p basex-jar="${BASEX_JAR}" \
        -p compiled-file="file:${compiled_file}" \
        -p xspec-home="file:${parent_dir_abs}/" \
        ../src/harnesses/basex/basex-standalone-xquery-harness.xproc
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${lines[${#lines[@]}-1]}" '.+:passed: 15 / pending: 0 / failed: 0 / total: 15'

    # Compiled file
    [ -f "${compiled_file}" ]

    # HTML report file should be created and its charset should be UTF-8 #72
    run java -jar "${SAXON_JAR}" -s:"${expected_report}" -xsl:check-html-charset.xsl
    echo "$output"
    [ "$status" -eq 0 ]
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
    expected_report="${work_dir}/issue-1020-result_${RANDOM}.html"

    # Run (also test with special characters in expression #1020)
    run java -cp "${XMLCALABASH_JAR}:${SAXON_JAR}" com.xmlcalabash.drivers.Main \
        -i source=issue-1020.xspec \
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
    assert_regex "${lines[1]}" '.+:passed: 15 / pending: 0 / failed: 0 / total: 15'

    # HTML report file should be created and its charset should be UTF-8 #72
    run java -jar "${SAXON_JAR}" -s:"${expected_report}" -xsl:check-html-charset.xsl
    echo "$output"
    [ "$status" -eq 0 ]
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
        -xsl:check-html-css.xsl
    echo "$output"
    [ "$status" -eq 0 ]
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
    [ "${#lines[@]}" = "6" ]
    [ "${lines[0]}" = "demo-03-compiled.xsl" ]
    [ "${lines[1]}" = "demo-03-result.html" ]
    [ "${lines[2]}" = "demo-03-result.xml" ]
    [ "${lines[3]}" = "demo-03-sch-preprocessed.xsl" ]
    [ "${lines[4]}" = "demo-03-sch-preprocessed.xspec" ]
    [ "${lines[5]}" = "demo-03_xml-to-properties.xml" ]
}

#
# Catalog file path (Ant)
#
#     Test 'catalog' property containing multiple file paths (relative and absolute)
#

@test "Ant with catalog file path (XSLT)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -lib "${XML_RESOLVER_JAR}" \
        -Dcatalog="test/catalog/01/catalog-public.xml;${PWD}/catalog/01/catalog-rewriteURI.xml" \
        -Dxspec.xml="${PWD}/catalog/catalog-01_stylesheet.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-10]}" = "     [xslt] passed: 4 / pending: 0 / failed: 0 / total: 4" ]
    [ "${lines[${#lines[@]}-2]}"  = "BUILD SUCCESSFUL" ]
}

@test "Ant with catalog file path (XQuery)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -lib "${XML_RESOLVER_JAR}" \
        -Dcatalog="test/catalog/01/catalog-public.xml;${PWD}/catalog/01/catalog-rewriteURI.xml" \
        -Dtest.type=q \
        -Dxspec.xml="${PWD}/catalog/catalog-01_query.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-10]}" = "     [xslt] passed: 2 / pending: 0 / failed: 0 / total: 2" ]
    [ "${lines[${#lines[@]}-2]}"  = "BUILD SUCCESSFUL" ]
}

@test "Ant with catalog file path (Schematron)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -lib "${XML_RESOLVER_JAR}" \
        -Dcatalog="test/catalog/01/catalog-public.xml;${PWD}/catalog/01/catalog-rewriteURI.xml" \
        -Dtest.type=s \
        -Dxspec.xml="${PWD}/catalog/catalog-01_schematron.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-10]}" = "     [xslt] passed: 4 / pending: 0 / failed: 0 / total: 4" ]
    [ "${lines[${#lines[@]}-2]}"  = "BUILD SUCCESSFUL" ]
}

#
# Catalog file URI (Ant)
#
#     Test 'catalog' property containing multiple URIs (relative and absolute)
#

@test "Ant with catalog file URI (XSLT)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -lib "${XML_RESOLVER_JAR}" \
        -Dcatalog="test/catalog/01/catalog-public.xml;file:${PWD}/catalog/01/catalog-rewriteURI.xml" \
        -Dcatalog.is.uri=true \
        -Dxspec.xml="${PWD}/catalog/catalog-01_stylesheet.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-10]}" = "     [xslt] passed: 4 / pending: 0 / failed: 0 / total: 4" ]
    [ "${lines[${#lines[@]}-2]}"  = "BUILD SUCCESSFUL" ]
}

@test "Ant with catalog file URI (XQuery)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -lib "${XML_RESOLVER_JAR}" \
        -Dcatalog="test/catalog/01/catalog-public.xml;file:${PWD}/catalog/01/catalog-rewriteURI.xml" \
        -Dcatalog.is.uri=true \
        -Dtest.type=q \
        -Dxspec.xml="${PWD}/catalog/catalog-01_query.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-10]}" = "     [xslt] passed: 2 / pending: 0 / failed: 0 / total: 2" ]
    [ "${lines[${#lines[@]}-2]}"  = "BUILD SUCCESSFUL" ]
}

@test "Ant with catalog file URI (Schematron)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -lib "${XML_RESOLVER_JAR}" \
        -Dcatalog="test/catalog/01/catalog-public.xml;file:${PWD}/catalog/01/catalog-rewriteURI.xml" \
        -Dcatalog.is.uri=true \
        -Dtest.type=s \
        -Dxspec.xml="${PWD}/catalog/catalog-01_schematron.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-10]}" = "     [xslt] passed: 4 / pending: 0 / failed: 0 / total: 4" ]
    [ "${lines[${#lines[@]}-2]}"  = "BUILD SUCCESSFUL" ]
}

#
# Ant catalog.is.uri=true without setting catalog
#

@test "Ant catalog.is.uri=true without setting catalog" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dcatalog.is.uri=true \
        -Dxspec.fail=false \
        -Dxspec.xml="tutorial/escape-for-regex.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${output}" $'\n''     \[xslt\] passed: 5 / pending: 0 / failed: 1 / total: 6'$'\n'
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    # Temporary catalog should not be created
    run ls "${TEST_DIR}"
    echo "$output"
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "escape-for-regex-compiled.xsl" ]
    [ "${lines[1]}" = "escape-for-regex-result.html" ]
    [ "${lines[2]}" = "escape-for-regex-result.xml" ]
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
# Catalog file path (CLI) (-catalog)
#
#     Test -catalog specifying multiple file paths (relative and absolute)
#

@test "CLI with -catalog file path (XSLT)" {
    space_dir="${work_dir}/cat a log ${RANDOM}"
    mkdir -p "${space_dir}/01"
    cp catalog/catalog-01* "${space_dir}"
    cp catalog/01/*        "${space_dir}/01"

    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    run ../bin/xspec.sh \
        -catalog "catalog/01/catalog-public.xml;${space_dir}/01/catalog-rewriteURI.xml" \
        "${space_dir}/catalog-01_stylesheet.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[15]}" = "passed: 4 / pending: 0 / failed: 0 / total: 4" ]
}

@test "CLI with -catalog file path (XQuery)" {
    space_dir="${work_dir}/cat a log ${RANDOM}"
    mkdir -p "${space_dir}/01"
    cp catalog/catalog-01* "${space_dir}"
    cp catalog/01/*        "${space_dir}/01"

    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    run ../bin/xspec.sh \
        -catalog "catalog/01/catalog-public.xml;${space_dir}/01/catalog-rewriteURI.xml" \
        -q \
        "${space_dir}/catalog-01_query.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[6]}" = "passed: 2 / pending: 0 / failed: 0 / total: 2" ]
}

@test "CLI with -catalog file path (Schematron)" {
    space_dir="${work_dir}/cat a log ${RANDOM}"
    mkdir -p "${space_dir}/01"
    cp catalog/catalog-01* "${space_dir}"
    cp catalog/01/*        "${space_dir}/01"

    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    run ../bin/xspec.sh \
        -catalog "catalog/01/catalog-public.xml;${space_dir}/01/catalog-rewriteURI.xml" \
        -s \
        "${space_dir}/catalog-01_schematron.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[17]}" = "passed: 4 / pending: 0 / failed: 0 / total: 4" ]
}

#
# Catalog file URI (CLI) (-catalog)
#
#     Test -catalog specifying multiple file URIs (absolute, no relative)
#

@test "CLI with -catalog file URI (XSLT)" {
    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    run ../bin/xspec.sh \
        -catalog "file:${PWD}/catalog/01/catalog-public.xml;file:${PWD}/catalog/01/catalog-rewriteURI.xml" \
        catalog/catalog-01_stylesheet.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[15]}" = "passed: 4 / pending: 0 / failed: 0 / total: 4" ]
}

@test "CLI with -catalog file URI (XQuery)" {
    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    run ../bin/xspec.sh \
        -catalog "file:${PWD}/catalog/01/catalog-public.xml;file:${PWD}/catalog/01/catalog-rewriteURI.xml" \
        -q \
        catalog/catalog-01_query.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[6]}" = "passed: 2 / pending: 0 / failed: 0 / total: 2" ]
}

@test "CLI with -catalog file URI (Schematron)" {
    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    run ../bin/xspec.sh \
        -catalog "file:${PWD}/catalog/01/catalog-public.xml;file:${PWD}/catalog/01/catalog-rewriteURI.xml" \
        -s \
        catalog/catalog-01_schematron.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[17]}" = "passed: 4 / pending: 0 / failed: 0 / total: 4" ]
}

#
# Catalog file path (CLI) (XML_CATALOG)
#
#     Test XML_CATALOG containing multiple file paths (relative and absolute)
#

@test "CLI with XML_CATALOG file path (XSLT)" {
    space_dir="${work_dir}/cat a log ${RANDOM}"
    mkdir -p "${space_dir}/01"
    cp catalog/catalog-01* "${space_dir}"
    cp catalog/01/*        "${space_dir}/01"

    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    export XML_CATALOG="catalog/01/catalog-public.xml;${space_dir}/01/catalog-rewriteURI.xml"

    run ../bin/xspec.sh "${space_dir}/catalog-01_stylesheet.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[15]}" = "passed: 4 / pending: 0 / failed: 0 / total: 4" ]
}

@test "CLI with XML_CATALOG file path (XQuery)" {
    space_dir="${work_dir}/cat a log ${RANDOM}"
    mkdir -p "${space_dir}/01"
    cp catalog/catalog-01* "${space_dir}"
    cp catalog/01/*        "${space_dir}/01"

    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    export XML_CATALOG="catalog/01/catalog-public.xml;${space_dir}/01/catalog-rewriteURI.xml"

    run ../bin/xspec.sh -q "${space_dir}/catalog-01_query.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[6]}" = "passed: 2 / pending: 0 / failed: 0 / total: 2" ]
}

@test "CLI with XML_CATALOG file path (Schematron)" {
    space_dir="${work_dir}/cat a log ${RANDOM}"
    mkdir -p "${space_dir}/01"
    cp catalog/catalog-01* "${space_dir}"
    cp catalog/01/*        "${space_dir}/01"

    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    export XML_CATALOG="catalog/01/catalog-public.xml;${space_dir}/01/catalog-rewriteURI.xml"

    run ../bin/xspec.sh -s "${space_dir}/catalog-01_schematron.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[17]}" = "passed: 4 / pending: 0 / failed: 0 / total: 4" ]
}

#
# Catalog file URI (CLI) (XML_CATALOG)
#
#     Test XML_CATALOG containing multiple file URIs (absolute, no relative)
#

@test "CLI with XML_CATALOG file URI (XSLT)" {
    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    export XML_CATALOG="file:${PWD}/catalog/01/catalog-public.xml;file:${PWD}/catalog/01/catalog-rewriteURI.xml"

    run ../bin/xspec.sh "catalog/catalog-01_stylesheet.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[15]}" = "passed: 4 / pending: 0 / failed: 0 / total: 4" ]
}

@test "CLI with XML_CATALOG file URI (XQuery)" {
    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    export XML_CATALOG="file:${PWD}/catalog/01/catalog-public.xml;file:${PWD}/catalog/01/catalog-rewriteURI.xml"

    run ../bin/xspec.sh -q "catalog/catalog-01_query.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[6]}" = "passed: 2 / pending: 0 / failed: 0 / total: 2" ]
}

@test "CLI with XML_CATALOG file URI (Schematron)" {
    export SAXON_CP="$SAXON_JAR:$XML_RESOLVER_JAR"
    export XML_CATALOG="file:${PWD}/catalog/01/catalog-public.xml;file:${PWD}/catalog/01/catalog-rewriteURI.xml"

    run ../bin/xspec.sh -s "catalog/catalog-01_schematron.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[17]}" = "passed: 4 / pending: 0 / failed: 0 / total: 4" ]
}

#
# Catalog resolver and SAXON_HOME (CLI)
#

@test "invoking xspec using SAXON_HOME finds Saxon jar and XML Catalog Resolver jar" {
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

    run ../bin/xspec.sh \
        -catalog "catalog/01/catalog-public.xml;catalog/01/catalog-rewriteURI.xml" \
        catalog/catalog-01_stylesheet.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[15]}" = "passed: 4 / pending: 0 / failed: 0 / total: 4" ]
}

#
# Catalog Saxon bug https://saxonica.plan.io/issues/3025/
#
#     This test must specify the catalog parameter as an absolute native file path.
#

@test "Catalog Saxon bug 3025 (CLI)" {
    export SAXON_CP="${SAXON_JAR}:${XML_RESOLVER_JAR}"
    run ../bin/xspec.sh \
        -catalog "${PWD}/catalog/02/catalog.xml" \
        catalog/catalog-02.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[9]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
}

@test "Catalog Saxon bug 3025 (Ant)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -lib "${XML_RESOLVER_JAR}" \
        -Dcatalog="${PWD}/catalog/02/catalog.xml" \
        -Dxspec.xml="${PWD}/catalog/catalog-02.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]}-10]}" = "     [xslt] passed: 1 / pending: 0 / failed: 0 / total: 1" ]
    [ "${lines[${#lines[@]}-2]}"  = "BUILD SUCCESSFUL" ]
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
# xspec.compiler.saxon.config
#

@test "xspec.compiler.saxon.config (relative path)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.compiler.saxon.config=test/compiler-saxon-config/config.xml \
        -Dxspec.xml=test/compiler-saxon-config/test.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${output}" $'\n''     \[xslt\] passed: 2 / pending: 0 / failed: 0 / total: 2'$'\n'
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]
}

@test "xspec.compiler.saxon.config (absolute path)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.compiler.saxon.config="${PWD}/compiler-saxon-config/config.xml" \
        -Dxspec.xml="${PWD}/compiler-saxon-config/test.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${output}" $'\n''     \[xslt\] passed: 2 / pending: 0 / failed: 0 / total: 2'$'\n'
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]
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

    # Coverage report HTML file is created and contains CSS inline
    run java -jar "${SAXON_JAR}" \
        -s:"${TEST_DIR}/demo-coverage.html" \
        -xsl:check-html-css.xsl
    echo "$output"
    [ "$status" -eq 0 ]
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
# Import order #185
#

@test "Import order #185 (CLI)" {
    run ../bin/xspec.sh issue-185/import-1.xspec
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

@test "Import order #185 (Ant)" {
    ant_log="${work_dir}/ant.log"

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -logfile "${ant_log}" \
        -Dxspec.xml="${PWD}/issue-185/import-1.xspec"
    echo "$output"
    [ "$status" -eq 0 ]

    run grep -F " Scenario " "${ant_log}"
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
# Circular import #987
#

@test "Circular import #987 (CLI)" {
    run ../bin/xspec.sh issue-987_child.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[6]}"  = "Scenario in child" ]
    [ "${lines[8]}"  = "Scenario in parent" ]
    [ "${lines[11]}" = "passed: 2 / pending: 0 / failed: 0 / total: 2" ]

    # Use a fresh dir, to make the message line numbers predictable
    export TEST_DIR="${TEST_DIR}/parent ${RANDOM}"
    run ../bin/xspec.sh issue-987_parent.xspec
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[6]}"  = "Scenario in parent" ]
    [ "${lines[8]}"  = "Scenario in child" ]
    [ "${lines[11]}" = "passed: 2 / pending: 0 / failed: 0 / total: 2" ]
}

@test "Circular import #987 (Ant)" {
    #
    # Child
    #
    ant_log="${work_dir}/ant_child.log"

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -logfile "${ant_log}" \
        -Dxspec.xml="${PWD}/issue-987_child.xspec"
    echo "$output"
    [ "$status" -eq 0 ]

    run cat "${ant_log}"
    echo "$output"
    [ "${lines[${#lines[@]}-10]}" = "     [xslt] passed: 2 / pending: 0 / failed: 0 / total: 2" ]

    run grep -F " Scenario in " "${ant_log}"
    echo "$output"
    [ "${#lines[@]}" = "2" ]
    [ "${lines[0]}" = "     [java] Scenario in child" ]
    [ "${lines[1]}" = "     [java] Scenario in parent" ]

    #
    # Parent
    #
    ant_log="${work_dir}/ant_parent.log"

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -logfile "${ant_log}" \
        -Dxspec.xml="${PWD}/issue-987_parent.xspec"
    echo "$output"
    [ "$status" -eq 0 ]

    run cat "${ant_log}"
    echo "$output"
    [ "${lines[${#lines[@]}-10]}" = "     [xslt] passed: 2 / pending: 0 / failed: 0 / total: 2" ]

    run grep -F " Scenario in " "${ant_log}"
    echo "$output"
    [ "${#lines[@]}" = "2" ]
    [ "${lines[0]}" = "     [java] Scenario in parent" ]
    [ "${lines[1]}" = "     [java] Scenario in child" ]
}

#
# Ambiguous x:expect
#

@test "Ambiguous x:expect generates warning" {
    run ../bin/xspec.sh end-to-end/cases/ambiguous-expect.xspec
    echo "$output"
    [ "${lines[11]}" = "WARNING: x:expect has boolean @test (i.e. assertion) along with @href, @select or child node (i.e. comparison). Comparison factors will be ignored." ]
    [ "${lines[16]}" = "WARNING: x:expect has boolean @test (i.e. assertion) along with @href, @select or child node (i.e. comparison). Comparison factors will be ignored." ]
    [ "${lines[23]}" = "WARNING: x:expect has boolean @test (i.e. assertion) along with @href, @select or child node (i.e. comparison). Comparison factors will be ignored." ]
    [ "${lines[32]}" = "Formatting Report..." ]
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

    run java -cp "${XMLCALABASH_JAR}:${SAXON_JAR}" com.xmlcalabash.drivers.Main \
        -i source=issue-423/test.xspec \
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

    run java -cp "${XMLCALABASH_JAR}:${SAXON_JAR}" com.xmlcalabash.drivers.Main \
        -i source=issue-423/test.xspec \
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
        -Dxspec.xml="${PWD}/../test/issue-423/test.xspec"
    echo "$output"
    [ "$status" -eq 2 ]
    assert_regex "${output}" $'\n''     \[java\]   XPDY0002[: ]'
    [ "${lines[${#lines[@]}-3]}" = "BUILD FAILED" ]
}

@test "XSLT selecting nodes without context should be error (CLI) #423" {
    run ../bin/xspec.sh issue-423/test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  XPDY0002[: ]'
    [ "${lines[${#lines[@]}-1]}" = "*** Error running the test suite" ]
}

@test "XSLT selecting nodes without context should be error (CLI -c) #423" {
    if [ -z "${XSLT_SUPPORTS_COVERAGE}" ]; then
        skip "XSLT_SUPPORTS_COVERAGE is not defined"
    fi

    run ../bin/xspec.sh -c issue-423/test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  XPDY0002[: ]'
    [ "${lines[${#lines[@]}-1]}" = "*** Error collecting test coverage data" ]
}

@test "XQuery selecting nodes without context should be error (CLI) #423" {
    run ../bin/xspec.sh -q issue-423/test.xspec
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
        -Dxspec.result.html.css="${PWD}/check-html-css.css" \
        -Dxspec.xml="${PWD}/../tutorial/escape-for-regex.xspec"
    echo "$output"
    [ "$status" -eq 0 ]

    run java -jar "${SAXON_JAR}" \
        -s:"${TEST_DIR}/escape-for-regex-result.html" \
        -xsl:check-html-css.xsl \
        STYLE-CONTAINS="This CSS file is for testing report-css-uri parameter"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "true" ]
}

@test "report-css-uri for coverage report HTML file" {
    if [ -z "${XSLT_SUPPORTS_COVERAGE}" ]; then
        skip "XSLT_SUPPORTS_COVERAGE is not defined"
    fi

    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.coverage.enabled=true \
        -Dxspec.coverage.html.css="${PWD}/check-html-css.css" \
        -Dxspec.xml="${PWD}/../tutorial/coverage/demo.xspec"
    echo "$output"
    [ "$status" -eq 0 ]

    run java -jar "${SAXON_JAR}" \
        -s:"${TEST_DIR}/demo-coverage.html" \
        -xsl:check-html-css.xsl \
        STYLE-CONTAINS="This CSS file is for testing report-css-uri parameter"
    echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "true" ]
}

#
# #522
#

@test "Error message when source is not XSpec #522" {
    run ../bin/xspec.sh do-nothing.xsl
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "Source document is not XSpec. /x:description is missing. Supplied source has /xsl:stylesheet instead." ]
}

#
# User-defined variable in XSpec namespace
#

@test "Error on user-defined variable in XSpec namespace (URIQualifiedName in local variable)" {
    run ../bin/xspec.sh variable/reserved-eqname.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "ERROR: User-defined XSpec variable, Q{http://www.jenitennison.com/xslt/xspec}foo, must not use the XSpec namespace." ]
}

@test "Error on user-defined variable in XSpec namespace (QName in global variable)" {
    run ../bin/xspec.sh variable/reserved-name.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "ERROR: User-defined XSpec variable, u:foo, must not use the XSpec namespace." ]
}

#
# Deprecated Saxon version
#

@test "Deprecated Saxon version" {
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
    echo "$output"
    [ "$status" -eq 0 ]

    if ! java -cp "${SAXON_JAR}" net.sf.saxon.Version 2>&1 | grep -F " 9.8."; then
        [ "${lines[3]}" = " " ]
    else
        [ "${lines[3]}" = "WARNING: Saxon version 9.8 is not recommended. Consider migrating to Saxon 9.9." ]
    fi

    [ "${lines[4]}" = "Running Tests..." ]
    assert_regex "${lines[5]}" '^Testing with SAXON [EHP]E [1-9][0-9]*\.[1-9][0-9]*'
}

#
# No warning on Ant
#

@test "No warning on Ant (XSLT) #633" {
    if java -cp "${SAXON_JAR}" net.sf.saxon.Version 2>&1 | grep -F " 9.8."; then
        skip "Always expect a deprecation warning on Saxon 9.8"
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
    if java -cp "${SAXON_JAR}" net.sf.saxon.Version 2>&1 | grep -F " 9.8."; then
        skip "Always expect a deprecation warning on Saxon 9.8"
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
    if java -cp "${SAXON_JAR}" net.sf.saxon.Version 2>&1 | grep -F " 9.8."; then
        skip "Always expect a deprecation warning on Saxon 9.8"
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
}

#
# @catch should not catch error outside SUT
#

@test "@catch should not catch error outside SUT (XSLT)" {
    run ../bin/xspec.sh catch/compiler-error.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''ERROR in x:scenario '
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]

    run ../bin/xspec.sh catch/error-in-context-avt-for-template-call.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  error-code-of-my-context-avt-for-template-call[: ] Error signalled '
    [ "${lines[${#lines[@]}-1]}" = "*** Error running the test suite" ]

    run ../bin/xspec.sh catch/error-in-context-param-for-matching-template.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  error-code-of-my-context-param-for-matching-template[: ] Error signalled '
    [ "${lines[${#lines[@]}-1]}" = "*** Error running the test suite" ]

    run ../bin/xspec.sh catch/error-in-function-call-param.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  error-code-of-my-function-call-param[: ] Error signalled '
    [ "${lines[${#lines[@]}-1]}" = "*** Error running the test suite" ]

    run ../bin/xspec.sh catch/error-in-template-call-param.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  error-code-of-my-template-call-param[: ] Error signalled '
    [ "${lines[${#lines[@]}-1]}" = "*** Error running the test suite" ]

    run ../bin/xspec.sh catch/error-in-variable.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''  error-code-of-my-variable[: ] Error signalled '
    [ "${lines[${#lines[@]}-1]}" = "*** Error running the test suite" ]

    run ../bin/xspec.sh catch/static-error-in-compiled-test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" 'XPST0017[: ]'
    [ "${lines[${#lines[@]}-1]}" = "*** Error running the test suite" ]
}

@test "@catch should not catch error outside SUT (XQuery)" {
    run ../bin/xspec.sh -q catch/compiler-error.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${output}" $'\n''ERROR in x:scenario '

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

@test "x:like error (scenario not found)" {
    run ../bin/xspec.sh like/none.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "ERROR in x:like: Scenario not found: 'none'" ]
}

@test "x:like error (multiple scenarios)" {
    run ../bin/xspec.sh like/multiple.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "ERROR in x:like: 2 scenarios found with same label: 'shared scenario'" ]
}

@test "x:like error (infinite loop)" {
    run ../bin/xspec.sh like/loop.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "ERROR in x:like: Reference to ancestor scenario creates infinite loop: 'parent scenario'" ]
}

#
# Override ID generation templates
#

@test "Override ID generation (XSLT)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dxspec.xslt.compiler.xsl="${PWD}/override-id/generate-xspec-tests.xsl" \
        -Dxspec.fail=false \
        -Dxspec.xml="${PWD}/../tutorial/escape-for-regex.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${output}" $'\n''     \[xslt\] passed: 5 / pending: 0 / failed: 1 / total: 6'$'\n'
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    run cat "${TEST_DIR}/escape-for-regex-compiled.xsl"
    echo "$output"
    assert_regex "${output}" '.+Q\{http://www.jenitennison.com/xslt/xspec\}overridden-xslt-scenario-id-'
    assert_regex "${output}" '.+Q\{http://www.jenitennison.com/xslt/xspec\}overridden-xslt-expect-id'
}

@test "Override ID generation (XQuery)" {
    run ant \
        -buildfile ../build.xml \
        -lib "${SAXON_JAR}" \
        -Dtest.type=q \
        -Dxspec.xquery.compiler.xsl="${PWD}/override-id/generate-query-tests.xsl" \
        -Dxspec.xml="${PWD}/../tutorial/xquery-tutorial.xspec"
    echo "$output"
    [ "$status" -eq 0 ]
    assert_regex "${output}" $'\n''     \[xslt\] passed: 1 / pending: 0 / failed: 0 / total: 1'$'\n'
    [ "${lines[${#lines[@]}-2]}" = "BUILD SUCCESSFUL" ]

    run cat "${TEST_DIR}/xquery-tutorial-compiled.xq"
    echo "$output"
    assert_regex "${output}" $'\n''declare function local:overridden-xquery-scenario-id-'
    assert_regex "${output}" $'\n''declare function local:overridden-xquery-expect-id-'
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

#
# Error message from x:output-scenario template (XSLT)
#

@test "x:context both with @href and content" {
    run ../bin/xspec.sh output-scenario-error/context-both-href-and-content.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "ERROR in x:scenario ('x:context both with @href and content'): Can't set the context document using both the href attribute and the content of the x:context element" ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

@test "x:call both with @function and @template" {
    run ../bin/xspec.sh output-scenario-error/call-both-function-and-template.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "ERROR in x:scenario ('x:call both with @function and @template'): Can't call a function and a template at the same time" ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

@test "x:apply with x:context" {
    run ../bin/xspec.sh output-scenario-error/apply-with-context.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "WARNING: The instruction x:apply is not supported yet!" ]
    [ "${lines[5]}" = "ERROR in x:scenario ('x:apply with x:context'): Can't use x:apply and set a context at the same time" ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

@test "x:apply with x:call" {
    run ../bin/xspec.sh output-scenario-error/apply-with-call.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "WARNING: The instruction x:apply is not supported yet!" ]
    [ "${lines[5]}" = "ERROR in x:scenario ('x:apply with x:call'): Can't use x:apply and x:call at the same time" ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

@test "x:call[@function] with x:context" {
    run ../bin/xspec.sh output-scenario-error/function-with-context.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "ERROR in x:scenario ('x:call[@function] with x:context'): Can't set a context and call a function at the same time" ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

@test "x:expect without action" {
    run ../bin/xspec.sh output-scenario-error/expect-without-action.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "ERROR in x:scenario ('x:expect without action'): There are x:expect but no x:call, x:apply or x:context has been given" ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

#
# Error message from x:output-scenario template (XQuery)
#

@test "x:context (XQuery)" {
    run ../bin/xspec.sh -q output-scenario-error/xquery_context.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "ERROR in x:scenario ('x:context'): x:context not supported for XQuery" ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

@test "x:call/@template (XQuery)" {
    run ../bin/xspec.sh -q output-scenario-error/xquery_template-call.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "ERROR in x:scenario ('x:call/@template'): x:call/@template not supported for XQuery" ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

@test "No x:call (XQuery)" {
    run ../bin/xspec.sh -q output-scenario-error/xquery_no-call.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "ERROR in x:scenario ('No x:call'): There are x:expect but no x:call" ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

#
# $x:saxon-config is not a Saxon config
#

@test "\$x:saxon-config is not a Saxon config" {
    run ../bin/xspec.sh x-saxon-config/test.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[7]}" = "ERROR: \$Q{http://www.jenitennison.com/xslt/xspec}saxon-config does not appear to be a Saxon configuration" ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error running the test suite" ]
}

#
# Duplicate param name
#

@test "Duplicate function-call param name (XSLT)" {
    run ../bin/xspec.sh dup-param-name/function-call.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "Duplicate parameter name, Q{}left, used in x:call." ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

@test "Duplicate function-call param name (XQuery)" {
    run ../bin/xspec.sh -q dup-param-name/function-call.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "Duplicate parameter name, Q{}left, used in x:call." ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

@test "Duplicate context param name" {
    run ../bin/xspec.sh dup-param-name/context.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "Duplicate parameter name, Q{}left, used in x:context." ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

@test "Duplicate template-call param name" {
    run ../bin/xspec.sh dup-param-name/template-call.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "Duplicate parameter name, Q{}left, used in x:call." ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

#
# Static param not allowed
#

@test "Static param is allowed only with run-as external (XSLT)" {
    run ../bin/xspec.sh static-param/disallowed_stylesheet.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "Enabling @static in x:param is supported only when /x:description has @run-as='external'." ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

@test "Static param not allowed (XQuery)" {
    run ../bin/xspec.sh -q static-param/disallowed_query.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[4]}" = "Enabling @static in x:param is not supported for XQuery." ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error compiling the test suite" ]
}

@test "Static param not allowed (Schematron)" {
    run ../bin/xspec.sh -s static-param/disallowed_schematron.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[3]}" = "Enabling @static in x:param is not supported for Schematron." ]
    [ "${lines[${#lines[@]}-1]}" = "*** Error converting Schematron into XSLT" ]
}


