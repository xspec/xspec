<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dsdl="http://www.schematron.com/namespace/dsdl"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:import href="../../src/schematron/iso-schematron/iso_dsdl_include.xsl" />

    <xsl:template match="sch:include[@href eq 'hook-me']" as="element(sch:pattern)" mode="dsdl:go">
        <sch:pattern is-a="hook-me" />
    </xsl:template>
</xsl:stylesheet>
