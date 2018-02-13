<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template as="xs:anyAtomicType" match="foo">
		<xsl:sequence select="data(.)" />
	</xsl:template>
</xsl:stylesheet>