<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:deserializer="x-urn:xspec:test:end-to-end:processor:deserializer"
	xmlns:local="x-urn:xspec:test:end-to-end:processor:deserializer:local"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.w3.org/1999/xhtml">

	<!--
		This stylesheet module helps deserialize the report HTML.
	-->

	<xsl:function as="document-node()" name="deserializer:unindent">
		<xsl:param as="document-node()" name="doc" />

		<xsl:apply-templates mode="local:unindent" select="$doc" />
	</xsl:function>

	<xsl:template as="node()" match="document-node() | attribute() | node()" mode="local:unindent"
		priority="-1">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute() | node()" />
		</xsl:copy>
	</xsl:template>

	<xsl:template as="text()?" match="text()[not(parent::pre)]" mode="local:unindent">
		<xsl:choose>
			<xsl:when test="normalize-space()">
				<xsl:value-of select="replace(., '\n +$', '')" />
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
