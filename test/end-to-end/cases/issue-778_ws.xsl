<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:output encoding="UTF-8" 
                method="text"/>

    <xsl:strip-space elements="*" />

    <xsl:template match="/" as="text()+">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/title ')]" as="text()+">
        <xsl:text># </xsl:text><xsl:value-of select="text()"/><xsl:text>&#xA;</xsl:text>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/shortdesc ')]" as="text()+">
        <xsl:text>&#xA;</xsl:text><xsl:value-of select="text()"/><xsl:text>&#xA;</xsl:text>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/p ')]" as="text()+">
        <xsl:text>&#xA;</xsl:text><xsl:value-of select="text()"/><xsl:text>&#xA;</xsl:text>
    </xsl:template> 

</xsl:stylesheet>