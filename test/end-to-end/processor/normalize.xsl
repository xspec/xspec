<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet normalizes the input document.
	-->

	<xsl:include href="_normalizer.xsl" />
	<xsl:include href="_util.xsl" />

	<xsl:template as="empty-sequence()" match="document-node()">
		<xsl:message select="'Normalizing', base-uri()" />

		<xsl:result-document format="normalizer:output">
			<xsl:call-template name="normalizer:normalize" />
		</xsl:result-document>

		<xsl:message select="'Normalized'" />
	</xsl:template>
</xsl:stylesheet>
