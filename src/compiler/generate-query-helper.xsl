<?xml version="1.0" encoding="UTF-8"?>
<!-- ===================================================================== -->
<!--  File:       generate-query-helper.xsl                                -->
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
  
   <pkg:import-uri>http://www.jenitennison.com/xslt/xspec/generate-query-helper.xsl</pkg:import-uri>

   <!--
      Generates XQuery variable declaration(s) from the current element.
      
      This mode itself does not handle whitespace-only text nodes specially. To handle
      whitespace-only text node in a special manner, the text node should be handled specially
      before applying this mode and/or mode="x:create-node-generator" should be overridden.
   -->
   <xsl:mode name="x:generate-variable-declarations" on-multiple-match="fail" on-no-match="fail" />

   <xsl:template match="element()" as="node()+" mode="x:generate-variable-declarations">
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
      <xsl:variable name="exclude" as="element(x:label)?"
         select="self::x:expect/x:label" />

      <!-- True if the variable should be declared as global -->
      <xsl:variable name="is-global" as="xs:boolean" select="exists(parent::x:description)" />

      <!-- True if the variable should be declared as external.
         TODO: If true, define external variable (which can have a default value in
         XQuery 1.1, but not in 1.0, so we will need to generate an error for global
         x:param with default value...) -->
      <!--<xsl:variable name="is-param" as="xs:boolean" select="self::x:param and $is-global" />-->

      <!-- Reject @static=yes -->
      <xsl:if test="x:yes-no-synonym(@static, false())">
         <xsl:message terminate="yes">
            <xsl:text expand-text="yes">Enabling @static in {name()} is not supported for XQuery.</xsl:text>
         </xsl:message>
      </xsl:if>

      <!-- URIQualifiedName of the temporary runtime variable which holds a document specified by
         child::node() or @href -->
      <xsl:variable name="temp-doc-uqname" as="xs:string?">
         <xsl:if test="not($is-pending) and (node() or @href)">
            <xsl:sequence
               select="x:known-UQName('impl:' || local-name() || '-' || generate-id() || '-doc')" />
         </xsl:if>
      </xsl:variable>

      <!--
         Output
            declare variable $TEMPORARYNAME-doc as document-node() := DOCUMENT;
         or
                         let $TEMPORARYNAME-doc as document-node() := DOCUMENT
         
         where DOCUMENT is
            doc('RESOLVED-HREF')
         or
            document { NODE-GENERATORS }
      -->
      <xsl:if test="$temp-doc-uqname">
         <xsl:call-template name="x:declare-or-let-variable">
            <xsl:with-param name="is-global" select="$is-global" />
            <xsl:with-param name="name" select="$temp-doc-uqname" />
            <xsl:with-param name="type" select="'document-node()'" />
            <xsl:with-param name="value" as="node()+">
               <xsl:choose>
                  <xsl:when test="@href">
                     <xsl:text expand-text="yes">doc({@href => resolve-uri(base-uri()) => x:quote-with-apos()})</xsl:text>
                  </xsl:when>

                  <xsl:otherwise>
                     <xsl:text>document {&#x0A;</xsl:text>
                     <xsl:call-template name="x:create-zero-or-more-node-generators">
                        <xsl:with-param name="nodes" select="node() except $exclude" />
                     </xsl:call-template>
                     <xsl:text>&#x0A;</xsl:text>
                     <xsl:text>}</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:with-param>
         </xsl:call-template>
      </xsl:if>

      <!--
         Output
            declare variable ${$name} as TYPE := SELECTION;
         or
                         let ${$name} as TYPE := SELECTION
         
         where SELECTION is
            ( $TEMPORARYNAME-doc ! ( EXPRESSION ) )
         or
            ( EXPRESSION )
      -->
      <xsl:call-template name="x:declare-or-let-variable">
         <xsl:with-param name="is-global" select="$is-global" />
         <xsl:with-param name="name" select="$uqname" />
         <xsl:with-param name="type" select="if ($is-pending) then () else (@as)" />
         <xsl:with-param name="value" as="text()?">
            <xsl:choose>
               <xsl:when test="$is-pending">
                  <!-- Do not give variable a value (or type, above) because the value specified
                    in test file might not be executable. -->
               </xsl:when>

               <xsl:when test="$temp-doc-uqname">
                  <xsl:variable name="selection" as="xs:string"
                     select="(@select, '.'[current()/@href], 'node()')[1]" />
                  <xsl:text expand-text="yes">${$temp-doc-uqname} ! ( {x:disable-escaping($selection)} )</xsl:text>
               </xsl:when>

               <xsl:when test="@select">
                  <xsl:value-of select="x:disable-escaping(@select)" />
               </xsl:when>
            </xsl:choose>
         </xsl:with-param>
         <xsl:with-param name="comment" select="$comment" />
      </xsl:call-template>
   </xsl:template>

   <!--
      Outputs
         declare variable $NAME as TYPE := ( VALUE );
      or
                      let $NAME as TYPE := ( VALUE )
   -->
   <xsl:template name="x:declare-or-let-variable" as="node()+">
      <xsl:context-item use="absent" />

      <xsl:param name="is-global" as="xs:boolean" required="yes" />
      <xsl:param name="name" as="xs:string" required="yes" />
      <xsl:param name="type" as="xs:string?" required="yes" />
      <xsl:param name="value" as="node()*" required="yes" />
      <xsl:param name="comment" as="xs:string?" />

      <xsl:choose>
         <xsl:when test="$is-global">
            <xsl:text>declare variable</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>let</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

      <xsl:text expand-text="yes"> ${$name}</xsl:text>

      <xsl:if test="$type">
         <xsl:text expand-text="yes"> as {$type}</xsl:text>
      </xsl:if>

      <xsl:if test="$comment">
         <xsl:text expand-text="yes"> (:{$comment}:)</xsl:text>
      </xsl:if>

      <xsl:text> := (&#x0A;</xsl:text>

      <xsl:choose>
         <xsl:when test="$value">
            <xsl:sequence select="$value" />
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>()</xsl:text>
         </xsl:otherwise>
      </xsl:choose>

      <xsl:text>&#x0A;)</xsl:text>

      <xsl:if test="$is-global">
         <xsl:text>;</xsl:text>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
   </xsl:template>

   <!--
      mode="x:create-node-generator"
   -->
   <xsl:mode name="x:create-node-generator" on-multiple-match="fail" on-no-match="fail" />

   <xsl:template match="element()" as="node()+" mode="x:create-node-generator">
      <xsl:text>element { </xsl:text>
      <xsl:value-of select="node-name() => x:QName-expression()" />
      <xsl:text> } {&#x0A;</xsl:text>

      <xsl:call-template name="x:create-zero-or-more-node-generators">
         <xsl:with-param name="nodes"
            select="
               x:element-additional-namespace-nodes(.),
               attribute(),
               node()" />
      </xsl:call-template>

      <xsl:text>&#x0A;}</xsl:text>
   </xsl:template>

   <xsl:template match="namespace-node()" as="text()+" mode="x:create-node-generator">
      <xsl:text>namespace { "</xsl:text>
      <xsl:value-of select="name()" />
      <xsl:text>" } { </xsl:text>
      <xsl:value-of select="x:quote-with-apos(.)" />
      <xsl:text> }</xsl:text>
   </xsl:template>

   <xsl:template match="attribute()" as="node()+" mode="x:create-node-generator">
      <xsl:text>attribute { </xsl:text>
      <xsl:value-of select="node-name() => x:QName-expression()" />
      <xsl:text> } { </xsl:text>

      <xsl:choose>
         <xsl:when test="x:is-user-content(.)">
            <xsl:call-template name="x:avt-or-tvt" />
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="x:quote-with-apos(.)" />
         </xsl:otherwise>
      </xsl:choose>

      <xsl:text> }</xsl:text>
   </xsl:template>

   <xsl:template match="text()" as="node()+" mode="x:create-node-generator">
      <xsl:text>text { </xsl:text>

      <xsl:choose>
         <xsl:when test="x:is-user-content(.) and parent::x:text/@expand-text/x:yes-no-synonym(.)">
            <xsl:call-template name="x:avt-or-tvt" />
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="x:quote-with-apos(.)" />
         </xsl:otherwise>
      </xsl:choose>

      <xsl:text> }</xsl:text>
   </xsl:template>

   <xsl:template match="processing-instruction()" as="text()+" mode="x:create-node-generator">
      <xsl:text>processing-instruction { "</xsl:text>
      <xsl:value-of select="name()" />
      <xsl:text>" } { </xsl:text>
      <xsl:value-of select="x:quote-with-apos(.)" />
      <xsl:text> }</xsl:text>
   </xsl:template>

   <xsl:template match="comment()" as="text()+" mode="x:create-node-generator">
      <xsl:text>comment { </xsl:text>
      <xsl:value-of select="x:quote-with-apos(.)" />
      <xsl:text> }</xsl:text>
   </xsl:template>

   <!-- x:text represents its child text node -->
   <xsl:template match="x:text" as="node()+" mode="x:create-node-generator">
      <!-- Unwrap -->
      <xsl:apply-templates mode="#current" />
   </xsl:template>

   <xsl:template name="x:avt-or-tvt" as="node()+">
      <xsl:context-item as="node()" use="required" />

      <!-- TODO: '<' and '>' inside expressions should not be escaped. They (and other special
         characters) should be escaped outside expressions. In other words, an attribute
         attr="&gt; {0 &gt; 1} &lt; {0 &lt; 1}" in user-content in an XSpec file should be treated
         as equal to attr="&gt; false &lt; true". -->
      <!-- Use x:xspec-name() for the element name so that the namespace for the name of the
         created element does not pollute the namespaces copied for AVT/TVT. -->
      <xsl:element name="{x:xspec-name('dummy', parent::element())}"
         namespace="{$x:xspec-namespace}">
         <!-- AVT/TVT may use namespace prefixes and/or the default namespace such as
            xs:QName('foo') -->
         <xsl:sequence select="parent::element() => x:copy-of-namespaces()" />

         <xsl:attribute name="vt" select="." />
      </xsl:element>
      <xsl:text>/@vt</xsl:text>
   </xsl:template>

   <xsl:template name="x:create-zero-or-more-node-generators" as="node()+">
      <xsl:context-item use="absent" />

      <xsl:param name="nodes" as="node()*" />

      <xsl:choose>
         <xsl:when test="$nodes">
            <xsl:for-each select="$nodes">
               <xsl:apply-templates select="." mode="x:create-node-generator" />
               <xsl:if test="position() ne last()">
                  <xsl:text>,&#x0A;</xsl:text>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>

         <xsl:otherwise>
            <xsl:text>()</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!-- @character specifies intermediate characters for mimicking @disable-output-escaping.
      For the XQuery XSpec, these Private Use Area characters should be considered as reserved by
      x:disable-escaping.
      This mapping should be in sync with t:escape-markup in ../harnesses/harness-lib.xpl. -->
   <xsl:character-map name="x:disable-escaping">
      <xsl:output-character character="&#xE801;" string="&lt;" />
      <xsl:output-character character="&#xE803;" string="&gt;" />
   </xsl:character-map>

   <!-- Replaces < > characters with the reserved characters.
      The serializer will convert those reserved characters back to < > characters,
      provided that x:disable-escaping character map is specified as a serialization
      parameter.
      Returns a zero-length string if the input is an empty sequence. -->
   <xsl:function name="x:disable-escaping" as="xs:string">
      <xsl:param name="input" as="xs:string?" />

      <xsl:sequence select="
         doc('')
         /xsl:*
         /xsl:character-map[@name eq 'x:disable-escaping']
         /translate(
            $input,
            string-join(xsl:output-character/@string),
            string-join(xsl:output-character/@character)
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
