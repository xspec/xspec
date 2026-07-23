<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:s="x-urn:test:xproc:steplibrary" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">

    <p:declare-step type="s:public-step-that-calls-private-step">
        <p:documentation>This step calls a private step.</p:documentation>
        <p:input port="source"/>
        <p:option name="some-option"/>
        <p:output port="xproc-result"/>
        <s:private-step some-option="{$some-option}"/>
        <p:add-attribute attribute-name="public-step" attribute-value="{$some-option}"/>
    </p:declare-step>

    <p:declare-step type="s:private-step" visibility="private">
        <p:input port="source"/>
        <p:option name="some-option"/>
        <p:output port="xproc-result"/>
        <p:add-attribute attribute-name="private-step" attribute-value="{$some-option}"/>
    </p:declare-step>

    <p:declare-step type="s:unused-private-step" visibility="private">
        <p:input port="source"/>
        <p:option name="some-option"/>
        <p:output port="xproc-result"/>
        <p:identity/>
    </p:declare-step>

    <p:declare-step type="s:self-contained-public-step" visibility="public">
        <p:input port="source"/>
        <p:option name="some-option"/>
        <p:output port="xproc-result"/>
        <p:identity/>
    </p:declare-step>

</p:library>
