<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="x-urn:xspec:test:xspec-bat">

	<xsl:output method="text" />

	<xsl:template as="text()+" match="document-node()">
		<xsl:apply-templates select="collection" />
	</xsl:template>

	<xsl:template as="text()+" match="collection">
		<!-- Tell the number of test cases -->
		<xsl:call-template name="write">
			<xsl:with-param name="text" xml:space="preserve">
:get-num-cases
	set NUM_CASES=<xsl:value-of select="count(child::case)" />
	goto :EOF
</xsl:with-param>
		</xsl:call-template>

		<!-- Write each case -->
		<xsl:apply-templates select="case" />
	</xsl:template>

	<xsl:template as="text()+" match="case">
		<!-- Prologue -->
		<xsl:call-template name="write">
			<xsl:with-param name="text" xml:space="preserve">
:case_<xsl:value-of select="position()" />
	call :setup "<xsl:value-of select="@name" />"
</xsl:with-param>
		</xsl:call-template>

		<!-- Prerequisites -->
		<xsl:apply-templates select="@ifdef" />

		<!-- Script body -->
		<xsl:call-template name="write">
			<xsl:with-param as="xs:string" name="text" select="." />
		</xsl:call-template>

		<!-- Epilogue -->
		<xsl:call-template name="write">
			<xsl:with-param name="text" xml:space="preserve">
	goto :EOF
</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Writes ifdef skips -->
	<xsl:template as="text()+" match="@ifdef">
		<xsl:call-template name="write">
			<xsl:with-param name="text">
				<xsl:for-each select="tokenize(., '\s')[.]" xml:space="preserve">
	if not defined <xsl:value-of select="." /> (
		call :skip "<xsl:value-of select="." /> is not defined"
		goto :EOF
	)
</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Writes lines with CR LF -->
	<xsl:template as="text()+" name="write">
		<xsl:context-item use="absent" use-when="element-available('xsl:context-item')" />

		<xsl:param as="xs:string" name="text" required="yes" />

		<xsl:value-of select="tokenize($text, '\n')" separator="&#x0D;&#x0A;" />
	</xsl:template>
</xsl:stylesheet>
