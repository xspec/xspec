<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template as="node()" match="document-node() | attribute() | node()">
		<xsl:sequence select="." />
	</xsl:template>

	<!--
		Document node
	-->
	<xsl:variable as="document-node()" name="document-node_multiple-nodes">
		<xsl:document>
			<?pi?>
			<!--comment-->
			<elem />
		</xsl:document>
	</xsl:variable>

	<xsl:variable as="document-node()" name="document-node_empty">
		<xsl:document />
	</xsl:variable>

	<xsl:variable as="document-node()" name="document-node_three-dots">
		<xsl:document>...</xsl:document>
	</xsl:variable>

	<xsl:variable as="document-node()" name="document-node_text">
		<xsl:document>text</xsl:document>
	</xsl:variable>

	<!--
		Text node
	-->
	<xsl:variable as="text()" name="text-node_usual">
		<xsl:text>text</xsl:text>
	</xsl:variable>

	<xsl:variable as="text()" name="text-node_whitespace-only">
		<xsl:text>&#x09;&#x0A;&#x0D;&#x20;</xsl:text>
	</xsl:variable>

	<xsl:variable as="text()" name="text-node_zero-length">
		<xsl:text />
	</xsl:variable>

	<xsl:variable as="text()" name="text-node_three-dots">
		<xsl:text>...</xsl:text>
	</xsl:variable>
</xsl:stylesheet>
