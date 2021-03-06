<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:include href="items.xsl" />

	<xsl:template as="empty-sequence()" name="null">
		<xsl:context-item use="absent" />
	</xsl:template>
</xsl:stylesheet>
