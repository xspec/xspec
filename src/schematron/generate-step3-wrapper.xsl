<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
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
		Empty sequence means the built-in preprocessor. -->
	<xsl:param as="xs:string?" name="ACTUAL-PREPROCESSOR-URI" />

	<xsl:include href="../common/xspec-utils.xsl" />
	<xsl:include href="../compiler/generate-tests-helper.xsl" />

	<xsl:output indent="yes" />

	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="element(xsl:stylesheet)" match="document-node(element(x:description))">
		<xsl:apply-templates select="x:description" />
	</xsl:template>

	<xsl:template as="element(xsl:stylesheet)" match="x:description">
		<!-- Absolute URI of the stylesheet of the built-in Schematron Step 3 preprocessor -->
		<xsl:variable as="xs:anyURI" name="builtin-preprocessor-uri"
			select="resolve-uri('../../lib/iso-schematron/iso_svrl_for_xslt2.xsl')" />

		<xsl:element name="xsl:stylesheet" namespace="{$x:xsl-namespace}">
			<xsl:attribute name="exclude-result-prefixes" select="'#all'" />
			<xsl:attribute name="version" select="x:xslt-version(.) => x:decimal-string()" />

			<!-- Import the stylesheet of the Schematron Step 3 preprocessor -->
			<xsl:element name="xsl:import" namespace="{$x:xsl-namespace}">
				<xsl:attribute name="href"
					select="($ACTUAL-PREPROCESSOR-URI, $builtin-preprocessor-uri)[1]" />
			</xsl:element>

			<!-- Import the private patch. This must be after importing the Step 3 preprocessor
				for the patch to take precedence. -->
			<xsl:if test="empty($ACTUAL-PREPROCESSOR-URI)">
				<xsl:element name="xsl:import" namespace="{$x:xsl-namespace}">
					<xsl:attribute name="href" select="resolve-uri('patch-step3.xsl')" />
				</xsl:element>
			</xsl:if>

			<!-- Set up a pseudo x:param which holds the fully-resolved Schematron file URI
				so that $x:schematron-uri holding the URI is generated and made available in
				the wrapper stylesheet being generated -->
			<xsl:variable as="element(x:param)" name="xml-base-param">
				<!-- Use x:xspec-name() for the element name just for cleanness -->
				<xsl:element name="{x:xspec-name('param', .)}" namespace="{$x:xspec-namespace}">
					<xsl:attribute name="as" select="x:known-UQName('xs:anyURI')" />
					<xsl:attribute name="name" select="x:known-UQName('x:schematron-uri')" />

					<xsl:value-of select="x:locate-schematron-uri(.)" />
				</xsl:element>
			</xsl:variable>

			<!-- Resolve x:param -->
			<xsl:apply-templates mode="test:generate-variable-declarations"
				select="$xml-base-param, x:param" />
		</xsl:element>
	</xsl:template>

</xsl:stylesheet>
