<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       format-xspec-report.xsl                                  -->
<!--  Author:     Jeni Tennison                                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2008, 2010 Jeni Tennison (see end of file.)          -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<xsl:stylesheet version="2.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

<xsl:import href="format-utils.xsl"/>

<xsl:include href="../common/parse-report.xsl" />
<xsl:include href="../common/xspec-utils.xsl" />

<pkg:import-uri>http://www.jenitennison.com/xslt/xspec/format-xspec-report.xsl</pkg:import-uri>

<xsl:param name="inline-css" as="xs:string" select="false() cast as xs:string" />

<xsl:param name="report-css-uri" as="xs:string?" />

<!-- @use-character-maps for inline CSS -->
<xsl:output method="xhtml" use-character-maps="test:disable-escaping" />

<!-- Returns formatted output for $pending -->
<xsl:function name="x:pending-callback" as="node()*">
  <xsl:param name="pending" as="xs:string?"/>

  <xsl:if test="$pending">
    <xsl:text>(</xsl:text>
    <strong><xsl:value-of select="$pending"/></strong>
    <xsl:text>) </xsl:text>
  </xsl:if>
</xsl:function>

<!-- Returns formatted output for separator between scenarios -->
<xsl:function name="x:separator-callback" as="text()">
  <xsl:text> </xsl:text>
</xsl:function>

<!-- Named template to be overridden.
  Override this template to insert additional nodes at the end of /html/head. -->
<xsl:template name="x:html-head-callback" as="empty-sequence()">
  <xsl:context-item as="document-node(element(x:report))" use="required"
    use-when="element-available('xsl:context-item')" />
</xsl:template>
  
<xsl:template name="x:format-top-level-scenario" as="element(xhtml:div)">
  <xsl:context-item as="element(x:scenario)" use="required"
    use-when="element-available('xsl:context-item')" />

  <xsl:variable name="pending" as="xs:boolean"
    select="exists(@pending)" />
  <xsl:variable name="any-failure" as="xs:boolean"
    select="exists(x:test[x:is-failed-test(.)])" />
  <div id="top-level-{local-name()}-{generate-id()}">
    <h2 class="{if ($pending) then 'pending' else if ($any-failure) then 'failed' else 'successful'}">
      <xsl:sequence select="x:pending-callback(@pending)"/>
      <xsl:apply-templates select="x:label" mode="x:html-report" />
      <span class="scenario-totals">
        <xsl:call-template name="x:totals">
          <xsl:with-param name="tests" select="x:descendant-tests(.)" />
          <xsl:with-param name="labels" select="true()"/>
        </xsl:call-template>
      </span>
    </h2>
    <table class="xspec" id="t-{generate-id()}">
      <colgroup>
        <col style="width:75%" />
        <col style="width:25%" />
      </colgroup>
      <tbody>
        <tr class="{if ($pending) then 'pending' else if ($any-failure) then 'failed' else 'successful'}">
          <th>
            <xsl:sequence select="x:pending-callback(@pending)"/>
            <xsl:apply-templates select="x:label" mode="x:html-report" />
          </th>
          <th>
            <xsl:call-template name="x:totals">
              <xsl:with-param name="tests" select="x:descendant-tests(.)" />
              <xsl:with-param name="labels" select="true()"/>
            </xsl:call-template>
          </th>
        </tr>
        <xsl:apply-templates select="x:test" mode="x:html-summary" />
        <xsl:for-each select=".//x:scenario[x:test]">
          <xsl:variable name="pending" as="xs:boolean"
            select="exists(@pending)" />
          <xsl:variable name="any-failure" as="xs:boolean"
            select="exists(x:test[x:is-failed-test(.)])" />
          <xsl:variable name="label" as="node()+">
            <xsl:for-each select="ancestor-or-self::x:scenario[position() != last()]">
              <xsl:apply-templates select="x:label" mode="x:html-report" />
              <xsl:if test="position() != last()">
                <xsl:sequence select="x:separator-callback()"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <tr class="{if ($pending) then 'pending' else if ($any-failure) then 'failed' else 'successful'}">
            <th>
              <xsl:sequence select="x:pending-callback(@pending)"/>
              <xsl:choose>
                <xsl:when test="$any-failure">
                  <a href="#{local-name()}-{generate-id()}">
                    <xsl:sequence select="$label" />
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="$label" />
                </xsl:otherwise>
              </xsl:choose>
            </th>
            <th>
              <xsl:call-template name="x:totals">
                <xsl:with-param name="tests" select="x:test" />
                <xsl:with-param name="labels" select="true()"/>
              </xsl:call-template>
            </th>
          </tr>
          <xsl:apply-templates select="x:test" mode="x:html-summary" />
        </xsl:for-each>
      </tbody>
    </table>
    <xsl:apply-templates select="descendant-or-self::x:scenario[x:test[x:is-failed-test(.)]]" mode="x:html-report" />
  </div>
</xsl:template>

<xsl:template match="document-node()" as="element(xhtml:html)">
  <xsl:message>
    <xsl:call-template name="x:totals">
      <xsl:with-param name="tests" select="x:descendant-tests(.)" />
      <xsl:with-param name="labels" select="true()" />
    </xsl:call-template>
  </xsl:message>

  <html>
    <head>
      <title>
         <xsl:text>Test Report for </xsl:text>
         <xsl:value-of select="x:report/x:format-uri((@schematron,@stylesheet,@query)[1])"/>
         <xsl:text> (</xsl:text>
         <xsl:call-template name="x:totals">
           <xsl:with-param name="tests" select="x:descendant-tests(.)"/>
           <xsl:with-param name="labels" select="true()"/>
         </xsl:call-template>
         <xsl:text>)</xsl:text>
      </title>
      <xsl:call-template name="test:load-css">
        <xsl:with-param name="inline" select="$inline-css cast as xs:boolean" />
        <xsl:with-param name="uri" select="$report-css-uri" />
      </xsl:call-template>
      <xsl:call-template name="x:html-head-callback"/>
    </head>
    <body>
      <h1>Test Report</h1>
      <xsl:apply-templates select="*"/>
    </body>
  </html>
</xsl:template>

<xsl:template match="x:report" as="element()+">
   <xsl:apply-templates select="." mode="x:html-report"/>
</xsl:template>

<xsl:template match="x:report" as="element()+" mode="x:html-report">
  <!-- Write URIs, ignoring @stylesheet when actual test target is Schematron -->
  <xsl:for-each select="@query, @query-at, @schematron, @stylesheet[empty(current()/@schematron)]">
    <p>
      <xsl:variable as="xs:string" name="attr-name" select="local-name()" />

      <!-- Capitalize the first character -->
      <xsl:value-of select="
        concat(
          upper-case(substring($attr-name, 1, 1)),
          substring($attr-name, 2)
        )" />

      <xsl:text>: </xsl:text>

      <!-- @query is a namespace. The others are URI of file -->
      <xsl:choose>
        <xsl:when test="self::attribute(query)">
          <xsl:value-of select="." />
        </xsl:when>

        <xsl:otherwise>
          <a href="{.}">
            <xsl:value-of select="x:format-uri(.)" />
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </p>
  </xsl:for-each>

  <p>
    <xsl:text>XSpec: </xsl:text>
    <a href="{@xspec}">
      <xsl:value-of select="x:format-uri(@xspec)"/>
    </a>
  </p>
  <p>
    <xsl:text>Tested: </xsl:text>
    <xsl:value-of select="format-dateTime(@date, '[D] [MNn] [Y] at [H01]:[m01]')" />
  </p>
  <h2>Contents</h2>
  <table class="xspec">
    <colgroup>
      <col style="width:75%" />
      <col style="width:6.25%" />
      <col style="width:6.25%" />
      <col style="width:6.25%" />
      <col style="width:6.25%" />
    </colgroup>
    <thead>
      <tr>
        <xsl:variable name="totals" select="x:totals(x:descendant-tests(.))"/>
        <th/>
        <th class="totals">passed:&#xa0;<xsl:value-of select="$totals[1]"/></th>
        <th class="totals">pending:&#xa0;<xsl:value-of select="$totals[2]"/></th>
        <th class="totals">failed:&#xa0;<xsl:value-of select="$totals[3]"/></th>
        <th class="totals">total:&#xa0;<xsl:value-of select="$totals[4]"/></th>
      </tr>
    </thead>
    <tbody>
      <xsl:for-each select="x:scenario">
        <xsl:variable name="pending" as="xs:boolean"
          select="exists(@pending)" />
        <xsl:variable name="any-failure" as="xs:boolean"
          select="exists(x:descendant-failed-tests(.))" />
        <tr class="{if ($pending) then 'pending' else if ($any-failure) then 'failed' else 'successful'}">
          <th>
            <xsl:sequence select="x:pending-callback(@pending)"/>
            <a>
              <xsl:if test="x:top-level-scenario-needs-format(.)">
                <xsl:attribute name="href" select="string-join(('#top-level', local-name(), generate-id()), '-')" />
              </xsl:if>
              <xsl:apply-templates select="x:label" mode="x:html-report" />
            </a>
          </th>
          <xsl:variable name="totals" select="x:totals(x:descendant-tests(.))"/>
          <th class="totals"><xsl:value-of select="$totals[1]"/></th>
          <th class="totals"><xsl:value-of select="$totals[2]"/></th>
          <th class="totals"><xsl:value-of select="$totals[3]"/></th>
          <th class="totals"><xsl:value-of select="$totals[4]"/></th>
        </tr>
      </xsl:for-each>
    </tbody>
  </table>
  <xsl:for-each select="x:scenario[x:top-level-scenario-needs-format(.)]">
    <xsl:call-template name="x:format-top-level-scenario"/>
  </xsl:for-each>
</xsl:template>

<!-- Returns true if the top level x:scenario needs to be processed by x:format-top-level-scenario template -->
<xsl:function name="x:top-level-scenario-needs-format" as="xs:boolean">
  <xsl:param name="scenario-elem" as="element(x:scenario)" />

  <xsl:sequence select="$scenario-elem/(
    empty(@pending)
    or exists(x:descendant-tests(.)[not(x:is-pending-test(.))])
    )"/>
</xsl:function>

<xsl:template match="x:test[x:is-pending-test(.)]" as="element(xhtml:tr)" mode="x:html-summary">
  <tr class="pending">
    <td>
      <xsl:sequence select="x:pending-callback(@pending)"/>
      <xsl:apply-templates select="x:label" mode="x:html-report" />
    </td>
    <td>Pending</td>
  </tr>
</xsl:template>

<xsl:template match="x:test[x:is-passed-test(.)]" as="element(xhtml:tr)" mode="x:html-summary">
  <tr class="successful">
  	<td><xsl:apply-templates select="x:label" mode="x:html-report" /></td>
    <td>Success</td>
  </tr>
</xsl:template>

<xsl:template match="x:test[x:is-failed-test(.)]" as="element(xhtml:tr)" mode="x:html-summary">
  <tr class="failed">
    <td>
      <a href="#{local-name()}-{generate-id()}">
      	<xsl:apply-templates select="x:label" mode="x:html-report" />
      </a>
    </td>
    <td>Failure</td>
  </tr>
</xsl:template>

<xsl:template match="x:scenario" as="element(xhtml:div)" mode="x:html-report">
  <div id="{local-name()}-{generate-id()}">
    <h3>
      <xsl:for-each select="ancestor-or-self::x:scenario">
        <xsl:apply-templates select="x:label" mode="x:html-report" />
        <xsl:if test="position() != last()">
          <xsl:sequence select="x:separator-callback()"/>
        </xsl:if>
      </xsl:for-each>
    </h3>
    <xsl:apply-templates select="x:test[x:is-failed-test(.)]" mode="x:html-report" />
  </div>
</xsl:template>

<xsl:template match="x:test" as="element(xhtml:div)" mode="x:html-report">
  <div id="{local-name()}-{generate-id()}">

    <xsl:variable name="result" as="element(x:result)"
      select="if (x:result) then x:result else ../x:result" />
    <h4>
      <xsl:apply-templates select="x:label" mode="x:html-report" />
    </h4>

    <!-- True if the expectation is boolean (i.e. x:expect/@test was an xs:boolean at runtime.) -->
    <xsl:variable as="xs:boolean" name="boolean-test" select="not(x:result) and x:expect/@test" />

    <table class="xspecResult">
      <thead>
        <tr>
          <th>Result</th>
          <th>
            <xsl:choose>
              <xsl:when test="$boolean-test">Expecting</xsl:when>
              <xsl:otherwise>Expected Result</xsl:otherwise>
            </xsl:choose>
          </th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <!-- Actual Result -->
          <td>
            <xsl:apply-templates select="$result" mode="x:format-result">
              <xsl:with-param name="result-to-compare-with" select="x:expect[not($boolean-test)]" />
            </xsl:apply-templates>
          </td>

          <td>
            <xsl:choose>
              <!-- Boolean expectation -->
              <xsl:when test="$boolean-test">
                <pre>
                  <xsl:value-of select="x:expect/@test" />
                </pre>
              </xsl:when>

              <!-- Expected Result -->
              <xsl:otherwise>
                <xsl:apply-templates select="x:expect" mode="x:format-result">
                  <xsl:with-param name="result-to-compare-with" select="$result" />
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </tbody>
    </table>

  </div>
</xsl:template>

<!-- Formats the Actual Result or the Expected Result in HTML -->
<xsl:template match="element()" as="element()+" mode="x:format-result">
  <xsl:param name="result-to-compare-with" as="element()?" required="yes" />

  <!-- True if this element represents Expected Result -->
  <xsl:variable name="expected" as="xs:boolean" select=". instance of element(x:expect)" />

  <xsl:choose>
    <xsl:when test="@href or node() or (@select eq '/self::document-node()')">
      <xsl:if test="@select">
        <p>
          <xsl:text>XPath </xsl:text>
          <code>
            <xsl:if test="exists($result-to-compare-with)">
              <xsl:attribute name="class" select="
                test:comparison-html-class(
                  @select,
                  $result-to-compare-with/@select,
                  $expected,
                  false())" />
            </xsl:if>
            <xsl:value-of select="@select" />
          </code>
          <xsl:text> from:</xsl:text>
        </p>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="@href">
          <p><a href="{@href}"><xsl:value-of select="x:format-uri(@href)" /></a></p>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="indentation"
            select="string-length(substring-after(text()[1], '&#xA;'))" />
          <pre>
            <xsl:choose>
              <!-- Serialize the result while performing comparison -->
              <xsl:when test="exists($result-to-compare-with)">
                <xsl:variable name="nodes-to-compare-with" as="node()*"
                  select="if ($result-to-compare-with/@href)
                          then document($result-to-compare-with/@href)/node()
                          else $result-to-compare-with/node()" />
                <xsl:for-each select="node()">
                  <xsl:variable name="significant-pos" as="xs:integer?" select="test:significant-position(.)" />
                  <xsl:apply-templates select="." mode="test:serialize">
                    <xsl:with-param name="indentation" select="$indentation" tunnel="yes" />
                    <xsl:with-param name="perform-comparison" select="true()" tunnel="yes" />
                    <xsl:with-param name="node-to-compare-with" select="$nodes-to-compare-with[test:significant-position(.) eq $significant-pos]" />
                    <xsl:with-param name="expected" select="$expected" />
                  </xsl:apply-templates>
                </xsl:for-each>
              </xsl:when>

              <!-- Serialize the result without performing comparison -->
              <xsl:otherwise>
                <xsl:apply-templates select="node()" mode="test:serialize">
                  <xsl:with-param name="indentation" select="$indentation" tunnel="yes" />
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </pre>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <pre><xsl:value-of select="@select" /></pre>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="x:totals" as="text()?">
  <xsl:context-item use="absent"
    use-when="element-available('xsl:context-item')" />

  <xsl:param name="tests" as="element(x:test)*" required="yes" />
  <xsl:param name="labels" as="xs:boolean" select="false()" />

  <xsl:if test="$tests">
    <xsl:variable name="counts" select="x:totals($tests)"/>

    <xsl:value-of>
      <xsl:if test="$labels">passed: </xsl:if>
      <xsl:value-of select="$counts[1]"/>

      <xsl:if test="$labels"><xsl:text> </xsl:text></xsl:if>
      <xsl:text>/</xsl:text>

      <xsl:if test="$labels"> pending: </xsl:if>
      <xsl:value-of select="$counts[2]"/>

      <xsl:if test="$labels"><xsl:text> </xsl:text></xsl:if>
      <xsl:text>/</xsl:text>

      <xsl:if test="$labels"> failed: </xsl:if>
      <xsl:value-of select="$counts[3]"/>

      <xsl:if test="$labels"><xsl:text> </xsl:text></xsl:if>
      <xsl:text>/</xsl:text>

      <xsl:if test="$labels"> total: </xsl:if>
      <xsl:value-of select="$counts[4]"/>
    </xsl:value-of>
  </xsl:if>
</xsl:template>
  
<xsl:function name="x:totals" as="xs:integer+">
  <xsl:param name="tests" as="element(x:test)*"/>
  <xsl:variable name="passed" as="element(x:test)*" select="$tests[x:is-passed-test(.)]" />
  <xsl:variable name="pending" as="element(x:test)*" select="$tests[x:is-pending-test(.)]" />
  <xsl:variable name="failed" as="element(x:test)*" select="$tests[x:is-failed-test(.)]" />
  <xsl:sequence select="count($passed)"/>
  <xsl:sequence select="count($pending)"/>
  <xsl:sequence select="count($failed)"/>
  <xsl:sequence select="count($tests)"/>
</xsl:function>

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
