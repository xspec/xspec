<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
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

	<!-- Query parameter for fn:collection() -->
	<xsl:param as="xs:string" name="XSPECFILES-DIR-URI-QUERY" required="yes" />

	<!-- XSLT processor capabilities -->
	<xsl:param as="xs:boolean" name="XSLT-SUPPORTS-SCHEMA" required="yes" />
	<xsl:param as="xs:boolean" name="XSLT-SUPPORTS-HOF" required="yes" />

	<!-- XQuery processor capabilities -->
	<xsl:param as="xs:boolean" name="XQUERY-SUPPORTS-SCHEMA" required="yes" />
	<xsl:param as="xs:boolean" name="XQUERY-SUPPORTS-HOF" required="yes" />

	<!-- Saxon -now option -->
	<xsl:param as="xs:string?" name="NOW" />

	<!-- Parallel thread count -->
	<xsl:param as="xs:integer?" name="THREAD-COUNT" />

	<!--
		mode=#default
		Transforms a template of Ant build file into a working build file.
	-->
	<xsl:mode on-multiple-match="fail" on-no-match="shallow-copy" />

	<xsl:template as="element()" match="/element()">
		<xsl:copy>
			<xsl:apply-templates select="attribute()" />
			<xsl:comment expand-text="yes">Temporary build file generated from {document-uri(/)} at {current-dateTime()}</xsl:comment>
			<xsl:apply-templates />
		</xsl:copy>
	</xsl:template>

	<xsl:template as="element(target)" match="target[@name = 'run-all-xspec-files']">
		<xsl:copy>
			<xsl:apply-templates select="attribute() | node()" />

			<xsl:variable as="xs:string" name="collection-uri"
				select="string-join(($XSPECFILES-DIR-URI, $XSPECFILES-DIR-URI-QUERY), '?')" />

			<!--<xsl:message select="'Collecting:', $collection-uri" />-->
			<xsl:variable as="document-node()+" name="xspec-docs"
				select="collection($collection-uri)" />

			<parallel failonany="true">
				<xsl:choose>
					<xsl:when test="exists($THREAD-COUNT)">
						<xsl:attribute name="threadCount" select="$THREAD-COUNT" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="threadsPerProcessor" select="1" />
					</xsl:otherwise>
				</xsl:choose>

				<xsl:apply-templates mode="xspec" select="$xspec-docs">
					<xsl:sort select="document-uri(/)" />
				</xsl:apply-templates>
			</parallel>
		</xsl:copy>
	</xsl:template>

	<!--
		mode=xspec
		Transforms a .xspec document into a series of <run-xspec> elements (or comment nodes if skipped)
		based on /x:description/@*
	-->
	<xsl:mode name="xspec" on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="node()+" match="document-node(element(x:description))" mode="xspec">
		<xsl:variable as="xs:anyURI" name="xspec-file-uri" select="document-uri(/)" />

		<xsl:variable as="processing-instruction(xspec-test)*" name="pis"
			select="processing-instruction(xspec-test)" />
		<xsl:variable as="xs:boolean" name="enable-coverage" select="$pis = 'enable-coverage'" />
		<xsl:variable as="xs:boolean" name="require-xquery-to-support-3-1"
			select="x:description/@xquery-version = '3.1'" />

		<xsl:for-each select="x:description/(@query | @schematron | @stylesheet)">
			<xsl:sort select="name()" />

			<xsl:variable as="xs:string" name="test-type">
				<xsl:choose>
					<xsl:when test="name() = 'query'">q</xsl:when>
					<xsl:when test="name() = 'schematron'">s</xsl:when>
					<xsl:when test="name() = 'stylesheet'">t</xsl:when>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable as="xs:string?" name="skip">
				<xsl:choose>
					<xsl:when
						test="
							($test-type eq 't')
							and $enable-coverage
							and ($x:saxon-version ge x:pack-version(10))">
						<xsl:text>XSLT Code Coverage requires Saxon version less than 10 (xspec/xspec#852)</xsl:text>
					</xsl:when>

					<xsl:when
						test="
							($test-type eq 't')
							and ($pis = 'require-xslt-to-support-schema')
							and not($XSLT-SUPPORTS-SCHEMA)">
						<xsl:text>Requires schema-aware XSLT processor</xsl:text>
					</xsl:when>

					<xsl:when
						test="
							($test-type eq 't')
							and ($pis = 'require-xslt-to-support-hof')
							and not($XSLT-SUPPORTS-HOF)">
						<xsl:text>Requires XSLT processor to support higher-order functions</xsl:text>
					</xsl:when>

					<xsl:when
						test="
							($test-type eq 'q')
							and ($pis = 'require-xquery-to-support-schema')
							and not($XQUERY-SUPPORTS-SCHEMA)">
						<xsl:text>Requires schema-aware XQuery processor</xsl:text>
					</xsl:when>

					<xsl:when
						test="
							($test-type eq 'q')
							and ($pis = 'require-xquery-to-support-hof')
							and not($XQUERY-SUPPORTS-HOF)">
						<xsl:text>Requires XQuery processor to support higher-order functions</xsl:text>
					</xsl:when>

					<xsl:when
						test="
							($pis = 'require-saxon-bug-3543-fixed')
							and ($x:saxon-version lt x:pack-version((9, 8, 0, 7)))">
						<xsl:text>Requires Saxon bug #3543 to have been fixed</xsl:text>
					</xsl:when>

					<xsl:when
						test="
							($pis = 'require-saxon-bug-3889-fixed')
							and ($x:saxon-version lt x:pack-version((9, 8, 0, 15)))">
						<xsl:text>Requires Saxon bug #3889 to have been fixed</xsl:text>
					</xsl:when>

					<xsl:when
						test="
							($pis = 'require-saxon-bug-4315-fixed')
							and ($x:saxon-version ge x:pack-version((9, 9)))
							and ($x:saxon-version le x:pack-version((9, 9, 1, 6)))">
						<xsl:text>Requires Saxon bug #4315 to have been fixed</xsl:text>
					</xsl:when>

					<xsl:when
						test="
							($pis = 'require-saxon-bug-4376-fixed')
							and ($x:saxon-version le x:pack-version((9, 9, 1, 5)))">
						<xsl:text>Requires Saxon bug #4376 to have been fixed</xsl:text>
					</xsl:when>

					<xsl:when
						test="
							($pis = 'require-saxon-bug-4483-fixed')
							and ($x:saxon-version eq x:pack-version((10, 0)))">
						<xsl:text>Requires Saxon bug #4483 to have been fixed</xsl:text>
					</xsl:when>

					<xsl:when
						test="
							($pis = 'require-saxon-bug-4621-fixed')
							and
							(
							(
							($x:saxon-version ge x:pack-version(10))
							and
							($x:saxon-version le x:pack-version((10, 1)))
							)
							or
							($x:saxon-version le x:pack-version((9, 9, 1, 7)))
							)">
						<xsl:text>Requires Saxon bug #4621 to have been fixed</xsl:text>
					</xsl:when>

					<xsl:when
						test="
							($pis = 'require-saxon-bug-4666-fixed')
							and ($x:saxon-version ge x:pack-version((10, 0)))
							and ($x:saxon-version le x:pack-version((10, 1)))">
						<xsl:text>Requires Saxon bug #4666 to have been fixed</xsl:text>
					</xsl:when>

					<xsl:when
						test="
							($test-type eq 't')
							and (parent::x:description/@run-as eq 'external')
							and ($x:saxon-version lt x:pack-version((9, 8, 0, 8)))">
						<!-- Saxon changed 'vendor-options' on 9.8.0.8
							http://www.saxonica.com/documentation9.8/index.html#!functions/fn/transform -->
						<xsl:text>Requires transform() vendor-options saxon:configuration</xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable as="xs:string?" name="skip">
				<xsl:if test="$skip">
					<xsl:text expand-text="yes">Skipping {x:filename-and-extension($xspec-file-uri)} [{$test-type}{'c'[$enable-coverage]}]: {$skip}</xsl:text>
				</xsl:if>
			</xsl:variable>

			<xsl:choose>
				<xsl:when test="$skip">
					<xsl:message select="$skip" />
					<xsl:comment select="$skip" />
				</xsl:when>

				<xsl:otherwise>
					<run-xspec test-type="{$test-type}" xspec-file-url="{$xspec-file-uri}">
						<xsl:if test="$enable-coverage">
							<xsl:attribute name="enable-coverage" select="$enable-coverage" />
						</xsl:if>

						<xsl:variable as="xs:string*" name="saxon-custom-options">
							<xsl:if test="$NOW">
								<xsl:sequence select="'-now:' || $NOW" />
							</xsl:if>

							<xsl:sequence
								select="
									$pis[starts-with(., 'saxon-custom-options=')]
									/substring-after(., 'saxon-custom-options=')"
							 />
						</xsl:variable>
						<xsl:if test="exists($saxon-custom-options)">
							<xsl:attribute name="saxon-custom-options"
								select="$saxon-custom-options" />
						</xsl:if>

						<xsl:for-each
							select="
								'additional-classpath',
								'coverage-reporter',
								'force-focus',
								'html-reporter'">
							<xsl:variable as="xs:string" name="left-hand-side" select="." />
							<xsl:variable as="xs:string" name="starts-with"
								select="$left-hand-side || '='" />
							<xsl:for-each select="$pis[starts-with(., $starts-with)]">
								<xsl:attribute name="{$left-hand-side}"
									select="substring-after(., $starts-with)" />
							</xsl:for-each>
						</xsl:for-each>

						<xsl:call-template name="on-run-xspec">
							<xsl:with-param name="coverage-enabled" select="$enable-coverage" />
						</xsl:call-template>
					</run-xspec>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!--
		Named template to be overridden
	-->

	<!-- Override this template to provide <run-xspec> with additional nodes -->
	<xsl:template as="empty-sequence()" name="on-run-xspec">
		<xsl:context-item as="attribute()" use="required" />

		<xsl:param as="xs:boolean" name="coverage-enabled" />
	</xsl:template>
</xsl:stylesheet>
