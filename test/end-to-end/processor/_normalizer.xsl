<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:local="x-urn:xspec:test:end-to-end:processor:normalizer:local"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:util="x-urn:xspec:test:end-to-end:processor:util"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.w3.org/1999/xhtml">

	<!--
		This stylesheet module provides a primitive normalizer for the XSpec report HTML.
	-->

	<!--
		Public functions
	-->

	<!-- Normalizes the transient parts of the document such as @href, @id, datetime and file path -->
	<xsl:function as="document-node()" name="normalizer:normalize">
		<xsl:param as="document-node()" name="doc" />

		<xsl:apply-templates mode="local:normalize" select="$doc" />
	</xsl:function>

	<!--
		Private templates
	-->

	<!-- Identity template, in lowest priority -->
	<xsl:template as="node()" match="document-node() | attribute() | node()" mode="local:normalize"
		priority="-1">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute() | node()" />
		</xsl:copy>
	</xsl:template>

	<!--
		Removes comments and processing instructions
			They are often ignored by fn:deep-equal(). So remove them explicitly in the first place.
	-->
	<xsl:template as="empty-sequence()" match="comment() | processing-instruction()"
		mode="local:normalize" />

	<!--
		Normalizes the title text
			Example:
				in:		<title>Test Report for /path/to/tested.xsl (2/0/1/3)</title>
				out:	<title>Test Report for tested.xsl (2/0/1/3)</title>
	-->
	<xsl:template as="text()" match="/html/head/title/text()" mode="local:normalize">
		<xsl:analyze-string regex="^(Test Report for) (.+) (\([0-9/]+\))$" select=".">
			<xsl:matching-substring>
				<xsl:value-of
					select="
						regex-group(1),
						util:filename-and-extension(regex-group(2)),
						regex-group(3)"
					separator=" " />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<!--
		Normalizes the link to CSS
			Example:
				in:		href="file:/xspec/src/reporter/test-report.css"
				out:	href="../../../../src/reporter/test-report.css"
	-->
	<xsl:template as="attribute(href)" match="/html/head/link/@href" mode="local:normalize">
		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}">
			<!-- Relative path to XSPEC_HOME from XSPEC_HOME/test/end-to-end/cases/*/*.html -->
			<xsl:text>../../../../</xsl:text>

			<!-- Last 3 components of path -->
			<xsl:variable as="xs:string+" name="path-components"
				select="tokenize(., '/')[position() ge (last() - 2)]" />

			<xsl:sequence select="string-join($path-components, '/')" />
		</xsl:attribute>
	</xsl:template>

	<!--
		Normalizes the link to the tested module
			Example:
				in:		<a href="file:/path/to/tested.xsl">/path/to/tested.xsl</a>
				out:	<a href="tested.xsl">tested.xsl</a>
	-->
	<xsl:template as="element(a)" match="/html/body/p[1]/a" mode="local:normalize">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute()" />
			<xsl:attribute name="href" select="util:filename-and-extension(@href)" />

			<xsl:value-of select="util:filename-and-extension(.)" />
		</xsl:copy>
	</xsl:template>

	<!--
		Normalizes datetime
			Example:
				in:		<p>Tested: 23 February 2017 at 11:18</p>
				out:	<p>Tested: ONCE-UPON-A-TIME</p>
	-->
	<xsl:template as="text()" match="/html/body/p[2]/text()" mode="local:normalize">
		<!-- Use analyze-string() so that the transformation will fail when nothing matches -->
		<xsl:analyze-string regex="^(Tested:) .+$" select=".">
			<xsl:matching-substring>
				<xsl:value-of select="regex-group(1), 'ONCE-UPON-A-TIME'" />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<!-- Makes @id predictable -->
	<xsl:template as="attribute(id)" match="@id" mode="local:normalize"
		name="normalize-id-attribute">
		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="local:generate-predictable-id(parent::element())" />
	</xsl:template>

	<!--
		Makes the in-page link follow its target element
			@id of the target element is normalized by the 'normalize-id-attribute' template. So @href has to follow it.
	-->
	<xsl:template as="attribute(href)" match="@href[starts-with(., '#')]" mode="local:normalize">
		<!-- Substring after '#' -->
		<xsl:variable as="xs:string" name="original-id" select="substring(., 2)" />

		<xsl:variable as="element()?" name="target-element"
			select="local:element-by-id(., $original-id)" />

		<xsl:variable as="xs:string" name="predictable-id">
			<xsl:choose>
				<xsl:when test="$target-element">
					<xsl:sequence select="local:generate-predictable-id($target-element)" />
				</xsl:when>

				<!-- @href's target element may not exist for pending scenarios: xspec/xspec#85 -->
				<xsl:when test="parent::a/parent::th/parent::tr/@class eq 'pending'">
					<!-- Assume that @href is always unique when the scenario is pending -->
					<xsl:if test="count(//@href[. eq current()]) eq 1">
						<!-- Use the current element's ID, prefixing 'PENDING_' to it -->
						<xsl:sequence
							select="concat('PENDING_', local:generate-predictable-id(parent::element()))"
						 />
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

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
			If multiple elements satisfy the condition, returns the first element.
	-->
	<xsl:function as="element()?" name="local:element-by-id">
		<xsl:param as="node()" name="context-node" />
		<xsl:param as="xs:string" name="id" />

		<xsl:variable as="document-node()" name="doc" select="root($context-node)" />
		<xsl:sequence select="$doc/descendant::element()[@id eq $id][1]" />
	</xsl:function>

	<!--
		Generates ID for element
			Unlike fn:generate-id(), ID is generated solely from the element's positional index. So the ID value is predictable.
	-->
	<xsl:function as="xs:string" name="local:generate-predictable-id">
		<xsl:param as="element()" name="element" />

		<!--
			Unfortunately the original @id is not always unique: xspec/xspec#78
			So, for calculating the element index, you can't simply use the specified element. You have to determine which element to use.
		-->
		<xsl:variable as="element()" name="index-element"
			select="
				if ($element/@id) then
					local:element-by-id($element, $element/@id)
				else
					$element" />

		<xsl:sequence select="concat('ELEM-', local:element-index($index-element))" />
	</xsl:function>
</xsl:stylesheet>
