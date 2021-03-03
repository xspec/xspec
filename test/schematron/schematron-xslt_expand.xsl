<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:import href="../../lib/schxslt/2.0/expand.xsl" />

    <!-- Check -->
    <xsl:template match="sch:let[@name eq 'hook-me']" as="empty-sequence()" mode="#all">
        <xsl:message select="name(), 'already exists'" terminate="yes" />
    </xsl:template>

    <!-- Hook -->
    <xsl:template match="sch:pattern[@is-a eq 'hook-me']" as="element(sch:let)" mode="schxslt:expand">
        <sch:let name="hook-me" />
    </xsl:template>
</xsl:stylesheet>
