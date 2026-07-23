<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:assert Coverage Test Case (needs AssertEnabled option -ea).
  -->
  <xsl:template match="xsl-assert" mode="xsl-assert-false-seq-constr">
    <root>
      <!-- Assert false -->
      <!-- Trace appears on child xsl:text element so Use Descendant Data. -->
      <node type="assert">
        <xsl:assert test="100 lt 0">
          <xsl:text>Assert Message: 100 lt 0</xsl:text>
        </xsl:assert>
      </node>
    </root>
  </xsl:template>

  <xsl:template match="xsl-assert" mode="xsl-assert-false-no-seq-constr">
      <!-- Trace appears on xsl:assert element so Use Trace Data -->
      <node type="assert">
        <xsl:assert test="100 lt 0" />
        <xsl:text>can't get here</xsl:text>                                    <!-- Expected miss -->
      </node>
  </xsl:template>

  <xsl:template match="xsl-assert" mode="xsl-assert-true-seq-constr">
    <root>
      <!-- Assert true -->
      <node type="assert">
        <xsl:assert test="100 gt 0">                                           <!-- Expected miss -->
          <xsl:text>Assert Message: 100 gt 0</xsl:text>                        <!-- Expected miss -->
        </xsl:assert>                                                          <!-- Expected miss -->
      </node>
    </root>
  </xsl:template>

  <xsl:template match="xsl-assert" mode="xsl-assert-true-no-seq-constr">
    <root>
      <!-- Assert true -->
      <node type="assert">
        <xsl:assert test="100 gt 0" />                                         <!-- Expected miss -->
        <xsl:text>can get here</xsl:text>
      </node>
    </root>
  </xsl:template>

  <xsl:template match="xsl-assert" mode="xsl-assert-not-evaluated">
    <root>
      <node type="assert">
        <xsl:if test="100 lt 0">
          <xsl:text>can't get here</xsl:text>                                  <!-- Expected miss -->
          <xsl:assert test="100 gt 0">                                         <!-- Expected miss -->
            <xsl:text>Assert Message: 100 gt 0</xsl:text>                      <!-- Expected miss -->
          </xsl:assert>                                                        <!-- Expected miss -->
          <xsl:assert test="100 gt 0" />                                       <!-- Expected miss -->
        </xsl:if>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>