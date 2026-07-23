<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:merge Coverage Test Case (also includes xsl:merge-source, xsl:merge-key and xsl:merge-action)
  -->
  <xsl:template match="xsl-merge">
    <root>
      <!-- 2 data sets to be merged -->
      <xsl:variable name="mergeSourceA">
        <node>100</node>
        <node>300</node>
        <node>500</node>
      </xsl:variable>
      <xsl:variable name="mergeSourceB">
        <node>200</node>
        <node>400</node>
        <node>600</node>
      </xsl:variable>
      <!-- 1st merge-key uses select attribute, 2nd uses sequence constructor -->
      <xsl:merge>
        <xsl:merge-source select="$mergeSourceA/*">
          <xsl:merge-key select="." />
        </xsl:merge-source>
        <xsl:merge-source select="$mergeSourceB/*">
          <xsl:merge-key>
            <xsl:value-of select="." />                                        <!-- Expected unknown -->
          </xsl:merge-key>
        </xsl:merge-source>
        <xsl:merge-action>
          <node type="merge">
            <xsl:value-of select="current-merge-group()" />
          </node>
        </xsl:merge-action>
      </xsl:merge>
      <xsl:if test="exists(merge-not-hit)">
        <xsl:merge>                                                            <!-- Expected miss -->
          <xsl:merge-source select="$mergeSourceA/*">                          <!-- Expected miss -->
            <xsl:merge-key select="." />                                       <!-- Expected miss -->
          </xsl:merge-source>                                                  <!-- Expected miss -->
          <xsl:merge-source select="$mergeSourceB/*">                          <!-- Expected miss -->
            <xsl:merge-key>                                                    <!-- Expected miss -->
              <xsl:value-of select="." />                                      <!-- Expected miss -->
            </xsl:merge-key>                                                   <!-- Expected miss -->
          </xsl:merge-source>                                                  <!-- Expected miss -->
          <xsl:merge-action>                                                   <!-- Expected miss -->
            <node type="merge">                                                <!-- Expected miss -->
              <xsl:value-of select="current-merge-group()" />                  <!-- Expected miss -->
            </node>                                                            <!-- Expected miss -->
          </xsl:merge-action>                                                  <!-- Expected miss -->
        </xsl:merge>                                                           <!-- Expected miss -->
      </xsl:if>
    </root>
  </xsl:template>
</xsl:stylesheet>