<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:s="x-urn:test:step-using-xslt" version="3.1"
    type="s:file-string-value">
    <p:option name="href"
        select="'catalog-01:/ws-only-text.xml?strip-space=yes;xinclude=yes'"/>
    <p:output port="xproc-result"/>
    <p:xslt>
        <p:with-input port="source">
            <input/>
        </p:with-input>
        <p:with-input port="stylesheet">
            <xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
                <xsl:param name="href"/>
                <xsl:template match=".">
                    <xsl:sequence select="doc($href)"/>
                </xsl:template>
            </xsl:stylesheet>
        </p:with-input>
        <p:with-option name="parameters" select="map{'href': $href}"/>
    </p:xslt>
    <p:filter select="normalize-space()"/>
</p:declare-step>
