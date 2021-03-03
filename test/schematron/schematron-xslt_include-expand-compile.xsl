<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:param as="xs:anyURI" name="x:schematron-uri" required="yes" />

	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="document-node(element(xsl:transform))"
		match="document-node(element(sch:schema))">
		<!--
			Include (Step 1) & Expand (Step 2)
		-->
		<xsl:variable as="map(xs:string, item())" name="options-map" select="
				map {
					'source-node': .,
					'stylesheet-location': 'schematron-xslt_include-expand.xsl'
				}" />
		<xsl:variable as="document-node(element(sch:schema))" name="step1-step2-transformed-doc"
			select="transform($options-map)?output" />

		<!--
			Compile (Step 3)
		-->
		<xsl:variable as="map(xs:string, item())" name="options-map" select="
				map {
					'source-node': $step1-step2-transformed-doc,
					'stylesheet-location': 'schematron-xslt_compile.xsl',
					'stylesheet-params': map {xs:QName('x:schematron-uri'): $x:schematron-uri}
				}" />
		<xsl:sequence select="transform($options-map)?output" />
	</xsl:template>

</xsl:stylesheet>
