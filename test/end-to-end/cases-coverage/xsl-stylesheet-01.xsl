<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:stylesheet Coverage Test Case
  -->
  <xsl:template match="xsl-stylesheet">
    <root>
      <node type="stylesheet">
        <xsl:text>100</xsl:text>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>