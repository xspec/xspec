<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:x="http://www.jenitennison.com/xslt/xspec"
  xmlns:test="http://www.jenitennison.com/xslt/unit-test" exclude-result-prefixes="xs" version="3.0">

  <xsl:output indent="yes" exclude-result-prefixes="#all" omit-xml-declaration="yes"/>

  <xsl:import href="coverage-report.xsl"/>

  <xsl:template match="/">
    <xsl:apply-templates select="." mode="test:coverage-sonar-report"/>
  </xsl:template>

  <xsl:template match="/" mode="test:coverage-sonar-report" exclude-result-prefixes="#all">
    <xsl:variable name="context" as="node()*" select="trace/m"/>
    
    <coverage version="1">
      <xsl:for-each select="$context[not(contains(@u,'xspec-utils.xsl'))]">
        <xsl:variable name="mId" as="xs:string" select="@id"/>
        <xsl:variable name="mPath" as="xs:string" select="$context[@id = $mId]/@u"/>
        
        <file path="{test:xsl-file-location($mPath)}">
          <xsl:apply-templates select="doc($mPath)/xsl:*" mode="test:coverage-report" exclude-result-prefixes="#all"/>
        </file>
      </xsl:for-each>
    </coverage>
  </xsl:template>

  <xsl:template name="body-content">
    <xsl:param name="number-of-lines" as="xs:integer"/>
    <xsl:param name="module" as="xs:string?" tunnel="yes"/>
    <xsl:param name="stylesheet-string" as="xs:string"/>
    <xsl:param name="number-format" as="xs:string" tunnel="yes"/>

    <xsl:call-template name="test:output-lines">
        <xsl:with-param name="line-number" select="0"/>
        <xsl:with-param name="stylesheet-string" select="$stylesheet-string"/>
        <xsl:with-param name="node" select="."/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="line-content" exclude-result-prefixes="#all">
    <xsl:param name="line-number" as="xs:integer"/>
    <xsl:param name="coverage" as="xs:string"/>
    <xsl:param name="number-format" as="xs:string" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$coverage = 'missed'">
        <lineToCover lineNumber="{$line-number+1}" covered="false"/>
      </xsl:when>
      <xsl:when test="$coverage = 'hit'">
        <lineToCover lineNumber="{$line-number+1}" covered="true"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <!-- Function to calculate the xsl output, in order to be understood by SonarQube according to the Operating System  -->
  <xsl:function name="test:xsl-file-location">
    <xsl:param name="location" required="true"/>
    <xsl:variable name="absoluteXslPath" as="xs:string" select="substring-after($location, 'file:/')"/>
    <xsl:variable name="xslPathCorrected" as="xs:string" select="replace($absoluteXslPath, '%20', ' ')"/>
    <xsl:choose>
      <xsl:when test="contains($xslPathCorrected, ':/')">
        <!-- Windows os -->
        <xsl:value-of select="$xslPathCorrected"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('/', $xslPathCorrected)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>