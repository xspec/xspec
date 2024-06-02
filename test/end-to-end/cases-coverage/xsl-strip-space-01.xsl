<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:strip-space Coverage Test Case
  -->
  <xsl:strip-space elements="*" />

  <xsl:template match="xsl-strip-space">
    <root>
      <node type="strip-space">
        <xsl:text>100</xsl:text>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>