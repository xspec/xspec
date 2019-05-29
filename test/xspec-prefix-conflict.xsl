<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:x="x-urn:test:xspec-prefix-conflict" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Returns the context node intact -->
	<xsl:template as="node()" name="x:context-mirror-template">
		<xsl:sequence select="." />
	</xsl:template>

	<!-- Returns the items in the parameter intact -->
	<xsl:template as="item()*" match="attribute() | node() | document-node()"
		mode="x:param-mirror-mode" name="x:param-mirror-template">
		<xsl:param as="item()*" name="x:param-items" />

		<xsl:sequence select="$x:param-items" />
	</xsl:template>

	<!-- Returns the items in the parameter intact -->
	<xsl:function as="item()*" name="x:param-mirror-function">
		<xsl:param as="item()*" name="x:param-items" />

		<xsl:sequence select="$x:param-items" />
	</xsl:function>
</xsl:stylesheet>
