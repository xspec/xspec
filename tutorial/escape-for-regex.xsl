<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:er="x-urn:tutorial:xslt-tutorial" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all" version="3.0">

    <!--
        The er:escape-for-regex function escapes regex special characters that
        you want the fn:replace function to interpret literally.
        Inspired by https://www.datypic.com/xsl/functx_escape-for-regex.html
    -->
    <xsl:function name="er:escape-for-regex" as="xs:string">
        <xsl:param name="arg" as="xs:string?" />

        <xsl:variable name="escaped-chars" as="xs:string+" select="
                ('.', '[', ']', '\', '|', '-', '^', '$', '?', '*', '+', '{', '}',
                '(', ')') ! concat('\', .)" />
        <xsl:variable name="pattern" as="xs:string"
            select="concat('(', string-join($escaped-chars, '|'), ')')" />
        <xsl:sequence select="replace($arg, $pattern, '\\$1')" />
    </xsl:function>


    <!-- Escape regexes in a list of phrases -->

    <xsl:mode on-no-match="shallow-copy" on-multiple-match="fail" />

    <xsl:template match="phrase" as="element(phrase)">
        <xsl:variable name="escaped-text" as="xs:string" select="er:escape-for-regex(.)" />
        <xsl:copy>
            <xsl:attribute name="status" select="if (. = $escaped-text) then 'changed' else 'same'" />
            <xsl:value-of select="$escaped-text" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
