<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module is a private patch for the built-in Schematron Step 3 preprocessor.
	-->

	<!--
		Workaround for the built-in preprocessor not setting @xml:base.
	-->
	<xsl:template as="element(xsl:stylesheet)" match="document-node()">
		<xsl:variable as="element(xsl:stylesheet)" name="imports-applied">
			<xsl:next-match />
		</xsl:variable>

		<xsl:for-each select="$imports-applied">
			<xsl:copy>
				<xsl:attribute name="xml:base" select="$x:schematron-uri" />
				<xsl:sequence select="attribute() | node()" />
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
