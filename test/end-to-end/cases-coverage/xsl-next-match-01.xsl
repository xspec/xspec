<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:next-match Coverage Test Case - See imported template as well
  -->
  <!-- Import stylesheet with lower priority template -->
  <xsl:import href="xsl-next-match-01A.xsl" />
  <!-- Use a mode for matching -->
  <xsl:mode name="nextMatch" />
  <!-- Variable with the node to be processed -->
  <xsl:variable name="nextMatchNodes">
    <node>content for built-in template</node>
  </xsl:variable>
  <!-- Main template -->
  <xsl:template match="xsl-next-match">
    <root>
      <!-- Start processing node -->
      <xsl:apply-templates select="$nextMatchNodes" mode="nextMatch" />
    </root>
  </xsl:template>
  <!-- Initial template invoked for node -->
  <xsl:template match="node" mode="nextMatch" priority="1">
    <node type="next-match">
      <xsl:text>100</xsl:text>
    </node>
    <xsl:next-match />
    <xsl:next-match>
      <xsl:with-param name="param">300</xsl:with-param>
    </xsl:next-match>
   </xsl:template>
</xsl:stylesheet>