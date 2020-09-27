<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">

   <!--
      Utils for compiling x:expect
   -->

   <!-- Returns true if x:expect has any comparison factor -->
   <xsl:function name="x:has-comparison" as="xs:boolean">
      <xsl:param name="expect" as="element(x:expect)" />

      <xsl:sequence select="$expect/(@href or @select or (node() except x:label))" />
   </xsl:function>

   <!-- Returns an error string for boolean @test with any comparison factor -->
   <xsl:function name="x:bad-boolean-test" as="xs:string">
      <xsl:param name="expect" as="element(x:expect)" />

      <xsl:text expand-text="yes">{name($expect)} has boolean @test, but it also has (@href | @select | child::node()).</xsl:text>
   </xsl:function>

   <!-- Returns an error string for non-boolean @test with no comparison factors -->
   <xsl:function name="x:bad-non-boolean-test" as="xs:string">
      <xsl:param name="expect" as="element(x:expect)" />

      <xsl:text expand-text="yes">{name($expect)} has non-boolean @test, but it lacks (@href | @select | child::node()).</xsl:text>
   </xsl:function>

</xsl:stylesheet>