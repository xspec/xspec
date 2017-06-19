<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xspec-17="https://github.com/xspec/xspec/pull/17"  xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="2.0">

	<xsl:function name="xspec-17:read-document" as="document-node()?">
	  <xsl:sequence select="doc('xspec-result-naming-collision.xml')"/>
	</xsl:function>

</xsl:stylesheet>
