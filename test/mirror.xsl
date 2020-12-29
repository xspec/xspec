<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0" xmlns:local="x-urn:test:mirror:xsl"
	xmlns:mirror="x-urn:test:mirror" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Returns the context node intact
	-->
	<xsl:mode name="mirror:context-mirror" on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="item()" match="." mode="mirror:context-mirror" name="mirror:context-mirror">
		<xsl:sequence select="." />
	</xsl:template>

	<!--
		Returns the items in the non-tunnel parameter intact
	-->
	<xsl:mode name="mirror:param-mirror" on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="item()*" match="attribute() | node() | document-node()"
		mode="mirror:param-mirror" name="mirror:param-mirror">
		<xsl:param as="item()*" name="param-items" tunnel="no" />

		<xsl:sequence select="$param-items" />
	</xsl:template>

	<!--
		Returns the items in the tunnel parameter intact
	-->
	<xsl:mode name="mirror:tunnel-param-mirror" on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="item()*" match="attribute() | node() | document-node()"
		mode="mirror:tunnel-param-mirror" name="mirror:tunnel-param-mirror">
		<xsl:call-template name="local:get-tunnel-param" />
	</xsl:template>

	<xsl:template as="item()*" name="local:get-tunnel-param">
		<xsl:param as="item()*" name="tunnel-param-items" tunnel="yes" />

		<xsl:sequence select="$tunnel-param-items" />
	</xsl:template>

	<!--
		Returns the items in the parameter intact
	-->
	<xsl:function as="item()*" name="mirror:param-mirror">
		<xsl:param as="item()*" name="param-items" />

		<xsl:sequence select="$param-items" />
	</xsl:function>

	<!--
		Emulates fn:trace#2
	-->
	<xsl:function as="item()*" name="mirror:trace">
		<xsl:param as="item()*" name="items" />
		<xsl:param as="xs:string" name="label" />

		<xsl:sequence select="trace($items, $label)" />
	</xsl:function>

	<!--
		Emulates fn:true()
	-->
	<xsl:function as="xs:boolean" name="mirror:true">
		<xsl:sequence select="true()" />
	</xsl:function>

	<!--
		Emulates fn:false()
	-->
	<xsl:function as="xs:boolean" name="mirror:false">
		<xsl:sequence select="false()" />
	</xsl:function>

	<!--
		Emulates fn:upper-case()
	-->
	<xsl:function as="xs:string" name="mirror:upper-case">
		<xsl:param as="xs:string?" name="input" />

		<xsl:sequence select="upper-case($input)" />
	</xsl:function>

</xsl:stylesheet>
