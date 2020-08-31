<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <xsl:template name="x:wrap-node-constructors-and-undeclare-default-ns" as="element(xsl:element)">
      <xsl:param name="wrapper-name" as="xs:string" />
      <xsl:param name="node-constructors" as="element()" />

      <xsl:element name="xsl:element" namespace="{$x:xsl-namespace}">
         <xsl:attribute name="name" select="$wrapper-name" />
         <xsl:attribute name="namespace" />

         <xsl:sequence select="$node-constructors" />
      </xsl:element>
   </xsl:template>

</xsl:stylesheet>