<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:x="http://www.jenitennison.com/xslt/xspec"
  exclude-result-prefixes="xs"
  version="3.0">

  <xsl:mode name="mymode" on-multiple-match="fail" on-no-match="fail" />
  <xsl:template match="myelement" mode="mymode">
    <xsl:param name="myparam" as="map(*)" required="yes" />
    <xsl:value-of select="$myparam('key')"/>
  </xsl:template>

  <xsl:template match="myelement">
    <xsl:param name="myparam" as="map(*)" required="yes" />
    <xsl:value-of select="$myparam('key')"/>
  </xsl:template>

  <xsl:template name="mytemplate">
    <xsl:param name="myparam" as="map(*)" required="yes" />
    <xsl:value-of select="$myparam('key')"/>
  </xsl:template>

</xsl:stylesheet>