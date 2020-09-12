<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:test-with-schxslt="x-urn:test:test-with-schxslt"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:include href="base-uri.xsl" />
	<xsl:include _href="{resolve-uri('expand.xsl', $test-with-schxslt:base-uri)}" />
</xsl:stylesheet>
