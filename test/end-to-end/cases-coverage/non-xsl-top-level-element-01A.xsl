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
  <xsl:template name="unhit-imported">                                         <!-- Expected miss -->
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
    <!-- Non-XSLT-top-level rule is higher priority than XSLT:sort/*/descendant::node() rule -->
    <xsl:for-each select="1 to 5">                                             <!-- Expected ignored -->
      <xsl:text>Ignored, not unknown</xsl:text>                                <!-- Expected ignored -->
      <xsl:sort>                                                               <!-- Expected ignored -->
        <xsl:choose>                                                           <!-- Expected ignored -->
          <xsl:when test="1 eq 2">                                             <!-- Expected ignored -->
            <xsl:value-of select="." />                                        <!-- Expected ignored -->
          </xsl:when>                                                          <!-- Expected ignored -->
          <xsl:otherwise>                                                      <!-- Expected ignored -->
            <xsl:value-of select="." />                                        <!-- Expected ignored -->
          </xsl:otherwise>                                                     <!-- Expected ignored -->
        </xsl:choose>                                                          <!-- Expected ignored -->
      </xsl:sort>                                                              <!-- Expected ignored -->
    </xsl:for-each>                                                            <!-- Expected ignored -->
    <!-- Non-XSLT-top-level rule is higher priority than XSLT:merge-key/descendant::node() rule -->
    <xsl:merge>                                                                <!-- Expected ignored -->
      <xsl:merge-source>                                                       <!-- Expected ignored -->
        <xsl:merge-key>                                                        <!-- Expected ignored -->
          <xsl:text>Ignored, not missed</xsl:text>                             <!-- Expected ignored -->
        </xsl:merge-key>                                                       <!-- Expected ignored -->
      </xsl:merge-source>                                                      <!-- Expected ignored -->
    </xsl:merge>                                                               <!-- Expected ignored -->
  </template>                                                                  <!-- Expected ignored -->

</xsl:transform>