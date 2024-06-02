<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:attribute Coverage Test Case
  -->
  <!-- Single xsl:attribute in xsl:attribute-set -->
  <xsl:attribute-set name="type">
    <xsl:attribute name="type">attribute</xsl:attribute>
  </xsl:attribute-set>

  <!-- Two xsl:attribute in xsl:attribute-set -->
  <xsl:attribute-set name="types">
    <xsl:attribute name="type1">
      <xsl:text>attribute1</xsl:text>
    </xsl:attribute>
    <xsl:attribute name="type2">
      <xsl:text>attribute2</xsl:text>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="xsl-attribute">
    <root>
      <!-- use-attribute-sets in xsl:element -->
      <xsl:element name="node" use-attribute-sets="type">
        <xsl:text>100</xsl:text>
      </xsl:element>
      <!-- Using select attribute -->
      <node>
        <xsl:attribute name="type" select="'attribute'" />
        <xsl:text>200</xsl:text>
      </node>
      <!-- Using select attribute -->
      <node>
        <xsl:attribute name="type" select="string('attribute')" />
        <xsl:text>300</xsl:text>
      </node>
      <!-- Using sequence constructor -->
      <node>
       <xsl:attribute name="type">attribute</xsl:attribute>
        <xsl:text>400</xsl:text>
      </node>
      <!-- Using sequence constructor -->
      <node>
        <xsl:attribute name="type">
          <xsl:text>attribute</xsl:text>
        </xsl:attribute>
        <xsl:text>500</xsl:text>
      </node>
      <!-- As a child of xsl:copy. Context node is the template match node xsl-attribute -->
      <xsl:copy>
        <xsl:attribute name="type">attribute</xsl:attribute>
        <xsl:text>600</xsl:text>
      </xsl:copy>
    </root>
  </xsl:template>
</xsl:stylesheet>