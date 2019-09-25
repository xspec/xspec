git status --porcelain | %SYSTEMROOT%\system32\find /v ""
if errorlevel 1 (
  verify > NUL
) else (
  verify other 2> NUL
)
