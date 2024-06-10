<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:element Coverage Test Case
  -->
  <xsl:template match="xsl-element">
    <root>
      <xsl:element name="node">
        <xsl:attribute name="type">element</xsl:attribute>
        <xsl:text>100</xsl:text>
      </xsl:element>
    </root>
  </xsl:template>
</xsl:stylesheet>