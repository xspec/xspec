<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:result-document Coverage Test Case
  -->
  <xsl:template match="xsl-result-document">
    <root>
      <node type="result-document">
        <xsl:text>100</xsl:text>
      </node>
    </root>
    <xsl:result-document href="result-document.xml">
      <node type="result-document">
        <xsl:text>200</xsl:text>
      </node>
    </xsl:result-document>
  </xsl:template>
</xsl:stylesheet>