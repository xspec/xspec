## find-examples

Details are unknown ([discussion](https://groups.google.com/d/msg/xspec-users/V8kWLyxjj80/gtw-7ubLRw4J)). 

`find-examples.xsl` *seems* to work as follows:
1. Receives an XML document as defined by `find-examples.rnc`.
1. Based on the received document, collects a set of XML documents.
1. Generates a boilerplate XSpec document which tests the collected documents.

For example, if you run `java -jar saxon.jar -s:find-examples.xml -xsl:find-examples.xsl`, you'll get this XSpec document:
```xml
<?xml version="1.0" encoding="ASCII"?>
<x:description xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:x="http://www.jenitennison.com/xslt/xspec">
   <x:scenario label="when processing a my-element-to-be-tested element">
      <x:scenario label="with the content model (@my-decimal-attribute{xs:decimal})">
         <x:context select="/my-topmost-element/my-element-to-be-tested"
                    href=".../misc/find-examples/docs/doc1.xml"/>
         <x:expect label="it should ...">
            <my-element-to-be-tested my-decimal-attribute="3.14">...</my-element-to-be-tested>
         </x:expect>
      </x:scenario>
   </x:scenario>
   <x:scenario label="when processing a my-processing-instruction-to-be-tested PI">
      <x:scenario label="with content like (@my-pseudo-attribute)">
         <x:context select="/my-topmost-element/processing-instruction(my-processing-instruction-to-be-tested)"
                    href=".../misc/find-examples/docs/doc2.xml"/>
         <x:expect label="it should ..."><?my-processing-instruction-to-be-tested my-pseudo-attribute="my-value"?></x:expect>
      </x:scenario>
   </x:scenario>
</x:description>
```
