<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:key Coverage Test Case
  -->
  <!-- xsl:key declaration -->
  <xsl:key name="key01" match="node" use="@type" />
  <!-- Main template -->
  <xsl:template match="xsl-key">
    <root>
      <node type="key">
        <xsl:value-of select="key('key01', 'B')" />
      </node>
      <node type="key">
        <xsl:value-of select="key('key01', 'D')" />
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>