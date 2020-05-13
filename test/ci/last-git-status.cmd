echo Check git status

setlocal

git status --porcelain 2>&1 | "%SYSTEMROOT%\system32\find" /v ""
if errorlevel 1 (
  verify > NUL
) else (
  verify other 2> NUL
)
