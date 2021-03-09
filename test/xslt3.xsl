<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="xs" version="3.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template name="supportXPath3">
		<xsl:context-item use="absent" />

		<root>
			<question>
				<xsl:text>Does XSpec support XPath 3.0?</xsl:text>
			</question>
			<answer>
				<xsl:value-of select="
						let $answer := 'Yes it does'
						return
							$answer" />
			</answer>
		</root>
	</xsl:template>

</xsl:stylesheet>
