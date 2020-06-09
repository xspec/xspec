echo Test Maven jar

setlocal

if not defined MAVEN_PACKAGE_VERSION (
    echo Skip Testing Maven jar
    exit /b
)

rem Coverage HTML report file
set "ACTUAL_REPORT_DIR=%CD%\test\end-to-end\cases\actual__\stylesheet"
if not exist "%ACTUAL_REPORT_DIR%" mkdir "%ACTUAL_REPORT_DIR%" || exit /b
set "COVERAGE_HTML=%ACTUAL_REPORT_DIR%\coverage-tutorial-coverage.html"
del "%COVERAGE_HTML%" || exit /b

rem Replace *.class...
echo Delete *.class
del /s java\*.class || exit /b

rem ...with jar
set "SAXON_CP=%SAXON_JAR%;target\xspec-%MAVEN_PACKAGE_VERSION%.jar"

rem Run
call bin\xspec.bat -c test\end-to-end\cases\coverage-tutorial.xspec ^
    || exit /b

rem Verify Coverage HTML report
java -jar "%SAXON_JAR%" ^
    -s:"%COVERAGE_HTML%" ^
    -xsl:test\end-to-end\processor\coverage\compare.xsl ^
    EXPECTED-DOC-URI="file:///%ACTUAL_REPORT_DIR:\=/%/../../expected/stylesheet/coverage-tutorial-coverage.html"
