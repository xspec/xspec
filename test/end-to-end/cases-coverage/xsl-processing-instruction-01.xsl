<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:processing-instruction Coverage Test Case
  -->
  <xsl:template match="xsl-processing-instruction">
    <!-- Using select attribute -->
    <xsl:processing-instruction name="processing-instruction" select="'TestCase1'" />
    <!-- Using sequence constructor -->
    <xsl:processing-instruction name="processing-instruction">
      <xsl:text>TestCase2="yes"</xsl:text>
    </xsl:processing-instruction>
    <root>
      <!-- No content -->
    </root>
  </xsl:template>
</xsl:stylesheet>