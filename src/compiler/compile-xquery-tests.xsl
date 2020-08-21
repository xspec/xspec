<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       compile-xquery-tests.xsl                                 -->
<!--  Author:     Jeni Tennison                                            -->
<!--  URL:        http://github.com/xspec/xspec                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2008, 2010 Jeni Tennison (see end of file.)          -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<xsl:stylesheet xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <xsl:import href="generate-common-tests.xsl"/>
   <xsl:import href="generate-query-helper.xsl"/>

   <pkg:import-uri>http://www.jenitennison.com/xslt/xspec/compile-xquery-tests.xsl</pkg:import-uri>

   <xsl:output omit-xml-declaration="yes" use-character-maps="x:disable-escaping" />

   <!--
       The special value '#none' is used to generate no "at" clause at
       all.

       By default, the URI is generated as a file relative to this
       stylesheet (because it comes with it in the XSpec release, but
       accessing the module on the file system is not always the best
       option, for instance for XML databases like eXist or
       MarkLogic).
   -->
   <xsl:param name="utils-library-at" as="xs:string?" />

   <!-- TODO: The at hint should not be always resolved (e.g. for MarkLogic). -->
   <xsl:param name="query-at" as="xs:string?"
      select="$initial-document/x:description/@query-at/resolve-uri(., base-uri())"/>

   <!--
      mode="x:generate-tests"
   -->
   <xsl:template match="x:description" as="node()+" mode="x:generate-tests">
      <xsl:variable name="this" select="." as="element(x:description)" />

      <!-- Version declaration -->
      <xsl:text expand-text="yes">xquery version "{($this/@xquery-version, '3.1')[1]}";&#x0A;</xsl:text>

      <!-- Import module to be tested -->
      <xsl:text>&#x0A;</xsl:text>
      <xsl:text>(: the tested library module :)&#10;</xsl:text>
      <xsl:text expand-text="yes">import module "{$this/@query}"</xsl:text>
      <xsl:if test="exists($query-at)">
         <xsl:text expand-text="yes">&#x0A;at "{$query-at}"</xsl:text>
      </xsl:if>
      <xsl:text>;&#10;</xsl:text>

      <!-- Import helpers -->
      <xsl:if test="x:helper">
         <xsl:text>&#x0A;</xsl:text>
         <xsl:text>(: user-provided library module(s) :)&#x0A;</xsl:text>
         <xsl:call-template name="x:compile-helpers" />
      </xsl:if>

      <!-- Import utils -->
      <xsl:text>&#x0A;</xsl:text>
      <xsl:text>(: XSpec library modules providing tools :)&#x0A;</xsl:text>
      <xsl:variable name="utils" as="map(xs:anyURI, xs:string)"
         select="
            map {
               $x:deq-namespace:   '../common/deep-equal.xqm',
               $x:rep-namespace:   '../common/report-sequence.xqm',
               $x:xspec-namespace: '../common/xspec-utils.xqm'
            }" />
      <xsl:for-each select="map:keys($utils)">
         <xsl:sort />

         <xsl:text expand-text="yes">import module "{.}"</xsl:text>
         <xsl:if test="not($utils-library-at eq '#none')">
            <xsl:text expand-text="yes">&#x0A;at "{$utils(.) => resolve-uri()}"</xsl:text>
         </xsl:if>
         <xsl:text>;&#x0A;</xsl:text>
      </xsl:for-each>

      <xsl:text>&#x0A;</xsl:text>

      <!-- Declare namespaces. User-provided XPath expressions may use namespace prefixes.
         Unlike XSLT, XQuery requires them to be declared globally. -->
      <xsl:for-each select="x:copy-of-namespaces($initial-document/x:description)[name() (: Exclude the default namespace :)]">
         <xsl:text expand-text="yes">declare namespace {name()} = "{string()}";&#x0A;</xsl:text>
      </xsl:for-each>

      <!-- Serialization parameters for the test result report XML -->
      <xsl:text expand-text="yes">declare option {x:known-UQName('output:parameter-document')} "{resolve-uri('../common/xml-report-serialization-parameters.xml')}";&#x0A;</xsl:text>

      <!-- Absolute URI of the master .xspec file -->
      <xsl:call-template name="x:declare-or-let-variable">
         <xsl:with-param name="is-global" select="true()" />
         <xsl:with-param name="name" select="x:known-UQName('x:xspec-uri')" />
         <xsl:with-param name="type" select="'xs:anyURI'" />
         <xsl:with-param name="value" as="text()">
            <xsl:text expand-text="yes">xs:anyURI("{$actual-document-uri}")</xsl:text>
         </xsl:with-param>
      </xsl:call-template>

      <!-- Compile global params and global variables. -->
      <xsl:call-template name="x:compile-global-params-and-vars" />

      <!-- Compile the top-level scenarios. -->
      <xsl:call-template name="x:compile-scenarios"/>
      <xsl:text>&#10;</xsl:text>

      <xsl:text>(: the query body of this main module, to run the suite :)&#10;</xsl:text>
      <xsl:text>(: set up the result document (the report) :)&#10;</xsl:text>
      <xsl:text>document {&#x0A;</xsl:text>

      <!-- <x:report> -->
      <xsl:text>element { </xsl:text>
      <xsl:value-of select="QName($x:xspec-namespace, 'report') => x:QName-expression()" />
      <xsl:text> } {&#x0A;</xsl:text>

      <xsl:call-template name="x:zero-or-more-node-constructors">
         <xsl:with-param name="nodes" as="attribute()+">
            <xsl:attribute name="xspec" select="$actual-document-uri" />
            <xsl:attribute name="query" select="$this/@query" />
            <xsl:if test="exists($query-at)">
               <xsl:attribute name="query-at" select="$query-at" />
            </xsl:if>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:text>,&#x0A;</xsl:text>

      <!-- @date must be evaluated at run time -->
      <xsl:text>attribute { QName('', 'date') } { current-dateTime() },&#x0A;</xsl:text>

      <!-- Generate calls to the compiled top-level scenarios. -->
      <xsl:text>(: a call instruction for each top-level scenario :)&#x0A;</xsl:text>
      <xsl:call-template name="x:call-scenarios"/>

      <!-- </x:report> -->
      <xsl:text>}&#x0A;</xsl:text>

      <!-- End of the document constructor -->
      <xsl:text>}&#x0A;</xsl:text>
   </xsl:template>

   <!-- *** x:output-call *** -->
   <!-- Generates a call to the function compiled from a scenario or an expect element. --> 

   <xsl:template name="x:output-call">
      <xsl:context-item as="element()" use="required" />

      <xsl:param name="last" as="xs:boolean" />

      <!-- URIQualifiedNames of the variables that will be passed as the parameters to the call.
         Their order must be stable, because they are passed to a function. -->
      <xsl:param name="with-param-uqnames" as="xs:string*" />

      <xsl:if test="exists(preceding-sibling::x:*[1][self::x:pending])">
         <xsl:text>,&#10;</xsl:text>
      </xsl:if>

      <xsl:text expand-text="yes">let ${x:known-UQName('x:tmp')} := local:{@id}(&#x0A;</xsl:text>
      <xsl:for-each select="$with-param-uqnames">
         <xsl:text expand-text="yes">${.}</xsl:text>
         <xsl:if test="position() ne last()">
            <xsl:text>,</xsl:text>
         </xsl:if>
         <xsl:text>&#x0A;</xsl:text>
      </xsl:for-each>
      <xsl:text>)&#x0A;</xsl:text>

      <xsl:text>return (&#x0A;</xsl:text>
      <xsl:text expand-text="yes">${x:known-UQName('x:tmp')}</xsl:text>
      <xsl:if test="not($last)">
         <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
      <!-- Continue compiling calls. -->
      <xsl:call-template name="x:continue-call-scenarios"/>
      <xsl:text>)&#x0A;</xsl:text>
   </xsl:template>

   <!--
      Generates the functions that perform the tests.
      Called during mode="x:compile-each-element".
   -->
   <xsl:template name="x:compile-scenario" as="node()+">
      <xsl:context-item as="element(x:scenario)" use="required" />

      <xsl:param name="pending"   as="node()?"              tunnel="yes" />
      <!-- No $apply for XQuery -->
      <xsl:param name="context"   as="element(x:context)?"  tunnel="yes" />
      <xsl:param name="call"      as="element(x:call)?"     tunnel="yes" />
      <xsl:param name="stacked-variables" as="element(x:variable)*" tunnel="yes" />

      <xsl:variable name="local-preceding-variables" as="element(x:variable)*"
         select="x:call/preceding-sibling::x:variable" />

      <xsl:variable name="pending-p" as="xs:boolean"
         select="exists($pending) and empty(ancestor-or-self::*/@focus)" />

      <xsl:variable name="quoted-label" as="xs:string" select="$x:apos || x:label(.) || $x:apos" />

      <xsl:if test="$context">
         <xsl:call-template name="x:error-compiling-scenario">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text expand-text="yes">{name($context)} not supported for XQuery</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="$call/@template">
         <xsl:call-template name="x:error-compiling-scenario">
            <xsl:with-param name="message" as="xs:string">
               <xsl:text expand-text="yes">{name($call)}/@template not supported for XQuery</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>
      <xsl:if test="x:expect and empty($call)">
         <xsl:call-template name="x:error-compiling-scenario">
            <xsl:with-param name="message" as="xs:string">
               <!-- Use x:xspec-name() for displaying the element names with the prefix preferred by
                  the user -->
               <xsl:text expand-text="yes">There are {x:xspec-name('expect', .)} but no {x:xspec-name('call', .)}</xsl:text>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>

      <!--
        declare function local:...(...)
        {
      -->
      <xsl:text>&#10;(: generated from the x:scenario element :)</xsl:text>
      <xsl:text expand-text="yes">&#10;declare function local:{@id}(&#x0A;</xsl:text>

      <!-- Function parameters. Their order must be stable, because this is a function. -->
      <xsl:for-each select="x:distinct-strings-stable($stacked-variables ! x:variable-UQName(.))">
         <xsl:text expand-text="yes">${.}</xsl:text>
         <xsl:if test="position() ne last()">
            <xsl:text>,</xsl:text>
         </xsl:if>
         <xsl:text>&#x0A;</xsl:text>
      </xsl:for-each>

      <xsl:text expand-text="yes">) as element({x:known-UQName('x:scenario')})&#x0A;</xsl:text>

      <!-- Start of the function body -->
      <xsl:text>{&#x0A;</xsl:text>

      <!-- If there are variables before x:call, define them here followed by "return". -->
      <xsl:if test="exists($local-preceding-variables)">
         <xsl:apply-templates select="$local-preceding-variables" mode="x:declare-variable" />
         <xsl:text>return&#x0A;</xsl:text>
      </xsl:if>

      <!-- <x:scenario> -->
      <xsl:text>element { </xsl:text>
      <xsl:value-of select="QName(namespace-uri(), local-name()) => x:QName-expression()" />
      <xsl:text> } {&#x0A;</xsl:text>

      <xsl:call-template name="x:zero-or-more-node-constructors">
         <xsl:with-param name="nodes" as="node()+">
            <xsl:sequence select="@id, @xspec" />

            <xsl:if test="$pending-p">
               <xsl:sequence select="x:pending-attribute-from-pending-node($pending)" />
            </xsl:if>

            <xsl:sequence select="x:label(.)" />
         </xsl:with-param>
      </xsl:call-template>
      <xsl:text>,&#x0A;</xsl:text>

      <!-- Copy the input to the test result report XML -->
      <xsl:for-each select="x:call">
         <!-- Undeclare the default namespace in the wrapper element, because x:param/@select may
            use the default namespace such as xs:QName('foo'). -->
         <xsl:call-template name="x:wrap-node-constructors-and-undeclare-default-ns">
            <xsl:with-param name="wrapper-name" select="'input-wrap'" />
            <xsl:with-param name="node-constructors" as="node()+">
               <xsl:apply-templates select="." mode="x:node-constructor" />
            </xsl:with-param>
         </xsl:call-template>
         <xsl:text>,&#x0A;</xsl:text>
      </xsl:for-each>

      <xsl:choose>
         <xsl:when test="not($pending-p) and x:expect">
            <!--
              let $xxx-param1 := ...
              let $xxx-param2 := ...
              let $t:result   := ...($xxx-param1, $xxx-param2)
              return (
                rep:report-sequence($t:result, 'x:result'),
            -->
            <!-- #current is x:compile-each-element -->
            <xsl:apply-templates select="$call/x:param[1]" mode="#current" />

            <xsl:text expand-text="yes">let ${x:known-UQName('x:result')} := (&#x0A;</xsl:text>
            <xsl:call-template name="x:enter-sut">
               <xsl:with-param name="instruction" as="text()+">
                  <xsl:sequence select="x:function-call-text($call)" />
                  <xsl:text>&#x0A;</xsl:text>
               </xsl:with-param>
            </xsl:call-template>
            <xsl:text>)&#x0A;</xsl:text>

            <xsl:text>return (&#x0A;</xsl:text>
            <xsl:text expand-text="yes">{x:known-UQName('rep:report-sequence')}(${x:known-UQName('x:result')}, 'result'),&#x0A;</xsl:text>

            <xsl:text>&#x0A;</xsl:text>
            <xsl:text>(: a call instruction for each x:expect element :)&#x0A;</xsl:text>
         </xsl:when>

         <xsl:otherwise>
            <!--
               let $t:result := ()
               return (
            -->
            <xsl:text expand-text="yes">let ${x:known-UQName('x:result')} := ()&#x0A;</xsl:text>
            <xsl:text>return (&#x0A;</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

      <xsl:call-template name="x:call-scenarios"/>
      <xsl:text>)&#x0A;</xsl:text>

      <!-- </x:scenario> -->
      <xsl:text>}&#x0A;</xsl:text>

      <!-- End of the function -->
      <xsl:text>};&#x0A;</xsl:text>

      <xsl:call-template name="x:compile-scenarios"/>
   </xsl:template>

   <xsl:template name="x:output-try-catch" as="text()+">
      <xsl:context-item use="absent" />

      <xsl:param name="instruction" as="text()+" required="yes" />

      <xsl:text>try {&#x0A;</xsl:text>
      <xsl:sequence select="$instruction" />
      <xsl:text>}&#x0A;</xsl:text>

      <xsl:text>catch * {&#x0A;</xsl:text>
      <xsl:text>map {&#x0A;</xsl:text>
      <xsl:text>'err': map {&#x0A;</xsl:text>

      <!-- Variables available within the catch clause: https://www.w3.org/TR/xquery-31/#id-try-catch
         $err:additional doesn't work on Saxon 9.8: https://saxonica.plan.io/issues/4133 -->
      <xsl:for-each select="'code', 'description', 'value', 'module', 'line-number', 'column-number'">
         <xsl:text expand-text="yes">'{.}': ${x:known-UQName('err:' || .)}</xsl:text>
         <xsl:if test="position() ne last()">
            <xsl:text>,</xsl:text>
         </xsl:if>
         <xsl:text>&#x0A;</xsl:text>
      </xsl:for-each>

      <!-- End of 'err' map -->
      <xsl:text>}&#x0A;</xsl:text>

      <!-- End of $x:result map -->
      <xsl:text>}&#x0A;</xsl:text>

      <!-- End of catch -->
      <xsl:text>}&#x0A;</xsl:text>
   </xsl:template>

   <!--
      Generate an XQuery function from the expect element.
      
      This generated function, when called, checks the expectation against the actual result of the
      test and returns the corresponding x:test element for the XML report.
   -->
   <xsl:template name="x:compile-expect" as="node()+">
      <xsl:context-item as="element(x:expect)" use="required" />

      <xsl:param name="pending" as="node()?"                         tunnel="yes" />
      <!-- No $context for XQuery -->
      <xsl:param name="call"    as="element(x:call)?" required="yes" tunnel="yes" />

      <!-- URIQualifiedNames of the parameters of the function being generated.
         Their order must be stable, because they are function parameters. -->
      <xsl:param name="param-uqnames" as="xs:string*" required="yes" />

      <xsl:variable name="pending-p" as="xs:boolean"
         select="exists($pending) and empty(ancestor::*/@focus)" />

      <!--
        declare function local:...($t:result as item()*)
        {
      -->
      <xsl:text>&#10;(: generated from the x:expect element :)</xsl:text>
      <xsl:text expand-text="yes">&#10;declare function local:{@id}(&#x0A;</xsl:text>
      <xsl:for-each select="$param-uqnames">
         <xsl:text expand-text="yes">${.}</xsl:text>
         <xsl:if test="position() ne last()">
            <xsl:text>,</xsl:text>
         </xsl:if>
         <xsl:text>&#x0A;</xsl:text>
      </xsl:for-each>
      <xsl:text expand-text="yes">) as element({x:known-UQName('x:test')})&#x0A;</xsl:text>

      <!-- Start of the function body -->
      <xsl:text>{&#x0A;</xsl:text>

      <xsl:if test="not($pending-p)">
         <!-- Set up the $local:expected variable -->
         <xsl:apply-templates select="." mode="x:declare-variable">
            <xsl:with-param name="comment" select="'expected result'" />
         </xsl:apply-templates>

         <!-- Flags for deq:deep-equal() enclosed in ''. -->
         <xsl:variable name="deep-equal-flags" as="xs:string">''</xsl:variable>

         <xsl:choose>
            <xsl:when test="@test">
               <!-- $local:test-items
                  TODO: Wrap $x:result in a document node if possible -->
               <xsl:text expand-text="yes">let $local:test-items as item()* := ${x:known-UQName('x:result')}&#x0A;</xsl:text>

               <!-- $local:test-result
                  TODO: Evaluate @test in the context of $local:test-items, if
                    $local:test-items is a node -->
               <xsl:text expand-text="yes">let $local:test-result as item()* (: evaluate the predicate :) := (&#x0A;</xsl:text>
               <xsl:text expand-text="yes">{x:disable-escaping(@test)}&#x0A;</xsl:text>
               <xsl:text>)&#x0A;</xsl:text>

               <!-- $local:boolean-test -->
               <xsl:text>let $local:boolean-test as xs:boolean := ($local:test-result instance of xs:boolean)&#x0A;</xsl:text>

               <!-- TODO: xspec/xspec#309 -->

               <!-- $local:successful -->
               <xsl:text>let $local:successful as xs:boolean (: did the test pass? :) := (&#x0A;</xsl:text>
               <xsl:text>if ($local:boolean-test)&#x0A;</xsl:text>
               <xsl:text>then boolean($local:test-result)&#x0A;</xsl:text>
               <xsl:text expand-text="yes">else {x:known-UQName('deq:deep-equal')}(${x:variable-UQName(.)}, $local:test-result, {$deep-equal-flags})&#x0A;</xsl:text>
               <xsl:text>)&#x0A;</xsl:text>

            </xsl:when>

            <xsl:otherwise>
               <!-- $local:successful -->
               <xsl:text>let $local:successful as xs:boolean :=&#x0A;</xsl:text>
               <xsl:text expand-text="yes">{x:known-UQName('deq:deep-equal')}(${x:variable-UQName(.)}, ${x:known-UQName('x:result')}, {$deep-equal-flags})&#x0A;</xsl:text>
            </xsl:otherwise>
         </xsl:choose>

         <xsl:text>return&#x0A;</xsl:text>
      </xsl:if>

      <!-- <x:test> -->
      <xsl:text>element { </xsl:text>
      <xsl:value-of select="QName(namespace-uri(), 'test') => x:QName-expression()" />
      <xsl:text> } {&#x0A;</xsl:text>

      <xsl:call-template name="x:zero-or-more-node-constructors">
         <xsl:with-param name="nodes" as="node()+">
            <xsl:sequence select="@id" />

            <xsl:if test="$pending-p">
               <xsl:sequence select="x:pending-attribute-from-pending-node($pending)" />
            </xsl:if>
         </xsl:with-param>
      </xsl:call-template>
      <xsl:text>,&#x0A;</xsl:text>

      <xsl:if test="not($pending-p)">
         <!-- @successful must be evaluated at run time -->
         <xsl:text>attribute { QName('', 'successful') } { $local:successful },&#x0A;</xsl:text>
      </xsl:if>

      <xsl:apply-templates select="x:label(.)" mode="x:node-constructor" />

      <!-- Report -->
      <xsl:if test="not($pending-p)">
         <xsl:text>,&#x0A;</xsl:text>

         <xsl:if test="@test">
            <xsl:call-template name="x:report-test-attribute" />
            <xsl:text>,&#x0A;</xsl:text>

            <xsl:text>(&#x0A;</xsl:text>
            <xsl:text>if ( $local:boolean-test )&#x0A;</xsl:text>
            <xsl:text>then ()&#x0A;</xsl:text>
            <xsl:text expand-text="yes">else {x:known-UQName('rep:report-sequence')}($local:test-result, 'result')&#x0A;</xsl:text>
            <xsl:text>),&#x0A;</xsl:text>
         </xsl:if>

         <xsl:text expand-text="yes">{x:known-UQName('rep:report-sequence')}(${x:variable-UQName(.)}, '{local-name()}')&#x0A;</xsl:text>
      </xsl:if>

      <!-- </x:test> -->
      <xsl:text>}&#x0A;</xsl:text>

      <!-- End of the function -->
      <xsl:text>};&#x0A;</xsl:text>
   </xsl:template>

   <xsl:template name="x:wrap-node-constructors-and-undeclare-default-ns" as="node()+">
      <xsl:param name="wrapper-name" as="xs:string" />
      <xsl:param name="node-constructors" as="node()+" />

      <xsl:text>element { QName('', '</xsl:text>
      <xsl:value-of select="$wrapper-name" />
      <xsl:text>') } {&#x0A;</xsl:text>
      <xsl:sequence select="$node-constructors" />
      <xsl:text>}</xsl:text>
   </xsl:template>

   <xsl:template name="x:compile-helpers" as="text()*">
      <xsl:context-item as="element(x:description)" use="required" />

      <xsl:for-each select="x:helper[@query]">
         <xsl:text expand-text="yes">import module "{@query}"</xsl:text>
         <xsl:if test="exists(@query-at)">
            <xsl:text expand-text="yes">&#x0A;at "{@query-at}"</xsl:text>
         </xsl:if>
         <xsl:text>;&#x0A;</xsl:text>
      </xsl:for-each>
   </xsl:template>

</xsl:stylesheet>


<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
<!-- DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS COMMENT.             -->
<!--                                                                       -->
<!-- Copyright (c) 2008, 2010 Jeni Tennison                                -->
<!--                                                                       -->
<!-- The contents of this file are subject to the MIT License (see the URI -->
<!-- http://www.opensource.org/licenses/mit-license.php for details).      -->
<!--                                                                       -->
<!-- Permission is hereby granted, free of charge, to any person obtaining -->
<!-- a copy of this software and associated documentation files (the       -->
<!-- "Software"), to deal in the Software without restriction, including   -->
<!-- without limitation the rights to use, copy, modify, merge, publish,   -->
<!-- distribute, sublicense, and/or sell copies of the Software, and to    -->
<!-- permit persons to whom the Software is furnished to do so, subject to -->
<!-- the following conditions:                                             -->
<!--                                                                       -->
<!-- The above copyright notice and this permission notice shall be        -->
<!-- included in all copies or substantial portions of the Software.       -->
<!--                                                                       -->
<!-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       -->
<!-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    -->
<!-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.-->
<!-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  -->
<!-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  -->
<!-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     -->
<!-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
