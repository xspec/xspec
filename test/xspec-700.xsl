<?xml version="1.0"?>
<xsl:transform
    exclude-result-prefixes="html"
    version="2.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
>
    <xsl:template match="/">
        <xsl:for-each select="//abbr[not(@title)]">
            <xsl:choose>
                <xsl:when test="//abbr[@title]/. = current()/."/>
                <xsl:when test="(document('xspec-700.xml') treat as document-node(element(test)))//abbr[. = current()/.]"/>
                <xsl:otherwise>
                    <xsl:message terminate="yes">
                        <xsl:value-of select="base-uri(.)"/>
                        <xsl:text>: error: Abbreviations without title:</xsl:text>
                            <xsl:for-each select="//abbr[not(@title)]">
                                <xsl:choose>
                                    <xsl:when test="//abbr[@title]/. = current()/."/>
                                    <xsl:when test="(document('xspec-700.xml') treat as document-node(element(test)))//abbr[. = current()/.]"/>
                                    <xsl:otherwise><xsl:text> </xsl:text><xsl:value-of select="."/></xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

</xsl:transform>