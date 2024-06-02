<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!-- Secondary template invoked for node -->
  <xsl:template match="node" mode="nextMatch" priority="2">
    <node type="next-match">
      <xsl:text>200</xsl:text>
    </node>
  </xsl:template>
</xsl:stylesheet>