* `stub.cmd` contains test driver
* `collection.xml` contains actual tests. Each `<case>` holds a test case written in ordinary Windows batch script.
* `collection.xsd` helps writing `collection.xml`. (It provides default `xml:space=preserve` in particular). Nothing to do with actual tests.
* `generate.xsl` transforms `collection.xml` into a batch script

1. Just run `..\run-bats.cmd`.
1. `..\run-bats.cmd` executes `generate.xsl` to transform `collection.xml` into a batch script.
1. `..\run-bats.cmd` merges `stub.cmd` and the generated batch script into a temporary batch file (`..\run-bats~TEMP~.cmd`).
1. `..\run-bats.cmd` executes `..\run-bats~TEMP~.cmd`.
