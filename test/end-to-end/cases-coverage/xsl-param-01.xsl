<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:myns="file://myNamespace">
  <!--
      xsl:param Coverage Test Case
  -->
  <!-- Global param -->
  <xsl:param name="globalParam01" />

  <xsl:template match="xsl-param">
    <root>
      <!-- Global param -->
      <node type="param - global">
        <xsl:value-of select="$globalParam01" />
      </node>
      <!-- Template param -->
      <xsl:call-template name="paramTemplate01">
        <xsl:with-param name="templateParam01">200</xsl:with-param>
      </xsl:call-template>
      <!-- Function param -->
      <node type="param - function">
        <xsl:value-of select="myns:paramFunction01('300')" />
      </node>
      <!--Iterate param -->
      <xsl:iterate select="node">
        <xsl:param name="iterateParam01" select="4" />
        <node type="param - iterate">
          <xsl:value-of select="$iterateParam01 * 100" />
        </node>
      </xsl:iterate>
    </root>
  </xsl:template>
  <!-- Template param -->
  <xsl:template name="paramTemplate01">
    <xsl:param name="templateParam01" />
    <node type="param - template">
      <xsl:value-of select="$templateParam01" />
    </node>
  </xsl:template>
  <!-- Function param -->
  <xsl:function name="myns:paramFunction01">
    <xsl:param name="functionParam01" />
    <xsl:value-of select="$functionParam01" />
  </xsl:function>
</xsl:stylesheet>