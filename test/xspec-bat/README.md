* `stub.cmd` contains test driver
* `collection.xml` contains actual tests. Each `<case>` holds a test case written in ordinary Windows batch script.
* `collection.xsd` helps writing `collection.xml`. (It provides default `xml:space=preserve` in particular). Nothing to do with actual tests.
* `generate.xsl` transforms `collection.xml` into a batch script

1. Just run `..\xspec-bat.cmd`.
1. `..\xspec-bat.cmd` executes `generate.xsl` to transform `collection.xml` into a batch script.
1. `..\xspec-bat.cmd` merges `stub.cmd` and the generated batch script into a temporary batch file (`..\xspec-bat~TEMP~.cmd`).
1. `..\xspec-bat.cmd` executes `..\xspec-bat~TEMP~.cmd`.
