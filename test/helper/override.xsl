<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:items="x-urn:test:xspec-items"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Override a variable -->
	<xsl:variable as="xs:integer" name="items:all-nodes" select="2" />

</xsl:stylesheet>
