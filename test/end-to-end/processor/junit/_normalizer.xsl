<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module helps normalize the JUnit report.
	-->

	<!--
		Normalizes the link to the XSpec file
			Example:
				in:		<testsuites name="file:/path/to/test.xspec">
				out:	<testsuites name="test.xspec">
	-->
	<xsl:template as="attribute(name)" match="/testsuites/@name" mode="normalizer:normalize">
		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="x:filename-and-extension(.)" />
	</xsl:template>

</xsl:stylesheet>
