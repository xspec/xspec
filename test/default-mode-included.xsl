<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    default-mode="implicit-default-mode"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:template match="*" as="element(no-explicit-mode)">
        <no-explicit-mode/>
    </xsl:template>
    
    <xsl:template match="*" as="element(unnamed-mode)"
        mode="#unnamed" name="unnamed-mode-template">
        <unnamed-mode/>
    </xsl:template>

</xsl:stylesheet>