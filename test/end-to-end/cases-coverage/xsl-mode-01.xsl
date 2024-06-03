<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:mode Coverage Test Case
  -->
  <xsl:mode name="modeUsed" />
  <xsl:mode on-multiple-match="fail" />
  <!-- Mode not used -->
  <xsl:mode name="modeNotUsed" />

  <xsl:template match="xsl-mode">
      <root>
        <!-- Apply template using mode - xspec context has a node element -->
        <xsl:apply-templates mode="modeUsed" />
      </root>
  </xsl:template>

  <xsl:template match="node" mode="modeUsed">
    <node type="mode">
      <xsl:text>100</xsl:text>
    </node>
  </xsl:template>
</xsl:stylesheet>