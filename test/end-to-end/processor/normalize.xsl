<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:deserializer="x-urn:xspec:test:end-to-end:processor:deserializer"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:serializer="x-urn:xspec:test:end-to-end:processor:serializer"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This master stylesheet normalizes the input document.
	-->

	<xsl:include href="_deserializer.xsl" />
	<xsl:include href="_normalizer.xsl" />
	<xsl:include href="_serializer.xsl" />
	<xsl:include href="_util.xsl" />

	<xsl:template as="empty-sequence()" match="document-node()">
		<xsl:message select="'Normalizing', base-uri()" />

		<xsl:variable as="document-node()" name="input-doc" select="deserializer:unindent(.)" />

		<xsl:result-document format="serializer:output">
			<xsl:sequence select="normalizer:normalize($input-doc)" />
		</xsl:result-document>

		<xsl:message select="'Normalized'" />
	</xsl:template>
</xsl:stylesheet>
