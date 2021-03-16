<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="document-node(element(sch:schema))" match="document-node(element(sch:schema))">
		<!--
			Include (Step 1)
		-->
		<xsl:variable as="map(xs:string, item())" name="options-map" select="
				map {
					'source-node': .,
					'stylesheet-location': 'schematron-xslt_include.xsl'
				}" />
		<xsl:variable as="document-node(element(sch:schema))" name="step1-transformed-doc"
			select="transform($options-map)?output" />

		<!--
			Expand (Step 2)
		-->
		<xsl:variable as="map(xs:string, item())" name="options-map" select="
				map {
					'source-node': $step1-transformed-doc,
					'stylesheet-location': 'schematron-xslt_expand.xsl'
				}" />
		<xsl:sequence select="transform($options-map)?output" />
	</xsl:template>

</xsl:stylesheet>
