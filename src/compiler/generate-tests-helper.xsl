<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       generate-tests-helper.xsl                                -->
<!--  Author:     Jeni Tennison                                            -->
<!--  URL:        http://github.com/xspec/xspec                            -->
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
                exclude-result-prefixes="#all"
                extension-element-prefixes="test">
  
<pkg:import-uri>http://www.jenitennison.com/xslt/xspec/generate-tests-helper.xsl</pkg:import-uri>

<xsl:namespace-alias stylesheet-prefix="#default" result-prefix="xsl"/>

<xsl:key name="functions" 
         match="xsl:function" 
         use="resolve-QName(@name, .)" />

<xsl:key name="named-templates" 
         match="xsl:template[@name]"
         use="if (contains(@name, ':'))
	            then resolve-QName(@name, .)
	            else QName('', @name)" />

<xsl:key name="matching-templates" 
         match="xsl:template[@match]" 
         use="concat('match=', normalize-space(@match), '+',
                     'mode=', normalize-space(@mode))" />


<xsl:template match="*" as="element()+" mode="test:generate-variable-declarations">
  <xsl:param name="var" as="xs:string" required="yes" />
  <xsl:param name="type" as="xs:string" select="'variable'" />

  <xsl:variable name="var-doc" as="xs:string?"
    select="if (node() or @href) then concat($var, '-doc') else ()" />

  <xsl:if test="$var-doc">
    <variable name="{$var-doc}" as="document-node()">
      <xsl:choose>
        <xsl:when test="@href">
          <xsl:attribute name="select">
            <xsl:text>doc('</xsl:text>
            <xsl:value-of select="resolve-uri(@href, base-uri())" />
            <xsl:text>')</xsl:text>
          </xsl:attribute>
        </xsl:when>

        <xsl:otherwise>
          <document>
            <xsl:apply-templates mode="test:create-node-generator" />
          </document>
        </xsl:otherwise>
      </xsl:choose>
    </variable>
  </xsl:if>

  <xsl:element name="xsl:{$type}">
    <xsl:attribute name="name" select="$var" />
    <xsl:sequence select="@as" />

    <xsl:choose>
      <xsl:when test="$var-doc">
        <xsl:if test="empty(@as)">
          <!-- Set @as in order not to create an unexpected document node:
            http://www.w3.org/TR/xslt20/#temporary-trees -->
          <xsl:attribute name="as" select="'item()*'" />
        </xsl:if>

        <for-each select="${$var-doc}">
          <sequence select="{(@select, '.'[current()/@href], 'node()')[1]}" />
        </for-each>
      </xsl:when>

      <xsl:otherwise>
        <xsl:attribute name="select" select="(@select, '()')[1]" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>
</xsl:template>


<xsl:template match="element()" as="element()" mode="test:create-node-generator">
  <!-- Non XSLT elements (non xsl:* elements) can be just thrown into identity template -->
  <xsl:call-template name="x:identity" />
</xsl:template>

<xsl:template match="attribute() | comment() | processing-instruction() | text()"
  as="element()" mode="test:create-node-generator">
  <!-- As for attribute(), do not just throw XSLT attributes (@xsl:*) into identity template.
    If you do so, the attribute being generated becomes a generator... -->
  <xsl:element name="xsl:{x:node-type(.)}">
    <xsl:if test="(. instance of attribute()) or (. instance of processing-instruction())">
      <xsl:attribute name="name" select="name()" />
    </xsl:if>

    <xsl:choose>
      <xsl:when test="(. instance of attribute()) and x:is-user-content(.)">
        <!-- AVT -->
        <xsl:attribute name="select">'', ''</xsl:attribute>
        <xsl:attribute name="separator" select="." />
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>
</xsl:template>

<xsl:template match="xsl:*" as="element(xsl:element)" mode="test:create-node-generator">
  <!-- Do not just throw XSLT elements (xsl:*) into identity template.
    If you do so, the element being generated becomes a generator... -->
  <element name="{name()}">
    <xsl:variable name="context-element" as="element()" select="." />
    <xsl:for-each select="in-scope-prefixes($context-element)[not(. eq 'xml')]">
      <namespace name="{.}">
        <xsl:value-of select="namespace-uri-for-prefix(., $context-element)" />
      </namespace>
    </xsl:for-each>

    <xsl:apply-templates select="attribute() | node()" mode="#current" />
  </element>
</xsl:template>

<xsl:function name="test:matching-xslt-elements" as="element()*">
  <xsl:param name="element-kind" as="xs:string"/>
  <xsl:param name="element-id" as="item()"/>
  <xsl:param name="stylesheet" as="document-node()"/>
  <xsl:sequence select="key($element-kind, $element-id, $stylesheet)"/>
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
