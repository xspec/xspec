<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xspec-space="x-urn:test:xspec-space">

	<!-- Returns the context node intact -->
	<xsl:template as="node()" name="context-mirror-template">
		<xsl:sequence select="." />
	</xsl:template>

	<!-- Inserts $text into <match> -->
	<xsl:template as="element(match)" match="match">
		<xsl:param as="text()?" name="text" />

		<xsl:copy>
			<xsl:sequence select="$text" />
		</xsl:copy>
	</xsl:template>

	<!-- Returns true if $items is the known whitespace-only text node -->
	<xsl:function as="xs:boolean" name="xspec-space:is-expected-text-node">
		<xsl:param as="item()*" name="items" />

		<xsl:sequence
			select="
				($items instance of text())
				and ($items eq '&#x09;&#x0A;&#x0D;&#x20;')"
		 />
	</xsl:function>

</xsl:stylesheet>
