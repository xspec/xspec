<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:my="my-namespace"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:variable as="document-node(element(test))" name="my:test-doc">
		<xsl:document>
			<test>document defined in SUT</test>
		</xsl:document>
	</xsl:variable>

	<xsl:variable as="xs:anyURI" name="my:test-doc-uri" select="xs:anyURI('URI defined in SUT')" />

</xsl:stylesheet>
