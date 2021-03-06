<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Catches any item in any mode with highest priority -->
	<xsl:mode on-multiple-match="fail" on-no-match="fail" />
	<xsl:template as="xs:string" match="." mode="#all" priority="999999999999999999">
		<xsl:sequence select="'Caught by #all mode'" />
	</xsl:template>

	<xsl:template as="xs:string" name="named-template">
		<xsl:context-item use="absent" />
		<xsl:sequence select="'Returned from named template'" />
	</xsl:template>

</xsl:stylesheet>
