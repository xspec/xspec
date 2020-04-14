<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet transforms a template of Ant build file into a working build file.
		The basic transformation is done by the imported stylesheet.
		In addition to the imported basic transformation, this stylesheet creates some Ant
		nodes to compare the XSpec report files.
	-->

	<!-- Import: Some may be overridden -->
	<xsl:import href="../../base/worker/generate.xsl" />

	<!--
		Overrides an imported named template
		
		Inserts <compare-xspec-report> into the default <post-task>.
		Context node is in each .xspec file's /x:description/@*.
	-->
	<xsl:template as="element(compare-xspec-report)+" name="on-post-task">
		<xsl:context-item as="attribute()" use="required" />

		<xsl:param as="element(reports)" name="reports" required="yes" />

		<!-- Compare the actual report files with the expected ones -->
		<xsl:for-each select="$reports/element()">
			<compare-xspec-report actual-report-url="{@actual}"
				comparer-xsl-url="{resolve-uri('compare.xsl', @processor-dir)}"
				expected-report-url="{@expected}" />
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
