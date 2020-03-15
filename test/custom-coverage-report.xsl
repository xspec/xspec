<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="../src/reporter/coverage-report.xsl" />

	<xsl:template as="node()+" match="/">
		<!-- Just insert a comment into the document -->
		<xsl:comment>Customized coverage report</xsl:comment>

		<xsl:apply-imports />
	</xsl:template>

</xsl:stylesheet>
