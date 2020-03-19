<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:x="http://www.jenitennison.com/xslt/xspec"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.jenitennison.com/xslt/xspec">

	<!--
		This stylesheet module helps normalize the test result XML.
	-->

	<!--
		Normalizes the link to the files
			Example:
				in   <x:report xspec="file:/path/to/test.xspec">
				out: <x:report xspec="../path/to/test.xspec">
	-->
	<xsl:template as="attribute()"
		match="
			/report/attribute()[name() = ('query-at', 'schematron', 'xspec')]
			| /report[not(@schematron)]/@stylesheet
			| scenario/@xspec
			| scenario/call/param/@href
			| scenario/context/@href
			| /report[@schematron]//scenario/result/svrl:schematron-output/svrl:active-pattern/@document[string()]"
		mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="normalizer:relative-uri(., $tunnel_document-uri)" />
	</xsl:template>

	<!--
		Normalizes Schematron @stylesheet
			Schematron XSLT is created in the output dir. Only the file name (and extension) is predictable.
	-->
	<xsl:template as="attribute(stylesheet)" match="/report[@schematron]/@stylesheet"
		mode="normalizer:normalize">
		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="x:filename-and-extension(.)" />
	</xsl:template>

	<!-- Normalizes the link to the files created dynamically by XSpec -->
	<xsl:template as="attribute(href)"
		match="
			scenario/result/@href
			| scenario/test/expect/@href"
		mode="normalizer:normalize">
		<xsl:call-template name="normalizer:normalize-external-link-attribute" />
	</xsl:template>
</xsl:stylesheet>
