<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:s="x-urn:test:xproc:steplibrary" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:h="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">

    <p:import href="library-mirror.xpl"/>

    <p:declare-step type="s:get-html-description">
        <p:input port="source" content-types="html application/xml"/>
        <p:output port="xproc-result" sequence="true"/>
        <p:filter select="//h:meta[@name='description']"/>
    </p:declare-step>

    <p:declare-step type="s:get-text-line">
        <p:input port="source" content-types="text" sequence="true"/>
        <p:output port="xproc-result" content-types="text/plain" sequence="true"/>
        <p:for-each>
            <p:text-head count="1"/>
        </p:for-each>
    </p:declare-step>

    <p:declare-step type="s:json-join" name="json-join">
        <p:input port="source" content-types="application/json" sequence="true"/>
        <p:output port="xproc-result" content-types="application/json"/>
        <p:json-join flatten-to-depth="unbounded"/>
    </p:declare-step>

    <p:declare-step type="s:get-content-type" name="get-content-type">
        <p:input port="source"/>
        <p:output port="xproc-result"/>
        <p:identity>
            <p:with-input port="source" select="p:document-property(., 'content-type')"/>
        </p:identity>
    </p:declare-step>

</p:library>
