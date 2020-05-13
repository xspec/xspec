<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:x="http://www.jenitennison.com/xslt/xspec"
    xmlns:test="http://www.jenitennison.com/xslt/unit-test" exclude-result-prefixes="xs"
    version="2.0">

    <xsl:output indent="yes" exclude-result-prefixes="#all" omit-xml-declaration="yes"/>

    <xsl:import href="coverage-report.xsl"/>

    <xsl:template match="/">
            <xsl:apply-templates select="." mode="test:coverage-sonar-report"/>
    </xsl:template>

    <xsl:template match="/" mode="test:coverage-sonar-report" exclude-result-prefixes="#all">
        <coverage version="1">
            <file path="{test:xsl-file-location()}">
                <xsl:apply-templates select="$stylesheet-trees/xsl:*" mode="test:coverage-report" exclude-result-prefixes="#all"/>
            </file>
        </coverage>
    </xsl:template>
    
    <xsl:template name="body-content">
        <xsl:param name="number-of-lines" as="xs:integer"/>
        <xsl:param name="module" as="xs:string" tunnel="yes"/>
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

    <xsl:function name="test:sonar-coverage-report-uri">
        <xsl:variable name="xspecFolderPath" as="xs:anyURI" select="resolve-uri($trace/trace/x/@u)"/>
        <xsl:variable name="subBeforeDot" as="xs:string" select="substring-before($xspecFolderPath,'.')"/>
        <xsl:variable name="slash" select="tokenize(substring-before($xspecFolderPath,'.'),'/')"/>
        <xsl:variable name="pathDirectory" as="xs:string" select="substring-before($subBeforeDot,$slash[last()])"/>
        <xsl:variable name="sonarReportPath" as="xs:string" select="concat($pathDirectory,'sonar-coverage-report.xml')"/>
        <xsl:value-of select="$sonarReportPath"/>
    </xsl:function>

    <!-- Function to calculate the xsl output, in order to be understood by SonarQube according to the Operating System  -->
    <xsl:function name="test:xsl-file-location">
        <xsl:variable name="absoluteXslPath" as="xs:string"
            select="substring-after($stylesheet-uri, 'file:/')"/>
        <xsl:variable name="xslPathCorrected" as="xs:string"
            select="replace($absoluteXslPath, '%20', ' ')"/>
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
