<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0" xmlns:dct="http://purl.org/dc/terms/"
	xmlns:local="x-urn:xspec:test:end-to-end:processor:xml:normalizer:local"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module helps normalize the test result XML.
	-->

	<!--
		Normalizes the link to the files inside the repository
			Example:
				in:  <x:report xspec="file:/path/to/test.xspec">
				out: <x:report xspec="../path/to/test.xspec">
	-->
	<xsl:template as="attribute()" match="
			/x:report/attribute()[name() = ('query-at', 'schematron', 'xspec')]
			| /x:report[not(@schematron)]/@stylesheet
			| x:scenario/@xspec
			| x:scenario/input-wrap/x:call/x:param/@href
			| x:scenario/input-wrap/x:context/@href
			|
			/x:report[local:svrl-creator(.) eq 'skeleton']//x:scenario/x:result/content-wrap
			/svrl:schematron-output/svrl:active-pattern/@document[string()]" mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="normalizer:relative-uri(., $tunnel_document-uri)" />
	</xsl:template>

	<!--
		Normalizes the link to the files outside the repository
			Only the file name (and extension) is predictable.
	-->
	<xsl:template as="attribute()" match="
			/x:report[@schematron]/@stylesheet
			|
			/x:report[local:svrl-creator(.) eq 'schxslt']//x:scenario/x:result/content-wrap
			/svrl:schematron-output/svrl:active-pattern/@documents" mode="normalizer:normalize">
		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="x:filename-and-extension(.)" />
	</xsl:template>

	<!--
		Normalizes dct:created by copying another element text
	-->
	<xsl:template as="text()" match="
			/x:report[local:svrl-creator(.) eq 'schxslt']//x:scenario/x:result/content-wrap
			/svrl:schematron-output/svrl:metadata/dct:source/rdf:Description/dct:created/text()
			[. castable as xs:dateTimeStamp]" mode="normalizer:normalize">
		<xsl:value-of select="ancestor::svrl:metadata[1]/dct:created cast as xs:dateTimeStamp" />
	</xsl:template>

	<!--
		Normalizes skos:prefLabel
			Example:
				in:  <skos:prefLabel>SchXslt/1.6.2 SAXON/EE 9.9.1.7</skos:prefLabel>
				out: <skos:prefLabel>SchXslt/1.6.2 SAXON/product-version</skos:prefLabel>
				
				in:  <skos:prefLabel>SAXON/HE 9.9.1.7</skos:prefLabel>
				out: <skos:prefLabel>SAXON/product-version</skos:prefLabel>
	-->
	<xsl:template as="text()" match="
			/x:report[local:svrl-creator(.) eq 'schxslt']//x:scenario/x:result/content-wrap
			/svrl:schematron-output/svrl:metadata//dct:creator/dct:Agent/skos:prefLabel[. ne 'Unknown']/text()"
		mode="normalizer:normalize">
		<!-- Use analyze-string() so that the transformation will fail when nothing matches -->
		<xsl:analyze-string regex="^((?:SchXslt/[0-9.]+ )?SAXON/)[^/]+$" select=".">
			<xsl:matching-substring>
				<xsl:value-of select="regex-group(1) || 'product-version'" />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<!--
		Normalizes the link to the files created dynamically by XSpec
	-->
	<xsl:template as="attribute(href)" match="
			x:scenario/x:result/@href
			| x:scenario/x:test/x:expect/@href
			| x:scenario/x:test/x:result/@href" mode="normalizer:normalize">
		<xsl:call-template name="normalizer:normalize-external-link-attribute" />
	</xsl:template>

	<!--
		Normalizes x:timestamp
	-->
	<xsl:template as="attribute(at)" match="x:timestamp/@at[. castable as xs:dateTimeStamp]"
		mode="normalizer:normalize">
		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="/x:report/@date[. castable as xs:dateTimeStamp] => exactly-one()" />
	</xsl:template>

	<!--
		Private utility functions
	-->

	<!--
		Returns the SVRL creator name. Empty sequence if no SVRL.
	-->
	<xsl:function as="xs:string?" name="local:svrl-creator">
		<xsl:param as="node()" name="context-node" />

		<xsl:variable as="document-node(element(x:report))" name="doc" select="root($context-node)" />
		<xsl:variable as="element(svrl:schematron-output)?" name="svrl" select="
				$doc/x:report[@schematron]//x:scenario/x:result/content-wrap
				/svrl:schematron-output
				=> head()" />
		<xsl:if test="$svrl">
			<xsl:choose>
				<xsl:when test="
						$svrl/svrl:metadata/dct:source
						/rdf:Description/dct:creator/dct:Agent/skos:prefLabel
						=> starts-with('SchXslt/')">
					<xsl:sequence select="'schxslt'" />
				</xsl:when>

				<xsl:otherwise>
					<!-- Assume the "skeleton" Schematron implementation -->
					<xsl:sequence select="'skeleton'" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:function>

</xsl:stylesheet>
