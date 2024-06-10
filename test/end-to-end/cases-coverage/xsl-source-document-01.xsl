<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:source-document Coverage Test Case (requires xsl-data-01.xml input file)
  -->
  <xsl:template match="xsl-source-document">
    <root>
      <xsl:source-document href="xsl-data-01.xml">
        <node type="source-document">
          <xsl:value-of select="root/node[1]" />
        </node>
        <node type="source-document">
          <xsl:value-of select="root/node[2]" />
        </node>
      </xsl:source-document>
    </root>
  </xsl:template>
</xsl:stylesheet>