<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:s="x-urn:test:xproc:steplibrary"
    xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.1">

    <p:declare-step type="s:xslt-varying-html-report-theme">
        <p:import href="../../../src/xproc3/run-xslt.xpl"/>
        <p:option name="html-report-theme" as="xs:string"/>
        <p:output port="result"/>
        <x:run-xslt xspec-home="{resolve-uri('../../../')}">
            <p:with-input href="../../../tutorial/escape-for-regex.xspec"/>
            <p:with-option name="html-report-theme" select="$html-report-theme"/>
            <p:with-option name="inline-css" select="'false'"/>
        </x:run-xslt>
    </p:declare-step>

    <p:declare-step type="s:xquery-varying-html-report-theme">
        <p:import href="../../../src/xproc3/run-xquery.xpl"/>
        <p:option name="html-report-theme" as="xs:string"/>
        <p:output port="result"/>
        <x:run-xquery xspec-home="{resolve-uri('../../../')}">
            <p:with-input href="../../../tutorial/xquery-tutorial.xspec"/>
            <p:with-option name="html-report-theme" select="$html-report-theme"/>
            <p:with-option name="inline-css" select="'false'"/>
        </x:run-xquery>
    </p:declare-step>

    <p:declare-step type="s:xproc-varying-html-report-theme">
        <p:import href="../../../src/xproc3/xproc-testing/run-xproc.xpl"/>
        <p:option name="html-report-theme" as="xs:string"/>
        <p:output port="result"/>
        <x:run-xproc xspec-home="{resolve-uri('../../../')}">
            <p:with-input href="../../../tutorial/xproc/xproc-testing-demo.xspec"/>
            <p:with-option name="html-report-theme" select="$html-report-theme"/>
            <p:with-option name="inline-css" select="'false'"/>
        </x:run-xproc>
    </p:declare-step>

    <!-- Schematron via XQS requires BaseX, so s:schematron-xqs-varying-html-report-theme
        is used in test/xqs/html-report-theme.xspec, not in test/xproc/html-report-theme.xspec -->
    <p:declare-step type="s:schematron-xqs-varying-html-report-theme">
        <p:import href="../../../src/xproc3/schematron-xqs/run-schematron-xqs.xpl"/>
        <p:option name="html-report-theme" as="xs:string"/>
        <p:output port="result"/>
        <x:run-schematron-xqs xspec-home="{resolve-uri('../../../')}">
            <p:with-input href="../../../tutorial/schematron-xqs/demo-01.xspec"/>
            <p:with-option name="html-report-theme" select="$html-report-theme"/>
            <p:with-option name="inline-css" select="'false'"/>
        </x:run-schematron-xqs>
    </p:declare-step>

</p:library>
