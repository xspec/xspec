<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This stylesheet module is a collection of utilities to parse XSpec report XML.
		This module is used across component borders. Elements in this stylesheet must
		not affect the other stylesheets.
	-->

	<!--
		Returns a sequence of descendant x:test
	-->
	<xsl:function as="element(x:test)*" name="x:descendant-tests">
		<xsl:param as="node()" name="context-node" />

		<xsl:sequence select="$context-node/descendant::x:test[parent::x:scenario]" />
	</xsl:function>

	<!--
		Returns a sequence of descendant failed x:test
	-->
	<xsl:function as="element(x:test)*" name="x:descendant-failed-tests">
		<xsl:param as="node()" name="context-node" />

		<xsl:sequence select="x:descendant-tests($context-node)[x:is-failed-test(.)]" />
	</xsl:function>

	<!--
		Returns true if x:test represents success
	-->
	<xsl:function as="xs:boolean" name="x:is-passed-test">
		<xsl:param as="element(x:test)" name="test-element" />

		<xsl:sequence select="$test-element/(exists(@successful) and xs:boolean(@successful))" />
	</xsl:function>

	<!--
		Returns true if x:test represents failure
	-->
	<xsl:function as="xs:boolean" name="x:is-failed-test">
		<xsl:param as="element(x:test)" name="test-element" />

		<xsl:sequence select="$test-element/(exists(@successful) and not(xs:boolean(@successful)))"
		 />
	</xsl:function>

	<!--
		Returns true if x:test is pending
	-->
	<xsl:function as="xs:boolean" name="x:is-pending-test">
		<xsl:param as="element(x:test)" name="test-element" />

		<xsl:sequence select="$test-element/exists(@pending)" />
	</xsl:function>

</xsl:stylesheet>
