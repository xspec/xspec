<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:x="http://www.jenitennison.com/xslt/xspec"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

    <xsl:include href="../common/xspec-utils.xsl" />

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

        <xsl:variable name="expect-expanded" as="xs:string"
            select="
                $expect-location
                => x:schematron-location-expand-attributes($namespaces)
                => x:schematron-location-expand-xpath1-expect($svrl-location, $namespaces)" />
        <xsl:variable name="svrl-expanded" as="xs:string"
            select="
                $svrl-location
                => x:schematron-location-expand-attributes($namespaces)
                => x:schematron-location-expand-xpath1()
                => x:schematron-location-expand-xpath2($namespaces)" />

        <xsl:variable name="trim-match" as="xs:string" select="'^/|\[1\]'" />
        <xsl:sequence
            select="
                ($expect-location = $svrl-location)
                or (replace($expect-expanded, $trim-match, '')
                    eq replace($svrl-expanded, $trim-match, ''))" />

        <!--
        <xsl:variable name="expect-parts" as="xs:string+"
            select="tokenize($expect-expanded, '/')[.]" />
        <xsl:variable name="svrl-parts" as="xs:string+"
            select="tokenize($svrl-expanded, '/')[.]" />
        <xsl:variable name="trim-match" as="xs:string" select="'\[1\]$'" />
        <xsl:sequence
            select="
                every $i
                in (1 to max((count($svrl-parts), count($expect-parts))))
                satisfies
                    (replace($expect-parts[$i], $trim-match, '')
                     eq replace($svrl-parts[$i], $trim-match, ''))" />
        -->
    </xsl:function>

    <!-- function x:schematron-location-expand-xpath2
  
      This function is used in Schematron tests to reformat XPath location attribute values
      from the format Schematron produces for XPath 2.0 to human friendly XPath
      using namespace prefixes defined in Schematron ns elements.
      
      The XPath 2.0 format produced by Schematron is:
      *:NCName[namespace-uri()='http://example.com/ns1']
    -->
    <xsl:function name="x:schematron-location-expand-xpath2" as="xs:string">
        <xsl:param name="location" as="xs:string?"/>
        <xsl:param name="namespaces" as="element()*"/>

        <xsl:choose>
            <xsl:when test="exists($namespaces)">
                <xsl:iterate select="$namespaces">
                    <xsl:param name="location" as="xs:string?" select="$location" />

                    <xsl:on-completion>
                        <xsl:sequence select="$location" />
                    </xsl:on-completion>

                    <xsl:variable name="match" as="xs:string">
                        <xsl:text expand-text="yes">\*:{$x:capture-NCName}\[namespace-uri\(\)='{x:escape-for-match(@uri)}'\]</xsl:text>
                    </xsl:variable>
                    <xsl:variable name="replacement" as="xs:string" select="@prefix || ':$1'" />

                    <xsl:next-iteration>
                        <xsl:with-param name="location"
                            select="replace($location, $match, $replacement)" />
                    </xsl:next-iteration>
                </xsl:iterate>
            </xsl:when>

            <xsl:otherwise>
                <xsl:sequence select="string($location)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- function x:schematron-location-expand-xpath1
  
      This function is used in Schematron tests to reformat XPath location attribute values
      from the format Schematron produces for XPath 1.0 to human friendly XPath.
      Namespace URIs are not available so effectively the XPath does not recognize namespaces.
      
      The XPath 1.0 format produced by Schematron is:
      *[local-name()='NCName']
    -->
    <xsl:function name="x:schematron-location-expand-xpath1" as="xs:string">
        <xsl:param name="location" as="xs:string?"/>

        <xsl:variable name="match" as="xs:string">
            <xsl:text expand-text="yes">\*\[local-name\(\)='{$x:capture-NCName}'\]</xsl:text>
        </xsl:variable>
        <xsl:sequence select="replace($location, $match, '$1')" />
    </xsl:function>

    <!-- function schematron-location-expand-xpath1-expect
    
    
    -->
    <xsl:function name="x:schematron-location-expand-xpath1-expect" as="xs:string">
        <xsl:param name="expect-location" as="xs:string?"/>
        <xsl:param name="svrl-location" as="xs:string?"/>
        <xsl:param name="namespaces" as="element()*"/>

        <xsl:choose>
            <xsl:when test="$namespaces and contains($svrl-location, '*[local-name()=')">
                <xsl:variable name="match" as="xs:string"
                    select="($namespaces/@prefix ! (. || ':')) => string-join('|')" />
                <xsl:sequence select="replace($expect-location, $match, '')" />
            </xsl:when>

            <xsl:otherwise>
                <xsl:sequence select="string($expect-location)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- function schematron-location-expand-attributes
    
    This function reformats namespaced attribute nodes in XPath to use the 
    namespace prefix defined in the Schematron.
    
    The XPath format produced by Schematron for XPath 1 and 2, which is also 
    produced by oXygen's Copy XPath function, is:
    
    @*[namespace-uri()='http://example.com/ns2' and local-name()='NCName']
    -->
    <xsl:function name="x:schematron-location-expand-attributes" as="xs:string">
        <xsl:param name="location" as="xs:string?"/>
        <xsl:param name="namespaces" as="element()*"/>

        <xsl:choose>
            <xsl:when test="exists($namespaces)">
                <xsl:iterate select="$namespaces">
                    <xsl:param name="location" as="xs:string?" select="$location" />

                    <xsl:on-completion>
                        <xsl:sequence select="$location" />
                    </xsl:on-completion>

                    <xsl:variable name="match" as="xs:string">
                        <xsl:text expand-text="yes">@\*\[namespace-uri\(\)='{x:escape-for-match(@uri)}' and local-name\(\)='{$x:capture-NCName}'\]</xsl:text>
                    </xsl:variable>
                    <xsl:variable name="replacement" as="xs:string" select="'@' || @prefix || ':$1'" />

                    <xsl:next-iteration>
                        <xsl:with-param name="location"
                            select="replace($location, $match, $replacement)" />
                    </xsl:next-iteration>
                </xsl:iterate>
            </xsl:when>

            <xsl:otherwise>
                <xsl:sequence select="string($location)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="x:escape-for-match" as="xs:string">
        <xsl:param name="input" as="xs:string" />

        <xsl:sequence select="replace($input, '([\.\\\?\*\+\|\^\$\{\}\(\)\[\]])', '\\$1')" />
    </xsl:function>

</xsl:stylesheet>
