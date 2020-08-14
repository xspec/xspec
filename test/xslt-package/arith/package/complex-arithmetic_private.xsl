<?xml version="1.0" encoding="UTF-8"?>
<!--
	Example: An example package
		https://www.w3.org/TR/xslt-30/#packages
	
	@visibility is set as a shadow attribute controlled by a static param ('private' by default).
-->
<xsl:package
  name="http://example.org/complex-arithmetic.xsl"
  package-version="1.0"
  version="3.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="http://example.org/complex-arithmetic.xsl">
  
  <xsl:param name="visibility" as="xs:string" select="'private'" static="yes" />
  
  <xsl:function name="f:complex-number" 
                as="map(xs:integer, xs:double)" _visibility="{$visibility}">
    <xsl:param name="real" as="xs:double"/>
    <xsl:param name="imaginary" as="xs:double"/>
    <xsl:sequence select="map{ 0:$real, 1:$imaginary }"/>
  </xsl:function>
  
  <!-- This function's @visibility is a fixed 'private' deliberately -->
  <xsl:function name="f:real" 
                as="xs:double" visibility="private">
    <xsl:param name="complex" as="map(xs:integer, xs:double)"/>
    <xsl:sequence select="$complex(0)"/>
  </xsl:function>
  
  <xsl:function name="f:imag" 
                as="xs:double" _visibility="{$visibility}">
    <xsl:param name="complex" as="map(xs:integer, xs:double)"/>
    <xsl:sequence select="$complex(1)"/>
  </xsl:function>
  
  <xsl:function name="f:add" 
                as="map(xs:integer, xs:double)" _visibility="{$visibility}">
    <xsl:param name="x" as="map(xs:integer, xs:double)"/>
    <xsl:param name="y" as="map(xs:integer, xs:double)"/>
    <xsl:sequence select="
         f:complex-number(
           f:real($x) + f:real($y), 
           f:imag($x) + f:imag($y))"/>
  </xsl:function>
  
  <xsl:function name="f:multiply" 
                as="map(xs:integer, xs:double)" _visibility="{$visibility}">
    <xsl:param name="x" as="map(xs:integer, xs:double)"/>
    <xsl:param name="y" as="map(xs:integer, xs:double)"/>
    <xsl:sequence select="
         f:complex-number(
           f:real($x)*f:real($y) - f:imag($x)*f:imag($y),
           f:real($x)*f:imag($y) + f:imag($x)*f:real($y))"/>
  </xsl:function>
  
  <!-- etc. -->
  
</xsl:package>