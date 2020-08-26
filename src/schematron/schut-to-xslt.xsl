<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		$STEP?-PREPROCESSOR-DOC is for ../../bin/xspec.* who can pass a document node as a
		stylesheet parameter but can not handle URI natively.
		Those who can pass a URI as a stylesheet parameter natively will probably prefer
		$STEP?-PREPROCESSOR-URI.
	-->
	<xsl:param as="document-node()?" name="STEP1-PREPROCESSOR-DOC" />
	<xsl:param as="document-node()?" name="STEP2-PREPROCESSOR-DOC" />
	<xsl:param as="document-node()?" name="STEP3-PREPROCESSOR-DOC" />

	<xsl:param as="xs:string" name="STEP1-PREPROCESSOR-URI"
		select="'../../lib/iso-schematron/iso_dsdl_include.xsl'" />
	<xsl:param as="xs:string" name="STEP2-PREPROCESSOR-URI"
		select="'../../lib/iso-schematron/iso_abstract_expand.xsl'" />
	<xsl:param as="xs:string?" name="STEP3-PREPROCESSOR-URI"
		select="document-uri($STEP3-PREPROCESSOR-DOC)" />

	<xsl:param as="xs:boolean" name="CACHE" select="false()" />

	<xsl:include href="../common/uri-utils.xsl" />
	<xsl:include href="locate-schematron-uri.xsl" />

	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="document-node()" match="document-node(element(x:description))">
		<xsl:variable as="map(xs:string, item())+" name="common-options-map">
			<xsl:map-entry key="'cache'" select="$CACHE" />
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
							select="$STEP3-PREPROCESSOR-URI" />
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
					<xsl:when test="$STEP1-PREPROCESSOR-DOC">
						<xsl:map-entry key="'stylesheet-node'" select="$STEP1-PREPROCESSOR-DOC" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:map-entry key="'stylesheet-location'" select="$STEP1-PREPROCESSOR-URI"
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
					<xsl:when test="$STEP2-PREPROCESSOR-DOC">
						<xsl:map-entry key="'stylesheet-node'" select="$STEP2-PREPROCESSOR-DOC" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:map-entry key="'stylesheet-location'" select="$STEP2-PREPROCESSOR-URI"
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
