<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.w3.org/1999/xhtml">

	<xsl:param as="xs:string" name="STYLE-CONTAINS" select="'margin-right:'" />

	<xsl:output method="text" />

	<xsl:template as="text()" match="/">
		<xsl:value-of>
			<xsl:value-of
				select="/html/head[not(link[@type = 'text/css'])]/style[@type = 'text/css']/contains(., $STYLE-CONTAINS)" />
			<xsl:text>&#x0A;</xsl:text>
		</xsl:value-of>
	</xsl:template>
</xsl:stylesheet>
