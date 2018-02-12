<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="../../src/schemas/xspec.rnc" type="application/relax-ng-compact-syntax"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:x="http://www.jenitennison.com/xslt/xspec" 
    exclude-result-prefixes="xs" version="2.0">
    
    <xsl:param name="stylesheet" select="concat(x:description/@schematron, '.xsl')"/>
    <xsl:param name="test_dir" select="'xspec'"/>
    

    <xsl:variable name="error" select="('error', 'fatal')"/>
    <xsl:variable name="warn" select="('warn', 'warning')"/>
    <xsl:variable name="info" select="('info', 'information')"/>


    <xsl:template match="@* | node()" priority="-2">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="x:description[@schematron]">
        <xsl:element name="x:description">
            <xsl:namespace name="svrl" select="'http://purl.oclc.org/dsdl/svrl'"/>
            <xsl:apply-templates select="@*[not(name() = ('stylesheet'))]"/>
            <xsl:element name="x:scenario">
                <xsl:attribute name="label">
                    <xsl:text>Schematron: "</xsl:text>
                    <xsl:value-of select="@schematron"/>
                    <xsl:text>"</xsl:text>
                    <xsl:if test="x:param[@name='phase']">
                        <xsl:value-of select="concat(' phase: ', x:param[@name='phase'][1]/(@select,string())[1])"/>
                    </xsl:if>
                </xsl:attribute>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@schematron">
        <xsl:attribute name="stylesheet" select="$stylesheet"/>
        <xsl:variable name="path" select="resolve-uri(string(), base-uri())"/>
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
                <xsl:apply-templates select="doc($href)/x:description/node()"/>
                <xsl:comment>END IMPORT "<xsl:value-of select="@href"/>"</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="x:context[not(@href)][
        parent::*/x:expect-assert | parent::*/x:expect-not-assert |
        parent::*/x:expect-report | parent::*/x:expect-not-report |
        parent::*/x:expect-valid | ancestor::x:description[@schematron] ]">
        <xsl:variable name="file" select="concat($test_dir, '/', 'context-', generate-id(), '.xml')"/>
        <xsl:result-document href="{$file}">
            <xsl:copy-of select="./node()"/>
        </xsl:result-document>
        <xsl:element name="x:context">
            <xsl:attribute name="href" select="$file"/>
        </xsl:element>
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
        <xsl:attribute name="label" select="string-join((@label, tokenize(local-name(),'-')[.=('report','assert','not','rule')], @id, @role, @location, @context, current()[@count]/string('count:'), @count), ' ')"/>
    </xsl:template>

    <xsl:template match="x:expect-valid">
        <xsl:element name="x:expect">
            <xsl:attribute name="label" select="'valid'"/>
            <xsl:attribute name="test" select="concat(
                'boolean(svrl:schematron-output[svrl:fired-rule]) and
                not(boolean((svrl:schematron-output/svrl:failed-assert union svrl:schematron-output/svrl:successful-report)[
                not(@role) or @role = (',
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
    
</xsl:stylesheet>
