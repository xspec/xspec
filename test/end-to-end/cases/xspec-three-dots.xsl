<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xspec-three-dots="x-urn:test:xspec-three-dots">

	<!--
		Document node
	-->
	<xsl:variable as="document-node()" name="xspec-three-dots:document-node_multiple-nodes">
		<xsl:document>
			<xsl:processing-instruction name="pi" />
			<xsl:comment>comment</xsl:comment>
			<xsl:element name="elem" />
		</xsl:document>
	</xsl:variable>

	<xsl:variable as="document-node()" name="xspec-three-dots:document-node_empty">
		<xsl:document />
	</xsl:variable>

	<xsl:variable as="document-node()" name="xspec-three-dots:document-node_three-dots">
		<xsl:document>...</xsl:document>
	</xsl:variable>

	<xsl:variable as="document-node()" name="xspec-three-dots:document-node_text">
		<xsl:document>text</xsl:document>
	</xsl:variable>

	<!--
		Text node
	-->
	<xsl:variable as="text()" name="xspec-three-dots:text-node_usual">
		<xsl:text>text</xsl:text>
	</xsl:variable>

	<xsl:variable as="text()" name="xspec-three-dots:text-node_whitespace-only">
		<xsl:text>&#x09;&#x0A;&#x0D;&#x20;</xsl:text>
	</xsl:variable>

	<xsl:variable as="text()" name="xspec-three-dots:text-node_zero-length">
		<xsl:text />
	</xsl:variable>

	<xsl:variable as="text()" name="xspec-three-dots:text-node_three-dots">
		<xsl:text>...</xsl:text>
	</xsl:variable>

	<!--
		Namespace node
	-->
	<xsl:function as="namespace-node()" name="xspec-three-dots:namespace-node">
		<xsl:param as="xs:string" name="prefix" />
		<xsl:param as="xs:string" name="namespace-uri" />

		<xsl:namespace name="{$prefix}" select="$namespace-uri" />
	</xsl:function>
</xsl:stylesheet>
