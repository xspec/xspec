<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:myns="myNamespace">
  <!--
      xsl:map Coverage Test Case (includes xsl:map)
  -->
  <xsl:template match="xsl-map">
    <!-- Map construction, including xsl:map -->
    <xsl:param name="hundreds-param" as="map(xs:string, xs:integer)">
      <xsl:map>
        <!-- Using select attribute -->
        <xsl:map-entry key="'One'" select="100"/>
        <xsl:map-entry key="'Two'" select="200"/>
        <!-- Using sequence constructor -->
        <xsl:map-entry key="'Three'">
          <xsl:sequence select="300" />
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
          <xsl:sequence select="300" />
        </xsl:map-entry>
        <xsl:map-entry key="'Four'">
          <xsl:sequence select="400" />
        </xsl:map-entry>
      </xsl:map>
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
      <node type="function/map">
        <xsl:value-of select="myns:returnMap()('One')" />
      </node>
      <node type="function/map">
        <xsl:value-of select="myns:returnMap()('Three')" />
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
        <xsl:sequence select="300" />
      </xsl:map-entry>
      <xsl:map-entry key="'Four'">
        <xsl:sequence select="400" />
      </xsl:map-entry>
    </xsl:map>
  </xsl:function>
</xsl:stylesheet>