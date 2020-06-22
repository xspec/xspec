<?xml version="1.0" encoding="UTF-8"?>
<!--
	Based on
		3.13.2 Shadow Attributes
			https://www.w3.org/TR/xslt-30/#shadow-attributes
-->
<xsl:package name="http://example.org/filter.xsl" package-version="1.0" version="3.0"
	xmlns:f="http://example.org/filter.xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:param as="xs:string" name="filter" select="'true()'" static="yes" />

	<xsl:function as="xs:boolean" name="f:filter" visibility="public">
		<xsl:param as="element(employee)" name="e" />

		<xsl:sequence _select="$e/({$filter})" />
	</xsl:function>

</xsl:package>
