<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet transforms a template of Ant build file into a working build file.
		In doing so, the stylesheet scans all the XSpec files in $XSPECFILES-DIR-URI and
		creates a series of <run-xspec> elements based on /x:description/@*.
	-->

	<xsl:include href="../../../src/common/version-utils.xsl" />
	<xsl:include href="../../../src/common/yes-no-utils.xsl" />
	<xsl:include href="../../test-utils.xsl" />

	<xsl:output indent="yes" />

	<!-- Absolute URI of directory where *.xspec files are located. Must ends with '/'. -->
	<xsl:param as="xs:anyURI" name="XSPECFILES-DIR-URI" required="yes" />

	<!-- Query parameter for fn:collection() -->
	<xsl:param as="xs:string" name="XSPECFILES-DIR-URI-QUERY" required="yes" />

	<!-- XSLT processor capabilities -->
	<xsl:param as="xs:boolean" name="XSLT-SUPPORTS-SCHEMA" required="yes" />
	<xsl:param as="xs:boolean" name="XSLT-SUPPORTS-HOF" required="yes" />
	<xsl:param as="xs:boolean" name="XSLT-SUPPORTS-JREF" required="yes" />
	<xsl:param as="xs:boolean" name="XSLT-SUPPORTS-TIMESTAMP" required="yes" />

	<!-- XQuery processor capabilities -->
	<xsl:param as="xs:boolean" name="XQUERY-SUPPORTS-SCHEMA" required="yes" />
	<xsl:param as="xs:boolean" name="XQUERY-SUPPORTS-HOF" required="yes" />
	<xsl:param as="xs:boolean" name="XQUERY-SUPPORTS-JREF" required="yes" />
	<xsl:param as="xs:boolean" name="XQUERY-SUPPORTS-TIMESTAMP" required="yes" />

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

			<!-- Make environment variables accessible from 'xspec-test' processing instruction
				values -->
			<property environment="env" />

			<xsl:variable as="xs:string" name="collection-uri"
				select="($XSPECFILES-DIR-URI, $XSPECFILES-DIR-URI-QUERY) => string-join('?')" />

			<!--<xsl:message select="'Collecting:', $collection-uri" />-->
			<!-- collection() does not always work, due to a Saxon design change introduced by
				https://saxonica.plan.io/issues/4382. Setting <fileExtension> in a Saxon config file
				makes collection() work, but its /configuration/@edition ties Saxon to a specific
				edition (HE, PE or EE). A possible workaround, 'content-type' query parameter
				mentioned in https://saxonica.plan.io/issues/4476#note-14, is not widely available.
				Use uri-collection() + doc() instead. -->
			<xsl:variable as="document-node(element(x:description))+" name="xspec-docs"
				select="uri-collection($collection-uri) ! doc(.)" />

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

		<xsl:variable as="attribute(run-as)?" name="run-as" select="x:description/@run-as" />
		<xsl:variable as="xs:boolean" name="run-as-external" select="$run-as = 'external'" />
		<xsl:variable as="xs:string" name="xspec-filename-and-extension"
			select="x:filename-and-extension($xspec-file-uri)" />
		<xsl:if
			test="not($run-as-external eq starts-with($xspec-filename-and-extension, 'external_'))">
			<xsl:message terminate="yes">
				<xsl:text expand-text="yes">ERROR: Filename '{$xspec-filename-and-extension}' and @run-as '{$run-as}' mismatch</xsl:text>
			</xsl:message>
		</xsl:if>

		<xsl:variable as="processing-instruction(xspec-test)*" name="pis"
			select="processing-instruction(xspec-test)" />
		<xsl:variable as="xs:boolean" name="enable-coverage" select="$pis = 'enable-coverage'" />
		<xsl:variable as="xs:boolean" name="require-timestamp"
			select="x:description/@measure-time => x:yes-no-synonym(false())" />

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
					<xsl:when test="
							($test-type eq 't')
							and $enable-coverage
							and ($x:saxon-version lt x:pack-version((12, 4)))">
						<!-- https://saxonica.plan.io/issues/6223 -->
						<xsl:text>XSLT Code Coverage requires Saxon version 12.4 or later</xsl:text>
					</xsl:when>

					<xsl:when test="
							($test-type eq 't')
							and ($pis = 'require-xslt-to-support-schema')
							and not($XSLT-SUPPORTS-SCHEMA)">
						<xsl:text>Requires schema-aware XSLT processor</xsl:text>
					</xsl:when>

					<xsl:when test="
							($test-type = ('s', 't'))
							and ($pis = 'require-xslt-to-support-hof')
							and not($XSLT-SUPPORTS-HOF)">
						<xsl:text>Requires XSLT processor to support higher-order functions</xsl:text>
					</xsl:when>

					<xsl:when test="
							($test-type eq 't')
							and ($pis = 'require-xslt-to-support-jref')
							and not($XSLT-SUPPORTS-JREF)">
						<xsl:text>Requires XSLT processor to support Java reflexive extension functions</xsl:text>
					</xsl:when>

					<xsl:when test="
							($test-type = ('s', 't'))
							and ($pis = 'require-xslt-to-support-threads')
							and not(system-property('xsl:product-version') => starts-with('EE '))">
						<xsl:text>Requires XSLT processor to support multi-threaded processing</xsl:text>
					</xsl:when>

					<xsl:when test="
							($test-type = ('s', 't'))
							and $require-timestamp
							and not($XSLT-SUPPORTS-TIMESTAMP)">
						<xsl:text>Requires XSLT processor to support timestamp</xsl:text>
					</xsl:when>

					<xsl:when test="
						($test-type = ('s', 't'))
						and ($pis = 'require-xslt-to-support-v4')
						and (
							($x:saxon-version lt x:pack-version(12)) or
							not(system-property('xsl:product-version') => matches('^[EP]E '))
						)">
						<!-- Requires EE or PE, version 12 and up -->
						<xsl:text>Requires XSLT processor to support XSLT 4</xsl:text>
					</xsl:when>

					<xsl:when test="
							($test-type eq 'q')
							and ($pis = 'require-xquery-to-support-schema')
							and not($XQUERY-SUPPORTS-SCHEMA)">
						<xsl:text>Requires schema-aware XQuery processor</xsl:text>
					</xsl:when>

					<xsl:when test="
							($test-type eq 'q')
							and ($pis = 'require-xquery-to-support-hof')
							and not($XQUERY-SUPPORTS-HOF)">
						<xsl:text>Requires XQuery processor to support higher-order functions</xsl:text>
					</xsl:when>

					<xsl:when test="
							($test-type eq 'q')
							and ($pis = 'require-xquery-to-support-jref')
							and not($XQUERY-SUPPORTS-JREF)">
						<xsl:text>Requires XQuery processor to support Java reflexive extension functions</xsl:text>
					</xsl:when>

					<xsl:when test="
							($test-type eq 'q')
							and $require-timestamp
							and not($XQUERY-SUPPORTS-TIMESTAMP)">
						<xsl:text>Requires XQuery processor to support timestamp</xsl:text>
					</xsl:when>

					<xsl:when test="
						($test-type = ('q'))
						and ($pis = 'require-xquery-to-support-v4')
						and (
							($x:saxon-version lt x:pack-version(12)) or
							not(system-property('xsl:product-version') => matches('^[EP]E '))
						)">
						<!-- Requires EE or PE, version 12 and up -->
						<xsl:text>Requires XQuery processor to support XQuery 4</xsl:text>
					</xsl:when>

					<xsl:when test="
							($pis = 'require-saxon-bug-4315-fixed')
							and ($x:saxon-version ge x:pack-version((9, 9)))
							and ($x:saxon-version le x:pack-version((9, 9, 1, 6)))">
						<xsl:text>Requires Saxon bug #4315 to have been fixed</xsl:text>
					</xsl:when>

					<xsl:when test="
							($pis = 'require-saxon-bug-4376-fixed')
							and ($x:saxon-version le x:pack-version((9, 9, 1, 5)))">
						<xsl:text>Requires Saxon bug #4376 to have been fixed</xsl:text>
					</xsl:when>

					<xsl:when test="
							($pis = 'require-saxon-bug-4471-fixed')
							and ($x:saxon-version lt x:pack-version((9, 9, 1, 7)))">
						<xsl:text>Requires Saxon bug #4471 to have been fixed</xsl:text>
					</xsl:when>

					<xsl:when test="
							($pis = 'require-saxon-bug-4483-fixed')
							and ($x:saxon-version eq x:pack-version((10, 0)))">
						<xsl:text>Requires Saxon bug #4483 to have been fixed</xsl:text>
					</xsl:when>

					<xsl:when test="
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

					<xsl:when test="
							($pis = 'require-saxon-bug-4696-fixed')
							and ($x:saxon-version ge x:pack-version((10, 0)))
							and ($x:saxon-version le x:pack-version((10, 2)))">
						<xsl:text>Requires Saxon bug #4696 to have been fixed</xsl:text>
					</xsl:when>

					<xsl:when test="
							($pis = 'require-saxon-bug-4835-fixed')
							and ($x:saxon-version le x:pack-version((10, 3)))">
						<xsl:text>Requires Saxon bug #4835 to have been fixed</xsl:text>
					</xsl:when>

					<xsl:when test="
							($pis = 'require-xspec-issue-1156-fixed')
							and
							(
							(environment-variable('TRAVIS_OS_NAME') eq 'linux')
							or
							(
							(environment-variable('GITHUB_ACTIONS') eq 'true')
							and
							(environment-variable('RUNNER_OS') eq 'macOS')
							)
							)">
						<xsl:text>Requires xspec/xspec#1156 to have been fixed</xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable as="xs:string?" name="skip">
				<xsl:if test="$skip">
					<xsl:text expand-text="yes">Skipping {$xspec-filename-and-extension} [{$test-type}{'c'[$enable-coverage]}]: {$skip}</xsl:text>
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

							<xsl:sequence select="
									$pis[starts-with(., 'saxon-custom-options=')]
									/substring-after(., 'saxon-custom-options=')" />
						</xsl:variable>
						<xsl:if test="exists($saxon-custom-options)">
							<xsl:attribute name="saxon-custom-options"
								select="$saxon-custom-options" />
						</xsl:if>

						<xsl:for-each select="
								'additional-classpath',
								'compiler-saxon-config',
								'coverage-reporter',
								'force-focus',
								'html-reporter',
								'schematron-preprocessor-step1',
								'schematron-preprocessor-step2',
								'schematron-preprocessor-step3',
								'xml-version'">
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

		<xsl:param as="xs:boolean" name="coverage-enabled" required="yes" />
	</xsl:template>
</xsl:stylesheet>
