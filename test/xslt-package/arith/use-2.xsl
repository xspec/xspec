<?xml version="1.0" encoding="UTF-8"?>
<!-- Based on https://github.com/xspec/xspec/issues/762#issuecomment-589986214 -->
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:f="http://example.org/complex-arithmetic.xsl" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:use-package name="http://example.org/complex-arithmetic.xsl" version="1.0" />

	<xsl:output method="adaptive" />

	<xsl:template match="MyNumbers" as="map(xs:integer, xs:double)+">
		<xsl:variable as="xs:double*" name="real-numbers" select="Real/nbr" />
		<xsl:variable as="xs:double*" name="imaginary-numbers" select="Imaginary/nbr" />
		<xsl:sequence
			select="
				for $r in $real-numbers,
					$i in $imaginary-numbers
				return
					f:complex-number($r, $i)"
		 />
	</xsl:template>

</xsl:stylesheet>
