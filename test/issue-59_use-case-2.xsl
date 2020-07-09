<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:issue-59="https://github.com/xspec/xspec/issues/59#issuecomment-281689650"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:function as="attribute()+"
		name="issue-59:extract-local-name-and-namespace-from-lexical-qname">
		<xsl:param as="xs:string" name="lexical-qname" />

		<xsl:variable as="xs:QName" name="qname" select="xs:QName($lexical-qname)" />
		<xsl:attribute name="local-name" select="local-name-from-QName($qname)" />
		<xsl:attribute name="namespace" select="namespace-uri-from-QName($qname)" />
	</xsl:function>
</xsl:stylesheet>
