<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- xsl:apply-imports Template -->
  <xsl:template match="node" mode="withParamModeAI" >
    <xsl:param name="withParam-AI-Param01" />
    <node type="with-param - apply-imports part 2">
      <xsl:value-of select="$withParam-AI-Param01 + . + 50" />
    </node>
  </xsl:template>

  <!-- Secondary template invoked for node -->
  <xsl:template match="node" mode="withParamModeNM" priority="2">
    <xsl:param name="withParam-NM-Param01" />
    <node type="with-param - next-match part 2">
      <xsl:value-of select="$withParam-NM-Param01 + . + 50" />
    </node>
  </xsl:template>
</xsl:stylesheet>