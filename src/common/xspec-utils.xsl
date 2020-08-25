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
		Saxon version packed as uint64, based on 'xsl:product-version' system property, ignoring
		edition (EE, PE, HE).
		An empty sequence, if XSLT processor is not Saxon.
			Example:
				"EE 9.9.1.5"  -> 2533313445167109 (0x0009000900010005)
				"HE 9.3.0.11" -> 2533287675297809 (0x0009000300000011)
				"HE 10.0"     -> 2814749767106560 (0x000A000000000000)
	-->
	<xsl:variable as="xs:integer?" name="x:saxon-version">
		<xsl:if test="system-property('xsl:product-name') eq 'SAXON'">
			<xsl:variable as="xs:integer+" name="ver-components"
				select="
					system-property('xsl:product-version')
					=> x:extract-version()" />
			<xsl:sequence select="x:pack-version($ver-components)" />
		</xsl:if>
	</xsl:variable>

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
		Resolves URI (of an XML document) with the currently enabled catalog,
		working around an XML resolver bug
	-->
	<xsl:function as="xs:anyURI" name="x:resolve-xml-uri-with-catalog">
		<xsl:param as="xs:string" name="xml-uri" />

		<!-- https://sourceforge.net/p/saxon/mailman/message/36339785/
			"document-uri() returns the (absolutized) requested URI, while base-uri() returns
			the actual document location after catalog resolution." -->
		<xsl:sequence select="
				$xml-uri
				=> doc()
				=> x:base-uri()" />
	</xsl:function>

	<!--
		Returns the actual document URI (i.e. resolved with the currently enabled catalog),
		working around an XML resolver bug
	-->
	<xsl:function as="xs:anyURI" name="x:actual-document-uri">
		<xsl:param as="document-node()" name="doc" />

		<xsl:sequence
			select="
				$doc
				=> document-uri()
				=> x:resolve-xml-uri-with-catalog()" />
	</xsl:function>

	<!--
		Performs fn:base-uri(), working around an XML resolver bug
	-->
	<xsl:function as="xs:anyURI" name="x:base-uri">
		<xsl:param as="node()" name="node" />

		<!-- Fix invalid URI such as 'file:C:/dir/file'
			https://issues.apache.org/jira/browse/XMLCOMMONS-24 -->
		<xsl:sequence
			select="
				$node
				=> base-uri()
				=> replace('^(file:)([^/])', '$1/$2')
				=> xs:anyURI()"
		 />
	</xsl:function>

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
		Returns true if node is user-content
	-->
	<xsl:function as="xs:boolean" name="x:is-user-content">
		<xsl:param as="node()" name="node" />

		<xsl:sequence
			select="
				exists(
				$node/ancestor-or-self::node() intersect
				(
				$node/ancestor::x:context/node()[not(self::x:param)]
				| $node/ancestor::x:expect/node()[not(self::x:label)]
				| $node/ancestor::x:param/node()
				| $node/ancestor::x:variable/node()
				)
				)"
		 />
	</xsl:function>

	<!--
		Packs w.x.y.z version into uint64, assuming every component is uint16.
		x, y and z are optional (0 by default).
			Example:
				(76,  0, 3809, 132) -> 21392098479636612 (0x004C00000EE10084)
				( 1,  2,    3     ) ->   281483566841856 (0x0001000200030000)
				(10, 11           ) ->  2814797011746816 (0x000A000B00000000)
				( 9               ) ->  2533274790395904 (0x0009000000000000)
	-->
	<xsl:function as="xs:integer" name="x:pack-version">
		<xsl:param as="xs:integer+" name="ver-components" />

		<!-- 0x10000 -->
		<xsl:variable as="xs:integer" name="x10000" select="65536" />

		<!-- Return a value only when the input is valid. Return nothing if not valid, which
			effectively causes an error. -->
		<xsl:if
			test="
				(: 5th+ component is not allowed :)
				(count($ver-components) le 4)
				
				(: Every component must be uint16 :)
				and empty($ver-components[. ge $x10000]) and empty($ver-components[. lt 0])">
			<xsl:variable as="xs:integer" name="w" select="$ver-components[1]" />
			<xsl:variable as="xs:integer" name="x" select="($ver-components[2], 0)[1]" />
			<xsl:variable as="xs:integer" name="y" select="($ver-components[3], 0)[1]" />
			<xsl:variable as="xs:integer" name="z" select="($ver-components[4], 0)[1]" />

			<xsl:variable as="xs:integer" name="high32" select="($w * $x10000) + $x" />
			<xsl:variable as="xs:integer" name="low32" select="($y * $x10000) + $z" />
			<xsl:sequence select="($high32 * $x10000 * $x10000) + $low32" />
		</xsl:if>
	</xsl:function>

	<!--
		Extracts 4 version integers from string, assuming it contains zero or one
		"#.#.#.#" or "#.#" (# = ASCII numbers).
		Returns an empty sequence, if string contains no "#.#.#.#" or "#.#".
			Example:
				"HE 9.9.1.5"  -> 9, 9, 1, 5
				"１.２.３.４" -> ()
				"HE 10.1"     -> 10, 1, 0, 0
	-->
	<xsl:function as="xs:integer*" name="x:extract-version">
		<xsl:param as="xs:string" name="input" />

		<xsl:variable as="xs:string" name="regex" xml:space="preserve">
			([0-9]+)		<!-- group 1 -->
			\.
			([0-9]+)		<!-- group 2 -->
			(?:
				\.
				([0-9]+)	<!-- group 3 -->
				\.
				([0-9]+)	<!-- group 4 -->
			)?
		</xsl:variable>
		<xsl:analyze-string flags="x" regex="{$regex}" select="$input">
			<xsl:matching-substring>
				<xsl:sequence
					select="
						(1 to 4)
						! (regex-group(.)[.], 0)[1]
						! xs:integer(.)"
				 />
			</xsl:matching-substring>
		</xsl:analyze-string>
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
		Returns a semi-formatted string of URI
	-->
	<xsl:function as="xs:string" name="x:format-uri">
		<xsl:param as="xs:string" name="uri" />

		<xsl:choose>
			<xsl:when test="starts-with($uri, 'file:')">
				<!-- Remove 'file:' -->
				<xsl:variable as="xs:string" name="formatted" select="substring($uri, 6)" />

				<!-- Remove implicit localhost (Consolidate '///' to '/') -->
				<xsl:variable as="xs:string" name="formatted"
					select="replace($formatted, '^//(/)', '$1')" />

				<!-- Remove '/' from '/C:' -->
				<xsl:variable as="xs:string" name="formatted"
					select="replace($formatted, '^/([A-Za-z]:)', '$1')" />

				<!-- Unescape whitespace -->
				<xsl:sequence select="replace($formatted, '%20', ' ')" />
			</xsl:when>

			<xsl:otherwise>
				<xsl:sequence select="$uri" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!--
		Parses @preserve-space in x:description and returns a sequence of element QName.
		For those elements, child whitespace-only text nodes should be preserved in XSpec node-selection.
	-->
	<xsl:function as="xs:QName*" name="x:parse-preserve-space">
		<xsl:param as="element(x:description)" name="description" />

		<xsl:sequence
			select="
				tokenize($description/@preserve-space, '\s+')[.]
				! resolve-QName(., $description)"
		 />
	</xsl:function>

	<!--
		Returns true if whitespace-only text node is significant in XSpec node-selection.
		False if it is ignorable.
		
		$preserve-space is usually obtained by x:parse-preserve-space().
	-->
	<xsl:function as="xs:boolean" name="x:is-ws-only-text-node-significant">
		<xsl:param as="text()" name="ws-only-text-node" />
		<xsl:param as="xs:QName*" name="preserve-space-qnames" />

		<xsl:sequence
			select="
				$ws-only-text-node
				/(
				parent::x:text
				or (ancestor::*[@xml:space][1]/@xml:space eq 'preserve')
				or (node-name(parent::*) = $preserve-space-qnames)
				)"
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
