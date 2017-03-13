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

	<xsl:function as="document-node()" name="normalizer:normalize">
		<xsl:param as="document-node()" name="doc" />

		<xsl:apply-templates mode="local:normalize" select="$doc" />
	</xsl:function>

	<xsl:template as="node()" match="document-node() | attribute() | node()" mode="local:normalize"
		priority="-1">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute() | node()" />
		</xsl:copy>
	</xsl:template>

	<xsl:template as="empty-sequence()" match="comment() | processing-instruction()"
		mode="local:normalize" />

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

	<xsl:template as="attribute(href)" match="/html/head/link/@href" mode="local:normalize">
		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}">
			<xsl:text>../../../../</xsl:text>

			<xsl:variable as="xs:string+" name="path-components"
				select="tokenize(., '/')[position() ge (last() - 2)]" />

			<xsl:sequence select="string-join($path-components, '/')" />
		</xsl:attribute>
	</xsl:template>

	<xsl:template as="element(a)" match="/html/body/p[1]/a" mode="local:normalize">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute()" />
			<xsl:attribute name="href" select="util:filename-and-extension(@href)" />

			<xsl:value-of select="util:filename-and-extension(.)" />
		</xsl:copy>
	</xsl:template>

	<xsl:template as="text()" match="/html/body/p[2]/text()" mode="local:normalize">
		<xsl:analyze-string regex="^(Tested:) .+$" select=".">
			<xsl:matching-substring>
				<xsl:value-of select="regex-group(1), 'ONCE-UPON-A-TIME'" />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<xsl:template as="attribute(id)" match="@id" mode="local:normalize"
		name="normalize-id-attribute">
		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="local:generate-predictable-id(parent::element())" />
	</xsl:template>

	<xsl:template as="attribute(href)" match="@href[starts-with(., '#')]" mode="local:normalize">
		<xsl:variable as="xs:string" name="original-id" select="substring(., 2)" />

		<xsl:variable as="element()?" name="target-element"
			select="local:element-by-id(., $original-id)" />

		<xsl:variable as="xs:string" name="predictable-id">
			<xsl:choose>
				<xsl:when test="$target-element">
					<xsl:sequence select="local:generate-predictable-id($target-element)" />
				</xsl:when>

				<xsl:when test="parent::a/parent::th/parent::tr/@class eq 'pending'">
					<xsl:if test="count(//@href[. eq current()]) eq 1">
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

	<xsl:function as="xs:integer" name="local:element-index">
		<xsl:param as="element()" name="element" />

		<xsl:sequence select="count($element/preceding::element()) + 1" />
	</xsl:function>

	<xsl:function as="element()?" name="local:element-by-id">
		<xsl:param as="node()" name="context-node" />
		<xsl:param as="xs:string" name="id" />

		<xsl:variable as="document-node()" name="doc" select="root($context-node)" />
		<xsl:sequence select="$doc/descendant::element()[@id eq $id][1]" />
	</xsl:function>

	<xsl:function as="xs:string" name="local:generate-predictable-id">
		<xsl:param as="element()" name="element" />

		<xsl:variable as="element()" name="index-element"
			select="
				if ($element/@id) then
					local:element-by-id($element, $element/@id)
				else
					$element" />

		<xsl:sequence select="concat('ELEM-', local:element-index($index-element))" />
	</xsl:function>
</xsl:stylesheet>
