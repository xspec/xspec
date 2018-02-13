<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:deserializer="x-urn:xspec:test:end-to-end:processor:deserializer"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:saxon="http://saxon.sf.net/"
	xmlns:serializer="x-urn:xspec:test:end-to-end:processor:serializer"
	xmlns:util="x-urn:xspec:test:end-to-end:processor:util"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This master stylesheet normalizes the input document and compares the normalized document with the expected HTML file.
			Note: Comparison is performed by fn:deep-equal() which may ignore some comments and processing instructions.
	-->

	<xsl:include href="_deserializer.xsl" />
	<xsl:include href="_normalizer.xsl" />
	<xsl:include href="_serializer.xsl" />
	<xsl:include href="_util.xsl" />

	<xsl:output method="text" />

	<!--
		URI of the expected HTML file
			Its content must be already normalized by the 'normalizer:normalize' template.
	-->
	<xsl:param as="xs:anyURI" name="EXPECTED-HTML"
		select="
			resolve-uri(
			concat('../expected/', util:filename-without-extension(base-uri()), '-norm.html'),
			base-uri())" />

	<xsl:param as="xs:boolean" name="DEBUG" select="false()" />

	<xsl:template as="text()+" match="document-node()">
		<!-- Load the expected HTML -->
		<xsl:variable as="document-node()" name="expected-doc"
			select="deserializer:unindent(doc($EXPECTED-HTML))" />

		<!-- Normalize the input document -->
		<xsl:variable as="document-node()" name="input-doc" select="deserializer:unindent(.)" />
		<xsl:variable as="document-node()" name="normalized-input-doc"
			select="normalizer:normalize($input-doc)" />

		<!-- Compare the normalized input document with the expected document -->
		<xsl:variable as="xs:boolean" name="comparison-result"
			select="deep-equal($normalized-input-doc, $expected-doc)" />

		<!-- Diagnostic output -->
		<xsl:if test="not($comparison-result) or $DEBUG">
			<!-- Save the normalized input document -->
			<xsl:variable as="xs:anyURI" name="normalized-input-html"
				select="
					resolve-uri(
					concat(util:filename-without-extension(base-uri()), '-norm.html'),
					base-uri())" />
			<xsl:result-document format="serializer:output" href="{$normalized-input-html}">
				<xsl:sequence select="$normalized-input-doc" />
			</xsl:result-document>
			<xsl:message select="'Saved the normalized input:', $normalized-input-html" />

			<!-- Print the documents -->
			<xsl:message select="'[NORMALIZED INPUT]', $normalized-input-doc" />
			<xsl:message select="'[EXPECTED]', $expected-doc" />

			<!-- Print the diff by passing '?' flag to saxon:deep-equal()-->
			<xsl:if
				test="
					saxon:deep-equal($normalized-input-doc, $expected-doc, (), '?')
					ne $comparison-result"
				use-when="function-available('saxon:deep-equal') (: Requires Saxon-PE :)">
				<!-- Terminate if saxon:deep-equal() contradicts the comparison result -->
				<xsl:message terminate="yes" />
			</xsl:if>
		</xsl:if>

		<!-- Output the comparison result -->
		<xsl:value-of select="
				if ($comparison-result) then
					'OK'
				else
					'FAILED'" />
		<xsl:text>: Compared </xsl:text>
		<xsl:value-of select="base-uri()" />
		<xsl:text> with </xsl:text>
		<xsl:value-of select="$EXPECTED-HTML" />
		<xsl:text>&#x0A;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
