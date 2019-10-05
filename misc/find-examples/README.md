## find-examples

Details are unknown ([discussion](https://groups.google.com/d/msg/xspec-users/V8kWLyxjj80/gtw-7ubLRw4J)). 

`find-examples.xsl` *seems* to work as follows:
1. Receives an XML document as defined by `find-examples.rnc`.
1. Based on the received document, collects a set of XML documents.
1. Generates a boilerplate XSpec document which tests the collected documents.

For example, if you run `java -jar saxon.jar -s:find-examples.xml -xsl:find-examples.xsl`, you'll get an XSpec document.
