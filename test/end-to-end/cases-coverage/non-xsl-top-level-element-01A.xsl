<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      Coverage Test Case for non-XSLT child of xsl:transform
  -->
  <xsl:template match="non-xsl-top-level-element">
    <xsl:copy>
      <xsl:text>Child of xsl:transform</xsl:text>
    </xsl:copy>
  </xsl:template>

  <!-- The non-XSLT element in the template should be missed, not ignored. -->
  <xsl:template name="unhit">                                                  <!-- Expected miss -->
    <non-xsl-element/>                                                         <!-- Expected miss -->
  </xsl:template>                                                              <!-- Expected miss -->

  <doc:template name="non-xsl-top-level-element" xmlns:doc="NotTheXSLTNamespace">
    <xsl:text>Ignored</xsl:text>
    <doc:para>Top-level element is not in <doc:uri>http://www.w3.org/1999/XSL/Transform</doc:uri> namespace</doc:para>
  </doc:template>
  
  <xsl:template name="non-xsl-top-level-element" xmlns:xsl="NotTheXSLTNamespace">
    <xsl:text xmlns:xsl="http://www.w3.org/1999/XSL/Transform">Ignored</xsl:text>
    <xsl:para>Top-level element is not in <xsl:uri>http://www.w3.org/1999/XSL/Transform</xsl:uri> namespace</xsl:para>
  </xsl:template>
  
  <template name="non-xsl-top-level-element" xmlns="NotTheXSLTNamespace">
    <xsl:text>Ignored</xsl:text>
    <para>Top-level element is not in <uri>http://www.w3.org/1999/XSL/Transform</uri> namespace</para>
  </template>

</xsl:transform>