<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:evaluate Coverage Test Case - need a test case using with-param
  -->
  <!-- Data for the test -->
  <xsl:variable name="data">
    <data value="400">400</data>
    <data value="100">100</data>
    <data value="300">300</data>
    <data value="200">300</data>
  </xsl:variable>
  <!-- Sort key -->
  <xsl:variable name="sortKey">@value</xsl:variable>

   <xsl:template match="xsl-evaluate">
      <root>
        <xsl:for-each select="$data/data">
          <xsl:sort>
            <xsl:evaluate xpath="$sortKey" context-item="."  />
          </xsl:sort>
          <node type="evaluate">
            <xsl:value-of select="@value" />
          </node>
        </xsl:for-each>
        <!--xsl:variable name="evaluateExpression">
            <xsl:evaluate xpath="substring('hello', 1, 4)" />
        </xsl:variable>
          <node type="evaluate">
            <xsl:value-of select="$evaluateExpression" />
          </node-->
      </root>
   </xsl:template>
</xsl:stylesheet>
