<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="../../src/compiler/generate-xspec-tests.xsl" />

	<xsl:template match="x:scenario" as="xs:string" mode="x:generate-id">
		<xsl:sequence select="'overridden-scenario-id-' || generate-id()" />
	</xsl:template>

	<xsl:template match="x:expect" as="xs:string" mode="x:generate-id">
		<xsl:sequence select="'overridden-expect-id-' || generate-id()" />
	</xsl:template>

</xsl:stylesheet>
