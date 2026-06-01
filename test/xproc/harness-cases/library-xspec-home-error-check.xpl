<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:s="x-urn:test:xproc:steplibrary"
    xmlns:x="http://www.jenitennison.com/xslt/xspec" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.1">

    <p:declare-step type="s:xslt-varying-xspec-home">
        <p:import href="../../../src/xproc3/run-xslt.xpl"/>
        <p:option name="xspec-home" as="xs:string?"/>
        <p:output port="result" sequence="true"/>
        <x:run-xslt>
            <p:with-input href="../../../tutorial/escape-for-regex.xspec"/>
            <p:with-option name="xspec-home" select="$xspec-home"/>
        </x:run-xslt>
    </p:declare-step>

    <p:declare-step type="s:xquery-varying-xspec-home">
        <p:import href="../../../src/xproc3/run-xquery.xpl"/>
        <p:option name="xspec-home" as="xs:string?"/>
        <x:run-xquery>
            <p:with-input href="../../../tutorial/xquery-tutorial.xspec"/>
            <p:with-option name="xspec-home" select="$xspec-home"/>
        </x:run-xquery>
    </p:declare-step>

    <p:declare-step type="s:xproc-varying-xspec-home">
        <p:import href="../../../src/xproc3/xproc-testing/run-xproc.xpl"/>
        <p:option name="xspec-home" as="xs:string?"/>
        <x:run-xproc>
            <p:with-input href="../../../tutorial/xproc/xproc-testing-demo.xspec"/>
            <p:with-option name="xspec-home" select="$xspec-home"/>
        </x:run-xproc>
    </p:declare-step>

    <!-- Schematron via XQS requires BaseX, so s:schematron-xqs-varying-xspec-home
        is used in test/xqs/xspec-home-error-check.xspec, not in
        test/xproc/xspec-home-error-check.xspec -->
    <p:declare-step type="s:schematron-xqs-varying-xspec-home">
        <p:import href="../../../src/xproc3/schematron-xqs/run-schematron-xqs.xpl"/>
        <p:option name="xspec-home" as="xs:string?"/>
        <x:run-schematron-xqs>
            <p:with-input href="../../../tutorial/schematron-xqs/demo-01.xspec"/>
            <p:with-option name="xspec-home" select="$xspec-home"/>
        </x:run-schematron-xqs>
    </p:declare-step>

</p:library>