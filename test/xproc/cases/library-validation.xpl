<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:s="x-urn:test:xproc:steplibrary" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.1">

    <!-- Simplified wrapper around p:validate-with-relax-ng -->
    <p:declare-step type="s:validate-with-relax-ng">
        <p:input port="source" primary="true" content-types="xml"/>
        <p:input port="schema" primary="false" content-types="text xml"/>
        <p:output port="xproc-result" primary="true" content-types="xml html"/>
        <p:output port="xproc-report" primary="false" sequence="true" content-types="xml json"
        pipe="report@validate"/>
        <p:option name="assert-valid" select="true()" as="xs:boolean"/>
        <p:option name="report-format" select="'xvrl'" as="xs:string"/>
        <p:validate-with-relax-ng assert-valid="{$assert-valid}" report-format="{$report-format}"
            name="validate">
            <p:with-input port="source" pipe="source"/>
            <p:with-input port="schema" pipe="schema"/>
        </p:validate-with-relax-ng>
    </p:declare-step>

</p:library>
