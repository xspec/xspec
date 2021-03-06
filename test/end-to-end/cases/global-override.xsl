<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Global xsl:param
	-->
	<xsl:param as="xs:string" name="x-param-vs-xsl-param"
		select="'xsl:param not affected by x:param'" />
	<xsl:param as="xs:string" name="x-variable-vs-xsl-param"
		select="'xsl:param not affected by x:variable'" />

	<xsl:template as="xs:string" name="x-param-vs-xsl-param">
		<xsl:context-item use="absent" />
		<xsl:sequence select="$x-param-vs-xsl-param" />
	</xsl:template>
	<xsl:template as="xs:string" name="x-variable-vs-xsl-param">
		<xsl:context-item use="absent" />
		<xsl:sequence select="$x-variable-vs-xsl-param" />
	</xsl:template>

	<!--
		Global xsl:variable
	-->
	<xsl:variable as="xs:string" name="x-variable-vs-xsl-variable"
		select="'xsl:variable not affected by x:variable'" />
	<xsl:variable as="xs:string" name="x-param-vs-xsl-variable"
		select="'xsl:variable not affected by x:param'" />

	<xsl:template as="xs:string" name="x-variable-vs-xsl-variable">
		<xsl:context-item use="absent" />
		<xsl:sequence select="$x-variable-vs-xsl-variable" />
	</xsl:template>
	<xsl:template as="xs:string" name="x-param-vs-xsl-variable">
		<xsl:context-item use="absent" />
		<xsl:sequence select="$x-param-vs-xsl-variable" />
	</xsl:template>

</xsl:stylesheet>
