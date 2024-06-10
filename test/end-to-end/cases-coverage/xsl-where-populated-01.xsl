<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:where-populated Test Case
  -->
  <xsl:template match="xsl-where-populated">
    <root>
      <!-- Data doesn't exist so node/copy-of not executed -->
      <node type="where-populated">
        <xsl:where-populated>
          <xsl:copy-of select="nonExistentNode" />      <!-- node element is empty but this element is executed because it needs to see if there is any output -->
        </xsl:where-populated>
      </node>
      <!-- Data exists so node/copy-of executed -->
      <node type="where-populated">
        <xsl:where-populated>
          <xsl:copy-of select="node" />
        </xsl:where-populated>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>