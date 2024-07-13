<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="99.0">
  <!--
      xsl:fallback Coverage Test Case
  -->
   <xsl:template match="xsl-fallback">
      <root>
        <!-- Sets the xsl version number higher than current version and has unknown instruction (adapted from XSLT Spec) -->
        <xsl:non-existent-instruction>                                         <!-- Expected miss -->
          <xsl:fallback>
            <node type="fallback">
              <xsl:text>100</xsl:text>
            </node>
          </xsl:fallback>
        </xsl:non-existent-instruction>                                        <!-- Expected miss -->

        <!-- Test cases for unknown status -->
        <node type="fallback executed unknown">
          <xsl:non-existent-instruction>                                       <!-- Expected miss -->
            <xsl:fallback></xsl:fallback>                                      <!-- Expected unknown -->
          </xsl:non-existent-instruction>                                      <!-- Expected miss -->          
        </node>
        <node type="fallback executed unknown">
          <xsl:non-existent-instruction>                                       <!-- Expected miss -->
            <xsl:fallback>                                                     <!-- Expected unknown -->
              <!--untraced node-->                                             <!-- Expected ignored -->
            </xsl:fallback>                                                    <!-- Expected unknown -->
          </xsl:non-existent-instruction>                                      <!-- Expected miss -->          
        </node>
        <node type="fallback executed unknown">
          <xsl:non-existent-instruction>                                       <!-- Expected miss -->
            <xsl:fallback>                                                     <!-- Expected unknown -->
              <xsl:sequence select="200" />                                    <!-- Expected unknown -->
            </xsl:fallback>                                                    <!-- Expected unknown -->
          </xsl:non-existent-instruction>                                      <!-- Expected miss -->          
        </node>
        <node type="fallback unexecuted unknown">
          <xsl:value-of>
            <xsl:fallback></xsl:fallback>                                      <!-- Expected unknown -->
          </xsl:value-of>          
        </node>
        <node type="fallback unexecuted unknown">
          <xsl:value-of>
            <xsl:fallback>                                                     <!-- Expected unknown -->
              <!--untraced node-->                                             <!-- Expected ignored -->
            </xsl:fallback>                                                    <!-- Expected unknown -->
          </xsl:value-of>          
        </node>
        <node type="fallback unexecuted unknown">
          <xsl:value-of>
            <xsl:fallback>                                                     <!-- Expected unknown -->
              <xsl:sequence select="200" />                                    <!-- Expected unknown -->
            </xsl:fallback>                                                    <!-- Expected unknown -->
          </xsl:value-of>          
        </node>
      </root>
   </xsl:template>
</xsl:stylesheet>