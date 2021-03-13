<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:myinternal="http://example.org/ns/myinternal"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Override an internal worker template in SUT and return a fixed integer -->
	<xsl:template as="xs:integer" name="myinternal:square-worker">
		<xsl:context-item use="absent" />

		<xsl:param as="xs:integer" name="n" required="yes" />

		<xsl:sequence select="1234567890" />
	</xsl:template>

</xsl:stylesheet>
