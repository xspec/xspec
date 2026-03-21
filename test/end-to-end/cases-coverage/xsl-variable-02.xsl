<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">
  <!--
      xsl:variable Optimization Coverage Test Case
      This test covers the 4 ways xsl:variables are optimized by Saxon:
        Eliminated unused variable (marked as unused)
        Eliminated trivial variable (marked as trivial)
        Inlined constant variable (marked as constant)
        Inlined references to $xxx (marked as inlined)
  -->
  <xsl:template match="xsl-variable">
    <root>
      <!-- Local variable unused with select attribute -->
      <xsl:variable name="unused01" select="string(400)" />                    <!-- Expected miss (optim unused) -->
      <node type="variable - unused">
      </node>
      <!-- Local variable unused with sequence constructor -->
      <xsl:variable name="unused02">                                           <!-- Expected miss (optim unused) -->
        <xsl:value-of select="string(400)" />                                  <!-- Expected miss (optim unused) -->
      </xsl:variable>                                                          <!-- Expected miss (optim unused) -->
      <node type="variable - unused">
      </node>
      <!-- Local variable trivial with select attribute
           xsl:sequence is needed to make it trivial, xsl:value-of causes inlined -->
      <node type="variable - trivial">
        <xsl:variable name="trivial01" select="node * 1" />
        <xsl:sequence select="$trivial01" />
      </node>
      <!-- Local variable trivial with sequence constructor
           xsl:sequence is needed to make it trivial, xsl:value-of causes inlined -->
      <node type="variable - trivial">
        <xsl:variable name="trivial02">
          <xsl:text>1</xsl:text>
          <xsl:text>00</xsl:text>
        </xsl:variable>
        <xsl:sequence select="$trivial02" />
      </node>
      <!-- Local variable constant with select attribute -->
      <xsl:variable name="constant01" select="200" />                          <!-- Expected miss (optim constant) -->
      <node type="variable - constant">
        <xsl:value-of select="$constant01" />
      </node>
      <!-- Local variable constant with sequence constructor
           Needed as attribute to make it constant -->
      <xsl:variable name="constant02" as="xs:string+">                         <!-- Expected miss (optim constant) -->
        <xsl:text>2</xsl:text>                                                 <!-- Expected miss (optim constant) -->
        <xsl:text>00</xsl:text>                                                <!-- Expected miss (optim constant) -->
      </xsl:variable>                                                          <!-- Expected miss (optim constant) -->
      <node type="variable - constant">
        <xsl:value-of select="$constant02" separator="" />
      </node>
      <!-- Local variable inlined with select attribute -->
      <xsl:variable name="inlined01" select="node || '0'" />
      <node type="variable - inlined">
        <xsl:value-of select="$inlined01" />
      </node>
      <!-- Local variable inlined with sequence constructor -->
      <xsl:variable name="inlined02">
        <xsl:value-of select="node" />
        <xsl:text>0</xsl:text>
      </xsl:variable>
      <node type="variable - inlined">
        <xsl:value-of select="$inlined02" />
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>