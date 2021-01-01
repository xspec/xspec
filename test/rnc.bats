#!/usr/bin/env bats

#
# Setup and teardown
#

setup() {
    cd "${BATS_TEST_DIRNAME}" || return

    # Unset JVM environment variable which makes output line numbers unpredictable
    unset JAVA_TOOL_OPTIONS
}

#
# Helper
#

load bats-helper

#
# RelaxNG Schema
#

@test "Schema detects no error in known good .xspec files" {
    run ant -buildfile schema/build.xml -lib "${JING_JAR}"
    echo "$output"
    [ "$status" -eq 0 ]

    # Verify that the fileset includes test and tutorial files recursively
    assert_regex "${output}" '/test/catalog/'
    assert_regex "${output}" '/tutorial/coverage/'
}

@test "Schema detects errors in node-selection test" {
    # '-t' for identifying the last line
    run java -jar "${JING_JAR}" -c -t ../src/schemas/xspec.rnc \
        node-selection.xspec \
        node-selection_stylesheet.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${lines[0]}" '.+: error: element "function-param-child-not-allowed" not allowed here;'
    assert_regex "${lines[1]}" '.+: error: element "global-variable-child-not-allowed" not allowed here;'
    assert_regex "${lines[2]}" '.+: error: element "assertion-child-not-allowed" not allowed here;'
    assert_regex "${lines[3]}" '.+: error: element "variable-child-not-allowed" not allowed here;'
    assert_regex "${lines[4]}" '.+: error: element "template-param-child-not-allowed" not allowed here;'
    assert_regex "${lines[5]}" '.+: error: element "template-param-child-not-allowed" not allowed here;'
    assert_regex "${lines[6]}" '.+: error: element "global-param-child-not-allowed" not allowed here;'
    assert_regex "${lines[7]}" '^Elapsed time '
}

@test "Schema detects missing @href in x:import" {
    # '-t' for identifying the last line
    run java -jar "${JING_JAR}" -c -t ../src/schemas/xspec.rnc import/no-href.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${lines[0]}" '.+: error: element "x:import" missing required attribute "href"$'
    assert_regex "${lines[1]}" '^Elapsed time '
}

@test "Schema detects errors in x:compile-scenario test" {
    # '-t' for identifying the last line
    run java -jar "${JING_JAR}" -c -t ../src/schemas/xspec.rnc \
        error-compiling-scenario/apply-with-call.xspec \
        error-compiling-scenario/apply-with-context.xspec \
        error-compiling-scenario/call-both-function-and-template.xspec \
        error-compiling-scenario/context-both-href-and-content.xspec \
        error-compiling-scenario/function-with-context.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${lines[0]}" '.+: error: element "x:apply" not allowed anywhere;'
    assert_regex "${lines[1]}" '.+: error: element "x:apply" not allowed anywhere;'
    assert_regex "${lines[2]}" '.+: error: attribute "template" not allowed here;'
    assert_regex "${lines[3]}" '.+: error: element "context-child" not allowed here;'
    assert_regex "${lines[4]}" '.+: error: attribute "function" not allowed here;'
    assert_regex "${lines[5]}" '^Elapsed time '
}

@test "Schema detects non-positive @position" {
    # '-t' for identifying the last line
    run java -jar "${JING_JAR}" -c -t ../src/schemas/xspec.rnc \
        bad-position/non-positive.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${lines[0]}" '.+: error: value of attribute "position" is invalid; must be an integer greater than or equal to 1$'
    assert_regex "${lines[1]}" '.+: error: value of attribute "position" is invalid; must be an integer greater than or equal to 1$'
    assert_regex "${lines[2]}" '^Elapsed time '
}

@test "Schema detects mixture of explicit and implicit @position" {
    # '-t' for identifying the last line

    run java -jar "${JING_JAR}" -c -t ../src/schemas/xspec.rnc \
        bad-position/mixed_explicit-implicit.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${lines[0]}" '.+: error: element "x:param" missing required attribute "position"$'
    assert_regex "${lines[1]}" '^Elapsed time '

    run java -jar "${JING_JAR}" -c -t ../src/schemas/xspec.rnc \
        bad-position/mixed_implicit-explicit.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${lines[0]}" '.+: error: attribute "position" not allowed here;'
    assert_regex "${lines[1]}" '^Elapsed time '
}

