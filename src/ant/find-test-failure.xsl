<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Finds any test failure in XSpec test result XML file.
		Output XML structure is for Ant <xmlproperty> task.
	-->
	<xsl:template as="element(xspec)" match="document-node()">
		<xspec>
			<passed>
				<xsl:value-of select="empty(//x:scenario/x:test/@successful[not(xs:boolean(.))])" />
			</passed>
		</xspec>
	</xsl:template>
</xsl:stylesheet>
