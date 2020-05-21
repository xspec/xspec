echo Maven package

setlocal

if "%DO_MAVEN_PACKAGE%"=="true" (
    if "%GITHUB_ACTIONS%"=="true" (
        rem Propagate the project version as an environment variable to any actions running next in a job
        for /f %%I in ('call mvn help:evaluate --quiet "-Dexpression=project.version" -DforceStdout') do (
            echo ::set-env name=MAVEN_PACKAGE_VERSION::%%I
        )
    )

    call mvn package -P release %*
) else (
    echo Skip Maven package
)
