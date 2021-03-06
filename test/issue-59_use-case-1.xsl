<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template as="attribute()" name="makeAtt">
		<xsl:context-item use="absent" />

		<xsl:param as="element()" name="e" required="yes" />
		<xsl:param as="xs:string" name="att" required="yes" />
		<xsl:param as="xs:string" name="val" required="yes" />

		<xsl:choose>
			<xsl:when test="$e/@*[name() = $att]">
				<xsl:variable as="xs:string" name="oldVal" select="string($e/@*[name() = $att])" />
				<xsl:attribute name="{$att}"
					select="string-join(distinct-values((tokenize($oldVal, ' +'), $val)), ' ')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="{$att}" select="$val" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
