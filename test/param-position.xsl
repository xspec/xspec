<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:param-position="x-urn:test:param-position" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:function as="xs:string" name="param-position:join">
		<xsl:param as="xs:string" name="p1" />
		<xsl:param as="xs:string" name="p2" />
		<xsl:param as="xs:string" name="p3" />
		<xsl:param as="xs:string" name="p4" />

		<xsl:sequence select="($p1, $p2, $p3, $p4) => string-join()" />
	</xsl:function>

</xsl:stylesheet>
