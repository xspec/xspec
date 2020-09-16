<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet is a testable version of stylesheet_original.xsl.
	-->

	<!-- @use has been changed to "optional" as a workaround for XSpec. -->
	<xsl:global-context-item as="document-node(element(foo))" use="optional" />

	<!-- This global variable is a workaround for XSpec. In XSpec document, you must override this
		global variable with a global x:variable pointing to a source document. -->
	<xsl:variable as="document-node(element(foo))" name="global-context-item" select="." />

	<!-- "$global-context-item" has been inserted into @select as a workaround for XSpec. -->
	<xsl:variable as="element(bar)" name="my-global-var" select="$global-context-item/foo/bar" />

	<xsl:template as="element(bar)" name="test-me">
		<xsl:sequence select="$my-global-var" />
	</xsl:template>

</xsl:stylesheet>
