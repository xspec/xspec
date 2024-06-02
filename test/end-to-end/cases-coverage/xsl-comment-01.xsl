<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:comment Coverage Test Case
  -->
  <xsl:template match="xsl-comment">
    <root>
      <node type="comment">
        <xsl:comment> 100 </xsl:comment>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>