#!/bin/bash
#===============================================================================
#
#         USAGE:  ./run-xspec.tests.sh 
#         
#   DESCRIPTION:  This script is a runner for XSpec test suite inside test directory
#		  it runs all the tests with extension .xspec in the test directory
#		  it outputs stdout and stderr into a file result.log
#	          it greps for failing tests in the log file or for compilation errors
#		  it returns no output if the tests are successful
#		  or an error message if there are failing tests or compilation errors
#
#         INPUT:  N/A
#
#        OUTPUT:  Error message if there are failing tests or compilation errors
#	          A log file is created at result.log
#
#  DEPENDENCIES:  This script must be run from the current directory (i.e. the test directory)
#
#       AUTHORS:  Sandro Cirulli, github.com/cirulls
#                 Tobias Fischer, github.com/tofi86
#
#       LICENSE:  MIT License
#
#===============================================================================
for xspectest in *.xspec
do 
    if test "${xspectest:0:10}" = "schematron"; then
        ../bin/xspec.sh -s $xspectest &> result.log;
    else 
        ../bin/xspec.sh $xspectest &> result.log;
    fi
    if grep -q ".*failed:\s[1-9]" result.log || grep -q -E "\*+\sError\s(.*Schematron.*|(running|compiling)\sthe\stest\ssuite)" result.log;
        then
            echo "FAILED: $xspectest";
            echo "---------- result.log";
            cat result.log;
            echo "----------";
            exit 1;
        else echo "OK: $xspectest";
    fi
done
