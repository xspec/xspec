<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:value-of Coverage Test Case
  -->
  <xsl:template match="xsl-value-of">
    <root>
      <!-- Using select attribute -->
      <node type="value-of">
        <xsl:value-of select="string('100')" />
      </node>
      <!-- Using sequence constructor -->
      <node type="value-of">
        <xsl:value-of>
          <xsl:text>200</xsl:text>
        </xsl:value-of>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>