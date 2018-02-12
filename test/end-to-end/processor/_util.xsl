<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:util="x-urn:xspec:test:end-to-end:processor:util"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module is a collection of utilities.
	-->

	<!--
		Extracts filename (with extension) from slash-delimited path
			Example:
				in:		"file:/path/to/foo.bar.baz" or "/path/to/foo.bar.baz"
				out:	"foo.bar.baz"
	-->
	<xsl:function as="xs:string" name="util:filename-and-extension">
		<xsl:param as="xs:string" name="uri" />

		<xsl:sequence select="tokenize($uri, '/')[last()]" />
	</xsl:function>

	<!--
		Extracts filename (without extension) from slash-delimited path
			Example:
				in:		"file:/path/to/foo.bar.baz" or "/path/to/foo.bar.baz"
				out:	"foo.bar"
	-->
	<xsl:function as="xs:string" name="util:filename-without-extension">
		<xsl:param as="xs:string" name="uri" />

		<xsl:variable as="xs:string+" name="except-last"
			select="tokenize(util:filename-and-extension($uri), '\.')[position() lt last()]" />
		<xsl:sequence select="string-join($except-last, '.')" />
	</xsl:function>
</xsl:stylesheet>
