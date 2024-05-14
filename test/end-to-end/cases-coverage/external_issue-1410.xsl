<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Test Code Coverage with this xsl:global-context-item -->
	<xsl:global-context-item as="document-node(element(foo))" use="required" />

	<!-- Template containing no elements but xsl:context-item -->
	<xsl:mode name="empty" on-multiple-match="fail" on-no-match="fail" />
	<xsl:template as="empty-sequence()" match="foo" mode="empty">
		<!-- Test Code Coverage with this xsl:context-item -->
		<xsl:context-item as="element(foo)" use="required" />
	</xsl:template>

	<!-- Template containing xsl:context-item and literal result elements -->
	<xsl:mode name="not-empty" on-multiple-match="fail" on-no-match="fail" />
	<xsl:template as="element(bar)" match="foo" mode="not-empty">
		<!-- Test Code Coverage with this xsl:context-item -->
		<xsl:context-item as="element(foo)" use="required" />
		<bar />
	</xsl:template>

</xsl:stylesheet>
