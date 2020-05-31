<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog"
	xmlns:catalog="urn:oasis:names:tc:entity:xmlns:xml:catalog"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!-- URIs separated by semicolons (;) -->
	<xsl:param as="xs:string" name="CATALOG-URIS" />

	<xsl:param as="xs:string" name="BASE-URI" />

	<xsl:output indent="yes" />

	<xsl:template as="element(catalog:catalog)" name="xsl:initial-template">
		<xsl:context-item use="absent" />

		<xsl:variable as="xs:string+" name="catalog-uris" select="tokenize($CATALOG-URIS, ';')[.]" />

		<catalog>
			<xsl:attribute name="xml:base" select="$BASE-URI" />
			<xsl:for-each select="$catalog-uris">
				<nextCatalog catalog="{.}" />
			</xsl:for-each>
		</catalog>
	</xsl:template>

</xsl:stylesheet>
