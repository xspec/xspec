<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:param as="xs:string" name="global-param" select="'global param defined in SUT'" />

	<xsl:variable as="xs:string" name="global-variable" select="'global variable defined in SUT'" />

	<!-- Returns the global parameter intact -->
	<xsl:template as="xs:string" name="get-global-param">
		<xsl:sequence select="$global-param" />
	</xsl:template>

	<!-- Returns the global variable intact -->
	<xsl:template as="xs:string" name="get-global-variable">
		<xsl:sequence select="$global-variable" />
	</xsl:template>

	<!-- Returns the context item intact -->
	<xsl:template as="item()?" name="get-template-context">
		<xsl:sequence select="." />
	</xsl:template>

</xsl:stylesheet>
