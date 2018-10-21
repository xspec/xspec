<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns="http://www.w3.org/1999/XSL/TransformAlias"
	xmlns:test="http://www.jenitennison.com/xslt/unit-test"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.jenitennison.com/xslt/xspec">

	<!-- This master stylesheet generates a wrapper XSLT which imports the actual XSLT file
		of the Schematron Step 3 preprocessor.
		While generating the wrapper XSLT, /x:description/x:param is transformed to
		/xsl:stylesheet/xsl:param. -->

	<!-- Absolute URI of the actual XSLT file of the Schematron Step 3 preprocessor.
		Zero-length string is ignored. -->
	<xsl:param as="xs:string?" name="ACTUAL-PREPROCESSOR-URI" />

	<xsl:include href="../common/xspec-utils.xsl" />
	<xsl:include href="../compiler/generate-tests-helper.xsl" />

	<xsl:output indent="yes" />

	<xsl:template as="element(xsl:stylesheet)" match="description">
		<!-- Discard zero-length string -->
		<xsl:variable as="xs:string?" name="actual-preprocessor-uri"
			select="$ACTUAL-PREPROCESSOR-URI[.]" />

		<!-- Absolute URI of the built-in XSLT file -->
		<xsl:variable as="xs:anyURI" name="builtin-preprocessor-uri"
			select="resolve-uri('iso-schematron/iso_svrl_for_xslt2.xsl')" />

		<stylesheet exclude-result-prefixes="#all" version="{(@xslt-version, 2.0)[1]}">
			<!-- Copy namespaces. /x:description/x:param may use them.
				This aligns with the XSpec implementation for XSLT, but probably the
				namespaces should be handled in finer granularity and copied in
				mode="test:generate-variable-declarations". -->
			<xsl:sequence select="x:copy-namespaces(.)" />

			<import href="{($actual-preprocessor-uri, $builtin-preprocessor-uri)[1]}" />
			<xsl:apply-templates select="param" />
		</stylesheet>
	</xsl:template>

	<xsl:template as="element()+" match="param">
		<xsl:apply-templates mode="test:generate-variable-declarations" select=".">
			<xsl:with-param name="var" select="@name" />
			<xsl:with-param name="type" select="'param'" />
		</xsl:apply-templates>
	</xsl:template>
</xsl:stylesheet>
