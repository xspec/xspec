<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:mode name="upper-case-text" on-multiple-match="fail" on-no-match="shallow-copy" />
	<xsl:template as="text()" match="text()" mode="upper-case-text">
		<xsl:value-of select="upper-case(.)" />
	</xsl:template>

	<xsl:mode name="upper-case-attribute" on-multiple-match="fail" on-no-match="shallow-copy" />
	<xsl:template as="attribute()" match="attribute()" mode="upper-case-attribute">
		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}" select="upper-case(.)" />
	</xsl:template>

</xsl:stylesheet>
