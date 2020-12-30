<?xml version="1.0" encoding="UTF-8"?>
<!--
	Utilities common between XSLT and XQuery
-->
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		XSpec 'x' namespace URI
	-->
	<xsl:variable as="xs:anyURI" name="x:xspec-namespace"
		select="xs:anyURI('http://www.jenitennison.com/xslt/xspec')" />

	<!--
		U+0027
	-->
	<xsl:variable as="xs:string" name="x:apos">'</xsl:variable>

	<!--
		Returns numeric literal of xs:decimal
			https://www.w3.org/TR/xpath-31/#id-literals

			Example:
				in:  1
				out: '1.0'
	-->
	<xsl:function as="xs:string" name="x:decimal-string">
		<xsl:param as="xs:decimal" name="decimal" />

		<xsl:variable as="xs:string" name="decimal-string" select="string($decimal)" />
		<xsl:sequence
			select="
				if (contains($decimal-string, '.')) then
					$decimal-string
				else
					($decimal-string || '.0')"
		 />
	</xsl:function>

	<!--
		Returns XPath expression of fn:QName() which represents the given xs:QName
	-->
	<xsl:function as="xs:string" name="x:QName-expression">
		<xsl:param as="xs:QName" name="qname" />

		<xsl:variable as="xs:string" name="quoted-uri"
			select="
				$qname
				=> namespace-uri-from-QName()
				=> x:quote-with-apos()" />

		<xsl:text expand-text="yes">QName({$quoted-uri}, '{$qname}')</xsl:text>
	</xsl:function>

	<!--
		Duplicates every apostrophe character in a string
		and quotes the whole string with apostrophes
	-->
	<xsl:function as="xs:string" name="x:quote-with-apos">
		<xsl:param as="xs:string" name="input" />

		<xsl:variable as="xs:string" name="escaped"
			select="replace($input, $x:apos, ($x:apos || $x:apos))" />
		<xsl:sequence select="$x:apos || $escaped || $x:apos" />
	</xsl:function>

</xsl:stylesheet>
