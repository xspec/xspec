<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Identity template
	-->
	<xsl:template as="node()" match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>

	<!--
		Makes <iron> into <sword>
			This template will be overridden.
	-->
	<xsl:template as="element(sword)" match="iron">
		<sword>
			<xsl:apply-templates select="@* | node()" />
		</sword>
	</xsl:template>

</xsl:stylesheet>
