<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Returns the items in the parameter intact -->
	<xsl:template as="item()*" match="attribute() | node() | document-node()"
		mode="param-mirror-mode" name="param-mirror-template">
		<xsl:param as="item()*" name="param-items" />

		<xsl:sequence select="$param-items" />
	</xsl:template>

</xsl:stylesheet>
