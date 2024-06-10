<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- Secondary template invoked for node -->
  <xsl:template match="node" mode="nextMatch" priority="2">
    <xsl:param name="param" select="200" />
    <node type="next-match">
      <xsl:value-of select="$param" />
    </node>
    <!-- Next match is built-in template -->
    <xsl:next-match />
  </xsl:template>
</xsl:stylesheet>