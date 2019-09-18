<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Returns the context node intact -->
  <xsl:template match="attribute() | node() | document-node()" as="node()" name="context-mirror-template">
		<xsl:sequence select="." />
	</xsl:template>

	<!-- Returns the items in the parameter intact -->
	<xsl:template as="item()*" match="attribute() | node() | document-node()" mode="param-mirror-mode">
		<xsl:param as="item()*" name="param-items" />

		<xsl:sequence select="$param-items" />
	</xsl:template>

</xsl:stylesheet>
