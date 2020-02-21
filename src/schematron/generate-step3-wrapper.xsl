<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns="http://www.w3.org/1999/XSL/TransformAlias"
	xmlns:test="http://www.jenitennison.com/xslt/unit-test"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This master stylesheet generates a wrapper stylesheet which imports the actual stylesheet
		of the Schematron Step 3 preprocessor.
		While generating the wrapper stylesheet, the following adjustments are made:
			* Transforms /x:description/x:param into /xsl:stylesheet/xsl:param.
			* Imports the private patch (only for the built-in preprocessor).
	-->

	<!-- Absolute URI of the actual stylesheet of the Schematron Step 3 preprocessor.
		Zero-length string is ignored. -->
	<xsl:param as="xs:string?" name="ACTUAL-PREPROCESSOR-URI" />

	<xsl:include href="../common/xspec-utils.xsl" />
	<xsl:include href="../compiler/generate-tests-helper.xsl" />

	<xsl:output indent="yes" />

	<xsl:namespace-alias result-prefix="xsl" stylesheet-prefix="#default" />

	<xsl:template as="element(xsl:stylesheet)" match="x:description">
		<!-- Discard zero-length string -->
		<xsl:variable as="xs:string?" name="actual-preprocessor-uri"
			select="$ACTUAL-PREPROCESSOR-URI[.]" />

		<!-- Absolute URI of the stylesheet of the built-in Schematron Step 3 preprocessor -->
		<xsl:variable as="xs:anyURI" name="builtin-preprocessor-uri"
			select="resolve-uri('iso-schematron/iso_svrl_for_xslt2.xsl')" />

		<stylesheet exclude-result-prefixes="#all" version="{x:decimal-string(x:xslt-version(.))}">
			<!-- Namespaces required by the wrapper stylesheet being generated -->
			<xsl:namespace name="impl" select="'urn:x-xspec:compile:xslt:impl'" />
			<xsl:namespace name="xs" select="'http://www.w3.org/2001/XMLSchema'" />

			<!-- Import the stylesheet of the Schematron Step 3 preprocessor -->
			<import href="{($actual-preprocessor-uri, $builtin-preprocessor-uri)[1]}" />

			<!-- Import the private patch -->
			<xsl:if test="empty($actual-preprocessor-uri)">
				<import href="{resolve-uri('patch-step3.xsl')}" />
			</xsl:if>

			<!-- Set up a pseudo x:param which holds the fully-resolved Schematron file URI
				so that $x:schematron-uri holding the URI is generated and made available in
				the wrapper stylesheet being generated -->
			<xsl:variable as="element(x:param)" name="xml-base-param">
				<x:param as="xs:anyURI" name="x:schematron-uri">
					<xsl:value-of select="x:locate-schematron-uri(.)" />
				</x:param>
			</xsl:variable>

			<!-- Resolve x:param -->
			<xsl:apply-templates select="$xml-base-param, x:param" />
		</stylesheet>
	</xsl:template>

	<xsl:template as="element()+" match="x:param">
		<xsl:apply-templates mode="test:generate-variable-declarations" select="." />
	</xsl:template>
</xsl:stylesheet>
