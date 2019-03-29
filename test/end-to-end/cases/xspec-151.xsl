<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:test-mix="x-urn:test-mix"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import-schema namespace="x-urn:test-mix" schema-location="xspec-151.xsd" />

	<xsl:function as="item()+" name="test-mix:element-and-string">
		<xsl:element name="test-mix:fooElement" type="test-mix:fooType">
			<test-mix:barElement />
		</xsl:element>
		<xsl:sequence select="'string'" />
	</xsl:function>
</xsl:stylesheet>
