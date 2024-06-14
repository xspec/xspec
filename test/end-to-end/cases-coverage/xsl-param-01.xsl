<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:myns="file://myNamespace">
  <!--
      xsl:param Coverage Test Case
  -->
  <!-- Global param overridden in XSpec -->
  <xsl:param name="globalParam01">0</xsl:param>                                <!-- Expected miss -->
  <!-- Global param not overridden in XSpec - no default -->
  <xsl:param name="globalParam02" />
  <!-- Global param not overridden in XSpec - with select attribute -->
  <xsl:param name="globalParam03" select="200" />
  <!-- Global param not overridden in XSpec - with inline sequence constructor -->
  <xsl:param name="globalParam04">300</xsl:param>
  <!-- Global param not overridden in XSpec - with multiline sequence constructor-->
  <xsl:param name="globalParam05">
    <xsl:text>4</xsl:text>
    <xsl:text>0</xsl:text>
    <xsl:text>0</xsl:text>
  </xsl:param>
  <!-- Global param not overridden in XSpec - with multiline sequence constructor - not used -->
  <xsl:param name="globalParam06">                                             <!-- Expected miss -->
    <xsl:text>4</xsl:text>                                                     <!-- Expected miss -->
    <xsl:text>0</xsl:text>                                                     <!-- Expected miss -->
    <xsl:text>0</xsl:text>                                                     <!-- Expected miss -->
  </xsl:param>                                                                 <!-- Expected miss -->

  <xsl:template match="xsl-param">
    <root>
      <!-- Global param -->
      <node type="param - global">
        <xsl:value-of select="$globalParam01" />
      </node>
      <node type="param - global">
        <xsl:value-of select="$globalParam02" />
      </node>
      <node type="param - global">
        <xsl:value-of select="$globalParam03" />
      </node>
      <node type="param - global">
        <xsl:value-of select="$globalParam04" />
      </node>
      <node type="param - global">
        <xsl:value-of select="$globalParam05" />
      </node>
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
      <!-- Function param -->
      <node type="param - function">
        <xsl:value-of select="myns:paramFunction01('1200')" />
      </node>
      <!--Iterate param with select attribute -->
      <xsl:iterate select="node">
        <xsl:param name="iterateParam01" select="13" />
        <node type="param - iterate">
          <xsl:value-of select="$iterateParam01 * 100" />
        </node>
      </xsl:iterate>
      <!--Iterate param with inline sequence constructor -->
      <xsl:iterate select="node">
        <xsl:param name="iterateParam01">14</xsl:param>
        <node type="param - iterate">
          <xsl:value-of select="$iterateParam01 * 100" />
        </node>
      </xsl:iterate>
      <!--Iterate param with multiline sequence constructor -->
      <xsl:iterate select="node">
        <xsl:param name="iterateParam01">
          <xsl:text>1</xsl:text>
          <xsl:choose>
            <xsl:when test="1 eq 1">
              <xsl:text>5</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>99</xsl:text>                                          <!-- Expected miss -->
            </xsl:otherwise>
          </xsl:choose>
        </xsl:param>
        <node type="param - iterate">
          <xsl:value-of select="$iterateParam01 * 100" />
        </node>
      </xsl:iterate>
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
  <!-- Function param - not allowed a default value so no select attribute of sequence constructor tests -->
  <xsl:function name="myns:paramFunction01">
    <xsl:param name="functionParam01" />
    <xsl:value-of select="$functionParam01" />
  </xsl:function>
</xsl:stylesheet>