<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:issue-1029="x-urn:test:issue-1029" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- Function -->

	<xsl:function as="xs:integer" name="issue-1029:as-integer">
		<xsl:message select="'my error message'" terminate="yes" />
		<xsl:sequence select="1" />
	</xsl:function>

	<xsl:function name="issue-1029:no-as">
		<xsl:message select="'my error message'" terminate="yes" />
	</xsl:function>

	<!-- Named template -->

	<xsl:template as="xs:integer" name="issue-1029:as-integer">
		<xsl:context-item use="absent" />
		<xsl:message select="'my error message'" terminate="yes" />
		<xsl:sequence select="1" />
	</xsl:template>

	<xsl:template name="issue-1029:no-as">
		<xsl:context-item use="absent" />
		<xsl:message select="'my error message'" terminate="yes" />
	</xsl:template>

	<!-- Matching template -->

	<xsl:mode name="issue-1029:as-integer" on-multiple-match="fail" on-no-match="fail" />
	<xsl:template as="xs:integer" match="context-child" mode="issue-1029:as-integer">
		<xsl:message select="'my error message'" terminate="yes" />
		<xsl:sequence select="1" />
	</xsl:template>

	<xsl:mode name="issue-1029:no-as" on-multiple-match="fail" on-no-match="fail" />
	<xsl:template match="context-child" mode="issue-1029:no-as">
		<xsl:message select="'my error message'" terminate="yes" />
	</xsl:template>

</xsl:stylesheet>
