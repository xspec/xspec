<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:output Coverage Test Case
  -->
  <xsl:output method="xml" />

  <xsl:template match="xsl-output">
    <root>
      <node type="output">
        <xsl:text>100</xsl:text>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>