<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">

  <!-- xsl:apply-imports Template -->
  <xsl:template match="node" mode="applyImportsMode">
    <node type="apply-imports - import stylesheet">
      <xsl:value-of select="." />
    </node>
  </xsl:template>

  <!-- xsl:apply-imports Template with xsl:param -->
  <xsl:template match="node" mode="applyImportsWithParamMode">
    <xsl:param name="applyImportsParam01" />
    <node type="apply-imports - import stylesheet">
      <xsl:value-of select=". + number($applyImportsParam01)" />
    </node>
  </xsl:template>
</xsl:stylesheet>