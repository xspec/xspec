<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias" xmlns:foo="foo"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- This master stylesheet imports iso_svrl_for_xslt2.xsl and injects some private global
		variables (strings copied from the known global parameters).
		The source parameters are supposed to be supplied by /x:description/x:param.
		The injected variables are to be checked by //x:scenario/x:expect. -->

	<xsl:import href="../../lib/iso-schematron/iso_svrl_for_xslt2.xsl" />

	<xsl:template as="node()+" match="sch:schema" mode="stylesheetbody">
		<axsl:variable as="xs:string" name="schematron-param-001:phase">
			<xsl:value-of select="$phase" />
		</axsl:variable>
		<axsl:variable as="xs:string" name="schematron-param-001:selected">
			<xsl:value-of select="$selected" />
		</axsl:variable>
		<axsl:variable as="xs:string" name="schematron-param-001:escape1">
			<xsl:value-of select="$escape1" />
		</axsl:variable>
		<axsl:variable as="xs:string" name="schematron-param-001:escape2">
			<xsl:value-of select="$escape2" />
		</axsl:variable>
		<axsl:variable as="xs:string" name="schematron-param-001:escape3">
			<xsl:value-of select="$escape3" />
		</axsl:variable>
		<axsl:variable as="xs:string" name="schematron-param-001:escape4">
			<xsl:value-of select="$escape4" />
		</axsl:variable>
		<axsl:variable as="xs:string" name="schematron-param-001:foo-selected">
			<xsl:value-of select="$foo:selected" />
		</axsl:variable>
		<axsl:variable as="xs:string" name="schematron-param-001:href-selected">
			<xsl:value-of select="$href-selected" />
		</axsl:variable>

		<!-- Let the other things go -->
		<xsl:apply-imports />
	</xsl:template>
</xsl:stylesheet>
