<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.w3.org/1999/xhtml">

	<!--
		This stylesheet module helps normalize the coverage report HTML.
	-->

	<!--
		Normalizes the title text
			Example:
				in:  <title>Test Report for /path/to/tested.xsl</title>
				out: <title>Test Report for tested.xsl</title>
	-->
	<xsl:template as="text()" match="/html/head/title/text()" mode="normalizer:normalize">
		<xsl:analyze-string regex="^(Test Coverage Report for) (\S+)$" select=".">
			<xsl:matching-substring>
				<xsl:value-of
					select="
						regex-group(1),
						x:filename-and-extension(regex-group(2))"
				 />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<!--
		Replaces the embedded CSS with the link to its source
			For brevity. The details of style are not critical anyway.
	-->
	<xsl:template as="element(link)+" match="/html/head/style" mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:for-each select="('test-report-colors-classic.css', 'test-report.css')">
			<!-- Absolute URI of CSS -->
			<xsl:variable as="xs:anyURI" name="css-uri"
				select="resolve-uri(concat('../../../../src/reporter/', .))" />
			
			<link rel="stylesheet" type="text/css" xmlns="http://www.w3.org/1999/xhtml">
				<xsl:attribute name="href"
					select="normalizer:relative-uri($css-uri, $tunnel_document-uri)" />
			</link>			
		</xsl:for-each>
	</xsl:template>

	<!--
		Normalizes the links to the tested module
			Example:
				in:  <a href="file:/path/to/tested.xsl">/path/to/tested.xsl</a>
				out: <a href="../path/to/tested.xsl">tested.xsl</a>
	-->
	<xsl:template as="element(a)" match="/html/body/p[1]/a" mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute()" />
			<xsl:for-each select="@href">
				<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
					select="normalizer:relative-uri(., $tunnel_document-uri)" />
			</xsl:for-each>

			<xsl:value-of select="x:filename-and-extension(.)" />
		</xsl:copy>
	</xsl:template>

	<!--
		Normalizes the header for module
			Example:
				in:  <h2>module: file:/path/to/module.xsl; 25 lines</h2>
				out: <h2>module: module.xsl; 25 lines</h2>
	-->
	<xsl:template as="text()" match="/html/body/h2/text()" mode="normalizer:normalize">
		<xsl:variable as="xs:string" name="regex" xml:space="preserve">
			^
				(module:[ ])		<!-- group 1 -->
				(\S+)				<!-- group 2 -->
				(;)					<!-- group 3 -->
				(?:\n[ ]+)?
				([ ][1-9][0-9]*)	<!-- group 4 -->
				(?:\n[ ]+)?
				([ ]lines)			<!-- group 5 -->
			$
		</xsl:variable>
		<xsl:analyze-string flags="x" regex="{$regex}" select=".">
			<xsl:matching-substring>
				<xsl:value-of
					select="
						regex-group(1),
						x:filename-and-extension(regex-group(2)),
						regex-group(3),
						regex-group(4),
						regex-group(5)"
					separator="" />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>
</xsl:stylesheet>
