<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:attribute-set Coverage Test Case
  -->
  <!-- Single attribute -->
  <xsl:attribute-set name="attrSet01">
    <xsl:attribute name="attr01">attr01</xsl:attribute>
  </xsl:attribute-set>
  <!-- Multiple attributes-->
  <xsl:attribute-set name="attrSet02">
    <xsl:attribute name="attr02A">attr02A</xsl:attribute>
    <xsl:attribute name="attr02B">attr02B</xsl:attribute>
  </xsl:attribute-set>
  <!-- Including another attribute set -->
  <xsl:attribute-set name="attrSet03A" use-attribute-sets="attrSet03B">
    <xsl:attribute name="attr03A">attr03A</xsl:attribute>
  </xsl:attribute-set>
  <xsl:attribute-set name="attrSet03B">
    <xsl:attribute name="attr03B">attr03B</xsl:attribute>
  </xsl:attribute-set>
  <!-- Main template -->
  <xsl:template match="xsl-attribute-set">
    <root>
      <!-- use-attribute-sets in xsl:element -->
      <xsl:element name="node" use-attribute-sets="attrSet01">
        <xsl:attribute name="type">attribute-set</xsl:attribute>
        <xsl:text>100</xsl:text>
      </xsl:element>
      <!-- use-attribute-sets in literal result element -->
      <node xsl:use-attribute-sets="attrSet02" type="attribute-set">
        <xsl:text>100</xsl:text>
      </node>
      <!-- use-attribute-sets in literal result element -->
      <node xsl:use-attribute-sets="attrSet03A" type="attribute-set">
        <xsl:text>100</xsl:text>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>