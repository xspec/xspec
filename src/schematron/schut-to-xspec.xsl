<?xml version="1.0" encoding="UTF-8"?>
<?xml-model href="../../src/schemas/xspec.rnc" type="application/relax-ng-compact-syntax"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:s="http://www.jenitennison.com/xslt/xspec/schematron"
    xmlns:x="http://www.jenitennison.com/xslt/xspec" 
    exclude-result-prefixes="xs" version="2.0">
    
    <xsl:param name="stylesheet" select="concat(s:description/@schematron, '.xsl')"/>
    

    <xsl:variable name="error" select="('error', 'fatal')"/>
    <xsl:variable name="warn" select="('warn', 'warning')"/>
    <xsl:variable name="info" select="('info', 'information')"/>


    <xsl:variable name="ns" as="element()">
        <namespaces>
            <ns name="XSpec" prefix="x" uri="http://www.jenitennison.com/xslt/xspec"/>
            <ns name="Schut" prefix="s" uri="http://www.jenitennison.com/xslt/xspec/schematron"/>
        </namespaces>
    </xsl:variable>

    <xsl:template match="*[namespace-uri-from-QName(node-name(.)) = $ns/ns[@name = 'Schut']/@uri]" priority="-1">
        <xsl:element name="{concat('x:', local-name())}" namespace="{$ns/ns[@name='XSpec']/@uri}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@* | node()" priority="-2">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')"/>
    
    <xsl:template match="s:description">
        <xsl:element name="x:description">
            <xsl:namespace name="svrl" select="'http://purl.oclc.org/dsdl/svrl'"/>
            <xsl:apply-templates select="@*[not(name() = 'phase')]"/>
            <xsl:element name="x:scenario">
                <xsl:attribute name="label">
                    <xsl:text>Schematron: "</xsl:text>
                    <xsl:value-of select="@schematron"/>
                    <xsl:text>" phase: </xsl:text>
                    <xsl:value-of select="(@phase/string(), '#ALL')[1]"/>
                </xsl:attribute>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@schematron">
        <xsl:attribute name="stylesheet" select="$stylesheet"/>
        <xsl:variable name="path" select="iri-to-uri(concat(replace(document-uri(/), '(.*)/.*$', '$1'), '/', string()))"/>
        <xsl:for-each select="doc($path)/sch:schema/sch:ns" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
            <xsl:namespace name="{./@prefix}" select="./@uri"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="s:import">
        <xsl:variable name="href" select="iri-to-uri(concat(replace(document-uri(/), '(.*)/.*$', '$1'), '/', @href))"/>
        <xsl:comment>BEGIN IMPORT "<xsl:value-of select="@href"/>"</xsl:comment>
        <xsl:apply-templates select="doc($href)/s:description/node()"/>
        <xsl:comment>END IMPORT "<xsl:value-of select="@href"/>"</xsl:comment>
    </xsl:template>
    
    <xsl:template match="s:import[@type = 'xspec']">
        <xsl:element name="x:import">
            <xsl:attribute name="href" select="@href"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="s:context[not(@href)]">
        <xsl:variable name="file" select="concat('xspec/', 'context-', generate-id(), '.xml')"/>
        <xsl:result-document href="{$file}">
            <xsl:copy-of select="./node()"/>
        </xsl:result-document>
        <xsl:element name="x:context">
            <xsl:attribute name="href" select="$file"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="s:expect-assert">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="'exists(svrl:schematron-output/svrl:failed-assert'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="s:expect-not-assert">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="'boolean(svrl:schematron-output[svrl:fired-rule]) and empty(svrl:schematron-output/svrl:failed-assert'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="s:expect-report">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="'exists(svrl:schematron-output/svrl:successful-report'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>


    <xsl:template match="s:expect-not-report">
        <xsl:element name="x:expect">
            <xsl:call-template name="make-label"/>
            <xsl:attribute name="test">
                <xsl:sequence select="'boolean(svrl:schematron-output[svrl:fired-rule]) and empty(svrl:schematron-output/svrl:successful-report'"/>
                <xsl:apply-templates select="@*" mode="make-predicate"/>
                <xsl:sequence select="')'"/>
            </xsl:attribute>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@id | @role | @location" mode="make-predicate">
        <xsl:sequence select="concat('[@', local-name(.), ' = ', codepoints-to-string(39), ., codepoints-to-string(39), ']')"/>
    </xsl:template>

    <xsl:template name="make-label">
        <xsl:attribute name="label" select="string-join((tokenize(local-name(),'-')[.=('report','assert','not')], @id, @role, @location), ' ')"/>
    </xsl:template>

    <xsl:template match="s:expect-valid">
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
    
</xsl:stylesheet>
