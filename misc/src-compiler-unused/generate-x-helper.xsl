<?xml version="1.0" encoding="UTF-8"?>
<!--
   These objects were both in generate-query-helper.xsl and generate-tests-helper.xsl
-->
<xsl:stylesheet version="3.0"
                xmlns:test="http://www.jenitennison.com/xslt/unit-test"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

   <xsl:include href="../../src/common/xspec-utils.xsl" />

   <xsl:key name="functions" 
            match="xsl:function" 
            use="x:resolve-EQName-ignoring-default-ns(@name, .)" />

   <xsl:key name="named-templates" 
            match="xsl:template[@name]"
            use="x:resolve-EQName-ignoring-default-ns(@name, .)" />

   <xsl:key name="matching-templates" 
            match="xsl:template[@match]" 
            use="'match=' || normalize-space(@match) ||
                 '+' ||
                 'mode=' || normalize-space(@mode)" />

   <xsl:function name="test:matching-xslt-elements" as="element()*">
      <xsl:param name="element-kind" as="xs:string" />
      <xsl:param name="element-id" as="item()" />
      <xsl:param name="stylesheet" as="document-node()" />

      <xsl:sequence select="key($element-kind, $element-id, $stylesheet)" />
   </xsl:function>

</xsl:stylesheet>
