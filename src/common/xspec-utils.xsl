<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module is a collection of common utilities used across component borders
		Elements in this stylesheet must not affect the other stylesheets.
	-->

	<!-- Identity template -->
	<xsl:template as="node()" name="x:identity">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute() | node()" />
		</xsl:copy>
	</xsl:template>

	<!--
		Extracts filename (with extension) from slash-delimited path
			Example:
				in:  "file:/path/to/foo.bar.baz" or "/path/to/foo.bar.baz"
				out: "foo.bar.baz"
	-->
	<xsl:function as="xs:string" name="x:filename-and-extension">
		<xsl:param as="xs:string" name="input" />

		<xsl:sequence select="tokenize($input, '/')[last()]" />
	</xsl:function>

	<!--
		Extracts filename (without extension) from slash-delimited path
			Example:
				in:  "file:/path/to/foo.bar.baz" or "/path/to/foo.bar.baz"
				out: "foo.bar"
	-->
	<xsl:function as="xs:string" name="x:filename-without-extension">
		<xsl:param as="xs:string" name="input" />

		<xsl:variable as="xs:string+" name="except-last"
			select="tokenize(x:filename-and-extension($input), '\.')[position() lt last()]" />
		<xsl:sequence select="string-join($except-last, '.')" />
	</xsl:function>

</xsl:stylesheet>
