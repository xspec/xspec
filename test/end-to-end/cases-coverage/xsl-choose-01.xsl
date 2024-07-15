<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:choose Test Case
  -->
  <xsl:template match="xsl-choose">
    <root>
      <!-- xsl:when matches, so xsl:otherwise does not execute -->
      <xsl:choose>
        <xsl:when test="1 eq 1">
          <node type="choose when">
            <xsl:text>100</xsl:text>
          </node>
        </xsl:when>
        <xsl:otherwise version="3.0">                                          <!-- Expected miss -->
          <node type="choose otherwise" version="3.0">                         <!-- Expected miss -->
            <xsl:text version="3.0">0</xsl:text>                               <!-- Expected miss -->
          </node>                                                              <!-- Expected miss -->
        </xsl:otherwise>                                                       <!-- Expected miss -->
      </xsl:choose>
      <!-- xsl:when doesn't match, so does not execute -->
      <xsl:choose>
        <xsl:when test="1 eq 2" version="3.0">                                 <!-- Expected miss -->
          <node type="choose when" version="3.0">                              <!-- Expected miss -->
            <xsl:text version="3.0">0</xsl:text>                               <!-- Expected miss -->
          </node>                                                              <!-- Expected miss -->
        </xsl:when>                                                            <!-- Expected miss -->
        <xsl:otherwise>
          <node type="choose otherwise">
            <xsl:text>200</xsl:text>
          </node>
        </xsl:otherwise>
      </xsl:choose>
      <!-- Second xsl:when executes but has no content, so unknown. First when and otherwise not executed. -->
      <xsl:choose>
        <xsl:when test="1 eq 2" version="3.0">                                 <!-- Expected miss -->
          <node type="choose when" version="3.0">                              <!-- Expected miss -->
            <xsl:text version="3.0">0</xsl:text>                               <!-- Expected miss -->
          </node>                                                              <!-- Expected miss -->
        </xsl:when>                                                            <!-- Expected miss -->
        <xsl:when test="2 eq 2"></xsl:when>                                    <!-- Expected unknown -->
        <xsl:otherwise version="3.0">                                          <!-- Expected miss -->
          <node type="choose otherwise" version="3.0">                         <!-- Expected miss -->
            <xsl:text version="3.0">0</xsl:text>                               <!-- Expected miss -->
          </node>                                                              <!-- Expected miss -->
        </xsl:otherwise>                                                       <!-- Expected miss -->
      </xsl:choose>
      <!-- xsl:when not executed. xsl:otherwise executes but has no content, so unknown. -->
      <xsl:choose>
        <xsl:when test="1 eq 2" version="3.0">                                 <!-- Expected miss -->
          <node type="choose when" version="3.0">                              <!-- Expected miss -->
            <xsl:text version="3.0">0</xsl:text>                               <!-- Expected miss -->
          </node>                                                              <!-- Expected miss -->
        </xsl:when>                                                            <!-- Expected miss -->
        <xsl:otherwise></xsl:otherwise>                                        <!-- Expected unknown -->
      </xsl:choose>
      <!-- xsl:when not executed, but status is unknown. -->
      <xsl:choose>
        <xsl:when test="exists(nonexistent)" version="3.0"></xsl:when>         <!-- Expected unknown -->
        <xsl:when test="exists(missing)" version="3.0">                        <!-- Expected unknown -->
          <!--untraced node-->                                                 <!-- Expected ignored -->
        </xsl:when>                                                            <!-- Expected unknown -->
        <xsl:when test="exists(omitted)" version="3.0">                        <!-- Expected unknown -->
          <xsl:where-populated>                                                <!-- Expected unknown -->
          </xsl:where-populated>                                               <!-- Expected unknown -->
        </xsl:when>                                                            <!-- Expected unknown -->
      </xsl:choose>
      <!-- xsl:when executes, but status is unknown. -->
      <!-- xsl:otherwise not executed, but status is unknown. -->
      <xsl:for-each select="(1,2)">
        <node type="choose when executed unknown">
          <xsl:choose>
            <xsl:when test=". eq 1" version="3.0">                             <!-- Expected unknown -->
              <!--untraced node-->                                             <!-- Expected ignored -->
            </xsl:when>                                                        <!-- Expected unknown -->
            <xsl:when test=". eq 2" version="3.0">                             <!-- Expected unknown -->
              <xsl:where-populated>                                            <!-- Expected unknown -->
              </xsl:where-populated>                                           <!-- Expected unknown -->
            </xsl:when>                                                        <!-- Expected unknown -->
            <xsl:otherwise version="3.0">                                      <!-- Expected unknown -->
              <xsl:where-populated>                                            <!-- Expected unknown -->
              </xsl:where-populated>                                           <!-- Expected unknown -->
            </xsl:otherwise>                                                   <!-- Expected unknown -->
          </xsl:choose>
        </node>
      </xsl:for-each>
      <!-- xsl:otherwise not executed, but status is unknown. -->
      <xsl:choose>
        <xsl:when test="1 eq 1" version="3.0"></xsl:when>                      <!-- Expected unknown -->
        <xsl:otherwise version="3.0">                                          <!-- Expected unknown -->
          <!--untraced node-->                                                 <!-- Expected ignored -->
        </xsl:otherwise>                                                       <!-- Expected unknown -->
      </xsl:choose>
      <!-- xsl:otherwise executes, but status is unknown; untraced child element. -->
      <node type="choose otherwise executed unknown">
        <xsl:choose>
          <xsl:when test="1 eq 2" version="3.0"></xsl:when>                    <!-- Expected unknown -->
          <xsl:otherwise version="3.0">                                        <!-- Expected unknown -->
            <xsl:where-populated>                                              <!-- Expected unknown -->
            </xsl:where-populated>                                             <!-- Expected unknown -->
          </xsl:otherwise>                                                     <!-- Expected unknown -->
        </xsl:choose>
      </node>
      <!-- xsl:otherwise executes, but status is unknown; untraced non-element child nodes. -->
      <node type="choose otherwise executed unknown">
        <xsl:choose>
          <xsl:when test="1 eq 2" version="3.0"></xsl:when>                    <!-- Expected unknown -->
          <xsl:otherwise version="3.0">                                        <!-- Expected unknown -->
            <!--untraced node-->                                               <!-- Expected ignored -->
          </xsl:otherwise>                                                     <!-- Expected unknown -->
        </xsl:choose>
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>