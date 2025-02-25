<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
     xmlns:local="http://local/xslt" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!--
      Test Coverage Report Statistics Test
  -->
  <xsl:function name="local:timesThree" as="xs:integer">
    <xsl:param name="number" as="xs:integer" />

    <xsl:sequence select="$number * 3" />
  </xsl:function>
</xsl:stylesheet>