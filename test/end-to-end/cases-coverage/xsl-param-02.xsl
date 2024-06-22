<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:myns="file://myNamespace">
  <!--
      xsl:param Coverage Test Case for child of xsl:template
  -->
  <xsl:template match="xsl-param">
    <root>
      <!-- Template param -->
      <xsl:call-template name="paramTemplate01">
        <xsl:with-param name="templateParam01">500</xsl:with-param>
      </xsl:call-template>
      <!-- Template param -->
      <xsl:call-template name="paramTemplate02">
        <xsl:with-param name="templateParam02">600</xsl:with-param>
      </xsl:call-template>
      <!-- Template param -->
      <xsl:call-template name="paramTemplate03">
        <xsl:with-param name="templateParam03">700</xsl:with-param>
      </xsl:call-template>
      <!-- Template param -->
      <xsl:call-template name="paramTemplate04">
        <xsl:with-param name="templateParam04">800</xsl:with-param>
      </xsl:call-template>
      <!-- Call Template using default xsl:param values -->
      <xsl:call-template name="paramTemplate05" />
      <xsl:call-template name="paramTemplate06" />
      <xsl:call-template name="paramTemplate07" />
      <xsl:call-template name="paramTemplate08" />
    </root>
  </xsl:template>
  <!-- Templates where xsl:param value is provided by caller -->
  <!-- Template param with no default - value provided by caller -->
  <xsl:template name="paramTemplate01">
    <xsl:param name="templateParam01" />
    <node type="param - template">
      <xsl:value-of select="$templateParam01" />
    </node>
  </xsl:template>
  <!-- Template param with select attribute - value provided by caller -->
  <xsl:template name="paramTemplate02">
    <xsl:param name="templateParam02" select="999" />
    <node type="param - template">
      <xsl:value-of select="$templateParam02" />
    </node>
  </xsl:template>
  <!-- Template param with inline sequence constructor - value provided by caller -->
  <xsl:template name="paramTemplate03">
    <xsl:param name="templateParam03">999</xsl:param>                          <!-- Expected miss for 999 -->
    <node type="param - template">
      <xsl:value-of select="$templateParam03" />
    </node>
  </xsl:template>
  <!-- Template param with multi-line sequence constructor - value provided by caller -->
  <xsl:template name="paramTemplate04">
    <xsl:param name="templateParam04">
      <xsl:text>9</xsl:text>                                                   <!-- Expected miss -->
      <xsl:text>9</xsl:text>                                                   <!-- Expected miss -->
      <xsl:text>9</xsl:text>                                                   <!-- Expected miss -->
    </xsl:param>
    <node type="param - template">
      <xsl:value-of select="$templateParam04" />
    </node>
  </xsl:template>
  <!-- Templates where xsl:param default value is used -->
  <!-- Template param with no default - no value provided by caller, relying on default value -->
  <xsl:template name="paramTemplate05">
    <xsl:param name="templateParam05" />
    <node type="param - template">
      <xsl:value-of select="$templateParam05" />
    </node>
  </xsl:template>
  <!-- Template param with select attribute - no value provided by caller, relying on default value -->
  <xsl:template name="paramTemplate06">
    <xsl:param name="templateParam06" select="900" />
    <node type="param - template">
      <xsl:value-of select="$templateParam06" />
    </node>
  </xsl:template>
  <!-- Template param with inline sequence constructor - no value provided by caller, relying on default value -->
  <xsl:template name="paramTemplate07">
    <xsl:param name="templateParam07">1000</xsl:param>
    
    <node type="param - template">
      <xsl:value-of select="$templateParam07" />
    </node>
  </xsl:template>
  <!-- Template param with multi-line sequence constructor - no value provided by caller, relying on default value -->
  <xsl:template name="paramTemplate08">
    <xsl:param name="templateParam08">
      <xsl:text>1</xsl:text>
      <xsl:text>1</xsl:text>
      <xsl:text>0</xsl:text>
      <xsl:text>0</xsl:text>
    </xsl:param>
    <node type="param - template">
      <xsl:value-of select="$templateParam08" />
    </node>
  </xsl:template>
</xsl:stylesheet>