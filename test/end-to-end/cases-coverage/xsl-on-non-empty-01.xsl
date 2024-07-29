<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:on-non-empty Coverage Test Case
  -->
  <xsl:template match="xsl-on-non-empty">
    <root>
      <!-- Using select attribute -->
      <node type="on-non-empty">
        <xsl:text>1</xsl:text>
        <xsl:on-non-empty select="'00'" />
      </node>
      <!-- Using sequence constructor -->
      <node type="on-non-empty">
        <xsl:text>2</xsl:text>
        <xsl:on-non-empty>
          <xsl:text>00</xsl:text>
        </xsl:on-non-empty>
      </node>
      <!-- NOT on-non-empty --><!-- Need to check if comments below affect the outcome - trace does. See https://saxonica.plan.io/issues/6428 -->
      <node type="on-non-empty">
        <xsl:on-non-empty>                                                     <!-- Expected miss -->
          <xsl:text>300</xsl:text>                                             <!-- Expected miss -->
        </xsl:on-non-empty>                                                    <!-- Expected miss -->
      </node>
      <!-- NOT on-non-empty but static analysis cannot make that judgment --> 
      <node type="on-non-empty">
        <xsl:sequence select="@nonexistent-attribute" />                       <!-- Expected unknown -->
        <xsl:on-non-empty>                                                     <!-- Expected miss -->
          <xsl:text>400</xsl:text>                                             <!-- Expected miss -->
        </xsl:on-non-empty>                                                    <!-- Expected miss -->
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>