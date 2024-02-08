<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="global-override.xsl" />

	<!--
		Scenario-level x:param (non-empty) versus
	-->

	<!-- xsl:param -->
	<xsl:param as="xs:string" name="scenario-x-param_vs_xsl-param"
		select="'xsl:param not affected by scenario-level x:param'" />
	<xsl:template as="xs:string" match=".[. eq 'scenario-x-param_vs_xsl-param']">
		<xsl:sequence select="$scenario-x-param_vs_xsl-param" />
	</xsl:template>

	<!-- xsl:variable -->
	<xsl:variable as="xs:string" name="scenario-x-param_vs_xsl-variable"
		select="'xsl:variable not affected by scenario-level x:param'" />
	<xsl:template as="xs:string" match=".[. eq 'scenario-x-param_vs_xsl-variable']">
		<xsl:sequence select="$scenario-x-param_vs_xsl-variable" />
	</xsl:template>

	<!-- No XSLT parameter or variable -->
	<xsl:template as="empty-sequence()" match=".[. eq 'scenario-x-param_vs_none']" />

	<!--
		Scenario-level x:param (empty) versus
	-->

	<!-- xsl:param -->
	<xsl:param as="xs:string?" name="scenario-x-param-empty_vs_xsl-param"
		select="'xsl:param not affected by empty scenario-level x:param'" />
	<xsl:template as="xs:string?" match=".[. eq 'scenario-x-param-empty_vs_xsl-param']">
		<xsl:sequence select="$scenario-x-param-empty_vs_xsl-param" />
	</xsl:template>

	<!-- xsl:variable -->
	<xsl:variable as="xs:string" name="scenario-x-param-empty_vs_xsl-variable"
		select="'xsl:variable not affected by empty scenario-level x:param'" />
	<xsl:template as="xs:string" match=".[. eq 'scenario-x-param-empty_vs_xsl-variable']">
		<xsl:sequence select="$scenario-x-param-empty_vs_xsl-variable" />
	</xsl:template>

</xsl:stylesheet>
