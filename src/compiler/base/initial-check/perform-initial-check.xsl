<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <xsl:template name="x:perform-initial-check" as="empty-sequence()">
      <xsl:context-item as="document-node()" use="required" />

      <xsl:variable name="deprecation-warning" as="xs:string?">
         <xsl:choose>
            <xsl:when test="$x:saxon-version lt x:pack-version((9, 8))">
               <xsl:text>Saxon version 9.7 or less is not supported.</xsl:text>
            </xsl:when>
            <xsl:when test="$x:saxon-version lt x:pack-version((9, 9))">
               <xsl:text>Saxon version 9.8 is not recommended. Consider migrating to Saxon 9.9.</xsl:text>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:message select="
         if ($deprecation-warning)
         then ('WARNING:', $deprecation-warning)
         else ' ' (: Always write a single non-empty line to help Bats tests to predict line numbers. :)" />

      <xsl:variable name="description-name" as="xs:QName" select="xs:QName('x:description')" />
      <xsl:if test="not(node-name(element()) eq $description-name)">
         <xsl:message terminate="yes">
            <xsl:text expand-text="yes">Source document is not XSpec. /{$description-name} is missing. Supplied source has /{element() => name()} instead.</xsl:text>
         </xsl:message>
      </xsl:if>
   </xsl:template>

</xsl:stylesheet>