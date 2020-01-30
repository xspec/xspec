<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="../common/xspec-utils.xsl" />

	<xsl:output method="text" />

	<!--
		Just outputs the fully resolved Schematron file URI
	-->
	<xsl:template as="text()" match="document-node()">
		<xsl:value-of select="x:locate-schematron-uri(x:description)" />
	</xsl:template>
</xsl:stylesheet>
