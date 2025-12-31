<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:s="x-urn:test:xproc:steplibrary" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:h="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">

    <p:declare-step type="s:set-properties">
        <p:input port="source"/>
        <p:output port="xproc-result" sequence="true"/>
        <p:option name="properties" as="map(xs:QName,item()*)" required="true"/>
        <p:option name="merge" as="xs:boolean" select="true()"/>
        <p:set-properties merge="{$merge}">
            <p:with-option name="properties" select="$properties"/>
        </p:set-properties>
    </p:declare-step>

    <p:declare-step type="s:two-outputs-sequence-true">
        <p:input port="source" sequence="true"/>
        <p:output port="out1" primary="true" sequence="true" pipe="@identity"/>
        <p:output port="out2" primary="false" sequence="true" pipe="@count"/>
        <p:output port="out3" primary="false" sequence="true"/>
        <p:identity name="identity"/>
        <p:count name="count"/>
    </p:declare-step>
</p:library>
