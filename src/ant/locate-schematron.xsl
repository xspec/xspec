<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:import href="../schematron/locate-schematron.xsl" />

	<xsl:output method="xml" />

	<!--
		Makes absolute URI from @schematron and resolves it with catalog.
		Output XML structure is for Ant <xmlproperty> task.
	-->
	<xsl:template as="element(xspec)" match="document-node()">
		<xspec>
			<schematron>
				<uri>
					<xsl:apply-imports />
				</uri>
			</schematron>
		</xspec>
	</xsl:template>
</xsl:stylesheet>
