<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="text" />

	<xsl:template as="text()" match="document-node()">
		<xsl:variable as="xs:string+" name="lines" select="document-uri(.) => unparsed-text-lines()" />
		<xsl:variable as="xs:string" name="regex"
			><![CDATA[^<\?xml version="(1\.[01])" encoding="UTF-8"\?>.*]]></xsl:variable>
		<xsl:analyze-string regex="{$regex}" select="$lines[1]">
			<xsl:matching-substring>
				<xsl:value-of select="regex-group(1)" />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>

</xsl:stylesheet>
