<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:s="x-urn:test:xproc:steplibrary" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">

    <p:import href="library-connections.xpl"/>
    <p:import href="input-port-use-when.xpl"/>

    <p:declare-step type="s:step-with-substep">
        <p:documentation>This step has a substep.</p:documentation>
        <p:input port="source"/>
        <p:output port="xproc-result"/>
        <p:declare-step type="s:substep" visibility="public">
            <p:input port="source"/>
            <p:output port="xproc-result"/>
            <p:add-attribute attribute-name="substep" attribute-value="executed"/>
        </p:declare-step>
        <s:substep/>
        <p:add-attribute attribute-name="parent-step" attribute-value="executed"/>
    </p:declare-step>

    <p:declare-step type="s:input-port-sequence-true">
        <p:documentation>This step outputs the number of input documents.</p:documentation>
        <p:input port="source" content-types="any" sequence="true"/>
        <p:output port="xproc-result" sequence="false"/>
        <p:count/>
    </p:declare-step>

    <p:declare-step type="s:output-port-sequence-true">
        <p:documentation>This step can output up to 3 documents.</p:documentation>
        <p:output port="xproc-result" sequence="true"/>
        <p:option name="num" as="xs:integer" select="2"/>
        <p:for-each>
            <p:with-input select="/wrapper/document[position() le $num]">
                <wrapper>
                    <document/>
                    <document/>
                    <document/>
                </wrapper>
            </p:with-input>
            <p:identity>
                <p:with-input>
                    <output-document/>
                </p:with-input>
            </p:identity>
        </p:for-each>
    </p:declare-step>

    <p:declare-step type="s:input-port-with-default">
        <p:documentation>This step has a default document on the input port.</p:documentation>
        <p:input port="source">
            <p:inline>
                <document/>
            </p:inline>
        </p:input>
        <p:output port="xproc-result"/>
        <p:identity/>
    </p:declare-step>

</p:library>
