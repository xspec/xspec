<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:my="http://example.org/ns/my"
  version="3.0">
   <!-- Example in Compilation.md, under "SUT" -->

   <xsl:function name="my:f">
      <xsl:param name="p1"/>
      <xsl:param name="p2"/>
      <xsl:sequence select="true()"/>
   </xsl:function>

   <xsl:template name="t">
      <xsl:param name="p1"/>
      <xsl:param name="p2"/>
      <xsl:sequence select="true()"/>
   </xsl:template>

   <xsl:template match="elem">
      <xsl:sequence select="true()"/>
   </xsl:template>
</xsl:stylesheet>
