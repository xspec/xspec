<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
	xmlns:iso="http://purl.oclc.org/dsdl/schematron"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This master stylesheet is a privately patched version of the original Schematron Step 3
		preprocessor.
	-->

	<!--
		Import the original Schematron Step 3 preprocessor
	-->
	<xsl:include href="../src/schematron/preprocessor.xsl" />
	<xsl:import _href="{$x:schematron-preprocessor?stylesheets?3}" />

	<!--
		Workaround for $document-uri not expecting the global context item to be absent.
		XPDY0002 in this case was implemented probably by https://saxonica.plan.io/issues/5131 on Saxon 10.7.
	-->
	<xsl:template as="node()+" match="element()" mode="stylesheetbody">
		<xsl:variable as="node()+" name="next-match">
			<xsl:next-match />
		</xsl:variable>

		<xsl:for-each select="$next-match">
			<xsl:choose>
				<xsl:when test="self::xsl:variable[@name eq 'document-uri']">
					<xsl:copy>
						<xsl:sequence select="attribute()" />

						<xsl:comment expand-text="yes">This ${@name} was modified by {static-base-uri()}</xsl:comment>

						<!-- Use root() instead of / -->
						<axsl:value-of select="document-uri(root())" />
					</xsl:copy>
				</xsl:when>

				<xsl:otherwise>
					<xsl:sequence select="." />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
