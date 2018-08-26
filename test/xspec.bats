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

setup() {
	work_dir="${BATS_TMPDIR}/xspec/bats_work"
	mkdir -p "${work_dir}"
	mkdir ../tutorial/xspec
	mkdir ../test/xspec
	mkdir ../tutorial/schematron/xspec
	mkdir ../test/catalog/xspec
}


teardown() {
	rm -rf "${work_dir}"
	rm -rf ../tutorial/xspec
	rm -rf ../test/xspec
	rm -rf ../tutorial/schematron/xspec
	rm -rf ../test/catalog/xspec
}


@test "invoking xspec without arguments prints usage" {
    run ../bin/xspec.sh
	echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[2]}" = "Usage: xspec [-t|-q|-s|-c|-j|-catalog file|-h] file [coverage]" ]
}


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


@test "invoking code coverage with Saxon9HE returns error message" {
    export SAXON_CP=/path/to/saxon9he.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon9SA returns error message" {
    export SAXON_CP=/path/to/saxon9sa.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon9 returns error message" {
    export SAXON_CP=/path/to/saxon9.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon8SA returns error message" {
    export SAXON_CP=/path/to/saxon8sa.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon8 returns error message" {
    export SAXON_CP=/path/to/saxon8.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon9EE creates test stylesheet" {
    # Append non-Saxon jar to see if SAXON_CP is parsed correctly
    export SAXON_CP="/path/to/saxon9ee.jar:$XML_RESOLVER_CP"
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
  	echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Creating Test Stylesheet..." ]
}


@test "invoking code coverage with Saxon9PE creates test stylesheet" {
    export SAXON_CP=/path/to/saxon9pe.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo "$output"
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Creating Test Stylesheet..." ]
}


@test "invoking xspec generates XML report file" {
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec

    # XML report file
    run stat ../tutorial/xspec/escape-for-regex-result.xml
	echo "$output"
    [ "$status" -eq 0 ]
}


@test "invoking xspec generates HTML report file" {
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec

    # HTML report file is created
    run stat ../tutorial/xspec/escape-for-regex-result.html
	echo "$output"
    [ "$status" -eq 0 ]
}


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


@test "invoking xspec with -j option generates message with JUnit report location" {
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
	echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[18]}" = "Report available at ../tutorial/xspec/escape-for-regex-junit.xml" ]
}


@test "invoking xspec with -j option generates XML report file" {
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec

    # XML report file
    run stat ../tutorial/xspec/escape-for-regex-result.xml
	echo "$output"
    [ "$status" -eq 0 ]
}


@test "invoking xspec with -j option generates JUnit report file" {
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec

    # JUnit report file
    run stat ../tutorial/xspec/escape-for-regex-junit.xml
	echo "$output"
    [ "$status" -eq 0 ]
}


@test "invoking xspec with Saxon-B-9-1-0-8 creates test stylesheet" {
    export SAXON_CP=/path/to/saxonb9-1-0-8.jar
	run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	echo "$output"
	[ "$status" -eq 1 ]
  	[ "${lines[1]}" = "Creating Test Stylesheet..." ]
}


@test "invoking xspec.sh with TEST_DIR already set externally generates files inside TEST_DIR" {
    export TEST_DIR="${work_dir}"
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[18]}" = "Report available at ${TEST_DIR}/escape-for-regex-result.html" ]
}


@test "invoking xspec.sh without TEST_DIR generates files in default location" {
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[18]}" = "Report available at ../tutorial/xspec/escape-for-regex-result.html" ]
}


@test "invoking xspec.sh that passes a non xs:boolean does not raise a warning #46" {
    run ../bin/xspec.sh ../test/xspec-46.xspec
	echo "$output"
    [ "$status" -eq 0 ]
    [[ "${lines[3]}" =~ "Testing with" ]]
}


@test "executing the Saxon XProc harness generates a report with UTF-8 encoding" {

    if [ -z ${XMLCALABASH_CP} ]; then
        skip "test for XProc skipped as XMLCalabash uses a higher version of Saxon";
    else
        run java -Xmx1024m -cp ${XMLCALABASH_CP} com.xmlcalabash.drivers.Main -isource=xspec-72.xspec -p xspec-home=file:${PWD}/../ -oresult=xspec/xspec-72-result.html ../src/harnesses/saxon/saxon-xslt-harness.xproc

    	query="declare default element namespace 'http://www.w3.org/1999/xhtml'; concat(/html/head/meta[@http-equiv eq 'Content-Type']/@content = 'text/html; charset=UTF-8', '&#x0A;')";

        run java -cp ${SAXON_CP} net.sf.saxon.Query -s:xspec/xspec-72-result.html -qs:"$query" !method=text
    fi

    echo "$output"
    [ "${lines[0]}" = "true" ]
}


@test "invoking xspec.sh with path containing an apostrophe runs successfully #119" {
	special_chars_dir="${work_dir}/some'path"
	mkdir "${special_chars_dir}"
	cp ../tutorial/escape-for-regex.* "${special_chars_dir}"

	expected_report="${special_chars_dir}/xspec/escape-for-regex-result.html"

	run ../bin/xspec.sh "${special_chars_dir}/escape-for-regex.xspec"
	echo "$output"
	[ "$status" -eq 0 ]
	[ "${lines[19]}" = "Report available at ${expected_report}" ]
}


@test "invoking xspec.sh with saxon script uses the saxon script #121 #122" {
	echo "echo 'Saxon script with EXPath Packaging System'" > "${work_dir}/saxon"
	chmod +x "${work_dir}/saxon"
	export PATH="$PATH:${work_dir}"
	run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	echo "$output"
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Saxon script found, use it." ]
}


@test "Schematron phase/parameters are passed to Schematron compile" {
    run ../bin/xspec.sh -s ../test/schematron-param-001.xspec
	echo "${lines[2]}"
    [ "$status" -eq 0 ]
    [ "${lines[2]}" == "Parameters: phase=P1 ?selected=codepoints-to-string((80,49))" ]
}

@test "invoking xspec with Schematron XSLTs provided externally uses provided XSLTs for Schematron compile" {
    
    export SCHEMATRON_XSLT_INCLUDE=schematron/schematron-xslt-include.xsl
    export SCHEMATRON_XSLT_EXPAND=schematron/schematron-xslt-expand.xsl
    export SCHEMATRON_XSLT_COMPILE=schematron/schematron-xslt-compile.xsl
    
    run ../bin/xspec.sh -s ../tutorial/schematron/demo-01.xspec
	echo "$output"
    [ "${lines[4]}" = "Schematron XSLT include" ]
    [ "${lines[5]}" = "Schematron XSLT expand" ]
    [ "${lines[6]}" = "Schematron XSLT compile" ]
}


@test "invoking xspec.sh with the -s option does not display Schematron warnings #129 #131" {
    run ../bin/xspec.sh -s ../tutorial/schematron/demo-01.xspec
	echo "${lines[4]}"
	echo "$output"
    [ "$status" -eq 0 ]
    [ "${lines[4]}" == "Compiling the Schematron tests..." ]
}


@test "Cleanup removes temporary files" {
    run ../bin/xspec.sh -s ../tutorial/schematron/demo-03.xspec
    [ "$status" -eq 0 ]

    # Cleanup removes compiled .xspec
    [ ! -f "../tutorial/schematron/demo-03.xspec-compiled.xspec" ]

    # Cleanup removes temporary files in TEST_DIR
    run ls ../tutorial/schematron/xspec
    [ "${#lines[@]}" = "3" ]
    [ "${lines[0]}" = "demo-03-result.html" ]
    [ "${lines[1]}" = "demo-03-result.xml" ]
    [ "${lines[2]}" = "demo-03.xsl" ]
}


@test "invoking xspec.sh with -q option runs XSpec test for XQuery" {
    run ../bin/xspec.sh -q ../tutorial/xquery-tutorial.xspec
	echo "${lines[5]}"
    [ "$status" -eq 0 ]
    [ "${lines[5]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
}


@test "executing the XProc harness for BaseX generates a report" {

    if [[ -z ${XMLCALABASH_CP} && -z ${BASEX_CP} ]]; then
        skip "test for BaseX skipped as it requires XMLCalabash and a higher version of Saxon";
    else
        run java -Xmx1024m -cp ${XMLCALABASH_CP} com.xmlcalabash.drivers.Main -i source=../tutorial/xquery-tutorial.xspec -p xspec-home=file:${PWD}/../ -p basex-jar=${BASEX_CP} -o result=xspec/xquery-tutorial-result.html ../src/harnesses/basex/basex-standalone-xquery-harness.xproc
    fi

    echo "$output"
    [[ "${output}" =~ "src/harnesses/harness-lib.xpl:267:45:passed: 1 / pending: 0 / failed: 0 / total: 1" ]]
}


@test "HTML report contains CSS inline and not as an external file #135" {
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	grep '<style type="text/css">' ../tutorial/xspec/escape-for-regex-result.html
	grep 'margin-right:' ../tutorial/xspec/escape-for-regex-result.html
}


@test "Ant for XSLT with default properties fails on test failure" {
    run ant -buildfile ${PWD}/../build.xml -Dxspec.xml=${PWD}/../tutorial/escape-for-regex.xspec -lib ${SAXON_CP}
	echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "passed: 5 / pending: 0 / failed: 1 / total: 6" ]]
    [[ "${output}" =~  "BUILD FAILED" ]]
}


@test "Ant for XSLT with xspec.fail=false continues on test failure" {
    run ant -buildfile ${PWD}/../build.xml -Dxspec.xml=${PWD}/../tutorial/escape-for-regex.xspec -lib ${SAXON_CP} -Dxspec.fail=false
	echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 5 / pending: 0 / failed: 1 / total: 6" ]]
    [[ "${output}" =~  "BUILD SUCCESSFUL" ]]
}


@test "Ant for XSLT with catalog resolves URI" {
    run ant -buildfile ${PWD}/../build.xml -Dxspec.xml=${PWD}/catalog/xspec-160_xslt.xspec -lib ${SAXON_CP} -Dxspec.fail=false -Dcatalog=${PWD}/catalog/xspec-160_catalog.xml -lib ${XML_RESOLVER_CP}
	echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 5 / pending: 0 / failed: 1 / total: 6" ]]
    [[ "${output}" =~  "BUILD SUCCESSFUL" ]]
}


@test "Ant for Schematron with minimum properties #168" {
    run ant -buildfile ${PWD}/../build.xml -Dxspec.xml=${PWD}/../tutorial/schematron/demo-03.xspec -lib ${SAXON_CP} -Dtest.type=s
	echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 10 / pending: 1 / failed: 0 / total: 11" ]]
    [[ "${output}" =~  "BUILD SUCCESSFUL" ]]

    # Verify default clean.output.dir is false
    [  -d "../tutorial/schematron/xspec/" ]
    [  -f "../tutorial/schematron/demo-03.xspec-compiled.xspec" ]
    [  -f "../tutorial/schematron/demo-03.sch-compiled.xsl" ]

    # Delete temp file
    rm -f "../tutorial/schematron/demo-03.xspec-compiled.xspec"
    rm -f "../tutorial/schematron/demo-03.sch-compiled.xsl"
}


@test "Ant for Schematron with various properties except catalog" {
    build_xml="${work_dir}/build.xml"
    ant_test_dir="${work_dir}/ant-temp"

    # Remove a temp dir created by setup
    rm -r ../tutorial/schematron/xspec

    # For testing -Dxspec.project.dir
    cp ../build.xml "${build_xml}"

    run ant -buildfile "${build_xml}" -Dxspec.xml=${PWD}/../tutorial/schematron/demo-03.xspec -lib ${SAXON_CP} -Dtest.type=s -Dxspec.project.dir=${PWD}/.. -Dxspec.phase=#ALL -Dxspec.dir="${ant_test_dir}" -Dclean.output.dir=true
	echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 10 / pending: 1 / failed: 0 / total: 11" ]]
    [[ "${output}" =~  "BUILD SUCCESSFUL" ]]

    # Verify that -Dxspec-dir was honered and the default dir was not created
    [ ! -d "../tutorial/schematron/xspec/" ]

    # Verify clean.output.dir=true
    [ ! -d "${ant_test_dir}" ]
    [ ! -f "../tutorial/schematron/demo-03.xspec-compiled.xspec" ]
    [ ! -f "../tutorial/schematron/demo-03.sch-compiled.xsl" ]
}


@test "Ant for Schematron with catalog and default xspec.fail fails on test failure" {
    run ant -buildfile ${PWD}/../build.xml -Dxspec.xml=${PWD}/catalog/xspec-160_schematron.xspec -lib ${SAXON_CP} -Dtest.type=s -Dxspec.phase=#ALL -Dclean.output.dir=true -Dcatalog=${PWD}/catalog/xspec-160_catalog.xml -lib ${XML_RESOLVER_CP}
	echo "$output"
    [ "$status" -eq 1 ]
    [[ "${output}" =~ "passed: 6 / pending: 0 / failed: 1 / total: 7" ]]
    [[ "${output}" =~  "BUILD FAILED" ]]

    # Verify the build fails before cleanup
    [  -d "catalog/xspec/" ]

    # Verify the build fails after Schematron setup
    [  -f "catalog/xspec-160_schematron.xspec-compiled.xspec" ]
    [  -f "../tutorial/schematron/demo-04.sch-compiled.xsl" ]

    # Delete temp file
    rm -f "catalog/xspec-160_schematron.xspec-compiled.xspec"
    rm -f "../tutorial/schematron/demo-04.sch-compiled.xsl"
}


@test "Ant for Schematron with catalog and xspec.fail=false continues on test failure" {
    run ant -buildfile ${PWD}/../build.xml -Dxspec.xml=${PWD}/catalog/xspec-160_schematron.xspec -lib ${SAXON_CP} -Dtest.type=s -Dxspec.phase=#ALL -Dclean.output.dir=true -Dcatalog=${PWD}/catalog/xspec-160_catalog.xml -lib ${XML_RESOLVER_CP} -Dxspec.fail=false
	echo "$output"
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "passed: 6 / pending: 0 / failed: 1 / total: 7" ]]
    [[ "${output}" =~  "BUILD SUCCESSFUL" ]]
}

@test "invoking xspec.sh for XSLT with -catalog uses XML Catalog resolver" {
    export SAXON_CP="$SAXON_CP:$XML_RESOLVER_CP"
	run ../bin/xspec.sh -catalog catalog/catalog-01-catalog.xml catalog/catalog-01-xslt.xspec
	echo "$output"
	[ "$status" -eq 0 ]
	[ "${lines[7]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
}

@test "invoking xspec.sh for XQuery with -catalog uses XML Catalog resolver" {
    export SAXON_CP="$SAXON_CP:$XML_RESOLVER_CP"
	run ../bin/xspec.sh -catalog catalog/catalog-01-catalog.xml -q catalog/catalog-01-xquery.xspec
	echo "$output"
	[ "$status" -eq 0 ]
	[ "${lines[5]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
}

@test "invoking xspec.sh with XML_CATALOG set uses XML Catalog resolver" {
    export SAXON_CP="$SAXON_CP:$XML_RESOLVER_CP"
    export XML_CATALOG=catalog/catalog-01-catalog.xml
	run ../bin/xspec.sh catalog/catalog-01-xslt.xspec
	echo "$output"
	[ "$status" -eq 0 ]
	[ "${lines[7]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
}

@test "invoking xspec.sh using -catalog with spaces in file path uses XML Catalog resolver" {
    space_dir="${work_dir}/cat a log"
    mkdir -p "${space_dir}/xspec"
    cp catalog/catalog-01* "${space_dir}"
    
    export SAXON_CP="$SAXON_CP:$XML_RESOLVER_CP"
	run ../bin/xspec.sh -catalog "${space_dir}/catalog-01-catalog.xml" "${space_dir}/catalog-01-xslt.xspec"
	echo "$output"
	[ "$status" -eq 0 ]
	[ "${lines[7]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
}

@test "invoking xspec.sh using XML_CATALOG with spaces in file path uses XML Catalog resolver" {
    space_dir="${work_dir}/cat a log"
    mkdir -p "${space_dir}/xspec"
    cp catalog/catalog-01* "${space_dir}"
    
    export SAXON_CP="$SAXON_CP:$XML_RESOLVER_CP"
    export XML_CATALOG="${space_dir}/catalog-01-catalog.xml"
	run ../bin/xspec.sh "${space_dir}/catalog-01-xslt.xspec"
	echo "$output"
	[ "$status" -eq 0 ]
	[ "${lines[7]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
}

@test "invoking xspec.sh using SAXON_HOME finds Saxon jar and XML Catalog Resolver jar" {
    export SAXON_HOME="${work_dir}/saxon"
    mkdir "${SAXON_HOME}"
    cp "${SAXON_CP}"        "${SAXON_HOME}"
    cp "${XML_RESOLVER_CP}" "${SAXON_HOME}/xml-resolver-1.2.jar"
    export SAXON_CP=
	run ../bin/xspec.sh -catalog catalog/catalog-01-catalog.xml catalog/catalog-01-xslt.xspec
	echo "$output"
	[ "$status" -eq 0 ]
	[ "${lines[7]}" = "passed: 1 / pending: 0 / failed: 0 / total: 1" ]
}


@test "Schema detects no error in tutorial" {
    if [ -n "${JING_CP}" ]; then
        run java -jar ${JING_CP} -c ../src/schemas/xspec.rnc ../tutorial/*.xspec ../tutorial/schematron/*.xspec
    	echo "$output"
        [ "$status" -eq 0 ]
    else
        skip "Schema validation for tutorial skipped";
    fi
}


@test "Schema detects no error in known good tests" {
    if [ -n "${JING_CP}" ]; then
        run java -jar ${JING_CP} -c ../src/schemas/xspec.rnc catalog/*.xspec schematron/*-import.xspec schematron/*-in.xspec
    	echo "$output"
        [ "$status" -eq 0 ]
    else
        skip "Schema validation for known good tests skipped";
    fi
}
