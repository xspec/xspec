#!/usr/bin/env bats

#
# Setup and teardown
#

setup() {
    # Work directory
    work_dir="${BATS_TEST_TMPDIR}"

    # Full path to the parent directory
    parent_dir_abs=$(
        cd ..
        pwd
    )

    # Set TEST_DIR and xspec.dir within the work directory so that it's cleaned up by teardown
    export TEST_DIR="${work_dir}/output_${RANDOM}"
    export ANT_ARGS="-Dxspec.dir=${TEST_DIR}"

    # Invalidate XMLResolver.org XML Resolver cache
    XMLRESOLVER_PROPERTIES="${work_dir}/xmlresolver.properties"
    echo "cache=${work_dir}/xmlcatalog-cache_${RANDOM}" > "${XMLRESOLVER_PROPERTIES}"
    export XMLRESOLVER_PROPERTIES="file:${XMLRESOLVER_PROPERTIES}"
}

#
# Helper
#

load bats-helper

#
# Usage (CLI)
#

@test "MorganaXProc-IIIee license is found" {
    myrun java -cp "${MORGANAXPROC_CP}" com.xml_project.morganaxproc3.XProcEngine ${MORGANAXPROC_HOME}/pipeline.xpl
    [ "$status" -eq 0 ]
}

#
# xspec.sh/xspec.bat using MorganaXProc-IIIee
#

@test "CLI -e with some failures (XProc)" {
    export SAXON_CP="${MORGANAXPROC_CP}"
    myrun ../bin/xspec.sh -e -p some-failures/step.xspec
    [ "$status" -eq 1 ]
    assert_regex "${lines[7]}" '^.*MorganaXProc'
    [ "${lines[16]}" = "passed: 1 / pending: 0 / failed: 2 / total: 3" ]
    [ "${lines[17]}" = "Report available at ${TEST_DIR}/step-result.html" ]
    [ "${lines[19]}" = "*** Found a test failure" ]
}

@test "CLI -e with no failures (XProc)" {
    export SAXON_CP="${MORGANAXPROC_CP}"
    myrun ../bin/xspec.sh -e -p xproc/cases/one-input-no-option-one-output.xspec
    [ "$status" -eq 0 ]
    [ "${lines[12]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
    [ "${lines[13]}" = "Report available at ${TEST_DIR}/one-input-no-option-one-output-result.html" ]
    [ "${lines[14]}" = "Done." ]
}

@test "-processor set to morganaxproc uses MorganaXProc (CLI)" {
    export SAXON_CP="${MORGANAXPROC_CP}"
    unset XPROC_PROCESSOR
    myrun ../bin/xspec.sh -p -processor morganaxproc xproc/cases/one-input-no-option-one-output.xspec
    assert_regex "${lines[7]}" '^Testing with .* and MorganaXProc'
}

@test "-processor takes precedence over XPROC_PROCESSOR (CLI)" {
    export SAXON_CP="${MORGANAXPROC_CP}"
    export XPROC_PROCESSOR=xmlcalabash
    # Also check that XMLCALABASH_CONFIG is ignored if processor in effect is not XML Calabash
    export XMLCALABASH_CONFIG=nonexistent-file.xml
    myrun ../bin/xspec.sh -p -processor morganaxproc xproc/cases/one-input-no-option-one-output.xspec
    assert_regex "${lines[7]}" '^Testing with .* and MorganaXProc'
}

@test "MORGANAXPROC_INIT must be set (CLI)" {
    export SAXON_CP="${MORGANAXPROC_CP}"
    unset MORGANAXPROC_INIT
    myrun ../bin/xspec.sh -p xproc/cases/one-input-no-option-one-output.xspec
    [ "${lines[${#lines[@]} - 1]}" = "ERROR: When XProc processor is set to 'morganaxproc', MORGANAXPROC_INIT must be set." ]
}

# As of MorganaXProc-IIIee 1.8.15, the ...saxon13connector... class works with either Saxon 13.x
# or Saxon 12.10. If these RegisterXProcStepsAsFunctions classes diverge between Saxon versions,
# the following test case might need to be replaced or removed.
@test "MORGANAXPROC_INIT set to fully qualified class name (CLI)" {
    export SAXON_CP="${MORGANAXPROC_CP}"
    export MORGANAXPROC_INIT=com.xml_project.morganaxproc3.saxon13connector.RegisterXProcStepsAsFunctions
    myrun ../bin/xspec.sh -p xproc/cases/one-input-no-option-one-output.xspec
    [ "$status" -eq 0 ]
    [ "${lines[12]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
}

#
# MorganaXProc configuration in tests for XProc
#

@test "MorganaXProc configuration for testing XProc (CLI)" {
    r=${RANDOM}
    # Test with a space in file name
    export MORGANAXPROC_CONFIG="file:${work_dir}/morganaxproc%20config${r}.xml"
    cp xproc/cases/morganaxproc-config-example.xml "${work_dir}/morganaxproc config${r}.xml"

    export SAXON_CP="${MORGANAXPROC_CP}"
    myrun ../bin/xspec.sh -p xproc/integ-test-supporting-files/load.xspec
    [ "$status" -eq 0 ]
    [ "${lines[${#lines[@]} - 3]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]

    # Confirm that test raises error without the configuration file
    unset MORGANAXPROC_CONFIG
    myrun ../bin/xspec.sh -p xproc/integ-test-supporting-files/load.xspec
    [ "$status" -eq 1 ]
}

#
# Ant using MorganaXProc-IIIee (TODO)
#

#
# Catalog file path (CLI) (-catalog)
#
#     Test -catalog specifying multiple file paths (relative and absolute)
#

@test "CLI with -catalog file path (XProc)" {
    if [ -z "${SAXON_BUG_7127_FIXED}" ]; then
        skip "Saxon bug 7127"
    fi

    space_dir="${work_dir}/cat a log ${RANDOM}"
    mkdir -p "${space_dir}/01"
    cp catalog/catalog-01* "${space_dir}"
    cp catalog/01/* "${space_dir}/01"

    export SAXON_CP="${MORGANAXPROC_CP}"
    myrun ../bin/xspec.sh -p \
        -catalog "catalog/01/catalog-public.xml;${space_dir}/01/catalog-rewriteURI.xml" \
        "${space_dir}/catalog-01_xproc.xspec"
    [ "$status" -eq 0 ]
    [ "${lines[24]}" = "passed: 6 / pending: 0 / failed: 0 / total: 6" ]
}

#
# Catalog file URI (CLI) (-catalog)
#
#     Test -catalog specifying multiple file URIs (absolute, no relative)
#

@test "CLI with -catalog file URI (XProc)" {
    if [ -z "${SAXON_BUG_7127_FIXED}" ]; then
        skip "Saxon bug 7127"
    fi

    export SAXON_CP="${MORGANAXPROC_CP}"
    myrun ../bin/xspec.sh -p \
        -catalog "file:${PWD}/catalog/01/catalog-public.xml;file:${PWD}/catalog/01/catalog-rewriteURI.xml" \
        catalog/catalog-01_xproc.xspec
    [ "$status" -eq 0 ]
    [ "${lines[24]}" = "passed: 6 / pending: 0 / failed: 0 / total: 6" ]
}

#
# Catalog file path (CLI) (XML_CATALOG)
#
#     Test XML_CATALOG containing multiple file paths (relative and absolute)
#

@test "CLI with XML_CATALOG file path (XProc)" {
    if [ -z "${SAXON_BUG_7127_FIXED}" ]; then
        skip "Saxon bug 7127"
    fi

    space_dir="${work_dir}/cat a log ${RANDOM}"
    mkdir -p "${space_dir}/01"
    cp catalog/catalog-01* "${space_dir}"
    cp catalog/01/* "${space_dir}/01"

    export SAXON_CP="${MORGANAXPROC_CP}"
    export XML_CATALOG="catalog/01/catalog-public.xml;${space_dir}/01/catalog-rewriteURI.xml"
    myrun ../bin/xspec.sh -p "${space_dir}/catalog-01_xproc.xspec"
    [ "$status" -eq 0 ]
    [ "${lines[24]}" = "passed: 6 / pending: 0 / failed: 0 / total: 6" ]
}

#
# Catalog file URI (CLI) (XML_CATALOG)
#
#     Test XML_CATALOG containing multiple file URIs (absolute, no relative)
#

@test "CLI with XML_CATALOG file URI (XProc)" {
    if [ -z "${SAXON_BUG_7127_FIXED}" ]; then
        skip "Saxon bug 7127"
    fi

    export SAXON_CP="${MORGANAXPROC_CP}"
    export XML_CATALOG="file:${PWD}/catalog/01/catalog-public.xml;file:${PWD}/catalog/01/catalog-rewriteURI.xml"

    myrun ../bin/xspec.sh -p "catalog/catalog-01_xproc.xspec"
    [ "$status" -eq 0 ]
    [ "${lines[24]}" = "passed: 6 / pending: 0 / failed: 0 / total: 6" ]
}
