<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="text" />

	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="text()" match="document-node(element(trace))">
		<xsl:apply-templates select="trace" />
	</xsl:template>

	<xsl:template as="text()" match="trace">
		<xsl:if test="empty(construct)">
			<xsl:message select="'No construct!'" terminate="yes" />
		</xsl:if>

		<xsl:if test="empty(hit)">
			<xsl:message select="'No hit!'" terminate="yes" />
		</xsl:if>

		<xsl:if test="empty(module)">
			<xsl:message select="'No module!'" terminate="yes" />
		</xsl:if>

		<xsl:for-each select="module[contains(@uri, '/src/')]">
			<xsl:message select="'module/@uri contains /src/!', ." terminate="yes" />
		</xsl:for-each>

		<xsl:if test="empty(util)">
			<xsl:message select="'No util!'" terminate="yes" />
		</xsl:if>

		<xsl:for-each select="util[contains(@uri, '/src/') => not()]">
			<xsl:message select="'util/@uri not contains /src/!', ." terminate="yes" />
		</xsl:for-each>

		<xsl:text expand-text="yes">{true()}&#x0A;</xsl:text>
	</xsl:template>

</xsl:stylesheet>
