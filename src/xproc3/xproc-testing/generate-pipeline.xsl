<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:p="http://www.w3.org/ns/xproc" xmlns:x="http://www.jenitennison.com/xslt/xspec"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="xspec-home" as="xs:string?"/>
    <xsl:param name="force-focus" as="xs:string?"/>
    <xsl:param name="html-report-theme" as="xs:string" select="'default'"/>
    <xsl:param name="inline-css" as="xs:string" select="'true'"/>
    <xsl:param name="junit-enabled" as="xs:string" select="'false'"/>
    <xsl:include href="../../compiler/xproc/in-scope-steps/generate-xproc-imports.xsl"/>

    <xsl:template name="generate-pipeline" as="element(p:declare-step)">
        <xsl:context-item as="document-node(element(x:description))" use="required"/>
        <p:declare-step version="3.1" xmlns:x="http://www.jenitennison.com/xslt/xspec">
            <xsl:call-template name="generate-imports"/>
            <xsl:call-template name="declare-ports"/>
            <xsl:call-template name="declare-step-runner"/>
            <xsl:call-template name="declare-harness-step"/>
            <xsl:call-template name="execute-harness-step"/>
        </p:declare-step>
    </xsl:template>

    <xsl:template name="declare-ports" as="node()+">
        <xsl:comment>Declare ports</xsl:comment>
        <p:input port="xspec"/>
        <p:output port="result" primary="true"/>
        <p:output port="junit" primary="false" sequence="true" pipe="junit@run-test-suite"/>
    </xsl:template>

    <xsl:template name="declare-harness-step" as="node()+">
        <xsl:comment>substep to run a test suite whose XProc step functions are in scope</xsl:comment>
        <xsl:variable name="harness-library"
            select="if ($xspec-home != '') then
            resolve-uri('src/xproc3/harness-lib.xpl', $xspec-home)
            else
            'http://www.jenitennison.com/xslt/xspec/xproc/lib'"/>

        <p:declare-step name="xproc-compile-run-format" type="x:xproc-compile-run-format">
            <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>

            <p:import href="{$harness-library}"/>

            <p:input port="source" primary="true" sequence="false" content-types="application/xml"/>
            <p:output port="result" serialization="map{{
                'indent':true(),
                'method':'xhtml',
                'encoding':'UTF-8',
                'include-content-type':true(),
                'omit-xml-declaration':false()
                }}"
                primary="true"
                pipe="result@format-report" />
            <p:output port="junit"
                content-types="xml"
                serialization="map{{
                'method':'xml'
                }}"
                primary="false"
                sequence="true"
                pipe="result@junit-report"/>

            <p:option name="xspec-home" as="xs:string?"/>
            <p:option name="force-focus" as="xs:string?" select="'{$force-focus}'"/>
            <p:option name="html-report-theme" as="xs:string" select="'{$html-report-theme}'"/>
            <p:option name="inline-css" as="xs:string" select="'{$inline-css}'"/>
            <p:option name="junit-enabled" as="xs:string" select="'{$junit-enabled}'"/>

            <p:option name="parameters" as="map(xs:QName,item()*)" select="map{{}}"/>

            <xsl:comment>compile the suite into a stylesheet</xsl:comment>
            <x:compile-xproc name="compile" p:message="&#10;Creating Test Runner...">
                <p:with-option name="xspec-home" select="$xspec-home"/>
                <p:with-option name="force-focus" select="$force-focus"/>
                <p:with-option name="parameters" select="$parameters"/>
            </x:compile-xproc>

            <xsl:comment>run it</xsl:comment>
            <p:xslt name="run" template-name="x:main" message="&#10;Running Tests...">
                <p:with-input port="source">
                    <p:empty/>
                </p:with-input>
                <p:with-input port="stylesheet" pipe="@compile"/>
            </p:xslt>

            <xsl:comment>format the report</xsl:comment>
            <x:format-report name="format-report" p:message="&#10;Formatting Report...">
                <p:with-option name="xspec-home" select="$xspec-home"/>
                <p:with-option name="force-focus" select="$force-focus"/>
                <p:with-option name="html-report-theme" select="$html-report-theme"/>
                <p:with-option name="inline-css" select="$inline-css"/>
                <p:with-option name="parameters" select="$parameters"/>
            </x:format-report>

            <xsl:comment>produce the JUnit report if requested</xsl:comment>
            <x:maybe-format-junit-report name="junit-report" p:depends="format-report">
                <p:with-input port="source" pipe="result@run"/>
                <p:with-option name="xspec-home" select="$xspec-home" />
                <p:with-option name="junit-enabled" select="$junit-enabled" />
            </x:maybe-format-junit-report>
        </p:declare-step>
    </xsl:template>

    <xsl:template name="execute-harness-step" as="node()+">
        <xsl:comment>run the test suite</xsl:comment>
        <x:xproc-compile-run-format name="run-test-suite">
            <p:with-option name="xspec-home">
                <xsl:attribute name="select"
                    select="if (exists($xspec-home)) then x:quote-with-apos($xspec-home) else '()'"/>
            </p:with-option>
        </x:xproc-compile-run-format>
    </xsl:template>
</xsl:stylesheet>
