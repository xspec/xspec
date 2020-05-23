<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:include href="x-urn:test:catalog:02:stylesheets:stylesheet.xsl" />
	<xsl:template as="xs:string" name="main">
		<xsl:call-template name="imported" />
	</xsl:template>
</xsl:stylesheet>
