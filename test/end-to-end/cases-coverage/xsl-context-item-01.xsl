<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:context-item Coverage Test Case
  -->
  <xsl:template match="xsl-context-item">
    <xsl:context-item use="required" as="item()" />
      <root>
        <node type="context-item">
          <xsl:text>100</xsl:text>
        </node>
      </root>
  </xsl:template>
  <xsl:template name="template-not-hit">                                       <!-- Expected miss -->
    <xsl:context-item use="required" as="item()" />                            <!-- Expected miss -->
    <root>                                                                     <!-- Expected miss -->
      <node>                                                                   <!-- Expected miss -->
        <xsl:text>not hit</xsl:text>                                           <!-- Expected miss -->
      </node>                                                                  <!-- Expected miss -->
    </root>                                                                    <!-- Expected miss -->
  </xsl:template>                                                              <!-- Expected miss -->
</xsl:stylesheet>