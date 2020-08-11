<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="../../src/compiler/generate-xspec-tests.xsl" />

	<xsl:template as="xs:string" match="x:scenario" mode="x:generate-id">
		<xsl:sequence select="'overridden-xslt-scenario-id-' || generate-id()" />
	</xsl:template>

	<xsl:template as="xs:string" match="x:expect" mode="x:generate-id">
		<xsl:sequence select="'overridden-xslt-expect-id-' || generate-id()" />
	</xsl:template>

</xsl:stylesheet>
