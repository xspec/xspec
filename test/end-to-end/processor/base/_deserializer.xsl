<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:deserializer="x-urn:xspec:test:end-to-end:processor:deserializer"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module helps deserialize the document.
	-->

	<!--
		Returns the XML version ('1.0' or '1.1') of the serialized document.
		This is an ad hoc implementation only suitable for the report files.
	-->
	<xsl:function as="xs:string" name="deserializer:xml-version">
		<xsl:param as="xs:string" name="document-uri" />

		<xsl:variable as="xs:string" name="document-string" select="unparsed-text($document-uri)" />
		<xsl:variable as="xs:string" name="regex"
			><![CDATA[^<\?xml version="(1\.[01])" encoding="UTF-8"\?>.*]]></xsl:variable>
		<xsl:analyze-string regex="{$regex}" select="$document-string">
			<xsl:matching-substring>
				<xsl:value-of select="regex-group(1)" />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>

	<!--
		mode=unindent
			Removes side effect of loading indented XML
	-->

	<!-- Shallow-copy by default -->
	<xsl:mode name="deserializer:unindent" on-multiple-match="fail" on-no-match="shallow-copy" />

	<!-- The other processing depends on each processor... -->
</xsl:stylesheet>
