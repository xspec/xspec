<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns=""
	xmlns:mirror="x-urn:test:mirror"
	xmlns:s2="http://example.org/ns/my/ns2"
	xmlns:s3="http://example.org/ns/my/ns3"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:param name="mirror:paramElementA" as="element()"><element-in-no-namespace/></xsl:param>
	<xsl:param name="mirror:paramElementB" as="element()"><element-in-no-namespace/></xsl:param>

	<xsl:function name="mirror:get_global_paramElementA" as="element()">
		<xsl:sequence select="$mirror:paramElementA"/>
	</xsl:function>
	<xsl:function name="mirror:get_global_paramElementB" as="element()">
		<xsl:sequence select="$mirror:paramElementB"/>
	</xsl:function>

	<!-- Returns the items in the parameter intact -->
	<xsl:mode on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="item()*" match="attribute() | node() | document-node()"
		name="mirror:param-mirror">
		<xsl:param as="item()*" name="mirror:param-items" required="yes" />
		<xsl:sequence select="$mirror:param-items" />
	</xsl:template>

	<xsl:function as="item()*" name="mirror:param-mirror">
		<xsl:param as="item()*" name="mirror:param-items" />
		<xsl:sequence select="$mirror:param-items" />
	</xsl:function>

	<!-- Returns the distinct namespace URIs of the matched node and parameter. -->
	<xsl:mode name="mirror:get-namespaces" on-multiple-match="fail" on-no-match="fail" />

	<xsl:template as="xs:anyURI+" match="attribute() | node()"
		mode="mirror:get-namespaces" name="mirror:get-namespaces">
		<xsl:param name="mirror:input" as="element()" required="yes" />
		<xsl:sequence select="distinct-values((namespace-uri(), namespace-uri($mirror:input)))" />
	</xsl:template>

	<!-- Emulates fn:true() -->
	<xsl:function as="xs:boolean" name="mirror:true">
		<xsl:sequence select="true()" />
	</xsl:function>

</xsl:stylesheet>
