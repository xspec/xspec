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

Those examples could be the base for test cases, too, developed as an automated test suite.

## Simple suite

Show the structure of a compiled test suite, both in XSLT and XQuery.

### Test suite

```xml
<t:description xmlns:t="http://www.jenitennison.com/xslt/xspec"
               xmlns:q="http://example.org/ns/query"
               query="http://example.org/ns/query"
               stylesheet="http://example.org/ns/stylesheet.xsl">

   <t:scenario label="scenario">
      <t:call function="f"/>
      <t:expect label="expectations" test="predicate"/>
   </t:scenario>

</t:description>
```

### Stylesheet

```xml
<xsl:stylesheet xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:o="http://www.w3.org/1999/XSL/TransformAliasAlias"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:impl="urn:x-xspec:compile:xslt:impl"
                xmlns:t="http://www.jenitennison.com/xslt/xspec"
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

declare namespace t = "http://www.jenitennison.com/xslt/xspec";
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
declare function local:d4e4($t:result as item()*)
{
  ...
};

(: the query body of this main module, to run the suite :)
(: setup the result document (the report) :)
<t:report xmlns:t="http://www.jenitennison.com/xslt/xspec"
          date="2010-01-28T22:45:03.649+01:00"
          query="http://example.org/ns/query">
{
  (: a call instruction for each top-level scenario :)
  local:d4e2()
}
</t:report>
```

## Simple scenario

Show the structure of a compiled scenario, both in XSLT and
XQuery.  The general idea is to generate a template for the
scenario (or a function in XQuery), that calls the [SUT](#sut) (or System Under Test) and puts
the result in a variable, `$x:result`.  A separate template (or function in
XQuery) is generated for each expectation, and those templates (or
functions) are called from the first one, in sequence, with the
result as parameter.

### Test suite

```xml
<t:scenario label="scenario">
   <t:call function="f"/>
   <t:expect label="expectations" test="predicate"/>
</t:scenario>
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
   <!-- wrap $t:result into a doc node if node()+ -->
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
   <!-- evaluate the predicate with $t:result as context
        node if $t:result is a single node, if not just
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
  let $x:result := f()
    return (
      local:d4e4($x:result)
    )
};

(: generated from the expect element :)
declare function local:d4e4($t:result as item()*)
{
  let $local:expected    :=                  (: expected result (none here) :)
      (  )
  let $local:test-result :=                  (: evaluate the predicate :)
      if ( $t:result instance of node() ) then
        $t:result/( predicate )
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
the former represents more a full transform (e.g., the result is
always one document node) where `apply` is exactly the result of a
template rule (the result is the exact result sequence or the
rule).

Those examples show only what is related to the call of the SUT in
the template (or function) generated from the scenario (see the
section "[Simple scenario](#simple-scenario)").

### Test suite

```xml
<!-- apply template rules on a node (with t:apply) -->
<t:variable name="ctxt">
   <elem/>
</t:variable>
<t:apply select="$ctxt" mode="mode">
   <t:param name="p1" select="val1" tunnel="yes"/>
   <t:param name="p2" as="element()">
      <val2/>
   </t:param>
</t:apply>

<!-- call a function -->
<t:call function="f">
   <t:param select="val1"/>
   <t:param name="p2" as="element()">
      <val2/>
   </t:param>
</t:call>

<!-- call a named template -->
<t:call template="t">
   <t:param name="p1" select="val"/>
   <t:param name="p2">
      <val2/>
   </t:param>
</t:call>

<!-- apply template rules on a node (with t:context) -->
<t:context>
   <elem/>
</t:context>
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

[Variables have been supported since version (TBD).]

The `variable` element in the XSpec namespace defines an XSpec variable. Any number of `variable` elements can occur before or after `context`, `call`, `apply` (not implemented yet), or the first `expect`. XSpec variables can be referenced in XPath expressions, such as in `@select` and `@test` attributes.

The first example shows how an XSpec variable maps to an `xsl:variable` element in generated XSLT code or a `let` statement in generated XQuery code.

### Test suite

```xml
<t:scenario label="scenario">
   <t:variable name="var" select="'value'"/>
   ...
   <t:expect .../>
</t:scenario>
```

### Stylesheet

```xml
<!-- generated from the scenario element -->
<xsl:template name="x:d4e2">
   <!-- the generated variable -->
   <xsl:variable name="var" select="'value'"/>
   <xsl:variable name="x:result" as="item()*">
      ... exercise the SUT ...
   </xsl:variable>
   ...
   <xsl:call-template name="x:d4e4">
      <xsl:with-param name="x:result" select="$x:result"/>
      <xsl:with-param name="var" select="$var"/>
   </xsl:call-template>
</xsl:template>

<!-- generated from the expect element -->
<xsl:template name="x:d4e4">
   <xsl:param name="x:result" required="yes"/>
   <xsl:param name="var" required="yes"/>
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
  let $var := ( 'value' )        (: the generated variable :)
  ...
  let $x:result := ... exercise the SUT ...
    return (
      ...,
      let $x:tmp := local:d4e4($x:result, $var) return (
        $x:tmp
      )
    )
  ...
};

(: generated from the expect element :)
declare function local:d4e4($x:result, $var)
{
  let $local:expected    :=  ... (: expected result :)
  let $local:successful as xs:boolean := ... (: did the test pass?:)
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

The resulting variables become accessible from the code generated
for the `scenario` and `expect` elements. See "[Variables scope](#variables-scope)"
below for details on how the generated stylesheet or query achieves
this accessibility.

### Test suite

```xml
<t:variable name="select"  select="'value'"/>
<t:variable name="href"    href="test-data.xml"/>
<t:variable name="content" as="element()">
   <elem/>
</t:variable>
```

### Stylesheet

```xml
<xsl:variable name="select" select="'value'"/>
<xsl:variable name="href-doc"
              as="document-node()"
              select="doc('.../test-data.xml')"/>
<xsl:variable name="href" select="$href-doc"/>
<xsl:variable name="content-doc" as="document-node()">
   <xsl:document>
      <elem/>
   </xsl:document>
</xsl:variable>
<xsl:variable name="content" as="element()" select="$content-doc/node()"/>
```

### Query

```xquery
let $select := ( 'value' )
let $href := doc('.../test-data.xml')
let $content as element() := ( <elem/> )
```

## Variables scope

In a given scenario, the variables in scope are:

- Local variables defined in that scenario
- Variables defined as children of an ancestor scenario
- Global variables defined as children of `description`

This example shows where variables are generated depending on their scope.
It is worth noting the first implementation of this was to generate
variables several times if needed, e.g., if they were in scope in
a scenario and expectations (see the revision r78, a revision before changed by [r79](https://groups.google.com/forum/#!topic/xspec-dev/K25fP9Zb--4), of this page
for an example).  But this would lead to several evaluations of
the same thing (which could lead to being less efficient, and to
subtle bugs in case of side-effects). So instead, variables are
evaluated once, and then passed as parameters (to templates in XSLT
and functions in XQuery).

### Test suite

```xml
<t:variable name="global" ...>
<t:scenario label="outer">
   <t:variable name="var-1" ...>
   <t:scenario label="inner">
      <t:variable name="var-2" ...>
      <t:call function="f"/>
      <t:variable name="var-3" ...>
      <t:expect label="expect one" ...>
      <t:variable name="var-4" ...>
      <t:expect label="expect two" ...>
   </t:scenario>
</t:scenario>
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
      ...,
      let $x:tmp := local:d4e3($var-1) return (
        $x:tmp
      )
    )
};

(: generated from the scenario inner :)
declare function local:d4e3($var-1) (: $var-1 can have a "as" clause :)
{
  ...
  let $var-2        := ...
  let $x:result := f()
    return (
      ...,
      let $var-3 := ...
      let $x:tmp := local:d5e11($x:result, $var-1, $var-2, $var-3) return (
        $x:tmp,
        let $var-4 := ...
        let $x:tmp := local:d5e13($x:result, $var-1, $var-2, $var-3, $var-4) return (
          $x:tmp
        )
      )
    )
};

(: generated from the expect one :)
declare function local:d4e4($t:result as item()*, $var-1, $var-2, $var-3)
{
  ...evaluate the expectations ...
};

(: generated from the expect two :)
declare function local:d4e5($t:result as item()*, $var-1, $var-2, $var-3, $var-4)
{
  ...evaluate the expectations ...
};
```
