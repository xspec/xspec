<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:assert Coverage Test Case (needs AssertEnabled option -ea). xsl:assert is always executed.
  -->
  <xsl:template match="xsl-assert" mode="xsl-assert-false">
    <root>
      <!-- Assert false -->
      <node type="assert">
        <xsl:assert test="100 lt 0">
          <xsl:text>Assert Message: 100 lt 0</xsl:text>
        </xsl:assert>
      </node>
    </root>
  </xsl:template>

  <xsl:template match="xsl-assert" mode="xsl-assert-false-before-traceable">
      <!-- Use Descendant Data case of untraceable executed combined with traceable unexecuted -->
      <!-- xsl:iterate with xsl:on-completion executed but unknown status -->
      <node type="iterate/on-completion executed unknown">
        <xsl:iterate select="1">
          <xsl:on-completion>                                                  <!-- Expected unknown -->
            <xsl:assert test="100 lt 0" />
            <xsl:text>can't get here</xsl:text>                                <!-- Expected miss -->
          </xsl:on-completion>                                                 <!-- Expected unknown -->
          <xsl:value-of select="concat(., ', ')" />
        </xsl:iterate>
      </node>
  </xsl:template>

  <xsl:template match="xsl-assert" mode="xsl-assert-true">
    <root>
      <!-- Assert true -->
      <node type="assert">
        <xsl:assert test="100 gt 0">
          <xsl:text>Assert Message: 100 gt 0</xsl:text>                        <!-- Expected miss -->
        </xsl:assert>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>