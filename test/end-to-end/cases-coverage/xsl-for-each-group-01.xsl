<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:for-each-group - just a single example using group-by.
  -->
  <xsl:template match="xsl-for-each-group">
    <root>
      <!-- Returns remainder after division by 3. Groups contain 0, 1 and 2 -->
      <xsl:for-each-group select="9 to 20" group-by="(. mod 3)">
        <node type="for-each-group">
          <xsl:value-of select="current-grouping-key()" />
        </node>
      </xsl:for-each-group>
      <!-- Child of xsl:for-each-group is not traced -->
      <xsl:variable name="my-map" as="map(*)">                                 <!-- Expected miss (optim inlined) -->
        <xsl:for-each-group select="1" group-by="1">
          <xsl:map-entry key="current-grouping-key()" select="'100'"/>         <!-- Expected unknown -->
        </xsl:for-each-group>
      </xsl:variable>                                                          <!-- Expected miss (optim inlined) -->
      <node type="for-each-group - untraced child">
        <xsl:value-of select="$my-map(1)"/>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>