<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:apply-templates Coverage Test Case
  -->
  <xsl:template match="xsl-apply-templates">
    <root>
      <xsl:apply-templates />
      <xsl:apply-templates mode="#unnamed" />
      <xsl:apply-templates mode="#current" />
      <xsl:apply-templates mode="#default" />
      <xsl:apply-templates mode="mode-with-matching-template" />
      <xsl:apply-templates mode="mode-without-explicit-template-with-xsl-mode" />
      <xsl:apply-templates mode="mode-without-explicit-template-without-xsl-mode" />
    </root>
  </xsl:template>

  <xsl:template match="applyTemplateNode">
    <node type="apply-templates">
      <xsl:value-of select="." />
    </node>
  </xsl:template>

  <xsl:mode name="mode-without-explicit-template-with-xsl-mode" on-no-match="shallow-copy" />

  <xsl:template match="applyTemplateNode" mode="mode-with-matching-template">
    <node type="apply-templates-mode-with-matching-template">
      <xsl:value-of select="." />
    </node>
  </xsl:template>
</xsl:stylesheet>