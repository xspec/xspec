<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:deserializer="x-urn:xspec:test:end-to-end:processor:deserializer"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module helps deserialize the document.
	-->

	<!--
		mode=unindent
			Removes side effect of loading indented XML
	-->

	<!-- Shallow-copy by default -->
	<xsl:mode name="deserializer:unindent" on-multiple-match="fail" on-no-match="shallow-copy" />

	<!-- The other processing depends on each processor... -->
</xsl:stylesheet>
