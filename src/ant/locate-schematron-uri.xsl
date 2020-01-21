<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:include href="../common/xspec-utils.xsl" />

	<!--
		Just outputs the fully resolved Schematron file URI.
		Output XML structure is for Ant <xmlproperty> task.
	-->
	<xsl:template as="element(xspec)" match="document-node()">
		<xspec>
			<schematron>
				<uri>
					<xsl:value-of select="x:locate-schematron-uri(x:description)" />
				</uri>
			</schematron>
		</xspec>
	</xsl:template>
</xsl:stylesheet>
