<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      Generates an invocation of the template compiled from x:scenario or x:expect.
   -->
   <xsl:template name="x:invoke-compiled-current-scenario-or-expect">
      <!-- Context item is x:scenario or x:expect -->
      <xsl:context-item as="element()" use="required" />

      <xsl:param name="last" as="xs:boolean" />

      <!-- URIQualifiedNames of the variables that will be passed as the parameters (of the same
         URIQualifiedName) to the compiled x:scenario or x:expect being invoked. -->
      <xsl:param name="with-param-uqnames" as="xs:string*" />

      <xsl:element name="xsl:call-template" namespace="{$x:xsl-namespace}">
         <xsl:attribute name="name" select="x:known-UQName('x:' || @id)" />

         <xsl:for-each select="$with-param-uqnames">
            <xsl:element name="xsl:with-param" namespace="{$x:xsl-namespace}">
               <xsl:attribute name="name" select="." />
               <xsl:attribute name="select" select="'$' || ." />
            </xsl:element>
         </xsl:for-each>
      </xsl:element>

      <!-- Continue invoking compiled x:scenario or x:expect elements. -->
      <xsl:call-template name="x:continue-walking-siblings" />
   </xsl:template>

</xsl:stylesheet>