<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:util="x-urn:xspec:test:end-to-end:processor:util"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.w3.org/1999/xhtml">

	<!--
		This stylesheet is a collection of utilities.
	-->

	<xsl:function as="xs:string" name="util:filename-and-extension">
		<xsl:param as="xs:string" name="uri" />

		<xsl:sequence select="tokenize($uri, '/')[last()]" />
	</xsl:function>

	<xsl:function as="xs:string" name="util:filename-without-extension">
		<xsl:param as="xs:string" name="uri" />

		<xsl:variable as="xs:string+" name="except-last"
			select="tokenize(util:filename-and-extension($uri), '\.')[position() lt last()]" />
		<xsl:sequence select="string-join($except-last, '.')" />
	</xsl:function>
</xsl:stylesheet>
