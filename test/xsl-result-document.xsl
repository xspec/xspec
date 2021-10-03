<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template as="element(principal)" name="has-href">
		<xsl:context-item use="absent" />

		<xsl:result-document
			href="{if (system-property('file.separator') eq '\') then 'NUL' else 'file:/dev/null'}">
			<secondary />
		</xsl:result-document>
		<principal />
	</xsl:template>

	<xsl:template as="empty-sequence()" name="no-href">
		<xsl:context-item use="absent" />

		<xsl:result-document>
			<secondary />
		</xsl:result-document>
	</xsl:template>

</xsl:stylesheet>
