<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:message Coverage Test Case from https://saxonica.plan.io/issues/6492
  -->
  <xsl:param name="globalBoolean" select="not(false())"/>
  <xsl:template match="source">
    <xsl:param name="localBoolean" select="boolean(1)"/>
    <xsl:value-of select="$globalBoolean"/>
    <xsl:value-of select="$localBoolean"/>
    <xsl:message>mes</xsl:message>
  </xsl:template>
</xsl:stylesheet>