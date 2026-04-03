<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:myns="myNamespace">
  <!--
      xsl:map Coverage Test Case (includes xsl:map-entry)
  -->

  <xsl:template match="xsl-map">
    <!-- Map construction, including xsl:map-entry -->
    <xsl:param name="hundreds-param" as="map(xs:string, item())">
      <xsl:map>
        <!-- Using select attribute -->
        <xsl:map-entry key="'One'" select="100"/>                              <!-- Expected unknown -->
        <xsl:map-entry key="'Two'" select="200"/>                              <!-- Expected unknown -->
        <!-- Using sequence constructor -->
        <xsl:map-entry key="'Three'">
          <!-- Combination of xsl:for-each and xsl:text is to make both
            Saxon 12.4 and 12.5 trace some descendant of xsl:map, to
            illustrate the Use Descendant Data rule. -->
          <xsl:for-each select="1 to 1">
            <xsl:text>300</xsl:text>
          </xsl:for-each>
        </xsl:map-entry>
        <xsl:map-entry key="'Four'">                                           <!-- Expected unknown -->
          <xsl:sequence select="400" />                                        <!-- Expected unknown -->
        </xsl:map-entry>                                                       <!-- Expected unknown -->
      </xsl:map>
    </xsl:param>
    <xsl:variable name="hundreds-variable" as="map(xs:string, item())">
      <xsl:map>
        <!-- Using select attribute -->
        <xsl:map-entry key="'One'" select="100"/>                              <!-- Expected unknown -->
        <xsl:map-entry key="'Two'" select="200"/>                              <!-- Expected unknown -->
        <!-- Using sequence constructor -->
        <xsl:map-entry key="'Three'">
          <xsl:sequence>
            <xsl:for-each select="1 to 1">
              <xsl:text>300</xsl:text>
            </xsl:for-each>
          </xsl:sequence>
        </xsl:map-entry>
        <xsl:map-entry key="'Four'">                                           <!-- Expected unknown -->
          <xsl:sequence select="400" />                                        <!-- Expected unknown -->
        </xsl:map-entry>                                                       <!-- Expected unknown -->
      </xsl:map>
    </xsl:variable>
    <!-- xsl:map with child that is not xsl:map-entry -->
    <xsl:variable name="map-variable01" as="map(xs:string, xs:decimal)">
      <xsl:map>
        <xsl:for-each select="1 to 5">
          <xsl:map-entry key="string(.)" select="xs:decimal(. * 600 div 6)"/>  <!-- Expected unknown -->
        </xsl:for-each>
      </xsl:map>
    </xsl:variable>
    <!-- xsl:map with xsl:map-entry child using select attribute. A simple test case. -->
    <xsl:variable name="map-variable02" as="map(xs:string, xs:decimal)">
      <xsl:map>                                                                <!-- Expected unknown -->
        <xsl:map-entry key="'Seven'" select="xs:decimal(700)" />               <!-- Expected unknown -->
      </xsl:map>                                                               <!-- Expected unknown -->
    </xsl:variable>
    <!-- xsl:map-entry not inside a xsl:map. Using select attribute -->
    <xsl:variable name="map-entry-variable01" as="map(xs:string, item())">
      <xsl:map-entry key="'One'" select="100"/>                                <!-- Expected unknown -->
    </xsl:variable>
    <!-- xsl:map-entry not inside a xsl:map. Using sequence constructor -->
    <xsl:variable name="map-entry-variable02" as="map(xs:string, item())">
      <xsl:map-entry key="'Three'">
        <xsl:for-each select="1 to 1">
          <xsl:text>300</xsl:text>
        </xsl:for-each>
      </xsl:map-entry>
    </xsl:variable>
    <!-- Use xsl:map values -->
    <root>
      <node type="param/map">
        <xsl:value-of select="$hundreds-param('One')" />
      </node>
      <node type="param/map">
        <xsl:value-of select="$hundreds-param('Three')" />
      </node>
      <node type="variable/map">
        <xsl:value-of select="$hundreds-variable('One')" />
      </node>
      <node type="variable/map">
        <xsl:value-of select="$hundreds-variable('Three')" />
      </node>
      <node type="variable/map">
        <xsl:value-of select="$map-variable01('5')" />
      </node>
      <node type="variable/map">
        <xsl:value-of select="$map-variable02('Seven')" />
      </node>
      <node type="function/map">
        <xsl:value-of select="myns:returnMap()('One')" />
      </node>
      <node type="function/map">
        <xsl:value-of select="myns:returnMap()('Three')" />
      </node>
    <!-- Use xsl:map-entry values -->
      <node type="variable/map-entry">
        <xsl:value-of select="$map-entry-variable01('One')" />
      </node>
      <node type="variable/map-entry">
        <xsl:value-of select="$map-entry-variable02('Three')" />
      </node>
    </root>
  </xsl:template>

  <xsl:function name="myns:returnMap" as="map(xs:string, item())">
    <xsl:map>
      <!-- Using select attribute -->
      <xsl:map-entry key="'One'" select="100"/>                                <!-- Expected unknown -->
      <xsl:map-entry key="'Two'" select="200"/>                                <!-- Expected unknown -->
      <!-- Using sequence constructor -->
      <xsl:map-entry key="'Three'">
        <xsl:for-each select="1 to 1">
          <xsl:text>300</xsl:text>
        </xsl:for-each>
      </xsl:map-entry>
      <xsl:map-entry key="'Four'">                                             <!-- Expected unknown -->
        <xsl:sequence select="400" />                                          <!-- Expected unknown -->
      </xsl:map-entry>                                                         <!-- Expected unknown -->
    </xsl:map>
  </xsl:function>
</xsl:stylesheet>