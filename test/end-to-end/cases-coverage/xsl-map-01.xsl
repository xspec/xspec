<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:myns="myNamespace">
  <!--
      xsl:map Coverage Test Case (includes xsl:map-entry)
  -->
  <!-- Create a variable containing the value 300. Copy this variable as an alternative to using xsl:sequence inside a xsl:map-entry.
       This is on the basis that xsl:sequence is not traced in Saxon 12.4 so it isn't possible to tell if child nodes are traced
       inside xsl:map-entry. -->
  <xsl:variable name="mapValue300" as="xs:integer">
    <xsl:sequence select="300" />
  </xsl:variable>

  <xsl:template match="xsl-map">
    <!-- Map construction, including xsl:map-entry -->
    <xsl:param name="hundreds-param" as="map(xs:string, xs:integer)">
      <xsl:map>
        <!-- Using select attribute -->
        <xsl:map-entry key="'One'" select="100"/>
        <xsl:map-entry key="'Two'" select="200"/>
        <!-- Using sequence constructor -->
        <xsl:map-entry key="'Three'">
          <xsl:copy select="$mapValue300" />
        </xsl:map-entry>
        <xsl:map-entry key="'Four'">
          <xsl:sequence select="400" />
        </xsl:map-entry>
      </xsl:map>
    </xsl:param>
    <xsl:variable name="hundreds-variable" as="map(xs:string, xs:integer)">
      <xsl:map>
        <!-- Using select attribute -->
        <xsl:map-entry key="'One'" select="100"/>
        <xsl:map-entry key="'Two'" select="200"/>
        <!-- Using sequence constructor -->
        <xsl:map-entry key="'Three'">
          <xsl:sequence>
            <xsl:copy select="$mapValue300" />
          </xsl:sequence>
        </xsl:map-entry>
        <xsl:map-entry key="'Four'">
          <xsl:sequence select="400" />
        </xsl:map-entry>
      </xsl:map>
    </xsl:variable>
    <!-- xsl:map with child that is not xsl:map-entry -->
    <xsl:variable name="map-variable01" as="map(xs:string, xs:decimal)">
      <xsl:map>
        <xsl:for-each select="1 to 5">
          <xsl:map-entry key="string(.)" select="xs:decimal(. * 600 div 6)"/>
        </xsl:for-each>
      </xsl:map>
    </xsl:variable>
    <!-- xsl:map with xsl:map-entry child using select attribute. A simple test case. -->
    <xsl:variable name="map-variable02" as="map(xs:string, xs:decimal)">
      <xsl:map>
        <xsl:map-entry key="'Seven'" select="xs:decimal(700)" />
      </xsl:map>
    </xsl:variable>
    <!-- xsl:map-entry not inside a xsl:map. Using select attribute -->
    <xsl:variable name="map-entry-variable01" as="map(xs:string, xs:integer)">
      <xsl:map-entry key="'One'" select="100"/>
    </xsl:variable>
    <!-- xsl:map-entry not inside a xsl:map. Using sequence constructor -->
    <xsl:variable name="map-entry-variable02" as="map(xs:string, xs:integer)">
      <xsl:map-entry key="'Three'">
        <xsl:copy select="$mapValue300" />
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

  <xsl:function name="myns:returnMap" as="map(xs:string, xs:integer)">
    <xsl:map>
      <!-- Using select attribute -->
      <xsl:map-entry key="'One'" select="100"/>
      <xsl:map-entry key="'Two'" select="200"/>
      <!-- Using sequence constructor -->
      <xsl:map-entry key="'Three'">
        <xsl:copy select="$mapValue300" />
      </xsl:map-entry>
      <xsl:map-entry key="'Four'">
        <xsl:sequence select="400" />
      </xsl:map-entry>
    </xsl:map>
  </xsl:function>
</xsl:stylesheet>