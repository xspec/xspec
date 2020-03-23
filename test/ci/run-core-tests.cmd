echo Execute Bats unit tests
call test\run-bats.cmd || goto :EOF

echo Execute XSpec unit tests
call test\run-xspec-tests-ant.cmd -silent || goto :EOF

echo Execute XSpec end-to-end tests
call test\end-to-end\run-e2e-tests.cmd -silent || goto :EOF
