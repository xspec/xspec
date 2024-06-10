<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:copy Coverage Test Case
  -->
  <xsl:template match="xsl-copy">
    <root>
      <!-- Using select attribute -->
      <node type="copy">
        <xsl:copy select="node[2]/text()" />
      </node>
      <!-- Using sequence constructor -->
      <node type="copy">
        <xsl:copy>
          <xsl:value-of select="node[3]/text()" /><!-- Copies the context node which is xsl-copy -->
        </xsl:copy>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>