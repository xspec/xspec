## Contents

- [Introduction](#introduction)
- [Simple suite](#simple-suite)
- [Simple scenario](#simple-scenario)
- [SUT](#sut)
- [Variables](#variables)
- [Variable value](#variable-value)
- [Variables scope](#variables-scope)

## Introduction

This page is an overview of how XSpec test suites are compiled into XSLT and XQuery. It shows examples of simple test suites along with their XSpec-generated stylesheets and queries. Some of these examples are in the [test directory](https://github.com/xspec/xspec/tree/master/test).

The generated stylesheets and queries are not shown in their entirety. In particular, the code generating parts of the final report has been removed, except in examples specifically intended to show how this is done. The root elements of test suites are omitted, and indentation and comments have been added where appropriate.

The goal is to make the compilation phase clearer, mostly for development purposes.

Those examples could be the base for test cases, too, developed as an automated test suite.

## Simple suite

Show the structure of a compiled test suite, both in XSLT and XQuery.

### Test suite

[compilation-simple-suite.xspec](compilation-simple-suite.xspec)

```xml
<?xml version="1.0" encoding="UTF-8"?>
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

### Stylesheet

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:my="http://example.org/ns/my"
                version="3.0">
   <!-- the tested stylesheet -->
   <xsl:import href=".../compilation-simple-suite.xsl"/>
   <!-- an XSpec stylesheet providing tools -->
   <xsl:include href=".../xspec/src/compiler/generate-tests-utils.xsl"/>
   <xsl:include href=".../xspec/src/common/xspec-utils.xsl"/>
   <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}xspec-uri"
                 as="Q{http://www.w3.org/2001/XMLSchema}anyURI">.../compilation-simple-suite.xspec</xsl:variable>
   <!-- the main template to run the suite -->
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}main">
      <!-- info message -->
      <xsl:message>
         <xsl:text>Testing with </xsl:text>
         <xsl:value-of select="system-property('xsl:product-name')"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="system-property('xsl:product-version')"/>
      </xsl:message>
      <!-- set up the result document (the report) -->
      <xsl:result-document format="Q{{http://www.jenitennison.com/xslt/xspec}}xml-report-serialization-parameters">
         <xsl:element name="x:report" namespace="http://www.jenitennison.com/xslt/xspec">
            <xsl:namespace name="my">http://example.org/ns/my</xsl:namespace>
            <xsl:attribute name="xspec" namespace="">.../compilation-simple-suite.xspec</xsl:attribute>
            <xsl:attribute name="stylesheet" namespace="">.../compilation-simple-suite.xsl</xsl:attribute>
            <xsl:attribute name="date" namespace="" select="current-dateTime()"/>
            <!-- a call instruction for each top-level scenario -->
            <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1"/>
         </xsl:element>
      </xsl:result-document>
   </xsl:template>

   <!-- generated from the x:scenario element -->
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1">
      ...
      <!-- a call instruction for each x:expect element -->
      <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-expect1">
         ...
      </xsl:call-template>
   </xsl:template>

   <!-- generated from the x:expect element -->
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-expect1">
      ...
   </xsl:template>

</xsl:stylesheet>
```

### Query

```xquery
xquery version "3.1";

(: the tested library module :)
import module namespace my = "http://example.org/ns/my"
at ".../compilation-simple-suite.xqm";

(: XSpec library modules providing tools :)
import module "http://www.jenitennison.com/xslt/unit-test"
at ".../src/compiler/generate-query-utils.xqm";
import module "http://www.jenitennison.com/xslt/xspec"
at ".../src/common/xspec-utils.xqm";

declare namespace x = "http://www.jenitennison.com/xslt/xspec";
declare option Q{http://www.w3.org/2010/xslt-xquery-serialization}parameter-document ".../xml-report-serialization-parameters.xml";
declare variable $Q{http://www.jenitennison.com/xslt/xspec}xspec-uri as xs:anyURI := (
xs:anyURI(".../compilation-simple-suite.xspec")
);

(: generated from the x:scenario element :)
declare function local:scenario1(
)
{
...
(: a call instruction for each x:expect element :)
let $Q{http://www.jenitennison.com/xslt/xspec}tmp := local:scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result
)
return (
$Q{http://www.jenitennison.com/xslt/xspec}tmp
)
...
};

(: generated from the x:expect element :)
declare function local:scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result
)
{
...
};

(: the query body of this main module, to run the suite :)
(: set up the result document (the report) :)
document {
element { QName('http://www.jenitennison.com/xslt/xspec', 'x:report') } {
namespace { "my" } { 'http://example.org/ns/my' },
attribute { QName('', 'xspec') } { '.../compilation-simple-suite.xspec' },
attribute { QName('', 'query') } { 'http://example.org/ns/my' },
attribute { QName('', 'query-at') } { '.../compilation-simple-suite.xqm' },
attribute { QName('', 'date') } { current-dateTime() },
(: a call instruction for each top-level scenario :)
let $Q{http://www.jenitennison.com/xslt/xspec}tmp := local:scenario1(
)
return (
$Q{http://www.jenitennison.com/xslt/xspec}tmp
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

[compilation-simple-suite.xspec](compilation-simple-suite.xspec)

```xml
<x:scenario label="scenario">
   <x:call function="my:f"/>
   <x:expect label="expectations" test="$x:result = 1"/>
</x:scenario>
```

### Stylesheet

```xml
<!-- generated from the x:scenario element -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1">
   <xsl:message>scenario</xsl:message>
   <xsl:element name="x:scenario" namespace="http://www.jenitennison.com/xslt/xspec">
      <xsl:attribute name="id" namespace="">scenario1</xsl:attribute>
      <xsl:attribute name="xspec" namespace="">.../compilation-simple-suite.xspec</xsl:attribute>
      <xsl:element name="x:label" namespace="http://www.jenitennison.com/xslt/xspec">
         <xsl:text>scenario</xsl:text>
      </xsl:element>
      <xsl:element name="x:call" namespace="http://www.jenitennison.com/xslt/xspec">
         <xsl:namespace name="my">http://example.org/ns/my</xsl:namespace>
         <xsl:attribute name="function" namespace="">my:f</xsl:attribute>
      </xsl:element>
      <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
         <xsl:sequence select="Q{http://example.org/ns/my}f()"/>
      </xsl:variable>

      ... generate scenario data in the report ...

      <!-- a call instruction for each x:expect element -->
      <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-expect1">
         <xsl:with-param name="Q{http://www.jenitennison.com/xslt/xspec}result" select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
      </xsl:call-template>
   </x:element>
</xsl:template>

<!-- generated from the x:expect element -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-expect1">
   <xsl:param name="Q{http://www.jenitennison.com/xslt/xspec}result" required="yes"/>
   <xsl:message>expectations</xsl:message>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}expect-..." select="()"><!--expected result--></xsl:variable>
   <!-- wrap $x:result into a doc node if possible -->
   <xsl:variable name="Q{urn:x-xspec:compile:impl}test-items" as="item()*">
      <xsl:choose>
         <xsl:when test="exists($Q{http://www.jenitennison.com/xslt/xspec}result) and Q{http://www.jenitennison.com/xslt/unit-test}wrappable-sequence($Q{http://www.jenitennison.com/xslt/xspec}result)">
            <xsl:sequence select="Q{http://www.jenitennison.com/xslt/unit-test}wrap-nodes($Q{http://www.jenitennison.com/xslt/xspec}result)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <!-- evaluate the predicate with $x:result as context node if $x:result is a single node; if not, just evaluate the predicate -->
   <xsl:variable name="Q{urn:x-xspec:compile:impl}test-result" as="item()*">
      <xsl:choose>
         <xsl:when test="count($Q{urn:x-xspec:compile:impl}test-items) eq 1">
            <xsl:for-each select="$Q{urn:x-xspec:compile:impl}test-items">
               <xsl:sequence select="$x:result = 1" version="2"/>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$x:result = 1" version="2"/>
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
         <xsl:when test="$Q{urn:x-xspec:compile:impl}boolean-test">
            <xsl:sequence select="boolean($Q{urn:x-xspec:compile:impl}test-result)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="Q{http://www.jenitennison.com/xslt/unit-test}deep-equal($Q{urn:x-xspec:compile:impl}expect-..., $Q{urn:x-xspec:compile:impl}test-result, '')"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   ... generate test result in the report ...
</xsl:template>
```

### Query

```xquery
(: generated from the x:scenario element :)
declare function local:scenario1(
)
{
... generate scenario data in the report ...

let $Q{http://www.jenitennison.com/xslt/xspec}result := (
Q{http://example.org/ns/my}f()
)
return (
Q{http://www.jenitennison.com/xslt/unit-test}report-sequence($Q{http://www.jenitennison.com/xslt/xspec}result, 'x:result'),

(: a call instruction for each x:expect element :)
let $Q{http://www.jenitennison.com/xslt/xspec}tmp := local:scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result
)
return (
$Q{http://www.jenitennison.com/xslt/xspec}tmp
)
)
}
};

(: generated from the x:expect element :)
declare function local:scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result
)
{
let $Q{urn:x-xspec:compile:impl}expect-... (: expected result :) := (
()
)
let $local:test-items as item()* := $Q{http://www.jenitennison.com/xslt/xspec}result
let $local:test-result as item()* (: evaluate the predicate :) := (
$x:result = 1
)
let $local:boolean-test as xs:boolean := ($local:test-result instance of xs:boolean)
let $local:successful as xs:boolean (: did the test pass? :) := (
if ($local:boolean-test)
then boolean($local:test-result)
else Q{http://www.jenitennison.com/xslt/unit-test}deep-equal($Q{urn:x-xspec:compile:impl}expect-..., $local:test-result, '')
)
return
... generate test result in the report ...
};
```

## SUT

The SUT (or System Under Test) is the component tested in a
scenario. In XSpec, this is either an XSLT template (named or
rule) or an XPath function (written either in XSLT or XQuery).
Here, we use it to refer to the three ways to refer to the SUT
itself, as well as parameters to use for the current scenario:
`x:apply`, `x:call` and `x:context` (so that's not strictly speaking
the SUT itself, but rather the way to "call" it for this
scenario).

`x:apply` represents applying a template rule to a node (this is not
possible in XQuery), and corresponds naturally to
`xsl:apply-templates`. `x:call` represents a call either to a named
template or an XPath function. `x:context` also represents applying
a template rule to a node, but in a different way than `x:apply`:
the former represents more a full transform (e.g., the result is
always one document node) where `x:apply` is exactly the result of a
template rule (the result is the exact result sequence of the
rule).

Those examples show only what is related to the call of the SUT in
the template (or function) generated from the scenario (see the
section "[Simple scenario](#simple-scenario)").

### Test suite

- For function (XSLT and XQuery): [compilation-sut_function.xspec](compilation-sut_function.xspec)
- For template (only XSLT) [compilation-sut_template.xspec](compilation-sut_template.xspec)

```xml
<!-- call a function -->
<x:call function="my:f">
   <x:param select="'val1'"/>
   <x:param name="p2" as="element()">
      <val2/>
   </x:param>
</x:call>

<!-- call a named template -->
<x:call template="t">
   <x:param name="p1" select="'val1'"/>
   <x:param name="p2">
      <val2/>
   </x:param>
</x:call>

<!-- apply template rules on a node (with x:context) -->
<x:context>
   <elem/>
</x:context>

<!-- apply template rules on a node (with x:apply) -->
<!-- TODO: x:apply not implemented yet -->
<x:variable name="ctxt">
   <elem/>
</x:variable>
<x:apply select="$ctxt" mode="mode">
   <x:param name="p1" select="'val1'" tunnel="yes"/>
   <x:param name="p2" as="element()">
      <val2/>
   </x:param>
</x:apply>

```

### Stylesheet

```xml
<!-- "call a function" -->
<xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
   <xsl:variable name="Q{urn:x-xspec:compile:impl}param-..." select="'val1'"/>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}param-...-doc" as="document-node()">
      <xsl:document>
         <xsl:element name="val2" namespace="">
            <xsl:namespace name="my">http://example.org/ns/my</xsl:namespace>
            <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
         </xsl:element>
      </xsl:document>
   </xsl:variable>
   <xsl:variable name="Q{}p2"
                 as="element()"
                 select="$Q{urn:x-xspec:compile:impl}param-...-doc ! ( node() )"/>
   <xsl:sequence select="Q{http://example.org/ns/my}f($Q{urn:x-xspec:compile:impl}param-..., $Q{}p2)"/>
</xsl:variable>

<!-- "call a named template" -->
<xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
   <xsl:variable name="Q{}p1" select="'val1'"/>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}param-...-doc" as="document-node()">
      <xsl:document>
         <xsl:element name="val2" namespace="">
            <xsl:namespace name="my">http://example.org/ns/my</xsl:namespace>
            <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
         </xsl:element>
      </xsl:document>
   </xsl:variable>
   <xsl:variable name="Q{}p2"
                 select="$Q{urn:x-xspec:compile:impl}param-...-doc ! ( node() )" />
   <xsl:call-template name="Q{}t">
      <xsl:with-param name="Q{}p1" select="$Q{}p1"/>
      <xsl:with-param name="Q{}p2" select="$Q{}p2"/>
   </xsl:call-template>
</xsl:variable>

<!-- "apply template rules on a node (with x:context)" -->
<xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
   <xsl:variable name="Q{urn:x-xspec:compile:impl}context-...-doc" as="document-node()">
      <xsl:document>
         <xsl:element name="elem" namespace="">
            <xsl:namespace name="my">http://example.org/ns/my</xsl:namespace>
            <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
         </xsl:element>
      </xsl:document>
   </xsl:variable>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}context-..."
                 select="$Q{urn:x-xspec:compile:impl}context-...-doc ! ( node() )"/>
   <xsl:apply-templates select="$Q{urn:x-xspec:compile:impl}context-..."/>
</xsl:variable>

<!-- "apply template rules on a node (with x:apply)" -->
<!-- TODO: x:apply not implemented yet -->
<xsl:variable name="ctxt" as="item()*">
   <elem/>
</xsl:variable>
<xsl:variable name="x:result" as="item()*">
   <xsl:variable name="p1" select="'val1'"/>
   <xsl:variable name="p2" as="element()">
      <val2/>
   </xsl:variable>
   ... error if "$ctxt instance of node()" is not true ...
   <xsl:apply-templates select="$ctxt" mode="mode">
      <xsl:with-param name="p1" select="$p1" tunnel="yes"/>
      <xsl:with-param name="p2" select="$p2"/>
   </xsl:apply-templates>
</xsl:variable>
```

### Query

```xquery
let $Q{urn:x-xspec:compile:impl}param-... := (
'val1'
)
let $Q{urn:x-xspec:compile:impl}param-...-doc as document-node() := (
document {
element { QName('', 'val2') } {
namespace { "my" } { 'http://example.org/ns/my' },
namespace { "x" } { 'http://www.jenitennison.com/xslt/xspec' }
}
}
)
let $p2 as element() := (
$Q{urn:x-xspec:compile:impl}param-...-doc ! ( node() )
)
let $Q{http://www.jenitennison.com/xslt/xspec}result := (
Q{http://example.org/ns/my}f($Q{urn:x-xspec:compile:impl}param-..., $Q{}p2)
)
```

## Variables

The `x:variable` element in the XSpec namespace defines an XSpec variable. Any number of `x:variable` elements can occur as a child of `x:description` or `x:scenario`. In `x:scenario`, an `x:variable` element can occur before or after `x:context`, `x:call`, `x:apply` (not implemented yet), or `x:expect`. XSpec variables can be redefined locally, but names of global XSpec variables must be unique. XSpec variables can be referenced in XPath expressions, such as in `@select` and `@test` attributes.

The first example shows how an XSpec variable maps to an `xsl:variable` element in generated XSLT code or a `let` statement in generated XQuery code.

### Test suite

[compilation-variables.xspec](compilation-variables.xspec)

```xml
<x:scenario label="scenario">
   <x:variable name="myv:var" select="'value'"/>
   ...
   <x:expect .../>
</x:scenario>
```

### Stylesheet

```xml
<!-- generated from the x:scenario element -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1">
   ...
   <!-- the generated variable -->
   <xsl:variable name="Q{http://example.org/ns/my/variable}var" select="'value'"/>
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
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-expect1">
   <xsl:param name="Q{http://www.jenitennison.com/xslt/xspec}result" required="yes"/>
   <xsl:param name="Q{http://example.org/ns/my/variable}var" required="yes"/>
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

### Query

```xquery
(: generated from the x:scenario element :)
declare function local:scenario1(
)
{
(: the generated variable :)
let $Q{http://example.org/ns/my/variable}var := (
'value'
)
...
let $Q{http://www.jenitennison.com/xslt/xspec}result := (
... exercise the SUT ...
)
return (
...,
let $Q{http://www.jenitennison.com/xslt/xspec}tmp := local:scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result,
$Q{http://example.org/ns/my/variable}var
)
return (
$Q{http://www.jenitennison.com/xslt/xspec}tmp
)
)
...
};

(: generated from the x:expect element :)
declare function local:scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result,
$Q{http://example.org/ns/my/variable}var
)
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

[compilation-variable-value.xspec](compilation-variable-value.xspec)

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

### Stylesheet

```xml
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1">
   ...

   <!-- $myv:select -->
   <xsl:variable name="Q{http://example.org/ns/my/variable}select" select="'value'"/>

   <!-- $myv:href -->
   <xsl:variable name="Q{urn:x-xspec:compile:impl}variable-...-uri"
                 as="Q{http://www.w3.org/2001/XMLSchema}anyURI">.../test-data.xml</xsl:variable>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}variable-...-doc"
                 as="document-node()"
                 select="doc($Q{urn:x-xspec:compile:impl}variable-...-uri)"/>
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
   <xsl:variable name="Q{http://example.org/ns/my/variable}content"
                 as="element()"
                 select="$Q{urn:x-xspec:compile:impl}variable-...-doc ! ( node() )"/>

   ...
</xsl:template>
```

### Query

```xquery
declare function local:scenario1(
)
{
...

(: $myv:select :)
let $Q{http://example.org/ns/my/variable}select := (
'value'
)

(: $myv:href :)
let $Q{urn:x-xspec:compile:impl}variable-...-uri as xs:anyURI := (
xs:anyURI(".../test-data.xml")
)
let $Q{urn:x-xspec:compile:impl}variable-...-doc as document-node() := (
doc($Q{urn:x-xspec:compile:impl}variable-...-uri)
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

[compilation-variables-scope.xspec](compilation-variables-scope.xspec)

```xml
<x:variable name="myv:global" select="'global-value'"/>

<x:scenario label="outer">
   <x:variable name="myv:var-1" select="'var-1-value'"/>

   <x:scenario label="inner">
      <x:variable name="myv:var-2" select="'var-2-value'"/>
      <x:call function="my:square">
         <x:param select="0"/>
      </x:call>

      <x:variable name="myv:var-3" select="'var-3-value'"/>
      <x:expect label="expect one" .../>

      <x:variable name="myv:var-4" select="'var-4-value'"/>
      <x:expect label="expect two" .../>
   </x:scenario>
</x:scenario>
```

### Stylesheet

```xml
<!-- the generated global variable -->
<xsl:variable name="Q{http://example.org/ns/my/variable}global"
              select="'global-value'"/>

<!-- generated from the scenario outer -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1">
   <!-- the generated variable -->
   <xsl:variable name="Q{http://example.org/ns/my/variable}var-1" select="'var-1-value'" />
   ...
   <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1">
      <!-- pass the variable to inner context -->
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-1" select="$Q{http://example.org/ns/my/variable}var-1"/>
   </xsl:call-template>
</xsl:template>

<!-- generated from the scenario inner -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1">
   <!-- the variable is passed as param -->
   <xsl:param name="Q{http://example.org/ns/my/variable}var-1" required="yes"/>
   ...
   <!-- the generated variable -->
   <xsl:variable name="Q{http://example.org/ns/my/variable}var-2" select="'var-2-value'"/>
   ...
   <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
      <xsl:sequence select="Q{http://example.org/ns/my}square(...)"/>
   </xsl:variable>
   ...
   <!-- the generated variable -->
   <xsl:variable name="Q{http://example.org/ns/my/variable}var-3" select="'var-3-value'"/>
   <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1-expect1">
      <xsl:with-param name="Q{http://www.jenitennison.com/xslt/xspec}result"
                      select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-1"
                      select="$Q{http://example.org/ns/my/variable}var-1"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-2"
                      select="$Q{http://example.org/ns/my/variable}var-2"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-3"
                      select="$Q{http://example.org/ns/my/variable}var-3"/>
   </xsl:call-template>
   <!-- the generated variable -->
   <xsl:variable name="Q{http://example.org/ns/my/variable}var-4" select="'var-4-value'"/>
   <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1-expect2">
      <xsl:with-param name="Q{http://www.jenitennison.com/xslt/xspec}result"
                      select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-1"
                      select="$Q{http://example.org/ns/my/variable}var-1"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-2"
                      select="$Q{http://example.org/ns/my/variable}var-2"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-3"
                      select="$Q{http://example.org/ns/my/variable}var-3"/>
      <xsl:with-param name="Q{http://example.org/ns/my/variable}var-4"
                      select="$Q{http://example.org/ns/my/variable}var-4"/>
   </xsl:call-template>
</xsl:template>

<!-- generated from the expect one -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1-expect1">
   <xsl:param name="Q{http://www.jenitennison.com/xslt/xspec}result" required="yes"/>
   <!-- the variables are passed as param -->
   <xsl:param name="Q{http://example.org/ns/my/variable}var-1" required="yes"/>
   <xsl:param name="Q{http://example.org/ns/my/variable}var-2" required="yes"/>
   <xsl:param name="Q{http://example.org/ns/my/variable}var-3" required="yes"/>
   ... evaluate the expectations ...
</xsl:template>

<!-- generated from the expect two -->
<xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1-expect2">
   <xsl:param name="Q{http://www.jenitennison.com/xslt/xspec}result" required="yes"/>
   <!-- the variables are passed as param -->
   <xsl:param name="Q{http://example.org/ns/my/variable}var-1" required="yes"/>
   <xsl:param name="Q{http://example.org/ns/my/variable}var-2" required="yes"/>
   <xsl:param name="Q{http://example.org/ns/my/variable}var-3" required="yes"/>
   <xsl:param name="Q{http://example.org/ns/my/variable}var-4" required="yes"/>
   ... evaluate the expectations ...
</xsl:template>
```

### Query

```xquery
(: the generated global variable :)
declare variable $Q{http://example.org/ns/my/variable}global := (
'global-value'
);

(: generated from the scenario outer :)
declare function local:scenario1(
)
{
...
(: the generated variable :)
let $Q{http://example.org/ns/my/variable}var-1 := (
'var-1-value'
)
let $Q{http://www.jenitennison.com/xslt/xspec}tmp := local:scenario1-scenario1(
(: pass the variable to inner context :)
$Q{http://example.org/ns/my/variable}var-1
)
return (
$Q{http://www.jenitennison.com/xslt/xspec}tmp
)
...
};

(: generated from the scenario inner :)
declare function local:scenario1-scenario1(
(: the variable is passed as param :)
$Q{http://example.org/ns/my/variable}var-1
)
{
(: the generated variable :)
let $Q{http://example.org/ns/my/variable}var-2 := (
'var-2-value'
)
return
...
let $Q{http://www.jenitennison.com/xslt/xspec}result := (
Q{http://example.org/ns/my}square(...)
)
return (
...,
(: the generated variable :)
let $Q{http://example.org/ns/my/variable}var-3 := (
'var-3-value'
)
let $Q{http://www.jenitennison.com/xslt/xspec}tmp := local:scenario1-scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result,
$Q{http://example.org/ns/my/variable}var-1,
$Q{http://example.org/ns/my/variable}var-2,
$Q{http://example.org/ns/my/variable}var-3
)
return (
$Q{http://www.jenitennison.com/xslt/xspec}tmp,
(: the generated variable :)
let $Q{http://example.org/ns/my/variable}var-4 := (
'var-4-value'
)
let $Q{http://www.jenitennison.com/xslt/xspec}tmp := local:scenario1-scenario1-expect2(
$Q{http://www.jenitennison.com/xslt/xspec}result,
$Q{http://example.org/ns/my/variable}var-1,
$Q{http://example.org/ns/my/variable}var-2,
$Q{http://example.org/ns/my/variable}var-3,
$Q{http://example.org/ns/my/variable}var-4
)
return (
$Q{http://www.jenitennison.com/xslt/xspec}tmp
)
)
)
}
};

(: generated from the expect one :)
declare function local:scenario1-scenario1-expect1(
$Q{http://www.jenitennison.com/xslt/xspec}result,
(: the variables are passed as param :)
$Q{http://example.org/ns/my/variable}var-1,
$Q{http://example.org/ns/my/variable}var-2,
$Q{http://example.org/ns/my/variable}var-3
)
{
...evaluate the expectations ...
};

(: generated from the expect two :)
declare function local:scenario1-scenario1-expect2(
$Q{http://www.jenitennison.com/xslt/xspec}result,
(: the variables are passed as param :)
$Q{http://example.org/ns/my/variable}var-1,
$Q{http://example.org/ns/my/variable}var-2,
$Q{http://example.org/ns/my/variable}var-3,
$Q{http://example.org/ns/my/variable}var-4
)
{
...evaluate the expectations ...
};
```
