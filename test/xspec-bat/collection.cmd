setlocal
    call :setup "invoking xspec without arguments prints usage"

    call :run ..\bin\xspec.bat
    call :verify_retval 1
    call :verify_line 3 x "Usage: xspec [-t|-q|-s|-c|-j|-catalog file|-h] file [coverage]"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -s and -t prints error message"

    call :run ..\bin\xspec.bat -s -t
    call :verify_retval 1
    call :verify_line 2 x "-s and -t are mutually exclusive"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -s and -q prints error message"

    call :run ..\bin\xspec.bat -s -q
    call :verify_retval 1
    call :verify_line 2 x "-s and -q are mutually exclusive"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -t and -q prints error message"

    call :run ..\bin\xspec.bat -t -q
    call :verify_retval 1
    call :verify_line 2 x "-t and -q are mutually exclusive"

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon9HE returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9he.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon9SA returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9sa.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon9 returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon8SA returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon8sa.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon8 returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon8.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Code coverage requires Saxon extension functions which are available only under Saxon9EE or Saxon9PE."

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon9EE creates test stylesheet"

    rem Append non-Saxon jar to see if SAXON_CP is parsed correctly
    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9ee.jar;%XML_RESOLVER_CP%

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Creating Test Stylesheet..."

    call :teardown
endlocal

setlocal
    call :setup "invoking code coverage with Saxon9PE creates test stylesheet"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon9pe.jar

    call :run ..\bin\xspec.bat -c ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Creating Test Stylesheet..."

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec generates message with default report location and creates report files"

    call :run ..\bin\xspec.bat ..\tutorial\escape-for-regex.xspec
    call :verify_retval 0
    call :verify_line 19 x "Report available at %PARENT_DIR_ABS%\tutorial\xspec\escape-for-regex-result.html"

    rem XML report file is created
    call :verify_exist ..\tutorial\xspec\escape-for-regex-result.xml

    rem HTML report file is created and contains CSS inline #135
    call :run java -cp "%SAXON_CP%" net.sf.saxon.Transform -s:..\tutorial\xspec\escape-for-regex-result.html -xsl:html-css.xsl
    call :verify_line 1 x "true"

    rem JUnit is disabled by default
    call :verify_not_exist ..\tutorial\xspec\escape-for-regex-junit.xml

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -j option with Saxon8 returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon8.jar

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Saxon8 detected. JUnit report requires Saxon9."

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -j option with Saxon8-SA returns error message"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxon8sa.jar

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Saxon8 detected. JUnit report requires Saxon9."

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with -j option generates message with JUnit report location and creates report files"

    call :run ..\bin\xspec.bat -j ..\tutorial\escape-for-regex.xspec
    call :verify_retval 0
    call :verify_line 19 x "Report available at %PARENT_DIR_ABS%\tutorial\xspec\escape-for-regex-junit.xml"

    rem XML report file
    call :verify_exist ..\tutorial\xspec\escape-for-regex-result.xml

    rem HTML report file
    call :verify_exist ..\tutorial\xspec\escape-for-regex-result.html

    rem JUnit report file
    call :verify_exist ..\tutorial\xspec\escape-for-regex-junit.xml

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with Saxon-B-9-1-0-8 creates test stylesheet"

    set SAXON_CP=%SYSTEMDRIVE%\path\to\saxonb9-1-0-8.jar

    call :run ..\bin\xspec.bat ..\tutorial\escape-for-regex.xspec
    call :verify_retval 1
    call :verify_line 2 x "Creating Test Stylesheet..."

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat with TEST_DIR already set externally generates files inside TEST_DIR"

    set "TEST_DIR=%WORK_DIR%"

    call :run ..\bin\xspec.bat ..\tutorial\escape-for-regex.xspec
    call :verify_retval 0
    call :verify_line 19 x "Report available at %TEST_DIR%\escape-for-regex-result.html"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat that passes a non xs:boolean does not raise a warning #46"

    call :run ..\bin\xspec.bat xspec-46.xspec
    call :verify_retval 0
    call :verify_line 4 r "Testing with"

    call :teardown
endlocal

setlocal
    call :setup "executing the Saxon XProc harness generates a report with UTF-8 encoding"

    if defined XMLCALABASH_CP (
        call :run java -Xmx1024m -cp "%XMLCALABASH_CP%" com.xmlcalabash.drivers.Main -isource=xspec-72.xspec -p xspec-home="file:/%PARENT_DIR_ABS:\=/%/" -oresult=xspec/xspec-72-result.html ..\src\harnesses\saxon\saxon-xslt-harness.xproc
        call :run java -cp "%SAXON_CP%" net.sf.saxon.Transform -s:xspec\xspec-72-result.html -xsl:html-charset.xsl
        call :verify_line 1 x "true"
    ) else (
        call :skip "test for XProc skipped as XMLCalabash uses a higher version of Saxon"
    )

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat with path containing parentheses #84, an apostrophe #119 or an ampersand #202 runs successfully and generates HTML report file"

    set "SPECIAL_CHARS_DIR=%WORK_DIR%\some'path (84) here & there"
    call :mkdir "%SPECIAL_CHARS_DIR%"
    call :copy ..\tutorial\escape-for-regex.* "%SPECIAL_CHARS_DIR%"

    set "EXPECTED_REPORT=%SPECIAL_CHARS_DIR%\xspec\escape-for-regex-result.html"

    call :run ..\bin\xspec.bat "%SPECIAL_CHARS_DIR%\escape-for-regex.xspec"
    call :verify_retval 0
    call :verify_line 20 x "Report available at %EXPECTED_REPORT%"
    call :verify_exist "%EXPECTED_REPORT%"

    call :teardown
endlocal

setlocal
    call :setup "Schematron phase/parameters are passed to Schematron compile"

    call :run ..\bin\xspec.bat -s schematron-param-001.xspec
    call :verify_retval 0
    call :verify_line 3 x "Paramaters: phase=P1 ?selected=codepoints-to-string((80,49))"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec with Schematron XSLTs provided externally uses provided XSLTs for Schematron compile"
    
    set SCHEMATRON_XSLT_INCLUDE=schematron\schematron-xslt-include.xsl
    set SCHEMATRON_XSLT_EXPAND=schematron\schematron-xslt-expand.xsl
    set SCHEMATRON_XSLT_COMPILE=schematron\schematron-xslt-compile.xsl
    
    call :run ..\bin\xspec.bat -s ..\tutorial\schematron\demo-01.xspec
    call :verify_line 5 x "Schematron XSLT include"
    call :verify_line 6 x "Schematron XSLT expand"
    call :verify_line 7 x "Schematron XSLT compile"

    rem With the provided dummy XSLTs, XSpec leaves temp files. Delete them.
    call :del ..\tutorial\schematron\demo-01.sch-compiled.xsl
    call :del ..\tutorial\schematron\demo-01.xspec-compiled.xspec

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat with the -s option does not display Schematron warnings #129 #131 and removes temporary files"

    call :run ..\bin\xspec.bat -s ..\tutorial\schematron\demo-03.xspec
    call :verify_retval 0
    call :verify_line 5 x "Compiling the Schematron tests..."

    rem Cleanup removes compiled .xspec
    call :verify_not_exist ..\tutorial\schematron\demo-03.xspec-compiled.xspec

    rem Cleanup removes temporary files in TEST_DIR
    call :run dir /b /o:n ..\tutorial\schematron\xspec
    call :verify_line_count 3
    call :verify_line 1 x demo-03.xsl
    call :verify_line 2 x demo-03-result.html
    call :verify_line 3 x demo-03-result.xml

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat with -q option runs XSpec test for XQuery"

    call :run ..\bin\xspec.bat -q ..\tutorial\xquery-tutorial.xspec
    call :verify_retval 0
    call :verify_line 6 x "passed: 1 / pending: 0 / failed: 0 / total: 1"

    call :teardown
endlocal

setlocal
    call :setup "executing the XProc harness for BaseX generates a report"

    set "COMPILED_FILE=%WORK_DIR%\compiled.xq"

    if defined BASEX_CP (
        call :run java -Xmx1024m -cp "%XMLCALABASH_CP%" com.xmlcalabash.drivers.Main -i source=../tutorial/xquery-tutorial.xspec -p xspec-home="file:/%PARENT_DIR_ABS:\=/%/" -p basex-jar="%BASEX_CP%" -p compiled-file="file:/%COMPILED_FILE:\=/%" -o result=xspec/xquery-tutorial-result.html ..\src\harnesses\basex\basex-standalone-xquery-harness.xproc
        call :verify_line -1 r "..*/src/harnesses/harness-lib.xpl:267:45:passed: 1 / pending: 0 / failed: 0 / total: 1"

        rem compiled-file
        call :verify_exist "%COMPILED_FILE%"
    ) else (
        call :skip "test for BaseX skipped as it requires XMLCalabash and a higher version of Saxon"
    )

    call :teardown
endlocal

setlocal
    call :setup "Ant for XSLT with default properties fails on test failure"

    if defined ANT_VERSION (
        call :run ant -buildfile "%CD%\..\build.xml" -Dxspec.xml="%CD%\..\tutorial\escape-for-regex.xspec" -lib "%SAXON_CP%"
        call :verify_retval 1
        call :verify_line  * x "     [xslt] passed: 5 / pending: 0 / failed: 1 / total: 6"
        call :verify_line -4 x "BUILD FAILED"

        rem Default xspec.junit.enabled is false
        call :verify_not_exist ..\tutorial\xspec\escape-for-regex-junit.xml
    ) else (
        call :skip "test for XSLT Ant with default properties skipped"
    )

    call :teardown
endlocal

setlocal
    call :setup "Ant for XSLT with xspec.fail=false continues on test failure"

    if defined ANT_VERSION (
        call :run ant -buildfile "%CD%\..\build.xml" -Dxspec.xml="%CD%\..\tutorial\escape-for-regex.xspec" -lib "%SAXON_CP%" -Dxspec.fail=false
        call :verify_retval 0
        call :verify_line  * x "     [xslt] passed: 5 / pending: 0 / failed: 1 / total: 6"
        call :verify_line -2 x "BUILD SUCCESSFUL"
    ) else (
        call :skip "test for XSLT Ant with xspec.fail=false skipped"
    )

    call :teardown
endlocal

setlocal
    call :setup "Ant for XSLT with catalog resolves URI"

    if defined ANT_VERSION (
        call :run ant -buildfile "%CD%\..\build.xml" -Dxspec.xml="%CD%\catalog\xspec-160_xslt.xspec" -lib "%SAXON_CP%" -Dxspec.fail=false -Dcatalog="%CD%\catalog\xspec-160_catalog.xml" -lib "%XML_RESOLVER_CP%"
        call :verify_retval 0
        call :verify_line  * x "     [xslt] passed: 5 / pending: 0 / failed: 1 / total: 6"
        call :verify_line -2 x "BUILD SUCCESSFUL"
    ) else (
        call :skip "test for XSLT Ant with catalog skipped"
    )

    call :teardown
endlocal

setlocal
    call :setup "Ant for XQuery with default properties"

    if defined ANT_VERSION (
        call :run ant -buildfile "%CD%\..\build.xml" -Dxspec.xml="%CD%\..\tutorial\xquery-tutorial.xspec" -lib "%SAXON_CP%" -Dtest.type=q
        call :verify_retval 0
        call :verify_line  * x "     [xslt] passed: 1 / pending: 0 / failed: 0 / total: 1"
        call :verify_line -2 x "BUILD SUCCESSFUL"
    ) else (
        call :skip "test for XQuery Ant with default properties skipped"
    )

    call :teardown
endlocal

setlocal
    call :setup "Ant for Schematron with minimum properties #168"

    if defined ANT_VERSION (
        call :run ant -buildfile "%CD%\..\build.xml" -Dxspec.xml="%CD%\..\tutorial\schematron\demo-03.xspec" -lib "%SAXON_CP%" -Dtest.type=s
        call :verify_retval 0
        call :verify_line  * x "     [xslt] passed: 10 / pending: 1 / failed: 0 / total: 11"
        call :verify_line -2 x "BUILD SUCCESSFUL"

        rem Verify that the default clean.output.dir is false and leaves temp files. Delete the left files at the same time.
        call :verify_exist ..\tutorial\schematron\xspec\
        call :del          ..\tutorial\schematron\demo-03.xspec-compiled.xspec
        call :del          ..\tutorial\schematron\demo-03.sch-compiled.xsl
    ) else (
        call :skip "test for Schematron Ant with minimum properties skipped"
    )

    call :teardown
endlocal

setlocal
    call :setup "Ant for Schematron with various properties except catalog"

    set "BUILD_XML=%WORK_DIR%\build.xml"
    set "ANT_TEST_DIR=%WORK_DIR%\ant-temp"

    if defined ANT_VERSION (
        rem Remove a temp dir created by setup
        call :rmdir ..\tutorial\schematron\xspec

        rem For testing -Dxspec.project.dir
        call :copy ..\build.xml "%BUILD_XML%"

        call :run ant -buildfile "%BUILD_XML%" -Dxspec.xml="%CD%\..\tutorial\schematron\demo-03.xspec" -lib "%SAXON_CP%" -Dxspec.properties="%CD%\schematron.properties" -Dxspec.project.dir="%CD%\.." -Dxspec.phase=#ALL -Dxspec.dir="%ANT_TEST_DIR%" -Dclean.output.dir=true
        call :verify_retval 0
        call :verify_line  * x "     [xslt] passed: 10 / pending: 1 / failed: 0 / total: 11"
        call :verify_line -2 x "BUILD SUCCESSFUL"

        rem Verify that -Dxspec-dir was honered and the default dir was not created
        call :verify_not_exist ..\tutorial\schematron\xspec\

        rem Verify clean.output.dir=true
        call :verify_not_exist "%ANT_TEST_DIR%"
        call :verify_not_exist ..\tutorial\schematron\demo-03.xspec-compiled.xspec
        call :verify_not_exist ..\tutorial\schematron\demo-03.sch-compiled.xsl
    ) else (
        call :skip "test for Schematron Ant with various properties except catalog skipped"
    )

    call :teardown
endlocal

setlocal
    call :setup "Ant for Schematron with catalog and default xspec.fail fails on test failure"

    if defined ANT_VERSION (
        call :run ant -buildfile "%CD%\..\build.xml" -Dxspec.xml="%CD%\catalog\xspec-160_schematron.xspec" -lib "%SAXON_CP%" -Dtest.type=s -Dxspec.phase=#ALL -Dclean.output.dir=true -Dcatalog="%CD%\catalog\xspec-160_catalog.xml" -lib "%XML_RESOLVER_CP%"
        call :verify_retval 1
        call :verify_line  * x "     [xslt] passed: 6 / pending: 0 / failed: 1 / total: 7"
        call :verify_line -4 x "BUILD FAILED"

        rem Verify the build fails before cleanup
        call :verify_exist catalog\xspec\
        
        rem Verify that the build fails after Schematron setup and leaves temp files. Delete them at the same time.
        call :del catalog\xspec-160_schematron.xspec-compiled.xspec
        call :del ..\tutorial\schematron\demo-04.sch-compiled.xsl
    ) else (
        call :skip "test for Schematron Ant with catalog and default xspec.fail skipped"
    )

    call :teardown
endlocal

setlocal
    call :setup "Ant for Schematron with catalog and xspec.fail=false continues on test failure"

    if defined ANT_VERSION (
        call :run ant -buildfile "%CD%\..\build.xml" -Dxspec.xml="%CD%\catalog\xspec-160_schematron.xspec" -lib "%SAXON_CP%" -Dtest.type=s -Dxspec.phase=#ALL -Dclean.output.dir=true -Dcatalog="%CD%\catalog\xspec-160_catalog.xml" -lib "%XML_RESOLVER_CP%" -Dxspec.fail=false
        call :verify_retval 0
        call :verify_line  * x "     [xslt] passed: 6 / pending: 0 / failed: 1 / total: 7"
        call :verify_line -2 x "BUILD SUCCESSFUL"
    ) else (
        call :skip "test for Schematron Ant with catalog and xspec.fail=false skipped"
    )

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat for XSLT with -catalog uses XML Catalog resolver and does so even with spaces in file path"

    set "SPACE_DIR=%WORK_DIR%\cat a log"
    call :mkdir "%SPACE_DIR%\xspec"
    call :copy catalog\catalog-01* "%SPACE_DIR%"
    
    set "SAXON_CP=%SAXON_CP%;%XML_RESOLVER_CP%"
    call :run ..\bin\xspec.bat -catalog "%SPACE_DIR%\catalog-01-catalog.xml" "%SPACE_DIR%\catalog-01-xslt.xspec"
    call :verify_retval 0
    call :verify_line 8 x "passed: 1 / pending: 0 / failed: 0 / total: 1"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat for XQuery with -catalog uses XML Catalog resolver"

    set "SAXON_CP=%SAXON_CP%;%XML_RESOLVER_CP%"
    call :run ..\bin\xspec.bat -catalog catalog\catalog-01-catalog.xml -q catalog\catalog-01-xquery.xspec
    call :verify_retval 0
    call :verify_line 6 x "passed: 1 / pending: 0 / failed: 0 / total: 1"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat with XML_CATALOG set uses XML Catalog resolver and does so even with spaces in file path"

    set "SPACE_DIR=%WORK_DIR%\cat a log"
    call :mkdir "%SPACE_DIR%\xspec"
    call :copy catalog\catalog-01* "%SPACE_DIR%"
    
    set "SAXON_CP=%SAXON_CP%;%XML_RESOLVER_CP%"
    set "XML_CATALOG=%SPACE_DIR%\catalog-01-catalog.xml"
    call :run ..\bin\xspec.bat "%SPACE_DIR%\catalog-01-xslt.xspec"
    call :verify_retval 0
    call :verify_line 8 x "passed: 1 / pending: 0 / failed: 0 / total: 1"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat using SAXON_HOME finds Saxon jar and XML Catalog Resolver jar"

    set "SAXON_HOME=%WORK_DIR%\saxon"
    call :mkdir "%SAXON_HOME%"
    call :copy "%SAXON_CP%"        "%SAXON_HOME%"
    call :copy "%XML_RESOLVER_CP%" "%SAXON_HOME%\xml-resolver-1.2.jar"
    set SAXON_CP=
    
    call :run ..\bin\xspec.bat -catalog catalog\catalog-01-catalog.xml catalog\catalog-01-xslt.xspec
    call :verify_retval 0
    call :verify_line 8 x "passed: 1 / pending: 0 / failed: 0 / total: 1"

    call :teardown
endlocal

setlocal
    call :setup "Schema detects no error in tutorial"

    if defined JING_CP (
        call :run java -jar "%JING_CP%" -c ..\src\schemas\xspec.rnc ..\tutorial\*.xspec ..\tutorial\schematron\*.xspec
        call :verify_retval 0
    ) else (
        call :skip "Schema validation for tutorial skipped"
    )

    call :teardown
endlocal

setlocal
    call :setup "Schema detects no error in known good tests"

    if defined JING_CP (
        call :run java -jar "%JING_CP%" -c ..\src\schemas\xspec.rnc catalog\*.xspec schematron\*-import.xspec schematron\*-in.xspec
        call :verify_retval 0
    ) else (
        call :skip "Schema validation for known good tests skipped"
    )

    call :teardown
endlocal

setlocal
    call :setup "Ant for XSLT with saxon.custom.options"

    rem Test with a space in file name
    set "SAXON_CONFIG=%WORK_DIR%\saxon config.xml"

    if defined ANT_VERSION (
        call :copy saxon-custom-options\config.xml "%SAXON_CONFIG%"
        
        call :run ant -buildfile "%CD%\..\build.xml" -Dxspec.xml="%CD%\saxon-custom-options\test.xspec" -lib "%SAXON_CP%" -Dsaxon.custom.options="-config:""%SAXON_CONFIG%"" -t"
        call :verify_retval 0
        call :verify_line  * x "     [xslt] passed: 1 / pending: 0 / failed: 0 / total: 1"
        call :verify_line -2 x "BUILD SUCCESSFUL"

        rem Verify '-t'
        call :verify_line  * r "     \[java\] Memory used:"
    ) else (
        call :skip "test for XSLT Ant with saxon.custom.options skipped"
    )

    call :teardown
endlocal

setlocal
    call :setup "Ant for XQuery with saxon.custom.options"

    rem Test with a space in file name
    set "SAXON_CONFIG=%WORK_DIR%\saxon config.xml"

    if defined ANT_VERSION (
        call :copy saxon-custom-options\config.xml "%SAXON_CONFIG%"
        
        call :run ant -buildfile "%CD%\..\build.xml" -Dxspec.xml="%CD%\saxon-custom-options\test.xspec" -lib "%SAXON_CP%" -Dsaxon.custom.options="-config:""%SAXON_CONFIG%"" -t" -Dtest.type=q
        call :verify_retval 0
        call :verify_line  * x "     [xslt] passed: 1 / pending: 0 / failed: 0 / total: 1"
        call :verify_line -2 x "BUILD SUCCESSFUL"

        rem Verify '-t'
        call :verify_line  * r "     \[java\] Memory used:"
    ) else (
        call :skip "test for XQuery Ant with saxon.custom.options skipped"
    )

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat for XSLT with SAXON_CUSTOM_OPTIONS"

    rem Test with a space in file name
    set "SAXON_CONFIG=%WORK_DIR%\saxon config.xml"
    call :copy saxon-custom-options\config.xml "%SAXON_CONFIG%"
    
    set "SAXON_CUSTOM_OPTIONS=-config:"%SAXON_CONFIG%" -t"
    call :run ..\bin\xspec.bat saxon-custom-options\test.xspec
    call :verify_retval 0
    call :verify_line -3 x "passed: 1 / pending: 0 / failed: 0 / total: 1"

    rem Verify '-t'
    call :verify_line  * r "Memory used:"

    call :teardown
endlocal

setlocal
    call :setup "invoking xspec.bat for XQuery with SAXON_CUSTOM_OPTIONS"

    rem Test with a space in file name
    set "SAXON_CONFIG=%WORK_DIR%\saxon config.xml"
    call :copy saxon-custom-options\config.xml "%SAXON_CONFIG%"
    
    set "SAXON_CUSTOM_OPTIONS=-config:"%SAXON_CONFIG%" -t"
    call :run ..\bin\xspec.bat -q saxon-custom-options\test.xspec
    call :verify_retval 0
    call :verify_line -3 x "passed: 1 / pending: 0 / failed: 0 / total: 1"

    rem Verify '-t'
    call :verify_line  * r "Memory used:"

    call :teardown
endlocal

setlocal
    call :setup "Ant for XSLT with JUnit creates report files"

    if defined ANT_VERSION (
        call :run ant -buildfile "%CD%\..\build.xml" -Dxspec.xml="%CD%\..\tutorial\escape-for-regex.xspec" -lib "%SAXON_CP%" -Dxspec.junit.enabled=true
        call :verify_retval 1
        call :verify_line  * x "     [xslt] passed: 5 / pending: 0 / failed: 1 / total: 6"
        call :verify_line -4 x "BUILD FAILED"

        rem XML report file
        call :verify_exist ..\tutorial\xspec\escape-for-regex-result.xml

        rem HTML report file
        call :verify_exist ..\tutorial\xspec\escape-for-regex-result.html

        rem JUnit report file
        call :verify_exist ..\tutorial\xspec\escape-for-regex-junit.xml
    ) else (
        call :skip "test for XSLT Ant with JUnit skipped"
    )

    call :teardown
endlocal

setlocal
    call :setup "Import order with xspec.bat #185"

    rem Make the line numbers predictable by providing an existing output dir
    set "TEST_DIR=%WORK_DIR%"

    call :run ..\bin\xspec.bat xspec-185\import-1.xspec
    call :verify_retval 0
    call :verify_line  5 x "Scenario 1-1"
    call :verify_line  6 x "Scenario 1-2"
    call :verify_line  7 x "Scenario 1-3"
    call :verify_line  8 x "Scenario 2a-1"
    call :verify_line  9 x "Scenario 2a-2"
    call :verify_line 10 x "Scenario 2b-1"
    call :verify_line 11 x "Scenario 2b-2"
    call :verify_line 12 x "Scenario 3"
    call :verify_line 13 x "Formatting Report..."

    call :teardown
endlocal

setlocal
    call :setup "Import order with Ant #185"

    set "ANT_LOG=%WORK_DIR%\ant.log"

    if defined ANT_VERSION (
        call :run ant -buildfile "%CD%\..\build.xml" -Dxspec.xml="%CD%\xspec-185\import-1.xspec" -lib "%SAXON_CP%" -logfile "%ANT_LOG%"
        call :verify_retval 0

        call :run find " Scenario " "%ANT_LOG%"
        call :verify_line_count 9
        call :verify_line  2 x "     [java] Scenario 1-1"
        call :verify_line  3 x "     [java] Scenario 1-2"
        call :verify_line  4 x "     [java] Scenario 1-3"
        call :verify_line  5 x "     [java] Scenario 2a-1"
        call :verify_line  6 x "     [java] Scenario 2a-2"
        call :verify_line  7 x "     [java] Scenario 2b-1"
        call :verify_line  8 x "     [java] Scenario 2b-2"
        call :verify_line  9 x "     [java] Scenario 3"
    ) else (
        call :skip "Import order with Ant #185"
    )

    call :teardown
endlocal
