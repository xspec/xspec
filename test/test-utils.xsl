<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

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

		<xsl:variable as="xs:string" name="filename-and-extension"
			select="x:filename-and-extension($input)" />

		<xsl:sequence
			select="
				if (contains($filename-and-extension, '.')) then
					replace($filename-and-extension, '^(.*)\.[^.]*$', '$1')
				else
					$filename-and-extension"
		 />
	</xsl:function>

	<!--
		Extracts extension (without filename) from slash-delimited path
			Example:
				in:  "file:/path/to/foo.bar.baz" or "/path/to/foo.bar.baz"
				out: ".baz"
	-->
	<xsl:function as="xs:string" name="x:extension-without-filename">
		<xsl:param as="xs:string" name="input" />

		<xsl:variable as="xs:string" name="filename-and-extension"
			select="x:filename-and-extension($input)" />

		<xsl:sequence
			select="
				if (contains($filename-and-extension, '.')) then
					replace($filename-and-extension, '^.*(\.[^.]*)$', '$1')
				else
					''"
		 />
	</xsl:function>

	<!--
		Returns true if two QNames are exactly equal to each other.
		
		Unlike fn:deep-equal() or 'eq' operator, this function compares prefix.
	-->
	<xsl:function as="xs:boolean" name="x:QName-exactly-equal">
		<xsl:param as="xs:QName" name="qname1" />
		<xsl:param as="xs:QName" name="qname2" />

		<xsl:sequence
			select="
				deep-equal($qname1, $qname2)
				and
				deep-equal(prefix-from-QName($qname1), prefix-from-QName($qname2))"
		 />
	</xsl:function>

</xsl:stylesheet>
