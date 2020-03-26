<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is just for checking to see if the XSLT processor supports higher-order functions -->
<xsl:stylesheet version="3.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template name="xsl:initial-template">
		<xsl:sequence select="function-lookup(xs:QName('xs:integer'), 1)(0)" />
	</xsl:template>
</xsl:stylesheet>
