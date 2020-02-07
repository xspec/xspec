if exist "%SYSTEMROOT%\system32\tar.exe" (
    "%SYSTEMROOT%\system32\tar.exe" -xf %1 -C %2
) else (
    7z x %1 -o%2 -y
)
