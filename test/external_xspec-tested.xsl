<?xml version="1.0" encoding="UTF-8"?>
<xsl:package exclude-result-prefixes="#all" version="3.0" xmlns:my="http://example.org/ns/my"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:include href="xspec-tested.xsl" />
	<xsl:expose component="*" names="my:*" visibility="final" />
</xsl:package>
