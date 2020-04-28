<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:schematron-025="x-urn:test:schematron-025" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:function as="xs:boolean" name="schematron-025:has-bad-text">
		<xsl:param as="element()" name="elem" />

		<xsl:sequence select="contains($elem, 'bad')" />
	</xsl:function>

</xsl:stylesheet>
