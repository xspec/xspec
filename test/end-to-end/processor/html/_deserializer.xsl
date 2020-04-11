<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:deserializer="x-urn:xspec:test:end-to-end:processor:deserializer"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.w3.org/1999/xhtml">

	<!--
		This stylesheet module helps deserialize the test result HTML.
	-->

	<!--
		Removes insignificant whitespace (artifact of serialization indent) from text node
			This is an ad hoc implementation only suitable for the test result HTML.
	-->
	<xsl:template as="text()?"
		match="
			text()[not(
			parent::pre
			or
			parent::script
			or
			parent::span/parent::pre)]"
		mode="deserializer:unindent">
		<xsl:choose>
			<xsl:when test="normalize-space()">
				<!-- Remove whitespace-only tail line -->
				<xsl:variable as="xs:string" name="tail-removed" select="replace(., '\n +$', '')" />

				<!-- Compress whitespace -->
				<xsl:value-of select="replace($tail-removed, '[ \n\t]+', ' ')" />
			</xsl:when>
			<xsl:otherwise>
				<!-- Remove whitespace-only text node -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
