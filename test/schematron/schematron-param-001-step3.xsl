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

	<xsl:include href="../../src/schematron/preprocessor.xsl" />

	<xsl:import _href="{$x:schematron-preprocessor?stylesheets?3}" />

	<xsl:include href="../../src/common/common-utils.xsl" />
	<xsl:include href="../../src/common/namespace-vars.xsl" />
	<xsl:include href="../../src/common/uqname-utils.xsl" />

	<xsl:param name="selected" required="yes" />
	<xsl:param name="escape1" required="yes" />
	<xsl:param name="escape2" required="yes" />
	<xsl:param name="escape3" required="yes" />
	<xsl:param name="escape4" required="yes" />
	<xsl:param name="foo:selected" required="yes" />
	<xsl:param name="href-selected" required="yes" />

	<xsl:template _name="
			{
				'schxslt-api:validation-stylesheet-body-top-hook'[$x:schematron-preprocessor?name eq 'schxslt'],
				'process-prolog'[$x:schematron-preprocessor?name eq 'skeleton']
			}" as="element(xsl:variable)+">
		<xsl:param as="element(sch:schema)" name="schema" required="yes"
			use-when="$x:schematron-preprocessor?name eq 'schxslt'" />

		<xsl:variable as="map(xs:string, item())" name="vars-map" select="
				map {
					'phase': $phase,
					'selected': $selected,
					'escape1': $escape1,
					'escape2': $escape2,
					'escape3': $escape3,
					'escape4': $escape4,
					'foo-selected': $foo:selected,
					'href-selected': $href-selected
				}" />

		<xsl:for-each select="map:keys($vars-map)">
			<xsl:element name="xsl:variable" namespace="{$x:xsl-namespace}">
				<xsl:attribute name="as" select="x:known-UQName('xs:string')" />
				<xsl:attribute name="name"
					select="x:UQName('x-urn:xspec:test:schematron-param-001', .)" />

				<xsl:value-of select="map:get($vars-map, .)" />
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
