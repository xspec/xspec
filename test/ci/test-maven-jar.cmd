echo Test Maven jar

setlocal

if not "%DO_MAVEN_PACKAGE%"=="true" (
    echo Skip Testing Maven jar
    exit /b
)

for /f %%I in ('call mvn help:evaluate --quiet "-Dexpression=project.version" -DforceStdout') do (
    set "MAVEN_PACKAGE_VERSION=%%I"
)

if "%GITHUB_ACTIONS%"=="true" (
    rem Propagate the project version as an environment variable to any actions running next in a job
    echo ::set-env name=MAVEN_PACKAGE_VERSION::%MAVEN_PACKAGE_VERSION%
)

set "XSPEC_MAVEN_JAR=%~dp0..\..\target\xspec-%MAVEN_PACKAGE_VERSION%.jar"

call ant ^
    -buildfile "%~dp0build_test-maven-jar.xml" ^
    -lib "%SAXON_JAR%" ^
    -lib "%XSPEC_MAVEN_JAR%" ^
    %*
