<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:x="http://www.jenitennison.com/xslt/xspec" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

    <xsl:param name="stylesheet-uri" as="xs:string" select="x:description/@schematron || '.xsl'" />

    <xsl:include href="../common/xspec-utils.xsl"/>

    <xsl:variable name="errors" as="xs:string+" select="'error', 'fatal'" />
    <xsl:variable name="warns" as="xs:string+" select="'warn', 'warning'" />
    <xsl:variable name="infos" as="xs:string+" select="'info', 'information'" />

    <xsl:mode on-no-match="shallow-copy" />

    <xsl:template match="x:description[@schematron]" as="element(x:description)">
        <xsl:copy>
            <xsl:namespace name="svrl" select="'http://purl.oclc.org/dsdl/svrl'"/>

            <!-- child::x:param may use namespaces -->
            <xsl:sequence select="x:copy-namespaces(.)" />

            <xsl:apply-templates select="@*[not(name() = ('stylesheet'))]"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="x:description/@schematron" as="node()+">
        <xsl:variable name="resolved-schematron-uri" as="xs:anyURI"
            select="resolve-uri(., base-uri())" />

        <xsl:for-each select="doc($resolved-schematron-uri)/sch:schema/sch:ns">
            <xsl:namespace name="{@prefix}" select="@uri" />
        </xsl:for-each>

        <xsl:attribute name="xspec-original-location"
            select="
                document-uri(/)
                => x:resolve-xml-uri-with-catalog()" />
        <xsl:attribute name="stylesheet" select="$stylesheet-uri" />
        <xsl:attribute name="schematron" select="$resolved-schematron-uri" />
    </xsl:template>

    <xsl:template match="x:import" as="node()+">
        <xsl:variable name="fully-resolved-href" as="xs:anyURI"
            select="
                @href
                => resolve-uri(base-uri())
                => x:resolve-xml-uri-with-catalog()" />
        <xsl:variable name="imported-doc" as="document-node(element(x:description))"
            select="doc($fully-resolved-href)" />
        <xsl:variable name="is-schematron-xspec" as="xs:boolean"
            select="
                $imported-doc
                /(x:description[@schematron]
                  | descendant::x:expect-assert | descendant::x:expect-not-assert
                  | descendant::x:expect-report | descendant::x:expect-not-report
                  | descendant::x:expect-valid)
                => exists()" />

        <xsl:choose>
            <xsl:when test="$is-schematron-xspec">
                <xsl:comment>BEGIN IMPORT "<xsl:value-of select="@href"/>"</xsl:comment>
                <xsl:apply-templates select="$imported-doc/x:description/node()">
                    <xsl:with-param name="imported-uri" tunnel="yes" select="$fully-resolved-href" />
                </xsl:apply-templates>
                <xsl:comment>END IMPORT "<xsl:value-of select="@href"/>"</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="x:scenario" as="element(x:scenario)">
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

    <xsl:template match="x:expect-assert" as="element(x:expect)">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="if (@count) then 'count' else 'exists'"/>
                <xsl:sequence select="'(svrl:schematron-output/svrl:failed-assert'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
                <xsl:sequence select="current()[@count]/(' eq ' || @count)" />
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="x:expect-not-assert" as="element(x:expect)">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="'boolean(svrl:schematron-output[svrl:fired-rule]) and empty(svrl:schematron-output/svrl:failed-assert'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="x:expect-report" as="element(x:expect)">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="if (@count) then 'count' else 'exists'"/>
                <xsl:sequence select="'(svrl:schematron-output/svrl:successful-report'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
                <xsl:sequence select="current()[@count]/(' eq ' || @count)" />
            </xsl:attribute>
        </xsl:element>
    </xsl:template>


    <xsl:template match="x:expect-not-report" as="element(x:expect)">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="'boolean(svrl:schematron-output[svrl:fired-rule]) and empty(svrl:schematron-output/svrl:successful-report'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@location" as="xs:string" mode="make-predicate">
        <xsl:variable name="escaped" as="xs:string" select="if (not(contains(., codepoints-to-string(39)))) then 
            concat(codepoints-to-string(39), ., codepoints-to-string(39)) else 
            concat('concat(', codepoints-to-string(39), replace(., codepoints-to-string(39), concat(codepoints-to-string(39), ', codepoints-to-string(39), ', codepoints-to-string(39))), codepoints-to-string(39), ')')"/>
        <xsl:sequence select="concat('[x:schematron-location-compare(', $escaped, ', @location, preceding-sibling::svrl:ns-prefix-in-attribute-values)]')"/>
    </xsl:template>

    <xsl:template match="@id | @role" as="xs:string" mode="make-predicate">
        <xsl:sequence select="concat('[(@', local-name(.), 
            ', preceding-sibling::svrl:fired-rule[1]/@',local-name(.), 
            ', preceding-sibling::svrl:active-pattern[1]/@',local-name(.), 
            ')[1] = ', codepoints-to-string(39), ., codepoints-to-string(39), ']')"/>
    </xsl:template>

    <xsl:template match="@id[parent::x:expect-rule] | @context[parent::x:expect-rule]" as="xs:string"
        mode="make-predicate">
        <xsl:sequence select="concat('[@', local-name(.), 
            ' = ', codepoints-to-string(39), ., codepoints-to-string(39), ']')"/>
    </xsl:template>

    <xsl:template match="@count | @label" as="empty-sequence()" mode="make-predicate" />

    <xsl:template name="make-label" as="attribute(label)">
        <xsl:context-item as="element()" use="required" />

        <xsl:attribute name="label" select="string-join((@label, tokenize(local-name(),'-')[.=('report','assert','not','rule')], @id, @role, @location, @context, current()[@count]/string('count:'), @count), ' ')"/>
    </xsl:template>

    <xsl:template match="x:expect-valid" as="element(x:expect)">
        <xsl:element name="x:expect">
            <xsl:attribute name="label" select="'valid'"/>
            <xsl:attribute name="test" select="concat(
                'boolean(svrl:schematron-output[svrl:fired-rule]) and
                not(boolean((svrl:schematron-output/svrl:failed-assert union svrl:schematron-output/svrl:successful-report)[
                not(@role) or lower-case(@role) = (',
                string-join(for $e in $errors return concat(codepoints-to-string(39), $e, codepoints-to-string(39)), ','),
                ')]))'
                )"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="x:expect-rule" as="element(x:expect)">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="if (@count) then 'count' else 'exists'"/>
                <xsl:sequence select="'(svrl:schematron-output/svrl:fired-rule'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
                <xsl:sequence select="current()[@count]/(' eq ' || @count)" />
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="x:*/@href" as="attribute(href)">
        <xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
            select="resolve-uri(., x:base-uri(.))" />
    </xsl:template>

</xsl:stylesheet>
