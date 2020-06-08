<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

   <!-- Generate an human-readable path to a node within its document. -->
   <xsl:function name="x:node-path" as="xs:string">
      <xsl:param name="n" as="node()" />

      <!-- TODO: In case of a root document node, the path begins with '//'... -->
      <xsl:sequence select="string-join($n/ancestor-or-self::node()/x:node-step(.), '/')" />
   </xsl:function>

   <xsl:function name="x:node-step" as="xs:string">
      <xsl:param name="n" as="node()" />

      <xsl:choose>
         <xsl:when test="$n instance of document-node()">
            <xsl:sequence select="'/'" />
         </xsl:when>

         <xsl:when test="$n instance of element()">
            <xsl:variable name="precedings"
               select="$n/preceding-sibling::*[name(.) eq name($n)]" />
            <xsl:sequence select="concat(name($n), x:node-position($precedings))" />
         </xsl:when>

         <xsl:when test="$n instance of attribute()">
            <xsl:sequence select="concat('@', name($n))" />
         </xsl:when>

         <xsl:when test="$n instance of text()">
            <xsl:variable name="precedings" select="$n/preceding-sibling::text()" />
            <xsl:sequence select="concat('text()', x:node-position($precedings))" />
         </xsl:when>

         <xsl:when test="$n instance of comment()">
            <xsl:variable name="precedings" select="$n/preceding-sibling::comment()" />
            <xsl:sequence select="concat('comment()', x:node-position($precedings))" />
         </xsl:when>

         <xsl:when test="$n instance of processing-instruction()">
            <xsl:variable name="precedings"
               select="$n/preceding-sibling::processing-instruction[name(.) eq name($n)]" />
            <xsl:sequence select="concat('pi(', name($n), ')', x:node-position($precedings))" />
         </xsl:when>

         <!-- if not, that's a namespace node -->
         <xsl:otherwise>
            <xsl:sequence select="concat('ns({', name($n), '}', $n, ')')" />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>

   <xsl:function name="x:node-position" as="xs:string?">
      <xsl:param name="precedings" as="node()*" />

      <xsl:if test="exists($precedings)">
         <xsl:sequence select="concat('[', count($precedings) + 1, ']')" />
      </xsl:if>
   </xsl:function>

   <xsl:function name="msxsl:node-set" as="item()*">
      <xsl:param name="rtf" as="item()*" />

      <xsl:sequence select="$rtf" />
   </xsl:function>

</xsl:stylesheet>
