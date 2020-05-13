<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns=""
	xmlns:s1="http://example.org/ns/my/ns1"
	xmlns:s2="http://example.org/ns/my/ns2"
	xmlns:s3="http://example.org/ns/my/ns3"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:param name="s1:paramElementA" as="element()"><element-in-no-namespace/></xsl:param>
	<xsl:param name="s1:paramElementB" as="element()"><element-in-no-namespace/></xsl:param>

	<xsl:function name="s1:get_global_paramElementA" as="element()">
		<xsl:sequence select="$s1:paramElementA"/>
	</xsl:function>
	<xsl:function name="s1:get_global_paramElementB" as="element()">
		<xsl:sequence select="$s1:paramElementB"/>
	</xsl:function>

	<!-- Returns the items in the parameter intact -->
	<xsl:mode on-no-match="fail" use-when="element-available('xsl:mode')" />

	<xsl:template as="item()*" match="attribute() | node() | document-node()"
		name="s1:param-mirror">
		<xsl:param as="item()*" name="s1:param-items" />
		<xsl:sequence select="$s1:param-items" />
	</xsl:template>

	<xsl:function as="item()*" name="s1:param-mirror">
		<xsl:param as="item()*" name="s1:param-items" />
		<xsl:sequence select="$s1:param-items" />
	</xsl:function>

	<!-- Returns the distinct namespace URIs of the matched node and parameter. -->
	<xsl:mode name="s1:get-namespaces" on-no-match="fail" use-when="element-available('xsl:mode')" />

	<xsl:template as="xs:anyURI+" match="attribute() | node()"
		mode="s1:get-namespaces" name="s1:get-namespaces">
		<xsl:param name="s1:input" as="element()"/>
		<xsl:sequence select="distinct-values((namespace-uri(), namespace-uri($s1:input)))" />
	</xsl:template>

	<!-- Emulates fn:true() -->
	<xsl:function as="xs:boolean" name="s1:true">
		<xsl:sequence select="true()" />
	</xsl:function>

</xsl:stylesheet>
