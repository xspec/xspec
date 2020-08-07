<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:test-helper="x-urn:tutorial:helper:ws-only-text:test-helper"
	xmlns:worker="x-urn:tutorial:helper:ws-only-text:test-helper:worker"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This test helper function just removes whitespace-only text nodes from the input document.
		All the other nodes are kept intact.
	-->
	<xsl:function as="document-node()" name="test-helper:remove-whitespace-only-text">
		<xsl:param as="document-node()" name="input-document" />

		<xsl:apply-templates mode="worker:remove-whitespace-only-text" select="$input-document" />
	</xsl:function>

	<!--
		mode="worker:remove-whitespace-only-text"
		This mode does the real job.
		
		Note:
		- Use a dedicated mode to avoid clashes with the test target stylesheet.
		- You can't use @on-no-match="shallow-copy". The test target stylesheet may have
		  xsl:template[@mode = '#all'].
	-->
	<xsl:mode name="worker:remove-whitespace-only-text" on-multiple-match="fail" on-no-match="fail" />

	<!-- Identity template -->
	<xsl:template as="node()" match="attribute() | document-node() | node()"
		mode="worker:remove-whitespace-only-text">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute() | node()" />
		</xsl:copy>
	</xsl:template>

	<!-- Discard whitespace-only text nodes -->
	<xsl:template as="empty-sequence()" match="text()[normalize-space() => not()]"
		mode="worker:remove-whitespace-only-text" />

</xsl:stylesheet>
