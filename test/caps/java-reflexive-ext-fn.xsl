<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is just for checking to see if the XSLT processor supports Java reflexive extension functions -->
<xsl:stylesheet version="3.0" xmlns:jt="http://saxon.sf.net/java-type"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:global-context-item use="absent" />
	<xsl:template as="jt:java.lang.Runtime" name="xsl:initial-template">
		<xsl:sequence select="Q{java:java.lang.Runtime}getRuntime()" />
	</xsl:template>
</xsl:stylesheet>
