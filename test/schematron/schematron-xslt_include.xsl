<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dsdl="http://www.schematron.com/namespace/dsdl"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:import href="../../lib/iso-schematron/iso_dsdl_include.xsl" />

    <!-- Check -->
    <xsl:template match="sch:pattern[@is-a eq 'hook-me']" as="empty-sequence()" mode="#all">
        <xsl:message select="name(), 'already exists'" terminate="yes" />
    </xsl:template>

    <!-- Hook -->
    <xsl:template match="sch:include[@href eq 'hook-me']" as="element(sch:pattern)" mode="dsdl:go">
        <sch:pattern is-a="hook-me" />
    </xsl:template>
</xsl:stylesheet>
