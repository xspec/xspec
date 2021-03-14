<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0" xmlns:f="http://example.org/filter.xsl"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:use-package name="http://example.org/filter.xsl" version="1.0" />

	<xsl:strip-space elements="*" />

	<xsl:template as="element(report)" match="data">
		<report>
			<xsl:sequence select="employee[f:filter(.)]" />
		</report>
	</xsl:template>

</xsl:stylesheet>
