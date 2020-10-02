<?xml version="1.0" encoding="UTF-8"?>
<xsl:package exclude-result-prefixes="#all" version="3.0"
	xmlns:nested-function-call="x-urn:test:nested-function-call"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:include href="nested-function-call.xsl" />
	<xsl:expose component="*" names="nested-function-call:*" visibility="final" />
</xsl:package>
