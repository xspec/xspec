<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:local="urn:x-xspec:reporter:coverage-report:local"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:XSLT="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="#all">

    <!-- This file uses the "XSLT" prefix for names of elements in the stylesheet
        whose coverage is being reported and the conventional "xsl" prefix for
        the code in this stylesheet. -->

    <!-- The category-based-on-trace-data accumulator is raw information about whether a node
        is in the trace. Other logic builds upon this information. -->
    <xsl:accumulator name="category-based-on-trace-data" as="xs:string*" initial-value="()">
        <xsl:accumulator-rule match="element() | text()">
            <xsl:variable name="hits-on-node"
                select="local:hits-on-node(.)"/>
            <xsl:choose>
                <xsl:when test="exists($hits-on-node)">
                    <xsl:sequence select="'hit'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="'missed'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:accumulator-rule>
    </xsl:accumulator>

    <!-- The module-id-for-node accumulator computes the module ID for a stylesheet.
        The computation occurs only on the outermost element of a stylesheet module.
        The value can be retrieved for any node of the module because accumulators
        hold their values until they match a different accumulator rule. -->
    <xsl:accumulator name="module-id-for-node" as="xs:integer?" initial-value="()">
        <xsl:accumulator-rule match="XSLT:stylesheet | XSLT:transform">
            <xsl:variable name="stylesheet-uri" as="xs:anyURI"
                select="base-uri(.)" />
            <xsl:variable name="uri" as="xs:string"
                select="if (starts-with($stylesheet-uri, '/'))
                then ('file:' || $stylesheet-uri)
                else $stylesheet-uri" />
            <xsl:sequence select="key('modules', $uri, $trace)/@moduleId" />            
        </xsl:accumulator-rule>
    </xsl:accumulator>

    <!--
      mode="coverage"
   -->
    <xsl:mode name="coverage" on-multiple-match="fail" on-no-match="fail" />

    <!-- Always Ignore -->
    <!-- TODO: Design document suggests maybe switching to Always Hit rule for XSLT:stylesheet and XSLT:transform -->
    <xsl:template match="
        XSLT:stylesheet
        | XSLT:transform
        | XSLT:accumulator
        | XSLT:attribute-set
        | XSLT:character-map
        | XSLT:decimal-format
        | XSLT:global-context-item
        | XSLT:import
        | XSLT:import-schema
        | XSLT:include
        | XSLT:key
        | XSLT:mode
        | XSLT:namespace-alias
        | XSLT:output
        | XSLT:preserve-space
        | XSLT:strip-space
        | text()[normalize-space() = '' and not(parent::XSLT:text)]
        | processing-instruction()
        | comment()
        | document-node()"
        mode="coverage"
        as="xs:string">
        <xsl:sequence select="'ignored'"/>
    </xsl:template>

    <!-- A node within a top-level non-XSLT element -->
    <!-- In case a descendant is an XSLT element, priority makes us match this
      template instead of one that handles ordinary XSLT instructions outside
      top-level non-XSLT elements. -->
    <xsl:template match="
        XSLT:stylesheet/*[not(namespace-uri() = 'http://www.w3.org/1999/XSL/Transform')]/descendant-or-self::node()
        | XSLT:transform/*[not(namespace-uri() = 'http://www.w3.org/1999/XSL/Transform')]/descendant-or-self::node()"
        as="xs:string"
        mode="coverage"
        priority="10">
        <xsl:sequence select="'ignored'"/>
    </xsl:template>

    <!-- Ignore Element and All Descendants -->
    <xsl:template match="
        XSLT:attribute-set/XSLT:attribute/descendant-or-self::node()
        | XSLT:accumulator-rule/descendant-or-self::node()"
        as="xs:string"
        mode="coverage"
        priority="20">
        <xsl:sequence select="'ignored'"/>
    </xsl:template>

    <!-- Use Child Data -->
    <xsl:template
        match="
        XSLT:matching-substring
        | XSLT:non-matching-substring
        | XSLT:otherwise
        | XSLT:when"
        as="xs:string"
        mode="coverage">
        <xsl:choose>
            <xsl:when test="child::node()/accumulator-before('category-based-on-trace-data') = 'hit'">
                <xsl:sequence select="'hit'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="'missed'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Use Parent Data -->
    <xsl:template match="
        XSLT:context-item (: xspec/xspec#1410 :)
        | XSLT:param[not(parent::XSLT:stylesheet or parent::XSLT:transform)]"
        as="xs:string"
        mode="coverage">
        <xsl:sequence select="parent::*/accumulator-before('category-based-on-trace-data')"/>
    </xsl:template>

    <!-- Use Trace Data -->
    <xsl:template match="
        XSLT:function
        | XSLT:template"
        as="xs:string"
        mode="coverage">
        <xsl:sequence select="accumulator-before('category-based-on-trace-data')"/>
    </xsl:template>

    <!-- Element-Specific rule for XSLT:variable -->
    <xsl:template match="XSLT:variable"
        as="xs:string"
        mode="coverage">
        <xsl:choose>
            <xsl:when test="accumulator-before('category-based-on-trace-data') eq 'hit'">
                <xsl:sequence select="'hit'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="following-sibling::*[not(self::XSLT:variable)][1]"
                    mode="#current"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- General case. This template is like the one for the Use Trace Data rule, except
        that xsl:when blocks after the first one provide the capability of doing
        special handling. Eventually, maybe we should (a) move all the special handling
        to other templates, (b) make the Use Trace Data template have match="element | text()",
        and (c) delete this template. -->
    <xsl:template match="element() | text()" as="xs:string" mode="coverage">
        
        <xsl:choose>
            <xsl:when test="accumulator-before('category-based-on-trace-data') eq 'hit'">
                <xsl:sequence select="'hit'"/>
            </xsl:when>

            <xsl:when test="ancestor::XSLT:variable">
                <!-- Use status of nearest ancestor XSLT:variable (not always the same
                    as Use Trace Data for that ancestor) -->
                <xsl:apply-templates select="ancestor::XSLT:variable[1]" mode="#current"/>
            </xsl:when>

            <xsl:otherwise>
                <xsl:sequence select="'missed'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>