<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="3.0">
  <!--
      Coverage Test Case for Text Nodes
  -->
  <xsl:param name="param-text">100</xsl:param>
  <xsl:variable name="variable-text">100</xsl:variable>
  <xsl:template match="text-node">
    <root>
      <node type="text">100</node>
      <node type="text">
        <xsl:text>100</xsl:text>
      </node>
      <node type="text">
        <xsl:sequence>100</xsl:sequence>        
      </node>
      <node type="text">
        <xsl:value-of>100</xsl:value-of>    
      </node>
      <node type="text">
        <xsl:value-of select="string(100)"/>   
      </node>
      <node type="text" xsl:expand-text="yes">{
        $param-text
      }</node>
      <node type="text" xsl:expand-text="yes">{
        $variable-text
        }</node>
      <node type="text" xsl:expand-text="yes">{100}</node>
      <node type="text">
        <xsl:text expand-text="yes">{ $variable-text }</xsl:text>        
      </node>
      <node type="text">
        <xsl:sequence expand-text="yes">{ $variable-text }</xsl:sequence>        
      </node>
      <node type="text">
        <xsl:value-of expand-text="yes">{ $variable-text }</xsl:value-of>        
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>