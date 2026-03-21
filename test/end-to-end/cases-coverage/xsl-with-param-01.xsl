<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:with-param Coverage Test Case (Quite complex because it covers xsl:iterate, xsl:call-template, xsl:apply-templates, xsl:apply-import, xsl:next-match and xsl:evaluate)
  -->
  <xsl:import href="xsl-with-param-01A.xsl" />                                 <!-- Expected ignored -->
  <!-- xsl:mode for apply-templates -->
  <xsl:mode name="withParamMode" />                                            <!-- Expected ignored -->
  <!-- xsl:mode for apply-imports -->
  <xsl:mode name="withParamModeAI" />                                          <!-- Expected ignored -->
  <!-- xsl:mode for next-match -->
  <xsl:mode name="withParamModeNM" />                                          <!-- Expected ignored -->

  <xsl:template match="xsl-with-param">
    <root>
      <!-- Numbers in brackets refer to the value in the node output -->
      <!--Iterate with-param (100, 200, 300, 400) -->
      <xsl:iterate select="node">
        <xsl:param name="iterateParam01" select="100" />
        <node type="with-param - iterate">
          <xsl:value-of select="$iterateParam01" />
        </node>
        <xsl:next-iteration>
          <xsl:with-param name="iterateParam01" select="$iterateParam01 + 100" />
        </xsl:next-iteration>
      </xsl:iterate>
      <!-- Call Template with-param (500) -->
      <xsl:call-template name="withParamTemplate01">
        <xsl:with-param name="withParam-CT-Param01">500</xsl:with-param>
      </xsl:call-template>
      <!-- Apply Templates with-param (600, 700, 800, 900) -->
      <xsl:apply-templates mode="withParamMode">
        <xsl:with-param name="withParam-AT-Param01">500</xsl:with-param>
      </xsl:apply-templates>
      <!-- Apply Imports with-param (1000, 1050, 1100, 1150, 1200, 1250, 1300, 1350) -->
      <xsl:apply-templates select="*" mode="withParamModeAI">
        <xsl:with-param name="withParam-AI-Param01">900</xsl:with-param>
      </xsl:apply-templates>
      <!-- Next Match with-param (1400, 1450, 1500, 1550, 1600, 1650, 1700, 1750) -->
      <xsl:apply-templates select="*" mode="withParamModeNM">
        <xsl:with-param name="withParam-NM-Param01">1300</xsl:with-param>
      </xsl:apply-templates>
      <!-- Evaluate with-param (200) -->
      <xsl:variable name="index" select="2" />                                 <!-- Expected miss (optim constant) -->
      <xsl:variable name="evaluatedExpressionParamChild">
        <xsl:evaluate xpath="'string(node[$index])'" context-item=".">
          <xsl:with-param name="index" select="$index" />
          <xsl:with-param name="nonexistent">unused parameter</xsl:with-param>
        </xsl:evaluate>
      </xsl:variable>
      <node type="with-param - evaluate">
        <xsl:value-of select="$evaluatedExpressionParamChild" />
      </node>
      <!-- Constructs in which parent of xsl:with-param is not hit -->
      <xsl:if test="exists(parent-of-with-param-not-hit)">
        <xsl:call-template name="withParamTemplate01">                         <!-- Expected miss -->
          <xsl:with-param name="withParam-CT-Param01">500</xsl:with-param>     <!-- Expected miss -->
        </xsl:call-template>                                                   <!-- Expected miss -->
        <xsl:apply-templates mode="withParamMode">                             <!-- Expected miss -->
          <xsl:with-param name="withParam-AT-Param01">500</xsl:with-param>     <!-- Expected miss -->
        </xsl:apply-templates>                                                 <!-- Expected miss -->
        <xsl:apply-templates select="*" mode="withParamModeAI">                <!-- Expected miss -->
          <xsl:with-param name="withParam-AI-Param01">900</xsl:with-param>     <!-- Expected miss -->
        </xsl:apply-templates>                                                 <!-- Expected miss -->
        <xsl:next-match>                                                       <!-- Expected miss -->
          <xsl:with-param name="withParam-NM-Param01" select="0" />            <!-- Expected miss -->
        </xsl:next-match>                                                      <!-- Expected miss -->
        <xsl:variable name="evaluatedExpressionParamChild">                    <!-- Expected miss -->
          <xsl:evaluate xpath="'string(node[$index])'" context-item=".">       <!-- Expected miss -->
            <xsl:with-param name="index" select="$index" />                    <!-- Expected miss -->
          </xsl:evaluate>                                                      <!-- Expected miss -->
        </xsl:variable>                                                        <!-- Expected miss -->
        <xsl:value-of select="$evaluatedExpressionParamChild" />               <!-- Expected miss -->
      </xsl:if>
    </root>
  </xsl:template>
  <!-- Call Template -->
  <xsl:template name="withParamTemplate01">
    <xsl:param name="withParam-CT-Param01" />
    <node type="with-param - call-template">
      <xsl:value-of select="$withParam-CT-Param01" />
    </node>
  </xsl:template>
  <!-- Apply Templates Template -->
  <xsl:template match="node" mode="withParamMode">
    <xsl:param name="withParam-AT-Param01" />
    <node type="with-param - apply-templates">
      <xsl:value-of select="$withParam-AT-Param01 + ." />
    </node>
  </xsl:template>
  <!-- Apply Imports Template -->
  <xsl:template match="node" mode="withParamModeAI">
    <xsl:param name="withParam-AI-Param01" />
    <node type="with-param - apply-imports part 1">
      <xsl:value-of select="$withParam-AI-Param01 + ." />
    </node>
    <xsl:apply-imports>
      <xsl:with-param name="withParam-AI-Param01" select="$withParam-AI-Param01" />
    </xsl:apply-imports>
  </xsl:template>
  <!-- Next Match Template -->
  <xsl:template match="node" mode="withParamModeNM" priority="1">
    <xsl:param name="withParam-NM-Param01" />
    <node type="with-param - next-match part 1">
      <xsl:value-of select="$withParam-NM-Param01 + ." />
    </node>
    <xsl:next-match>
      <xsl:with-param name="withParam-NM-Param01" select="$withParam-NM-Param01" />
    </xsl:next-match>
  </xsl:template>
</xsl:stylesheet>