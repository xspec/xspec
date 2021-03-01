<?xml version="1.0" encoding="UTF-8"?>
<!-- Based on https://github.com/xspec/xspec/issues/762#issue-553725200 -->
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:f="http://example.org/complex-arithmetic.xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:use-package name="http://example.org/complex-arithmetic.xsl" version="1.0" />

	<xsl:template as="text()" name="xsl:initial-template">
		<xsl:context-item use="absent" />

		<xsl:variable name="val1" select="f:complex-number(2, 5)" />
		<xsl:variable name="val2" select="f:complex-number(3, 2)" />
		<xsl:variable name="sum" select="f:add($val1, $val2)" />
		<xsl:value-of expand-text="yes" xml:space="preserve">The sum of the two numbers is {f:real($sum)} + {f:imag($sum)}i</xsl:value-of>
	</xsl:template>

</xsl:stylesheet>
