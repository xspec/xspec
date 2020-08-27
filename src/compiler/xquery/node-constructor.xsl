<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      mode="x:node-constructor"
   -->
   <xsl:mode name="x:node-constructor" on-multiple-match="fail" on-no-match="fail" />

   <xsl:template match="element()" as="node()+" mode="x:node-constructor">
      <xsl:text>element { </xsl:text>
      <xsl:value-of select="node-name() => x:QName-expression()" />
      <xsl:text> } {&#x0A;</xsl:text>

      <xsl:call-template name="x:zero-or-more-node-constructors">
         <xsl:with-param name="nodes"
            select="
               x:element-additional-namespace-nodes(.),
               attribute(),
               node()" />
      </xsl:call-template>

      <xsl:text>&#x0A;}</xsl:text>
   </xsl:template>

   <xsl:template match="namespace-node()" as="text()+" mode="x:node-constructor">
      <xsl:text>namespace { "</xsl:text>
      <xsl:value-of select="name()" />
      <xsl:text>" } { </xsl:text>
      <xsl:value-of select="x:quote-with-apos(.)" />
      <xsl:text> }</xsl:text>
   </xsl:template>

   <xsl:template match="attribute()" as="node()+" mode="x:node-constructor">
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

   <xsl:template match="text()" as="node()+" mode="x:node-constructor">
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

   <xsl:template match="processing-instruction()" as="text()+" mode="x:node-constructor">
      <xsl:text>processing-instruction { "</xsl:text>
      <xsl:value-of select="name()" />
      <xsl:text>" } { </xsl:text>
      <xsl:value-of select="x:quote-with-apos(.)" />
      <xsl:text> }</xsl:text>
   </xsl:template>

   <xsl:template match="comment()" as="text()+" mode="x:node-constructor">
      <xsl:text>comment { </xsl:text>
      <xsl:value-of select="x:quote-with-apos(.)" />
      <xsl:text> }</xsl:text>
   </xsl:template>

   <!-- x:text represents its child text node -->
   <xsl:template match="x:text" as="node()+" mode="x:node-constructor">
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

   <xsl:template name="x:zero-or-more-node-constructors" as="node()+">
      <xsl:context-item use="absent" />

      <xsl:param name="nodes" as="node()*" />

      <xsl:choose>
         <xsl:when test="$nodes">
            <xsl:for-each select="$nodes">
               <xsl:apply-templates select="." mode="x:node-constructor" />
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

</xsl:stylesheet>