<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import-schema namespace="x-urn:test" schema-location="xspec-23_1.xsd" />

	<xsl:variable name="foo-strict">
		<xsl:copy-of select="doc('xspec-23_1.xml')" validation="strict" />
	</xsl:variable>

	<xsl:variable name="foo-strip">
		<xsl:copy-of select="doc('xspec-23_1.xml')" validation="strip" />
	</xsl:variable>
</xsl:stylesheet>
