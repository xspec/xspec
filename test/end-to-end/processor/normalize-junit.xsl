<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:util="x-urn:xspec:test:end-to-end:processor:util"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="_normalizer.xsl" />
	<xsl:include href="_normalizer_junit.xsl"/>
	<xsl:include href="_util.xsl" />
	
	<xsl:template as="empty-sequence()" match="document-node()">
		<xsl:message select="'Normalizing', base-uri()" />

		<xsl:result-document format="junit">
			<xsl:sequence select="normalizer:normalize(.)" />
		</xsl:result-document>
		
		<xsl:message select="'Normalized'" />
	</xsl:template>
</xsl:stylesheet>
