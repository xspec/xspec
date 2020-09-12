<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Returns the context item intact -->
	<xsl:mode name="get-template-context" on-multiple-match="fail" on-no-match="fail" />
	<xsl:template as="item()" match="." mode="get-template-context" name="get-template-context">
		<xsl:sequence select="." />
	</xsl:template>

</xsl:stylesheet>
