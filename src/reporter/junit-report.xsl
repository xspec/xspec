<?xml version="1.0" encoding="UTF-8"?>
<!-- =====================================================================

  Usage:	java -cp "$CP" net.sf.saxon.Transform 
		-o:"$JUNIT_RESULT" \
	        -s:"$RESULT" \
	        -xsl:"$XSPEC_HOME/src/reporter/junit-report.xsl"
  Description:  XSLT to convert XSpec XML report to JUnit report                                       
		Executed from bin/xspec.sh
  Input:        XSpec XML report                             
  Output:       JUnit report                                                         
  Dependencies: It requires XSLT 3.0 for function fn:serialize() 
  Authors:      Kal Ahmed, github.com/kal       
		Sandro Cirulli, github.com/cirulls
  License: 	MIT License (https://opensource.org/licenses/MIT)

  ======================================================================== -->
<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:pkg="http://expath.org/ns/pkg"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="x xs test pkg xhtml fn">
        
    <xsl:output name="escaped" method="xml" omit-xml-declaration="yes" indent="yes"/>

    <xsl:template match="x:report">
        <testsuites>
            <xsl:attribute name="name" select="@xspec"/>
            <xsl:apply-templates select="x:scenario"/>
        </testsuites>
    </xsl:template>
    
    <xsl:template match="x:scenario">
        <testsuite>
            <xsl:attribute name="name" select="x:label"/>
            <xsl:attribute name="tests" select="count(.//x:test)"/>
            <xsl:attribute name="failures" select="count(.//x:test[@successful='false'])"/>
            <xsl:apply-templates select="x:test"/>
            <xsl:apply-templates select="x:scenario" mode="nested"/>
        </testsuite>
    </xsl:template>

    <xsl:template match="x:scenario" mode="nested">
        <xsl:param name="prefix" select="''"/>
        <xsl:variable name="prefixed-label" select="concat($prefix, x:label, ' ')"/>
        <xsl:apply-templates select="x:test">
            <xsl:with-param name="prefix" select="$prefixed-label"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="x:scenario" mode="nested">
            <xsl:with-param name="prefix" select="$prefixed-label"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="x:test">
        <xsl:param name="prefix"/>
        <testcase>
            <xsl:attribute name="name" select="concat($prefix, x:label)"/>
            <xsl:attribute name="status">
                <xsl:choose>
                    <xsl:when test="@pending">skipped</xsl:when>
                    <xsl:when test="@successful='true'">passed</xsl:when>
                    <xsl:otherwise>failed</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="@pending"><skipped><xsl:value-of select="@pending"/></skipped></xsl:when>
                <xsl:when test="@successful='false'">
                    <failure message="expect assertion failed">
                        <xsl:apply-templates select="x:expect"/>
                    </failure>
                </xsl:when>
            </xsl:choose>
        </testcase>
    </xsl:template>
    
    <xsl:template match="x:expect[@select]">
        <xsl:text>Expected: </xsl:text><xsl:value-of select="x:expect/@select"/>
    </xsl:template>
    
    <xsl:template match="x:expect">
        <xsl:variable as="element(output:serialization-parameters)" name="serialization-parameters"
            xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:serialization-parameters>
                <output:omit-xml-declaration value="yes"/>
            </output:serialization-parameters>
        </xsl:variable>
        <xsl:value-of select="fn:serialize(., $serialization-parameters)"></xsl:value-of>
    </xsl:template>
    
</xsl:stylesheet>
