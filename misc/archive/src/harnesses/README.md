This page archives the instructions for the XSpec test harnesses that use XProc 1 with Saxon or BaseX. These harnesses worked as of XSpec v4.0.3 but are no longer being tested or supported.

## Run an XSpec test with XProc version 1 and Saxon

As an example, this description uses [XML Calabash 1](https://xmlcalabash.com/archive-1.x/) with the Saxon XProc harness ([for XSLT](https://github.com/xspec/xspec/blob/main/misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc) or [for XQuery](https://github.com/xspec/xspec/blob/main/misc/archive/src/harnesses/saxon/saxon-xquery-harness.xproc)). Harnesses for BaseX are also [available](https://github.com/xspec/xspec/tree/main/misc/archive/src/harnesses).

1. Download the zip file of [XML Calabash 1 latest release](https://github.com/ndw/xmlcalabash1/releases) and unzip it to a local path (e.g., `/tmp/xmlcalabash` for Linux/macOS or `C:\xmlcalabash` for Windows). Make sure you download the zip file because libraries are required (that is, using only the jar file won't work). XML Calabash version 1.1.27-99 is used here.

1. Make sure Java is installed, e.g.:

   ```
   java -version
   ```

1. Make sure XSpec is available in a local path (e.g., `/tmp/xspec` for Linux/macOS or `C:\xspec` for Windows).

1. Navigate to your XSpec directory.

1. Run an XSpec test for XSLT as follows:

   For Linux/macOS:

   ```bash
   java -jar /tmp/xmlcalabash/xmlcalabash-1.2.5-99.jar \
        -i source=tutorial/escape-for-regex.xspec \
        -o result=tutorial/escape-for-regex-result.html \
        -p xspec-home=file:/tmp/xspec/ \
        misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc
   ```

   For Windows:

   ```winbatch
   java -jar C:\xmlcalabash\xmlcalabash-1.2.5-99.jar ^
        -i source=tutorial/escape-for-regex.xspec ^
        -o result=tutorial/escape-for-regex-result.html ^
        -p xspec-home=file:///C:/xspec/ ^
        misc\archive\src\harnesses\saxon\saxon-xslt-harness.xproc
   ```

   where:
   - `-jar` is the XML Calabash jar file
   - `-i source` is the input port with the XSpec test to be executed
   - `-o result` is the output port where the HTML report will be stored
   - `-p xspec-home` is the absolute URI of the XSpec installation
   - `saxon-xslt-harness.xproc` is the Saxon XProc harness for XSLT

   The output result from the command line may look like this:

   ```console
   INFO : misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc:41:46:Testing with SAXON HE 9.9.1.2
   INFO : misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc:41:46:No escaping
   INFO : misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc:41:46:Must not be escaped at all
   INFO : misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc:41:46:Test simple patterns
   INFO : misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc:41:46:..When encountering parentheses
   INFO : misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc:41:46:escape them.
   INFO : misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc:41:46:..When encountering a whitespace character class
   INFO : misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc:41:46:escape the backslash
   INFO : misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc:41:46:result should have one more character than source
   INFO : misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc:41:46:When processing a list of phrases
   INFO : misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc:41:46:All phrase elements should remain
   INFO : misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc:41:46:Strings should be escaped and status attributes should be added
   INFO : misc/archive/src/harnesses/saxon/saxon-xslt-harness.xproc:41:46: FAILED
   INFO : misc/archive/src/harnesses/harness-lib.xpl:267:45:passed: 5 / pending: 0 / failed: 1 / total: 6
   ```

   The HTML report file is created in the location specified by `-o result=`.

1. Run an XSpec test for XQuery as follows:

   Make sure to use `saxon-xquery-harness.xproc`.

   For Linux/macOS:

   ```bash
   java -jar /tmp/xmlcalabash/xmlcalabash-1.2.5-99.jar \
        -i source=tutorial/xquery-tutorial.xspec \
        -o result=tutorial/xquery-tutorial-result.html \
        -p xspec-home=file:/tmp/xspec/ \
        misc/archive/src/harnesses/saxon/saxon-xquery-harness.xproc
   ```

   For Windows:

   ```winbatch
   java -jar C:\xmlcalabash\xmlcalabash-1.2.5-99.jar ^
        -i source=tutorial/xquery-tutorial.xspec ^
        -o result=tutorial/xquery-tutorial-result.html ^
        -p xspec-home=file:///C:/xspec/ ^
        misc\archive\src\harnesses\saxon\saxon-xquery-harness.xproc
   ```

   Output:

   ```console
   INFO : misc/archive/src/harnesses/harness-lib.xpl:267:45:passed: 1 / pending: 0 / failed: 0 / total: 1
   ```

## Run an XSpec test with XProc version 1 and BaseX

The XSpec distribution has dedicated XProc 1 harnesses for BaseX, described next.

### Dependencies

[XML Calabash 1](https://www.xmlcalabash.com/archive-1.x/) is used here as an example; follow [these instructions](https://github.com/xspec/xspec/wiki/Running-with-XProc#run-an-xspec-test-with-xproc-version-1) to set up XML Calabash and store the XML Calabash jar file in a local directory (e.g. `~/xml/xmlcalabash` for Linux/macOS or `C:\xmlcalabash` for Windows).

### Run an XSpec test for XQuery with BaseX standalone

1. Download the [ZIP package of BaseX](https://basex.org/download/) and extract it to a local directory (e.g. `~/xml/basex` for Linux/macOS or `C:\basex` for Windows).

1. Make sure a required version of [Java Runtime Environment](Requirements#java) is installed, e.g.:

   ```console
   java -version
   ```

1. Make sure XSpec is available in a local path (e.g. `~/xml/xspec` for Linux/macOS or `C:\xspec` for Windows).
1. Navigate to your XSpec directory.
1. Run an XSpec test for XQuery as follows:

   For Linux/macOS:

   ```bash
   java -jar ~/xml/xmlcalabash/xmlcalabash-1.2.5-99.jar \
        -i source=tutorial/xquery-tutorial.xspec \
        -p xspec-home=file:/home/myself/xml/xspec/ \
        -p basex-jar=/home/myself/xml/basex/BaseX.jar \
        -o result=tutorial/xquery-tutorial-result.html \
        misc/archive/src/harnesses/basex/basex-standalone-xquery-harness.xproc
   ```

   For Windows:

   ```winbatch
   java -jar C:\xmlcalabash\xmlcalabash-1.2.5-99.jar ^
        -i source=tutorial/xquery-tutorial.xspec ^
        -p xspec-home=file:///C:/xspec/ ^
        -p basex-jar=C:\basex\BaseX.jar ^
        -o result=tutorial/xquery-tutorial-result.html ^
        misc\archive\src\harnesses\basex\basex-standalone-xquery-harness.xproc
   ```

   where:

   - `-jar` is the XML Calabash jar file
   - `-i source` is the input port with the XSpec test for XQuery to be executed
   - `-o result` is the output port where the HTML report will be stored
   - `-p xspec-home` is the absolute URI of the XSpec installation
   - `-p basex-jar` is the jar file of BaseX
   - `basex-standalone-xquery-harness.xproc` is the XProc harness for BaseX standalone

The output result from the command line may look like this:

```console
INFO : misc/archive/src/harnesses/harness-lib.xpl:267:45:passed: 1 / pending: 0 / failed: 0 / total: 1
```

And the HTML report file is created in the location specified by `-o result=`.

### Run an XSpec test for XQuery with BaseX server

To run XSpec with BaseX server using its RESTful API, run XProc just like [the steps with BaseX standalone](#run-an-xspec-test-for-xquery-with-basex-standalone) but with these differences:

- Instead of the `basex-jar` parameter, provide `endpoint`, `username`, `password` and `auth-method`
- Instead of the `basex-standalone-xquery-harness.xproc` harness, use `basex-server-xquery-harness.xproc`

For Linux/macOS:

```bash
java -jar ~/xml/xmlcalabash/xmlcalabash-1.2.5-99.jar \
     -i source=tutorial/xquery-tutorial.xspec \
     -p xspec-home=file:/home/myself/xml/xspec/ \
     -p endpoint=http://localhost:8984/rest \
     -p username=admin \
     -p password=admin \
     -p auth-method=Basic \
     -o result=tutorial/xquery-tutorial-result.html \
     misc/archive/src/harnesses/basex/basex-server-xquery-harness.xproc
```

For Windows:

```winbatch
java -jar C:\xmlcalabash\xmlcalabash-1.2.5-99.jar ^
     -i source=tutorial/xquery-tutorial.xspec ^
     -p xspec-home=file:///C:/xspec/ ^
     -p endpoint=http://localhost:8984/rest ^
     -p username=admin ^
     -p password=admin ^
     -p auth-method=Basic ^
     -o result=tutorial/xquery-tutorial-result.html ^
     misc\archive\src\harnesses\basex\basex-server-xquery-harness.xproc
```
(Note: For BaseX 10.0 and later, specify `localhost:8080` instead of `localhost:8984` in the commands above.)