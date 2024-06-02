<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:message Coverage Test Case
  -->
  <xsl:template match="xsl-message">
    <root>
      <!-- Using select attribute -->
      <node type="message">
        <xsl:text>100</xsl:text>
        <xsl:message select="string('Message: 100')" />
      </node>
      <!-- Add content -->
      <node type="message">
        <xsl:text>200</xsl:text>
        <xsl:message>
          <xsl:text>Message: 200</xsl:text>
        </xsl:message>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>