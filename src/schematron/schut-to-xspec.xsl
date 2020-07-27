<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
                xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                xmlns:x="http://www.jenitennison.com/xslt/xspec" 
                xmlns:xs="http://www.w3.org/2001/XMLSchema" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">

    <!--
        $stylesheet-doc is for ../../bin/xspec.* who can pass a document node as a stylesheet
        parameter but can not handle URI natively.
        Those who can pass a URI as a stylesheet parameter natively will probably prefer
        $stylesheet-uri.
    -->
    <xsl:param name="stylesheet-doc" as="document-node()?" />

    <xsl:param name="stylesheet-uri" as="xs:string" select="document-uri($stylesheet-doc)" />

    <xsl:include href="../common/xspec-utils.xsl"/>

    <xsl:variable name="errors" as="xs:string+" select="'error', 'fatal'" />
    <xsl:variable name="warns" as="xs:string+" select="'warn', 'warning'" />
    <xsl:variable name="infos" as="xs:string+" select="'info', 'information'" />

    <!--
        mode="#default"
    -->
    <xsl:mode on-multiple-match="fail" on-no-match="shallow-copy" />

    <xsl:template match="x:description[@schematron]" as="element(x:description)">
        <!-- Do not set xsl:copy/@copy-namespaces="no". child::x:param may use namespace prefixes
            and/or the default namespace such as xs:QName('foo'). -->
        <xsl:copy>
            <xsl:apply-templates select="attribute() except @stylesheet" />
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="x:description/@schematron" as="node()+">
        <xsl:variable name="resolved-schematron-uri" as="xs:anyURI"
            select="resolve-uri(., base-uri())" />

        <xsl:for-each select="doc($resolved-schematron-uri)/sch:schema/sch:ns">
            <xsl:namespace name="{@prefix}" select="@uri" />
        </xsl:for-each>

        <xsl:attribute name="xspec-original-location" select="x:actual-document-uri(/)" />
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
                <xsl:comment expand-text="yes">BEGIN IMPORT "{@href}"</xsl:comment>
                <xsl:apply-templates select="$imported-doc/x:description/node()">
                    <xsl:with-param name="imported-uri" tunnel="yes" select="$fully-resolved-href" />
                </xsl:apply-templates>
                <xsl:comment expand-text="yes">END IMPORT "{@href}"</xsl:comment>
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
                        <xsl:text expand-text="yes">if (({@select}) => {x:known-UQName('test:wrappable-sequence')}())</xsl:text>
                        <xsl:text expand-text="yes"> then {x:known-UQName('test:wrap-nodes')}(({@select}))</xsl:text>

                        <!-- Some Schematron implementations might possibly be able to handle
                            non-document nodes. Just generate a warning and pass @select as is. -->
                        <xsl:text expand-text="yes"> else trace(({@select}), 'WARNING: Failed to wrap {name()}/@select')</xsl:text>
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
        <xsl:element name="x:expect" namespace="{$x:xspec-namespace}">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:value-of select="if (@count) then 'count' else 'exists'" />
                <xsl:text expand-text="yes">({x:known-UQName('svrl:schematron-output')}/{x:known-UQName('svrl:failed-assert')}</xsl:text>
                <xsl:apply-templates select="@*" mode="make-predicate" />
                <xsl:text>)</xsl:text>
                <xsl:value-of select="@count ! (' eq ' || .)" />
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="x:expect-not-assert" as="element(x:expect)">
        <xsl:element name="x:expect" namespace="{$x:xspec-namespace}">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:text expand-text="yes">{x:known-UQName('svrl:schematron-output')}[{x:known-UQName('svrl:fired-rule')}] and empty({x:known-UQName('svrl:schematron-output')}/{x:known-UQName('svrl:failed-assert')}</xsl:text>
                <xsl:apply-templates select="@*" mode="make-predicate" />
                <xsl:text>)</xsl:text>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="x:expect-report" as="element(x:expect)">
        <xsl:element name="x:expect" namespace="{$x:xspec-namespace}">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:value-of select="if (@count) then 'count' else 'exists'" />
                <xsl:text expand-text="yes">({x:known-UQName('svrl:schematron-output')}/{x:known-UQName('svrl:successful-report')}</xsl:text>
                <xsl:apply-templates select="@*" mode="make-predicate" />
                <xsl:text>)</xsl:text>
                <xsl:value-of select="@count ! (' eq ' || .)" />
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="x:expect-not-report" as="element(x:expect)">
        <xsl:element name="x:expect" namespace="{$x:xspec-namespace}">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:text expand-text="yes">{x:known-UQName('svrl:schematron-output')}[{x:known-UQName('svrl:fired-rule')}] and empty({x:known-UQName('svrl:schematron-output')}/{x:known-UQName('svrl:successful-report')}</xsl:text>
                <xsl:apply-templates select="@*" mode="make-predicate" />
                <xsl:text>)</xsl:text>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <!--
        mode="make-predicate"
    -->
    <xsl:mode name="make-predicate" on-multiple-match="fail" on-no-match="fail" />

    <xsl:template match="@location" as="text()" mode="make-predicate">
        <xsl:text expand-text="yes">[{x:known-UQName('x:schematron-location-compare')}({x:quote-with-apos(.)}, @location, preceding-sibling::{x:known-UQName('svrl:ns-prefix-in-attribute-values')})]</xsl:text>
    </xsl:template>

    <xsl:template match="@id | @role" as="text()" mode="make-predicate">
        <xsl:text expand-text="yes">[(@{local-name()}, preceding-sibling::{x:known-UQName('svrl:fired-rule')}[1]/@{local-name()}, preceding-sibling::{x:known-UQName('svrl:active-pattern')}[1]/@{local-name()})[1] = '{.}']</xsl:text>
    </xsl:template>

    <xsl:template match="@id[parent::x:expect-rule] | @context[parent::x:expect-rule]" as="text()"
        mode="make-predicate">
        <xsl:text expand-text="yes">[@{local-name()} = '{.}']</xsl:text>
    </xsl:template>

    <xsl:template match="@count | @label" as="empty-sequence()" mode="make-predicate" />

    <xsl:template name="make-label" as="attribute(label)">
        <xsl:context-item as="element()" use="required" />

        <xsl:attribute name="label"
            select="
                @label,
                tokenize(local-name(), '-')[. = ('report', 'assert', 'not', 'rule')],
                @id,
                @role,
                @location,
                @context,
                (@count ! ('count:', .))" />
    </xsl:template>

    <xsl:template match="x:expect-valid" as="element(x:expect)">
        <xsl:variable name="bad-roles" as="xs:string"
            select="
                ($errors ! ($x:apos || . || $x:apos))
                => string-join(', ')" />

        <xsl:element name="x:expect" namespace="{$x:xspec-namespace}">
            <xsl:attribute name="label" select="'valid'"/>
            <xsl:attribute name="test">
                <xsl:text expand-text="yes">{x:known-UQName('svrl:schematron-output')}[{x:known-UQName('svrl:fired-rule')}] and empty({x:known-UQName('svrl:schematron-output')}/({x:known-UQName('svrl:failed-assert')} | {x:known-UQName('svrl:successful-report')})[empty(@role) or (lower-case(@role) = ({$bad-roles}))])</xsl:text>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="x:expect-rule" as="element(x:expect)">
        <xsl:element name="x:expect" namespace="{$x:xspec-namespace}">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:value-of select="if (@count) then 'count' else 'exists'" />
                <xsl:text expand-text="yes">({x:known-UQName('svrl:schematron-output')}/{x:known-UQName('svrl:fired-rule')}</xsl:text>
                <xsl:apply-templates select="@*" mode="make-predicate" />
                <xsl:text>)</xsl:text>
                <xsl:value-of select="@count ! (' eq ' || .)" />
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="x:*/@href | x:helper/@stylesheet" as="attribute()">
        <xsl:attribute name="{local-name()}" namespace="{namespace-uri()}"
            select="resolve-uri(., x:base-uri(.))" />
    </xsl:template>

</xsl:stylesheet>
