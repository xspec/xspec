<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module is a private patch for the built-in Schematron Step 3 preprocessor.
	-->

	<!--
		Setting this parameter true activates the patch for @location containing text node
	-->
	<xsl:param as="xs:boolean" name="x:enable-schematron-text-location" select="false()" />

	<!--
		Workaround for schematron-select-full-path not working with text nodes
	-->
	<xsl:template match="*" mode="stylesheetbody">
		<xsl:next-match />

		<xsl:if test="$x:enable-schematron-text-location">
			<axsl:template match="text()" mode="schematron-select-full-path">
				<xsl:comment>This template was injected by <xsl:value-of select="static-base-uri()" /></xsl:comment>
				<axsl:apply-templates mode="#current" select="parent::element()" />
				<axsl:text>/text()[</axsl:text>
				<axsl:value-of select="count(preceding-sibling::text()) + 1" />
				<axsl:text>]</axsl:text>
			</axsl:template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
