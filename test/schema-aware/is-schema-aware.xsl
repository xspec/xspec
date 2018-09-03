<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" />

	<xsl:import-schema>
		<xs:schema />
	</xsl:import-schema>

	<xsl:template as="text()" name="main">
		<xsl:value-of select="system-property('xsl:is-schema-aware')" />
	</xsl:template>
</xsl:stylesheet>
