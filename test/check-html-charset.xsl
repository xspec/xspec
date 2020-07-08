<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.w3.org/1999/xhtml">

	<xsl:output method="text" />

	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="text()" match="document-node(element(html))">
		<xsl:text expand-text="yes">{html/head/meta[@http-equiv = 'Content-Type']/@content = 'text/html; charset=UTF-8'}&#x0A;</xsl:text>
	</xsl:template>

</xsl:stylesheet>
