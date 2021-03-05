<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import-schema namespace="x-urn:test" schema-location="issue-23_2.xsd" />

	<xsl:variable as="document-node(schema-element(Q{x-urn:test}foo))" name="expect">
		<xsl:copy-of select="doc('issue-23_2_expect.xml')" validation="strict" />
	</xsl:variable>

	<xsl:template match="/">
		<xsl:sequence select="." />
	</xsl:template>
</xsl:stylesheet>
