<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:myp="http://example.org/ns/my/param" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		myp:get()
	-->

	<!-- myp:get#0 returns $myp:default -->

	<xsl:param as="item()+" name="myp:default" />

	<xsl:function as="item()+" name="myp:get" visibility="final">
		<xsl:sequence select="$myp:default" />
	</xsl:function>

	<!-- myp:get#1 returns the specified global parameter -->

	<xsl:param as="item()+" name="myp:bracketed" />
	<xsl:param as="item()+" name="myp:description-param" />
	<xsl:param as="item()+" name="myp:local" />
	<xsl:param as="item()+" name="myp:outer" />
	<xsl:param as="item()+" name="myp:param-after-variable" />
	<xsl:param as="item()+" name="myp:param-between-variables" />
	<xsl:param as="item()+" name="myp:param-before-variable" />

	<xsl:function as="item()+" name="myp:get" visibility="final">
		<xsl:param as="xs:QName" name="name" />

		<xsl:choose>
			<xsl:when test="$name eq xs:QName('myp:bracketed')">
				<xsl:sequence select="$myp:bracketed" />
			</xsl:when>
			<xsl:when test="$name eq xs:QName('myp:description-param')">
				<xsl:sequence select="$myp:description-param" />
			</xsl:when>
			<xsl:when test="$name eq xs:QName('myp:local')">
				<xsl:sequence select="$myp:local" />
			</xsl:when>
			<xsl:when test="$name eq xs:QName('myp:outer')">
				<xsl:sequence select="$myp:outer" />
			</xsl:when>
			<xsl:when test="$name eq xs:QName('myp:param-after-variable')">
				<xsl:sequence select="$myp:param-after-variable" />
			</xsl:when>
			<xsl:when test="$name eq xs:QName('myp:param-before-variable')">
				<xsl:sequence select="$myp:param-before-variable" />
			</xsl:when>
			<xsl:when test="$name eq xs:QName('myp:param-between-variables')">
				<xsl:sequence select="$myp:param-between-variables" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:message select="'Unknown QName:', $name" terminate="yes" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!--
		Named template wrapper of myp:get()
	-->
	<xsl:template as="item()+" name="myp:get">
		<xsl:context-item use="absent" />

		<xsl:param as="xs:QName?" name="qname" />

		<xsl:sequence select="
				if (exists($qname)) then
					myp:get($qname)
				else
					myp:get()" />
	</xsl:template>

	<!--
		Unnamed template wrapper of myp:get()
	-->

	<xsl:mode name="myp:get" on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="item()+" match="." mode="myp:get">
		<xsl:param as="xs:QName?" name="qname" />

		<xsl:sequence select="
				if (exists($qname)) then
					myp:get($qname)
				else
					myp:get()" />
	</xsl:template>

</xsl:stylesheet>
