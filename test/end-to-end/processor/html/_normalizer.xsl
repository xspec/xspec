<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:local="x-urn:xspec:test:end-to-end:processor:html:normalizer:local"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.w3.org/1999/xhtml">

	<!--
		This stylesheet module helps normalize the test result HTML.
	-->

	<!--
		Normalizes the title text
			Example:
				in:  <title>Test Report for /path/to/tested.xsl (passed: 2 / pending: 0 / failed: 1 / total: 3)</title>
				out: <title>Test Report for tested.xsl (passed: 2 / pending: 0 / failed: 1 / total: 3)</title>
	-->
	<xsl:template as="text()" match="/html[not(local:is-xquery-report(.))]/head/title/text()"
		mode="normalizer:normalize">
		<xsl:analyze-string regex="^(Test Report for) (.+) (\([a-z0-9/: ]+\))$" select=".">
			<xsl:matching-substring>
				<xsl:value-of
					select="
						regex-group(1),
						x:filename-and-extension(regex-group(2)),
						regex-group(3)"
					separator=" " />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<!--
		Replaces the embedded CSS with the link to its source
			For brevity. The details of style are not critical anyway.
	-->
	<xsl:template as="element(link)" match="/html/head/style" mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<!-- Absolute URI of CSS -->
		<xsl:variable as="xs:anyURI" name="css-uri"
			select="resolve-uri('../../../../src/reporter/test-report.css')" />

		<link rel="stylesheet" type="text/css" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="href"
				select="normalizer:relative-uri($css-uri, $tunnel_document-uri)" />
		</link>
	</xsl:template>

	<!--
		Normalizes the links to the tested module and the XSpec file
			Example:
				in:  <a href="file:/path/to/tested.xsl">/path/to/tested.xsl</a>
				out: <a href="../path/to/tested.xsl">tested.xsl</a>
	-->
	<xsl:template as="element(a)" match="/html/body/p/a" mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute()" />
			<xsl:for-each select="@href">
				<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
					select="normalizer:relative-uri(., $tunnel_document-uri)" />
			</xsl:for-each>

			<xsl:value-of select="x:filename-and-extension(.)" />
		</xsl:copy>
	</xsl:template>

	<!--
		Normalizes the link to the files created dynamically by XSpec
	-->
	<xsl:template as="attribute(href)"
		match="table[tokenize(@class, '\s+')[.] = 'xspecResult']/tbody/tr/td/p/a/@href"
		mode="normalizer:normalize">
		<xsl:call-template name="normalizer:normalize-external-link-attribute" />
	</xsl:template>

	<xsl:template as="text()"
		match="table[tokenize(@class, '\s+')[.] = 'xspecResult']/tbody/tr/td/p/a[. eq @href]/text()"
		mode="normalizer:normalize">
		<xsl:value-of>
			<xsl:for-each select="parent::a/@href">
				<xsl:call-template name="normalizer:normalize-external-link-attribute" />
			</xsl:for-each>
		</xsl:value-of>
	</xsl:template>

	<!--
		Normalizes svrl:active-pattern/@document in Schematron Result
			Example:
				in:  <svrl:active-pattern document="file:/.../tutorial/schematron/demo-02.xml"
				out: <svrl:active-pattern document="../../../../../tutorial/schematron/demo-02.xml"
	-->
	<xsl:template as="text()"
		match="table[@class eq 'xspecResult'][local:is-schematron-report(.)]/tbody/tr/td[1]/pre/text()"
		mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:variable name="regex"
			><![CDATA[^( +<svrl:active-pattern document=")(.+?)(")$]]></xsl:variable>

		<xsl:value-of>
			<xsl:analyze-string flags="m" regex="{$regex}" select=".">
				<xsl:matching-substring>
					<xsl:sequence
						select="
							regex-group(1),
							normalizer:relative-uri(regex-group(2), $tunnel_document-uri),
							regex-group(3)"
					 />
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:copy />
				</xsl:non-matching-substring>
			</xsl:analyze-string>
		</xsl:value-of>
	</xsl:template>

	<!-- Makes @id predictable -->
	<xsl:template as="attribute(id)" match="@id" mode="normalizer:normalize"
		name="normalize-id-attribute">
		<xsl:context-item as="attribute(id)" use="required"
			use-when="element-available('xsl:context-item')" />

		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="local:generate-predictable-id(parent::element())" />
	</xsl:template>

	<!--
		Makes the in-page link follow its target element
			@id of the target element is normalized by the 'normalize-id-attribute' template. So @href has to follow it.
	-->
	<xsl:template as="attribute(href)" match="@href[starts-with(., '#')]"
		mode="normalizer:normalize">
		<!-- Substring after '#' -->
		<xsl:variable as="xs:string" name="original-id" select="substring(., 2)" />

		<xsl:variable as="element()" name="target-element"
			select="local:element-by-id(., $original-id)" />
		<xsl:variable as="xs:string" name="predictable-id"
			select="local:generate-predictable-id($target-element)" />
		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="concat('#', $predictable-id)" />
	</xsl:template>

	<!--
		Private utility functions
	-->

	<!-- Gets the positional index (1~) of element -->
	<xsl:function as="xs:integer" name="local:element-index">
		<xsl:param as="element()" name="element" />

		<xsl:sequence select="count($element/preceding::element()) + 1" />
	</xsl:function>

	<!--
		Returns the element whose original @id is equal to the specified ID
	-->
	<xsl:function as="element()?" name="local:element-by-id">
		<xsl:param as="node()" name="context-node" />
		<xsl:param as="xs:string" name="id" />

		<xsl:variable as="document-node()" name="doc" select="root($context-node)" />
		<xsl:sequence select="$doc/descendant::element()[@id eq $id]" />
	</xsl:function>

	<!--
		Generates ID for element
			Unlike fn:generate-id(), ID is generated solely from the element's positional index. So the ID value is predictable.
	-->
	<xsl:function as="xs:string" name="local:generate-predictable-id">
		<xsl:param as="element()" name="element" />

		<xsl:sequence select="concat('ELEM-', local:element-index($element))" />
	</xsl:function>

	<!--
		Returns true if the HTML report is for XQuery
	-->
	<xsl:function as="xs:boolean" name="local:is-xquery-report">
		<xsl:param as="node()" name="context-node" />

		<xsl:variable as="document-node(element(html))" name="doc" select="root($context-node)" />
		<xsl:sequence select="$doc/html/body/starts-with(p[1], 'Query:')" />
	</xsl:function>

	<!--
		Returns true if the HTML report is for Schematron
	-->
	<xsl:function as="xs:boolean" name="local:is-schematron-report">
		<xsl:param as="node()" name="context-node" />

		<xsl:variable as="document-node(element(html))" name="doc" select="root($context-node)" />
		<xsl:sequence select="$doc/html/body/starts-with(p[1], 'Schematron:')" />
	</xsl:function>

</xsl:stylesheet>
