<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:on-empty Coverage Test Case
  -->
  <xsl:template match="xsl-on-empty">
    <root>
      <!-- Using select attribute -->
      <node type="on-empty">
        <xsl:on-empty select="200 idiv 2" />
      </node>
      <!-- Using sequence constructor -->
      <node type="on-empty">
        <xsl:on-empty>
          <xsl:text>200</xsl:text>
        </xsl:on-empty>
      </node>
      <!-- NOT on-empty-->
      <node type="on-empty">
        <xsl:text>300</xsl:text>
        <xsl:on-empty>                                                         <!-- Expected miss -->
          <xsl:text>300</xsl:text>                                             <!-- Expected miss -->
        </xsl:on-empty>                                                        <!-- Expected miss -->
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>