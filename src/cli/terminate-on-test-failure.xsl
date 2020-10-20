<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="../common/parse-report.xsl" />

	<xsl:output method="text" />

	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="empty-sequence()" match="document-node(element(x:report))">
		<xsl:sequence select="x:descendant-failed-tests(.) ! error()" />
	</xsl:template>

</xsl:stylesheet>
