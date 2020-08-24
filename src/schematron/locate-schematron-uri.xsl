<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Makes absolute URI from x:description/@schematron and resolves it with catalog
	-->
	<xsl:function as="xs:anyURI" name="x:locate-schematron-uri">
		<xsl:param as="element(x:description)" name="description" />

		<!-- Resolve with node base URI -->
		<xsl:variable as="xs:anyURI" name="schematron-uri"
			select="$description/@schematron/resolve-uri(., base-uri())" />

		<!-- Resolve with catalog -->
		<xsl:sequence select="x:resolve-xml-uri-with-catalog($schematron-uri)" />
	</xsl:function>

</xsl:stylesheet>
