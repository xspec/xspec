<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet transforms a template of Ant build file into a working build file.
		The basic transformation is done by the imported stylesheet.
		In addition to the imported basic transformation, this stylesheet creates some Ant
		nodes to normalize or compare the XSpec report files.
	-->

	<!-- Import: Some may be overridden -->
	<xsl:import href="../../../../ant/worker/generate.xsl" />

	<!--
		Overrides an imported named template
		
		Inserts @output-*-url and <post-task> into the default <run-xspec>.
		Context node is in each .xspec file's /x:description/@*.
	-->
	<xsl:template as="node()+" name="on-run-xspec">
		<xsl:context-item as="attribute()" use="required" />

		<xsl:param as="xs:boolean" name="coverage-enabled" required="yes" />

		<!-- Directory URI of the processor root -->
		<xsl:variable as="xs:anyURI" name="processor-dir-uri"
			select="resolve-uri('../../../processor/')" />

		<!-- Directory URIs where the XSpec report files are put -->
		<xsl:variable as="xs:anyURI" name="actual-reports-dir-uri"
			select="
				('actual__/' || name() || '/')
				=> resolve-uri($XSPECFILES-DIR-URI)" />
		<xsl:variable as="xs:anyURI" name="expected-reports-dir-uri"
			select="
				('expected/' || name() || '/')
				=> resolve-uri($XSPECFILES-DIR-URI)" />

		<!-- Get the file name without extension. i.e. Get "foo" from "scheme://host/dir/foo.xspec" -->
		<xsl:variable as="xs:string" name="xspec-file-name-without-extension"
			select="x:filename-without-extension(document-uri(/))" />

		<!-- Absolute URIs of the reports -->
		<xsl:variable name="coverage-only-testing-location" as="xs:string"
			select="'/cases-coverage/'"/>
		<xsl:variable as="element(reports)" name="reports">
			<reports>
				<xsl:if test="$coverage-enabled or ends-with($XSPECFILES-DIR-URI,$coverage-only-testing-location)">
					<!-- Coverage -->
					<xsl:variable as="xs:string" name="coverage-file-name"
						select="$xspec-file-name-without-extension || '-coverage.html'" />
					<coverage actual="{resolve-uri($coverage-file-name, $actual-reports-dir-uri)}"
						expected="{resolve-uri($coverage-file-name, $expected-reports-dir-uri)}"
						processor-dir="{resolve-uri('coverage/', $processor-dir-uri)}" />
				</xsl:if>
				<xsl:if test="not(ends-with($XSPECFILES-DIR-URI,$coverage-only-testing-location))">
					<!-- XML -->
					<xsl:variable as="xs:string" name="xml-file-name"
						select="$xspec-file-name-without-extension || '-result.xml'" />
					<xml actual="{resolve-uri($xml-file-name, $actual-reports-dir-uri)}"
						expected="{resolve-uri($xml-file-name, $expected-reports-dir-uri)}"
						processor-dir="{resolve-uri('xml/', $processor-dir-uri)}" />

					<!-- HTML -->
					<xsl:variable as="xs:string" name="html-file-name"
						select="$xspec-file-name-without-extension || '-result.html'" />
					<html actual="{resolve-uri($html-file-name, $actual-reports-dir-uri)}"
						expected="{resolve-uri($html-file-name, $expected-reports-dir-uri)}"
						processor-dir="{resolve-uri('html/', $processor-dir-uri)}" />

					<!-- JUnit -->
					<xsl:variable as="xs:string" name="junit-file-name"
						select="$xspec-file-name-without-extension || '-junit.xml'" />
					<junit actual="{resolve-uri($junit-file-name, $actual-reports-dir-uri)}"
						expected="{resolve-uri($junit-file-name, $expected-reports-dir-uri)}"
						processor-dir="{resolve-uri('junit/', $processor-dir-uri)}" />
				</xsl:if>
			</reports>
		</xsl:variable>

		<!--
			Begin outputting nodes into <run-xspec>
		-->

		<!-- Attributes to instruct XSpec to write the test reports into specific files -->
		<xsl:for-each select="$reports/element()">
			<xsl:attribute name="output-{name()}-url" select="@actual" />
		</xsl:for-each>

		<!-- Tasks to be performed after running XSpec -->
		<post-task>
			<xsl:call-template name="on-post-task">
				<xsl:with-param name="reports" select="$reports" />
			</xsl:call-template>
		</post-task>
	</xsl:template>

	<!--
		Named template to be overridden
	-->

	<!-- Override this template to provide <post-task> with additional nodes -->
	<xsl:template as="empty-sequence()" name="on-post-task">
		<xsl:context-item as="attribute()" use="required" />

		<xsl:param as="element(reports)" name="reports" required="yes" />
	</xsl:template>
</xsl:stylesheet>
