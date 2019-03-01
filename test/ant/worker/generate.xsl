<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet transforms a template of Ant build file into a working build file.
		In doing so, the stylesheet scans all the XSpec files in $XSPECFILES-DIR-URI and
		creates a series of <run-xspec> elements based on /x:description/@*.
	-->

	<xsl:include href="../../../src/common/xspec-utils.xsl" />

	<xsl:output indent="yes" />

	<!-- Absolute URI of directory where *.xspec files are located. Must ends with '/'. -->
	<xsl:param as="xs:anyURI" name="XSPECFILES-DIR-URI" required="yes" />

	<!-- XSLT processor capabilities -->
	<xsl:param as="xs:boolean" name="XSLT-SUPPORTS-COVERAGE" required="yes" />
	<xsl:param as="xs:boolean" name="XSLT-SUPPORTS-SCHEMA" required="yes" />

	<!--
		mode=#default
			Transforms a template of Ant build file into a working build file.
	-->

	<xsl:template as="node()" match="document-node() | attribute() | node()">
		<xsl:call-template name="x:identity" />
	</xsl:template>

	<xsl:template as="element()" match="/*">
		<xsl:copy>
			<xsl:apply-templates select="attribute()" />
			<xsl:comment>Temporary build file generated from <xsl:value-of select="document-uri(/)" /> at <xsl:value-of select="current-dateTime()" /></xsl:comment>
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>

	<xsl:template as="element(target)" match="target[@name = 'run-all-xspec-files']">
		<xsl:copy>
			<xsl:apply-templates select="attribute() | node()" />

			<xsl:variable as="xs:string" name="collection-uri"
				select="concat($XSPECFILES-DIR-URI, '?select=*.xspec')" />

			<!--<xsl:message select="'Collecting:', $collection-uri" />-->
			<xsl:variable as="document-node()+" name="xspec-docs"
				select="collection($collection-uri)" />

			<xsl:apply-templates mode="xspec" select="$xspec-docs">
				<xsl:sort select="document-uri(/)" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<!--
		mode=xspec
			Transforms a .xspec document into a series of <run-xspec> elements (or comment nodes if skipped)
			based on /x:description/@*
	-->

	<xsl:template as="node()+" match="document-node()" mode="xspec">
		<xsl:variable as="xs:anyURI" name="xspec-file-uri" select="document-uri(/)" />

		<xsl:variable as="xs:boolean" name="enable-coverage"
			select="processing-instruction(xspec-test) = 'enable-coverage'" />

		<xsl:variable as="xs:string?" name="skip">
			<xsl:choose>
				<xsl:when test="
						$enable-coverage
						and not($XSLT-SUPPORTS-COVERAGE)">
					<xsl:value-of>
						<xsl:text>Skipping </xsl:text>
						<xsl:value-of select="x:filename-and-extension($xspec-file-uri)" />
						<xsl:text>: Requires XSLT processor to support coverage</xsl:text>
					</xsl:value-of>
				</xsl:when>

				<xsl:when
					test="
						(processing-instruction(xspec-test) = 'require-xslt-to-support-schema')
						and not($XSLT-SUPPORTS-SCHEMA)">
					<xsl:value-of>
						<xsl:text>Skipping </xsl:text>
						<xsl:value-of select="x:filename-and-extension($xspec-file-uri)" />
						<xsl:text>: Requires schema-aware XSLT processor</xsl:text>
					</xsl:value-of>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="$skip">
				<xsl:message select="$skip" />
				<xsl:comment select="$skip" />
			</xsl:when>

			<xsl:otherwise>
				<xsl:for-each select="x:description/(@query | @schematron | @stylesheet)">
					<xsl:sort select="name()" />

					<xsl:variable as="xs:string" name="test-type">
						<xsl:choose>
							<xsl:when test="name() = 'query'">q</xsl:when>
							<xsl:when test="name() = 'schematron'">s</xsl:when>
							<xsl:when test="name() = 'stylesheet'">t</xsl:when>
						</xsl:choose>
					</xsl:variable>

					<run-xspec test-type="{$test-type}" xspec-file-url="{$xspec-file-uri}">
						<xsl:if test="$enable-coverage">
							<xsl:attribute name="enable-coverage" select="$enable-coverage" />
						</xsl:if>

						<xsl:call-template name="on-run-xspec">
							<xsl:with-param name="coverage-enabled" select="$enable-coverage" />
						</xsl:call-template>
					</run-xspec>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
		Named template to be overridden
	-->

	<!-- Override this template to provide <run-xspec> with additional nodes -->
	<xsl:template as="empty-sequence()" name="on-run-xspec">
		<xsl:param as="xs:boolean" name="coverage-enabled" />
	</xsl:template>
</xsl:stylesheet>
