<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:iae="http://www.schematron.com/namespace/iae"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:import href="../../lib/iso-schematron/iso_abstract_expand.xsl" />

    <xsl:template match="sch:pattern[@is-a eq 'hook-me']" as="element(sch:let)" mode="iae:go">
        <sch:let name="hook-me" />
    </xsl:template>
</xsl:stylesheet>
