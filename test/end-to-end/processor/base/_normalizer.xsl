<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module helps normalize the document.
	-->

	<!--
		Converts an absolute URI to a relative URI
			This is an ad hoc implementation only suitable for the report files.

			Example:
				in:  input-uri='file:/path/to/xspec/src/reporter/format-xspec-report.xsl',
				      base-uri='file:/path/to/xspec/test/end-to-end/cases/expected/stylesheet/coverage-tutorial-result.xml'
				out: '../../../../../src/reporter/format-xspec-report.xsl'
	-->
	<xsl:function as="xs:anyURI" name="normalizer:relative-uri">
		<xsl:param as="xs:string" name="input-uri" />
		<xsl:param as="xs:anyURI" name="base-uri" />

		<xsl:variable as="xs:string+" name="input-tokens" select="tokenize($input-uri, '/')" />
		<xsl:variable as="xs:string+" name="base-tokens" select="tokenize($base-uri, '/')" />

		<xsl:variable as="xs:integer" name="num-base-tokens" select="count($base-tokens)" />
		<xsl:variable as="xs:integer" name="num-overlapped"
			select="min((count($input-tokens), $num-base-tokens))" />

		<xsl:variable as="xs:integer+" name="match-positions"
			select="
				for $position in (1 to $num-overlapped)
				return
					$position[$input-tokens[$position] eq $base-tokens[$position]]" />
		<xsl:variable as="xs:integer" name="last-contiguous-match-position"
			select="$match-positions[. eq position()][last()]" />

		<xsl:variable as="xs:string+" name="up-from-base"
			select="
				for $i in (1 to ($num-base-tokens - $last-contiguous-match-position - 1))
				return
					'..'" />

		<xsl:variable as="xs:string+" name="relative-tokens"
			select="
				$up-from-base,
				subsequence($input-tokens, $last-contiguous-match-position + 1)" />

		<xsl:sequence select="string-join($relative-tokens, '/') cast as xs:anyURI" />
	</xsl:function>

	<!--
		Normalizes the link to the files created dynamically by XSpec
			XSpec names them using fn:generate-id().
			This template makes them predictable while keeping uniqueness within document.
	-->
	<xsl:template as="attribute()" name="normalizer:normalize-external-link-attribute">
		<xsl:context-item as="attribute(href)" use="required"
			use-when="element-available('xsl:context-item')" />

		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<!-- Absolute URI -->
		<xsl:variable as="xs:anyURI" name="this-uri" select="resolve-uri(., $tunnel_document-uri)" />

		<!-- Attributes of the same name -->
		<xsl:variable as="attribute()+" name="same-name-attrs"
			select="//attribute()[node-name(.) eq node-name(current())]" />

		<!-- External absolute URIs -->
		<xsl:variable as="xs:anyURI+" name="uris"
			select="
				for $attr in $same-name-attrs[not(starts-with(., '#'))]
				return
					resolve-uri($attr, $tunnel_document-uri)" />

		<!-- Index where the same URI first appears -->
		<xsl:variable as="xs:integer" name="first-index" select="index-of($uris, $this-uri)[1]" />

		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="concat(upper-case(local-name()), '-', $first-index)" />
	</xsl:template>

	<!--
		mode=normalize
			Normalizes the transient parts of the document such as @href, @id, datetime and file path
	-->

	<!-- Identity template, in lowest priority -->
	<xsl:template as="node()" match="document-node() | attribute() | node()"
		mode="normalizer:normalize" priority="-1">
		<xsl:call-template name="x:identity" />
	</xsl:template>

	<!-- The other processing depends on each processor... -->
</xsl:stylesheet>
