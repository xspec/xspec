<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet transforms a template of Ant build file into a working build file.
		In doing so, the stylesheet scans all the XSpec files in $XSPECFILES-DIR-URI and
		creates a series of <run-xspec> elements based on /x:description/@*.
	-->

	<xsl:output indent="yes" />

	<xsl:param as="xs:anyURI" name="XSPECFILES-DIR-URI" />

	<!--
		mode=#default
	-->

	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>

	<xsl:template as="element()" match="/*">
		<xsl:copy>
			<xsl:apply-templates select="@*" />
			<xsl:comment>Temporary build file generated from <xsl:value-of select="document-uri(/)" /> at <xsl:value-of select="current-dateTime()" /></xsl:comment>
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>

	<xsl:template as="element(target)" match="target[@name = 'run-all-xspec-files']">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />

			<xsl:variable as="xs:string" name="collection-uri"
				select="concat($XSPECFILES-DIR-URI, '?select=*.xspec')" />

			<!--<xsl:message select="'Collecting:', $collection-uri" />-->
			<xsl:variable as="document-node()+" name="xspec-docs"
				select="collection($collection-uri)" />

			<xsl:apply-templates mode="xspec" select="$xspec-docs">
				<xsl:sort select="document-uri(.)" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<!--
		mode=xspec
	-->

	<xsl:template as="element(run-xspec)+" match="/" mode="xspec">
		<xsl:apply-templates mode="#current"
			select="x:description/(@query | @schematron | @stylesheet)">
			<xsl:sort select="name()" />
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template as="element(run-xspec)" match="@*" mode="xspec">
		<xsl:variable as="xs:anyURI" name="xspec-file-uri" select="document-uri(/)" />

		<xsl:variable as="xs:string" name="type">
			<xsl:choose>
				<xsl:when test="name() = 'query'">q</xsl:when>
				<xsl:when test="name() = 'schematron'">s</xsl:when>
				<xsl:when test="name() = 'stylesheet'">t</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<run-xspec test-type="{$type}" xspec-file-url="{$xspec-file-uri}" />
	</xsl:template>
</xsl:stylesheet>
