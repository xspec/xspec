<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:variable Coverage Test Case
  -->
  <!-- Global variable -->
  <xsl:variable name="variableGlobalSelect01" select="string(100)" />
  <xsl:variable name="variableGlobalDocNode01">
    <xsl:text>20</xsl:text>
    <element>0</element>
  </xsl:variable>
  <xsl:variable name="variableGlobalAs01" as="text()">
    <xsl:text>200</xsl:text>
  </xsl:variable>
  <xsl:variable name="variableGlobalEmptySequence01" as="element()?" />
  <xsl:variable name="variableGlobalEmptyString01" />
  <!-- Not used -->
  <xsl:variable name="variableGlobalSelectUnused01" select="string(300)" />    <!-- Expected miss -->
  <xsl:variable name="variableGlobalDocNodeUnused01">                          <!-- Expected miss -->
    <xsl:text>40</xsl:text>                                                    <!-- Expected miss -->
    <element>0</element>                                                       <!-- Expected miss -->
  </xsl:variable>                                                              <!-- Expected miss -->
  <!-- Not used -->
  <xsl:variable name="variableGlobalAsUnused01" as="text()">                   <!-- Expected miss -->
    <xsl:text>400</xsl:text>                                                   <!-- Expected miss -->
  </xsl:variable>                                                              <!-- Expected miss -->
  <!-- Not used -->
  <xsl:variable name="variableGlobalEmptySequenceUnused01" as="element()?" />  <!-- Expected miss -->
  <!-- Not used -->
  <xsl:variable name="variableGlobalEmptyStringUnused01" />                    <!-- Expected miss -->

  <xsl:template match="xsl-variable">
    <xsl:variable name="variableLocalSelect01" select="string(400)" />
    <xsl:variable name="variableLocalDocNode01">
      <xsl:text>50</xsl:text>
      <element>0</element>
    </xsl:variable>
    <xsl:variable name="variableLocalAs01" as="text()">
      <xsl:text>500</xsl:text>
    </xsl:variable>
    <xsl:variable name="variableLocalEmptySequence01" as="element()?" />       <!-- Expected miss (optim constant) -->
    <xsl:variable name="variableLocalEmptyString01" />                         <!-- Expected miss (optim constant) -->
    <!-- Not used -->
    <xsl:variable name="variableLocalSelectUnused01" select="string(600)" />   <!-- Expected miss (optim unused) -->
    <!-- Not used -->
    <xsl:variable name="variableLocalDocNodeUnused01">                         <!-- Expected miss (optim unused) -->
      <xsl:text>70</xsl:text>                                                  <!-- Expected miss (optim unused) -->
      <element>0</element>                                                     <!-- Expected miss (optim unused) -->
    </xsl:variable>                                                            <!-- Expected miss (optim unused) -->
    <!-- Not used -->
    <xsl:variable name="variableLocalAsUnused01" as="text()">                  <!-- Expected miss (optim unused) -->
      <xsl:text>700</xsl:text>                                                 <!-- Expected miss (optim unused) -->
    </xsl:variable>                                                            <!-- Expected miss (optim unused) -->
    <!-- Not used -->
    <xsl:variable name="variableLocalEmptySequenceUnused01" as="element()?" /> <!-- Expected miss (optim constant) -->
    <!-- Not used -->
    <xsl:variable name="variableLocalEmptyStringUnused01" />                   <!-- Expected miss (optim constant) -->

    <xsl:choose>
      <xsl:when test="1 eq 2">                                                 <!-- Expected miss -->
        <!-- No relevant following siblings -->
        <xsl:variable name="variableLocalSelectNoEffect01" select="string(1600)" /><!-- Expected miss -->
        <!-- No relevant following siblings -->
        <xsl:variable name="variableLocalDocNodeNoEffect01">                   <!-- Expected miss -->
          <xsl:text>170</xsl:text>                                             <!-- Expected miss -->
          <element>0</element>                                                 <!-- Expected miss -->
        </xsl:variable>                                                        <!-- Expected miss -->
        <!-- No relevant following siblings -->
        <xsl:variable name="variableLocalasNoEffect01" as="text()">            <!-- Expected miss -->
          <xsl:text>1700</xsl:text>                                            <!-- Expected miss -->
        </xsl:variable>                                                        <!-- Expected miss -->
        <!-- No relevant following siblings -->
        <xsl:variable name="variableLocalEmptySequenceNoEffect01" as="element()?" /><!-- Expected miss -->
        <!-- No relevant following siblings -->
        <xsl:variable name="variableLocalEmptyStringNoEffect01" />             <!-- Expected miss -->
        <!-- No relevant following siblings; warning from Saxon -->
        <xsl:variable name="variableLocalSeq" as="item()+"
          select="($variableLocalSelectNoEffect01, $variableLocalDocNodeNoEffect01,
          $variableLocalasNoEffect01, $variableLocalEmptySequenceNoEffect01,
          $variableLocalEmptyStringNoEffect01)"/>                              <!-- Expected miss -->
      </xsl:when>                                                              <!-- Expected miss -->
      <xsl:otherwise>                                                          <!-- Expected miss -->
        <!-- No relevant following siblings -->
        <xsl:variable name="variableLocalSelectNoEffect02" select="string(1600)" /><!-- Expected miss -->
        <!-- No relevant following siblings -->
        <xsl:variable name="variableLocalDocNodeNoEffect02">                   <!-- Expected miss -->
          <xsl:text>170</xsl:text>                                             <!-- Expected miss -->
          <element>0</element>                                                 <!-- Expected miss -->
        </xsl:variable>                                                        <!-- Expected miss -->
        <!-- No relevant following siblings -->
        <xsl:variable name="variableLocalasNoEffect02" as="text()">            <!-- Expected miss -->
          <xsl:text>1700</xsl:text>                                            <!-- Expected miss -->
        </xsl:variable>                                                        <!-- Expected miss -->
        <!-- No relevant following siblings -->
        <xsl:variable name="variableLocalEmptySequenceNoEffect02" as="element()?" /><!-- Expected miss -->
        <!-- No relevant following siblings -->
        <xsl:variable name="variableLocalEmptyStringNoEffect02" />             <!-- Expected miss -->
        <!-- No relevant following siblings; warning from Saxon -->
        <xsl:variable name="variableLocalSeq" as="item()+"
          select="($variableLocalSelectNoEffect02, $variableLocalDocNodeNoEffect02,
          $variableLocalasNoEffect02, $variableLocalEmptySequenceNoEffect02,
          $variableLocalEmptyStringNoEffect02)"/>                              <!-- Expected miss -->
      </xsl:otherwise>                                                         <!-- Expected miss -->
    </xsl:choose>

    <root>
      <!-- Global variable used -->
      <node type="variable - global">
        <xsl:value-of select="$variableGlobalSelect01" />
      </node>
      <!-- Global variable used -->
      <node type="variable - global">
        <xsl:value-of select="$variableGlobalDocNode01" />
      </node>
      <!-- Global variable used -->
      <node type="variable - global">
        <xsl:value-of select="$variableGlobalAs01" />
      </node>
      <!-- Global variable used -->
      <node type="variable - global">
        <xsl:value-of select="count($variableGlobalEmptySequence01)" />
      </node>
      <!-- Global variable used -->
      <node type="variable - global">
        <xsl:value-of select="count($variableGlobalEmptyString01)" />
      </node>
      <!-- Local variable used -->
      <node type="variable - local">
        <xsl:value-of select="$variableLocalSelect01" />
      </node>
      <!-- Local variable used -->
      <node type="variable - local">
        <xsl:value-of select="$variableLocalDocNode01" />
      </node>
      <!-- Local variable used -->
      <node type="variable - local">
        <xsl:value-of select="$variableLocalAs01" />
      </node>
      <!-- Local variable used -->
      <node type="variable - local">
        <xsl:value-of select="count($variableLocalEmptySequence01)" />
      </node>
      <!-- Local variable used -->
      <node type="variable - local">
        <xsl:value-of select="count($variableLocalEmptyString01)" />
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>