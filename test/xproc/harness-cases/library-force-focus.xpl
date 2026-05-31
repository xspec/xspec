<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:s="x-urn:test:xproc:steplibrary"
    xmlns:x="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.1">

    <p:declare-step type="s:xslt-varying-force-focus">
        <p:import href="../../../src/xproc3/run-xslt.xpl"/>
        <p:option name="force-focus" as="xs:string"/>
        <p:output port="result"/>
        <x:run-xslt xspec-home="{resolve-uri('../../../')}">
            <p:with-input href="../../end-to-end/cases/focus-without-pending.xspec"/>
            <p:with-option name="force-focus" select="$force-focus"/>
        </x:run-xslt>
    </p:declare-step>

    <p:declare-step type="s:xquery-varying-force-focus">
        <p:import href="../../../src/xproc3/run-xquery.xpl"/>
        <p:option name="force-focus" as="xs:string"/>
        <p:output port="result"/>
        <x:run-xquery xspec-home="{resolve-uri('../../../')}">
            <p:with-input href="../../end-to-end/cases/focus-without-pending.xspec"/>
            <p:with-option name="force-focus" select="$force-focus"/>
        </x:run-xquery>
    </p:declare-step>

    <p:declare-step type="s:xproc-varying-force-focus">
        <p:import href="../../../src/xproc3/xproc-testing/run-xproc.xpl"/>
        <p:option name="force-focus" as="xs:string"/>
        <p:output port="result"/>
        <x:run-xproc xspec-home="{resolve-uri('../../../')}">
            <p:with-input href="supporting-files/force-focus-scenarios_xproc.xspec"/>
            <p:with-option name="force-focus" select="$force-focus"/>
        </x:run-xproc>
    </p:declare-step>

    <!-- Schematron via XQS requires BaseX, so s:schematron-xqs-varying-force-focus
        is used in test/xqs/force-focus.xspec, not in test/xproc/force-focus.xspec -->
    <p:declare-step type="s:schematron-xqs-varying-force-focus">
        <p:import href="../../../src/xproc3/schematron-xqs/run-schematron-xqs.xpl"/>
        <p:option name="force-focus" as="xs:string"/>
        <p:output port="result"/>
        <x:run-schematron-xqs xspec-home="{resolve-uri('../../../')}">
            <p:with-input href="supporting-files/force-focus-scenarios_xqs.xspec"/>
            <p:with-option name="force-focus" select="$force-focus"/>
        </x:run-schematron-xqs>
    </p:declare-step>

</p:library>
