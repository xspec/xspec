<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="99.0">
  <!--
      xsl:fallback Coverage Test Case
  -->
   <xsl:template match="xsl-fallback">
      <root>
        <!-- Sets the xsl version number higher than current version and has unknown instruction (adapted from XSLT Spec) -->
        <xsl:non-existant-instruction>                                         <!-- Expected miss -->
          <xsl:fallback>
            <node type="fallback">
              <xsl:text>100</xsl:text>
            </node>
          </xsl:fallback>
        </xsl:non-existant-instruction>                                        <!-- Expected miss -->
      </root>
   </xsl:template>
</xsl:stylesheet>