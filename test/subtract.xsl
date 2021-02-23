<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0" xmlns:my="http://example.org/ns/my"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:function as="xs:integer" name="my:subtract">
		<xsl:param as="xs:integer" name="left" />
		<xsl:param as="xs:integer" name="right" />

		<xsl:sequence select="$left - $right" />
	</xsl:function>

	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="xs:integer" match="context-child" name="my:subtract">
		<xsl:param as="xs:integer" name="left" required="yes" />
		<xsl:param as="xs:integer" name="right" required="yes" />

		<xsl:sequence select="$left - $right" />
	</xsl:template>

</xsl:stylesheet>
