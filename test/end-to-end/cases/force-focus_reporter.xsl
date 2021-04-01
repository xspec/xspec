<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="../../../src/reporter/format-xspec-report.xsl" />

	<xsl:template as="node()+" match="document-node(element(x:report))">
		<xsl:comment>Report filtered by focus</xsl:comment>

		<xsl:variable as="document-node(element(x:report))" name="filtered-doc">
			<xsl:apply-templates mode="filter-focus" select="." />
		</xsl:variable>

		<xsl:apply-templates select="$filtered-doc/node()" />
	</xsl:template>

	<!--
		mode="filter-focus"
	-->
	<xsl:mode name="filter-focus" on-multiple-match="fail" on-no-match="shallow-copy" />

	<xsl:template as="empty-sequence()"
		match="x:scenario[descendant-or-self::x:scenario[contains-token($force-focus, @id)] => empty()]"
		mode="filter-focus" />

</xsl:stylesheet>
