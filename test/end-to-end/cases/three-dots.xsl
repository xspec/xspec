<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:three-dots="x-urn:test:three-dots" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Empty document node -->
	<xsl:variable as="document-node()" name="three-dots:document-node_empty">
		<xsl:document />
	</xsl:variable>

	<!-- Zero-length text node -->
	<xsl:variable as="text()" name="three-dots:text-node_zero-length">
		<xsl:text />
	</xsl:variable>

	<!-- Namespace node generator -->
	<xsl:function as="namespace-node()" name="three-dots:namespace-node">
		<xsl:param as="xs:string" name="prefix" />
		<xsl:param as="xs:string" name="namespace-uri" />

		<xsl:namespace name="{$prefix}" select="$namespace-uri" />
	</xsl:function>

</xsl:stylesheet>
