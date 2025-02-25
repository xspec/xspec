<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
     xmlns:local="http://local/xslt" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!--
      Test Coverage Report Statistics Test
  -->
  <xsl:include href="coverage-statisticsA.xsl" />
  <xsl:include href="coverage-statisticsB.xsl" />

  <xsl:template name="Template01">
    <xsl:param name="param01" as="xs:integer" />

    <!-- Eleven -->
    <xsl:if test="local:timesTwo($param01) eq 22">
      <result>Eleven</result>
    </xsl:if>
    <!-- Twenty Two -->
    <xsl:if test="$param01 eq 22">
      <result>Twenty  Two</result>
    </xsl:if>
    <!-- Thirty three -->
    <xsl:if test="$param01 eq 33">
      <input>33</input>
      <result>Thirty Three</result>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>