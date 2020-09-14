<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:variable as="item()" name="global-context" select="." />

	<!-- Returns the global context item intact -->
	<xsl:mode name="get-global-context" on-multiple-match="fail" on-no-match="fail" />
	<xsl:template as="item()" match="." mode="get-global-context" name="get-global-context">
		<xsl:sequence select="$global-context" />
	</xsl:template>

</xsl:stylesheet>
