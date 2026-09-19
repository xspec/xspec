<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:local="urn:x-xspec:compiler:base:initial-check:perform-initial-check:local"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <xsl:function name="local:saxon-deprecation-warning" as="text()?">
      <xsl:param name="saxon-version" as="xs:integer?"/>
      <xsl:choose>
         <xsl:when test="$saxon-version lt x:pack-version((12, 0))">
            <xsl:text>Saxon version 11 or earlier is not supported.</xsl:text>
         </xsl:when>
         <xsl:when test="$saxon-version lt x:pack-version((12, 4))">
            <xsl:text>Saxon version 12.3 or earlier is not recommended. Consider migrating to Saxon 12.4 or later.</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:function>

</xsl:stylesheet>
