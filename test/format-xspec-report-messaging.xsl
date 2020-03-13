<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Hooks the default HTML reporter and emits some messages for each failed test.
		Only for testing purposes. Not intended to be used in a production environment.
	-->

	<xsl:import href="../src/reporter/format-xspec-report.xsl" />

	<xsl:template as="element(xhtml:div)" match="x:test[x:is-failed-test(.)]" mode="x:html-report">
		<!--
			Capture the original HTML report and output it
		-->
		<xsl:variable as="element(xhtml:div)" name="html-report">
			<xsl:apply-imports />
		</xsl:variable>
		<xsl:sequence select="$html-report" />

		<!--
			Message
		-->
		<xsl:variable as="xs:string+" name="labels"
			select="(ancestor::x:scenario | .)/x:label ! normalize-space()" />
		<xsl:message select="'===', $labels, '==='" />
		<xsl:for-each select="$html-report/xhtml:table/xhtml:tbody/xhtml:tr/xhtml:td">
			<xsl:variable as="xs:integer" name="pos" select="position()" />
			<xsl:message select="'--- ' || ('Actual', 'Expected')[$pos] || ' Result ---'" />
			<xsl:for-each select="xhtml:p">
				<xsl:message select="string()" />
			</xsl:for-each>
			<xsl:for-each select="xhtml:pre">
				<xsl:message select="string() => parse-xml-fragment()" />
			</xsl:for-each>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
