<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:evaluate Coverage Test Case
  -->
  <!-- Data for the test -->
  <xsl:variable name="data">
    <data value="400">400</data>
    <data value="100">100</data>
    <data value="300">300</data>
    <data value="200">200</data>
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

        <!-- Circuitous ways to get $data/data[2] content -->
        <xsl:variable name="index" select="2" />
        <xsl:variable name="evaluatedExpressionParamChild">
          <xsl:evaluate xpath="'string(data[$index])'" context-item="$data">
            <xsl:with-param name="index" select="$index" />
            <xsl:with-param name="sortKey">parameter not used in evaluation</xsl:with-param>
          </xsl:evaluate>
        </xsl:variable>
        <node type="evaluate/with-param">
          <xsl:value-of select="$evaluatedExpressionParamChild" />
        </node>

        <xsl:variable name="evaluatedExpressionParamAttr">
          <xsl:evaluate xpath="'string(data[$index])'" context-item="$data"
            with-params="map{QName('','index'): $index }" />
        </xsl:variable>
        <node type="evaluate/with-param">
          <xsl:value-of select="$evaluatedExpressionParamAttr" />
        </node>
      </root>
   </xsl:template>
</xsl:stylesheet>
