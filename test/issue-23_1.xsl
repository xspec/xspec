<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:global-context-item use="absent" />

	<xsl:import-schema namespace="x-urn:test" schema-location="issue-23_1.xsd" />

	<xsl:variable as="document-node(schema-element(Q{x-urn:test}foo))" name="foo-strict">
		<xsl:copy-of select="doc('issue-23_1.xml')" validation="strict" />
	</xsl:variable>

	<xsl:variable as="document-node(element(Q{x-urn:test}foo))" name="foo-strip">
		<xsl:copy-of select="doc('issue-23_1.xml')" validation="strip" />
	</xsl:variable>
</xsl:stylesheet>
