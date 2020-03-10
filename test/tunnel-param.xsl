<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:local="x-urn:test:tunnel-param:xsl" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Returns the items in the tunnel parameter intact
	-->
	<xsl:template as="item()*" match="attribute() | node() | document-node()"
		mode="tunnel-param-mirror-mode" name="tunnel-param-mirror-template">
		<xsl:call-template name="local:get-tunnel-param" />
	</xsl:template>

	<xsl:template as="item()*" name="local:get-tunnel-param">
		<xsl:param as="item()*" name="tunnel-param-items" tunnel="yes" />

		<xsl:sequence select="$tunnel-param-items" />
	</xsl:template>

	<!--
		Returns the items in the non-tunnel parameter intact
	-->
	<xsl:template as="item()*" match="attribute() | node() | document-node()"
		mode="param-mirror-mode" name="param-mirror-template">
		<xsl:param as="item()*" name="param-items" tunnel="no" />

		<xsl:sequence select="$param-items" />
	</xsl:template>

</xsl:stylesheet>
