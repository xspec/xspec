<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:sequence Coverage Test Case
  -->
  <xsl:template match="xsl-sequence">
    <root>
      <!-- Using select attribute -->
      <node type="sequence">
        <xsl:sequence select="'100'" />
      </node>
      <!-- Using sequence constructor -->
      <node type="sequence">
        <xsl:sequence>
          <xsl:text>200</xsl:text>
        </xsl:sequence>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>