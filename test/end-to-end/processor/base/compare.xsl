<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:deserializer="x-urn:xspec:test:end-to-end:processor:deserializer"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:saxon="http://saxon.sf.net/"
	xmlns:serializer="x-urn:xspec:test:end-to-end:processor:serializer"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This master stylesheet is a basis for comparing the input document with the expected file.
			* Before comparing, the input document is normalized.
			* Comparison is performed by fn:deep-equal() which may ignore some comments and processing instructions.
		
		The processor must import this stylesheet and provide its own deserializer, normalizer and serializer.
	-->

	<xsl:include href="../../../../src/common/xspec-utils.xsl" />
	<xsl:include href="_deserializer.xsl" />
	<xsl:include href="_normalizer.xsl" />
	<xsl:include href="_serializer.xsl" />

	<xsl:output method="text" />

	<!--
		URI of the expected result file
			Its content must be already normalized by the 'normalizer:normalize' template.
	-->
	<xsl:param as="xs:anyURI" name="EXPECTED-RESULT-URI"
		select="
			resolve-uri(
			concat('../expected/', x:filename-without-extension(document-uri(/)), '-norm.',
			if (/testsuites) then
				'xml'
			else
				'html'),
			document-uri(/))" />

	<xsl:param as="xs:boolean" name="DEBUG" select="false()" />

	<xsl:template as="text()+" match="document-node()">
		<!-- Load the expected result -->
		<xsl:variable as="document-node()" name="expected-doc">
			<xsl:apply-templates mode="deserializer:unindent" select="doc($EXPECTED-RESULT-URI)" />
		</xsl:variable>

		<!-- Normalize the input document -->
		<xsl:variable as="document-node()" name="input-doc">
			<xsl:apply-templates mode="deserializer:unindent" select="." />
		</xsl:variable>
		<xsl:variable as="document-node()" name="normalized-input-doc">
			<xsl:apply-templates mode="normalizer:normalize" select="$input-doc" />
		</xsl:variable>

		<!-- Compare the normalized input document with the expected document -->
		<xsl:variable as="xs:boolean" name="comparison-result"
			select="deep-equal($normalized-input-doc, $expected-doc)" />

		<!-- Diagnostic output -->
		<xsl:if test="not($comparison-result) or $DEBUG">
			<!-- Save the normalized input document -->
			<xsl:variable as="xs:anyURI" name="save-normalized-input-uri"
				select="
					resolve-uri(
					concat(x:filename-without-extension(document-uri(.)), '-norm.html'),
					document-uri(.))" />
			<xsl:result-document format="serializer:output" href="{$save-normalized-input-uri}">
				<xsl:sequence select="$normalized-input-doc" />
			</xsl:result-document>
			<xsl:message select="'Saved the normalized input:', $save-normalized-input-uri" />

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
		<xsl:value-of select="document-uri(.)" />
		<xsl:text> with </xsl:text>
		<xsl:value-of select="$EXPECTED-RESULT-URI" />
		<xsl:text>&#x0A;</xsl:text>
	</xsl:template>
</xsl:stylesheet>
