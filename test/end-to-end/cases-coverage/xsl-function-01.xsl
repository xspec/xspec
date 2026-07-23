<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:myns="myNamespace">
  <!--
      xsl:function Coverage Test Case
  -->
  <xsl:template match="xsl-function">
    <root>
      <!-- Very simple just to check function called -->
      <node type="function">
        <xsl:value-of select="myns:returnHundred()" />
      </node>
    </root>
  </xsl:template>
  <!-- Function called -->
  <xsl:function name="myns:returnHundred">
    <xsl:text>100</xsl:text>
  </xsl:function>
  <!-- Function NOT called -->
  <xsl:function name="myns:returnThousand">                                    <!-- Expected miss -->
    <xsl:text>1000</xsl:text>                                                  <!-- Expected miss -->
  </xsl:function>                                                              <!-- Expected miss -->
</xsl:stylesheet>