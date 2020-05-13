<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:import href="../../src/schematron/iso-schematron/iso_abstract_expand.xsl" />

    <xsl:include href="../../src/common/xspec-utils.xsl" />

    <xsl:template match="/">
        <xsl:message>I am <xsl:value-of select="x:filename-and-extension(static-base-uri())" />!</xsl:message>
        <xsl:apply-imports />
    </xsl:template>
</xsl:stylesheet>
