<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		$step?-preprocessor-doc is for ../../bin/xspec.* who can pass a document node as a
		stylesheet parameter but can not handle URI natively.
		Those who can pass a URI as a stylesheet parameter natively will probably prefer
		$step?-preprocessor-uri.
	-->
	<xsl:param as="document-node()?" name="step1-preprocessor-doc" />
	<xsl:param as="document-node()?" name="step2-preprocessor-doc" />
	<xsl:param as="document-node()?" name="step3-preprocessor-doc" />

	<xsl:param as="xs:string" name="step1-preprocessor-uri"
		select="'iso-schematron/iso_dsdl_include.xsl'" />
	<xsl:param as="xs:string" name="step2-preprocessor-uri"
		select="'iso-schematron/iso_abstract_expand.xsl'" />
	<xsl:param as="xs:string" name="step3-preprocessor-uri"
		select="
			(: Zero-length string signals generate-step3-wrapper.xsl to use the default Step 3
				preprocessor :)
			''" />

	<xsl:include href="../common/xspec-utils.xsl" />

	<xsl:mode on-no-match="fail" />

	<xsl:template as="document-node()" match="document-node(element(x:description))">
		<xsl:variable as="map(xs:string, item())+" name="common-options-map">
			<xsl:map-entry key="'cache'" select="false()" />
		</xsl:variable>

		<!--
			Generate Step3 wrapper
		-->
		<xsl:variable as="map(xs:string, item())" name="step3-wrapper-generation-options-map">
			<xsl:map>
				<xsl:sequence select="$common-options-map" />
				<xsl:map-entry key="'source-node'" select="." />
				<xsl:map-entry key="'stylesheet-location'" select="'generate-step3-wrapper.xsl'" />
				<xsl:map-entry key="'stylesheet-params'">
					<xsl:map>
						<xsl:map-entry key="xs:QName('ACTUAL-PREPROCESSOR-URI')"
							select="
								if ($step3-preprocessor-doc) then
									document-uri($step3-preprocessor-doc)
								else
									$step3-preprocessor-uri"
						 />
					</xsl:map>
				</xsl:map-entry>
			</xsl:map>
		</xsl:variable>
		<xsl:variable as="document-node()" name="step3-wrapper-doc"
			select="transform($step3-wrapper-generation-options-map)?output" />

		<!--
			Step 1
		-->
		<xsl:variable as="xs:anyURI" name="schematron-uri"
			select="x:locate-schematron-uri(x:description)" />
		<xsl:variable as="map(xs:string, item())" name="step1-options-map">
			<xsl:map>
				<xsl:sequence select="$common-options-map" />
				<xsl:map-entry key="'source-location'" select="$schematron-uri" />
				<xsl:choose>
					<xsl:when test="$step1-preprocessor-doc">
						<xsl:map-entry key="'stylesheet-node'" select="$step1-preprocessor-doc" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:map-entry key="'stylesheet-location'" select="$step1-preprocessor-uri"
						 />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:map>
		</xsl:variable>
		<xsl:variable as="document-node()" name="step1-transformed-doc"
			select="transform($step1-options-map)?output" />

		<!--
			Step 2
		-->
		<xsl:variable as="map(xs:string, item())" name="step2-options-map">
			<xsl:map>
				<xsl:sequence select="$common-options-map" />
				<xsl:map-entry key="'source-node'" select="$step1-transformed-doc" />
				<xsl:choose>
					<xsl:when test="$step2-preprocessor-doc">
						<xsl:map-entry key="'stylesheet-node'" select="$step2-preprocessor-doc" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:map-entry key="'stylesheet-location'" select="$step2-preprocessor-uri"
						 />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:map>
		</xsl:variable>
		<xsl:variable as="document-node()" name="step2-transformed-doc"
			select="transform($step2-options-map)?output" />

		<!--
			Step 3
		-->
		<xsl:variable as="map(xs:string, item())" name="step3-options-map">
			<xsl:map>
				<xsl:sequence select="$common-options-map" />
				<xsl:map-entry key="'source-node'" select="$step2-transformed-doc" />
				<xsl:map-entry key="'stylesheet-node'" select="$step3-wrapper-doc" />
			</xsl:map>
		</xsl:variable>
		<xsl:variable as="map(*)" name="step3-transformed-map"
			select="transform($step3-options-map)" />
		<xsl:sequence select="$step3-transformed-map?output" />
	</xsl:template>

</xsl:stylesheet>
