<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:mirror="x-urn:test:mirror" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">

    <p:declare-step type="mirror:identity">
        <p:input port="source" sequence="true" content-types="any">
            <default/>
        </p:input>
        <p:output port="xproc-result" sequence="true" content-types="any"/>
        <p:identity/>
    </p:declare-step>

    <p:declare-step type="mirror:option-value">
        <!-- Note: For nodes, mirror:option-value returns the option value wrapped in
        a document node. For details, see
        https://spec.xproc.org/3.1/xproc/#creating-documents-from-xdm-step-results -->
        <p:output port="xproc-result" sequence="true" content-types="any"/>
        <p:option name="opt" select="'default'"/>
        <p:identity>
            <p:with-input select="$opt">
                <p:inline/>
            </p:with-input>
        </p:identity>
    </p:declare-step>

    <p:declare-step type="mirror:option-property">
        <p:output port="xproc-result" sequence="true" content-types="any"/>
        <p:option name="opt" select="'default'"/>
        <p:option name="property-to-get"/>
        <p:identity>
            <p:with-input select="$opt ! p:document-property(., $property-to-get)">
                <p:inline/>
            </p:with-input>
        </p:identity>
    </p:declare-step>
</p:library>
