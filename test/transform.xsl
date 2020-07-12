<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0" xmlns:transform="x-urn:test:transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:function as="xs:integer" name="transform:square">
		<xsl:param as="xs:integer" name="n" />

		<xsl:sequence
			select="
				transform(
				map {
					'delivery-format': 'raw',
					'function-params': [$n],
					'initial-function': QName('http://example.org/ns/my', 'square'),
					'stylesheet-location': 'external_square.xsl'
				}
				)?output"
		 />
	</xsl:function>

</xsl:stylesheet>
