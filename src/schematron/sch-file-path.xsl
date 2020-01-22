<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:file="http://expath.org/ns/file"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="../common/xspec-utils.xsl" />

	<xsl:output method="text" />

	<!--
		Obtains the fully resolved Schematron file URI
		and converts it to a native file path (or a format which resembles it).
	-->
	<xsl:template as="text()" match="document-node()">
		<xsl:variable as="xs:anyURI" name="schematron-uri"
			select="x:locate-schematron-uri(x:description)" />

		<!-- Convert URI to native (or wannabe native) -->
		<xsl:choose>
			<xsl:when test="true()" use-when="function-available('file:path-to-native')">
				<xsl:value-of select="file:path-to-native($schematron-uri)" />
			</xsl:when>

			<xsl:when test="true()">
				<!-- Escape some characters -->
				<xsl:variable as="xs:string" name="schematron-uri"
					select="iri-to-uri($schematron-uri)" />

				<!-- Omit 'file:' -->
				<xsl:variable as="xs:string" name="wannabe-native"
					select="replace($schematron-uri, '^file:', '')" />

				<xsl:choose>
					<!-- Windows -->
					<xsl:when test="system-property('file.separator') eq '\'">
						<!-- Remove '\' from '\C:' -->
						<xsl:variable as="xs:string" name="wannabe-native"
							select="replace($wannabe-native, '^/([A-Z]:)', '$1')" />

						<!-- Use backslash -->
						<xsl:value-of select="replace($wannabe-native, '/', '\\')" />
					</xsl:when>

					<!-- *nix -->
					<xsl:otherwise>
						<xsl:value-of select="$wannabe-native" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
