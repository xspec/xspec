<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <!--
      xsl:character-map Coverage Test Case (includes xsl:output-character)
  -->
  <!-- character map does not do any mapping changes (confident that it is used in Saxon).
       But xspec doesn't do character-map without some additional effort (which isn't done here)-->
  <xsl:character-map name="charMap01" use-character-maps="charMap01A">
    <xsl:output-character character="0" string="0" />
    <xsl:output-character character="&#xE003;" string="3" />
  </xsl:character-map>
  <!-- xsl:character-map included in one above -->
  <xsl:character-map name="charMap01A">
    <xsl:output-character character="1" string="1" />
  </xsl:character-map>

  <xsl:output use-character-maps="charMap01" method="xml" encoding="utf-8" />

  <xsl:template match="xsl-character-map">
    <root>
      <node type="character-map">
        <xsl:text>100</xsl:text><!-- Maps to 100 -->
      </node>
    </root>
  </xsl:template>
</xsl:stylesheet>