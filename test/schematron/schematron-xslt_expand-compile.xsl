<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="document-node(element(xsl:stylesheet))"
		match="document-node(element(sch:schema))">
		<!--
			Expand (Step 2)
		-->
		<xsl:variable as="map(xs:string, item())" name="options-map" select="
				map {
					'source-node': .,
					'stylesheet-location': 'schematron-xslt_expand.xsl'
				}" />
		<xsl:variable as="document-node(element(sch:schema))" name="step2-transformed-doc"
			select="transform($options-map)?output" />

		<!--
			Compile (Step 3)
		-->
		<xsl:variable as="map(xs:string, item())" name="options-map" select="
				map {
					'source-node': $step2-transformed-doc,
					'stylesheet-location': 'schematron-xslt_compile.xsl'
				}" />
		<xsl:sequence select="transform($options-map)?output" />
	</xsl:template>

</xsl:stylesheet>
