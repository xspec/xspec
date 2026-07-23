<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:global-context-item use="absent" />

	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<!--
		Global x:param (non-empty) versus
	-->

	<!-- xsl:param -->
	<xsl:param as="xs:string" name="global-x-param_vs_xsl-param"
		select="'xsl:param not affected by global x:param'" />
	<xsl:template as="xs:string" match=".[. eq 'global-x-param_vs_xsl-param']">
		<xsl:sequence select="$global-x-param_vs_xsl-param" />
	</xsl:template>

	<!-- xsl:variable -->
	<xsl:variable as="xs:string" name="global-x-param_vs_xsl-variable"
		select="'xsl:variable not affected by global x:param'" />
	<xsl:template as="xs:string" match=".[. eq 'global-x-param_vs_xsl-variable']">
		<xsl:sequence select="$global-x-param_vs_xsl-variable" />
	</xsl:template>

	<!-- No XSLT parameter or variable -->
	<xsl:template as="empty-sequence()" match=".[. eq 'global-x-param_vs_none']" />

	<!--
		Global x:param (empty) versus
	-->

	<!-- xsl:param -->
	<xsl:param as="xs:string?" name="global-x-param-empty_vs_xsl-param"
		select="'xsl:param not affected by empty global x:param'" />
	<xsl:template as="xs:string?" match=".[. eq 'global-x-param-empty_vs_xsl-param']">
		<xsl:sequence select="$global-x-param-empty_vs_xsl-param" />
	</xsl:template>

	<!-- xsl:variable -->
	<xsl:variable as="xs:string" name="global-x-param-empty_vs_xsl-variable"
		select="'xsl:variable not affected by empty global x:param'" />
	<xsl:template as="xs:string?" match=".[. eq 'global-x-param-empty_vs_xsl-variable']">
		<xsl:sequence select="$global-x-param-empty_vs_xsl-variable" />
	</xsl:template>

	<!--
		Global x:variable (non-empty) versus
	-->

	<!-- xsl:param -->
	<xsl:param as="xs:string" name="global-x-variable_vs_xsl-param"
		select="'xsl:param not affected by global x:variable'" />
	<xsl:template as="xs:string" match=".[. eq 'global-x-variable_vs_xsl-param']">
		<xsl:sequence select="$global-x-variable_vs_xsl-param" />
	</xsl:template>

	<xsl:variable as="xs:string" name="global-x-variable_vs_xsl-variable"
		select="'xsl:variable not affected by global x:variable'" />
	<xsl:template as="xs:string" match=".[. eq 'global-x-variable_vs_xsl-variable']">
		<xsl:sequence select="$global-x-variable_vs_xsl-variable" />
	</xsl:template>

	<!--
		Global x:variable (empty) versus
	-->

	<!-- xsl:param -->
	<xsl:param as="xs:string" name="global-x-variable-empty_vs_xsl-param"
		select="'xsl:param not affected by empty global x:variable'" />
	<xsl:template as="xs:string?" match=".[. eq 'global-x-variable-empty_vs_xsl-param']">
		<xsl:sequence select="$global-x-variable-empty_vs_xsl-param" />
	</xsl:template>

	<xsl:variable as="xs:string" name="global-x-variable-empty_vs_xsl-variable"
		select="'xsl:variable not affected by empty global x:variable'" />
	<xsl:template as="xs:string?" match=".[. eq 'global-x-variable-empty_vs_xsl-variable']">
		<xsl:sequence select="$global-x-variable-empty_vs_xsl-variable" />
	</xsl:template>

	<!--
		Scenario-level x:variable (non-empty) versus
	-->

	<!-- xsl:param -->
	<xsl:param as="xs:string" name="scenario-x-variable_vs_xsl-param"
		select="'xsl:param not affected by scenario-level x:variable'" />
	<xsl:template as="xs:string" match=".[. eq 'scenario-x-variable_vs_xsl-param']">
		<xsl:sequence select="$scenario-x-variable_vs_xsl-param" />
	</xsl:template>

	<!-- xsl:variable -->
	<xsl:variable as="xs:string" name="scenario-x-variable_vs_xsl-variable"
		select="'xsl:variable not affected by scenario-level x:variable'" />
	<xsl:template as="xs:string" match=".[. eq 'scenario-x-variable_vs_xsl-variable']">
		<xsl:sequence select="$scenario-x-variable_vs_xsl-variable" />
	</xsl:template>

	<!--
		Scenario-level x:variable (empty) versus
	-->

	<!-- xsl:param -->
	<xsl:param as="xs:string" name="scenario-x-variable-empty_vs_xsl-param"
		select="'xsl:param not affected by empty scenario-level x:variable'" />
	<xsl:template as="xs:string" match=".[. eq 'scenario-x-variable-empty_vs_xsl-param']">
		<xsl:sequence select="$scenario-x-variable-empty_vs_xsl-param" />
	</xsl:template>

	<!-- xsl:variable -->
	<xsl:variable as="xs:string" name="scenario-x-variable-empty_vs_xsl-variable"
		select="'xsl:variable not affected by empty scenario-level x:variable'" />
	<xsl:template as="xs:string" match=".[. eq 'scenario-x-variable-empty_vs_xsl-variable']">
		<xsl:sequence select="$scenario-x-variable-empty_vs_xsl-variable" />
	</xsl:template>

</xsl:stylesheet>
