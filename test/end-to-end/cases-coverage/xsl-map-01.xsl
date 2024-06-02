<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <!--
      xsl:map Coverage Test Case (includes xsl:map)
  -->
  <xsl:template match="xsl-map">
    <root>
      <!-- Map construction, including xsl:map -->
      <xsl:variable name="hundreds" as="map(xs:string, xs:integer)">
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
      <node type="map">
        <xsl:value-of select="$hundreds('One')" />
      </node>
      <node type="map">
        <xsl:value-of select="$hundreds('Three')" />
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>