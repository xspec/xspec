<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:fv="x-urn:test:function-in-variable"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		Returns the first and last items in a sequence.
		If sequence has fewer than 2 items, returns sequence intact.
	-->
	<xsl:variable name="fv:first-last" as="function(*)"
		select="function($param-items as item()*) as item()* {
			(head($param-items), $param-items[last()][count($param-items) gt 1])
		}" />

	<xsl:variable name="fv:function-item" as="function(*)"
		select="function() as function(*) {
			function-lookup(QName('http://www.w3.org/2005/xpath-functions','head'),1)
		}" />
</xsl:stylesheet>
