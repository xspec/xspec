<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:deserializer="x-urn:xspec:test:end-to-end:processor:deserializer"
	xmlns:local="x-urn:xspec:test:end-to-end:processor:base:compare:local"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:saxon="http://saxon.sf.net/"
	xmlns:serializer="x-urn:xspec:test:end-to-end:processor:serializer"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This master stylesheet is a basis for comparing the input document with the expected file.
			* Before comparing, the input document is normalized.
		
		Each processor must import this stylesheet and provide its own deserializer, normalizer and serializer.
	-->

	<xsl:include href="../../../../src/common/xspec-utils.xsl" />
	<xsl:include href="_deserializer.xsl" />
	<xsl:include href="_normalizer.xsl" />
	<xsl:include href="_serializer.xsl" />

	<xsl:output method="text" />

	<!--
		URI of the expected report file
			Its content must be already normalized by the 'normalizer:normalize' template.
	-->
	<xsl:param as="xs:anyURI" name="EXPECTED-DOC-URI" required="yes" />

	<xsl:param as="xs:boolean" name="DEBUG" select="false()" />

	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="empty-sequence()" match="document-node()">
		<!-- Absolute URI of input document -->
		<xsl:variable as="xs:anyURI" name="input-doc-uri" select="document-uri(/)" />

		<xsl:message>
			<xsl:text>Comparing&#x0A;</xsl:text>
			<xsl:text expand-text="yes">   Actual: {$input-doc-uri}&#x0A;</xsl:text>
			<xsl:text expand-text="yes"> Expected: {$EXPECTED-DOC-URI}</xsl:text>
		</xsl:message>

		<!-- Load the expected report file -->
		<xsl:variable as="document-node()" name="expected-doc">
			<xsl:apply-templates mode="deserializer:unindent" select="doc($EXPECTED-DOC-URI)" />
		</xsl:variable>

		<!-- Normalize the input document -->
		<xsl:variable as="document-node()" name="input-doc">
			<xsl:apply-templates mode="deserializer:unindent" select="." />
		</xsl:variable>
		<xsl:variable as="document-node()" name="normalized-input-doc">
			<xsl:apply-templates mode="normalizer:normalize" select="$input-doc">
				<xsl:with-param name="tunnel_document-uri" select="$input-doc-uri" tunnel="yes" />
			</xsl:apply-templates>
		</xsl:variable>

		<!-- Compare the normalized input document with the expected document -->
		<xsl:variable as="xs:boolean" name="comparison-result"
			select="local:single-node-deep-equal($normalized-input-doc, $expected-doc)" />

		<!-- Diagnostic output -->
		<xsl:if test="not($comparison-result) or $DEBUG">
			<!-- Save the normalized input document -->
			<xsl:variable as="xs:anyURI" name="save-normalized-input-uri"
				select="
					(x:filename-without-extension($input-doc-uri) || '-norm' || x:extension-without-filename($input-doc-uri))
					=> resolve-uri($input-doc-uri)" />
			<xsl:result-document format="serializer:output" href="{$save-normalized-input-uri}">
				<xsl:sequence select="$normalized-input-doc" />
			</xsl:result-document>
			<xsl:message select="'Saved the normalized input:', $save-normalized-input-uri" />

			<!-- Print the documents -->
			<xsl:message select="'[NORMALIZED INPUT]', $normalized-input-doc" />
			<xsl:message select="'[EXPECTED]', $expected-doc" />
		</xsl:if>

		<!--
			If saxon:deep-equal() is available (requires Saxon-PE),
			* Double-check the result with its 'NFCP' flags.
			* Print the diff by '?' flag.
		-->
		<xsl:if
			test="
				saxon:deep-equal($normalized-input-doc, $expected-doc, (), 'NFCP?')
				ne $comparison-result"
			use-when="function-available('saxon:deep-equal')">
			<!-- Terminate if saxon:deep-equal() contradicts the comparison result -->
			<xsl:message terminate="yes" />
		</xsl:if>

		<!-- Output the comparison result, terminating on comparison failure -->
		<xsl:message select="
				if ($comparison-result) then
					'OK'
				else
					'FAILED'"
			terminate="{not($comparison-result)}" />
	</xsl:template>

	<!--
		Private utility functions
	-->

	<!--
		Compares two nodes like saxon:deep-equal() with flags="NFCP":
			http://www.saxonica.com/documentation/index.html#!functions/saxon/deep-equal
			N  Include namespace nodes in the comparison. For two elements to be deep-equal, they must have the same in-scope namespaces (that is, same prefix and same URI).
			F  Include namespace prefixes in the comparison. For two elements or attributes to be equal, their names must use the same namespace prefix (or none).
			C  Include comment nodes in the comparison. For two element or document nodes to be deep-equal, they must have the same comment node children.
			P  Include processing-instruction nodes in the comparison. For two element or document nodes to be deep-equal, they must have the same processing-instruction node children.
	-->
	<xsl:function as="xs:boolean" name="local:single-node-deep-equal">
		<xsl:param as="node()" name="node1" />
		<xsl:param as="node()" name="node2" />

		<xsl:choose>
			<xsl:when
				test="
					$node1 instance of document-node()
					and $node2 instance of document-node()">
				<xsl:sequence select="local:nodes-deep-equal($node1/node(), $node2/node())" />
			</xsl:when>

			<xsl:when
				test="
					$node1 instance of element()
					and $node2 instance of element()">
				<xsl:variable as="attribute()*" name="attrs1">
					<xsl:perform-sort select="$node1/attribute()">
						<xsl:sort select="name()" />
					</xsl:perform-sort>
				</xsl:variable>
				<xsl:variable as="attribute()*" name="attrs2">
					<xsl:perform-sort select="$node2/attribute()">
						<xsl:sort select="name()" />
					</xsl:perform-sort>
				</xsl:variable>

				<xsl:sequence
					select="
						local:node-name-equal($node1, $node2)
						and local:in-scope-ns-equal($node1, $node2)
						and local:nodes-deep-equal($attrs1, $attrs2)
						and local:nodes-deep-equal($node1/node(), $node2/node())"
				 />
			</xsl:when>

			<xsl:when
				test="
					$node1 instance of attribute()
					and $node2 instance of attribute()">
				<xsl:sequence
					select="
						local:node-name-equal($node1, $node2)
						and ($node1 eq $node2)"
				 />
			</xsl:when>

			<xsl:otherwise>
				<xsl:sequence select="deep-equal($node1, $node2)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!--
		Dispatches sequence of nodes to local:single-node-deep-equal()
	-->
	<xsl:function as="xs:boolean" name="local:nodes-deep-equal">
		<xsl:param as="node()*" name="nodes1" />
		<xsl:param as="node()*" name="nodes2" />

		<xsl:choose>
			<xsl:when test="empty($nodes1) or empty($nodes2)">
				<xsl:sequence select="empty($nodes1) and empty($nodes2)" />
			</xsl:when>

			<xsl:when test="count($nodes1) eq count($nodes2)">
				<xsl:sequence
					select="
						every $position in (1 to count($nodes1))
							satisfies local:single-node-deep-equal($nodes1[$position], $nodes2[$position])"
				 />
			</xsl:when>

			<xsl:otherwise>
				<xsl:sequence select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!--
		Returns true if elements or attributes have the same name including namespace URI and
		namespace prefix
	-->
	<xsl:function as="xs:boolean" name="local:node-name-equal">
		<xsl:param as="node()" name="node1" />
		<xsl:param as="node()" name="node2" />

		<xsl:sequence select="x:QName-exactly-equal(node-name($node1), node-name($node2))" />
	</xsl:function>

	<!--
		Returns true if elements have the same set of namespace prefixes
	-->
	<xsl:function as="xs:boolean" name="local:in-scope-ns-equal">
		<xsl:param as="element()" name="elem1" />
		<xsl:param as="element()" name="elem2" />

		<xsl:variable as="xs:string*" name="prefixes1">
			<xsl:perform-sort select="in-scope-prefixes($elem1)">
				<xsl:sort select="." />
			</xsl:perform-sort>
		</xsl:variable>
		<xsl:variable as="xs:string*" name="prefixes2">
			<xsl:perform-sort select="in-scope-prefixes($elem2)">
				<xsl:sort select="." />
			</xsl:perform-sort>
		</xsl:variable>

		<xsl:sequence
			select="
				(count($prefixes1) eq count($prefixes2))
				and (every $prefix in $prefixes1
					satisfies
					namespace-uri-for-prefix($prefix, $elem1)
					eq namespace-uri-for-prefix($prefix, $elem2))"
		 />
	</xsl:function>

</xsl:stylesheet>
