<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:for-each-group - just a singe example using group-by.
  -->
  <xsl:template match="xsl-for-each-group">
    <root>
      <!-- Returns remainder after division by 3. Groups contain 0, 1 and 2 -->
      <xsl:for-each-group select="9 to 20" group-by="(. mod 3)">
        <node type="for-each-group">
          <xsl:value-of select="current-grouping-key()" />
        </node>
      </xsl:for-each-group>
    </root>
  </xsl:template>
</xsl:stylesheet>