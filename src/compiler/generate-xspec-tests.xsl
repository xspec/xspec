<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       generate-xspec-tests.xsl                                 -->
<!--  Author:     Jeni Tennison                                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2008, 2010 Jeni Tennison (see end of file.)          -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<xsl:stylesheet version="2.0"
                xmlns="http://www.w3.org/1999/XSL/TransformAlias"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

<xsl:import href="generate-common-tests.xsl"/>
<xsl:import href="generate-tests-helper.xsl" />

<pkg:import-uri>http://www.jenitennison.com/xslt/xspec/generate-xspec-tests.xsl</pkg:import-uri>

<xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl"/>

<xsl:output indent="yes" />

<!-- Absolute URI of .xsl file to be tested.
  This needs to be resolved here, not in mode="x:generate-tests" where base-uri() is not available -->
<xsl:variable name="stylesheet-uri" as="xs:anyURI"
  select="/x:description/resolve-uri(@stylesheet, base-uri())" />

<xsl:template match="/">
   <xsl:call-template name="x:generate-tests"/>
</xsl:template>

<!-- *** x:generate-tests *** -->
<!-- Does the generation of the test stylesheet -->
  
<xsl:template match="x:description" as="element(xsl:stylesheet)" mode="x:generate-tests">
  <!-- The compiled stylesheet element. -->
  <stylesheet version="{( @xslt-version, 2.0 )[1]}"
              exclude-result-prefixes="impl">
    <!-- The test result report XML may use namespace prefixes in XPath expressions
      even when the prefixes are not used in node names.
      So only very internal private prefixes can be included in @exclude-result-prefixes. -->

    <!-- The generated stylesheet requires these namespaces, even when this stylesheet
      does not use them in node names. -->
    <xsl:namespace name="impl" select="'urn:x-xspec:compile:xslt:impl'" />
    <xsl:namespace name="test" select="'http://www.jenitennison.com/xslt/unit-test'" />
    <xsl:namespace name="xs"   select="'http://www.w3.org/2001/XMLSchema'" />

    <xsl:apply-templates select="." mode="x:copy-namespaces" />

    <import href="{$stylesheet-uri}" />
    <import href="{resolve-uri('generate-tests-utils.xsl', static-base-uri())}"/>
    <import href="{resolve-uri('../schematron/sch-location-compare.xsl', static-base-uri())}"/>

    <include href="{resolve-uri('../common/xspec-utils.xsl', static-base-uri())}" />

    <!-- Serialization parameters -->
    <output name="{x:xspec-name('report')}" method="xml" indent="yes" />

    <!-- Absolute URI of .xspec file (Original one in case of Schematron) -->
    <xsl:variable name="xspec-uri" as="xs:anyURI"
      select="(@xspec-original-location, $actual-document-uri)[1] cast as xs:anyURI" />
    <variable name="{x:xspec-name('xspec-uri')}" as="xs:anyURI">
      <xsl:value-of select="$xspec-uri" />
    </variable>

    <!-- Compile the test suite params (aka global params). -->
    <xsl:call-template name="x:compile-params"/>

    <!-- The main compiled template. -->
    <template name="{x:xspec-name('main')}">
      <message>
        <text>Testing with </text>
        <value-of select="system-property('xsl:product-name')" />
        <text><xsl:text> </xsl:text></text>
        <value-of select="system-property('xsl:product-version')" />
      </message>

      <!-- Use <xsl:result-document> to avoid clashes with <xsl:output> in the stylesheet
        being tested which would otherwise govern the output of the report XML. -->
      <result-document format="{x:xspec-name('report')}">
        <xsl:apply-templates select="$html-reporter-pi" mode="test:create-node-generator" />

        <xsl:element name="{x:xspec-name('report')}" namespace="{$xspec-namespace}">
          <!-- This bit of jiggery-pokery with the $stylesheet-uri variable is so
            that the URI appears in the trace report generated from running the
            test stylesheet, which can then be picked up by stylesheets that
            process *that* to generate a coverage report -->
          <xsl:attribute name="stylesheet" select="$stylesheet-uri" />

          <xsl:attribute name="date" select="'{current-dateTime()}'" />
          <xsl:attribute name="xspec" select="$xspec-uri" />

          <xsl:copy-of select="@schematron"/>
          <!-- Generate calls to the compiled top-level scenarios. -->
          <xsl:call-template name="x:call-scenarios"/>
        </xsl:element>
      </result-document>
    </template>

    <!-- Compile the top-level scenarios. -->
    <xsl:call-template name="x:compile-scenarios"/>
  </stylesheet>
</xsl:template>

<!-- *** x:output-call *** -->
<!-- Generates a call to the template compiled from a scenario or an expect element. --> 

<xsl:template name="x:output-call">
   <xsl:param name="local-name" as="xs:string"/>
   <xsl:param name="last"       as="xs:boolean"/>
   <xsl:param name="params"     as="element(param)*"/>

   <call-template name="{x:xspec-name($local-name)}">
      <xsl:for-each select="$params">
         <with-param name="{ @name }" select="{ @select }"/>
      </xsl:for-each>
   </call-template>

   <!-- Continue compiling calls. -->
   <xsl:call-template name="x:continue-call-scenarios"/>
</xsl:template>

<!-- *** x:compile *** -->
<!-- Generates the templates that perform the tests -->

<xsl:template name="x:output-scenario" as="element(xsl:template)+">
  <xsl:param name="pending"   select="()" tunnel="yes" as="node()?"/>
  <xsl:param name="apply"     select="()" tunnel="yes" as="element(x:apply)?"/>
  <xsl:param name="call"      select="()" tunnel="yes" as="element(x:call)?"/>
  <xsl:param name="context"   select="()" tunnel="yes" as="element(x:context)?"/>
  <xsl:param name="variables" as="element(x:variable)*"/>
  <xsl:param name="params"    as="element(param)*"/>

  <xsl:variable name="pending-p" select="exists($pending) and empty(ancestor-or-self::*/@focus)"/>

  <!-- We have to create these error messages at this stage because before now
       we didn't have merged versions of the environment -->
  <xsl:if test="$context/@href and ($context/node() except $context/x:param)">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="x:label(.)" />
      <xsl:text>": can't set the context document using both the href</xsl:text>
      <xsl:text> attribute and the content of &lt;context&gt;</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:if test="$call/@template and $call/@function">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="x:label(.)" />
      <xsl:text>": can't call a function and a template at the same time</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:if test="$apply and $context">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="x:label(.)" />
      <xsl:text>": can't use apply and set a context at the same time</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:if test="$apply and $call">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="x:label(.)" />
      <xsl:text>": can't use apply and call at the same time</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:if test="$context and $call/@function">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="x:label(.)" />
      <xsl:text>": can't set a context and call a function at the same time</xsl:text>
    </xsl:message>
  </xsl:if>
  <xsl:if test="x:expect and not($call) and not($apply) and not($context)">
    <xsl:message terminate="yes">
      <xsl:text>ERROR in scenario "</xsl:text>
      <xsl:value-of select="x:label(.)" />
      <xsl:text>": there are tests in this scenario but no call, or apply or context has been given</xsl:text>
    </xsl:message>
  </xsl:if>

  <template name="{x:xspec-name(generate-id())}">
    <xsl:for-each select="$params">
      <param name="{ @name }" required="yes"/>
    </xsl:for-each>
    <message>
      <xsl:if test="$pending-p">
        <xsl:text>PENDING: </xsl:text>
        <xsl:if test="$pending != ''">
          <xsl:text>(</xsl:text>
          <xsl:value-of select="normalize-space($pending)"/>
          <xsl:text>) </xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="parent::x:scenario">
        <xsl:text>..</xsl:text>
      </xsl:if>
      <xsl:value-of select="normalize-space(x:label(.))"/>
    </message>

    <xsl:element name="{x:xspec-name('scenario')}" namespace="{$xspec-namespace}">
      <!-- Create @pending generator -->
      <xsl:if test="$pending-p">
        <xsl:sequence select="x:create-pending-attr-generator($pending)" />
      </xsl:if>

      <!-- Create x:label directly -->
      <xsl:sequence select="x:label(.)" />

      <!-- Create report generator -->
      <xsl:apply-templates select="x:apply | x:call | x:context" mode="x:report" />

      <xsl:apply-templates select="$variables" mode="x:generate-declarations"/>
      <xsl:if test="not($pending-p) and x:expect">
        <variable name="{x:xspec-name('result')}" as="item()*">
          <xsl:choose>
            <xsl:when test="$call/@template">
              <!-- Set up variables containing the parameter values -->
              <xsl:apply-templates select="$call/x:param[1]" mode="x:compile" />
              <!-- Create the template call -->
              <xsl:variable name="template-call">
                <call-template name="{$call/@template}">
                  <xsl:for-each select="$call/x:param">
                    <with-param name="{@name}" select="${@name}">
                      <xsl:copy-of select="@tunnel, @as" />
                    </with-param>
                  </xsl:for-each>
                </call-template>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="$context">
                  <!-- Set up the $impl:context variable -->
                  <xsl:apply-templates select="$context" mode="x:setup-context"/>
                  <!-- Switch to the context and call the template -->
                  <for-each select="$impl:context">
                    <xsl:copy-of select="$template-call" />
                  </for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$template-call" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$call/@function">
              <!-- Set up variables containing the parameter values -->
              <xsl:apply-templates select="$call/x:param[1]" mode="x:compile" />
              <!-- Create the function call -->
              <sequence>
                <xsl:attribute name="select">
                  <xsl:value-of select="$call/@function" />
                  <xsl:text>(</xsl:text>
                  <xsl:for-each select="$call/x:param">
                    <xsl:sort select="xs:integer(@position)" />
                    <xsl:text>$</xsl:text>
                    <xsl:value-of select="if (@name) then @name else generate-id()" />
                    <xsl:if test="position() != last()">, </xsl:if>
                  </xsl:for-each>
                  <xsl:text>)</xsl:text>
                </xsl:attribute>
              </sequence>
            </xsl:when>
            <xsl:when test="$apply">
               <!-- TODO: FIXME: ... -->
               <xsl:message terminate="yes">
                  <xsl:text>The instruction t:apply is not supported yet!</xsl:text>
               </xsl:message>
               <!-- Set up variables containing the parameter values -->
               <xsl:apply-templates select="$apply/x:param[1]" mode="x:compile"/>
               <!-- Create the apply templates instruction -->
               <apply-templates>
                  <xsl:copy-of select="$apply/@select | $apply/@mode"/>
                  <xsl:for-each select="$apply/x:param">
                     <with-param name="{ @name }" select="${ @name }">
                        <xsl:copy-of select="@tunnel"/>
                     </with-param>
                  </xsl:for-each>
               </apply-templates>
            </xsl:when>
            <xsl:when test="$context">
              <!-- Set up the $impl:context variable -->
              <xsl:apply-templates select="$context" mode="x:setup-context"/>
              <!-- Set up variables containing the parameter values -->
              <xsl:apply-templates select="$context/x:param[1]" mode="x:compile"/>
              <!-- Create the template call -->
              <apply-templates select="$impl:context">
                <xsl:sequence select="$context/@mode" />
                <xsl:for-each select="$context/x:param">
                  <with-param name="{@name}" select="${@name}">
                    <xsl:copy-of select="@tunnel, @as" />
                  </with-param>
                </xsl:for-each>
              </apply-templates>
            </xsl:when>
            <xsl:otherwise>
               <!-- TODO: Adapt to a new error reporting facility (above usages too). -->
               <xsl:message terminate="yes">Error: cannot happen.</xsl:message>
            </xsl:otherwise>
          </xsl:choose>      
        </variable>
        <call-template name="test:report-sequence">
          <with-param name="sequence" select="${x:xspec-name('result')}" />
          <with-param name="wrapper-name" as="xs:string">
            <xsl:value-of select="x:xspec-name('result')" />
          </with-param>
        </call-template>
      </xsl:if>
      <xsl:call-template name="x:call-scenarios"/>
    </xsl:element>
  </template>
  <xsl:call-template name="x:compile-scenarios"/>
</xsl:template>


<xsl:template name="x:output-expect" as="element(xsl:template)">
  <xsl:param name="pending" select="()"    tunnel="yes" as="node()?"/>
  <xsl:param name="context" required="yes" tunnel="yes" as="element(x:context)?"/>
  <xsl:param name="call"    required="yes" tunnel="yes" as="element(x:call)?"/>
  <xsl:param name="params"  required="yes"              as="element(param)*"/>

  <xsl:variable name="pending-p" select="exists($pending) and empty(ancestor::*/@focus)"/>

  <template name="{x:xspec-name(generate-id())}">
     <xsl:for-each select="$params">
        <param name="{ @name }" required="{ @required }"/>
     </xsl:for-each>
    <message>
      <xsl:if test="$pending-p">
        <xsl:text>PENDING: </xsl:text>
        <xsl:if test="normalize-space($pending) != ''">(<xsl:value-of select="normalize-space($pending)"/>) </xsl:if>
      </xsl:if>
      <xsl:value-of select="normalize-space(x:label(.))"/>
    </message>
    <xsl:if test="not($pending-p)">
      <xsl:variable name="xslt-version" as="xs:decimal" 
        select="(ancestor-or-self::*[@xslt-version]/@xslt-version, 2.0)[1]" />
      <!-- Set up the $impl:expected variable -->
      <xsl:call-template name="x:setup-expected">
        <xsl:with-param name="var" select="'impl:expected'" />
      </xsl:call-template>

      <!-- Flags for test:deep-equal() enclosed in ''. -->
      <xsl:variable name="deep-equal-flags" as="xs:string"
       select="concat('''', '1'[$xslt-version eq 1], '''')" />

      <xsl:choose>
        <xsl:when test="@test">
          <!-- This variable declaration could be moved from here (the
               template generated from x:expect) to the template
               generated from x:scenario. It depends only on
               $x:result, so could be computed only once. -->
          <variable name="impl:test-items" as="item()*">
            <choose>
              <!-- From trying this out, it seems like it's useful for the test
                   to be able to test the nodes that are generated in the
                   $x:result as if they were *children* of the context node.
                   Have to experiment a bit to see if that really is the case.                   
                   TODO: To remove. Use directly $x:result instead.  See issue 14. -->
              <when test="exists(${x:xspec-name('result')})
                and test:wrappable-sequence(${x:xspec-name('result')})">
                <sequence select="test:wrap-nodes(${x:xspec-name('result')})" />
              </when>
              <otherwise>
                <sequence select="${x:xspec-name('result')}" />
              </otherwise>
            </choose>
          </variable>
          <variable name="impl:test-result" as="item()*">
             <choose>
                <when test="count($impl:test-items) eq 1">
                   <for-each select="$impl:test-items">
                      <sequence select="{ @test }" version="{ $xslt-version }"/>
                   </for-each>
                </when>
                <otherwise>
                   <sequence select="{ @test }" version="{ $xslt-version }"/>
                </otherwise>
             </choose>
          </variable>
          <!-- TODO: A predicate should always return exactly one boolean, or
               this is an error.  See issue 5.-->
          <variable name="impl:boolean-test" as="xs:boolean"
            select="$impl:test-result instance of xs:boolean" />
          <xsl:if test="@href or @select or (node() except x:label)">
            <if test="$impl:boolean-test">
              <message>
                <text>WARNING: <xsl:value-of select="name(.)"/> has boolean @test (i.e. assertion) along with @href, @select or child node (i.e. comparison). Comparison factors will be ignored.</text>
              </message>
            </if>
          </xsl:if>
          <variable name="impl:successful" as="xs:boolean"
            select="if ($impl:boolean-test) then boolean($impl:test-result)
                    else test:deep-equal($impl:expected, $impl:test-result, {$deep-equal-flags})" />
        </xsl:when>
        <xsl:otherwise>
          <variable name="impl:successful" as="xs:boolean" 
            select="test:deep-equal($impl:expected, ${x:xspec-name('result')}, {$deep-equal-flags})" />
        </xsl:otherwise>
      </xsl:choose>
      <if test="not($impl:successful)">
        <message>
          <xsl:text>      FAILED</xsl:text>
        </message>
      </if>
    </xsl:if>

    <xsl:element name="{x:xspec-name('test')}" namespace="{$xspec-namespace}">
      <!-- Create @pending generator or create @successful directly -->
      <xsl:choose>
        <xsl:when test="$pending-p">
          <xsl:sequence select="x:create-pending-attr-generator($pending)" />
        </xsl:when>

        <xsl:otherwise>
          <xsl:attribute name="successful" select="'{$impl:successful}'" />
        </xsl:otherwise>
      </xsl:choose>

      <!-- Create x:label directly -->
      <xsl:sequence select="x:label(.)"/>

      <!-- Report -->
      <xsl:if test="not($pending-p)">
         <xsl:if test="@test">
            <if test="not($impl:boolean-test)">
               <call-template name="test:report-sequence">
                  <with-param name="sequence"     select="$impl:test-result"/>
                  <with-param name="wrapper-name" as="xs:string">
                     <xsl:value-of select="x:xspec-name('result')" />
                  </with-param>
               </call-template>
            </if>
         </xsl:if>
         <call-template name="test:report-sequence">
            <with-param name="sequence"     select="$impl:expected"/>
            <with-param name="wrapper-name" as="xs:string">
               <xsl:value-of select="x:xspec-name('expect')" />
            </with-param>
            <with-param name="test" as="attribute(test)?">
               <xsl:apply-templates select="@test" mode="test:create-node-generator" />
            </with-param>
         </call-template>
      </xsl:if>
    </xsl:element>
 </template>
</xsl:template>


<!-- *** x:generate-declarations *** -->
<!-- Code to generate parameter declarations -->
<xsl:template match="x:param" mode="x:generate-declarations">
  <xsl:apply-templates select="." mode="test:generate-variable-declarations">
    <xsl:with-param name="var"  select="@name"/>
    <xsl:with-param name="type" select="'param'"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="x:variable" mode="x:generate-declarations">
  <xsl:apply-templates select="." mode="test:generate-variable-declarations">
    <xsl:with-param name="var"  select="@name"/>
    <xsl:with-param name="type" select="'variable'"/>
  </xsl:apply-templates>
</xsl:template>

<!-- *** test:create-node-generator *** -->

<!-- At compile time, x:text (formerly x:space) has special meaning -->
<xsl:template match="x:space" as="empty-sequence()" mode="test:create-node-generator">
  <xsl:message terminate="yes">
    <xsl:value-of select="name()" />
    <xsl:text> is deprecated. Use </xsl:text>
    <xsl:value-of select="prefix-from-QName(node-name(.))" />
    <xsl:text>:text instead.</xsl:text>
  </xsl:message>
</xsl:template>

<xsl:template match="x:text" as="element(xsl:text)" mode="test:create-node-generator">
  <!-- Unwrap it and preserve its text node -->
  <xsl:apply-templates mode="#current" />
</xsl:template>

<!-- *** x:compile *** -->
<!-- Helper code for the tests -->

<xsl:template match="x:context" as="element()+" mode="x:setup-context">
   <xsl:variable name="context" as="element(x:context)">
      <xsl:element name="{x:xspec-name('context')}" namespace="{$xspec-namespace}">
         <xsl:sequence select="@*" />
         <xsl:sequence select="node() except x:param" />
      </xsl:element>
   </xsl:variable>
   <xsl:apply-templates select="$context" mode="test:generate-variable-declarations">
      <xsl:with-param name="var" select="'impl:context'" />
   </xsl:apply-templates>
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
