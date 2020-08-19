<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       generate-tests-helper.xsl                                -->
<!--  Author:     Jeni Tennison                                            -->
<!--  URL:        http://github.com/xspec/xspec                            -->
<!--  Tags:                                                                -->
<!--    Copyright (c) 2008, 2010 Jeni Tennison (see end of file.)          -->
<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->


<xsl:stylesheet version="3.0"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">
  
   <pkg:import-uri>http://www.jenitennison.com/xslt/xspec/generate-tests-helper.xsl</pkg:import-uri>

   <!--
      mode="x:declare-variable"
      Generates XSLT variable declaration(s) from the current element.
      
      This mode itself does not handle whitespace-only text nodes specially. To handle
      whitespace-only text node in a special manner, the text node should be handled specially
      before applying this mode and/or mode="x:node-constructor" should be overridden.
      
      This mode does not handle @static. It is just ignored. Enabling @static will create a usual
      non-static parameter or variable.
   -->
   <xsl:mode name="x:declare-variable" on-multiple-match="fail" on-no-match="fail" />

   <xsl:template match="element()" as="element()+" mode="x:declare-variable">
      <!-- Reflects @pending or x:pending -->
      <xsl:param name="pending" as="node()?" tunnel="yes" />

      <xsl:param name="comment" as="xs:string?" />

      <!-- URIQualifiedName of the variable being declared -->
      <xsl:variable name="uqname" as="xs:string" select="x:variable-UQName(.)" />

      <!-- True if the variable being declared is considered pending -->
      <xsl:variable name="is-pending" as="xs:boolean"
         select="self::x:variable
            and not(empty($pending|ancestor::x:scenario/@pending) or exists(ancestor::*/@focus))" />

      <!-- Child nodes to be excluded -->
      <xsl:variable name="exclude" as="element()*"
         select="self::x:context/x:param, self::x:expect/x:label" />

      <!-- True if the variable should be declared as global -->
      <xsl:variable name="is-global" as="xs:boolean" select="exists(parent::x:description)" />

      <!-- True if the variable should be declared using xsl:param (not xsl:variable) -->
      <xsl:variable name="is-param" as="xs:boolean" select="self::x:param and $is-global" />

      <!-- URIQualifiedName of the temporary runtime variable which holds a document specified by
         child::node() or @href -->
      <xsl:variable name="temp-doc-uqname" as="xs:string?">
         <xsl:if test="not($is-pending) and (node() or @href)">
            <xsl:sequence
               select="x:known-UQName('impl:' || local-name() || '-' || generate-id() || '-doc')" />
         </xsl:if>
      </xsl:variable>

      <xsl:if test="$temp-doc-uqname">
         <xsl:element name="xsl:variable" namespace="{$x:xsl-namespace}">
            <xsl:attribute name="name" select="$temp-doc-uqname" />
            <xsl:attribute name="as" select="'document-node()'" />

            <xsl:choose>
               <xsl:when test="@href">
                  <xsl:attribute name="select">
                     <xsl:text expand-text="yes">doc({@href => resolve-uri(base-uri()) => x:quote-with-apos()})</xsl:text>
                  </xsl:attribute>
               </xsl:when>

               <xsl:otherwise>
                  <xsl:element name="xsl:document" namespace="{$x:xsl-namespace}">
                     <xsl:apply-templates select="node() except $exclude" mode="x:node-constructor" />
                  </xsl:element>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:if>

      <xsl:element name="xsl:{if ($is-param) then 'param' else 'variable'}"
         namespace="{$x:xsl-namespace}">
         <!-- @as or @select may use namespace prefixes. @select may use the default namespace such
            as xs:QName('foo'). -->
         <xsl:if test="@as or @select">
            <xsl:sequence select="x:copy-of-namespaces(.)" />
         </xsl:if>

         <xsl:attribute name="name" select="$uqname" />
         <xsl:sequence select="@as" />

         <xsl:choose>
            <xsl:when test="$is-pending">
               <!-- Do not give variable a value, because the value specified
                  in test file might not be executable. Override data type, because
                  an empty sequence might not be valid for the type specified in test file. -->
               <xsl:attribute name="as" select="'item()*'" />
            </xsl:when>

            <xsl:when test="$temp-doc-uqname">
               <xsl:variable name="selection" as="xs:string"
                  select="(@select, '.'[current()/@href], 'node()')[1]" />
               <xsl:attribute name="select">
                  <xsl:text expand-text="yes">${$temp-doc-uqname} ! ( {$selection} )</xsl:text>
               </xsl:attribute>
            </xsl:when>

            <xsl:when test="empty(@as) and empty(@select)">
               <!--
                  Prevent the variable from being an unexpected zero-length string.

                  https://www.w3.org/TR/xslt-30/#variable-values
                        <xsl:variable name="x"/>
                     is equivalent to
                        <xsl:variable name="x" select="''"/>
               -->
               <xsl:attribute name="select" select="'()'" />
            </xsl:when>

            <xsl:otherwise>
               <xsl:sequence select="@select" />
            </xsl:otherwise>
         </xsl:choose>

         <xsl:if test="$comment">
            <xsl:comment select="$comment" />
         </xsl:if>
      </xsl:element>
   </xsl:template>

   <!--
      mode="x:node-constructor"
   -->
   <xsl:mode name="x:node-constructor" on-multiple-match="fail" on-no-match="fail" />

   <xsl:template match="element()" as="element(xsl:element)" mode="x:node-constructor">
      <xsl:element name="xsl:element" namespace="{$x:xsl-namespace}">
         <xsl:attribute name="name" select="name()" />
         <xsl:attribute name="namespace" select="namespace-uri()" />

         <xsl:apply-templates
            select="
               x:element-additional-namespace-nodes(.),
               attribute(),
               node()"
            mode="#current" />
      </xsl:element>
   </xsl:template>

   <xsl:template match="namespace-node()" as="element(xsl:namespace)" mode="x:node-constructor">
      <xsl:element name="xsl:namespace" namespace="{$x:xsl-namespace}">
         <xsl:attribute name="name" select="name()" />
         <xsl:value-of select="." />
      </xsl:element>
   </xsl:template>

   <xsl:template match="attribute()" as="element(xsl:attribute)" mode="x:node-constructor">
      <xsl:variable name="maybe-avt" as="xs:boolean" select="x:is-user-content(.)" />

      <xsl:element name="xsl:attribute" namespace="{$x:xsl-namespace}">
         <xsl:if test="$maybe-avt">
            <!-- AVT may use namespace prefixes and/or the default namespace such as
               xs:QName('foo') -->
            <xsl:sequence select="parent::element() => x:copy-of-namespaces()" />
         </xsl:if>

         <xsl:attribute name="name" select="name()" />
         <xsl:attribute name="namespace" select="namespace-uri()" />

         <xsl:choose>
            <xsl:when test="$maybe-avt">
               <xsl:attribute name="select">'', ''</xsl:attribute>
               <xsl:attribute name="separator" select="." />
            </xsl:when>

            <xsl:otherwise>
               <xsl:value-of select="." />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>

   <xsl:template match="text()" as="element(xsl:text)" mode="x:node-constructor">
      <xsl:element name="xsl:text" namespace="{$x:xsl-namespace}">
         <xsl:if test="x:is-user-content(.)">
            <xsl:if test="parent::x:text/@expand-text/x:yes-no-synonym(.)">
               <!-- TVT may use namespace prefixes and/or the default namespace such as
                  xs:QName('foo') -->
               <xsl:sequence select="x:copy-of-namespaces(parent::x:text)" />
            </xsl:if>

            <xsl:sequence select="parent::x:text/@expand-text" />
         </xsl:if>

         <xsl:sequence select="." />
      </xsl:element>
   </xsl:template>

   <xsl:template match="processing-instruction()" as="element(xsl:processing-instruction)"
      mode="x:node-constructor">
      <xsl:element name="xsl:processing-instruction" namespace="{$x:xsl-namespace}">
         <xsl:attribute name="name" select="name()" />

         <xsl:value-of select="." />
      </xsl:element>
   </xsl:template>

   <xsl:template match="comment()" as="element(xsl:comment)" mode="x:node-constructor">
      <xsl:element name="xsl:comment" namespace="{$x:xsl-namespace}">
         <xsl:value-of select="." />
      </xsl:element>
   </xsl:template>

   <!-- x:text represents its child text node -->
   <xsl:template match="x:text" as="element(xsl:text)" mode="x:node-constructor">
      <!-- Unwrap -->
      <xsl:apply-templates mode="#current" />
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
