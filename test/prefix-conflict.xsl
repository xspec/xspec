<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="x-urn:test:prefix-conflict" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Returns the context node intact -->
	<xsl:template as="node()" name="x:context-mirror">
		<xsl:sequence select="." />
	</xsl:template>

	<!-- Returns the items in the parameter intact -->
	<xsl:mode name="x:param-mirror" on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="item()*" match="attribute() | node() | document-node()"
		mode="x:param-mirror" name="x:param-mirror">
		<xsl:param as="item()*" name="x:param-items" />

		<xsl:sequence select="$x:param-items" />
	</xsl:template>

	<!-- Returns the items in the parameter intact -->
	<xsl:function as="item()*" name="x:param-mirror">
		<xsl:param as="item()*" name="x:param-items" />

		<xsl:sequence select="$x:param-items" />
	</xsl:function>

	<!-- Emulates fn:false() -->
	<xsl:function as="xs:boolean" name="x:false">
		<xsl:sequence select="false()" />
	</xsl:function>

</xsl:stylesheet>
