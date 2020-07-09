<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="demo-imported.xsl" />

	<!--
		Makes <iron> into <shield>
			This template overrides an imported template.
	-->
	<xsl:template as="element(shield)" match="iron">
		<shield>
			<xsl:apply-templates select="@* | node()" />
		</shield>
	</xsl:template>

	<!--
		Makes <iron> into <gold>
			Only in alchemy mode.
	-->
	<xsl:mode name="alchemy" on-multiple-match="fail" on-no-match="fail" />
	<xsl:template as="element(gold)" match="iron" mode="alchemy">
		<gold>
			<xsl:apply-templates select="@* | node()" />
		</gold>
	</xsl:template>

</xsl:stylesheet>
