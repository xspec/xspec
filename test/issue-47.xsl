<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import-schema namespace="x-urn:test" schema-location="issue-47.xsd" />

	<xsl:variable as="document-node()" name="test-doc">
		<xsl:copy-of select="doc('issue-47.xml')" validation="strict" />
	</xsl:variable>

	<xsl:template as="node()" match="node()">
		<xsl:sequence select="." />
	</xsl:template>
</xsl:stylesheet>
