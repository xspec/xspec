<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="${xspec.project.dir.url}src/reporter/coverage-report.xsl" />

	<xsl:template as="element(xhtml:html)" match="document-node()">
		<!-- Check the coverage trace XML -->
		<xsl:variable as="map(xs:string, item())" name="check-result-map" select="
				transform(
				map {
					'delivery-format': 'raw',
					'source-node': .,
					'stylesheet-location': '${test-maven-jar.check-coverage-xml.xsl.url}'
				}
				)" />
		<xsl:variable as="xs:string" name="check-result-string" select="$check-result-map?output" />
		<xsl:if test="$check-result-string => xs:boolean() => not()">
			<xsl:message terminate="yes" />
		</xsl:if>

		<!-- Transfer control to the original reporter -->
		<xsl:next-match />
	</xsl:template>

</xsl:stylesheet>
