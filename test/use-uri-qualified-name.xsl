<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Returns the items in the parameter intact -->
	<xsl:mode name="Q{x-urn:test:use-uri-qualified-name}param-mirror-mode" on-multiple-match="fail"
		on-no-match="fail" />
	<xsl:template as="item()*" match="attribute() | node() | document-node()"
		mode="Q{x-urn:test:use-uri-qualified-name}param-mirror-mode"
		name="Q{x-urn:test:use-uri-qualified-name}param-mirror-template">
		<xsl:param as="item()*" name="Q{x-urn:test:use-uri-qualified-name}param-items" />

		<xsl:sequence select="$Q{x-urn:test:use-uri-qualified-name}param-items" />
	</xsl:template>

	<!-- Returns the items in the parameter intact -->
	<xsl:function as="item()*" name="Q{x-urn:test:use-uri-qualified-name}param-mirror-function">
		<xsl:param as="item()*" name="Q{x-urn:test:use-uri-qualified-name}param-items" />

		<xsl:sequence select="$Q{x-urn:test:use-uri-qualified-name}param-items" />
	</xsl:function>

</xsl:stylesheet>
