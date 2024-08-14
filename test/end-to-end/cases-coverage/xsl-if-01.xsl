<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:if - xsl:if is always executed
  -->
  <xsl:template match="xsl-if">
    <root>
      <!-- Test succeeds -->
      <xsl:if test="1 eq 1">
        <node type="if">100</node>
      </xsl:if>
      <!-- Test fails but xsl:if still executed and is a hit-->
      <xsl:if test="1 eq 2">
        <node type="if">200</node>                                             <!-- Expected miss -->
      </xsl:if>
      <!-- Text node children of xsl:if -->
      <node type="if">
        <xsl:if test="1 eq 1">300</xsl:if>                                     <!-- Expected unknown for 300 -->
        <xsl:if test="1 eq 2">400</xsl:if>                                     <!-- Expected unknown for 400 -->
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>