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
	mkdir ../tutorial/xspec
	mkdir ../test/xspec
	mkdir ../tutorial/schematron/xspec
}


teardown() {
	rm -rf ../tutorial/xspec
	rm -rf ../test/xspec
	rm -rf ../tutorial/schematron/xspec
}


@test "invoking xspec without arguments prints usage" {
    run ../bin/xspec.sh
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[2]}" = "Usage: xspec [-t|-q|-s|-c|-j|-h] filename [coverage]" ]
}


@test "invoking xspec with -s and -t prints error message" {
    run ../bin/xspec.sh -s -t
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "-s and -t are mutually exclusive" ]
}


@test "invoking xspec with -s and -q prints error message" {
    run ../bin/xspec.sh -s -q
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "-s and -q are mutually exclusive" ]
}


@test "invoking xspec with -t and -q prints error message" {
    run ../bin/xspec.sh -t -q
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "-t and -q are mutually exclusive" ]
}


@test "invoking code coverage with Saxon9HE returns error message" {
    export SAXON_CP=/path/to/saxon9he.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon9SA returns error message" {
    export SAXON_CP=/path/to/saxon9sa.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon9 returns error message" {
    export SAXON_CP=/path/to/saxon9.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon8SA returns error message" {
    export SAXON_CP=/path/to/saxon8sa.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon8 returns error message" {
    export SAXON_CP=/path/to/saxon8.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE." ]
}


@test "invoking code coverage with Saxon9EE creates test stylesheet" {
    export SAXON_CP=/path/to/saxon9ee.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
  	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Creating Test Stylesheet..." ]
}


@test "invoking code coverage with Saxon9PE creates test stylesheet" {
    export SAXON_CP=/path/to/saxon9pe.jar
    run ../bin/xspec.sh -c ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Creating Test Stylesheet..." ]
}


@test "invoking xspec generates XML report file" {
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
    run stat ../tutorial/xspec/escape-for-regex-result.xml
	echo $output
    [ "$status" -eq 0 ]
}


@test "invoking xspec generates HTML report file" {
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
    run stat ../tutorial/xspec/escape-for-regex-result.html
	echo $output
    [ "$status" -eq 0 ]
}


@test "invoking xspec with -j option with Saxon8 returns error message" {
    export SAXON_CP=/path/to/saxon8.jar
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Saxon8 detected. JUnit report requires Saxon9." ]
}


@test "invoking xspec with -j option with Saxon8-SA returns error message" {
    export SAXON_CP=/path/to/saxon8sa.jar
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 1 ]
    [ "${lines[1]}" = "Saxon8 detected. JUnit report requires Saxon9." ]
}


@test "invoking xspec with -j option generates message with JUnit report location" {
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 0 ]
    [ "${lines[18]}" = "Report available at ../tutorial/xspec/escape-for-regex-junit.xml" ]
}


@test "invoking xspec with -j option generates XML report file" {
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
    run stat ../tutorial/xspec/escape-for-regex-result.xml
	echo $output
    [ "$status" -eq 0 ]
}


@test "invoking xspec with -j option generates JUnit report file" {
    run ../bin/xspec.sh -j ../tutorial/escape-for-regex.xspec
    run stat ../tutorial/xspec/escape-for-regex-junit.xml
	echo $output
    [ "$status" -eq 0 ]
}


@test "invoking xspec with Saxon-B-9-1-0-8 creates test stylesheet" {
    export SAXON_CP=/path/to/saxonb9-1-0-8.jar
	run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	echo $output
	[ "$status" -eq 1 ]
  	[ "${lines[1]}" = "Creating Test Stylesheet..." ]
}


@test "invoking xspec.sh with TEST_DIR already set externally generates files inside TEST_DIR" {
    export TEST_DIR=/tmp
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 0 ]
    [ "${lines[18]}" = "Report available at /tmp/escape-for-regex-result.html" ]
}


@test "invoking xspec.sh without TEST_DIR generates files in default location" {
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	echo $output
    [ "$status" -eq 0 ]
    [ "${lines[18]}" = "Report available at ../tutorial/xspec/escape-for-regex-result.html" ]
}


@test "invoking xspec.sh that passes a non xs:boolean does not raise a warning #46" {
    run ../bin/xspec.sh ../test/xspec-46.xspec
	echo $output
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

    echo $output
    [ "${lines[0]}" = "true" ]
}


@test "invoking xspec.sh with path containing an apostrophe runs successfully #119" {
	mkdir some\'path
	cp ../tutorial/escape-for-regex.* some\'path 
	run ../bin/xspec.sh some\'path/escape-for-regex.xspec
	echo $output
	[ "$status" -eq 0 ]
	[ "${lines[19]}" = "Report available at some'path/xspec/escape-for-regex-result.html" ]
	rm -rf some\'path
}


@test "invoking xspec.sh with saxon script uses the saxon script #121 #122" {
	echo "echo 'Saxon script with EXPath Packaging System'" > /tmp/saxon
	chmod +x /tmp/saxon
	export PATH=$PATH:/tmp
	run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	echo $output
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "Saxon script found, use it." ]
	rm /tmp/saxon
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
	echo $output
    [ "${lines[4]}" = "Schematron XSLT include" ]
    [ "${lines[5]}" = "Schematron XSLT expand" ]
    [ "${lines[6]}" = "Schematron XSLT compile" ]
}


@test "invoking xspec.sh with the -s option does not display Schematron warnings #129 #131" {
    run ../bin/xspec.sh -s ../tutorial/schematron/demo-01.xspec
	echo "${lines[4]}"
	echo $output
    [ "$status" -eq 0 ]
    [ "${lines[4]}" == "Compiling the Schematron tests..." ]
}


@test "Cleanup removes temporary files" {
    run ../bin/xspec.sh -s ../tutorial/schematron/demo-03.xspec
    [ "$status" -eq 0 ]
    [ ! -f "../tutorial/schematron/demo-03.xspec-compiled.xspec" ]
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

    echo $output
    [[ "${output}" =~ "src/harnesses/harness-lib.xpl:267:45:passed: 1 / pending: 0 / failed: 0 / total: 1" ]]
}


@test "HTML report contains CSS inline and not as an external file #135" {
    run ../bin/xspec.sh ../tutorial/escape-for-regex.xspec
	grep '<style type="text/css">' ../tutorial/xspec/escape-for-regex-result.html
	grep 'margin-right:' ../tutorial/xspec/escape-for-regex-result.html
}
