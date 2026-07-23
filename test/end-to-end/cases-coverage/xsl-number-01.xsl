<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:number Coverage Test Case
  -->
  <xsl:template match="xsl-number">
    <root>
      <node type="number">
        <xsl:number />
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>