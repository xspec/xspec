<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:issue-1564="x-urn:test:issue-1564" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:param as="xs:string" name="issue-1564:g" select="'global default value'" />

	<!--
		Returns global parameter value. Function parameter is not used at all.
	-->
	<xsl:function as="xs:string" name="issue-1564:get-g" visibility="final">
		<xsl:param as="xs:string" name="unused" />

		<xsl:sequence select="$issue-1564:g" />
	</xsl:function>

	<!--
		Returns global parameter value.
	-->
	<xsl:template as="xs:string" match="get-g" name="get-g">
		<xsl:sequence select="$issue-1564:g" />
	</xsl:template>

</xsl:stylesheet>
