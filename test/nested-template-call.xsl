<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:nested-function-call="x-urn:test:nested-function-call"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="nested-function-call.xsl" />

	<xsl:template as="document-node(element(table))" name="createTable">
		<xsl:context-item use="absent" />

		<xsl:param as="xs:integer" name="cols" required="yes" />
		<xsl:param as="element(value)+" name="nodes" required="yes" />

		<xsl:sequence select="nested-function-call:createTable($cols, $nodes)" />
	</xsl:template>

</xsl:stylesheet>
