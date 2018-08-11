<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:util="x-urn:xspec:test:end-to-end:processor:base:util"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module helps normalize the document.
	-->

	<!--
		mode=normalize
			Normalizes the transient parts of the document such as @href, @id, datetime and file path
	-->

	<!-- Identity template, in lowest priority -->
	<xsl:template as="node()" match="document-node() | attribute() | node()"
		mode="normalizer:normalize" priority="-1">
		<xsl:call-template name="util:identity" />
	</xsl:template>

	<!-- The other processing depends on each processor... -->
</xsl:stylesheet>
