<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dsdl="http://www.schematron.com/namespace/dsdl"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="3.0">

    <xsl:include href="../../src/schematron/preprocessor.xsl" />

    <xsl:import _href="{$x:schematron-preprocessor?stylesheets?1}" />

    <!--
        Check
    -->
    <xsl:template match="sch:pattern[@is-a eq 'hook-me']" as="empty-sequence()" mode="#all">
        <xsl:message select="name(), 'already exists'" terminate="yes" />
    </xsl:template>

    <!--
        Hook
    -->
    <xsl:template match="sch:include[@href eq 'hook-me']" as="element(sch:pattern)" _mode="
            {
                'schxslt:include'[$x:schematron-preprocessor?name eq 'schxslt'],
                'dsdl:go'[$x:schematron-preprocessor?name eq 'skeleton']
            }">
        <sch:pattern is-a="hook-me" />
    </xsl:template>

</xsl:stylesheet>
