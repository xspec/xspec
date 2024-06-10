<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:apply-imports Coverage Test Case (see xsl-apply-imports-01A.xsl as well)
  -->
  <!-- Import stylesheet -->
  <xsl:import href="xsl-apply-imports-01A.xsl" />
  <!-- xsl:mode for this test -->
  <xsl:mode name="applyImportsMode" />
  <!-- Main Stylesheet-->
  <xsl:template match="xsl-apply-imports">
    <root>
      <xsl:apply-templates select="*" mode="applyImportsMode" />
    </root>
  </xsl:template>

  <!-- Current Stylesheet Template -->
  <xsl:template match="node" mode="applyImportsMode">
    <node type="apply-imports - top stylesheet">
      <xsl:value-of select="." />
    </node>
    <xsl:apply-imports/>
  </xsl:template>
</xsl:stylesheet>