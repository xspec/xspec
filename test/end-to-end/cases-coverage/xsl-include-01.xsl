<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:include Coverage Test Case
  -->
  <!-- xsl:include -->
  <xsl:include href="xsl-include-01A.xsl" />
  <xsl:include href="xsl-include-01B.xsl" />
  <!-- Main template -->
  <xsl:template match="xsl-include">
    <root>
      <xsl:call-template name="includeTemplate01" />
    </root>
  </xsl:template>
</xsl:stylesheet>