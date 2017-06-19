<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:x="http://www.jenitennison.com/xslt/xspec" version="2.0">

    <!-- function x:schematron-location-compare
      
      This function is used in Schematron tests to compare 
      an expected @location XPath in a test scenario with
      a SVRL @location XPath in Schematron output.
      
      If the Schematron uses XPath 1.0 the SVRL location XPath has all namespaced
      elements use a wildcard namespace, so only the element name can be matched. 
      If XPath 1.0 is detected then namespace prefixes are removed from the comparison.
      
      Parameters:
      
      expect-location : @location from x:expect-assert or x:expect-report
      
      svrl-location : @location from svrl:failed-assert or svrl:successful-report
      
      namespaces : elements that contain namespace definitions in attributes @uri and @prefix
        <svrl:ns-prefix-in-attribute-values uri="http://example.com/ns1" prefix="ex1"/>
        <sch:ns uri="http://example.com/ns1" prefix="ex1"/>
    -->
    <xsl:function name="x:schematron-location-compare" as="xs:boolean">
        <xsl:param name="expect-location" as="xs:string?"/>
        <xsl:param name="svrl-location" as="xs:string?"/>
        <xsl:param name="namespaces" as="element()*"/>
        <xsl:variable name="svrl-expand1"
            select="
                x:schematron-location-expand-xpath1(
                x:schematron-location-expand-attributes($svrl-location, $namespaces))"/>
        <xsl:variable name="svrl-expand2" select="x:schematron-location-expand-xpath2($svrl-expand1, $namespaces)"/>
        <xsl:variable name="expect-expand"
            select="
                x:schematron-location-expand-xpath1-expect(
                x:schematron-location-expand-attributes($expect-location, $namespaces), $svrl-location, $namespaces)"/>
        <!--xsl:variable name="expect-parts" select="tokenize($expect-expand, '/')[.]"/>
        <xsl:variable name="svrl-parts" select="tokenize($svrl-expand2, '/')[.]"/-->
        <xsl:sequence select="
                ($expect-location = $svrl-location) or
                (replace($svrl-expand2, '^/|\[1\]', '') = replace($expect-expand, '^/|\[1\]', ''))
                "/>
        <!-- (: every $i in (1 to max((count($svrl-parts),count($expect-parts)))) satisfies
        replace($expect-parts[$i], '\[1\]$', '') = replace($svrl-parts[$i], '\[1\]$', '') :) -->
    </xsl:function>

    <!-- function x:schematron-location-expand-xpath2
  
      This function is used in Schematron tests to reformat XPath location attribute values
      from the format Schematron produces for XPath 2.0 to human friendly XPath
      using namespace prefixes defined in Schematron ns elements.
      
      The XPath 2.0 format produced by Schematron is:
      *:name[namespace-uri()='http://example.com/ns1']
    -->
    <xsl:function name="x:schematron-location-expand-xpath2" as="xs:string">
        <xsl:param name="location" as="xs:string?"/>
        <xsl:param name="namespaces" as="element()*"/>
        <xsl:choose>
            <xsl:when test="$namespaces">
                <xsl:variable name="match"
                    select="concat('\*:([^\[]+)\[namespace\-uri\(\)=', codepoints-to-string(39), replace($namespaces[1]/@uri, '([\.\\\?\*\+\|\^\$\{\}\(\)\[\]])', '\\$1'), codepoints-to-string(39), '\]')"/>
                <xsl:variable name="replace" select="concat($namespaces[1]/@prefix, ':$1')"/>
                <xsl:value-of
                    select="x:schematron-location-expand-xpath2(replace($location, $match, $replace), subsequence($namespaces, 2))"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$location"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- function x:schematron-location-expand-xpath1
  
      This function is used in Schematron tests to reformat XPath location attribute values
      from the format Schematron produces for XPath 1.0 to human friendly XPath.
      Namespace URIs are not available so effectively the XPath does not recognize namespaces.
      
      The XPath 1.0 format produced by Schematron is:
      *[local-name()='name']
  -->
    <xsl:function name="x:schematron-location-expand-xpath1" as="xs:string">
        <xsl:param name="location" as="xs:string?"/>
        <xsl:variable name="match"
            select="concat('\*\[local-name\(\)=', codepoints-to-string(39), '([^', codepoints-to-string(39), ']+)', codepoints-to-string(39), '\]')"/>
        <xsl:value-of select="replace($location, $match, '$1')"/>
    </xsl:function>

    <!-- function schematron-location-expand-xpath1-expect
    
    
  -->
    <xsl:function name="x:schematron-location-expand-xpath1-expect" as="xs:string">
        <xsl:param name="expect-location" as="xs:string?"/>
        <xsl:param name="svrl-location" as="xs:string?"/>
        <xsl:param name="namespaces" as="element()*"/>
        <xsl:value-of
            select="
                if ($namespaces and contains($svrl-location, '*[local-name()=')) then
                    replace($expect-location, concat('(', string-join(for $prefix in $namespaces/@prefix
                    return
                        concat($prefix, ':'), '|'), ')'), '')
                else
                    $expect-location"
        />
    </xsl:function>

    <!-- function schematron-location-expand-attributes
    
    This function reformats namespaced attribute nodes in XPath to use the 
    namespace prefix defined in the Schematron.
    
    The XPath format produced by Schematron for XPath 1 and 2, which is also 
    produced by oXygen's Copy XPath function, is:
    
    @*[namespace-uri()='http://example.com/ns2' and local-name()='type']
    -->
    <xsl:function name="x:schematron-location-expand-attributes" as="xs:string">
        <xsl:param name="location" as="xs:string?"/>
        <xsl:param name="namespaces" as="element()*"/>
        <xsl:choose>
            <xsl:when test="$namespaces">
                <xsl:variable name="match"
                    select="concat('@\*\[namespace-uri\(\)=', codepoints-to-string(39), replace($namespaces[1]/@uri, '([\.\\\?\*\+\|\^\$\{\}\(\)\[\]])', '\\$1'), codepoints-to-string(39), ' and local-name\(\)=', codepoints-to-string(39), '([^', codepoints-to-string(39), ']+)', codepoints-to-string(39), '\]')"/>
                <xsl:variable name="replace" select="concat('@', $namespaces[1]/@prefix, ':$1')"/>
                <xsl:value-of
                    select="x:schematron-location-expand-attributes(replace($location, $match, $replace), subsequence($namespaces, 2))"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$location"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


</xsl:stylesheet>
