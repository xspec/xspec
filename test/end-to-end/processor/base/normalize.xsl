<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:deserializer="x-urn:xspec:test:end-to-end:processor:deserializer"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:serializer="x-urn:xspec:test:end-to-end:processor:serializer"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This master stylesheet is a basis for normalizing various reports.
		
		The processor must import this stylesheet and provide its own deserializer, normalizer and serializer.
	-->

	<xsl:include href="../../../../src/common/xspec-utils.xsl" />
	<xsl:include href="_deserializer.xsl" />
	<xsl:include href="_normalizer.xsl" />
	<xsl:include href="_serializer.xsl" />

	<xsl:template as="empty-sequence()" match="document-node()">
		<!-- Absolute URI of input document -->
		<xsl:variable as="xs:anyURI" name="input-doc-uri" select="document-uri(/)" />

		<xsl:message select="' Normalizing:', $input-doc-uri" />

		<xsl:variable as="document-node()" name="input-doc">
			<xsl:apply-templates mode="deserializer:unindent" select="." />
		</xsl:variable>

		<xsl:result-document format="serializer:output">
			<xsl:apply-templates mode="normalizer:normalize" select="$input-doc">
				<xsl:with-param name="tunnel_document-uri" select="$input-doc-uri" tunnel="yes" />
			</xsl:apply-templates>
		</xsl:result-document>
	</xsl:template>
</xsl:stylesheet>
