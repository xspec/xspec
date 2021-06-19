<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:rep="urn:x-xspec:common:report-sequence" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:function as="element()" name="rep:report-sequence">
		<xsl:param as="item()*" name="sequence" />
		<xsl:param as="xs:string" name="report-name" />

		<xsl:call-template name="rep:report-sequence">
			<xsl:with-param name="sequence" select="$sequence" />
			<xsl:with-param name="report-name" select="$report-name" />
		</xsl:call-template>
	</xsl:function>

</xsl:stylesheet>
