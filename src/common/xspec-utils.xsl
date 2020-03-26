<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module is a collection of common utilities used across component borders
		Elements in this stylesheet must not affect the other stylesheets.
	-->

	<!--
		Identity template
	-->
	<xsl:template as="node()" name="x:identity">
		<xsl:context-item as="node()" use="required"
			use-when="element-available('xsl:context-item')" />

		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute() | node()" />
		</xsl:copy>
	</xsl:template>

	<!--
		Extracts filename (with extension) from slash-delimited path
			Example:
				in:  "file:/path/to/foo.bar.baz" or "/path/to/foo.bar.baz"
				out: "foo.bar.baz"
	-->
	<xsl:function as="xs:string" name="x:filename-and-extension">
		<xsl:param as="xs:string" name="input" />

		<xsl:sequence select="tokenize($input, '/')[last()]" />
	</xsl:function>

	<!--
		Extracts filename (without extension) from slash-delimited path
			Example:
				in:  "file:/path/to/foo.bar.baz" or "/path/to/foo.bar.baz"
				out: "foo.bar"
	-->
	<xsl:function as="xs:string" name="x:filename-without-extension">
		<xsl:param as="xs:string" name="input" />

		<xsl:variable as="xs:string" name="filename-and-extension"
			select="x:filename-and-extension($input)" />

		<xsl:sequence
			select="
				if (contains($filename-and-extension, '.')) then
					replace($filename-and-extension, '^(.*)\.[^.]*$', '$1')
				else
					$filename-and-extension"
		 />
	</xsl:function>

	<!--
		Extracts extension (without filename) from slash-delimited path
			Example:
				in:  "file:/path/to/foo.bar.baz" or "/path/to/foo.bar.baz"
				out: ".baz"
	-->
	<xsl:function as="xs:string" name="x:extension-without-filename">
		<xsl:param as="xs:string" name="input" />

		<xsl:variable as="xs:string" name="filename-and-extension"
			select="x:filename-and-extension($input)" />

		<xsl:sequence
			select="
				if (contains($filename-and-extension, '.')) then
					replace($filename-and-extension, '^.*(\.[^.]*)$', '$1')
				else
					''"
		 />
	</xsl:function>

	<!--
		Resolves URI (of an XML document) with the currently enabled catalog,
		working around an XML resolver bug
	-->
	<xsl:function as="xs:anyURI" name="x:resolve-xml-uri-with-catalog">
		<xsl:param as="xs:string" name="xml-uri" />

		<!-- https://sourceforge.net/p/saxon/mailman/message/36339785/
			"document-uri() returns the (absolutized) requested URI, while base-uri() returns
			the actual document location after catalog resolution." -->
		<xsl:sequence select="x:base-uri(doc($xml-uri))" />
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
				replace(base-uri($node), '^(file:)([^/])', '$1/$2')
				cast as xs:anyURI"
		 />
	</xsl:function>

	<!--
		Copies namespaces of element
	-->
	<xsl:function as="node()*" name="x:copy-namespaces">
		<xsl:param as="element()" name="e" />

		<xsl:for-each select="in-scope-prefixes($e)">
			<xsl:namespace name="{.}" select="namespace-uri-for-prefix(., $e)" />
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
			<xsl:when test="x:instance-of-namespace($node)">namespace-node</xsl:when>
			<xsl:when test="$node instance of processing-instruction()"
				>processing-instruction</xsl:when>
			<xsl:when test="$node instance of text()">text</xsl:when>
			<xsl:otherwise>node</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!--
		Returns true if item is namespace node
	-->
	<xsl:function as="xs:boolean" name="x:instance-of-namespace">
		<xsl:param as="item()?" name="item" />

		<!-- Unfortunately "instance of namespace-node()" is not available on XPath 2.0:
			http://www.biglist.com/lists/lists.mulberrytech.com/xsl-list/archives/200608/msg00719.html -->
		<xsl:sequence
			select="
				($item instance of node())
				and
				not(
				($item instance of attribute())
				or ($item instance of comment())
				or ($item instance of document-node())
				or ($item instance of element())
				or ($item instance of processing-instruction())
				or ($item instance of text())
				)"
		 />
	</xsl:function>

	<!--
		Returns true if item is function (including map and array).
		
		Alternative to "instance of function(*)" which is not widely available.
	-->
	<xsl:function as="xs:boolean" name="x:instance-of-function">
		<xsl:param as="item()" name="item" />

		<xsl:choose>
			<xsl:when test="($item instance of array(*)) or ($item instance of map(*))"
				use-when="number(system-property('xsl:version')) ge 3">
				<xsl:sequence select="true()" />
			</xsl:when>

			<xsl:when test="$item instance of function(*)"
				use-when="
					((: for Saxon-EE 9.7 :) number(system-property('xsl:version')) ge 3)
					and
					((: for Saxon 9.x :) function-available('function-lookup'))">
				<xsl:sequence select="true()" />
			</xsl:when>

			<xsl:when test="true()">
				<xsl:sequence select="false()" />
			</xsl:when>
		</xsl:choose>
	</xsl:function>

	<!--
		Returns type of function (including map and array).
		
		$function must be an instance of function(*).
	-->
	<xsl:function as="xs:string" name="x:function-type"
		use-when="number(system-property('xsl:version')) ge 3">

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

		<xsl:analyze-string regex="([0-9]+)\.([0-9]+)(\.([0-9]+)\.([0-9]+))?" select="$input">
			<xsl:matching-substring>
				<xsl:sequence
					select="
						for $i in (1, 2, 4, 5)
						return
							xs:integer((regex-group($i)[.], 0)[1])"
				 />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>

	<!--
		Returns Saxon version packed as uint64, based on 'xsl:product-version' system property,
		ignoring edition (EE, PE, HE).
		Returns an empty sequence, if XSLT processor is not Saxon.
			Example:
				"EE 9.9.1.5"  -> 2533313445167109 (0x0009000900010005)
				"HE 9.3.0.11" -> 2533287675297809 (0x0009000300000011)
				"HE 10.0"     -> 2814749767106560 (0x000A000000000000)
	-->
	<xsl:function as="xs:integer?" name="x:saxon-version">
		<xsl:if test="system-property('xsl:product-name') eq 'SAXON'">
			<xsl:variable as="xs:integer+" name="ver-components"
				select="x:extract-version(system-property('xsl:product-version'))" />
			<xsl:sequence select="x:pack-version($ver-components)" />
		</xsl:if>
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
					concat($decimal-string, '.0')"
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
				for $lexical-qname in tokenize($description/@preserve-space, '\s+')[.]
				return
					resolve-QName($lexical-qname, $description)"
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
				2.0
				)[1]"
		 />
	</xsl:function>

	<!--
		Makes absolute URI from x:description/@schematron and resolves it with catalog
	-->
	<xsl:function as="xs:anyURI" name="x:locate-schematron-uri">
		<xsl:param as="element(x:description)" name="description" />

		<!-- Resolve with node base URI -->
		<xsl:variable as="xs:anyURI" name="schematron-uri"
			select="$description/@schematron/resolve-uri(., base-uri())" />

		<!-- Resolve with catalog -->
		<xsl:sequence select="x:resolve-xml-uri-with-catalog($schematron-uri)" />
	</xsl:function>

	<!--
		Stub function for helping development on IDE without loading ../../java/
	-->
	<xsl:function as="xs:integer" name="x:line-number" override-extension-function="no"
		use-when="
			function-available('saxon:line-number')
			and
			(: Saxon 9.7 doesn't accept @override-extension-function when /xsl:stylesheet/@version
				isn't 3.0 :) (xs:decimal(system-property('xsl:version')) ge 3.0)"
		xmlns:saxon="http://saxon.sf.net/">
		<xsl:param as="node()" name="node" />

		<xsl:sequence select="saxon:line-number($node)" />
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

		<xsl:sequence select="x:left-trim(x:right-trim($input))" />
	</xsl:function>

	<!--
		Resolves URIQualifiedName to xs:QName
	-->
	<xsl:function as="xs:QName" name="x:resolve-URIQualifiedName">
		<xsl:param as="xs:string" name="uri-qualified-name" />

		<xsl:variable as="xs:string" name="regex" xml:space="preserve">
			<!-- based on https://github.com/xspec/xspec/blob/fb7f63d8190a5ccfea5c6a21b2ee142164a7c92c/src/schemas/xspec.rnc#L329 -->
			^
				Q\{
					([^\{\}]*)		<!-- group 1: URI -->
				\}
				([\i-[:]][\c-[:]]*)	<!-- group 2: local name -->
			$
		</xsl:variable>

		<xsl:analyze-string flags="x" regex="{$regex}" select="$uri-qualified-name">
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
				<xsl:sequence select="x:resolve-URIQualifiedName($eqname)" />
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
		Returns true if two QNames are exactly equal to each other.
		
		Unlike fn:deep-equal() or 'eq' operator, this function compares prefix.
	-->
	<xsl:function as="xs:boolean" name="x:QName-exactly-equal">
		<xsl:param as="xs:QName" name="qname1" />
		<xsl:param as="xs:QName" name="qname2" />

		<xsl:sequence
			select="
				deep-equal($qname1, $qname2)
				and
				deep-equal(prefix-from-QName($qname1), prefix-from-QName($qname2))"
		 />
	</xsl:function>

	<!--
		Returns XPath expression of fn:QName() which represents the given xs:QName
	-->
	<xsl:function as="xs:string" name="x:QName-expression">
		<xsl:param as="xs:QName" name="qname" />

		<xsl:variable as="xs:string" name="escaped-uri"
			select="
				replace(
				namespace-uri-from-QName($qname),
				'('')',
				'$1$1'
				)" />

		<xsl:value-of>
			<xsl:text>QName('</xsl:text>
			<xsl:value-of select="$escaped-uri" />
			<xsl:text>', '</xsl:text>
			<xsl:value-of select="$qname" />
			<xsl:text>')</xsl:text>
		</xsl:value-of>
	</xsl:function>

</xsl:stylesheet>
