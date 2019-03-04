<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.jenitennison.com/xslt/xspec">

	<!--
		This stylesheet module helps normalize the test result XML.
	-->

	<!--
		Normalizes xml-stylesheet processing instruction
			Example:
				in:  <?xml-stylesheet type="text/xsl" href="file:/path/to/format-xspec-report.xsl"?>
				out: <?xml-stylesheet type="text/xsl" href="../path/to/format-xspec-report.xsl"?>
	-->
	<xsl:template as="processing-instruction()" match="/processing-instruction(xml-stylesheet)"
		mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:variable as="xs:string" name="regex">
			<xsl:text>^(type="text/xsl" href=")(.+)(")$</xsl:text>
		</xsl:variable>

		<xsl:variable as="xs:string" name="value">
			<xsl:analyze-string regex="{$regex}" select=".">
				<xsl:matching-substring>
					<xsl:sequence
						select="
							concat(
							regex-group(1),
							normalizer:relative-uri(regex-group(2), $tunnel_document-uri),
							regex-group(3)
							)"
					 />
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:variable>

		<xsl:processing-instruction name="{name()}" select="$value" />
	</xsl:template>

	<!--
		Normalizes datetime
			Example:
				in:  <x:report date="2018-08-12T20:59:49.509+09:00">
				out: <x:report date="ONCE-UPON-A-TIME">
	-->
	<xsl:template as="attribute(date)" match="/report/@date" mode="normalizer:normalize">
		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="'ONCE-UPON-A-TIME'" />
	</xsl:template>

	<!--
		Normalizes the link to the files
			Example:
				in   <x:report xspec="file:/path/to/test.xspec">
				out: <x:report xspec="../path/to/test.xspec">
	-->
	<xsl:template as="attribute()"
		match="
			/report/attribute()[name() = ('query-at', 'schematron', 'stylesheet', 'xspec')]
			| scenario/call/param/@href
			| scenario/context/@href
			| /report[@schematron]//scenario/result/svrl:schematron-output/svrl:active-pattern/@document"
		mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="normalizer:relative-uri(., $tunnel_document-uri)" />
	</xsl:template>

</xsl:stylesheet>
