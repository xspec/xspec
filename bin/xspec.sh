#! /bin/bash

##############################################################################
##
## This script is used to compile a test suite to XSLT, run it, format
## the report and open it in a browser.
##
## It relies on the environment variable $SAXON_HOME to be set to the
## dir Saxon has been installed to (i.e. the containing the Saxon JAR
## file), or on $SAXON_CP to be set to a full classpath containing
## Saxon (and maybe more).  The latter has precedence over the former.
##
## It also uses the environment variable XSPEC_HOME.  It must be set
## to the XSpec install directory.  By default, it uses this script's
## parent dir.
##
## Note: If you use the EXPath Packaging System with Saxon, then you
## already have the script "saxon" shipped with expath-repo.  In that
## case you don't need to do anything, this script will be detected
## and used instead.  You just have to ensure it is visible from here
## (aka "ensure it is in the $PATH").  Even without packaging support,
## this script is a useful way to launch Saxon from the shell.
## 
## TODO: With the Packaging System, there should be no need to set the
## XSPEC_HOME, as we could use absolute public URIs for the public
## components...
##
##############################################################################

##
## utility functions #########################################################
##

usage() {
    if test -n "$1"; then
        echo "$1"
        echo;
    fi
    echo "Usage: xspec [-t|-q|-s|-c|-j|-catalog file|-h] file [coverage]"
    echo
    echo "  file           the XSpec document"
    echo "  -t             test an XSLT stylesheet (the default)"
    echo "  -q             test an XQuery module (mutually exclusive with -t and -s)"
    echo "  -s             test a Schematron schema (mutually exclusive with -t and -q)"
    echo "  -c             output test coverage report (XSLT only)"
    echo "  -j             output JUnit report"
    echo "  -catalog file  use XML Catalog file to locate resources"
    echo "  -h             display this help message"
    echo "  coverage       deprecated, use -c instead"
}

die() {
    echo
    echo "*** $@" >&2
    exit 1
}

# If there is a script called "saxon" and returning ok (status code 0)
# when called with "--help", we assume this is the EXPath Packaging
# script for Saxon [1].  If it is present, that means the user already
# configured it, so there is no point to duplicate the logic here.
# Just use it.

if which saxon > /dev/null 2>&1 && saxon --help | grep "EXPath Packaging" > /dev/null 2>&1; then
    echo Saxon script found, use it.
    echo
    xslt() {
        saxon \
            --java -Dxspec.coverage.xml="${COVERAGE_XML}" \
            --add-cp "${XSPEC_HOME}/java/" ${CATALOG:+"$CATALOG"} --xsl "$@"
    }
    xquery() {
        saxon \
            --java -Dxspec.coverage.xml="${COVERAGE_XML}" \
            --add-cp "${XSPEC_HOME}/java/" ${CATALOG:+"$CATALOG"} --xq "$@"
    }
else
    echo Saxon script not found, invoking JVM directly instead.
    echo
    xslt() {
        java \
            -Dxspec.coverage.xml="${COVERAGE_XML}" \
            -cp "$CP" net.sf.saxon.Transform ${CATALOG:+"$CATALOG"} "$@"
    }
    xquery() {
        java \
            -Dxspec.coverage.xml="${COVERAGE_XML}" \
            -cp "$CP" net.sf.saxon.Query ${CATALOG:+"$CATALOG"} "$@"
    }
fi

##
## some variables ############################################################
##

# the command to use to open the final HTML report
if [ `uname` = "Darwin" ]; then
    OPEN=open
else
    OPEN=see
fi

# the classpath delimiter (aka ':', except ';' on Cygwin)
if uname | grep -i cygwin >/dev/null 2>&1; then
    CP_DELIM=";"
else
    CP_DELIM=":"
fi

# set XSPEC_HOME if it has not been set by the user (set it to the
# parent dir of this script)
if test -z "$XSPEC_HOME"; then
    XSPEC_HOME=`dirname $0`;
    XSPEC_HOME=`dirname $XSPEC_HOME`;
fi
# safety checks
if test \! -d "${XSPEC_HOME}"; then
    echo "ERROR: XSPEC_HOME is not a directory: ${XSPEC_HOME}"
    exit 1;
fi
if test \! -f "${XSPEC_HOME}/src/compiler/generate-common-tests.xsl"; then
    echo "ERROR: XSPEC_HOME seems to be corrupted: ${XSPEC_HOME}"
    exit 1;
fi

# set SAXON_CP (either it has been by the user, or set it from SAXON_HOME)

if test -z "$SAXON_CP"; then
    # Set this variable in your environment or here, if you don't set SAXON_CP
    # SAXON_HOME=/path/to/saxon/dir
    if test -z "$SAXON_HOME"; then
    	echo "SAXON_CP and SAXON_HOME both not set!"
#        die "SAXON_CP and SAXON_HOME both not set!"
    fi
    if test -f "${SAXON_HOME}/saxon9ee.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon9ee.jar";
    elif test -f "${SAXON_HOME}/saxon9pe.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon9pe.jar";
    elif test -f "${SAXON_HOME}/saxon9he.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon9he.jar";
    elif test -f "${SAXON_HOME}/saxon9sa.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon9sa.jar";
    elif test -f "${SAXON_HOME}/saxon9.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon9.jar";
    elif test -f "${SAXON_HOME}/saxonb9-1-0-8.jar"; then
	SAXON_CP="${SAXON_HOME}/saxonb9-1-0-8.jar";
    elif test -f "${SAXON_HOME}/saxon8sa.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon8sa.jar";
    elif test -f "${SAXON_HOME}/saxon8.jar"; then
	SAXON_CP="${SAXON_HOME}/saxon8.jar";
    else
    	echo "Saxon jar cannot be found in SAXON_HOME: $SAXON_HOME"
#        die "Saxon jar cannot be found in SAXON_HOME: $SAXON_HOME"
    fi
    if test -f "${SAXON_HOME}/xml-resolver-1.2.jar"; then
	   SAXON_CP="${SAXON_CP}${CP_DELIM}${SAXON_HOME}/xml-resolver-1.2.jar";
	fi
fi

CP="${SAXON_CP}${CP_DELIM}${XSPEC_HOME}/java/"

##
## options ###################################################################
##

while echo "$1" | grep -- ^- >/dev/null 2>&1; do
    case "$1" in
        # XSLT
        -t)
            if test -n "$XQUERY"; then
                usage "-t and -q are mutually exclusive"
                exit 1
            fi
            if test -n "$SCHEMATRON"; then
                usage "-s and -t are mutually exclusive"
                exit 1
            fi
            XSLT=1;;
        # XQuery
        -q)
            if test -n "$XSLT"; then
                usage "-t and -q are mutually exclusive"
                exit 1
            fi
            if test -n "$SCHEMATRON"; then
                usage "-s and -q are mutually exclusive"
                exit 1
            fi
            XQUERY=1;;
        # Schematron
        -s)
            if test -n "$XQUERY"; then
                usage "-s and -q are mutually exclusive"
                exit 1
            fi
            if test -n "$XSLT"; then
                usage "-s and -t are mutually exclusive"
                exit 1
            fi
            SCHEMATRON=1;;
        # Coverage
        -c)
			if [[ ${SAXON_CP} != *"saxon9pe"* && ${SAXON_CP} != *"saxon9ee"* ]]; then
				echo "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."
			    exit 1
			fi
            COVERAGE=1;;
        # JUnit report
        -j)
			if [[ ${SAXON_CP} == *"saxon8"* || ${SAXON_CP} == *"saxon8sa"* ]]; then
				echo "Saxon8 detected. JUnit report requires Saxon9."
			    exit 1
			fi
            JUNIT=1;;
        # Catalog
        -catalog)
            shift
            XML_CATALOG="$1";;
        # Help!
        -h)
            usage
            exit 0;;
        # Unknown option!
        -*)
            usage "Error: Unknown option: $1"
            exit 1;;
    esac
    shift;
done

# Coverage is only for XSLT
if [ -n "${COVERAGE}" ] && [ -n "${XQUERY}${SCHEMATRON}" ]; then
    usage "Coverage is supported only for XSLT"
    exit 1
fi

# set CATALOG option for Saxon if XML_CATALOG has been set
if test -n "$XML_CATALOG"; then
    CATALOG="-catalog:$XML_CATALOG"
else
    CATALOG=
fi

# set XSLT if XQuery has not been set (that's the default)
if test -z "$XQUERY"; then
    XSLT=1;
fi

XSPEC=$1
if [ ! -f "$XSPEC" ]; then
    usage "Error: File not found."
    exit 1
fi

if [ -n "$2" ]; then
    if [ "$2" != coverage ]; then
        usage "Error: Extra option: $2"
        exit 1
    fi
	echo "Long-form option 'coverage' deprecated, use '-c' instead."
	if [[ ${SAXON_CP} != *"saxon9pe"* && ${SAXON_CP} != *"saxon9ee"* ]]; then
		echo "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."
		exit 1
	fi
	COVERAGE=1
    if [ -n "$3" ]; then
        usage "Error: Extra option: $3"
        exit 1
    fi
fi

##
## files and dirs ############################################################
##

# TEST_DIR (may be relative, may not exist)
if [ -z "$TEST_DIR" ]
then
    TEST_DIR=$(dirname "$XSPEC")/xspec
fi

TARGET_FILE_NAME=$(basename "$XSPEC" | sed 's:\.[^.]*$::')

if test -n "$XSLT"; then
    COMPILED=$TEST_DIR/$TARGET_FILE_NAME.xsl
else
    COMPILED=$TEST_DIR/$TARGET_FILE_NAME.xq
fi
COVERAGE_XML=$TEST_DIR/$TARGET_FILE_NAME-coverage.xml
COVERAGE_HTML=$TEST_DIR/$TARGET_FILE_NAME-coverage.html
RESULT=$TEST_DIR/$TARGET_FILE_NAME-result.xml
HTML=$TEST_DIR/$TARGET_FILE_NAME-result.html
JUNIT_RESULT=$TEST_DIR/$TARGET_FILE_NAME-junit.xml
COVERAGE_CLASS=com.jenitennison.xslt.tests.XSLTCoverageTraceListener

if [ ! -d "$TEST_DIR" ]; then
    echo "Creating XSpec Directory at $TEST_DIR..."
    mkdir "$TEST_DIR"
    echo
fi 

# Absolute TEST_DIR
TEST_DIR_ABS="$(cd "$(dirname "${TEST_DIR}")" && pwd)/$(basename "${TEST_DIR}")"

##
## compile the suite #########################################################
##

if test -n "$SCHEMATRON"; then
    echo "Setting up Schematron..."
    
    if test -z "$SCHEMATRON_XSLT_INCLUDE"; then
        SCHEMATRON_XSLT_INCLUDE="$XSPEC_HOME/src/schematron/iso-schematron/iso_dsdl_include.xsl";
    fi
    if test -z "$SCHEMATRON_XSLT_EXPAND"; then
        SCHEMATRON_XSLT_EXPAND="$XSPEC_HOME/src/schematron/iso-schematron/iso_abstract_expand.xsl";
    fi
    if test -n "${SCHEMATRON_XSLT_COMPILE}"; then
        # Absolute SCHEMATRON_XSLT_COMPILE
        SCHEMATRON_XSLT_COMPILE_ABS="$(cd "$(dirname "${SCHEMATRON_XSLT_COMPILE}")" && pwd)/$(basename "${SCHEMATRON_XSLT_COMPILE}")"
    fi
    
    # Get Schematron file path
    xslt -o:"${TEST_DIR}/${TARGET_FILE_NAME}-var.txt" \
        -s:"${XSPEC}" \
        -xsl:"${XSPEC_HOME}/src/schematron/sch-file-path.xsl" \
        || die "Error getting Schematron location"
    SCH=`cat "${TEST_DIR}/${TARGET_FILE_NAME}-var.txt"`
    
    # Generate Step 3 wrapper XSLT
    if test -n "${SCHEMATRON_XSLT_COMPILE}"; then
        SCHEMATRON_XSLT_COMPILE_URI="file:${SCHEMATRON_XSLT_COMPILE_ABS}"
    fi
    SCH_STEP3_WRAPPER="${TEST_DIR}/${TARGET_FILE_NAME}-sch-step3-wrapper.xsl"
    xslt -o:"${SCH_STEP3_WRAPPER}" \
        -s:"${XSPEC}" \
        -xsl:"${XSPEC_HOME}/src/schematron/generate-step3-wrapper.xsl" \
        "ACTUAL-PREPROCESSOR-URI=${SCHEMATRON_XSLT_COMPILE_URI}" \
        || die "Error generating Step 3 wrapper XSLT"
    
    SCHUT=$XSPEC-compiled.xspec
    SCH_COMPILED="${SCH}-compiled.xsl"
    
    echo
    echo "Compiling the Schematron..."
    xslt -o:"$TEST_DIR/$TARGET_FILE_NAME-sch-temp1.xml" -s:"$SCH" -xsl:"$SCHEMATRON_XSLT_INCLUDE" -versionmsg:off || die "Error compiling the Schematron on step 1"
    xslt -o:"$TEST_DIR/$TARGET_FILE_NAME-sch-temp2.xml" -s:"$TEST_DIR/$TARGET_FILE_NAME-sch-temp1.xml" -xsl:"$SCHEMATRON_XSLT_EXPAND" -versionmsg:off || die "Error compiling the Schematron on step 2"
    xslt -o:"${SCH_COMPILED}" -s:"${TEST_DIR}/${TARGET_FILE_NAME}-sch-temp2.xml" \
        -xsl:"${SCH_STEP3_WRAPPER}" -versionmsg:off \
        || die "Error compiling the Schematron on step 3"
    
    # use XQuery to get full URI to compiled Schematron
    # xquery -qs:"declare namespace output = 'http://www.w3.org/2010/xslt-xquery-serialization'; declare option output:method 'text'; replace(iri-to-uri(document-uri(/)), concat(codepoints-to-string(94), 'file:/'), '')" -s:"$SCH_COMPILED" >"$TEST_DIR/$TARGET_FILE_NAME-var.txt" || die "Error getting compiled Schematron location"
    # SCH_COMPILED_URI=`cat "$TEST_DIR/$TARGET_FILE_NAME-var.txt"`
    SCH_COMPILED_URI="file:${SCH_COMPILED}"
    
    echo 
    echo "Compiling the Schematron tests..."
    TEST_DIR_URI="file:${TEST_DIR_ABS}"
    xslt -o:"${SCHUT}" \
        -s:"${XSPEC}" \
        -xsl:"${XSPEC_HOME}/src/schematron/schut-to-xspec.xsl" \
        stylesheet-uri="${SCH_COMPILED_URI}" \
        test-dir-uri="${TEST_DIR_URI}" \
        || die "Error compiling the Schematron tests"
    XSPEC=$SCHUT
    
    echo 
fi

if test -n "$XSLT"; then
    COMPILE_SHEET=generate-xspec-tests.xsl
else
    COMPILE_SHEET=generate-query-tests.xsl
fi
echo "Creating Test Stylesheet..."
xslt -o:"$COMPILED" -s:"$XSPEC" \
    -xsl:"$XSPEC_HOME/src/compiler/$COMPILE_SHEET" \
    || die "Error compiling the test suite"
echo

##
## run the suite #############################################################
##

declare -a "saxon_custom_options_array=(${SAXON_CUSTOM_OPTIONS})"

echo "Running Tests..."
if test -n "$XSLT"; then
    # for XSLT
    if test -n "$COVERAGE"; then
        echo "Collecting test coverage data..."
        xslt "${saxon_custom_options_array[@]}" \
            -T:$COVERAGE_CLASS \
            -o:"$RESULT" -xsl:"$COMPILED" \
            -it:{http://www.jenitennison.com/xslt/xspec}main \
            || die "Error collecting test coverage data"
    else
        xslt "${saxon_custom_options_array[@]}" \
            -o:"$RESULT" -xsl:"$COMPILED" \
            -it:{http://www.jenitennison.com/xslt/xspec}main \
            || die "Error running the test suite"
    fi
else
    # for XQuery
    if test -n "$COVERAGE"; then
        echo "Collecting test coverage data..."
        xquery "${saxon_custom_options_array[@]}" \
            -T:$COVERAGE_CLASS \
            -o:"$RESULT" -q:"$COMPILED" \
            || die "Error collecting test coverage data"
    else
        xquery "${saxon_custom_options_array[@]}" \
            -o:"$RESULT" -q:"$COMPILED" \
            || die "Error running the test suite"
    fi
fi

##
## format the report #########################################################
##

echo
echo "Formatting Report..."
xslt -o:"$HTML" \
    -s:"$RESULT" \
    -xsl:"$XSPEC_HOME/src/reporter/format-xspec-report.xsl" \
    inline-css=true \
    || die "Error formatting the report"
if test -n "$COVERAGE"; then
    echo
    echo "Formatting Coverage Report..."
    xslt -l:on \
        -o:"$COVERAGE_HTML" \
        -s:"$COVERAGE_XML" \
        -xsl:"$XSPEC_HOME/src/reporter/coverage-report.xsl" \
        "tests=$XSPEC" \
        inline-css=true \
        || die "Error formatting the coverage report"
    echo "Report available at $COVERAGE_HTML"
    #$OPEN "$COVERAGE_HTML"
elif test -n "$JUNIT"; then
    echo
    echo "Generating JUnit Report..."
    xslt -o:"$JUNIT_RESULT" \
        -s:"$RESULT" \
        -xsl:"$XSPEC_HOME/src/reporter/junit-report.xsl" \
        || die "Error formatting the JUnit report"
    echo "Report available at $JUNIT_RESULT"
else
    echo "Report available at $HTML"
    #$OPEN "$HTML"
fi

##
## cleanup
##
if test -n "$SCHEMATRON"; then
    rm -f "$SCHUT"
    rm -f "$TEST_DIR"/context-*.xml
    rm -f "$TEST_DIR/$TARGET_FILE_NAME-var.txt"
    rm -f "$TEST_DIR/$TARGET_FILE_NAME-sch-temp1.xml"
    rm -f "$TEST_DIR/$TARGET_FILE_NAME-sch-temp2.xml"
    rm -f "$SCH_STEP3_WRAPPER"
    rm -f "$SCH_COMPILED"
fi

echo "Done."
