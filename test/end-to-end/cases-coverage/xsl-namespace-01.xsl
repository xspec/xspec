<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:namespace Coverage Test Case
  -->
  <xsl:template match="xsl-namespace">
    <root>
      <!-- Using select attribute -->
      <node type="namespace">
        <xsl:namespace name="dummy" select="'namespaceURI'" />
        <xsl:text>100</xsl:text>
      </node>
      <!-- Using sequence constructor -->
      <node type="namespace">
        <xsl:namespace name="dummy">
          <xsl:text>namespaceURI</xsl:text>
        </xsl:namespace>
        <xsl:text>200</xsl:text>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>