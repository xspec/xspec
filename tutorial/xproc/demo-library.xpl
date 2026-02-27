<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:eg="x-urn:tutorial:xproc:xproc-demo"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-inline-prefixes="eg xs">

    <p:declare-step name="demo" type="eg:demo">

        <!-- Ports -->
        <p:input port="source" primary="true" content-types="application/xml"/>
        <p:input port="id-data" content-types="application/xml">
            <element-with-id xml:id="some-ID-value"/>
        </p:input>
        <p:output port="result" primary="true"/>
        <p:output port="original" pipe="source@demo"/>

        <!-- Options -->
        <p:option name="wrapper" as="xs:QName" select="QName('','wrapper-element')"/>

        <!-- Body of step -->
        <p:wrap-sequence wrapper="{$wrapper}"/>
        <p:add-attribute attribute-name="xml:id">
            <p:with-option name="attribute-value" select="(//@xml:id)[1]" pipe="id-data@demo"/>
        </p:add-attribute>
    </p:declare-step>
</p:library>
