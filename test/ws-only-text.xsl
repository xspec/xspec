<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:ws-only-text="x-urn:test:ws-only-text"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="mirror.xsl" />

	<!-- Whitespace-only text node for test -->
	<xsl:variable as="text()" name="ws-only-text:wsot">
		<xsl:text>&#x09;&#x0A;&#x0D;&#x20;</xsl:text>
	</xsl:variable>

	<!-- Elements for test -->
	<xsl:variable as="element(span)" name="ws-only-text:span-element-empty">
		<span />
	</xsl:variable>
	<xsl:variable as="element(span)" name="ws-only-text:span-element-wsot">
		<span>
			<xsl:sequence select="$ws-only-text:wsot" />
		</span>
	</xsl:variable>
	<xsl:variable as="element(pre)" name="ws-only-text:pre-element-wsot">
		<pre>
			<xsl:sequence select="$ws-only-text:wsot" />
		</pre>
	</xsl:variable>

</xsl:stylesheet>
