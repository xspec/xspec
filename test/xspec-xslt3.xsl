<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs" version="3.0">

	<xsl:template name="supportXPath3">
		<root>
			<question><xsl:text>Does XSpec support XPath 3.0?</xsl:text></question>
			<answer><xsl:value-of select="let $answer := 'Yes it does' return $answer"/></answer>
		</root>
	</xsl:template>

</xsl:stylesheet>
