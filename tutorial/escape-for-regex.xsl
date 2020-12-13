<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all" version="3.0">

    <!-- The functx:escape-for-regex function escapes a string that you wish to be taken 
         literally rather than treated like a regular expression. This is useful when, 
         for example, you are calling the built-in fn:replace function and you want any 
         periods or parentheses to be treated like literal characters rather than regex 
         special characters. 
         From: http://www.xsltfunctions.com/xsl/functx_escape-for-regex.html
    -->
    <xsl:function name="functx:escape-for-regex" as="xs:string">
        <xsl:param name="arg" as="xs:string?"/>

        <xsl:sequence
            select=" 
            replace($arg,
            '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
            "
        />
    </xsl:function>


    <!-- Escape regexes in a list of phrases -->

    <xsl:mode on-no-match="shallow-copy" on-multiple-match="fail" />

    <xsl:template match="phrase" as="element(phrase)">
        <xsl:variable name="escaped-text" as="xs:string" select="functx:escape-for-regex(.)" />
        <xsl:copy>
            <xsl:attribute name="status" select="if (. = $escaped-text) then 'changed' else 'same'" />
            <xsl:value-of select="$escaped-text" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
