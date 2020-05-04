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
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

    <xsl:include href="../common/parse-report.xsl" />

    <xsl:output indent="yes"/>

    <xsl:template match="x:report" as="element(testsuites)">
        <testsuites>
            <xsl:attribute name="name" select="@xspec"/>
            <xsl:apply-templates select="x:scenario"/>
        </testsuites>
    </xsl:template>

    <xsl:template match="x:scenario" as="element(testsuite)">
        <testsuite>
            <xsl:attribute name="name" select="x:label"/>
            <xsl:attribute name="tests" select="count(x:descendant-tests(.))"/>
            <xsl:attribute name="failures" select="count(x:descendant-failed-tests(.))"/>
            <xsl:apply-templates select="x:test"/>
            <xsl:apply-templates select="x:scenario" mode="nested"/>
        </testsuite>
    </xsl:template>

    <xsl:template match="x:scenario" as="element(testcase)+" mode="nested">
        <xsl:param name="prefix" as="xs:string" select="''" />

        <xsl:variable name="prefixed-label" as="xs:string" select="concat($prefix, x:label, ' ')" />
        <xsl:apply-templates select="x:test">
            <xsl:with-param name="prefix" select="$prefixed-label"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="x:scenario" mode="nested">
            <xsl:with-param name="prefix" select="$prefixed-label"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="x:test" as="element(testcase)">
        <xsl:param name="prefix" as="xs:string" />

        <testcase>
            <xsl:attribute name="name" select="concat($prefix, x:label)"/>
            <xsl:attribute name="status">
                <xsl:choose>
                    <xsl:when test="x:is-pending-test(.)">skipped</xsl:when>
                    <xsl:when test="x:is-passed-test(.)">passed</xsl:when>
                    <xsl:otherwise>failed</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="x:is-pending-test(.)"><skipped><xsl:value-of select="@pending"/></skipped></xsl:when>
                <xsl:when test="x:is-failed-test(.)">
                    <failure message="expect assertion failed">
                        <xsl:apply-templates select="x:expect"/>
                    </failure>
                </xsl:when>
            </xsl:choose>
        </testcase>
    </xsl:template>

    <xsl:template match="x:expect[@select]" as="text()+">
        <xsl:text>Expected: </xsl:text><xsl:value-of select="@select"/>
    </xsl:template>

    <xsl:template match="x:expect" as="text()">
        <xsl:variable as="element(output:serialization-parameters)" name="serialization-parameters"
            xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">
            <output:serialization-parameters>
                <output:omit-xml-declaration value="yes"/>
            </output:serialization-parameters>
        </xsl:variable>
        <xsl:value-of select="serialize(., $serialization-parameters)"/>
    </xsl:template>

</xsl:stylesheet>
