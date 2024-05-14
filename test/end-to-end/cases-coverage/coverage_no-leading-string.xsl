<xsl:transform exclude-result-prefixes="#all" version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Test Code Coverage when /xsl:* has no leading string.
		Do not write anything before the outermost element.
	-->

	<xsl:template as="element(bar)" match="foo">
		<bar />
	</xsl:template>

</xsl:transform>
