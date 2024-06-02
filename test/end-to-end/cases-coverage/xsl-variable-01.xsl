<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:variable Coverage Test Case
  -->
  <!-- Global variable -->
  <xsl:variable name="variableGlobal01" select="string(100)" />
  <xsl:variable name="variableGlobal02">
    <xsl:text>200</xsl:text>
  </xsl:variable>
  <!-- Not used -->
  <xsl:variable name="variableGlobal03">300</xsl:variable>                     <!-- Expected miss -->

  <xsl:template match="xsl-variable">
    <xsl:variable name="variableLocal01" select="string(400)" />
    <xsl:variable name="variableLocal02">
      <xsl:text>500</xsl:text>
    </xsl:variable>
    <!-- Not used -->
    <xsl:variable name="variableLocal03">600</xsl:variable>                    <!-- Expected miss -->
    <!-- Not used -->
    <xsl:variable name="variableLocal04">                                      <!-- Expected miss -->
      <xsl:text>700</xsl:text>                                                 <!-- Expected miss -->
    </xsl:variable>                                                            <!-- Expected miss -->
    <root>
      <!-- Global variable used -->
      <node type="variable - global">
        <xsl:value-of select="$variableGlobal01" />
      </node>
      <!-- Global variable used -->
      <node type="variable - global">
        <xsl:value-of select="$variableGlobal02" />
      </node>
      <!-- Local variable used -->
      <node type="variable - local">
        <xsl:value-of select="$variableLocal01" />
      </node>
      <!-- Local variable used -->
      <node type="variable - local">
        <xsl:value-of select="$variableLocal02" />
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>