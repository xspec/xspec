<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:choose Test Case
  -->
  <xsl:template match="xsl-choose">
    <root>
      <!-- xsl:when matches so otherwise not executed -->
      <xsl:choose>
        <xsl:when test="1 eq 1">
          <node type="choose when">
            <xsl:text>100</xsl:text>
          </node>
        </xsl:when>
        <xsl:otherwise version="3.0">                                          <!-- Expected miss -->
          <node type="choose otherwise" version="3.0">                         <!-- Expected miss -->
            <xsl:text version="3.0">200</xsl:text>                             <!-- Expected miss -->
          </node>                                                              <!-- Expected miss -->
        </xsl:otherwise>                                                       <!-- Expected miss -->
      </xsl:choose>
      <!-- xsl:when doesn't match so when not executed -->
      <xsl:choose>
        <xsl:when test="1 eq 2" version="3.0">                                 <!-- Expected miss -->
          <node type="choose when" version="3.0">                              <!-- Expected miss -->
            <xsl:text version="3.0">100</xsl:text>                             <!-- Expected miss -->
          </node>                                                              <!-- Expected miss -->
        </xsl:when>                                                            <!-- Expected miss -->
        <xsl:otherwise>
          <node type="choose otherwise">
            <xsl:text>200</xsl:text>
          </node>
        </xsl:otherwise>
      </xsl:choose>
      <!-- xsl:when with no content matches so first when and otherwise not executed -->
      <xsl:choose>
        <xsl:when test="1 eq 2" version="3.0">                                 <!-- Expected miss -->
          <node type="choose when" version="3.0">                              <!-- Expected miss -->
            <xsl:text version="3.0">100</xsl:text>                             <!-- Expected miss -->
          </node>                                                              <!-- Expected miss -->
        </xsl:when>                                                            <!-- Expected miss -->
        <xsl:when test="2 eq 2"></xsl:when>
        <xsl:otherwise version="3.0">                                          <!-- Expected miss -->
          <node type="choose otherwise" version="3.0">                         <!-- Expected miss -->
            <xsl:text version="3.0">200</xsl:text>                             <!-- Expected miss -->
          </node>                                                              <!-- Expected miss -->
        </xsl:otherwise>                                                       <!-- Expected miss -->
      </xsl:choose>
      <!-- xsl:when doesn't match so when not executed. otherwise has no content. -->
      <xsl:choose>
        <xsl:when test="1 eq 2" version="3.0">                                 <!-- Expected miss -->
          <node type="choose when" version="3.0">                              <!-- Expected miss -->
            <xsl:text version="3.0">100</xsl:text>                             <!-- Expected miss -->
          </node>                                                              <!-- Expected miss -->
        </xsl:when>                                                            <!-- Expected miss -->
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </root>
  </xsl:template>
</xsl:stylesheet>