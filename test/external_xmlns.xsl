<?xml version="1.0" encoding="UTF-8"?>
<xsl:package exclude-result-prefixes="#all" version="3.0" xmlns:s1="http://example.org/ns/my/ns1"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:include href="xmlns.xsl" />
	<xsl:expose component="*" names="s1:*" visibility="final" />
</xsl:package>
