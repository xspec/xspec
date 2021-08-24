<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:local="x-urn:xspec:test:end-to-end:processor:html:normalizer:local"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.w3.org/1999/xhtml">

	<!--
		This stylesheet module helps normalize the test result HTML.
	-->

	<!--
		When set, datetime is normalized to this value
	-->
	<xsl:param as="xs:dateTime?" name="NORMALIZE-HTML-DATETIME" static="yes" />

	<!--
		Normalizes the title text
			Example:
				in:  <title>Test Report for /path/to/tested.xsl (passed: 2 / pending: 0 / failed: 1 / total: 3)</title>
				out: <title>Test Report for tested.xsl (passed: 2 / pending: 0 / failed: 1 / total: 3)</title>
	-->
	<xsl:template as="text()" match="/html[local:is-xquery-report(.) => not()]/head/title/text()"
		mode="normalizer:normalize">
		<!-- Use analyze-string() so that the transformation will fail when nothing matches -->
		<xsl:analyze-string regex="^(Test Report for) (.+) (\([a-z0-9/: ]+\))$" select=".">
			<xsl:matching-substring>
				<xsl:value-of select="
						regex-group(1),
						x:filename-and-extension(regex-group(2)),
						regex-group(3)" />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<!--
		Replaces the embedded CSS with the link to its source
			For brevity. The details of style are not critical anyway.
	-->
	<xsl:template as="element(link)" match="style" mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<!-- Absolute URI of CSS -->
		<xsl:variable as="xs:anyURI" name="css-uri"
			select="resolve-uri('../../../../src/reporter/test-report.css')" />

		<link rel="stylesheet" type="text/css" xmlns="http://www.w3.org/1999/xhtml">
			<xsl:attribute name="href"
				select="normalizer:relative-uri($css-uri, $tunnel_document-uri)" />
		</link>
	</xsl:template>

	<!--
		Normalizes the link to the external CSS file
			Example:
				in:  href="file:/path/to/test-report.css"
				out: href="../path/to/test-report.css"
	-->
	<xsl:template as="attribute(href)" match="link[@rel eq 'stylesheet']/@href"
		mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="normalizer:relative-uri(., $tunnel_document-uri)" />
	</xsl:template>

	<!--
		Normalizes the links to the tested module and the XSpec file
			Example:
				in:  <a href="file:/path/to/tested.xsl">/path/to/tested.xsl</a>
				out: <a href="../path/to/tested.xsl">tested.xsl</a>
	-->
	<xsl:template as="element(a)" match="/html/body/p/a" mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:copy>
			<xsl:apply-templates mode="#current" select="attribute()" />
			<xsl:for-each select="@href">
				<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
					select="normalizer:relative-uri(., $tunnel_document-uri)" />
			</xsl:for-each>

			<xsl:value-of select="x:filename-and-extension(.)" />
		</xsl:copy>
	</xsl:template>

	<!--
		Normalizes datetime
			Example:
				in:  <p>Tested: 23 February 2017 at 11:18</p>
				out: <p>Tested: 1 January 2000 at 00:00</p>
	-->
	<xsl:template as="text()" match="/html/body/p[starts-with(., 'Tested:')]/text()"
		mode="normalizer:normalize" use-when="exists($NORMALIZE-HTML-DATETIME)">
		<!-- Format in the same way as XSPEC_HOME/src/reporter/format-xspec-report.xsl -->
		<xsl:variable as="xs:string" name="now"
			select="format-dateTime($NORMALIZE-HTML-DATETIME, '[D] [MNn] [Y] at [H01]:[m01]')" />

		<!-- Use analyze-string() so that the transformation will fail when nothing matches -->
		<xsl:analyze-string regex="^(Tested:) .+$" select=".">
			<xsl:matching-substring>
				<xsl:value-of select="regex-group(1), $now" />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<!--
		Normalizes the link to the files created dynamically by XSpec
	-->
	<xsl:template as="attribute(href)"
		match="table[contains-token(@class, 'xspecResult')]/tbody/tr/td/p/a/@href"
		mode="normalizer:normalize">
		<xsl:call-template name="normalizer:normalize-external-link-attribute" />
	</xsl:template>

	<xsl:template as="text()"
		match="table[contains-token(@class, 'xspecResult')]/tbody/tr/td/p/a[. eq @href]/text()"
		mode="normalizer:normalize">
		<xsl:value-of>
			<xsl:for-each select="parent::a/@href">
				<xsl:call-template name="normalizer:normalize-external-link-attribute" />
			</xsl:for-each>
		</xsl:value-of>
	</xsl:template>

	<!--
		Normalizes SVRL in Schematron Result

			Example (the "skeleton" Schematron implementation):
				in:  <svrl:active-pattern document="file:/.../tutorial/schematron/demo-02.xml"
				out: <svrl:active-pattern document="../../../../../tutorial/schematron/demo-02.xml"

			Example (SchXslt):
				in:  <svrl:active-pattern documents="file:/.../demo-02-compiled.xsl"
				out: <svrl:active-pattern documents="demo-02-compiled.xsl"
				
				in:  <dct:created>2021-03-03T21:34:06.276+01:00</dct:created>
				out: <dct:created>2000-01-01T00:00:00Z</dct:created>
				
				in:  <skos:prefLabel>SchXslt/1.6.2 SAXON/EE 9.9.1.7</skos:prefLabel>
				out: <skos:prefLabel>SchXslt/version SAXON/product-version</skos:prefLabel>
	-->
	<xsl:template as="text()" match="pre[contains-token(@class, 'svrl')]/text()"
		mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:choose>
			<xsl:when test="local:svrl-creator(.) eq 'skeleton'">
				<xsl:variable as="xs:string" name="regex">
					<xsl:text>
						^
						([ ]+&lt;svrl:active-pattern[ ]document=")	<!-- group 1 -->
						(\S+?)										<!-- group 2 -->
						(")											<!-- group 3 -->
						$
					</xsl:text>
				</xsl:variable>

				<xsl:value-of>
					<xsl:analyze-string flags="mx" regex="{$regex}" select=".">
						<xsl:matching-substring>
							<xsl:sequence select="
									regex-group(1),
									normalizer:relative-uri(regex-group(2), $tunnel_document-uri),
									regex-group(3)" />
						</xsl:matching-substring>

						<xsl:non-matching-substring>
							<xsl:copy />
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</xsl:value-of>
			</xsl:when>

			<xsl:when test="local:svrl-creator(.) eq 'schxslt'">
				<xsl:variable as="xs:string" name="regex">
					<xsl:text>
						^
						<!-- There are multiple dct:created. Identify the one by its leading spaces. -->
						[ ]{6}&lt;dct:created>
						(\S+?)					<!-- group 1 -->
						&lt;/dct:created>
						$
					</xsl:text>
				</xsl:variable>
				<xsl:variable as="element(fn:analyze-string-result)" name="analyzed"
					select="analyze-string(parent::pre, $regex, 'mx')" />
				<xsl:variable as="element(fn:group)" name="normalized-dct-created"
					select="$analyzed/fn:match/fn:group[@nr = 1]" />

				<xsl:variable as="xs:string" name="regex">
					<xsl:text>
						^
						(?:
							([ ]+(?:&lt;svrl:active-pattern[ ])?documents=")	<!-- group 1 -->
							(\S+?)												<!-- group 2 -->
							("[ ]/>)											<!-- group 3 -->
							|
							<!-- There are multiple dct:created. Identify the one by its leading spaces. -->
							([ ]{12}&lt;dct:created>)							<!-- group 4 -->
							\S+?
							(&lt;/dct:created>)									<!-- group 5 -->
							|
							([ ]+&lt;skos:prefLabel>SchXslt/)					<!-- group 6 -->
							[0-9.]+
							([ ]SAXON/)											<!-- group 7 -->
							[^/]+?
							(&lt;/skos:prefLabel>)								<!-- group 8 -->
						)
						$
					</xsl:text>
				</xsl:variable>

				<xsl:value-of>
					<xsl:analyze-string flags="mx" regex="{$regex}" select=".">
						<xsl:matching-substring>
							<xsl:choose>
								<xsl:when test="regex-group(1)">
									<xsl:sequence select="
											regex-group(1),
											x:filename-and-extension(regex-group(2)),
											regex-group(3)" />
								</xsl:when>
								<xsl:when test="regex-group(4)">
									<xsl:sequence select="
											regex-group(4),
											$normalized-dct-created,
											regex-group(5)" />
								</xsl:when>
								<xsl:when test="regex-group(6)">
									<xsl:sequence select="
											regex-group(6),
											'version',
											regex-group(7),
											'product-version',
											regex-group(8)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:message terminate="yes" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:matching-substring>

						<xsl:non-matching-substring>
							<xsl:copy />
						</xsl:non-matching-substring>
					</xsl:analyze-string>
				</xsl:value-of>
			</xsl:when>

			<xsl:otherwise>
				<xsl:message terminate="yes" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!--
		Normalizes elapsed time
	-->
	<xsl:template as="text()"
		match="span[contains-token(@class, 'elapsed-num')]/text()[. castable as xs:decimal]"
		mode="normalizer:normalize">
		<xsl:value-of select="xs:decimal(0)" />
	</xsl:template>

	<!--
		Private utility functions
	-->

	<!--
		Returns true if the HTML report is for XQuery
	-->
	<xsl:function as="xs:boolean" name="local:is-xquery-report">
		<xsl:param as="node()" name="context-node" />

		<xsl:variable as="document-node(element(html))" name="doc" select="root($context-node)" />
		<xsl:sequence select="$doc/html/body/starts-with(p[1], 'Query:')" />
	</xsl:function>

	<!--
		Returns true if the HTML report is for Schematron
	-->
	<xsl:function as="xs:boolean" name="local:is-schematron-report">
		<xsl:param as="node()" name="context-node" />

		<xsl:variable as="document-node(element(html))" name="doc" select="root($context-node)" />
		<xsl:sequence select="$doc/html/body/starts-with(p[1], 'Schematron:')" />
	</xsl:function>

	<!--
		Returns the SVRL creator name. Empty sequence if no SVRL.
	-->
	<xsl:function as="xs:string?" name="local:svrl-creator">
		<xsl:param as="node()" name="context-node" />

		<xsl:variable as="document-node(element(html))" name="doc" select="root($context-node)" />
		<xsl:variable as="element(pre)?" name="svrl-pre"
			select="$doc//pre[contains-token(@class, 'svrl')] => head()" />
		<xsl:if test="$svrl-pre">
			<!-- parse-xml() may fail to handle control characters when the serialized SVRL is XML
				1.1. Inspect the literal string instead of parsing it as XML. -->
			<xsl:variable as="xs:string" name="schxslt-xmlns"
				>xmlns:schxslt="https://doi.org/10.5281/zenodo.1495494"</xsl:variable>
			<xsl:variable as="xs:string" name="schxslt-agent"><![CDATA[<dct:Agent>
                  <skos:prefLabel>SchXslt/]]></xsl:variable>
			<xsl:choose>
				<xsl:when test="
						$svrl-pre/span[contains-token(@class, 'xmlns')][. eq $schxslt-xmlns]
						and $svrl-pre/text()[contains(., $schxslt-agent)]">
					<xsl:sequence select="'schxslt'" />
				</xsl:when>

				<xsl:otherwise>
					<!-- Assume the "skeleton" Schematron implementation -->
					<xsl:sequence select="'skeleton'" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:function>

	<!--
		Templates for format-xspec-report-folding.xsl
	-->

	<!--
		Normalizes image URI in script
	-->
	<xsl:template as="text()" match="script/text()" mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:variable as="xs:string" name="regex"
			><![CDATA[^( +icon\.src = ")(.+?)(" ;)$]]></xsl:variable>

		<xsl:value-of>
			<xsl:analyze-string flags="m" regex="{$regex}" select=".">
				<xsl:matching-substring>
					<xsl:sequence select="
							regex-group(1),
							normalizer:relative-uri(regex-group(2), $tunnel_document-uri),
							regex-group(3)" />
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:copy />
				</xsl:non-matching-substring>
			</xsl:analyze-string>
		</xsl:value-of>
	</xsl:template>

	<!--
		Normalizes image URI
	-->
	<xsl:template as="attribute(src)" match="img/@src" mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="normalizer:relative-uri(., $tunnel_document-uri)" />
	</xsl:template>

</xsl:stylesheet>
