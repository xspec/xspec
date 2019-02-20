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
