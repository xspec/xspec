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

```xml
<?xml version="1.0" encoding="UTF-8"?>
<x:description
   xmlns:my="http://example.org/ns/my"
   xmlns:x="http://www.jenitennison.com/xslt/xspec"
   stylesheet="compilation-simple-suite.xsl"
   query="http://example.org/ns/my"
   query-at="compilation-simple-suite.xquery">

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
                xmlns:impl="urn:x-xspec:compile:xslt:impl"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:my="http://example.org/ns/my"
                version="2.0"
                exclude-result-prefixes="impl">
   <!-- the tested stylesheet -->
   <xsl:import href=".../compilation-simple-suite.xsl"/>
   <!-- an XSpec stylesheet providing tools -->
   <xsl:import href=".../xspec/src/compiler/generate-tests-utils.xsl"/>
   <xsl:include href=".../xspec/src/common/xspec-utils.xsl"/>
   <xsl:output name="x:report" method="xml" indent="yes"/>
   <xsl:variable name="x:xspec-uri" as="xs:anyURI">.../compilation-simple-suite.xspec</xsl:variable>
   <!-- the main template to run the suite -->
   <xsl:template name="x:main">
      <!-- info message -->
      <xsl:message>
         <xsl:text>Testing with </xsl:text>
         <xsl:value-of select="system-property('xsl:product-name')"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="system-property('xsl:product-version')"/>
      </xsl:message>
      <!-- set up the result document (the report) -->
      <xsl:result-document format="x:report">
         <x:report stylesheet=".../compilation-simple-suite.xsl"
                   date="{current-dateTime()}"
                   xspec=".../compilation-simple-suite.xspec">
            <!-- a call instruction for each top-level scenario -->
            <xsl:call-template name="x:scenario1"/>
         </x:report>
      </xsl:result-document>
   </xsl:template>

   <!-- generated from the x:scenario element -->
   <xsl:template name="x:scenario1">
      ...
      <!-- a call instruction for each x:expect element -->
      <xsl:call-template name="x:scenario1-expect1">
         ...
      </xsl:call-template>
   </xsl:template>

   <!-- generated from the x:expect element -->
   <xsl:template name="x:scenario1-expect1">
      ...
   </xsl:template>

</xsl:stylesheet>
```

### Query

```xquery
(: the tested library module :)
import module namespace my = "http://example.org/ns/my"
  at ".../compilation-simple-suite.xquery";
(: an XSpec library module providing tools :)
import module namespace test = "http://www.jenitennison.com/xslt/unit-test"
  at ".../src/compiler/generate-query-utils.xql";
import module "http://www.jenitennison.com/xslt/xspec"
  at ".../src/common/xspec-utils.xquery";

declare namespace x = "http://www.jenitennison.com/xslt/xspec";

(: generated from the x:scenario element :)
declare function local:scenario1()
{
  ...
  (: a call instruction for each x:expect element :)
  let $x:tmp := local:scenario1-expect1($x:result) return (
    $x:tmp
  )

  ...
};

(: generated from the x:expect element :)
declare function local:scenario1-expect1($x:result)
{
  ...
};

(: the query body of this main module, to run the suite :)
(: set up the result document (the report) :)
document {
<x:report xmlns:x="http://www.jenitennison.com/xslt/xspec"
          xmlns:my="http://example.org/ns/my"
          date="{current-dateTime()}"
          query="http://example.org/ns/my"
          query-at=".../compilation-simple-suite.xquery"
          xspec=".../compilation-simple-suite.xspec"> {
      (: a call instruction for each top-level scenario :)
      let $x:tmp := local:scenario1() return (
        $x:tmp
      )

}
</x:report>
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

```xml
<x:scenario label="scenario">
   <x:call function="my:f"/>
   <x:expect label="expectations" test="$x:result = 1"/>
</x:scenario>
```

### Stylesheet

```xml
<!-- generated from the x:scenario element -->
<xsl:template name="x:scenario1">
   <xsl:message>scenario</xsl:message>
   <x:scenario id="scenario1"
               xspec=".../compilation-simple-suite.xspec">
      <x:label>scenario</x:label>
      <x:call>
         <xsl:attribute name="function">my:f</xsl:attribute>
      </x:call>
      <xsl:variable name="x:result" as="item()*">
         <xsl:sequence select="my:f()"/>
      </xsl:variable>
      ... generate scenario data in the report ...
      <xsl:call-template name="x:scenario1-expect1">
         <xsl:with-param name="x:result" select="$x:result"/>
      </xsl:call-template>
   </x:scenario>
</xsl:template>

<!-- generated from the x:expect element -->
<xsl:template name="x:scenario1-expect1">
   <xsl:param name="x:result" required="yes"/>
   <!-- expected result -->
   <xsl:variable name="impl:expect-d6e4" select="()"/>
   <!-- wrap $x:result into a doc node if possible -->
   <xsl:variable name="impl:test-items" as="item()*">
      <xsl:choose>
         <xsl:when test="exists($x:result) and test:wrappable-sequence($x:result)">
            <xsl:sequence select="test:wrap-nodes($x:result)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$x:result"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <!-- evaluate the predicate with $x:result as context
        node if $x:result is a single node; if not, just
        evaluate the predicate -->
   <xsl:variable name="impl:test-result" as="item()*">
      <xsl:choose>
         <xsl:when test="count($impl:test-items) eq 1">
            <xsl:for-each select="$impl:test-items">
               <xsl:sequence select="$x:result = 1" version="2"/>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$x:result = 1" version="2"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <!-- did the test pass? -->
   <xsl:variable name="impl:boolean-test"
                 as="xs:boolean"
                 select="$impl:test-result instance of xs:boolean"/>
   <xsl:variable name="impl:successful"
                 as="xs:boolean"
                 select="if ($impl:boolean-test) then  boolean($impl:test-result) else test:deep-equal($impl:expect-d6e4, $impl:test-result, '')"/>
   ... generate test result in the report ...
</xsl:template>
```

### Query

```xquery
(: generated from the x:scenario element :)
declare function local:scenario1()
{
  ... generate scenario data in the report ...
  let $x:result := (
    my:f()
  )
    return (
      test:report-sequence($x:result, 'x:result'),
      let $x:tmp := local:scenario1-expect1($x:result) return (
        $x:tmp
      )
    )
};

(: generated from the x:expect element :)
declare function local:scenario1-expect1($x:result)
{
  let $local:expect-d6e4 := (: expected result (none here) :)
      ( () )
  let $local:test-items as item()* := $x:result
  let $local:test-result as item()* := (: evaluate the predicate :)
      ($x:result = 1)

  let $local:boolean-test as xs:boolean :=
    ($local:test-result instance of xs:boolean)
  let $local:successful as xs:boolean := (: did the test pass? :) (
    if ($local:boolean-test)
    then boolean($local:test-result)
    else test:deep-equal($local:expect-d6e4, $local:test-result, '')
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

```xml
<!-- apply template rules on a node (with x:apply) -->
<x:variable name="ctxt">
   <elem/>
</x:variable>
<x:apply select="$ctxt" mode="mode">
   <x:param name="p1" select="val1" tunnel="yes"/>
   <x:param name="p2" as="element()">
      <val2/>
   </x:param>
</x:apply>

<!-- call a function -->
<x:call function="my:f">
   <x:param select="val1"/>
   <x:param name="p2" as="element()">
      <val2/>
   </x:param>
</x:call>

<!-- call a named template -->
<x:call template="t">
   <x:param name="p1" select="val1"/>
   <x:param name="p2">
      <val2/>
   </x:param>
</x:call>

<!-- apply template rules on a node (with x:context) -->
<x:context>
   <elem/>
</x:context>
```

### Stylesheet

```xml
<xsl:variable name="ctxt" as="item()*">
   <elem/>
</xsl:variable>
<xsl:variable name="x:result" as="item()*">
   <xsl:variable name="p1" select="val1"/>
   <xsl:variable name="p2" as="element()">
      <val2/>
   </xsl:variable>
   ... error if "$ctxt instance of node()" is not true ...
   <xsl:apply-templates select="$ctxt" mode="mode">
      <xsl:with-param name="p1" select="$p1" tunnel="yes"/>
      <xsl:with-param name="p2" select="$p2"/>
   </xsl:apply-templates>
</xsl:variable>

<xsl:variable name="x:result" as="item()*">
   <xsl:variable name="..." select="val1"/>
   <xsl:variable name="...-doc" as="document-node()">
      <xsl:document>
         <val2/>
      </xsl:document>
   </xsl:variable>
   <xsl:variable name="p2" as="element()">
      <xsl:for-each select="$...-doc">
         <xsl:sequence select="node()"/>
      </xsl:for-each>
   </xsl:variable>
   <xsl:sequence select="my:f($..., $p2)"/>
</xsl:variable>

<xsl:variable name="x:result" as="item()*">
   <xsl:variable name="p1" select="val1"/>
   <xsl:variable name="...-doc" as="document-node()">
      <xsl:document>
         <val2/>
      </xsl:document>
   </xsl:variable>
   <xsl:variable name="p2" as="item()*">
      <xsl:for-each select="$...-doc">
         <xsl:sequence select="node()"/>
      </xsl:for-each>
   </xsl:variable>
   <xsl:call-template name="t">
      <xsl:with-param name="p1" select="$p1"/>
      <xsl:with-param name="p2" select="$p2"/>
   </xsl:call-template>
</xsl:variable>

<xsl:variable name="x:result" as="item()*">
   <xsl:variable name="...-doc" as="document-node()">
      <xsl:document>
         <elem/>
      </xsl:document>
   </xsl:variable>
   <xsl:variable name="..." as="item()*">
      <xsl:for-each select="$...-doc">
         <xsl:sequence select="node()"/>
      </xsl:for-each>
   </xsl:variable>
   <xsl:apply-templates select="$..."/>
</xsl:variable>
```

### Query

```
let $local:param-... := ( val1 )
let $local:param-...-doc as document-node() := ( document { <val2 xmlns:my="http://example.org/ns/my">{ () }
</val2> } )
let $p2 as element() := ( $local:param-...-doc ! ( node() ) )
let $x:result := (
  my:f($local:param-..., $p2)
)
```

## Variables

The `x:variable` element in the XSpec namespace defines an XSpec variable. Any number of `x:variable` elements can occur as a child of `x:description` or `x:scenario`. In `x:scenario`, an `x:variable` element can occur before or after `x:context`, `x:call`, `x:apply` (not implemented yet), or `x:expect`. XSpec variables can be redefined locally, but names of global XSpec variables must be unique. XSpec variables can be referenced in XPath expressions, such as in `@select` and `@test` attributes.

The first example shows how an XSpec variable maps to an `xsl:variable` element in generated XSLT code or a `let` statement in generated XQuery code.

### Test suite

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
<xsl:template name="x:scenario1">
   <!-- the generated variable -->
   <xsl:variable name="myv:var" select="'value'"/>
   <xsl:variable name="x:result" as="item()*">
      ... exercise the SUT ...
   </xsl:variable>
   ...
   <xsl:call-template name="x:scenario1-expect1">
      <xsl:with-param name="x:result" select="$x:result"/>
      <xsl:with-param name="myv:var" select="$myv:var"/>
   </xsl:call-template>
</xsl:template>

<!-- generated from the x:expect element -->
<xsl:template name="x:scenario1-expect1">
   <xsl:param name="x:result" required="yes"/>
   <xsl:param name="myv:var" required="yes"/>
   <!-- evaluate the expectation -->
   <xsl:variable name="impl:expect-d6e8" ...>
   <xsl:variable name="impl:test-items" ...>
   <xsl:variable name="impl:test-result" ...>
   <xsl:variable name="impl:boolean-test" ...>
   <!-- did the test pass? -->
   <xsl:variable name="impl:successful" ...>
   ... generate test result in the report ...
</xsl:template>
```

### Query

```xquery
(: generated from the x:scenario element :)
declare function local:scenario1()
{
  let $myv:var := ( 'value' )        (: the generated variable :)
  ...
  let $x:result := ... exercise the SUT ...
    return (
      ...,
      let $x:tmp := local:scenario1-expect1($x:result, $myv:var) return (
        $x:tmp
      )
    )
  ...
};

(: generated from the x:expect element :)
declare function local:scenario1-expect1($x:result, $myv:var)
{
  let $local:expect-d6e8    :=  ... (: expected result :)
  let $local:test-items as item()* := ...
  let $local:test-result as item()* := ...
  let $local:boolean-test as xs:boolean :=  ...
  let $local:successful as xs:boolean := ... (: did the test pass? :)
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

```xml
<x:variable name="myv:select"  select="'value'"/>
<x:variable name="myv:href"    href="test-data.xml"/>
<x:variable name="myv:content" as="element()">
   <elem/>
</x:variable>
```

### Stylesheet

```xml
<xsl:variable name="myv:select" select="'value'"/>

<xsl:variable name="myv:href-doc"
              as="document-node()"
              select="doc('.../test-data.xml')"/>
<xsl:variable name="impl:variable-d6e6-uri" as="xs:anyURI">.../test-data.xml</xsl:variable>
<xsl:variable name="impl:variable-d6e6-doc"
              as="document-node()"
              select="doc($impl:variable-d6e6-uri)"/>
<xsl:variable name="myv:href" as="item()*">
   <xsl:for-each select="$impl:variable-d6e6-doc">
      <xsl:sequence select="."/>
   </xsl:for-each>
</xsl:variable>

<xsl:variable name="impl:variable-d6e7-doc" as="document-node()">
   <xsl:document>
      <elem/>
   </xsl:document>
</xsl:variable>
<xsl:variable name="myv:content" as="element()">
   <xsl:for-each select="$impl:variable-d6e7-doc">
      <xsl:sequence select="node()"/>
   </xsl:for-each>
</xsl:variable>
```

### Query

```xquery
let $myv:select := ( 'value' )
let $local:variable-d6e6-uri as xs:anyURI := ( xs:anyURI(".../test-data.xml") )
let $local:variable-d6e6-doc as document-node() := ( doc($local:variable-d6e6-uri) )
let $myv:href := ( $local:variable-d6e6-doc ! ( . ) )
let $local:variable-d6e7-doc as document-node() := ( document { <elem xmlns:my="http://example.org/ns/my" xmlns:myv="http://example.org/ns/my/variable" xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema">{ () }
</elem> } )
let $myv:content as element() := ( $local:variable-d6e7-doc ! ( node() ) )
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

```xml
<x:variable name="myv:global" ...>
<x:scenario label="outer">
   <x:variable name="myv:var-1" ...>
   <x:scenario label="inner">
      <x:variable name="myv:var-2" ...>
      <x:call function="my:f"/>
      <x:variable name="myv:var-3" ...>
      <x:expect label="expect one" ...>
      <x:variable name="myv:var-4" ...>
      <x:expect label="expect two" ...>
   </x:scenario>
</x:scenario>
```

### Stylesheet

```xml
<xsl:variable name="myv:global" ...>

<!-- generated from the scenario outer -->
<xsl:template name="x:scenario1">
   <!-- the generated variable -->
   <xsl:variable name="myv:var-1" ...>
   ...
   <xsl:call-template name="x:scenario1-scenario1">
      <!-- pass the variable to inner context -->
      <xsl:with-param name="myv:var-1" select="$myv:var-1"/>
   </xsl:call-template>
</xsl:template>

<!-- generated from the scenario inner -->
<xsl:template name="x:scenario1-scenario1">
   <!-- the variable is passed as param -->
   <xsl:param name="myv:var-1" required="yes" ...>
   <!-- the generated variable -->
   <xsl:variable name="myv:var-2" ...>
   <xsl:variable name="x:result" as="item()*">
      <xsl:sequence select="my:f()"/>
   </xsl:variable>
   ...
   <!-- the generated variable -->
   <xsl:variable name="myv:var-3" ...>
   <xsl:call-template name="x:scenario1-scenario1-expect1">
      <xsl:with-param name="x:result"  select="$x:result"/>
      <xsl:with-param name="myv:var-1" select="$myv:var-1"/>
      <xsl:with-param name="myv:var-2" select="$myv:var-2"/>
      <xsl:with-param name="myv:var-3" select="$myv:var-3"/>
   </xsl:call-template>
   <!-- the generated variable -->
   <xsl:variable name="myv:var-4" ...>
   <xsl:call-template name="x:scenario1-scenario1-expect2">
      <xsl:with-param name="x:result"  select="$x:result"/>
      <xsl:with-param name="myv:var-1" select="$myv:var-1"/>
      <xsl:with-param name="myv:var-2" select="$myv:var-2"/>
      <xsl:with-param name="myv:var-3" select="$myv:var-3"/>
      <xsl:with-param name="myv:var-4" select="$myv:var-4"/>
   </xsl:call-template>
</xsl:template>

<!-- generated from the expect one -->
<xsl:template name="x:scenario1-scenario1-expect1">
   <xsl:param name="x:result" required="yes"/>
   <!-- the variables are passed as param -->
   <xsl:param name="myv:var-1" required="yes" ...>
   <xsl:param name="myv:var-2" required="yes" ...>
   <xsl:param name="myv:var-3" required="yes" ...>
   ... evaluate the expectations ...
</xsl:template>

<!-- generated from the expect two -->
<xsl:template name="x:scenario1-scenario1-expect2">
   <xsl:param name="x:result" required="yes"/>
   <!-- the variables are passed as param -->
   <xsl:param name="myv:var-1" required="yes" ...>
   <xsl:param name="myv:var-2" required="yes" ...>
   <xsl:param name="myv:var-3" required="yes" ...>
   <xsl:param name="myv:var-4" required="yes" ...>
   ... evaluate the expectations ...
</xsl:template>
```

### Query

```xquery
declare variable $myv:global := ...;

(: generated from the scenario outer :)
declare function local:scenario1()
{
  ...
  let $myv:var-1 := ...
  let $x:tmp := local:scenario1-scenario1($myv:var-1)
    return (
      $x:tmp
    )
  ...
};

(: generated from the scenario inner :)
declare function local:scenario1-scenario1($myv:var-1) (: $myv:var-1 can have an "as" clause :)
{
  ...
  let $myv:var-2        := ...
  ...
  let $x:result := f()
    return (
      ...,
      let $myv:var-3 := ...
      let $x:tmp := local:scenario1-scenario1-expect1($x:result, $myv:var-1, $myv:var-2, $myv:var-3) return (
        $x:tmp,
        let $myv:var-4 := ...
        let $x:tmp := local:scenario1-scenario1-expect2($x:result, $myv:var-1, $myv:var-2, $myv:var-3, $myv:var-4) return (
          $x:tmp
        )
      )
    )
};

(: generated from the expect one :)
declare function local:scenario1-scenario1-expect1($x:result as item()*, $myv:var-1, $myv:var-2, $myv:var-3)
{
  ...evaluate the expectations ...
};

(: generated from the expect two :)
declare function local:scenario1-scenario1-expect2($x:result as item()*, $myv:var-1, $myv:var-2, $myv:var-3, $myv:var-4)
{
  ...evaluate the expectations ...
};
```
