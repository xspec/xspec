<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template as="element(principal)" name="has-href">
		<xsl:result-document
			href="{if (system-property('file.separator') eq '\') then 'NUL' else 'file:/dev/null'}">
			<secondary />
		</xsl:result-document>
		<principal />
	</xsl:template>

	<xsl:template as="empty-sequence()" name="no-href">
		<xsl:result-document>
			<!--
				xsl:document is for compatibility with all the Saxon versions.
				Without xsl:document, Saxon 9.8.0.15 returns a document-node(element(secondary))
				while 9.9.1.7, 9.9.1.8 and Saxon 10.3 return an element(secondary). I don't know
				which behavior is correct.
			-->
			<xsl:document>
				<secondary />
			</xsl:document>
		</xsl:result-document>
	</xsl:template>

</xsl:stylesheet>
