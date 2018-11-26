<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:util="x-urn:xspec:test:end-to-end:processor:base:util"
	xmlns:deserializer="x-urn:xspec:test:end-to-end:processor:deserializer"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module helps deserialize the document.
	-->

	<!--
		mode=unindent
			Removes side effect of loading indented XML
	-->

	<!-- Identity template, in lowest priority -->
	<xsl:template as="node()" match="document-node() | attribute() | node()"
		mode="deserializer:unindent" priority="-1">
		<xsl:call-template name="util:identity"/>
	</xsl:template>

	<!-- The other processing depends on each processor... -->
</xsl:stylesheet>
