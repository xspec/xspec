<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="#all" version="3.0">

    <xsl:include href="../../../common/uri-utils.xsl"/>
    <xsl:include href="../../../common/common-utils.xsl"/>
    <xsl:include href="../../../common/uqname-utils.xsl"/>
    <xsl:include href="../../../common/namespace-vars.xsl"/>
    <xsl:include href="../../base/util/compiler-misc-utils.xsl"/>

    <!-- Entry point from xspec.bat and xspec.sh -->
    <xsl:template match="/" as="element(p:library)">
        <p:library version="3.1">
            <xsl:call-template name="generate-imports"/>
        </p:library>
    </xsl:template>

    <!-- Entry point from generate-pipeline.xsl -->
    <xsl:template name="generate-imports" as="node()+">
        <xsl:context-item as="document-node(element(x:description))" use="required"/>
        <xsl:comment>Import the pipeline referenced in x:description/@xproc</xsl:comment>
        <xsl:apply-templates select="x:description/@xproc"/>
        <xsl:comment>Import a library that the test runner uses</xsl:comment>
        <xsl:call-template name="import-function-wrappers"/>
        <xsl:sequence>
            <xsl:on-non-empty>
                <xsl:comment select="'Import pipelines referenced by @xproc in x:helper, ' ||
                    'recursively across imported XSpec files'"/>
            </xsl:on-non-empty>
            <xsl:apply-templates select="x:description"/>
        </xsl:sequence>
    </xsl:template>

    <xsl:template match="x:description" as="element(p:import)*">
        <xsl:apply-templates select="x:helper"/>
        <xsl:for-each select="x:import[@href]">
            <xsl:variable name="imported-xspec" as="document-node(element(x:description))"
                select="@href => resolve-uri(base-uri()) => doc()"/>
            <xsl:apply-templates select="$imported-xspec/x:description"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="x:helper" as="element(p:import)?">
        <xsl:apply-templates select="@xproc"/>
    </xsl:template>

    <xsl:template match="x:description/@xproc | x:helper/@xproc" as="element(p:import)">
        <!-- Resolve @xproc to get actual base URI -->
        <xsl:variable name="resolved-xproc" select="
                resolve-uri(., base-uri())
                => x:resolve-xml-uri-with-catalog()"/>
        <xsl:choose>
            <xsl:when test="exists(doc($resolved-xproc)/(p:declare-step | p:library))">
                <p:import href="{$resolved-xproc}"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="..">
                    <xsl:message terminate="yes">
                        <xsl:call-template name="x:prefix-diag-message">
                            <xsl:with-param name="message">
                                <xsl:text expand-text="yes">File at {@xproc} is not XProc. </xsl:text>
                                <xsl:text>It should have /p:declare-step or /p:library. </xsl:text>
                                <xsl:text expand-text="yes">Instead, it has /{
                                    doc($resolved-xproc)/element() => name()
                                    }.</xsl:text>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:message>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="import-function-wrappers" as="element(p:import)">
        <xsl:variable name="resolved-uri" select="
                resolve-uri('../wrap-standard-functions/wrap-standard-functions.xpl')"/>
        <p:import href="{$resolved-uri}"/>
    </xsl:template>
</xsl:stylesheet>
