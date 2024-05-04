<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0" xmlns:dct="http://purl.org/dc/terms/"
	xmlns:local="x-urn:xspec:test:end-to-end:processor:xml:normalizer:local"
	xmlns:normalizer="x-urn:xspec:test:end-to-end:processor:normalizer"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module helps normalize the coverage data XML.
	-->
		
	<!--
		Normalizes the link to the files inside the repository
			Example:
				in:  <trace xspec="file:/path/to/test.xspec">
				out: <trace xspec="../path/to/test.xspec">
	-->
	<xsl:template as="attribute()" match="trace/@xspec | module/@uri | util/@uri" mode="normalizer:normalize">
		<xsl:param as="xs:anyURI" name="tunnel_document-uri" required="yes" tunnel="yes" />

		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="normalizer:relative-uri(., $tunnel_document-uri)" />
	</xsl:template>

	<!--
		Retains only the file name of the compiled file, because the URI
		is in a temporary directory.
	-->
	<xsl:template as="attribute()" match="compiled/@uri" mode="normalizer:normalize">
		<xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
			select="replace(string(.),'^.*/','')" />		
	</xsl:template>

</xsl:stylesheet>
