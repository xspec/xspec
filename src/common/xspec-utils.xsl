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
		Packs w.x.y.z version into uint64, assuming every component is uint16
			Example:
				in:  76, 0, 3809, 132
				out: 21392098479636612 (0x004C00000EE10084)
	-->
	<xsl:function as="xs:integer" name="x:pack-version">
		<xsl:param as="xs:integer" name="w" />
		<xsl:param as="xs:integer" name="x" />
		<xsl:param as="xs:integer" name="y" />
		<xsl:param as="xs:integer" name="z" />

		<!-- Shift by multiplying 0x10000 -->
		<xsl:variable as="xs:integer" name="high32" select="$w * 65536 + $x" />
		<xsl:variable as="xs:integer" name="low32" select="$y * 65536 + $z" />

		<!-- Shift by multiplying 0x100000000 -->
		<xsl:sequence select="$high32 * 4294967296 + $low32" />
	</xsl:function>

	<!--
		Extracts 4 version integers from string, assuming it contains zero or one
		"#.#.#.#" (# = ASCII numbers).
		Returns an empty sequence, if string contains no "#.#.#.#".
			Example:
				"HE 9.9.1.5"  -> 9, 9, 1, 5
				"１.２.３.４" -> ()
	-->
	<xsl:function as="xs:integer*" name="x:extract-version">
		<xsl:param as="xs:string" name="input" />

		<xsl:analyze-string regex="([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)" select="$input">
			<xsl:matching-substring>
				<xsl:sequence
					select="
						for $i in (1 to 4)
						return
							xs:integer(regex-group($i))"
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
	-->
	<xsl:function as="xs:integer?" name="x:saxon-version">
		<xsl:if test="system-property('xsl:product-name') eq 'SAXON'">
			<xsl:variable as="xs:integer+" name="versions"
				select="x:extract-version(system-property('xsl:product-version'))" />
			<xsl:sequence
				select="x:pack-version($versions[1], $versions[2], $versions[3], $versions[4])" />
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
				if (contains($decimal-string, '.'))
				then
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
				$context/ancestor-or-self::*[@xslt-version]/@xslt-version,
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

</xsl:stylesheet>
