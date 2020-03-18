<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       generate-query-tests.xsl                                 -->
<!--  Author:     Jeni Tennison                                            -->
<!--  URL:        http://github.com/xspec/xspec                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2008, 2010 Jeni Tennison (see end of file.)          -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<xsl:stylesheet version="2.0"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

   <xsl:import href="generate-common-tests.xsl"/>
   <xsl:import href="generate-query-helper.xsl"/>

   <pkg:import-uri>http://www.jenitennison.com/xslt/xspec/generate-query-tests.xsl</pkg:import-uri>

   <xsl:output omit-xml-declaration="yes"/>

   <!--
       The URI to use in the "at" clause of the import statement (aka
       the "location hint") for the library generate-query-utils.xql.
       The special value '#none' is used to generate no "at" clause at
       all.

       By default, the URI is generated as a file relative to this
       stylesheet (because it comes with it in the XSpec release, but
       accessing the module on the file system is not always the best
       option, for instance for XML databases like eXist or
       MarkLogic).
   -->
   <xsl:param name="utils-library-at" select="
       resolve-uri('generate-query-utils.xql')"/>

   <!-- TODO: The at hint should not be always resolved (e.g. for MarkLogic). -->
   <xsl:param name="query-at" as="xs:string?" select="
       /x:description/@query-at/resolve-uri(., base-uri(..))"/>
   <!--xsl:param name="query-at" as="xs:string?" select="
       /x:description/@query-at"/-->

   <xsl:template match="/">
      <xsl:call-template name="x:generate-tests"/>
   </xsl:template>

   <xsl:template match="x:description" mode="x:decl-ns">
      <xsl:param name="except" as="xs:string*" />

      <xsl:variable name="e" as="element()" select="."/>
      <xsl:for-each select="in-scope-prefixes($e)[not(. = ('xml', $except))]">
         <xsl:variable name="prefix" as="xs:string" select="." />
         <xsl:text>declare </xsl:text>
         <xsl:if test="not($prefix)">
            <xsl:text>default element </xsl:text>
         </xsl:if>
         <xsl:text>namespace </xsl:text>
         <xsl:if test="$prefix">
            <xsl:value-of select="$prefix"/>
            <xsl:text> = </xsl:text>
         </xsl:if>
         <xsl:text>"</xsl:text>
         <xsl:value-of select="namespace-uri-for-prefix($prefix, $e)"/>
         <xsl:text>";&#10;</xsl:text>
      </xsl:for-each>
   </xsl:template>

   <!-- *** x:generate-tests *** -->
   <!-- Does the generation of the test stylesheet.
      This mode assumes that all the scenarios have already been gathered and unshared. -->
  
   <xsl:template match="x:description" mode="x:generate-tests">
      <xsl:variable name="this" select="." as="element(x:description)" />

      <!-- Look for a prefix defined for the target namespace on x:description. -->
      <xsl:variable name="prefix" as="xs:string?" select="
          in-scope-prefixes($this)[
            namespace-uri-for-prefix(., $this) eq xs:anyURI($this/@query)
          ][1]"/>

      <!-- Version declaration -->
      <xsl:if test="$this/@xquery-version">
         <xsl:text>xquery version "</xsl:text>
         <xsl:value-of select="$this/@xquery-version" />
         <xsl:text>";&#x0A;</xsl:text>
      </xsl:if>

      <!-- Import module to be tested -->
      <xsl:text>import module </xsl:text>
      <xsl:if test="exists($prefix)">
         <xsl:text>namespace </xsl:text>
         <xsl:value-of select="$prefix"/>
         <xsl:text> = </xsl:text>
      </xsl:if>
      <xsl:text>"</xsl:text>
      <xsl:value-of select="$this/@query"/>
      <xsl:if test="exists($query-at)">
         <xsl:text>"&#10;  at "</xsl:text>
         <xsl:value-of select="$query-at"/>
      </xsl:if>
      <xsl:text>";&#10;</xsl:text>

      <!-- Import 'test' utils -->
      <xsl:text>import module namespace test = </xsl:text>
      <xsl:text>"http://www.jenitennison.com/xslt/unit-test"</xsl:text>
      <xsl:if test="not($utils-library-at eq '#none')">
         <xsl:text>&#10;  at "</xsl:text>
         <xsl:value-of select="$utils-library-at"/>
         <xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:text>;&#10;</xsl:text>

      <!-- Import common utils -->
      <xsl:text>import module "</xsl:text>
      <xsl:value-of select="$xspec-namespace" />
      <xsl:text>"</xsl:text>
      <xsl:if test="not($utils-library-at eq '#none')">
         <xsl:text>&#x0A;  at "</xsl:text>
         <xsl:value-of select="resolve-uri('../common/xspec-utils.xquery')" />
         <xsl:text>"</xsl:text>
      </xsl:if>
      <xsl:text>;&#x0A;</xsl:text>

      <!-- Declare namespaces -->
      <xsl:apply-templates select="$this" mode="x:decl-ns">
         <xsl:with-param name="except" select="$prefix, 'test'"/>
      </xsl:apply-templates>
      <xsl:text>declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";&#x0A;</xsl:text>

      <!-- Serialization parameters -->
      <xsl:text>declare option output:method "xml";&#x0A;</xsl:text>
      <xsl:text>declare option output:indent "yes";&#x0A;</xsl:text>

      <!-- Absolute URI of the master .xspec file -->
      <xsl:call-template name="test:declare-or-let-variable">
         <xsl:with-param name="is-global" select="true()" />
         <xsl:with-param name="name" select="x:xspec-name($this,'xspec-uri')" />
         <xsl:with-param name="type" select="'xs:anyURI'" />
         <xsl:with-param name="value" as="text()+">
            <xsl:text>xs:anyURI("</xsl:text>
            <xsl:value-of select="$actual-document-uri" />
            <xsl:text>")</xsl:text>
         </xsl:with-param>
      </xsl:call-template>

      <!-- Compile global params and global variables. -->
      <xsl:call-template name="x:compile-global-params-and-vars" />

      <!-- Compile the top-level scenarios. -->
      <xsl:call-template name="x:compile-scenarios"/>
      <xsl:text>&#10;</xsl:text>

      <xsl:text>document {&#x0A;</xsl:text>

      <xsl:element name="{x:xspec-name($this,'report')}" namespace="{$xspec-namespace}">
         <xsl:attribute name="date"  select="'{current-dateTime()}'" />
         <xsl:attribute name="query" select="$this/@query"/>
         <xsl:if test="exists($query-at)">
            <xsl:attribute name="query-at" select="$query-at"/>
         </xsl:if>
         <xsl:attribute name="xspec" select="$actual-document-uri"/>

         <xsl:sequence select="x:copy-namespaces($this)" />

         <xsl:text> {&#10;</xsl:text>
         <!-- Generate calls to the compiled top-level scenarios. -->
         <xsl:call-template name="x:call-scenarios"/>
         <xsl:text>&#10;}&#10;</xsl:text>
      </xsl:element>

      <xsl:text> }&#x0A;</xsl:text>
   </xsl:template>

   <!-- *** x:output-call *** -->
   <!-- Generates a call to the function compiled from a scenario or an expect element. --> 

   <xsl:template name="x:output-call">
      <xsl:context-item as="element()" use="required"
         use-when="element-available('xsl:context-item')" />

      <xsl:param name="last"   as="xs:boolean" />
      <xsl:param name="params" as="element(param)*" />

      <xsl:variable name="local-name" as="xs:string">
         <xsl:apply-templates select="." mode="x:generate-id" />
      </xsl:variable>

      <xsl:if test="exists(preceding-sibling::x:*[1][self::x:pending])">
         <xsl:text>,&#10;</xsl:text>
      </xsl:if>
      <xsl:text>      let $</xsl:text>
      <xsl:value-of select="x:xspec-name(.,'tmp')" />
      <xsl:text> := local:</xsl:text>
      <xsl:value-of select="$local-name"/>
      <xsl:text>(</xsl:text>
      <xsl:for-each select="$params">
         <xsl:value-of select="@select"/>
         <xsl:if test="position() ne last()">
            <xsl:text>, </xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:text>) return (&#10;</xsl:text>
      <xsl:text>        $</xsl:text>
      <xsl:value-of select="x:xspec-name(.,'tmp')" />
      <xsl:if test="not($last)">
         <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
      <!-- Continue compiling calls. -->
      <xsl:call-template name="x:continue-call-scenarios"/>
      <xsl:text>      )&#10;</xsl:text>
   </xsl:template>

   <!-- *** x:compile *** -->
   <!-- Generates the functions that perform the tests -->
   <!--
       TODO: Add the $params parameter as in the x:output-scenario for XSLT.
   -->

   <xsl:template name="x:output-scenario" as="node()+">
      <xsl:context-item as="element(x:scenario)" use="required"
         use-when="element-available('xsl:context-item')" />

      <xsl:param name="pending" select="()" tunnel="yes" as="node()?"/>
      <xsl:param name="context" select="()" tunnel="yes" as="element(x:context)?"/>
      <xsl:param name="call"    select="()" tunnel="yes" as="element(x:call)?"/>
      <xsl:param name="variables" as="element(x:variable)*"/>
      <xsl:param name="params"    as="element(param)*"/>

      <xsl:variable name="pending-p" select="exists($pending) and empty(ancestor-or-self::*/@focus)"/>

      <xsl:variable name="scenario-id" as="xs:string">
         <xsl:apply-templates select="." mode="x:generate-id" />
      </xsl:variable>

      <!-- x:context and x:call/@template not supported for XQuery -->
      <xsl:if test="exists($context)">
         <xsl:variable name="msg" select="
             concat('x:context not supported for XQuery (scenario ', x:label(.), ')')"/>
         <xsl:sequence select="error(xs:QName('x:XSPEC003'), $msg)"/>
      </xsl:if>
      <xsl:if test="exists($call/@template)">
         <xsl:variable name="msg" select="
             concat('x:call/@template not supported for XQuery (scenario ', x:label(.), ')')"/>
         <xsl:sequence select="error(xs:QName('x:XSPEC004'), $msg)"/>
      </xsl:if>

      <!-- x:call required if there are x:expect -->
      <xsl:if test="x:expect and not($call)">
         <xsl:variable name="msg" select="
             concat('there are x:expect but no x:call in scenario ''', x:label(.), '''')"/>
         <xsl:sequence select="error(xs:QName('x:XSPEC005'), $msg)"/>
      </xsl:if>

      <!--
        declare function local:...(...)
        {
      -->
      <xsl:text>&#10;declare function local:</xsl:text>
      <xsl:value-of select="$scenario-id" />
      <xsl:text>(</xsl:text>
      <xsl:value-of select="$params/concat('$', @name)" separator=", "/>
      <xsl:text>)&#10;{&#10;</xsl:text>

      <!-- If there are variables before x:call, the caller passed them in as $variables.
           Define them here followed by "return". -->
      <xsl:if test="exists($variables)">
         <xsl:apply-templates select="$variables" mode="test:generate-variable-declarations" />
         <xsl:text>    return&#10;</xsl:text>
      </xsl:if>

      <xsl:element name="{x:xspec-name(.,'scenario')}" namespace="{$xspec-namespace}">
         <xsl:attribute name="id" select="$scenario-id" />
         <xsl:sequence select="@xspec" />

         <!-- Create @pending generator -->
         <xsl:if test="$pending-p">
            <xsl:text>{ </xsl:text>
            <xsl:sequence select="x:create-pending-attr-generator($pending)" />
            <xsl:text> }&#x0A;</xsl:text>
         </xsl:if>

         <!-- Create x:label generator -->
         <xsl:apply-templates select="x:label(.)" mode="test:create-node-generator" />

         <!-- Create report generator -->
         <xsl:apply-templates select="x:call" mode="x:report"/>

         <xsl:text>      &#10;{&#10;</xsl:text>
         <xsl:choose>
            <xsl:when test="not($pending-p)">
               <!--
                 let $xxx-param1 := ...
                 let $xxx-param2 := ...
                 let $t:result   := ...($xxx-param1, $xxx-param2)
                   return (
                     test:report-sequence($t:result, 'x:result'),
               -->
               <xsl:apply-templates select="$call/x:param[1]" mode="x:compile"/>
               <xsl:text>  let $</xsl:text>
               <xsl:value-of select="x:xspec-name(.,'result')" />
               <xsl:text> := (&#10;</xsl:text>
               <xsl:call-template name="x:enter-sut">
                  <xsl:with-param name="instruction" as="text()+">
                     <xsl:text>    </xsl:text>
                     <xsl:value-of select="$call/@function"/>
                     <xsl:text>(</xsl:text>
                     <xsl:for-each select="$call/x:param">
                        <xsl:sort select="xs:integer(@position)"/>
                        <xsl:text>$</xsl:text>
                        <xsl:value-of select="test:variable-name(.)" />
                        <xsl:if test="position() != last()">, </xsl:if>
                     </xsl:for-each>
                     <xsl:text>)&#10;</xsl:text>
                  </xsl:with-param>
               </xsl:call-template>
               <xsl:text>  )&#10;</xsl:text>
               <xsl:text>    return (&#10;</xsl:text>
               <xsl:text>      test:report-sequence($</xsl:text>
               <xsl:value-of select="x:xspec-name(.,'result')" />
               <xsl:text>, '</xsl:text>
               <xsl:value-of select="x:xspec-name(.,'result')" />
               <xsl:text>'),&#10;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <!--
                 let $t:result := ()
                   return (
               -->
               <xsl:text>  let $</xsl:text>
               <xsl:value-of select="x:xspec-name(.,'result')" />
               <xsl:text> := ()&#10;</xsl:text>
               <xsl:text>    return (&#10;</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:call-template name="x:call-scenarios"/>
         <xsl:text>    )&#10;</xsl:text>
         <xsl:text>}&#10;</xsl:text>
      </xsl:element>
      <xsl:text>&#10;};&#10;</xsl:text>
      <xsl:call-template name="x:compile-scenarios"/>
   </xsl:template>

   <xsl:template name="x:output-try-catch" as="text()+">
      <xsl:context-item use="absent"
         use-when="element-available('xsl:context-item')" />

      <xsl:param name="instruction" as="text()+" required="yes" />

      <xsl:text>    try {&#x0A;</xsl:text>
      <xsl:text>  </xsl:text>
      <xsl:sequence select="$instruction" />
      <xsl:text>    }&#x0A;</xsl:text>
      <xsl:text>    catch * {&#x0A;</xsl:text>
      <xsl:text>      map {&#x0A;</xsl:text>
      <xsl:text>        'err': map {&#x0A;</xsl:text>

      <!-- Variables available within the catch clause: https://www.w3.org/TR/xquery-31/#id-try-catch
         $err:additional doesn't work on Saxon 9.8: https://saxonica.plan.io/issues/4133 -->
      <xsl:for-each select="'code', 'description', 'value', 'module', 'line-number', 'column-number'">
         <xsl:text>                 '</xsl:text>
         <xsl:value-of select="." />
         <xsl:text>': $Q{http://www.w3.org/2005/xqt-errors}</xsl:text>
         <xsl:value-of select="." />
         <xsl:if test="position() ne last()">
            <xsl:text>,</xsl:text>
         </xsl:if>
         <xsl:text>&#x0A;</xsl:text>
      </xsl:for-each>

      <xsl:text>               }&#x0A;</xsl:text>
      <xsl:text>      }&#x0A;</xsl:text>
      <xsl:text>    }&#x0A;</xsl:text>
   </xsl:template>

   <!--
       Generate an XQuery function from the expect element.
       
       This function, when called, checks the expectation against the
       actual result of the test and return the corresponding t:test
       element for the XML report.
   -->
   <xsl:template name="x:output-expect" as="node()+">
      <xsl:context-item as="element(x:expect)" use="required"
         use-when="element-available('xsl:context-item')" />

      <xsl:param name="pending" select="()"    tunnel="yes" as="node()?"/>
      <xsl:param name="call"    required="yes" tunnel="yes" as="element(x:call)?"/>
      <xsl:param name="params"  required="yes"              as="element(param)*"/>

      <xsl:variable name="pending-p" select="exists($pending) and empty(ancestor::*/@focus)"/>

      <xsl:variable name="expect-id" as="xs:string">
         <xsl:apply-templates select="." mode="x:generate-id" />
      </xsl:variable>

      <!--
        declare function local:...($t:result as item()*)
        {
      -->
      <xsl:text>&#10;declare function local:</xsl:text>
      <xsl:value-of select="$expect-id" />
      <xsl:text>(</xsl:text>
      <xsl:for-each select="$params">
         <xsl:text>$</xsl:text>
         <xsl:value-of select="@name"/>
         <xsl:if test="position() ne last()">
            <xsl:text>, </xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:text>)&#10;{&#10;</xsl:text>
      <xsl:if test="not($pending-p)">
         <!-- Set up the $local:expected variable -->
         <xsl:apply-templates select="." mode="test:generate-variable-declarations" />

         <!-- Flags for test:deep-equal() enclosed in ''. -->
         <xsl:variable name="deep-equal-flags" as="xs:string">''</xsl:variable>

         <xsl:choose>
            <xsl:when test="@test">
               <!-- $local:test-items
                  TODO: Wrap $x:result in a document node if possible -->
               <xsl:text>  let $local:test-items as item()* := $</xsl:text>
               <xsl:value-of select="x:xspec-name(.,'result')" />
               <xsl:text>&#x0A;</xsl:text>

               <!-- $local:test-result
                  TODO: Evaluate @test in the context of $local:test-items, if
                    $local:test-items is a node -->
               <xsl:text>  let $local:test-result as item()* := (</xsl:text>
               <xsl:value-of select="@test" />
               <xsl:text>)&#x0A;</xsl:text>

               <!-- $local:boolean-test -->
               <xsl:text>  let $local:boolean-test as xs:boolean :=&#x0A;</xsl:text>
               <xsl:text>    ($local:test-result instance of xs:boolean)&#x0A;</xsl:text>

               <!-- TODO: xspec/xspec#309 -->

               <!-- $local:successful -->
               <xsl:text>  let $local:successful as xs:boolean := (&#x0A;</xsl:text>
               <xsl:text>    if ($local:boolean-test)&#x0A;</xsl:text>
               <xsl:text>    then boolean($local:test-result)&#x0A;</xsl:text>
               <xsl:text>    else test:deep-equal($</xsl:text>
               <xsl:value-of select="test:variable-name(.)" />
               <xsl:text>, $local:test-result, </xsl:text>
               <xsl:value-of select="$deep-equal-flags" />
               <xsl:text>)&#x0A;</xsl:text>
               <xsl:text>  )&#x0A;</xsl:text>

            </xsl:when>

            <xsl:otherwise>
               <!-- $local:successful -->
               <xsl:text>  let $local:successful as xs:boolean :=&#x0A;</xsl:text>
               <xsl:text>      test:deep-equal($</xsl:text>
               <xsl:value-of select="test:variable-name(.)" />
               <xsl:text>, $</xsl:text>
               <xsl:value-of select="x:xspec-name(.,'result')" />
               <xsl:text>, </xsl:text>
               <xsl:value-of select="$deep-equal-flags" />
               <xsl:text>)&#x0A;</xsl:text>
            </xsl:otherwise>
         </xsl:choose>

         <xsl:text>    return&#x0A;</xsl:text>
         <xsl:text>      </xsl:text>
      </xsl:if>

      <!--
        return the x:test element for the report
      -->
      <xsl:element name="{x:xspec-name(.,'test')}" namespace="{$xspec-namespace}">
         <xsl:attribute name="id" select="$expect-id" />

         <!-- Create @pending generator or create @successful directly -->
         <xsl:choose>
            <xsl:when test="$pending-p">
               <xsl:text>{ </xsl:text>
               <xsl:sequence select="x:create-pending-attr-generator($pending)" />
               <xsl:text> }&#x0A;</xsl:text>
            </xsl:when>

            <xsl:otherwise>
               <xsl:attribute name="successful" select="'{ $local:successful }'"/>
            </xsl:otherwise>
         </xsl:choose>

         <!-- Create x:label generator -->
         <xsl:apply-templates select="x:label(.)" mode="test:create-node-generator" />

         <!-- Report -->
         <xsl:if test="not($pending-p)">
            <xsl:if test="@test">
               <xsl:text>&#x0A;</xsl:text>
               <xsl:text>      { if ( $local:boolean-test )&#x0A;</xsl:text>
               <xsl:text>        then ()&#x0A;</xsl:text>
               <xsl:text>        else test:report-sequence($local:test-result, '</xsl:text>
               <xsl:value-of select="x:xspec-name(.,'result')" />
               <xsl:text>') }</xsl:text>
            </xsl:if>

            <xsl:text>&#x0A;</xsl:text>
            <xsl:text>      { test:report-sequence($</xsl:text>
            <xsl:value-of select="test:variable-name(.)" />
            <xsl:text>, '</xsl:text>
            <xsl:value-of select="x:xspec-name(.,'expect')" />
            <xsl:text>'</xsl:text>

            <xsl:if test="@test">
               <xsl:text>, </xsl:text>
               <xsl:apply-templates select="@test" mode="test:create-node-generator" />
            </xsl:if>

            <xsl:text>) }</xsl:text>
         </xsl:if>
      </xsl:element>
      <xsl:text>&#10;};&#10;</xsl:text>
   </xsl:template>

   <!-- *** x:report *** -->

   <xsl:template match="document-node() | attribute() | node()" as="node()+" mode="x:report">
      <xsl:text>{ </xsl:text>
      <xsl:apply-imports />
      <xsl:text> }&#x0A;</xsl:text>
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
