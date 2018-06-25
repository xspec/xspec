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

</xsl:stylesheet>
