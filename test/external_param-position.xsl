<?xml version="1.0" encoding="UTF-8"?>
<xsl:package exclude-result-prefixes="#all" version="3.0"
	xmlns:param-position="x-urn:test:param-position"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:include href="param-position.xsl" />
	<xsl:expose component="*" names="param-position:*" visibility="final" />
</xsl:package>
