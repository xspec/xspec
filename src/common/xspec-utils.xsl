<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		XSpec 'deq' namespace URI
	-->
	<xsl:variable as="xs:anyURI" name="x:deq-namespace"
		select="xs:anyURI('urn:x-xspec:common:deep-equal')" />

	<!--
		XSpec 'rep' namespace URI
	-->
	<xsl:variable as="xs:anyURI" name="x:rep-namespace"
		select="xs:anyURI('urn:x-xspec:common:report-sequence')" />

	<!--
		XSpec 'x' namespace URI
	-->
	<xsl:variable as="xs:anyURI" name="x:xspec-namespace"
		select="xs:anyURI('http://www.jenitennison.com/xslt/xspec')" />

	<!--
		Standard 'xs' namespace URI
	-->
	<xsl:variable as="xs:anyURI" name="x:xs-namespace"
		select="xs:anyURI('http://www.w3.org/2001/XMLSchema')" />

	<!--
		Standard 'xsl' namespace URI
	-->
	<xsl:variable as="xs:anyURI" name="x:xsl-namespace"
		select="xs:anyURI('http://www.w3.org/1999/XSL/Transform')" />

	<!--
		U+0027
	-->
	<xsl:variable as="xs:string" name="x:apos">'</xsl:variable>

	<!--
		Regular expression to capture NCName
		
		Based on https://github.com/xspec/xspec/blob/fb7f63d8190a5ccfea5c6a21b2ee142164a7c92c/src/schemas/xspec.rnc#L329
	-->
	<xsl:variable as="xs:string" name="x:capture-NCName">([\i-[:]][\c-[:]]*)</xsl:variable>

	<!--
		Identity template
	-->
	<xsl:template as="node()" name="x:identity">
		<xsl:context-item as="node()" use="required" />

		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute() | node()" />
		</xsl:copy>
	</xsl:template>

	<!--
		Makes copies of namespaces from element
		The standard 'xml' namespace is excluded.
	-->
	<xsl:function as="namespace-node()*" name="x:copy-of-namespaces">
		<xsl:param as="element()" name="element" />

		<xsl:for-each select="in-scope-prefixes($element)[. ne 'xml']">
			<xsl:namespace name="{.}" select="namespace-uri-for-prefix(., $element)" />
		</xsl:for-each>
	</xsl:function>

	<!--
		Returns node type
			Example: 'element'
	-->
	<xsl:function as="xs:string" name="x:node-type">
		<xsl:param as="node()" name="node" />

		<xsl:choose>
			<xsl:when test="$node instance of attribute()">attribute</xsl:when>
			<xsl:when test="$node instance of comment()">comment</xsl:when>
			<xsl:when test="$node instance of document-node()">document-node</xsl:when>
			<xsl:when test="$node instance of element()">element</xsl:when>
			<xsl:when test="$node instance of namespace-node()">namespace-node</xsl:when>
			<xsl:when test="$node instance of processing-instruction()"
				>processing-instruction</xsl:when>
			<xsl:when test="$node instance of text()">text</xsl:when>
			<xsl:otherwise>node</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!--
		Returns true if item is function (including map and array).
		
		Alternative to "instance of function(*)" which is not widely available.
	-->
	<xsl:function as="xs:boolean" name="x:instance-of-function">
		<xsl:param as="item()" name="item" />

		<xsl:choose>
			<xsl:when test="($item instance of array(*)) or ($item instance of map(*))">
				<xsl:sequence select="true()" />
			</xsl:when>

			<xsl:when test="$item instance of function(*)"
				use-when="function-available('function-lookup')">
				<xsl:sequence select="true()" />
			</xsl:when>

			<xsl:otherwise>
				<xsl:sequence select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!--
		Returns type of function (including map and array).
		
		$function must be an instance of function(*).
	-->
	<xsl:function as="xs:string" name="x:function-type">

		<!-- TODO: @as="function(*)" -->
		<xsl:param as="item()" name="function" />

		<xsl:choose>
			<xsl:when test="$function instance of array(*)">array</xsl:when>
			<xsl:when test="$function instance of map(*)">map</xsl:when>
			<xsl:otherwise>function</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

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
		Removes leading whitespace
	-->
	<xsl:function as="xs:string" name="x:left-trim">
		<xsl:param as="xs:string" name="input" />

		<xsl:sequence select="replace($input, '^\s+', '')" />
	</xsl:function>

	<!--
		Removes trailing whitespace
	-->
	<xsl:function as="xs:string" name="x:right-trim">
		<xsl:param as="xs:string" name="input" />

		<xsl:sequence select="replace($input, '\s+$', '')" />
	</xsl:function>

	<!--
		Removes leading and trailing whitespace
	-->
	<xsl:function as="xs:string" name="x:trim">
		<xsl:param as="xs:string" name="input" />

		<xsl:sequence select="
				$input
				=> x:right-trim()
				=> x:left-trim()" />
	</xsl:function>

	<!--
		Resolves URIQualifiedName to xs:QName
	-->
	<xsl:function as="xs:QName" name="x:resolve-UQName">
		<xsl:param as="xs:string" name="uqname" />

		<xsl:variable as="xs:string" name="regex">
			<xsl:value-of xml:space="preserve">
				<!-- based on https://github.com/xspec/xspec/blob/fb7f63d8190a5ccfea5c6a21b2ee142164a7c92c/src/schemas/xspec.rnc#L329 -->
				^
					Q\{
						([^\{\}]*)								<!-- group 1: URI -->
					\}
					<xsl:value-of select="$x:capture-NCName" />	<!-- group 2: local name -->
				$
			</xsl:value-of>
		</xsl:variable>

		<xsl:analyze-string flags="x" regex="{$regex}" select="$uqname">
			<xsl:matching-substring>
				<xsl:sequence select="QName(regex-group(1), regex-group(2))" />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>

	<!--
		Resolves EQName (either URIQualifiedName or lexical QName, the latter is
		resolved without using the default namespace) to xs:QName.
		
		Unlike fn:resolve-QName(), this function can handle XSLT names in many cases. See
		"Notes" in https://www.w3.org/TR/xpath-functions-31/#func-resolve-QName or more
		specifically p.866 of XSLT 2.0 and XPath 2.0 Programmer's Reference, 4th Edition.
	-->
	<xsl:function as="xs:QName" name="x:resolve-EQName-ignoring-default-ns">
		<xsl:param as="xs:string" name="eqname" />
		<xsl:param as="element()" name="element" />

		<xsl:choose>
			<xsl:when test="starts-with($eqname, 'Q{')">
				<xsl:sequence select="x:resolve-UQName($eqname)" />
			</xsl:when>

			<xsl:otherwise>
				<!-- To suppress "SXWN9000: ... QName has null namespace but non-empty prefix",
					do not pass the lexical QName directly to fn:QName(). (xspec/xspec#826) -->
				<xsl:variable as="xs:QName" name="qname-taking-default-ns"
					select="resolve-QName($eqname, $element)" />

				<xsl:sequence
					select="
						if (prefix-from-QName($qname-taking-default-ns)) then
							$qname-taking-default-ns
						else
							QName('', local-name-from-QName($qname-taking-default-ns))"
				 />
			</xsl:otherwise>
		</xsl:choose>
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
		Resolves EQName (either URIQualifiedName or lexical QName, the latter is
		resolved without using the default namespace) to xs:QName
		and returns an XPath expression of fn:QName() which represents the resolved xs:QName.
	-->
	<xsl:function as="xs:string" name="x:QName-expression-from-EQName-ignoring-default-ns">
		<xsl:param as="xs:string" name="eqname" />
		<xsl:param as="element()" name="element" />

		<xsl:variable as="xs:QName" name="qname"
			select="x:resolve-EQName-ignoring-default-ns($eqname, $element)" />

		<xsl:sequence select="x:QName-expression($qname)" />
	</xsl:function>

	<!--
		Constructs URIQualifiedName from namespace URI and local name
	-->
	<xsl:function as="xs:string" name="x:UQName">
		<xsl:param as="xs:string" name="namespace-uri" />
		<xsl:param as="xs:string" name="local-name" />

		<xsl:sequence select="'Q{' || $namespace-uri || '}' || $local-name" />
	</xsl:function>

	<!--
		Returns URIQualifiedName constructed from known prefixes
	-->
	<xsl:function as="xs:string" name="x:known-UQName">
		<xsl:param as="xs:string" name="lexical-qname" />

		<xsl:variable as="xs:string" name="prefix" select="substring-before($lexical-qname, ':')" />
		<xsl:variable as="xs:string" name="local-name" select="substring-after($lexical-qname, ':')" />

		<xsl:variable as="xs:string" name="namespace">
			<xsl:choose>
				<xsl:when test="$prefix eq 'config'">
					<xsl:sequence select="'http://saxon.sf.net/ns/configuration'" />
				</xsl:when>
				<xsl:when test="$prefix eq 'deq'">
					<xsl:sequence select="$x:deq-namespace" />
				</xsl:when>
				<xsl:when test="$prefix eq 'err'">
					<xsl:sequence select="'http://www.w3.org/2005/xqt-errors'" />
				</xsl:when>
				<xsl:when test="$prefix eq 'impl'">
					<xsl:sequence select="'urn:x-xspec:compile:impl'" />
				</xsl:when>
				<xsl:when test="$prefix eq 'map'">
					<xsl:sequence select="'http://www.w3.org/2005/xpath-functions/map'" />
				</xsl:when>
				<xsl:when test="$prefix eq 'output'">
					<xsl:sequence select="'http://www.w3.org/2010/xslt-xquery-serialization'" />
				</xsl:when>
				<xsl:when test="$prefix eq 'rep'">
					<xsl:sequence select="$x:rep-namespace" />
				</xsl:when>
				<xsl:when test="$prefix eq 'svrl'">
					<xsl:sequence select="'http://purl.oclc.org/dsdl/svrl'" />
				</xsl:when>
				<xsl:when test="$prefix eq 'x'">
					<xsl:sequence select="$x:xspec-namespace" />
				</xsl:when>
				<xsl:when test="$prefix eq 'xs'">
					<xsl:sequence select="$x:xs-namespace" />
				</xsl:when>
				<xsl:when test="$prefix eq 'xsl'">
					<xsl:sequence select="$x:xsl-namespace" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:sequence select="x:UQName($namespace, $local-name)" />
	</xsl:function>

	<!--
		Returns URIQualifiedName of the variable generated by mode="x:declare-variable"
	-->
	<xsl:function as="xs:string" name="x:variable-UQName">
		<xsl:param as="element()" name="source-element" />

		<!-- xsl:for-each is not for iteration but for simplifying XPath -->
		<xsl:for-each select="$source-element">
			<xsl:choose>
				<xsl:when test="@name">
					<xsl:sequence select="x:UQName-from-EQName-ignoring-default-ns(@name, .)" />
				</xsl:when>

				<xsl:otherwise>
					<xsl:sequence
						select="x:known-UQName('impl:' || local-name() || '-' || generate-id())" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:function>

	<!--
		Expands EQName (either URIQualifiedName or lexical QName, the latter is
		resolved without using the default namespace) to URIQualifiedName.
	-->
	<xsl:function as="xs:string" name="x:UQName-from-EQName-ignoring-default-ns">
		<xsl:param as="xs:string" name="eqname" />
		<xsl:param as="element()" name="element" />

		<xsl:variable as="xs:QName" name="qname"
			select="x:resolve-EQName-ignoring-default-ns($eqname, $element)" />
		<xsl:sequence
			select="
				x:UQName(
				namespace-uri-from-QName($qname),
				local-name-from-QName($qname)
				)"
		 />
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
