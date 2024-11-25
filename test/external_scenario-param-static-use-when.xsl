<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:param name="A" static="yes" as="xs:integer" select="0"/>
	<xsl:param name="B" static="yes" as="xs:integer" select="0"/>
	<xsl:param name="myp:default" static="no"
		xmlns:myp="http://example.org/ns/my/param"/>

	<xsl:template name="process-A-and-B">
		<xsl:context-item use="absent"/>
		<xsl:call-template name="template-based-on-A"/>
		<xsl:call-template name="template-based-on-B"/>
	</xsl:template>

	<xsl:template name="template-based-on-A" use-when="$A ge 0" as="xs:integer">
		<xsl:context-item use="absent"/>
		<xsl:sequence select="$A"/>
	</xsl:template>

	<xsl:template name="template-based-on-A" use-when="$A lt 0" as="xs:string">
		<xsl:context-item use="absent"/>
		<xsl:sequence select="'$A is negative'"/>
	</xsl:template>

	<xsl:template name="template-based-on-B" use-when="$B ge 0" as="xs:integer">
		<xsl:context-item use="absent"/>
		<xsl:sequence select="$B"/>
	</xsl:template>

	<xsl:template name="template-based-on-B" use-when="$B lt 0" as="xs:string">
		<xsl:context-item use="absent"/>
		<xsl:sequence select="'$B is negative'"/>
	</xsl:template>

</xsl:stylesheet>
