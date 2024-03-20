<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xpath-default-namespace="http://docbook.org/ns/docbook"
    version="3.0">

    <!--
        Default element namespace is for XHTML.
        Default XPath namespace is for DocBook.
        XLink namespace is also in use.
    -->

    <xsl:template match="link">  <!-- Matches DocBook 'link' -->
        <a href="{@xlink:href}"> <!-- Produces XHTML 'a' -->
            <xsl:apply-templates/>
        </a>
    </xsl:template>

</xsl:stylesheet>