<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet just renames some elements. All the other nodes including whitespace-only
		text nodes are kept intact.
		
		This stylesheet uses mode="#all" for reasons best known to its author.
	-->

	<!-- Identity template -->
	<xsl:template as="node()" match="attribute() | document-node() | node()" mode="#all">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute() | node()" />
		</xsl:copy>
	</xsl:template>

	<!-- Rename <foo> to <bar> -->
	<xsl:template as="element(bar)" match="foo" mode="#all">
		<bar>
			<xsl:apply-templates mode="#current" select="attribute() | node()" />
		</bar>
	</xsl:template>

	<!-- Rename <bar> to <baz> -->
	<xsl:template as="element(baz)" match="bar" mode="#all">
		<baz>
			<xsl:apply-templates mode="#current" select="attribute() | node()" />
		</baz>
	</xsl:template>

</xsl:stylesheet>
