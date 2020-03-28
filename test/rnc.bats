#!/usr/bin/env bats

#
# Setup and teardown
#

setup() {
    cd "${BATS_TEST_DIRNAME}"
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
        xspec-node-selection.xspec \
        xspec-node-selection_stylesheet.xspec
    echo "$output"
    [ "$status" -eq 1 ]
    assert_regex "${lines[0]}" '.+: error: element "function-param-child-not-allowed" not allowed here;'
    assert_regex "${lines[1]}" '.+: error: element "global-param-child-not-allowed" not allowed here;'
    assert_regex "${lines[2]}" '.+: error: element "global-variable-child-not-allowed" not allowed here;'
    assert_regex "${lines[3]}" '.+: error: element "assertion-child-not-allowed" not allowed here;'
    assert_regex "${lines[4]}" '.+: error: element "variable-child-not-allowed" not allowed here;'
    assert_regex "${lines[5]}" '.+: error: element "template-param-child-not-allowed" not allowed here;'
    assert_regex "${lines[6]}" '.+: error: element "template-param-child-not-allowed" not allowed here;'
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

