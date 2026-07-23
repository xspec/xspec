<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:document Coverage Test Case
  -->
  <xsl:template match="xsl-document">
    <root>
      <xsl:document>
        <node type="document">
          <xsl:text>100</xsl:text>
        </node>
      </xsl:document>
    </root>
  </xsl:template>
</xsl:stylesheet>