<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      Generates an invocation of the function compiled from x:scenario or x:expect.
   -->
   <xsl:template name="x:invoke-compiled-current-scenario-or-expect">
      <!-- Context item is x:scenario or x:expect -->
      <xsl:context-item as="element()" use="required" />

      <xsl:param name="last" as="xs:boolean" />

      <!-- URIQualifiedNames of the variables that will be passed as the parameters to the compiled
         x:scenario or x:expect being invoked.
         Their order must be stable, because they are passed to a function. -->
      <xsl:param name="with-param-uqnames" as="xs:string*" />

      <xsl:if test="exists(preceding-sibling::x:*[1][self::x:pending])">
         <xsl:text>,&#10;</xsl:text>
      </xsl:if>

      <xsl:text expand-text="yes">let ${x:known-UQName('x:tmp')} := local:{@id}(&#x0A;</xsl:text>
      <xsl:for-each select="$with-param-uqnames">
         <xsl:text expand-text="yes">${.}</xsl:text>
         <xsl:if test="position() ne last()">
            <xsl:text>,</xsl:text>
         </xsl:if>
         <xsl:text>&#x0A;</xsl:text>
      </xsl:for-each>
      <xsl:text>)&#x0A;</xsl:text>

      <xsl:text>return (&#x0A;</xsl:text>
      <xsl:text expand-text="yes">${x:known-UQName('x:tmp')}</xsl:text>
      <xsl:if test="not($last)">
         <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>&#10;</xsl:text>
      <!-- Continue invoking compiled x:scenario or x:expect elements. -->
      <xsl:call-template name="x:continue-walking-siblings" />
      <xsl:text>)&#x0A;</xsl:text>
   </xsl:template>

</xsl:stylesheet>