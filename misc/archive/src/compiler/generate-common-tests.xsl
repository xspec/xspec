<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

   <!--
       Debugging tool.  Return a human-readable path of a node.
   -->
   <xsl:function name="x:node-path" as="xs:string">
      <xsl:param name="n" as="node()" />

      <xsl:value-of>
         <xsl:for-each select="$n/ancestor-or-self::*">
            <xsl:variable name="prec" select="
                preceding-sibling::*[node-name(.) eq node-name(current())]"/>
            <xsl:text expand-text="yes">/{name()}</xsl:text>
            <xsl:if test="exists($prec)">
               <xsl:text expand-text="yes">[{count($prec) + 1}]</xsl:text>
            </xsl:if>
         </xsl:for-each>
         <xsl:choose>
            <xsl:when test="$n instance of attribute()">
               <xsl:text expand-text="yes">/@{name($n)}</xsl:text>
            </xsl:when>
            <xsl:when test="$n instance of text()">
               <xsl:text>/{text: </xsl:text>
               <xsl:value-of select="substring($n, 1, 5)"/>
               <xsl:text>...}</xsl:text>
            </xsl:when>
            <xsl:when test="$n instance of comment()">
               <xsl:text>/{comment}</xsl:text>
            </xsl:when>
            <xsl:when test="$n instance of processing-instruction()">
               <xsl:text>/{pi: </xsl:text>
               <xsl:value-of select="name($n)"/>
               <xsl:text>}</xsl:text>
            </xsl:when>
            <xsl:when test="$n instance of document-node()">
               <xsl:text>/</xsl:text>
            </xsl:when>
            <xsl:when test="$n instance of element()"/>
            <xsl:otherwise>
               <xsl:text>/{ns: </xsl:text>
               <xsl:value-of select="name($n)"/>
               <xsl:text>}</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:value-of>
   </xsl:function>

</xsl:stylesheet>
