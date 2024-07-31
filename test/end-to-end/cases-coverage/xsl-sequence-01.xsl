<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:sequence Coverage Test Case
  -->
  <xsl:template match="xsl-sequence">
    <root>
      <!-- Using select attribute -->
      <node type="sequence">
        <xsl:sequence select="'100'" />                                        <!-- Expected unknown -->
      </node>
      <!-- Using sequence constructor -->
      <node type="sequence">
        <xsl:sequence>
          <xsl:text>200</xsl:text>
        </xsl:sequence>
      </node>
      <!-- Untraceable descendant -->
      <node type="sequence">
        <xsl:sequence>
          <xsl:fallback/>                                                      <!-- Expected unknown -->
          <xsl:text>300</xsl:text>
        </xsl:sequence>
      </node>
      <!-- Repeat the patterns above, in a missed code block -->
      <xsl:if test="exists(nonexistent)">
        <xsl:sequence select="'100'" />                                        <!-- Expected unknown -->
        <xsl:sequence>                                                         <!-- Expected miss -->
          <xsl:text>200</xsl:text>                                             <!-- Expected miss -->
        </xsl:sequence>                                                        <!-- Expected miss -->
        <xsl:sequence>                                                         <!-- Expected unknown -->
          <xsl:fallback/>                                                      <!-- Expected unknown -->
          <xsl:text>300</xsl:text>                                             <!-- Expected miss -->
        </xsl:sequence>                                                        <!-- Expected unknown -->
      </xsl:if>
    </root>
  </xsl:template>
</xsl:stylesheet>