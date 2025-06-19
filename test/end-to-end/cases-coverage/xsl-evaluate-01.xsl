<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
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
            <!-- As a child of xsl:sort, this xsl:evaluate element follows Use Parent Status rule. -->
            <xsl:evaluate xpath="$sortKey" context-item="."  />
          </xsl:sort>
          <node type="evaluate inside sort">
            <xsl:value-of select="@value" />
          </node>
        </xsl:for-each>
        <xsl:for-each select="$data/data">
          <node type="evaluate">
            <xsl:value-of>
              <xsl:evaluate xpath="$sortKey" context-item="."  />
            </xsl:value-of>
          </node>
        </xsl:for-each>

        <!-- Circuitous ways to get $data/data[2] content -->
        <xsl:variable name="index" select="2" />                               <!-- Expected miss (optim constant) -->
        <xsl:variable name="evaluatedExpressionParamChild">
          <!-- xsl:for-each, a descendant of xsl:evaluate and xsl:with-param, is traced -->
          <xsl:evaluate xpath="'string(data[xs:integer($index)])'" context-item="$data">
            <xsl:with-param name="index">
              <xsl:for-each select="1">
                <xsl:sequence select="$index"/>                                <!-- Expected unknown -->
              </xsl:for-each>
            </xsl:with-param>
            <xsl:with-param name="sortKey">parameter not used in evaluation</xsl:with-param>
          </xsl:evaluate>
        </xsl:variable>
        <node type="evaluate/with-param executed hit">
          <xsl:value-of select="$evaluatedExpressionParamChild" />
        </node>

        <xsl:variable name="evaluatedExpressionParamAttr">
          <xsl:evaluate xpath="'string(data[$index])'" context-item="$data"
            with-params="map{QName('','index'): $index }" />
        </xsl:variable>
        <xsl:if test="exists(nonexistent)">
          <xsl:evaluate xpath="'string(data[$index])'" context-item="$data"
            with-params="map{QName('','index'): $index }" />                   <!-- Expected miss -->
        </xsl:if>
        <node type="evaluate/with-param executed unknown">
          <xsl:value-of select="$evaluatedExpressionParamAttr" />
        </node>
        <node type="evaluate/with-param unexecuted unknown">
          <xsl:text>500</xsl:text>
        </node>
      </root>
   </xsl:template>
</xsl:stylesheet>
