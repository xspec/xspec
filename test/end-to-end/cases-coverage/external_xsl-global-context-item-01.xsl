<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:global-context-item Coverage Test Case
  -->
  <xsl:global-context-item use="optional" as="item()" />
  <!-- Put the context item in a global variable -->
  <xsl:variable name="globalVariable" select="$globalContextItem" />

  <xsl:template match="xsl-global-context-item">
    <root>
      <node type="global-context-item">
        <xsl:value-of select="$globalVariable" />
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>