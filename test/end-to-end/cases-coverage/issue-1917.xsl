<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0" xmlns:local="http://local/xslt" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" />

  <xsl:function name="local:func-choose">
    <xsl:param name="text" />
    <xsl:choose>
      <xsl:when test="$text = 'one'">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>                                                          <!-- Expected miss -->
        <xsl:text>0</xsl:text>                                                 <!-- Expected miss -->
      </xsl:otherwise>                                                         <!-- Expected miss -->
    </xsl:choose>
  </xsl:function>

  <xsl:function name="local:func-variable">
    <xsl:param name="text" />
    <xsl:variable name="normalizedText">
      <xsl:value-of select="normalize-space($text)" />
    </xsl:variable>
    <xsl:if test="$normalizedText = 'one'">
      <xsl:text>1</xsl:text>
    </xsl:if>
    <xsl:if test="$normalizedText != 'one'">
      <xsl:text>0</xsl:text>                                                   <!-- Expected miss -->
    </xsl:if>
  </xsl:function>
</xsl:stylesheet>