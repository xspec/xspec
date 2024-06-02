<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:assert Coverage Test Case (needs AssertEnabled option -ea). xsl:assert is always executed.
  -->
  <xsl:template match="xsl-assert">
    <root>
      <!-- Assert false -->
      <node type="assert">
        <xsl:try>
          <!-- Added instruction between xsl:try and xsl:assert to check trace output -->
          <xsl:value-of select="name()" />
          <xsl:assert test="100 lt 0">
            <xsl:text>Assert Message: 100 lt 0</xsl:text>
          </xsl:assert>
          <xsl:catch>
            <xsl:text>Assert was triggered as expected</xsl:text>
          </xsl:catch>
        </xsl:try>
      </node>
      <!-- Assert true -->
      <node type="assert">
      <xsl:try>
        <xsl:assert test="100 gt 0">
          <xsl:text>Assert Message: 100 gt 0</xsl:text>                        <!-- Expected miss -->
        </xsl:assert>
        <xsl:catch>                                                            <!-- Expected miss -->
          <xsl:text>Assert was triggered unexpectedly</xsl:text>               <!-- Expected miss -->
        </xsl:catch>                                                           <!-- Expected miss -->
      </xsl:try>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>