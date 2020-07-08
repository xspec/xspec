<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:test-mix="x-urn:test-mix"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import-schema namespace="x-urn:test-mix" schema-location="issue-151.xsd" />

	<xsl:function as="item()+" name="test-mix:element-and-string">
		<xsl:variable as="element(test-mix:fooElement, test-mix:fooType)" name="typed-element">
			<xsl:copy-of select="doc('issue-151.xml')/element()" validation="strict" />
		</xsl:variable>
		<xsl:sequence select="$typed-element, 'string'" />
	</xsl:function>
</xsl:stylesheet>
