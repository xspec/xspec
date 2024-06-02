<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
       xsl:accumulator Test Case
  -->
  <!-- xsl:accumulator -->
  <xsl:accumulator name="accumulatorTest" initial-value="0">
    <xsl:accumulator-rule match="node">
      <xsl:value-of select="$value + 1" />
    </xsl:accumulator-rule>
  </xsl:accumulator>
  <!-- xsl:accumulator not used -->
  <xsl:accumulator name="dummy01" initial-value="0">
    <xsl:accumulator-rule match="node()" select="$value + 1" />
  </xsl:accumulator>
  <!-- xsl:mode for accumulator -->
  <xsl:mode use-accumulators="accumulatorTest" name="accumulator" />
  <!-- Make accumulator applicable in default mode, too, so that
    xsl-accumulator-01.xspec can run with run-as="external" or
    when imported by a test with that setting. -->
  <xsl:mode use-accumulators="accumulatorTest" />
  <!-- Main template -->
  <xsl:template match="xsl-accumulator">
    <root>
      <!-- Process nodes used in xsl:accumulator -->
      <xsl:apply-templates select="*" mode="accumulator" />
    </root>
  </xsl:template>
  <!-- used in xsl:accumulator test -->
  <xsl:template match="node" mode="accumulator">
    <node type="accumulator before">
      <xsl:value-of select="accumulator-before('accumulatorTest')" />
    </node>
    <node type="accumulator after">
      <xsl:value-of select="accumulator-after('accumulatorTest')" />
    </node>
  </xsl:template>
</xsl:stylesheet>