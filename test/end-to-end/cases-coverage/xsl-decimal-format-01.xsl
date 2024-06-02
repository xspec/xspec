<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:decimal-format Coverage Test Case
  -->
  <xsl:decimal-format name="decFormat01" digit="?" />
  <!-- Main template -->
  <xsl:template match="xsl-decimal-format">
    <root>
      <node type="decimal-format">
        <xsl:value-of select="format-number(100.00, '???0', 'decFormat01')" />
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>