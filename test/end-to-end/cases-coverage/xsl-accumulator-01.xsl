<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
       xsl:accumulator Test Case
  -->
  <!-- xsl:accumulator -->
  <xsl:accumulator name="accumulatorTest" initial-value="0">                   <!-- Expected ignored -->
    <xsl:accumulator-rule match="node">                                        <!-- Expected ignored -->
      <xsl:value-of select="$value + 1" />                                     <!-- Expected ignored -->
    </xsl:accumulator-rule>                                                    <!-- Expected ignored -->
  </xsl:accumulator>                                                           <!-- Expected ignored -->
  <!-- xsl:accumulator not used -->
  <xsl:accumulator name="dummy01" initial-value="0">                           <!-- Expected ignored -->
    <xsl:accumulator-rule match="node()" select="$value + 1" />                <!-- Expected ignored -->
  </xsl:accumulator>                                                           <!-- Expected ignored -->
  <!-- xsl:accumulator rules are higher priority than xsl:assert rule -->
  <xsl:accumulator name="accumulatorVsAssert" initial-value="()">              <!-- Expected ignored -->
    <xsl:accumulator-rule match="node">                                        <!-- Expected ignored -->
      <xsl:assert test="true()">                                               <!-- Expected ignored -->
        <xsl:text>cannot get here</xsl:text>                                   <!-- Expected ignored -->
      </xsl:assert>                                                            <!-- Expected ignored -->
    </xsl:accumulator-rule>                                                    <!-- Expected ignored -->
  </xsl:accumulator>                                                           <!-- Expected ignored -->
 
  <!-- xsl:mode for accumulator -->
  <xsl:mode use-accumulators="accumulatorTest" name="accumulator" />           <!-- Expected ignored -->
  <!-- Make accumulator applicable in default mode, too, so that
    xsl-accumulator-01.xspec can run with run-as="external" or
    when imported by a test with that setting. -->
  <xsl:mode use-accumulators="accumulatorTest" />                              <!-- Expected ignored -->
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