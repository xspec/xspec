<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:preserve-space Coverage Test Case
  -->
  <xsl:preserve-space elements="*" />

  <xsl:template match="xsl-preserve-space">
    <root>
      <node type="preserve-space">
        <xsl:text>100</xsl:text>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>