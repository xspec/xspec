<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is just for checking to see if the XSLT processor supports saxon:timestamp() -->
<xsl:stylesheet version="3.0" xmlns:saxon="http://saxon.sf.net/"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:global-context-item use="absent" />
	<xsl:template as="xs:dateTimeStamp" name="xsl:initial-template">
		<xsl:context-item use="absent" />
		<xsl:sequence select="saxon:timestamp()" />
	</xsl:template>
</xsl:stylesheet>
