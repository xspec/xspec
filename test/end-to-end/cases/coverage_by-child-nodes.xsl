<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template as="element(hit)+" name="test">

		<!--
			'hit' or 'miss' of these nodes is determined by child nodes.
		-->

		<!--
			xsl:for-each
		-->

		<xsl:for-each select="1">
			<hit />
		</xsl:for-each>

		<xsl:for-each select="()">
			<xsl:message terminate="yes" />
		</xsl:for-each>

		<!--
			xsl:for-each-group
		-->

		<xsl:for-each-group group-by="." select="1">
			<hit />
		</xsl:for-each-group>

		<xsl:for-each-group group-by="." select="()">
			<xsl:message terminate="yes" />
		</xsl:for-each-group>

		<!--
			xsl:matching-substring
			xsl:non-matching-substring
		-->

		<xsl:analyze-string regex="a" select="'a'">
			<xsl:matching-substring>
				<hit />
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:message terminate="yes" />
			</xsl:non-matching-substring>
		</xsl:analyze-string>

		<xsl:analyze-string regex="b" select="'a'">
			<xsl:matching-substring>
				<xsl:message terminate="yes" />
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<hit />
			</xsl:non-matching-substring>
		</xsl:analyze-string>

		<!--
			xsl:otherwise
			xsl:when
		-->

		<xsl:choose>
			<xsl:when test="1 lt 2">
				<hit />
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes" />
			</xsl:otherwise>
		</xsl:choose>

		<xsl:choose>
			<xsl:when test="2 lt 1">
				<xsl:message terminate="yes" />
			</xsl:when>
			<xsl:otherwise>
				<hit />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
