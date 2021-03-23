<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="3.0">

    <xsl:include href="../../src/schematron/preprocessor.xsl" />

    <xsl:import _href="{$x:schematron-preprocessor?stylesheets?3}" />

    <!--
        Check
    -->
    <xsl:template match="xsl:variable[@name eq 'verify-me']" as="empty-sequence()" mode="#all">
        <xsl:message select="name(), 'already exists'" terminate="yes" />
    </xsl:template>

    <!--
        Hook
    -->
    <xsl:template match="/sch:schema" as="element(xsl:transform)"
        use-when="$x:schematron-preprocessor?name eq 'schxslt'">
        <xsl:variable as="element(xsl:transform)" name="imports-applied">
            <xsl:apply-imports />
        </xsl:variable>

        <xsl:variable as="element(sch:let)" name="hook-me" select="sch:let[@name eq 'hook-me']" />

        <xsl:copy select="$imports-applied">
            <xsl:sequence select="attribute()" />

            <xsl:sequence select="node() except exactly-one(xsl:param[@name eq 'hook-me'])" />
            <xsl:apply-templates select="$hook-me" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="sch:let[@name eq 'hook-me']" as="element(xsl:variable)">
        <xsl:element name="xsl:variable">
            <xsl:attribute name="name" select="'verify-me'" />
            <xsl:attribute name="select" select="'12345'" />
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
