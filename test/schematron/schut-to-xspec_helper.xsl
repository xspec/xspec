<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:helper="x-urn:test:schut-to-xspec_helper"
	xmlns:worker="x-urn:test:schut-to-xspec_helper:worker"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Test helper function 
	-->
	<xsl:function as="document-node()" name="helper:expect">
		<xsl:param as="document-node()" name="input-document" />

		<xsl:apply-templates mode="worker:expect" select="$input-document" />
	</xsl:function>

	<!--
		mode="worker:expect"
		This mode does the real job.
		
		Note:
		- Use a dedicated mode to avoid clashes with the test target stylesheet.
		- You can't use @on-no-match="shallow-copy". The test target stylesheet may have
		  xsl:template[@mode = '#all'].
	-->
	<xsl:mode name="worker:expect" on-multiple-match="fail" on-no-match="fail" />

	<!-- Identity template -->
	<xsl:template as="node()" match="attribute() | document-node() | node()" mode="worker:expect">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute() | node()" />
		</xsl:copy>
	</xsl:template>

	<!-- Discard whitespace-only text nodes -->
	<xsl:template as="empty-sequence()" match="text()[normalize-space() => not()]"
		mode="worker:expect" />

	<!-- Resolve "%TEST_BASE%/" in URI -->
	<xsl:template as="attribute()"
		match="
			x:context/@href |
			x:description/@original-xspec |
			x:description/@schematron |
			x:scenario/@xspec"
		mode="worker:expect">
		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="replace(., '%TEST_BASE%/', resolve-uri('../'))" />
	</xsl:template>

</xsl:stylesheet>
