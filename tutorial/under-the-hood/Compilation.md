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

The generated stylesheets and queries are not shown in their entirety.  In particular, the code generating parts of the final report has been removed, except in examples specifically intended to show how this is done.  The root elements of test suites are omitted, and indentation and comments have been added where appropriate.

The goal is to make the compilation phase clearer, mostly for development purposes.

Those examples could be the base for test cases too developed as an automated test suite.

## Simple suite

Show the structure of a compiled test suite, both in XSLT and XQuery.

### Test suite

```xml
<x:description xmlns:x="http://www.jenitennison.com/xslt/xspec"
               xmlns:q="http://example.org/ns/query"
               query="http://example.org/ns/query"
               stylesheet="http://example.org/ns/stylesheet.xsl">

   <x:scenario label="scenario">
      <x:call function="f"/>
      <x:expect label="expectations" test="predicate"/>
   </x:scenario>

</x:description>
```

### Stylesheet

```xml
<xsl:stylesheet xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:o="http://www.w3.org/1999/XSL/TransformAliasAlias"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:impl="urn:x-xspec:compile:xslt:impl"
                xmlns:q="http://example.org/ns/query"
                version="2.0">

   <!-- the tested stylesheet -->
   <xsl:import href="http://example.org/ns/stylesheet.xsl"/>
   <!-- an XSPec stylesheet providing tools -->
   <xsl:import href=".../generate-tests-utils.xsl"/>

   <xsl:namespace-alias stylesheet-prefix="o" result-prefix="xsl"/>

   <xsl:output name="report" method="xml" indent="yes"/>

   <!-- the tested stylesheet -->
   <xsl:variable name="x:stylesheet-uri" as="xs:string"
                 select="'http://example.org/ns/stylesheet.xsl'"/>

   <!-- the main template to run the suite -->
   <xsl:template name="x:main">
      <!-- info message -->
      <xsl:message>
         <xsl:text>Testing with </xsl:text>
         <xsl:value-of select="system-property('xsl:product-name')"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="system-property('xsl:product-version')"/>
      </xsl:message>
      <!-- setup the result document (the report) -->
      <xsl:result-document format="report">
         <xsl:processing-instruction name="xml-stylesheet">
            <xsl:text>type="text/xsl" href=".../format-xspec-report.xsl"</xsl:text>
         </xsl:processing-instruction>
         <x:report stylesheet="{ $x:stylesheet-uri }" date="{ current-dateTime() }">
            <!-- a call instruction for each top-level scenario -->
            <xsl:call-template name="x:d4e2"/>
         </x:report>
      </xsl:result-document>
   </xsl:template>

   <!-- generated from the scenario element -->
   <xsl:template name="x:d4e2">
      ...
      <!-- a call instruction for each expect element -->
      <xsl:call-template name="x:d4e4">
         ...
      </xsl:call-template>
   </xsl:template>

   <!-- generated from the expect element -->
   <xsl:template name="x:d4e4">
      ...
   </xsl:template>

</xsl:stylesheet>
```

### Query

```xquery
(: the tested library module :)
import module namespace q = "http://example.org/ns/query";
(: an XSPec library module providing tools :)
import module namespace test = "http://www.jenitennison.com/xslt/unit-test"
  at ".../generate-query-utils.xql";

declare namespace x = "http://www.jenitennison.com/xslt/xspec";

(: generated from the scenario element :)
declare function local:d4e2()
{
  ...
  (: a call instruction for each expect element :)
  local:d4e4($result)
  ...
};

(: generated from the expect element :)
declare function local:d4e4($x:result as item()*)
{
  ...
};

(: the query body of this main module, to run the suite :)
(: setup the result document (the report) :)
<x:report xmlns:x="http://www.jenitennison.com/xslt/xspec"
          date="2010-01-28T22:45:03.649+01:00"
          query="http://example.org/ns/query">
{
  (: a call instruction for each top-level scenario :)
  local:d4e2()
}
</x:report>
```

## Simple scenario

Show the structure of a compiled scenario, both in XSLT and
XQuery.  The general idea is to generate a template for the
scenario (or a function in XQuery), that calls the [SUT](#sut) and puts
the result in a variable (`$x:result` in XSLT and
`$local:result` in XQuery).  A separate template (or function in
XQuery) is generated for each expectation, and those templates (or
functions) are called from the first one, in sequence, with the
result as parameter.

### Test suite

```xml
<x:scenario label="scenario">
   <x:call function="f"/>
   <x:expect label="expectations" test="predicate"/>
</x:scenario>
```

### Stylesheet

```xml
<!-- generated from the scenario element -->
<xsl:template name="x:d4e2">
   <x:call function="f"/>
   <xsl:variable name="x:result" as="item()*">
      <xsl:sequence select="f()"/>
   </xsl:variable>
   ... generate scenario data in the report ...
   <xsl:call-template name="x:d4e4">
      <xsl:with-param name="x:result" select="$x:result"/>
   </xsl:call-template>
</xsl:template>

<!-- generated from the expect element -->
<xsl:template name="x:d4e4">
   <xsl:param name="x:result" required="yes"/>
   <!-- expected result (none here) -->
   <xsl:variable name="impl:expected" select="()"/>
   <!-- wrap $x:result into a doc node if node()+ -->
   <xsl:variable name="impl:test-items" as="item()*">
      <xsl:choose>
         <xsl:when test="$x:result instance of node()+">
            <xsl:document>
               <xsl:copy-of select="$x:result"/>
            </xsl:document>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="$x:result"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <!-- evaluate the predicate with $x:result as context
        node if $x:result is a single node, if not just
        evaluate the predicate -->
   <xsl:variable name="impl:test-result" as="item()*">
      <xsl:choose>
         <xsl:when test="count($impl:test-items) eq 1">
            <xsl:for-each select="$impl:test-items">
               <xsl:sequence select="predicate" version="2"/>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:sequence select="predicate" version="2"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:variable>
   <!-- did the test pass? -->
   <xsl:variable name="impl:boolean-test" as="xs:boolean"
                 select="$impl:test-result instance of xs:boolean"/>
   <xsl:variable name="impl:successful" as="xs:boolean" select="
       if ( $impl:boolean-test ) then
         $impl:test-result
       else
         test:deep-equal($impl:expected, $impl:test-result, 2)"/>
   ... generate test result in the report ...
</xsl:template>
```

### Query

```xquery
(: generated from the scenario element :)
declare function local:d4e2()
{
  ... generate scenario data in the report ...
  let $local:result := f()
    return (
      local:d4e4($local:result)
    )
};

(: generated from the expect element :)
declare function local:d4e4($x:result as item()*)
{
  let $local:expected    :=                  (: expected result (none here) :)
      (  )
  let $local:test-result :=                  (: evaluate the predicate :)
      if ( $x:result instance of node() ) then
        $x:result/( predicate )
      else
        ( predicate )
  let $local:successful  :=                  (: did the test pass?:)
      if ( $local:test-result instance of xs:boolean ) then
        $local:test-result
      else
        test:deep-equal($local:expected, $local:test-result)
    return
      ... generate test result in the report ...
};
```

## SUT

The SUT (or System Under Test) is the component tested in a
scenario.  In XSpec, this is either an XSLT template (named or
rule) or an XPath function (written either in XSLT or XQuery).
Here, we use it to refer to the three ways to refer to the SUT
itself, as well as parameters to use for the current scenario:
`apply`, `call` and `context` (so that's not strictly speaking
the SUT itself, but rather the way to "call" it for this
scenario).

`apply` represents applying a template rule to a node (this is not
possible in XQuery), and corresponds naturally to
`xsl:apply-templates`.  `call` represents a call either to a named
template or an XPath function.  `context` also represents applying
a template rule to a node, but in a different way than `apply`:
the former represents more a full transform (e.g. the result is
always one document node) where `apply` is exactly the result of a
template rule (the result is the exact result sequence or the
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
<x:call function="f">
   <x:param select="val1"/>
   <x:param name="p2" as="element()">
      <val2/>
   </x:param>
</x:call>

<!-- call a named template -->
<x:call template="t">
   <x:param name="p1" select="val"/>
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
   <xsl:variable name="..." select="val"/>
   <xsl:variable name="p2" as="element()">
      <val2/>
   </xsl:with-param>
   <xsl:sequence select="f($..., $p2)"/>
</xsl:variable>

<xsl:variable name="x:result" as="item()*">
   <xsl:variable name="p1" select="val"/>
   <xsl:variable name="p2" as="item()*">
      <val2/>
   </xsl:with-param>
   <xsl:call-template name="t">
      <xsl:with-param name="p1" select="$p1"/>
      <xsl:with-param name="p2" select="$p2"/>
   </xsl:call-template>
</xsl:variable>

<xsl:variable name="x:result" as="item()*">
   <xsl:variable name="context-doc" as="document-node()">
      <xsl:document>
         <elem/>
      </xsl:document>
   </xsl:variable>
   <xsl:variable name="context" select="$context-doc/node()"/>
   <xsl:apply-templates select="$context"/>
</xsl:variable>
```

### Query

```
TODO: ...
```

## Variables

This is not implemented yet, but this is an example of what they
will look like.

### Test suite

```xml
<x:scenario label="scenario">
   <x:variable name="var" select="'value'"/>
   ...
   <x:expect .../>
</x:scenario>
```

### Stylesheet

```xml
<!-- generated from the scenario element -->
<xsl:template name="x:d4e2">
   <!-- the generated variable -->
   <xsl:variable name="var" select="'value'"/>
   <xsl:variable name="x:result" as="item()*">
      ... evaluate the test expression ...
   </xsl:variable>
   ...
   <xsl:call-template name="x:d4e4">
      <xsl:with-param name="x:result" select="$x:result"/>
   </xsl:call-template>
</xsl:template>

<!-- generated from the expect element -->
<xsl:template name="x:d4e4">
   <xsl:param name="x:result" required="yes"/>
   <!-- the generated variable -->
   <xsl:variable name="var" select="'value'"/>
   <!-- evaluate the expectation -->
   <xsl:variable name="impl:expected" ...>
   <xsl:variable name="impl:test-items" ...>
   <xsl:variable name="impl:test-result" ...>
   ...
</xsl:template>
```

### Query

```xquery
(: generated from the scenario element :)
declare function local:d4e2()
{
  ...
  let $var          := 'value'               (: the generated variable :)
  let $local:result := ... evaluate the test expression ...
    return (
      local:d4e4($local:result)
    )
};

(: generated from the expect element :)
declare function local:d4e4($x:result as item()*)
{
  let $var               := 'value'          (: the generated variable :)
  let $local:expected    := ...              (: expected result :)
  let $local:test-result := ...              (: evaluate the expectations :)
  let $local:successful  := ...              (: did the test pass?:)
    return
      ... generate test result in the report ...
};
```

## Variable value

Here is an example of three variables, one using `@select`, one
using content, and one using `@href`.  The `href` attribute is
to load a document from a file (relative to the test suite
document). As with `x:param`,
content and `@href` are mutually exclusive. The `@select` attribute can appear alone or in combination with either content or `@href`.

The resulting variables must appear once in the code
generated for the `scenario` element and once in the code
generated for the `expect` element (well, define more precisely
the scope of the variables, I think we should be able to put them
everywhere, and the scope must "natural" when looking at the test
suite definition).

### Test suite

```xml
<x:variable name="select"  select="'value'"/>
<x:variable name="href"    href="test-data.xml"/>
<x:variable name="content" as="element()">
   <elem/>
</x:variable>
```

### Stylesheet

```xml
<xsl:variable name="select" select="'value'"/>
<xsl:variable name="href"   select="doc('.../test-data.xml')"/>
<xsl:variable name="content" as="element()">
   <elem/>
</xsl:variable>
```

### Query

```xquery
let $select := 'value'
let $href   := doc('.../test-data.xml')
let $content as element() := <elem/>
```

## Variables scope

This shows where variables are generated regarding their scope.
It is worth noting the first definition of this was to generate
variables several times if needed, e.g. if they were in scope in
a scenario and expectations (see the revision r78, a revision before changed by [r79](https://groups.google.com/forum/#!topic/xspec-dev/K25fP9Zb--4), of this page
for an example).  But this would lead to several evaluations of
the same thing (which could lead to being less efficient, and to
subtle bugs in case of side-effects). So instead, variables are
evaluated once, then passed as parameters (to templates in XSLT
and functions in XQuery).

### Test suite

```xml
<x:variable name="global" ...>
<x:scenario label="outer">
   <x:variable name="var-1" ...>
   <x:scenario label="inner">
      <x:variable name="var-2" ...>
      <x:call function="f"/>
      <x:variable name="var-3" ...>
      <x:expect label="expect one" ...>
      <x:variable name="var-4" ...>
      <x:expect label="expect two" ...>
   </x:scenario>
</x:scenario>
```

### Stylesheet

```xml
<xsl:variable name="global" ...>

<!-- generated from the scenario outer -->
<xsl:template name="x:d4e2">
   <!-- the generated variable -->
   <xsl:variable name="var-1" ...>
   ...
   <xsl:call-template name="x:d4e3">
      <!-- pass the variable to inner context -->
      <xsl:with-param name="var-1" select="$var-1"/>
   </xsl:call-template>
</xsl:template>

<!-- generated from the scenario inner -->
<xsl:template name="x:d4e3">
   <!-- the variable is passed as param -->
   <xsl:param name="var-1" required="yes" ...>
   <!-- the generated variable -->
   <xsl:variable name="var-2" ...>
   <xsl:variable name="x:result" as="item()*">
      <xsl:sequence select="f()"/>
   </xsl:variable>
   ...
   <!-- the generated variable -->
   <xsl:variable name="var-3" ...>
   <xsl:call-template name="x:d4e4">
      <xsl:with-param name="x:result" select="$x:result"/>
      <xsl:with-param name="var-1"    select="$var-1"/>
      <xsl:with-param name="var-2"    select="$var-2"/>
      <xsl:with-param name="var-3"    select="$var-3"/>
   </xsl:call-template>
   <!-- the generated variable -->
   <xsl:variable name="var-4" ...>
   <xsl:call-template name="x:d4e5">
      <xsl:with-param name="x:result" select="$x:result"/>
      <xsl:with-param name="var-1"    select="$var-1"/>
      <xsl:with-param name="var-2"    select="$var-2"/>
      <xsl:with-param name="var-3"    select="$var-3"/>
      <xsl:with-param name="var-4"    select="$var-4"/>
   </xsl:call-template>
</xsl:template>

<!-- generated from the expect one -->
<xsl:template name="x:d4e4">
   <xsl:param name="x:result" required="yes"/>
   <!-- the variables are passed as param -->
   <xsl:param name="var-1" required="yes" ...>
   <xsl:param name="var-2" required="yes" ...>
   <xsl:param name="var-3" required="yes" ...>
   ... evaluate the expectations ...
</xsl:template>

<!-- generated from the expect two -->
<xsl:template name="x:d4e5">
   <xsl:param name="x:result" required="yes"/>
   <!-- the variables are passed as param -->
   <xsl:param name="var-1" required="yes" ...>
   <xsl:param name="var-2" required="yes" ...>
   <xsl:param name="var-3" required="yes" ...>
   <xsl:param name="var-4" required="yes" ...>
   ... evaluate the expectations ...
</xsl:template>
```

### Query

```xquery
declare variable $global := ...;

(: generated from the scenario outer :)
declare function local:d4e2()
{
  ...
  let $var-1 := ...
  ...
    return (
      local:d4e3($var-1)
    )
};

(: generated from the scenario inner :)
declare function local:d4e3($var-1) (: $var-1 can have a "as" clause :)
{
  ...
  let $var-2        := ...
  let $local:result := f()
    return (
      let $var-3 := ...
        return (
          local:d4e4($local:result, $var-1, $var-2, $var-3),
          let $var-4 := ...
            return (
              local:d4e5($local:result, $var-1, $var-2, $var-3, $var-4)
            )
        )
    )
};

(: generated from the expect one :)
declare function local:d4e4($x:result as item()*, $var-1, $var-2, $var-3)
{
  ...evaluate the expectations ...
};

(: generated from the expect two :)
declare function local:d4e5($x:result as item()*, $var-1, $var-2, $var-3, $var-4)
{
  ...evaluate the expectations ...
};
```
