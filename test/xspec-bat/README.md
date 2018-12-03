* `stub.cmd` contains test driver
* `collection.cmd` contains actual tests

1. Just run `..\xspec-bat.cmd`.
1. `..\xspec-bat.cmd` merges `stub.cmd` and `collection.cmd` into a temporary batch file (`..\xspec-bat~TEMP~.cmd`).
1. `..\xspec-bat~TEMP~.cmd` is executed.
