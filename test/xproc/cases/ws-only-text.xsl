<?xml version="1.0" encoding="UTF-8"?>
<!--
	This file imitates test/ws-only-text.xsl, except that variables are
	document nodes instead of elements. Some x:expect elements in ws-only-text_xproc.xspec
	filter the document to reach descendant nodes as needed. 
-->
<xsl:stylesheet version="3.0" xmlns:ws-only-text="x-urn:test:ws-only-text"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:global-context-item use="absent" />

	<!-- Whitespace-only text node for test -->
	<xsl:variable as="document-node()" name="ws-only-text:wsot">
		<xsl:document>
			<xsl:text>&#x09;&#x0A;&#x0D;&#x20;</xsl:text>
		</xsl:document>
	</xsl:variable>

	<!-- Elements for test -->
	<xsl:variable as="document-node(element(span))" name="ws-only-text:span-element-empty">
		<xsl:document>
			<span />
		</xsl:document>
	</xsl:variable>
	<xsl:variable as="document-node(element(span))" name="ws-only-text:span-element-wsot">
		<xsl:document>
			<span>
				<xsl:sequence select="$ws-only-text:wsot" />
			</span>
		</xsl:document>
	</xsl:variable>
	<xsl:variable as="document-node(element(pre))" name="ws-only-text:pre-element-wsot">
		<xsl:document>
			<pre>
				<xsl:sequence select="$ws-only-text:wsot" />
			</pre>
		</xsl:document>
	</xsl:variable>

</xsl:stylesheet>
