<?xml version="1.0" encoding="UTF-8"?>
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
			http://www.w3.org/TR/xpath20/#id-literals

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
		Returns true or false based on "yes" or "no",
		accepting ("true" or "false") and ("1" or "0") as synonyms.
	-->
	<xsl:function as="xs:boolean" name="x:yes-no-synonym">
		<xsl:param as="xs:string" name="input" />

		<xsl:choose>
			<xsl:when test="$input = ('yes', 'true', '1')">
				<xsl:sequence select="true()" />
			</xsl:when>
			<xsl:when test="$input = ('no', 'false', '0')">
				<xsl:sequence select="false()" />
			</xsl:when>
		</xsl:choose>
	</xsl:function>

	<!--
		x:yes-no-synonym#1 plus default value in case of empty sequence
	-->
	<xsl:function as="xs:boolean" name="x:yes-no-synonym">
		<xsl:param as="xs:string?" name="input" />
		<xsl:param as="xs:boolean" name="default" />

		<xsl:sequence
			select="
				if (exists($input)) then
					x:yes-no-synonym($input)
				else
					$default"
		 />
	</xsl:function>

	<!--
		Returns the effective value of @xslt-version of the context element.
		
		$context is usually x:description or x:expect.
	-->
	<xsl:function as="xs:decimal" name="x:xslt-version">
		<xsl:param as="element()" name="context" />

		<xsl:sequence
			select="
				(
				$context/ancestor-or-self::*[@xslt-version][1]/@xslt-version,
				3.0
				)[1]"
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

	<!--
		Returns namespace nodes in the element excluding the same prefix as the element name.
		'xml' is excluded in the first place.

			Example:
				in:  <prefix1:e xmlns="default-ns" xmlns:prefix1="ns1" xmlns:prefix2="ns2" />
				out: xmlns="default-ns" and xmlns:prefix2="ns2"
	-->
	<xsl:function as="namespace-node()*" name="x:element-additional-namespace-nodes">
		<xsl:param as="element()" name="element" />

		<xsl:variable as="xs:string" name="element-name-prefix"
			select="
				$element
				=> node-name()
				=> prefix-from-QName()
				=> string()" />

		<!-- Sort for better serialization (hopefully) -->
		<xsl:perform-sort select="x:copy-of-namespaces($element)[name() ne $element-name-prefix]">
			<xsl:sort select="name()" />
		</xsl:perform-sort>
	</xsl:function>

	<!--
		Returns a lexical QName in the XSpec namespace. Usually 'x:local-name'.
		The prefix is taken from the context element's namespaces.
		If multiple namespace prefixes have the XSpec namespace URI,
			- The context element name's prefix is preferred.
			- If the context element's name is not in the XSpec namespace, the first prefix is used
			  after sorting them in a way that the default namespace is preferred.
	-->
	<xsl:function as="xs:string" name="x:xspec-name">
		<xsl:param as="xs:string" name="local-name" />
		<xsl:param as="element()" name="context-element" />

		<xsl:variable as="xs:QName" name="context-node-name" select="node-name($context-element)" />

		<xsl:variable as="xs:string?" name="prefix">
			<xsl:choose>
				<xsl:when test="namespace-uri-from-QName($context-node-name) eq $x:xspec-namespace">
					<xsl:sequence select="prefix-from-QName($context-node-name)" />
				</xsl:when>

				<xsl:otherwise>
					<xsl:variable as="xs:string+" name="xspec-prefixes"
						select="
							in-scope-prefixes($context-element)
							[namespace-uri-for-prefix(., $context-element) eq $x:xspec-namespace]" />
					<xsl:sequence select="sort($xspec-prefixes)[1]" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:sequence select="($prefix[.], $local-name) => string-join(':')" />
	</xsl:function>

</xsl:stylesheet>
