<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xspec-space="x-urn:test:xspec-space">

	<!-- Returns the context node intact -->
	<xsl:template as="node()" name="context-mirror-template">
		<xsl:sequence select="." />
	</xsl:template>

	<!-- Returns the items in the parameter intact -->
	<xsl:template as="item()*" match="attribute() | node() | document-node()"
		mode="param-mirror-mode" name="param-mirror-template">
		<xsl:param as="item()*" name="param-items" />

		<xsl:sequence select="$param-items" />
	</xsl:template>

	<!-- Whitespace-only text node for test -->
	<xsl:variable as="text()" name="xspec-space:wsot">
		<xsl:text>&#x09;&#x0A;&#x0D;&#x20;</xsl:text>
	</xsl:variable>

	<!-- Elements for test -->
	<xsl:variable as="element(span)" name="xspec-space:span-element-empty">
		<span />
	</xsl:variable>
	<xsl:variable as="element(span)" name="xspec-space:span-element-wsot">
		<span>
			<xsl:sequence select="$xspec-space:wsot" />
		</span>
	</xsl:variable>
	<xsl:variable as="element(pre)" name="xspec-space:pre-element-wsot">
		<pre>
			<xsl:sequence select="$xspec-space:wsot" />
		</pre>
	</xsl:variable>

</xsl:stylesheet>
