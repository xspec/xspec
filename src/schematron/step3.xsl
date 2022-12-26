<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="3.0"
	xmlns:axsl="http://www.w3.org/1999/XSL/TransformAlias"
	xmlns:iso="http://purl.oclc.org/dsdl/schematron"
	xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<!--
		This master stylesheet is a privately patched version of the original Schematron Step 3
		preprocessor.
	-->

	<!--
		Import the original Schematron Step 3 preprocessor
	-->
	<xsl:import href="../../lib/iso-schematron/iso_svrl_for_xslt2.xsl" />
	<xsl:include href="step3-override-process-assert.xsl"/>

	<!--
		Setting this parameter true activates the patch for @location containing text node
	-->
	<xsl:param as="xs:boolean" name="x:enable-schematron-text-location" select="false()" />

	<xsl:template as="node()+" match="element()" mode="stylesheetbody">
		<!--xsl:template name="stylesheetbody"-->
		<xsl:comment>Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. </xsl:comment><xsl:text>&#10;</xsl:text>
		
		<!-- These parameters may contain strings with the name and directory of the file being
   validated. For convenience, if the caller only has the information in a single string,
   that string could be put in fileDirParameter. The archives parameters are available
   for ZIP archives.
	-->
		
		<xsl:call-template name="iso:exslt.add.imports" /> <!-- RJ moved report BH -->
		<axsl:param name="archiveDirParameter" />
		<axsl:param name="archiveNameParameter" />
		<axsl:param name="fileNameParameter"  />
		<axsl:param name="fileDirParameter" /> 
		
		<!--
		Workaround for Saxon 10.6 having fatal error for / if context node is absent
		is to use root() instead.
    	-->		
		<axsl:variable name="document-uri"><axsl:value-of select="document-uri(root())" /></axsl:variable>

		<xsl:text>&#10;&#10;</xsl:text><xsl:comment>PHASES</xsl:comment><xsl:text>&#10;</xsl:text>
		<xsl:call-template name="handle-phase"/> 
		<xsl:text>&#10;&#10;</xsl:text><xsl:comment>PROLOG</xsl:comment><xsl:text>&#10;</xsl:text>
		<xsl:call-template name="process-prolog"/> 
		<xsl:text>&#10;&#10;</xsl:text><xsl:comment>XSD TYPES FOR XSLT2</xsl:comment><xsl:text>&#10;</xsl:text>
		<xsl:apply-templates mode="do-types"   select="xsl:import-schema"/>
		<xsl:text>&#10;&#10;</xsl:text><xsl:comment>KEYS AND FUNCTIONS</xsl:comment><xsl:text>&#10;</xsl:text>
		<xsl:apply-templates mode="do-keys"   select="xsl:key | xsl:function "/>
		<xsl:text>&#10;&#10;</xsl:text><xsl:comment>DEFAULT RULES</xsl:comment><xsl:text>&#10;</xsl:text>
		<xsl:call-template name="generate-default-rules" />
		<xsl:text>&#10;&#10;</xsl:text><xsl:comment>SCHEMA SETUP</xsl:comment><xsl:text>&#10;</xsl:text>
		<xsl:call-template name="handle-root"/>
		<xsl:text>&#10;&#10;</xsl:text><xsl:comment>SCHEMATRON PATTERNS</xsl:comment><xsl:text>&#10;</xsl:text>
		
		<xsl:apply-templates select="*[not(self::iso:ns)] " />
		
		<!--
		Workaround for schematron-select-full-path not working with text nodes
    	-->
		<xsl:if test="$x:enable-schematron-text-location">
			<axsl:template match="text()" mode="schematron-select-full-path">
				<xsl:comment expand-text="yes">This template was injected by {static-base-uri()}</xsl:comment>
				<axsl:apply-templates mode="#current" select="parent::element()" />
				<axsl:text>/text()[</axsl:text>
				<axsl:value-of select="count(preceding-sibling::text()) + 1" />
				<axsl:text>]</axsl:text>
			</axsl:template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
