<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="../common/xspec-utils.xsl" />

	<xsl:output method="text" />

	<!--
		Makes an absolute URI from @schematron and resolves it with catalog.
	-->
	<xsl:template as="text()" match="document-node()">
		<!-- Resolve with node base URI -->
		<xsl:variable as="xs:anyURI" name="schematron-uri"
			select="/x:description/@schematron/resolve-uri(., base-uri())" />

		<!-- Resolve with catalog -->
		<xsl:value-of select="x:resolve-xml-uri-with-catalog($schematron-uri)" />
	</xsl:template>
</xsl:stylesheet>
