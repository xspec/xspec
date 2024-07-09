<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:element Coverage Test Case
  -->
  <xsl:template match="xsl-element">
    <root>
      <!-- Element name as string value inline -->
      <!-- Compile time expression -->
      <!-- Saxon class is net.sf.saxon.expr.instruct.FixedElement -->
      <xsl:element name="node">
        <xsl:attribute name="type">element</xsl:attribute>
        <xsl:text>100</xsl:text>
      </xsl:element>
      <!-- Element name as simple ATV (attribute value template) -->
      <!-- Compile time expression -->
      <!-- Saxon class is net.sf.saxon.expr.instruct.FixedElement -->
      <xsl:element name="{'node'}">
        <xsl:attribute name="type">element</xsl:attribute>
        <xsl:text>200</xsl:text>
      </xsl:element>
      <!-- Element name as function in ATV (attribute value template) -->
      <!-- Run-time expression -->
      <!-- Saxon class is net.sf.saxon.expr.instruct.ComputedElement -->
      <xsl:element name="{string-join(('n','o','d','e'))}">
        <xsl:attribute name="type">element</xsl:attribute>
        <xsl:text>300</xsl:text>
      </xsl:element>
    </root>
  </xsl:template>
</xsl:stylesheet>