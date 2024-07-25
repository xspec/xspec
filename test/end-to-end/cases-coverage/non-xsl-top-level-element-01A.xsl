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

  <doc:template name="non-xsl-top-level-element" xmlns:doc="NotXSLTNamespace"> <!-- Expected ignored -->
    <xsl:text>Ignored</xsl:text>                                               <!-- Expected ignored -->
    <doc:para>Top-level element is not in namespace
      <doc:uri>http://www.w3.org/1999/XSL/Transform</doc:uri></doc:para>       <!-- Expected ignored -->
  </doc:template>                                                              <!-- Expected ignored -->

  <xsl:template name="non-xsl-top-level-element" xmlns:xsl="NotXSLTNamespace"> <!-- Expected ignored -->
    <xsl:text
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform">Ignored</xsl:text>      <!-- Expected ignored -->
    <xsl:para>Top-level element is not in namespace
      <xsl:uri>http://www.w3.org/1999/XSL/Transform</xsl:uri></xsl:para>       <!-- Expected ignored -->
  </xsl:template>                                                              <!-- Expected ignored -->

  <template name="non-xsl-top-level-element" xmlns="NotXSLTNamespace">         <!-- Expected ignored -->
    <xsl:text>Ignored</xsl:text>                                               <!-- Expected ignored -->
    <para>Top-level element is not in namespace
      <uri>http://www.w3.org/1999/XSL/Transform</uri></para>                   <!-- Expected ignored -->
    <!-- Non-XSLT-top-level rule is higher priority than xsl:assert rule -->
    <xsl:assert test="false()">                                                <!-- Expected ignored -->
      <xsl:text>Ignored, not unknown</xsl:text>                                <!-- Expected ignored -->
    </xsl:assert>                                                              <!-- Expected ignored -->
  </template>                                                                  <!-- Expected ignored -->

</xsl:transform>