<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:util="x-urn:xspec:test:end-to-end:processor:util"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet normalizes the input document and compares the normalized document with the expected HTML file.
			Note: Comparison is performed by fn:deep-equal() which may ignore some comments and procesing instructions.
	-->

	<xsl:include href="_normalizer.xsl" />
	<xsl:include href="_util.xsl" />

	<xsl:output method="text" />

	<xsl:param as="xs:anyURI" name="EXPECTED-HTML"
		select="
			resolve-uri(
			concat('../expected/', util:filename-without-extension(base-uri()), '-norm.html'),
			base-uri())" />

	<xsl:template as="text()+" match="document-node()">
		<xsl:variable as="document-node()" name="expected-doc" select="doc($EXPECTED-HTML)" />

		<xsl:variable as="document-node()" name="normalized-input-doc">
			<xsl:call-template name="normalizer:normalize" />
		</xsl:variable>

		<xsl:variable as="xs:boolean" name="comparison-result"
			select="deep-equal($normalized-input-doc, $expected-doc)" />

		<xsl:value-of select="
				if ($comparison-result) then
					'OK'
				else
					'FAILED'" />
		<xsl:text>: Compared </xsl:text>
		<xsl:value-of select="base-uri()" />
		<xsl:text> with </xsl:text>
		<xsl:value-of select="base-uri($expected-doc)" />
		<xsl:text>&#x0A;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
