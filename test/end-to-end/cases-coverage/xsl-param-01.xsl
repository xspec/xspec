<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:myns="file://myNamespace">
  <!--
      xsl:param Coverage Test Case for child of xsl:stylesheet, xsl:iterate, xsl:function
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
  <!-- Function param - not allowed a default value so no select attribute or sequence constructor tests -->
  <xsl:function name="myns:paramFunction01">
    <xsl:param name="functionParam01" />
    <xsl:value-of select="$functionParam01" />
  </xsl:function>
</xsl:stylesheet>