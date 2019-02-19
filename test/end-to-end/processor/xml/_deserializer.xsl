<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:deserializer="x-urn:xspec:test:end-to-end:processor:deserializer"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.jenitennison.com/xslt/xspec">
	<!--
		This stylesheet module helps deserialize the test result XML.
	-->

	<!--
		Removes whitespace-only text node from XQuery test result XML
	-->
	<xsl:template as="empty-sequence()" match="/report[@query]//text()[not(normalize-space())]"
		mode="deserializer:unindent" />
</xsl:stylesheet>
