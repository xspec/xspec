<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This master stylesheet generates a wrapper stylesheet which imports the actual stylesheet
		of the Schematron Step 3 preprocessor.
		While generating the wrapper stylesheet, the following adjustments are made:
			* Transforms /x:description/x:param into /xsl:stylesheet/xsl:param.
			* Imports the private patch (only for the built-in preprocessor).
			* Generates $x:schematron-uri global parameter.
		See ../../test/generate-step3-wrapper_*.xspec for examples.
	-->

	<!-- Absolute URI of the actual stylesheet of the Schematron Step 3 preprocessor.
		Empty sequence means the built-in preprocessor. -->
	<xsl:param as="xs:string?" name="ACTUAL-PREPROCESSOR-URI" />

	<!-- Import a compiler component and override it -->
	<xsl:import href="../compiler/base/resolve-import/resolve-import.xsl" />

	<xsl:include href="../common/common-utils.xsl" />
	<xsl:include href="../common/namespace-utils.xsl" />
	<xsl:include href="../common/trim.xsl" />
	<xsl:include href="../common/uqname-utils.xsl" />
	<xsl:include href="../common/uri-utils.xsl" />
	<xsl:include href="../common/user-content-utils.xsl" />
	<xsl:include href="../compiler/base/declare-variable/variable-uqname.xsl" />
	<xsl:include href="../compiler/base/util/compiler-eqname-utils.xsl" />
	<xsl:include href="../compiler/base/util/compiler-misc-utils.xsl" />
	<xsl:include href="../compiler/base/util/compiler-yes-no-utils.xsl" />
	<xsl:include href="../compiler/xslt/declare-variable/declare-variable.xsl" />
	<xsl:include href="../compiler/xslt/node-constructor/node-constructor.xsl" />
	<xsl:include href="locate-schematron-uri.xsl" />

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

			<xsl:variable as="element(x:description)" name="pseudo-description">
				<!--
					- Wrap x:param and x:variable in x:description so that they're recognized as
					  global ones.
					- Use x:xspec-name() for the element names just for cleanness.
				-->
				<xsl:element name="{x:xspec-name('description', .)}"
					namespace="{$x:xspec-namespace}">
					<!-- Set up a pseudo x:param which holds the fully-resolved Schematron file URI
						so that $x:schematron-uri holding the URI is generated and made available in
						the wrapper stylesheet being generated.
						Do it even when the private patch is not imported, because the preprocessor
						specified by $ACTUAL-PREPROCESSOR-URI may want to make use of it. -->
					<xsl:element name="{x:xspec-name('param', .)}" namespace="{$x:xspec-namespace}">
						<xsl:attribute name="as" select="x:known-UQName('xs:anyURI')" />
						<xsl:attribute name="name" select="x:known-UQName('x:schematron-uri')" />

						<!-- Output as a text node so that we don't need to take care of escaping -->
						<xsl:value-of select="x:locate-schematron-uri(.)" />
					</xsl:element>

					<!-- Resolve x:import and gather only the user-provided global params and
						variables -->
					<xsl:sequence select="x:resolve-import(.)" />
				</xsl:element>
			</xsl:variable>

			<xsl:apply-templates mode="x:declare-variable" select="$pseudo-description/element()" />
		</xsl:element>
	</xsl:template>

	<!--
		mode="x:gather-specs"
		Override the imported mode in order to gather only x:description/(x:param | x:variable)
	-->

	<!-- Discard all except global params and variables -->
	<xsl:template as="empty-sequence()"
		match="x:description/node()[not(self::x:param | self::x:variable)]" mode="x:gather-specs" />

	<!-- Reject @static=yes, because it doesn't take effect.
		Making @static=yes take effect requires coordination with schut-to-xslt.xsl who invokes the
		wrapper stylesheet being generated here. Implementing it isn't worthwhile until requested
		seriously. -->
	<xsl:template as="empty-sequence()" match="x:param[x:yes-no-synonym(@static, false())]"
		mode="x:gather-specs">
		<xsl:message terminate="yes">
			<xsl:text expand-text="yes">Enabling @static in {name()} is not supported for Schematron.</xsl:text>
		</xsl:message>
	</xsl:template>

</xsl:stylesheet>
