<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs"
	version="4.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		XSLT 4.0 supports xsl:switch
		https://www.saxonica.com/documentation12/index.html#!xsl-elements/switch
	-->
	<xsl:template as="xs:string" name="xsl-switch-v4">
		<xsl:context-item use="absent" />
		<xsl:param name="f" as="xs:string" required="1" />

		<xsl:switch select="$f">
			<xsl:when test="('svg','SVG')" select="'vector'" />
			<xsl:when test="('jpg','JPG','jpeg','JPEG')" select="'bitmap'" />
			<xsl:otherwise select="'not supported'" />
		</xsl:switch>
	</xsl:template>

</xsl:stylesheet>
