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

        | XSLT:output-character

        | text()[normalize-space() = '' and not(parent::XSLT:text)]
        | processing-instruction()
        | comment()
        | document-node()"
        mode="coverage"
        as="xs:string"
        priority="30">
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
        XSLT:fallback
        | XSLT:matching-substring
        | XSLT:non-matching-substring
        | XSLT:on-completion
        | XSLT:otherwise
        | XSLT:when
        | XSLT:where-populated"
        as="xs:string"
        mode="coverage">
        <xsl:choose>
            <xsl:when test="empty(child::node())">
                <xsl:sequence select="'unknown'"/>
            </xsl:when>
            <xsl:when test="descendant::node()/accumulator-before('category-based-on-trace-data') = 'hit'">
                <!-- If at least one descendant is hit, mark as hit -->
                <xsl:sequence select="'hit'"/>
            </xsl:when>
            <xsl:otherwise>
                <!--
                    If node has only untraceable descendants, mark it as 'unknown'.
                    Use xsl:iterate to examine descendants for traceability. Break
                    upon reaching a traceable element, because reaching xsl:otherwise
                    with a traceable descendant means this node should be marked as
                    'missed'.
                -->
                <xsl:variable name="all-untraceable" as="xs:boolean">
                    <xsl:iterate select="descendant::node()">
                        <xsl:on-completion>
                            <xsl:sequence select="true()" />
                        </xsl:on-completion>
                        <xsl:variable name="untraceable" as="xs:boolean">
                            <xsl:apply-templates select="." mode="untraceable-in-instruction" />
                        </xsl:variable> 
                        <xsl:if test="not($untraceable)">
                            <xsl:sequence select="false()" />
                            <xsl:break />
                        </xsl:if>
                    </xsl:iterate>
                </xsl:variable>
                <xsl:sequence select="if ($all-untraceable) then 'unknown' else 'missed'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Use Parent Data -->
    <xsl:template match="
        XSLT:context-item (: xspec/xspec#1410 :)
        | XSLT:merge-action
        | XSLT:merge-source
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

    <!-- Element-Specific rule for XSLT:merge-key -->
    <xsl:template match="XSLT:merge-key"
        as="xs:string"
        mode="coverage">
        <xsl:apply-templates select="ancestor::XSLT:merge[1]"
            mode="#current"/>        
    </xsl:template>

    <!-- Element-Specific rule for descendants of XSLT:merge-key -->
    <xsl:template match="XSLT:merge-key/descendant::node()"
        as="xs:string"
        mode="coverage"
        priority="5">
        <xsl:variable name="xsl-merge-status" as="xs:string">
            <xsl:apply-templates select="ancestor::XSLT:merge[1]"
                mode="#current"/>
        </xsl:variable>
        <xsl:sequence select="
                if ($xsl-merge-status eq 'hit') then
                    'unknown'
                else
                    'missed'
                "/>
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

    <!--
      mode="untraceable-in-instruction"
   -->
    <xsl:mode name="untraceable-in-instruction" on-multiple-match="fail" on-no-match="fail" />

    <!-- Low-priority fallback template rule -->
    <xsl:template match="node()" mode="untraceable-in-instruction"
        priority="-10">
        <xsl:sequence select="false()"/>
    </xsl:template>

    <!-- Nodes that follow "Always Ignore" rule and can occur in an instruction -->
    <xsl:template match="
        text()[normalize-space() = '' and not(parent::XSLT:text)]
        | processing-instruction()
        | comment()"
        mode="untraceable-in-instruction">
        <xsl:sequence select="true()"/>
    </xsl:template>

    <!-- Untraceable elements that can occur in an instruction -->
    <xsl:template match="
        XSLT:assert
        | XSLT:catch
        | XSLT:evaluate (: Not sure if this should be listed here :)
        | XSLT:fallback
        | XSLT:iterate/XSLT:param
        | XSLT:map
        | XSLT:map-entry
        | XSLT:matching-substring
        | XSLT:merge-action
        | XSLT:merge-key
        | XSLT:merge-source
        | XSLT:non-matching-substring
        | XSLT:on-completion
        | XSLT:on-empty
        | XSLT:on-non-empty
        | XSLT:otherwise
        | XSLT:perform-sort[@select]
        | XSLT:perform-sort[XSLT:sort][count(*) = 1]
        | XSLT:sequence[empty(node())]
        | XSLT:sort
        | XSLT:template/XSLT:param[@select]
        | XSLT:try
        | XSLT:where-populated
        | XSLT:with-param"
        mode="untraceable-in-instruction">
        <!--
            Some of the elements listed in the match attribute are not strictly needed
            in order to achieve the caller's objective, because the elements have a
            traceable ancestor that would also be a descendant of the element that calls
            this mode. Examples include XSLT:matching-substring, XSLT:non-matching-substring,
            XSLT:merge-*, and XSLT:on-completion. However, it's clearer to list them anyway.
        -->
        <xsl:sequence select="true()"/>
    </xsl:template>
    
</xsl:stylesheet>