<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:import href="../../src/schematron/step3.xsl" />

    <!-- Check -->
    <xsl:template match="xsl:variable[@name eq 'verify-me']" as="empty-sequence()" mode="#all">
        <xsl:message select="name(), 'already exists'" terminate="yes" />
    </xsl:template>

    <!-- Hook -->
    <xsl:template match="sch:let[@name eq 'hook-me']" as="element(xsl:variable)">
        <xsl:element name="xsl:variable">
            <xsl:attribute name="name">verify-me</xsl:attribute>
            <xsl:attribute name="select">12345</xsl:attribute>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
