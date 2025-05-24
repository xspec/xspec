## Contents

- [Introduction](#introduction)
- [Simple suite](#simple-suite)
- [Simple scenario](#simple-scenario)
- [SUT](#sut)
- [Variables](#variables)
- [Variable value](#variable-value)
- [Variables scope](#variables-scope)
- [run-as=external](#run-asexternal)
- [Scenario-level x:param scope](#scenario-level-xparam-scope)
- [result-type attribute](#result-type-attribute)

## Introduction

This page is an overview of how XSpec test suites are compiled into XSLT and XQuery. It shows examples of simple test suites along with their XSpec-generated stylesheets and queries. Some of these examples are in the [test directory](https://github.com/xspec/xspec/tree/master/test).

The generated stylesheets and queries are not shown in their entirety. In particular, the code generating parts of the final report has been removed, except in examples specifically intended to show how this is done. The root elements of test suites are omitted, and indentation and comments have been added where appropriate.

The goal is to make the compilation phase clearer, mostly for development purposes.

Those examples could be the base for test cases, too, developed as an automated test suite.

## Simple suite

Show the structure of a compiled test suite, both in XSLT and XQuery.

### Test suite

[`compilation-simple-suite.xspec`](compilation-simple-suite.xspec)

```xml
<x:description
   xmlns:my="http://example.org/ns/my"
   xmlns:x="http://www.jenitennison.com/xslt/xspec"
   stylesheet="compilation-simple-suite.xsl"
   query="http://example.org/ns/my"
   query-at="compilation-simple-suite.xqm">

   <x:scenario label="scenario">
      <x:call function="my:f"/>
      <x:expect label="expectations" test="$x:result = 1"/>
   </x:scenario>

</x:description>
```

### Compiled stylesheet

```xml
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">
   <!-- the tested stylesheet -->
   <xsl:import href=".../compilation-simple-suite.xsl"/>
   <!-- XSpec library modules providing tools -->
   <xsl:include href="..."/>
   ...
   <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}stylesheet-uri"
                 as="Q{http://www.w3.org/2001/XMLSchema}anyURI">.../compilation-simple-suite.xsl</xsl:variable>
   <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}xspec-uri"
                 as="Q{http://www.w3.org/2001/XMLSchema}anyURI">.../compilation-simple-suite.xspec</xsl:variable>
   <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}is-external"
                 as="Q{http://www.w3.org/2001/XMLSchema}boolean"
                 select="false()"/>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}thread-aware"
                 as="Q{http://www.w3.org/2001/XMLSchema}boolean"
                 select="(system-property('Q{http://www.w3.org/1999/XSL/Transform}product-name') eq 'SAXON') and starts-with(system-property('Q{http://www.w3.org/1999/XSL/Transform}product-version'), 'EE ')"
                 static="yes"/>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}logical-processor-count"
                 as="Q{http://www.w3.org/2001/XMLSchema}integer"
                 use-when="$Q{urn:x-xspec:compile:impl}thread-aware"
                 select="Q{java:java.lang.Runtime}getRuntime() => Q{java:java.lang.Runtime}availableProcessors()"/>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}thread-count"
                 as="Q{http://www.w3.org/2001/XMLSchema}integer"
                 select="1"
                 use-when="$Q{urn:x-xspec:compile:impl}thread-aware => not()"/>
   <!-- the main template to run the suite -->
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}main"
                 as="empty-sequence()">
      <xsl:context-item use="absent"/>
      <!-- info message -->
      <xsl:message>
         <xsl:text>Testing with XSpec v... and </xsl:text>
         <xsl:value-of select="system-property('Q{http://www.w3.org/1999/XSL/Transform}product-name')"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="system-property('Q{http://www.w3.org/1999/XSL/Transform}product-version')"/>
      </xsl:message>
      <!-- set up the result document (the report) -->
      <xsl:result-document format="Q{{http://www.jenitennison.com/xslt/xspec}}xml-report-serialization-parameters">
         <xsl:element name="report" namespace="http://www.jenitennison.com/xslt/xspec">
            <xsl:attribute name="xspec" namespace="">.../compilation-simple-suite.xspec</xsl:attribute>
            <xsl:attribute name="stylesheet" namespace="">.../compilation-simple-suite.xsl</xsl:attribute>
            <xsl:attribute name="date" namespace="" select="current-dateTime()"/>
            <!-- invoke each compiled top-level x:scenario -->
            <xsl:for-each select="1 to 1">
               <xsl:choose>
                  <xsl:when test=". eq 1">
                     <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:message terminate="yes">ERROR: Unhandled scenario invocation</xsl:message>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </xsl:element>
      </xsl:result-document>
   </xsl:template>

   <!-- generated from the x:scenario element -->
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1"
                 as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
      ...
      <!-- invoke each compiled x:expect -->
      <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-expect1">
         ...
      </xsl:call-template>
   </xsl:template>

   <!-- generated from the x:expect element -->
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-expect1"
                 as="element(Q{http://www.jenitennison.com/xslt/xspec}test)">
      ...
   </xsl:template>

</xsl:stylesheet>
```

### Compiled query

```xquery
xquery version "3.1";

(: the tested library module :)
import module "http://example.org/ns/my"
at ".../compilation-simple-suite.xqm";

(: XSpec library modules providing tools :)
import module "..."
at "...";
...

declare namespace my = "http://example.org/ns/my";
declare namespace x = "http://www.jenitennison.com/xslt/xspec";
declare option Q{http://www.w3.org/2010/xslt-xquery-serialization}parameter-document ".../xml-report-serialization-parameters.xml";
declare variable $Q{http://www.jenitennison.com/xslt/xspec}xspec-uri as xs:anyURI := (
xs:anyURI(".../compilation-simple-suite.xspec")
);

(: generated from the x:scenario element :)
declare function local:scenario1(
) as element(Q{http://www.jenitennison.com/xslt/xspec}scenario)
{
...
(: invoke each compiled x:expect :)
let $local:returned-from-scenario1-expect1 := local:scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result
)
return (
...
$local:returned-from-scenario1-expect1
)
...
};

(: generated from the x:expect element :)
declare function local:scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result as item()*
) as element(Q{http://www.jenitennison.com/xslt/xspec}test)
{
...
};

(: the query body of this main module, to run the suite :)
(: set up the result document (the report) :)
document {
element { QName('http://www.jenitennison.com/xslt/xspec', 'report') } {
attribute { QName('', 'xspec') } { '.../compilation-simple-suite.xspec' },
attribute { QName('', 'query') } { 'http://example.org/ns/my' },
attribute { QName('', 'query-at') } { '.../compilation-simple-suite.xqm' },
attribute { QName('', 'date') } { current-dateTime() },
(: invoke each compiled top-level x:scenario :)
let $local:returned-from-scenario1 := local:scenario1(
)
return (
$local:returned-from-scenario1
)
}
}
```

## Simple scenario

Show the structure of a compiled scenario, both in XSLT and
XQuery. The general idea is to generate a template for the
scenario (or a function in XQuery), that calls the [SUT](#sut) (or System Under Test) and puts
the result in a variable, `$x:result`. A separate template (or function in
XQuery) is generated for each expectation, and those templates (or
functions) are called from the first one, in sequence, with the
result as parameter.

### Test suite

[`compilation-simple-suite.xspec`](compilation-simple-suite.xspec)

```xml
<x:scenario label="scenario">
   <x:call function="my:f"/>
   <x:expect label="expectations" test="$x:result = 1"/>
</x:scenario>
```

### Compiled stylesheet

```xml
<!-- generated from the x:scenario element -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1"
              as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
   <xsl:context-item use="absent"/>
   <xsl:message>scenario</xsl:message>
   <xsl:element name="scenario" namespace="http://www.jenitennison.com/xslt/xspec">
      <xsl:attribute name="id" namespace="">scenario1</xsl:attribute>
      <xsl:attribute name="xspec" namespace="">.../compilation-simple-suite.xspec</xsl:attribute>
      <xsl:element name="label" namespace="http://www.jenitennison.com/xslt/xspec">
         <xsl:text>scenario</xsl:text>
      </xsl:element>
      <xsl:element name="input-wrap" namespace="">
         <xsl:element name="x:call" namespace="http://www.jenitennison.com/xslt/xspec">
            <xsl:namespace name="my">http://example.org/ns/my</xsl:namespace>
            <xsl:attribute name="function" namespace="">my:f</xsl:attribute>
         </xsl:element>
      </xsl:element>
      <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
         <xsl:sequence xmlns:my="http://example.org/ns/my"
                       xmlns:x="http://www.jenitennison.com/xslt/xspec"
                       select="Q{http://example.org/ns/my}f()"/>
      </xsl:variable>

      ... generate scenario data in the report ...

      <!-- invoke each compiled x:expect -->
      <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-expect1">
         <xsl:with-param name="Q{http://www.jenitennison.com/xslt/xspec}result" select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
      </xsl:call-template>
   </xsl:element>
</xsl:template>

<!-- generated from the x:expect element -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-expect1"
              as="element(Q{http://www.jenitennison.com/xslt/xspec}test)">
   <xsl:context-item use="absent"/>
   <xsl:param name="Q{http://www.jenitennison.com/xslt/xspec}result"
              as="item()*"
              required="yes"/>
   <xsl:message>expectations</xsl:message>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}expect-..." select="()"><!--expected result--></xsl:variable>
   <!-- flag if @result-type is present but $x:result is not the right type -->
   <xsl:variable name="Q{urn:x-xspec:compile:impl}result-type-mismatch"
                 as="Q{http://www.w3.org/2001/XMLSchema}boolean"
                 select="false()"/>
   <!-- wrap $x:result into a document node if possible -->
   <xsl:variable name="Q{urn:x-xspec:compile:impl}test-items" as="item()*">
      <xsl:choose>
         <xsl:when test="exists($Q{http://www.jenitennison.com/xslt/xspec}result) and Q{http://www.jenitennison.com/xslt/xspec}wrappable-sequence($Q{http://www.jenitennison.com/xslt/xspec}result)">
            <xsl:sequence select="Q{http://www.jenitennison.com/xslt/xspec}wrap-nodes($Q{http://www.jenitennison.com/xslt/xspec}result)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <!-- evaluate the predicate with $x:result (or its wrapper document node) as context item if it is a single item; if not, evaluate the predicate without context item -->
   <xsl:variable name="Q{urn:x-xspec:compile:impl}test-result" as="item()*">
      <xsl:choose>
         <xsl:when test="$Q{urn:x-xspec:compile:impl}result-type-mismatch"><!--In case of data type mismatch, do not process @test--></xsl:when>
         <xsl:when test="count($Q{urn:x-xspec:compile:impl}test-items) eq 1">
            <xsl:for-each select="$Q{urn:x-xspec:compile:impl}test-items">
               <xsl:sequence xmlns:my="http://example.org/ns/my"
                             xmlns:x="http://www.jenitennison.com/xslt/xspec"
                             select="$x:result = 1"
                             version="3"/>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence xmlns:my="http://example.org/ns/my"
                          xmlns:x="http://www.jenitennison.com/xslt/xspec"
                          select="$x:result = 1"
                          version="3"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}boolean-test"
                 as="Q{http://www.w3.org/2001/XMLSchema}boolean"
                 select="$Q{urn:x-xspec:compile:impl}test-result instance of Q{http://www.w3.org/2001/XMLSchema}boolean"/>
   <!-- did the test pass? -->
   <xsl:variable name="Q{urn:x-xspec:compile:impl}successful"
                 as="Q{http://www.w3.org/2001/XMLSchema}boolean">
      <xsl:choose>
         <xsl:when test="$Q{urn:x-xspec:compile:impl}result-type-mismatch">
            <xsl:sequence select="false()"/>
         </xsl:when>
         <xsl:when test="$Q{urn:x-xspec:compile:impl}boolean-test">
            <xsl:sequence select="$Q{urn:x-xspec:compile:impl}test-result => boolean()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">ERROR in x:expect ('scenario expectations'): Non-boolean @test must be accompanied by @as, @href, @select, or child node.</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   ... generate test result in the report ...
</xsl:template>
```

### Compiled query

```xquery
(: generated from the x:scenario element :)
declare function local:scenario1(
) as element(Q{http://www.jenitennison.com/xslt/xspec}scenario)
{
... generate scenario data in the report ...

let $Q{http://www.jenitennison.com/xslt/xspec}result as item()* := (
Q{http://example.org/ns/my}f()
)
let $local:actual-result-report := Q{urn:x-xspec:common:report-sequence}report-sequence($Q{http://www.jenitennison.com/xslt/xspec}result, 'result')

(: invoke each compiled x:expect :)
let $local:returned-from-scenario1-expect1 := local:scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result
)
return (
$local:actual-result-report,
$local:returned-from-scenario1-expect1
)
...
};

(: generated from the x:expect element :)
declare function local:scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result as item()*
) as element(Q{http://www.jenitennison.com/xslt/xspec}test)
{
let $Q{urn:x-xspec:compile:impl}expect-... (: expected result :) := (
()
)
(: flag if @result-type is present but $x:result is not the right type :)
let $local:result-type-mismatch as xs:boolean := false()
let $local:test-items as item()* := $Q{http://www.jenitennison.com/xslt/xspec}result
let $local:test-result as item()* (: evaluate the predicate :) := (
if ($local:result-type-mismatch)
then ((: In case of data type mismatch, do not process @test :))
else $x:result = 1
)
let $local:boolean-test as xs:boolean := ($local:test-result instance of xs:boolean)
let $local:successful as xs:boolean (: did the test pass? :) := (
if ($local:result-type-mismatch)
then false()
else if ($local:boolean-test) then
boolean($local:test-result)
else
error((), 'ERROR in x:expect ('scenario expectations'): Non-boolean @test must be accompanied by @as, @href, @select, or child node.')
)
return
... generate test result in the report ...
};
```

## SUT

The SUT (or System Under Test) is the component tested in a
scenario. In XSpec, this is either an XSLT template (named or
rule) or an XPath function (written either in XSLT or XQuery).
Here, we use it to refer to the two ways to refer to the SUT
itself, as well as parameters to use for the current scenario:
`x:call` and `x:context` (so that's not strictly speaking
the SUT itself, but rather the way to "call" it for this
scenario).

`x:context` represents applying a template rule to a node (this is not
possible in XQuery), and corresponds naturally to
`xsl:apply-templates`. `x:call` represents a call either to a named
template or an XPath function.

Those examples show only what is related to the call of the SUT in
the template (or function) generated from the scenario (see the
section "[Simple scenario](#simple-scenario)").

### Test suite

- For function (XSLT and XQuery): [`compilation-sut_function.xspec`](compilation-sut_function.xspec)
- For template (only XSLT) [`compilation-sut_template.xspec`](compilation-sut_template.xspec)

```xml
<x:scenario label="call a function">
   <x:call function="my:f">
      <x:param select="'val1'"/>
      <x:param name="p2" as="element()">
         <val2/>
      </x:param>
   </x:call>
   <x:expect ... />
</x:scenario>

<x:scenario label="call a named template (without x:context)">
   <x:call template="t">
      <x:param name="p1" select="'val1'"/>
      <x:param name="p2">
         <val2/>
      </x:param>
   </x:call>
   <x:expect ... />
</x:scenario>

<x:scenario label="call a named template (with x:context)">
   <x:context>
      <elem/>
   </x:context>
   <x:call template="t">
      <x:param name="p1" select="'val1'"/>
   </x:call>
   <x:expect ... />
</x:scenario>

<x:scenario label="apply template rules on a node (with x:context)">
   <x:context>
      <elem/>
   </x:context>
   <x:expect ... />
</x:scenario>
```

### Compiled stylesheet

```xml
<!-- "call a function" scenario -->
<xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
   <xsl:variable xmlns:x="http://www.jenitennison.com/xslt/xspec"
                 xmlns:my="http://example.org/ns/my"
                 name="Q{urn:x-xspec:compile:impl}param-...1"
                 select="'val1'"/>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}param-...2-doc" as="document-node()">
      <xsl:document>
         <xsl:element name="val2" namespace="">
            <xsl:namespace name="my">http://example.org/ns/my</xsl:namespace>
            <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
         </xsl:element>
      </xsl:document>
   </xsl:variable>
   <xsl:variable xmlns:x="http://www.jenitennison.com/xslt/xspec"
                 xmlns:my="http://example.org/ns/my"
                 name="Q{urn:x-xspec:compile:impl}param-...2"
                 as="element()"
                 select="$Q{urn:x-xspec:compile:impl}param-...2-doc ! ( node() )"><!--$p2--></xsl:variable>
   <xsl:sequence xmlns:my="http://example.org/ns/my"
                 xmlns:x="http://www.jenitennison.com/xslt/xspec"
                 select="Q{http://example.org/ns/my}f($Q{urn:x-xspec:compile:impl}param-...1, $Q{urn:x-xspec:compile:impl}param-...2)"/>
</xsl:variable>

<!-- "call a named template (without x:context)" scenario -->
<xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
   <xsl:variable xmlns:x="http://www.jenitennison.com/xslt/xspec"
                 name="Q{urn:x-xspec:compile:impl}param-...1"
                 select="'val1'"><!--$p1--></xsl:variable>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}param-...2-doc" as="document-node()">
      <xsl:document>
         <xsl:element name="val2" namespace="">
            <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
         </xsl:element>
      </xsl:document>
   </xsl:variable>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}param-...2"
                 select="$Q{urn:x-xspec:compile:impl}param-...2-doc ! ( node() )"><!--$p2--></xsl:variable>
   <xsl:call-template name="Q{}t">
      <xsl:with-param xmlns:x="http://www.jenitennison.com/xslt/xspec"
                      name="Q{}p1"
                      select="$Q{urn:x-xspec:compile:impl}param-...1"/>
      <xsl:with-param xmlns:x="http://www.jenitennison.com/xslt/xspec"
                      name="Q{}p2"
                      select="$Q{urn:x-xspec:compile:impl}param-...2"/>
   </xsl:call-template>
</xsl:variable>

<!-- "call a named template (with x:context)" scenario -->
<xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
   <xsl:variable xmlns:x="http://www.jenitennison.com/xslt/xspec"
                 name="Q{urn:x-xspec:compile:impl}param-..."
                 select="'val1'"><!--$p1--></xsl:variable>
   <xsl:for-each select="$Q{http://www.jenitennison.com/xslt/xspec}context">
      <xsl:call-template name="Q{}t">
         <xsl:with-param xmlns:x="http://www.jenitennison.com/xslt/xspec"
                         name="Q{}p1"
                         select="$Q{urn:x-xspec:compile:impl}param-..."/>
      </xsl:call-template>
   </xsl:for-each>
</xsl:variable>

<!-- "apply template rules on a node (with x:context)" scenario -->
<xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
   <xsl:apply-templates select="$Q{http://www.jenitennison.com/xslt/xspec}context"/>
</xsl:variable>
```

### Compiled query

```xquery
let $Q{urn:x-xspec:compile:impl}param-...1 := (
'val1'
)
let $Q{urn:x-xspec:compile:impl}param-...2-doc as document-node() := (
document {
element { QName('', 'val2') } {
namespace { "my" } { 'http://example.org/ns/my' },
namespace { "x" } { 'http://www.jenitennison.com/xslt/xspec' }
}
}
)
let $Q{urn:x-xspec:compile:impl}param-...2 as element() (:$p2:) := (
$Q{urn:x-xspec:compile:impl}param-...2-doc ! ( node() )
)
let $Q{http://www.jenitennison.com/xslt/xspec}result as item()* := (
Q{http://example.org/ns/my}f($Q{urn:x-xspec:compile:impl}param-...1, $Q{urn:x-xspec:compile:impl}param-...2)
)
```

## Variables

The `x:variable` element in the XSpec namespace defines an XSpec variable. Any number of `x:variable` elements can occur as a child of `x:description` or `x:scenario`. In `x:scenario`, an `x:variable` element can occur before or after `x:context`, `x:call`, or `x:expect`. XSpec variables can be redefined locally, but names of global XSpec variables must be unique. XSpec variables can be referenced in XPath expressions, such as in `@select` and `@test` attributes.

The first example shows how an XSpec variable maps to an `xsl:variable` element in generated XSLT code or a `let` statement in generated XQuery code.

### Test suite

[`compilation-variables.xspec`](compilation-variables.xspec)

```xml
<x:scenario label="scenario">
   <x:variable name="myv:var" select="'value'"/>
   ...
   <x:expect .../>
</x:scenario>
```

### Compiled stylesheet

```xml
<!-- generated from the x:scenario element -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1"
              as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
   ...
   <!-- the generated variable -->
   <xsl:variable xmlns:my="http://example.org/ns/my"
                 xmlns:myv="http://example.org/ns/my/variable"
                 xmlns:x="http://www.jenitennison.com/xslt/xspec"
                 xmlns:xs="http://www.w3.org/2001/XMLSchema"
                 name="Q{http://example.org/ns/my/variable}var"
                 select="'value'"/>
   ...
   <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
      ... exercise the SUT ...
   </xsl:variable>
   ...
   <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-expect1">
      <xsl:with-param name="Q{http://www.jenitennison.com/xslt/xspec}result"
                      select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var"
                      select="$Q{http://example.org/ns/my/variable}var"/>
   </xsl:call-template>
</xsl:template>

<!-- generated from the x:expect element -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-expect1"
              as="element(Q{http://www.jenitennison.com/xslt/xspec}test)">
   ...
   <xsl:param name="Q{http://www.jenitennison.com/xslt/xspec}result"
              as="item()*"
              required="yes"/>
   <xsl:param name="Q{http://example.org/ns/my/variable}var"
              as="item()*"
              required="yes"/>
   ...
   <xsl:variable name="Q{urn:x-xspec:compile:impl}expect-..." select="..."><!--expected result--></xsl:variable>
   ...
   <!-- did the test pass? -->
   <xsl:variable name="Q{urn:x-xspec:compile:impl}successful"
                 as="Q{http://www.w3.org/2001/XMLSchema}boolean">
      ...
   </xsl:variable>
   ... generate test result in the report ...
</xsl:template>
```

### Compiled query

```xquery
(: generated from the x:scenario element :)
declare function local:scenario1(
) as element(Q{http://www.jenitennison.com/xslt/xspec}scenario)
{
(: the generated variable :)
let $Q{http://example.org/ns/my/variable}var := (
'value'
)
...
let $Q{http://www.jenitennison.com/xslt/xspec}result as item()* := (
... exercise the SUT ...
)
let $local:returned-from-scenario1-expect1 := local:scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result,
$Q{http://example.org/ns/my/variable}var
)
return (
...
$local:returned-from-scenario1-expect1
)
...
};

(: generated from the x:expect element :)
declare function local:scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result as item()*,
$Q{http://example.org/ns/my/variable}var as item()*
) as element(Q{http://www.jenitennison.com/xslt/xspec}test)
{
let $Q{urn:x-xspec:compile:impl}expect-... (: expected result :) := (
...
)
...
let $local:successful as xs:boolean (: did the test pass? :) := (
...
)
return
... generate test result in the report ...
};
```

## Variable value

Here is an example of three variables, one using `@select`, one
using content, and one using `@href`. The `@href` attribute is
to load a document from a file (relative to the test suite
document). As with `x:param`,
content and `@href` are mutually exclusive. The `@select` attribute can appear alone or in combination with either content or `@href`.

The resulting variables become accessible from the code generated
for the `x:scenario` and `x:expect` elements. See "[Variables scope](#variables-scope)"
below for details on how the generated stylesheet or query achieves
this accessibility.

### Test suite

[`compilation-variable-value.xspec`](compilation-variable-value.xspec)

```xml
<x:scenario label="scenario">
   <x:variable name="myv:select"  select="'value'"/>
   <x:variable name="myv:href"    href="test-data.xml"/>
   <x:variable name="myv:content" as="element()">
      <elem/>
   </x:variable>
   ...
</x:scenario>
```

### Compiled stylesheet

```xml
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1"
              as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
   ...

   <!-- $myv:select -->
   <xsl:variable xmlns:my="http://example.org/ns/my"
                 xmlns:myv="http://example.org/ns/my/variable"
                 xmlns:x="http://www.jenitennison.com/xslt/xspec"
                 xmlns:xs="http://www.w3.org/2001/XMLSchema"
                 name="Q{http://example.org/ns/my/variable}select"
                 select="'value'"/>

   <!-- $myv:href -->
   <xsl:variable name="Q{urn:x-xspec:compile:impl}variable-...-doc"
                 as="document-node()"
                 select="doc('.../test-data.xml')"/>
   <xsl:variable name="Q{http://example.org/ns/my/variable}href"
                 select="$Q{urn:x-xspec:compile:impl}variable-...-doc ! ( . )"/>

   <!-- $myv:content -->
   <xsl:variable name="Q{urn:x-xspec:compile:impl}variable-...-doc" as="document-node()">
      <xsl:document>
         <xsl:element name="elem" namespace="">
            <xsl:namespace name="my">http://example.org/ns/my</xsl:namespace>
            <xsl:namespace name="myv">http://example.org/ns/my/variable</xsl:namespace>
            <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
            <xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema</xsl:namespace>
         </xsl:element>
      </xsl:document>
   </xsl:variable>
   <xsl:variable xmlns:my="http://example.org/ns/my"
                 xmlns:myv="http://example.org/ns/my/variable"
                 xmlns:x="http://www.jenitennison.com/xslt/xspec"
                 xmlns:xs="http://www.w3.org/2001/XMLSchema"
                 name="Q{http://example.org/ns/my/variable}content"
                 as="element()"
                 select="$Q{urn:x-xspec:compile:impl}variable-...-doc ! ( node() )"/>

   ...
</xsl:template>
```

### Compiled query

```xquery
declare function local:scenario1(
) as element(Q{http://www.jenitennison.com/xslt/xspec}scenario)
{
...

(: $myv:select :)
let $Q{http://example.org/ns/my/variable}select := (
'value'
)

(: $myv:href :)
let $Q{urn:x-xspec:compile:impl}variable-...-doc as document-node() := (
doc('.../test-data.xml')
)
let $Q{http://example.org/ns/my/variable}href := (
$Q{urn:x-xspec:compile:impl}variable-...-doc ! ( . )
)

(: $myv:content :)
let $Q{urn:x-xspec:compile:impl}variable-...-doc as document-node() := (
document {
element { QName('', 'elem') } {
namespace { "my" } { 'http://example.org/ns/my' },
namespace { "myv" } { 'http://example.org/ns/my/variable' },
namespace { "x" } { 'http://www.jenitennison.com/xslt/xspec' },
namespace { "xs" } { 'http://www.w3.org/2001/XMLSchema' }
}
}
)
let $Q{http://example.org/ns/my/variable}content as element() := (
$Q{urn:x-xspec:compile:impl}variable-...-doc ! ( node() )
)

...
};
```

## Variables scope

In a given scenario, the variables in scope are:

- Local variables defined in that scenario
- Variables defined as children of an ancestor scenario
- Global variables defined as children of `x:description`

This example shows where variables are generated depending on their scope.
It is worth noting the first implementation of this was to generate
variables several times if needed, e.g., if they were in scope in
a scenario and expectations (see the revision r78, a revision before changed by [r79](https://groups.google.com/forum/#!topic/xspec-dev/K25fP9Zb--4), of this page
for an example). But this would lead to several evaluations of
the same thing (which could lead to being less efficient, and to
subtle bugs in case of side-effects). So instead, variables are
evaluated once, and then passed as parameters (to templates in XSLT
and functions in XQuery).

### Test suite

[`compilation-variables-scope.xspec`](compilation-variables-scope.xspec)

```xml
<x:variable name="myv:var-1" select="trace('value-1')" />

<x:scenario label="outer scenario">
   <x:variable name="myv:var-2" select="trace('value-2')" />

   <x:scenario label="inner scenario">
      <x:variable name="myv:var-3" select="trace('value-3')" />
      <x:call function="my:square">
         <x:param select="0" />
      </x:call>

      <x:variable name="myv:var-4" select="trace('value-4')" />
      <x:expect label="1st expect" .../>

      <x:variable name="myv:var-5" select="trace('value-5')" />
      <x:expect label="2nd expect" .../>
   </x:scenario>
</x:scenario>
```

### Compiled stylesheet

```xml
<!-- the generated global variable -->
<xsl:variable xmlns:my="http://example.org/ns/my"
              xmlns:myv="http://example.org/ns/my/variable"
              xmlns:x="http://www.jenitennison.com/xslt/xspec"
              name="Q{http://example.org/ns/my/variable}var-1"
              select="trace('value-1')"/>

<!-- generated from the outer scenario -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1"
              as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
   ...
   <!-- the generated variable -->
   <xsl:variable xmlns:my="http://example.org/ns/my"
                 xmlns:myv="http://example.org/ns/my/variable"
                 xmlns:x="http://www.jenitennison.com/xslt/xspec"
                 name="Q{http://example.org/ns/my/variable}var-2"
                 select="trace('value-2')"/>
   <xsl:for-each select="1 to 1">
      <xsl:choose>
         <xsl:when test=". eq 1">
            <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1">
               <!-- pass the variable to inner context -->
               <xsl:with-param name="Q{http://example.org/ns/my/variable}var-2"
                               select="$Q{http://example.org/ns/my/variable}var-2"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:message terminate="yes">ERROR: Unhandled scenario invocation</xsl:message>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:for-each>
</xsl:template>

<!-- generated from the inner scenario -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1"
              as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
   ...
   <!-- the variable is passed as param -->
   <xsl:param name="Q{http://example.org/ns/my/variable}var-2"
              as="item()*"
              required="yes"/>
   ...
   <!-- the generated variable -->
   <xsl:variable xmlns:my="http://example.org/ns/my"
                 xmlns:myv="http://example.org/ns/my/variable"
                 xmlns:x="http://www.jenitennison.com/xslt/xspec"
                 name="Q{http://example.org/ns/my/variable}var-3"
                 select="trace('value-3')"/>
   ...
   <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
      ...
      <xsl:sequence xmlns:my="http://example.org/ns/my"
                    xmlns:myv="http://example.org/ns/my/variable"
                    xmlns:x="http://www.jenitennison.com/xslt/xspec"
                    select="Q{http://example.org/ns/my}square(...)"/>
   </xsl:variable>
   ...
   <!-- the generated variable -->
   <xsl:variable xmlns:my="http://example.org/ns/my"
                 xmlns:myv="http://example.org/ns/my/variable"
                 xmlns:x="http://www.jenitennison.com/xslt/xspec"
                 name="Q{http://example.org/ns/my/variable}var-4"
                 select="trace('value-4')"/>
   <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1-expect1">
      <xsl:with-param name="Q{http://www.jenitennison.com/xslt/xspec}result"
                      select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-2"
                      select="$Q{http://example.org/ns/my/variable}var-2"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-3"
                      select="$Q{http://example.org/ns/my/variable}var-3"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-4"
                      select="$Q{http://example.org/ns/my/variable}var-4"/>
   </xsl:call-template>
   <!-- the generated variable -->
   <xsl:variable xmlns:my="http://example.org/ns/my"
                 xmlns:myv="http://example.org/ns/my/variable"
                 xmlns:x="http://www.jenitennison.com/xslt/xspec"
                 name="Q{http://example.org/ns/my/variable}var-5"
                 select="trace('value-5')"/>
   <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1-expect2">
      <xsl:with-param name="Q{http://www.jenitennison.com/xslt/xspec}result"
                      select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-2"
                      select="$Q{http://example.org/ns/my/variable}var-2"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-3"
                      select="$Q{http://example.org/ns/my/variable}var-3"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-4"
                      select="$Q{http://example.org/ns/my/variable}var-4"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-5"
                      select="$Q{http://example.org/ns/my/variable}var-5"/>
   </xsl:call-template>
</xsl:template>

<!-- generated from the 1st expect -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1-expect1"
              as="element(Q{http://www.jenitennison.com/xslt/xspec}test)">
   ...
   <xsl:param name="Q{http://www.jenitennison.com/xslt/xspec}result"
              as="item()*"
              required="yes"/>
   <!-- the variables are passed as param -->
   <xsl:param name="Q{http://example.org/ns/my/variable}var-2"
              as="item()*"
              required="yes"/>
   <xsl:param name="Q{http://example.org/ns/my/variable}var-3"
              as="item()*"
              required="yes"/>
   <xsl:param name="Q{http://example.org/ns/my/variable}var-4"
              as="item()*"
              required="yes"/>
   ... evaluate the expectations ...
</xsl:template>

<!-- generated from the 2nd expect -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1-expect2"
              as="element(Q{http://www.jenitennison.com/xslt/xspec}test)">
   ...
   <xsl:param name="Q{http://www.jenitennison.com/xslt/xspec}result"
              as="item()*"
              required="yes"/>
   <!-- the variables are passed as param -->
   <xsl:param name="Q{http://example.org/ns/my/variable}var-2"
              as="item()*"
              required="yes"/>
   <xsl:param name="Q{http://example.org/ns/my/variable}var-3"
              as="item()*"
              required="yes"/>
   <xsl:param name="Q{http://example.org/ns/my/variable}var-4"
              as="item()*"
              required="yes"/>
   <xsl:param name="Q{http://example.org/ns/my/variable}var-5"
              as="item()*"
              required="yes"/>
   ... evaluate the expectations ...
</xsl:template>
```

### Compiled query

```xquery
(: the generated global variable :)
declare variable $Q{http://example.org/ns/my/variable}var-1 := (
trace('value-1')
);

(: generated from the outer scenario :)
declare function local:scenario1(
) as element(Q{http://www.jenitennison.com/xslt/xspec}scenario)
{
...
(: the generated variable :)
let $Q{http://example.org/ns/my/variable}var-2 := (
trace('value-2')
)
let $local:returned-from-scenario1-scenario1 := local:scenario1-scenario1(
(: pass the variable to inner context :)
$Q{http://example.org/ns/my/variable}var-2
)
return (
$local:returned-from-scenario1-scenario1
)
...
};

(: generated from the inner scenario :)
declare function local:scenario1-scenario1(
(: the variable is passed as param :)
$Q{http://example.org/ns/my/variable}var-2 as item()*
) as element(Q{http://www.jenitennison.com/xslt/xspec}scenario)
{
(: the generated variable :)
let $Q{http://example.org/ns/my/variable}var-3 := (
trace('value-3')
)
return
...
let $Q{http://www.jenitennison.com/xslt/xspec}result as item()* := (
Q{http://example.org/ns/my}square(...)
)
...
(: the generated variable :)
let $Q{http://example.org/ns/my/variable}var-4 := (
trace('value-4')
)
let $local:returned-from-scenario1-scenario1-expect1 := local:scenario1-scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result,
$Q{http://example.org/ns/my/variable}var-2,
$Q{http://example.org/ns/my/variable}var-3,
$Q{http://example.org/ns/my/variable}var-4
)
(: the generated variable :)
let $Q{http://example.org/ns/my/variable}var-5 := (
trace('value-5')
)
let $local:returned-from-scenario1-scenario1-expect2 := local:scenario1-scenario1-expect2(
$Q{http://www.jenitennison.com/xslt/xspec}result,
$Q{http://example.org/ns/my/variable}var-2,
$Q{http://example.org/ns/my/variable}var-3,
$Q{http://example.org/ns/my/variable}var-4,
$Q{http://example.org/ns/my/variable}var-5
)
return (
...
$local:returned-from-scenario1-scenario1-expect1,
$local:returned-from-scenario1-scenario1-expect2
)
...
};

(: generated from the 1st expect :)
declare function local:scenario1-scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result as item()*,
(: the variables are passed as param :)
$Q{http://example.org/ns/my/variable}var-2 as item()*,
$Q{http://example.org/ns/my/variable}var-3 as item()*,
$Q{http://example.org/ns/my/variable}var-4 as item()*
) as element(Q{http://www.jenitennison.com/xslt/xspec}test)
{
...evaluate the expectations ...
};

(: generated from the 2nd expect :)
declare function local:scenario1-scenario1-expect2(
$Q{http://www.jenitennison.com/xslt/xspec}result as item()*,
(: the variables are passed as param :)
$Q{http://example.org/ns/my/variable}var-2 as item()*,
$Q{http://example.org/ns/my/variable}var-3 as item()*,
$Q{http://example.org/ns/my/variable}var-4 as item()*,
$Q{http://example.org/ns/my/variable}var-5 as item()*
) as element(Q{http://www.jenitennison.com/xslt/xspec}test)
{
...evaluate the expectations ...
};
```

### Output at run time

By `trace()` in `x:variable/@select`, you see that each `x:variable` is evaluated only once:

```console
C:xspec>bin\xspec.bat tutorial\under-the-hood\compilation-variables-scope.xspec
...
Running Tests...
Testing with SAXON EE 9.9.1.8
outer scenario
* [1]: xs:string: value-2
..inner scenario
* [1]: xs:string: value-3
* [1]: xs:string: value-4
1st expect
* [1]: xs:string: value-1
* [1]: xs:string: value-5
2nd expect

Formatting Report...
...
```

## run-as=external

When `/x:description/@run-as` is `external`, XSpec test suites are compiled in a different way:

- The compiled stylesheet does not import the tested stylesheet.
- The compiled stylesheet invokes SUT via `fn:transform()`.

Before invoking the SUT, the compiled stylesheet creates a map (`$impl:transform-options` variable) that specifies how `transform()` should run the SUT. The data format of this map is standardized by [the spec](https://www.w3.org/TR/xpath-functions-31/#func-transform). The SUT is invoked and its raw result is retrieved by `transform($impl:transform-options)?output`.

### Test suite

[`compilation-sut_template_external.xspec`](compilation-sut_template_external.xspec)

```xml
<x:description
   run-as="external"
   stylesheet="compilation-sut.xsl"
   xmlns:x="http://www.jenitennison.com/xslt/xspec">

   <x:scenario label="call a named template (without x:context)">
      <x:call template="t">
         <x:param name="p1" select="'val1'"/>
         <x:param name="p2">
            <val2/>
         </x:param>
      </x:call>
      <x:expect .../>
   </x:scenario>

   <x:scenario label="call a named template (with x:context)">
      <x:context>
         <elem/>
      </x:context>
      <x:call template="t">
         <x:param name="p1" select="'val1'"/>
      </x:call>
      <x:expect .../>
   </x:scenario>

   <x:scenario label="apply template rules on a node (with x:context)">
      <x:context>
         <elem/>
      </x:context>
      <x:expect .../>
   </x:scenario>

</x:description>
```

### Compiled stylesheet

```xml
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   ... compilation-sut.xsl is not imported ...

   <!-- "call a named template (without x:context)" scenario -->
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1"
                 as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
      ...
         <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
            ...
            <xsl:variable name="Q{urn:x-xspec:compile:impl}transform-options"
                          as="map(Q{http://www.w3.org/2001/XMLSchema}string, item()*)">
               <xsl:map>
                  <xsl:map-entry key="'delivery-format'" select="'raw'"/>
                  <xsl:map-entry key="'stylesheet-location'">.../compilation-sut.xsl</xsl:map-entry>
                  <xsl:if test="$Q{http://www.jenitennison.com/xslt/xspec}saxon-config => exists()">
                     <xsl:choose>
                        <xsl:when test="$Q{http://www.jenitennison.com/xslt/xspec}saxon-config instance of element(Q{http://saxon.sf.net/ns/configuration}configuration)"/>
                        <xsl:when test="$Q{http://www.jenitennison.com/xslt/xspec}saxon-config instance of document-node(element(Q{http://saxon.sf.net/ns/configuration}configuration))"/>
                        <xsl:otherwise>
                           <xsl:message terminate="yes">ERROR: $Q{http://www.jenitennison.com/xslt/xspec}saxon-config does not appear to be a Saxon configuration</xsl:message>
                        </xsl:otherwise>
                     </xsl:choose>
                     <xsl:map-entry key="'cache'" select="false()"/>
                     <xsl:map-entry key="'vendor-options'">
                        <xsl:map>
                           <xsl:map-entry key="QName('http://saxon.sf.net/', 'configuration')"
                                          select="$Q{http://www.jenitennison.com/xslt/xspec}saxon-config"/>
                        </xsl:map>
                     </xsl:map-entry>
                  </xsl:if>
                  <xsl:map-entry key="'template-params'">
                     <xsl:map>
                        <xsl:map-entry key="QName('', 'p1')" select="$Q{urn:x-xspec:compile:impl}param-...1"/>
                        <xsl:map-entry key="QName('', 'p2')" select="$Q{urn:x-xspec:compile:impl}param-...2"/>
                     </xsl:map>
                  </xsl:map-entry>
                  <xsl:map-entry key="'initial-template'" select="QName('', 't')"/>
               </xsl:map>
            </xsl:variable>
            <xsl:sequence select="transform($Q{urn:x-xspec:compile:impl}transform-options)?output"/>
         </xsl:variable>
      ...
   </xsl:template>
   ...
   <!-- "call a named template (with x:context)" scenario -->
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario2"
                 as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
      ...
         <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
            ...
            <xsl:variable name="Q{urn:x-xspec:compile:impl}transform-options"
                          as="map(Q{http://www.w3.org/2001/XMLSchema}string, item()*)">
               <xsl:map>
                  <xsl:map-entry key="'delivery-format'" select="'raw'"/>
                  <xsl:map-entry key="'stylesheet-location'">.../compilation-sut.xsl</xsl:map-entry>
                  <xsl:if test="$Q{http://www.jenitennison.com/xslt/xspec}saxon-config => exists()">
                     ...
                  </xsl:if>
                  <xsl:map-entry key="'template-params'">
                     <xsl:map>
                        <xsl:map-entry key="QName('', 'p1')" select="$Q{urn:x-xspec:compile:impl}param-..."/>
                     </xsl:map>
                  </xsl:map-entry>
                  <xsl:map-entry key="'initial-template'" select="QName('', 't')"/>
               </xsl:map>
            </xsl:variable>
            <xsl:for-each select="$Q{http://www.jenitennison.com/xslt/xspec}context">
               <xsl:variable name="Q{urn:x-xspec:compile:impl}transform-options"
                             as="map(Q{http://www.w3.org/2001/XMLSchema}string, item()*)"
                             select="Q{http://www.w3.org/2005/xpath-functions/map}put($Q{urn:x-xspec:compile:impl}transform-options, 'global-context-item', .)"/>
               <xsl:sequence select="transform($Q{urn:x-xspec:compile:impl}transform-options)?output"/>
            </xsl:for-each>
         </xsl:variable>
      ...
   </xsl:template>
   ...
   <!-- "apply template rules on a node (with x:context)" scenario -->
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario3"
                 as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
      ...
         <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
            <xsl:variable name="Q{urn:x-xspec:compile:impl}transform-options"
                          as="map(Q{http://www.w3.org/2001/XMLSchema}string, item()*)">
               <xsl:map>
                  <xsl:map-entry key="'delivery-format'" select="'raw'"/>
                  <xsl:map-entry key="'stylesheet-location'">.../compilation-sut.xsl</xsl:map-entry>
                  <xsl:if test="$Q{http://www.jenitennison.com/xslt/xspec}saxon-config => exists()">
                     ...
                  </xsl:if>
                  <xsl:map-entry key="if ($Q{http://www.jenitennison.com/xslt/xspec}context instance of node()) then 'source-node' else 'initial-match-selection'"
                                 select="$Q{http://www.jenitennison.com/xslt/xspec}context"/>
               </xsl:map>
            </xsl:variable>
            <xsl:sequence select="transform($Q{urn:x-xspec:compile:impl}transform-options)?output"/>
         </xsl:variable>
      ...
   </xsl:template>
   ...
</xsl:stylesheet>
```

## Scenario-level `x:param` scope

Scenario-level `x:param` follows the same scope rule as [`x:variable`](#variables-scope).

### Test suite

Using `x:param` as direct children of `x:scenario` requires [`@run-as="external"`](#run-asexternal) on `x:description`.

[`compilation-params-scope.xspec`](compilation-params-scope.xspec)

```xml
<x:description run-as="external">
   <x:param name="myp:param-1" select="trace('value-1')" />

   <x:scenario label="outer scenario">
      <x:param name="myp:param-2" select="trace('value-2')" />

      <x:scenario label="inner scenario">
         <x:param name="myp:param-3" select="trace('value-3')" />
         <x:call function="my:square">
            <x:param select="0" />
         </x:call>
         <x:expect label="1st expect" .../>
      </x:scenario>
   </x:scenario>
</x:description>
```

### Compiled stylesheet

Scenario-level `x:param` is compiled in almost the same way as `x:variable`.

```xml
<!-- generated from global x:param -->
<xsl:param xmlns:my="http://example.org/ns/my"
           xmlns:myp="http://example.org/ns/my/param"
           xmlns:x="http://www.jenitennison.com/xslt/xspec"
           name="Q{http://example.org/ns/my/param}param-1"
           select="trace('value-1')"/>
...
<!-- generated from the outer scenario -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1"
              as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
   ...
   <xsl:element name="scenario" namespace="http://www.jenitennison.com/xslt/xspec">
      ...
      <!-- generated from scenario-level x:param -->
      <xsl:variable xmlns:my="http://example.org/ns/my"
                    xmlns:myp="http://example.org/ns/my/param"
                    xmlns:x="http://www.jenitennison.com/xslt/xspec"
                    name="Q{http://example.org/ns/my/param}param-2"
                    select="trace('value-2')"/>
      <xsl:for-each select="1 to 1">
         <xsl:choose>
            <xsl:when test=". eq 1">
               <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1">
                  <!-- pass the compiled x:param to inner context -->
                  <xsl:with-param name="Q{http://example.org/ns/my/param}param-2"
                                  select="$Q{http://example.org/ns/my/param}param-2"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
               <xsl:message terminate="yes">ERROR: Unhandled scenario invocation</xsl:message>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:element>
</xsl:template>

<!-- generated from the inner scenario -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1"
              as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
   ...
   <!-- the compiled x:param in the outer scenario is passed as xsl:param -->
   <xsl:param name="Q{http://example.org/ns/my/param}param-2" required="yes"/>
   ...
   <xsl:element name="scenario" namespace="http://www.jenitennison.com/xslt/xspec">
      ...
      <!-- generated from x:param in the inner scenario -->
      <xsl:variable xmlns:my="http://example.org/ns/my"
                    xmlns:myp="http://example.org/ns/my/param"
                    xmlns:x="http://www.jenitennison.com/xslt/xspec"
                    name="Q{http://example.org/ns/my/param}param-3"
                    select="trace('value-3')"/>
      ...
      <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
         ...
         <xsl:variable name="Q{urn:x-xspec:compile:impl}transform-options"
                       as="map(Q{http://www.w3.org/2001/XMLSchema}string, item()*)">
            <xsl:map>
               ...
               <!-- all the effective instances of x:param are collected
                  into the 'stylesheet-params' option of $impl:transform-options -->
               <xsl:map-entry key="'stylesheet-params'">
                  <xsl:map>
                     <xsl:map-entry key="QName('http://example.org/ns/my/param', 'myp:param-1')"
                                    select="$Q{http://example.org/ns/my/param}param-1"/>
                     <xsl:map-entry key="QName('http://example.org/ns/my/param', 'myp:param-2')"
                                    select="$Q{http://example.org/ns/my/param}param-2"/>
                     <xsl:map-entry key="QName('http://example.org/ns/my/param', 'myp:param-3')"
                                    select="$Q{http://example.org/ns/my/param}param-3"/>
                  </xsl:map>
               </xsl:map-entry>
               ...
            </xsl:map>
         </xsl:variable>
         <xsl:sequence select="transform($Q{urn:x-xspec:compile:impl}transform-options)?output"/>
      </xsl:variable>
      ...
      <!-- invoke each compiled x:expect -->
      <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1-expect1">
         <xsl:with-param name="Q{http://www.jenitennison.com/xslt/xspec}result"
                         select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
         <!-- pass the compiled x:param -->
         <xsl:with-param name="Q{http://example.org/ns/my/param}param-2"
                         select="$Q{http://example.org/ns/my/param}param-2"/>
         <xsl:with-param name="Q{http://example.org/ns/my/param}param-3"
                         select="$Q{http://example.org/ns/my/param}param-3"/>
      </xsl:call-template>
   </xsl:element>
</xsl:template>
```

### Output at run time

By `trace()` in `x:param/@select`, you see that each `x:param` is evaluated only once:

```console
C:\xspec>bin\xspec.bat tutorial\under-the-hood\compilation-params-scope.xspec
...
Running Tests...
Testing with SAXON EE 9.9.1.8
outer scenario
* [1]: xs:string: value-2
..inner scenario
* [1]: xs:string: value-3
* [1]: xs:string: value-1
1st expect

Formatting Report...
...
```

## `result-type` attribute

The `@result-type` attribute of the `x:expect` element causes the corresponding generated template or function to check whether the actual result is an instance of the specified type. If not, a boolean variable whose local name is `result-type-mismatch` is false, and the template or function reacts in these ways:

- Bypasses evaluating `@test`; look for `<xsl:when test="$Q{urn:x-xspec:compile:impl}result-type-mismatch">` (XSLT) or `if ($local:result-type-mismatch)` (XQuery)
- Fails the verification, even if the actual and expected results are deep-equal
- Records an `instance of` XPath expression based on the `@result-type` value, and the HTML test result report shows this expression in the box labeled **Expecting**

### Test suite

This test suite adds a `@result-type` attribute to the `x:expect` element in "Simple suite".

[`compilation-result-type.xspec`](compilation-result-type.xspec)

```xml
<x:expect label="expectations" test="$x:result = 1"
   result-type="xs:integer"/>
```

### Compiled stylesheet

```xml
   <!-- generated from the x:expect element -->
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-expect1"
                 as="element(Q{http://www.jenitennison.com/xslt/xspec}test)">
      <xsl:context-item use="absent"/>
      <xsl:param name="Q{http://www.jenitennison.com/xslt/xspec}result"
                 as="item()*"
                 required="yes"/>
      ...
      <!-- flag if @result-type is present but $x:result is not the right type -->
      <xsl:variable name="Q{urn:x-xspec:compile:impl}result-type-mismatch"
                    as="Q{http://www.w3.org/2001/XMLSchema}boolean"
                    select="not($Q{http://www.jenitennison.com/xslt/xspec}result instance of Q{http://www.w3.org/2001/XMLSchema}integer)"/>
      ...
      <!-- evaluate the predicate with $x:result (or its wrapper document node) as context item if it is a single item; if not, evaluate the predicate without context item -->
      <xsl:variable name="Q{urn:x-xspec:compile:impl}test-result" as="item()*">
         <xsl:choose>
            <xsl:when test="$Q{urn:x-xspec:compile:impl}result-type-mismatch"><!--In case of data type mismatch, do not process @test--></xsl:when>
            <xsl:when test="count($Q{urn:x-xspec:compile:impl}test-items) eq 1">
               <xsl:for-each select="$Q{urn:x-xspec:compile:impl}test-items">
                  <xsl:sequence xmlns:x="http://www.jenitennison.com/xslt/xspec"
                                select="$x:result = 1"
                                version="3"/>
               </xsl:for-each>
            </xsl:when>
            ...
         </xsl:choose>
      </xsl:variable>
      ...
      <!-- did the test pass? -->
      <xsl:variable name="Q{urn:x-xspec:compile:impl}successful"
                    as="Q{http://www.w3.org/2001/XMLSchema}boolean">
         <xsl:choose>
            <xsl:when test="$Q{urn:x-xspec:compile:impl}result-type-mismatch">
               <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:when ...></xsl:when>
            ...
         </xsl:choose>
      </xsl:variable>
      ...
      <!-- Reporting -->
      <xsl:element name="test" namespace="http://www.jenitennison.com/xslt/xspec">
         ...
         <xsl:choose>
            <xsl:when test="$Q{urn:x-xspec:compile:impl}result-type-mismatch">
               <xsl:element name="expect-test-wrap" namespace="">
                  <xsl:element name="x:expect" namespace="http://www.jenitennison.com/xslt/xspec">
                     <xsl:namespace name="xs">http://www.w3.org/2001/XMLSchema</xsl:namespace>
                     <xsl:attribute name="result-type" namespace="">$x:result instance of xs:integer</xsl:attribute>
                  </xsl:element>
               </xsl:element>
            </xsl:when>
            ...
         </xsl:choose>
         ...
      </xsl:element>
   </xsl:template>
```

### Compiled query

```xquery
(: generated from the x:expect element :)
declare function local:scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result as item()*
) as element(Q{http://www.jenitennison.com/xslt/xspec}test)
{
...
(: flag if @result-type is present but $x:result is not the right type :)
let $local:result-type-mismatch as xs:boolean := not($Q{http://www.jenitennison.com/xslt/xspec}result instance of Q{http://www.w3.org/2001/XMLSchema}integer)
...
let $local:test-result as item()* (: evaluate the predicate :) := (
if ($local:result-type-mismatch)
then ((: In case of data type mismatch, do not process @test :))
else $x:result = 1
)
...
let $local:successful as xs:boolean (: did the test pass? :) := (
if ($local:result-type-mismatch)
then false()
else ...
)
return
(: Reporting :)
element { QName('http://www.jenitennison.com/xslt/xspec', 'test') } {
...
if ( $local:result-type-mismatch )
then (element { QName('', 'expect-test-wrap') } {
element { QName('http://www.jenitennison.com/xslt/xspec', 'x:expect') } {
namespace { "xs" } { 'http://www.w3.org/2001/XMLSchema' },
attribute { QName('', 'result-type') } { '$x:result instance of xs:integer' }
}})
else
...
};
```
