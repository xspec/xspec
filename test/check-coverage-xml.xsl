<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="text" />

	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="text()" match="document-node(element(trace))">
		<xsl:apply-templates select="trace" />
	</xsl:template>

	<xsl:template as="text()" match="trace">
		<xsl:if test="empty(c)">
			<xsl:message select="'No c!'" terminate="yes" />
		</xsl:if>

		<xsl:if test="empty(h)">
			<xsl:message select="'No h!'" terminate="yes" />
		</xsl:if>

		<xsl:if test="empty(m)">
			<xsl:message select="'No m!'" terminate="yes" />
		</xsl:if>

		<xsl:for-each select="m[contains(@u, '/src/')]">
			<xsl:message select="'m/@u contains /src/!', ." terminate="yes" />
		</xsl:for-each>

		<xsl:if test="empty(u)">
			<xsl:message select="'No u!'" terminate="yes" />
		</xsl:if>

		<xsl:for-each select="u[contains(@u, '/src/') => not()]">
			<xsl:message select="'u/@u not contains /src/!', ." terminate="yes" />
		</xsl:for-each>

		<xsl:text expand-text="yes">{true()}&#x0A;</xsl:text>
	</xsl:template>

</xsl:stylesheet>
