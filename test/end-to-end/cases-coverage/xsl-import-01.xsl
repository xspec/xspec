<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:import Coverage Test Case (See imported stylesheet)
  -->
  <xsl:import href="xsl-import-01A.xsl" />
  <xsl:template match="xsl-import">
    <root>
      <!-- Call template in imported stylesheet -->
      <xsl:call-template name="importTemplate01" />
    </root>
  </xsl:template>
</xsl:stylesheet>