<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       format-utils.xsl                                         -->
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

<xsl:import href="../compiler/generate-tests-utils.xsl" />

<pkg:import-uri>http://www.jenitennison.com/xslt/xspec/format-utils.xsl</pkg:import-uri>

<xsl:output name="x:report" method="xml" indent="yes"/>

<!-- @character specifies intermediate characters for mimicking @disable-output-escaping.
  For the test result report HTML, these Private Use Area characters should be considered
  as reserved by test:disable-escaping. -->
<xsl:character-map name="test:disable-escaping">
  <xsl:output-character character="&#xE801;" string="&lt;" />
  <xsl:output-character character="&#xE802;" string="&amp;" />
  <xsl:output-character character="&#xE803;" string="&gt;" />
  <xsl:output-character character="&#xE804;" string="&apos;" />
  <xsl:output-character character="&#xE805;" string="&quot;" />
</xsl:character-map>

<!--
  mode="test:serialize"
    All the whitespace-only text nodes except the ones in <test:ws> are considered to be of indentation.
-->

<xsl:template match="element()" as="node()+" mode="test:serialize">
  <xsl:param name="level" as="xs:integer" select="0" tunnel="yes" />
  <xsl:param name="perform-comparison" as="xs:boolean" select="false()" tunnel="yes" />
  <xsl:param name="node-to-compare-with" as="node()?" select="()" />
  <xsl:param name="expected" as="xs:boolean" select="true()" />

  <!-- Open the start tag of this element -->
  <xsl:text>&lt;</xsl:text>

  <!-- Output the name of this element -->
  <xsl:choose>
    <xsl:when test="$perform-comparison">
      <span class="{test:comparison-html-class(., $node-to-compare-with, $expected)}">
        <xsl:value-of select="name()" />
      </span>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="name()" />
    </xsl:otherwise>
  </xsl:choose>

  <!-- Whitespace string for indenting namespace or attribute -->
  <xsl:variable name="ns-attr-indent" as="xs:string">
    <xsl:value-of>
      <xsl:text>&#xA;</xsl:text>
      <xsl:for-each select="1 to $level"><xsl:text>   </xsl:text></xsl:for-each>
      <xsl:value-of select="replace(name(parent::*), '.', ' ')" />
    </xsl:value-of>
  </xsl:variable>

  <!-- Namespace nodes -->
  <xsl:variable name="omit-namespace-uris" as="xs:string+" select="
    'http://www.jenitennison.com/xslt/unit-test' (: test :),
    'http://www.jenitennison.com/xslt/xspec' (: x :),
    'http://www.w3.org/1999/XSL/Transform' (: xsl :),
    'http://www.w3.org/2001/XMLSchema' (: xs :),
    'http://www.w3.org/XML/1998/namespace' (: xml :)" />
  <xsl:variable name="namespaces" as="node()*" select="namespace::*" />
  <xsl:variable name="parent-namespaces" as="node()*" select="parent::element()/namespace::*" />
  <xsl:variable name="significant-namespaces" as="node()*" select="$namespaces[not(string() = $omit-namespace-uris)]" />
  <xsl:variable name="new-namespaces" as="node()*">
    <xsl:choose>
      <xsl:when test="$level eq 0">
        <!-- Take all -->
        <xsl:sequence select="$significant-namespaces" />
      </xsl:when>

      <xsl:otherwise>
        <!-- Take only the ones not appeared in the parent -->
        <xsl:sequence select="for $ns in $significant-namespaces
          return $ns
           [empty(
              $parent-namespaces
                [name() eq name($ns) (: prefix :)]
                [string() eq string($ns) (: URI :)]
           )]" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- Output xmlns="" to undeclare the default namespace -->
  <xsl:if test="exists($parent-namespaces[name() = '']) and empty($namespaces[name() = ''])">
    <xsl:text> xmlns=""</xsl:text>
  </xsl:if>

  <!-- Output namespace nodes -->
  <xsl:for-each select="$new-namespaces">
    <xsl:if test="position() ge 2">
      <xsl:value-of select="$ns-attr-indent" />
    </xsl:if>
    <xsl:text> xmlns</xsl:text>
    <xsl:if test="name()">
      <xsl:value-of select="concat(':', name())" />
    </xsl:if>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>"</xsl:text>
  </xsl:for-each>

  <!-- Output attributes while performing comparison -->
  <xsl:for-each select="@*">
    <xsl:if test="$new-namespaces or (position() ge 2)">
      <xsl:value-of select="$ns-attr-indent" />
    </xsl:if>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="$perform-comparison">
        <xsl:variable name="node-name" as="xs:QName" select="node-name(.)" />
        <xsl:variable name="attribute-to-compare-with" as="attribute()?" select="$node-to-compare-with/@*[node-name(.) = $node-name]" />
        <span class="{test:comparison-html-class(., $attribute-to-compare-with, $expected)}">
          <xsl:value-of select="name()" />
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="name()" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="replace(replace(., '&quot;', '&amp;quot;'),
      '\s(\s+)', '&#xA;$1')" />
    <xsl:text>"</xsl:text>
  </xsl:for-each>

  <!-- Handle the child nodes or end this element -->
  <xsl:choose>
    <xsl:when test="child::node()">
      <!-- Close the start tag of this element -->
      <xsl:text>&gt;</xsl:text>

      <xsl:choose>
        <!-- If this element is in Actual Result and the corresponding node in Expected Result
          has one and only child node which is a text node of '...', then Expected Result does
          not care about the child nodes. So just output the same ellipsis. -->
        <xsl:when test="$perform-comparison and
          not($expected) and
          $node-to-compare-with/node() instance of text() and
          $node-to-compare-with = '...'">
          <span class="same ellipsis">...</span>
        </xsl:when>

        <!-- Serialize the child nodes while performing comparison -->
        <xsl:when test="$perform-comparison">
          <xsl:for-each select="node()">
            <xsl:variable name="significant-pos" as="xs:integer?" select="test:significant-position(.)" />
            <xsl:apply-templates select="." mode="test:serialize">
              <xsl:with-param name="level" select="$level + 1" tunnel="yes" />
              <xsl:with-param name="node-to-compare-with" select="$node-to-compare-with/node()[test:significant-position(.) eq $significant-pos]" />
              <xsl:with-param name="expected" select="$expected" />
            </xsl:apply-templates>
          </xsl:for-each>
        </xsl:when>

        <!-- Serialize the child nodes without performing comparison -->
        <xsl:otherwise>
          <xsl:apply-templates mode="test:serialize">
            <xsl:with-param name="level" select="$level + 1" tunnel="yes" />
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>      

      <!-- End this element -->
      <xsl:text>&lt;/</xsl:text>
      <xsl:value-of select="name()" />
      <xsl:text>&gt;</xsl:text>
    </xsl:when>

    <!-- End this element without any child node -->
    <xsl:otherwise> /&gt;</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="comment() | processing-instruction() | text() | test:ws" as="node()" mode="test:serialize">
  <xsl:param name="perform-comparison" as="xs:boolean" select="false()" tunnel="yes" />
  <xsl:param name="node-to-compare-with" as="node()?" select="()" />
  <xsl:param name="expected" as="xs:boolean" select="true()" />

  <xsl:variable name="serialized" as="text()">
    <xsl:choose>
      <xsl:when test="self::comment()">
        <xsl:value-of select="concat('&lt;!--', ., '-->')" />
      </xsl:when>

      <xsl:when test="self::processing-instruction()">
        <xsl:value-of select="concat('&lt;?', name(), ' ', ., '?>')" />
      </xsl:when>

      <xsl:when test="self::text()">
        <xsl:sequence select="." />
      </xsl:when>

      <xsl:when test="self::test:ws">
        <xsl:value-of>
          <xsl:analyze-string select="." regex="[&#x09;&#x0A;&#x0D;&#x20;]">
            <xsl:matching-substring>
              <xsl:choose>
                <xsl:when test=". eq '&#x09;'">\t</xsl:when>
                <xsl:when test=". eq '&#x0A;'">\n</xsl:when>
                <xsl:when test=". eq '&#x0D;'">\r</xsl:when>
                <xsl:when test=". eq '&#x20;'">
                  <!-- OPEN BOX character -->
                  <xsl:value-of select="'&#x2423;'" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:message select="'Unexpected whitespace'" terminate="yes" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:matching-substring>

            <xsl:non-matching-substring>
              <xsl:message select="'Unexpected character'" terminate="yes" />
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:value-of>
      </xsl:when>

      <xsl:otherwise>
        <xsl:message select="'Node not serialized'" terminate="yes" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$perform-comparison or self::test:ws">
      <span class="{
        test:comparison-html-class(., $node-to-compare-with, $expected)[$perform-comparison],
        'whitespace'[current()/self::test:ws]
        }">
        <xsl:sequence select="$serialized" />
      </span>
    </xsl:when>

    <xsl:otherwise>
      <xsl:sequence select="$serialized" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="text()[not(normalize-space())]" as="text()?" mode="test:serialize">
  <xsl:param name="level" as="xs:integer" select="0" tunnel="yes" />
  <xsl:param name="indentation" as="xs:integer" select="0" tunnel="yes" />

  <xsl:choose>
    <xsl:when test="
      ($level eq 0)
      and
      (
        (: leading or trailing indent :)
        not(preceding-sibling::node()) or not(following-sibling::node())
      )">
      <!-- Discard -->
    </xsl:when>

    <xsl:otherwise>
      <xsl:value-of select="concat('&#x0A;', substring(., $indentation + 2))" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="document-node() | attribute() | node()" as="empty-sequence()" mode="test:serialize" priority="-1">
  <xsl:message select="'Unhandled node'" terminate="yes" />
</xsl:template>

<!-- Returns the position of the node, ignoring the preceding-sibling whitespace-only text nodes.
  Returns an empty sequence, if the node is a whitespace-only text node. -->
<xsl:function name="test:significant-position" as="xs:integer?">
  <xsl:param name="node" as="node()" />

  <xsl:choose>
    <xsl:when test="$node/self::text() and not(normalize-space($node))">
      <!-- The node is a whitespace-only text node. Return an empty sequence. -->
    </xsl:when>

    <xsl:otherwise>
      <!-- Count the preceding-sibling nodes, ignoring whitespace-only text nodes -->
      <xsl:sequence select="
        count(
          $node/preceding-sibling::node()
            [not(
              self::text() and not(normalize-space())
            )]
        )
        + 1" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- Compares $node with $node-to-compare-with and returns an HTML class accordingly: 'same' or 'diff'
  Set $expected to true if $node is in Expected Result. Set false if in Actual Result. -->
<xsl:function name="test:comparison-html-class" as="xs:string">
  <xsl:param name="node" as="node()" />
  <xsl:param name="node-to-compare-with" as="node()?" />
  <xsl:param name="expected" as="xs:boolean" />

  <xsl:variable name="equal" as="xs:boolean" select="
    if ($expected)
    then test:deep-equal($node, $node-to-compare-with, 'w')
    else test:deep-equal($node-to-compare-with, $node, 'w')" />

  <xsl:sequence select="if ($equal) then 'same' else 'diff'" />
</xsl:function>

<xsl:function name="test:format-URI" as="xs:string">
  <xsl:param name="URI" as="xs:anyURI" />
  <xsl:choose>
    <xsl:when test="starts-with($URI, 'file:/')">
      <xsl:value-of select="replace(substring-after($URI, 'file:/'), '%20', ' ')" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$URI" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>

<!-- Generates <style> or <link> for CSS.
  If you enable $inline, you must use test:disable-escaping character map in serialization. -->
<xsl:template name="test:load-css" as="element()">
  <xsl:param name="inline" as="xs:boolean" required="yes" />
  <xsl:param name="uri" as="xs:string?" />

  <xsl:variable as="xs:string" name="uri" select="($uri, resolve-uri('test-report.css'))[1]" />

  <xsl:choose>
    <xsl:when test="$inline">
      <xsl:variable name="css-string" as="xs:string" select="unparsed-text($uri)" />

      <!-- Replace CR LF with LF -->
      <xsl:variable name="css-string" as="xs:string" select="replace($css-string, '&#x0D;(&#x0A;)', '$1')" />

      <style type="text/css">
        <xsl:value-of select="test:disable-escaping($css-string)" />
      </style>
    </xsl:when>

    <xsl:otherwise>
      <link rel="stylesheet" type="text/css" href="{$uri}"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Replaces < & > ' " characters with the reserved characters.
  The serializer will convert those reserved characters back to < & > ' " characters,
  provided that test:disable-escaping character map is specified as a serialization parameter. -->
<xsl:function name="test:disable-escaping" as="xs:string">
  <xsl:param name="input" as="xs:string" />

  <xsl:sequence select="
    document('')
    /element()/xsl:character-map[@name eq 'test:disable-escaping']
    /translate(
      $input,
      string-join(xsl:output-character/@string, ''),
      string-join(xsl:output-character/@character, '')
      )"/>
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
