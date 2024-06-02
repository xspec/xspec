<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:apply-templates Coverage Test Case
  -->
  <xsl:template match="xsl-apply-templates">
    <root>
      <xsl:apply-templates />
    </root>
  </xsl:template>

  <xsl:template match="applyTemplateNode">
    <node type="apply-templates">
      <xsl:value-of select="." />
    </node>
  </xsl:template>
</xsl:stylesheet>