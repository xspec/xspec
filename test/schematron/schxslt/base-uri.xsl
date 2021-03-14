<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:test-with-schxslt="x-urn:test:test-with-schxslt"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:variable as="xs:string" name="test-with-schxslt:base-uri"
		select="xs:anyURI('https://github.com/schxslt/schxslt/raw/v1.6.2/core/src/main/resources/xslt/2.0/')"
		static="yes" />
</xsl:stylesheet>
