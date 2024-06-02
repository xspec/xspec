<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:call-template Coverage Test Case
  -->
  <xsl:template match="xsl-call-template">
    <root>
      <xsl:call-template name="calledTemplate" />
    </root>
  </xsl:template>
  <!-- Called template-->
  <xsl:template name="calledTemplate">
    <node type="call-template">100</node>
  </xsl:template>
</xsl:stylesheet>