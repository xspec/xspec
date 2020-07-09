<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="xs:boolean" match="context-element-for-test-template" name="test-template">
		<xsl:param as="item()?" name="param-item" />

		<xsl:sequence select="exists($param-item)" />
	</xsl:template>

</xsl:stylesheet>
