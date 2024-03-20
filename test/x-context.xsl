<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:mode on-no-match="shallow-skip" />
	<xsl:mode name="template-mode" on-no-match="shallow-skip" />

	<xsl:template as="empty-sequence()" name="null">
		<xsl:context-item use="absent" />
	</xsl:template>

	<xsl:template as="item()*" name="template-with-param">
		<xsl:context-item use="absent" />
		<xsl:param name="param" as="item()*"/>
		<xsl:sequence select="$param" />
	</xsl:template>
</xsl:stylesheet>
