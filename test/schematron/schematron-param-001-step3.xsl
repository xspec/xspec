<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0" xmlns:foo="foo"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:schxslt-api="https://doi.org/10.5281/zenodo.1495494#api"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- This master stylesheet imports the original Schematron Step 3 preprocessor and injects some
		private global variables (strings copied from the known global parameters).
		The source parameters are supposed to be supplied by /x:description/x:param.
		The injected variables are to be checked by //x:scenario/x:expect. -->

	<xsl:import href="../../lib/schxslt/2.0/compile-for-svrl.xsl" />

	<xsl:include href="../../src/common/common-utils.xsl" />
	<xsl:include href="../../src/common/namespace-utils.xsl" />
	<xsl:include href="../../src/common/uqname-utils.xsl" />

	<xsl:template as="element(xsl:variable)+" name="schxslt-api:validation-stylesheet-body-top-hook">
		<xsl:param as="element(sch:schema)" name="schema" required="yes" />

		<xsl:variable as="map(xs:string, item())" name="vars-map" select="
				map {
					'schematron-param-001:phase': $phase,
					'schematron-param-001:selected': $selected,
					'schematron-param-001:escape1': $escape1,
					'schematron-param-001:escape2': $escape2,
					'schematron-param-001:escape3': $escape3,
					'schematron-param-001:escape4': $escape4,
					'schematron-param-001:foo-selected': $foo:selected,
					'schematron-param-001:href-selected': $href-selected
				}" />

		<xsl:for-each select="map:keys($vars-map)">
			<xsl:element name="xsl:variable" namespace="{$x:xsl-namespace}">
				<xsl:attribute name="as" select="x:known-UQName('xs:string')" />
				<xsl:attribute name="name" select="." />

				<xsl:value-of select="map:get($vars-map, .)" />
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
