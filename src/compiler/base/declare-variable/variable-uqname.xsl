<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      Returns URIQualifiedName of the variable generated by mode="x:declare-variable"
   -->
   <xsl:function as="xs:string" name="x:variable-UQName">
      <xsl:param as="element()" name="source-element" />

      <!-- xsl:for-each is not for iteration but for simplifying XPath -->
      <xsl:for-each select="$source-element">
         <xsl:choose>
            <xsl:when test="@name">
               <xsl:sequence select="x:UQName-from-EQName-ignoring-default-ns(@name, .)" />
            </xsl:when>

            <xsl:otherwise>
               <xsl:sequence
                  select="x:known-UQName('impl:' || local-name() || '-' || generate-id())" />
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
   </xsl:function>

</xsl:stylesheet>
