<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:myns="file://myNamespace"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="3.0">
  <!--
      xsl:param Coverage Test Case for child of xsl:stylesheet, xsl:iterate, xsl:function
  -->
  <!-- Global param overridden in XSpec -->
  <xsl:param name="globalParam01">0</xsl:param>                                <!-- Expected miss -->
  <!-- Global param not overridden in XSpec - no default provided -->
  <xsl:param name="globalParamEmptyString01" />
  <!-- Global param not overridden in XSpec - no default provided but @as is present-->
  <xsl:param name="globalParamEmptySequence01" as="text()?" />
  <!-- Global param not overridden in XSpec - with select attribute -->
  <xsl:param name="globalParamSelect01" select="200" />
  <!-- Global param not overridden in XSpec - with inline sequence constructor -->
  <xsl:param name="globalParamDocNode01">300</xsl:param>
  <xsl:param name="globalParamAs01" as="text()">300</xsl:param>
  <!-- Global param not overridden in XSpec - with multiline sequence constructor-->
  <xsl:param name="globalParamDocNode02">
    <xsl:text>4</xsl:text>
    <xsl:text>0</xsl:text>
    <xsl:text>0</xsl:text>
  </xsl:param>
  <xsl:param name="globalParamAs02" as="text()+">
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
        <xsl:value-of select="count($globalParamEmptyString01)" />
      </node>
      <node type="param - global">
        <xsl:value-of select="count($globalParamEmptySequence01)" />
      </node>
      <node type="param - global">
        <xsl:value-of select="$globalParamSelect01" />
      </node>
      <node type="param - global">
        <xsl:value-of select="$globalParamDocNode01" />
      </node>
      <node type="param - global">
        <xsl:value-of select="$globalParamAs01" />
      </node>
      <node type="param - global">
        <xsl:value-of select="$globalParamDocNode02" />
      </node>
      <node type="param - global">
        <xsl:value-of select="$globalParamAs02" />
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
        <xsl:param name="iterateParamDocNode01">14</xsl:param>
        <xsl:param name="iterateParamAs01" as="xs:integer" select="14" />
        <node type="param - iterate">
          <xsl:value-of select="$iterateParamDocNode01 * 100 + $iterateParamAs01" />
        </node>
      </xsl:iterate>
      <!--Iterate param with multiline sequence constructor -->
      <xsl:iterate select="node">
        <xsl:param name="iterateParamDocNode01">
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
        <xsl:param name="iterateParamAs01" as="xs:integer" select="15" />
        <node type="param - iterate">
          <xsl:value-of select="$iterateParamDocNode01 * 100 + $iterateParamAs01" />
        </node>
      </xsl:iterate>
      <!--Iterate param with empty string and empty sequence -->
      <xsl:iterate select="node">
        <xsl:param name="iterateParamEmptySequence01" as="xs:string?" />
        <xsl:param name="iterateParamEmptyString01" />
        <node type="param - iterate">
          <xsl:value-of select="count($iterateParamEmptySequence01)" />
          <xsl:value-of select="count($iterateParamEmptyString01)" />
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