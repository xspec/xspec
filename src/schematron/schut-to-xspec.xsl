<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:x="http://www.jenitennison.com/xslt/xspec" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">
    
    <xsl:param name="stylesheet-uri" select="concat(x:description/@schematron, '.xsl')"/>

    <xsl:include href="../common/xspec-utils.xsl"/>

    <xsl:variable name="error" select="('error', 'fatal')"/>
    <xsl:variable name="warn" select="('warn', 'warning')"/>
    <xsl:variable name="info" select="('info', 'information')"/>

    <xsl:template match="@* | node() | document-node()" as="node()" priority="-2">
        <xsl:call-template name="x:identity" />
    </xsl:template>
    
    <xsl:template match="x:description[@schematron]">
        <xsl:element name="x:description">
            <!-- Place xsl:namespace before x:copy-namespaces(), otherwise Saxon 9.6 complains,
                "Warning... Creating a namespace node here will fail if previous instructions create
                any children" -->
            <xsl:namespace name="svrl" select="'http://purl.oclc.org/dsdl/svrl'"/>

            <!-- child::x:param may use namespaces -->
            <xsl:sequence select="x:copy-namespaces(.)" />

            <xsl:apply-templates select="@*[not(name() = ('stylesheet'))]"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="x:description/@schematron">
        <xsl:attribute name="xspec-original-location" select="x:resolve-xml-uri-with-catalog(document-uri(/))"/>
        <xsl:attribute name="stylesheet" select="$stylesheet-uri"/>
        <xsl:variable name="path" select="resolve-uri(string(), base-uri())"/>
        <xsl:attribute name="schematron" select="$path"/>
        <xsl:for-each select="doc($path)/sch:schema/sch:ns" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
            <xsl:namespace name="{./@prefix}" select="./@uri"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="x:import">
        <xsl:variable name="href" select="resolve-uri(@href, base-uri())"/>
        <xsl:choose>
            <xsl:when test="doc($href)//*[ 
                self::x:expect-assert | self::x:expect-not-assert | 
                self::x:expect-report | self::x:expect-not-report |
                self::x:expect-valid | self::x:description[@schematron] ]">
                <xsl:comment>BEGIN IMPORT "<xsl:value-of select="@href"/>"</xsl:comment>
                <xsl:apply-templates select="doc($href)/x:description/node()">
                    <xsl:with-param name="imported-uri" tunnel="yes"
                        select="x:resolve-xml-uri-with-catalog($href)" />
                </xsl:apply-templates>
                <xsl:comment>END IMPORT "<xsl:value-of select="@href"/>"</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="x:scenario">
        <xsl:param name="imported-uri" as="xs:anyURI?" tunnel="yes" />

        <xsl:copy>
            <xsl:if test="exists($imported-uri)">
                <xsl:attribute name="xspec-original-location" select="$imported-uri" />
            </xsl:if>
            <xsl:apply-templates select="attribute() | node()" />
        </xsl:copy>
    </xsl:template>

    <!-- Schematron skeleton implementation requires a document node -->
    <xsl:template match="x:context[not(@href)][
        parent::*/x:expect-assert | parent::*/x:expect-not-assert |
        parent::*/x:expect-report | parent::*/x:expect-not-report |
        parent::*/x:expect-valid | ancestor::x:description[@schematron] ]"
        as="element(x:context)">
        <xsl:copy>
            <xsl:apply-templates select="attribute()" />
            <xsl:attribute name="select">
                <xsl:choose>
                    <xsl:when test="@select">
                        <xsl:text>if (test:wrappable-sequence((</xsl:text>
                        <xsl:value-of select="@select" />
                        <xsl:text>))) then test:wrap-nodes((</xsl:text>
                        <xsl:value-of select="@select" />
                        <xsl:text>)) else </xsl:text>

                        <!-- Some Schematron implementations might possibly be able to handle
                            non-document nodes. Just generate a warning and pass @select as is. -->
                        <xsl:text>trace((</xsl:text>
                        <xsl:value-of select="@select" />
                        <xsl:text>), 'WARNING: Failed to wrap </xsl:text>
                        <xsl:value-of select="name()" />
                        <xsl:text>/@select')</xsl:text>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:text>self::document-node()</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>

            <xsl:apply-templates select="node()" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="x:expect-assert">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="if (@count) then 'count' else 'exists'"/>
                <xsl:sequence select="'(svrl:schematron-output/svrl:failed-assert'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
                <xsl:sequence select="current()[@count]/concat(' eq ', @count)"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="x:expect-not-assert">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="'boolean(svrl:schematron-output[svrl:fired-rule]) and empty(svrl:schematron-output/svrl:failed-assert'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="x:expect-report">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="if (@count) then 'count' else 'exists'"/>
                <xsl:sequence select="'(svrl:schematron-output/svrl:successful-report'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
                <xsl:sequence select="current()[@count]/concat(' eq ', @count)"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>


    <xsl:template match="x:expect-not-report">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="'boolean(svrl:schematron-output[svrl:fired-rule]) and empty(svrl:schematron-output/svrl:successful-report'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@location" mode="make-predicate">
        <xsl:variable name="escaped" select="if (not(contains(., codepoints-to-string(39)))) then 
            concat(codepoints-to-string(39), ., codepoints-to-string(39)) else 
            concat('concat(', codepoints-to-string(39), replace(., codepoints-to-string(39), concat(codepoints-to-string(39), ', codepoints-to-string(39), ', codepoints-to-string(39))), codepoints-to-string(39), ')')"/>
        <xsl:sequence select="concat('[x:schematron-location-compare(', $escaped, ', @location, preceding-sibling::svrl:ns-prefix-in-attribute-values)]')"/>
    </xsl:template>

    <xsl:template match="@id | @role" mode="make-predicate">
        <xsl:sequence select="concat('[(@', local-name(.), 
            ', preceding-sibling::svrl:fired-rule[1]/@',local-name(.), 
            ', preceding-sibling::svrl:active-pattern[1]/@',local-name(.), 
            ')[1] = ', codepoints-to-string(39), ., codepoints-to-string(39), ']')"/>
    </xsl:template>
    
    <xsl:template match="@id[parent::x:expect-rule] | @context[parent::x:expect-rule]" mode="make-predicate">
        <xsl:sequence select="concat('[@', local-name(.), 
            ' = ', codepoints-to-string(39), ., codepoints-to-string(39), ']')"/>
    </xsl:template>
    
    <xsl:template match="@count | @label" mode="make-predicate"/>
    
    <xsl:template name="make-label">
        <xsl:context-item as="element()" use="required"
            use-when="element-available('xsl:context-item')" />

        <xsl:attribute name="label" select="string-join((@label, tokenize(local-name(),'-')[.=('report','assert','not','rule')], @id, @role, @location, @context, current()[@count]/string('count:'), @count), ' ')"/>
    </xsl:template>

    <xsl:template match="x:expect-valid">
        <xsl:element name="x:expect">
            <xsl:attribute name="label" select="'valid'"/>
            <xsl:attribute name="test" select="concat(
                'boolean(svrl:schematron-output[svrl:fired-rule]) and
                not(boolean((svrl:schematron-output/svrl:failed-assert union svrl:schematron-output/svrl:successful-report)[
                not(@role) or lower-case(@role) = (',
                string-join(for $e in $error return concat(codepoints-to-string(39), $e, codepoints-to-string(39)), ','),
                ')]))'
                )"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="x:expect-rule">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="if (@count) then 'count' else 'exists'"/>
                <xsl:sequence select="'(svrl:schematron-output/svrl:fired-rule'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
                <xsl:sequence select="current()[@count]/concat(' eq ', @count)"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="x:*/@href" as="attribute(href)">
        <xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
            select="resolve-uri(., x:base-uri(.))" />
    </xsl:template>
    
</xsl:stylesheet>
