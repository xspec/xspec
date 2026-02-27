<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:s="x-urn:test:xproc:steplibrary" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xspec="http://www.jenitennison.com/xslt/xspec" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    type="s:option-name-in-x-namespace" version="3.0">

    <p:documentation>This step has an option name in the XSpec namespace.</p:documentation>
    <p:input port="source"/>
    <p:output port="xproc-result"/>
    <p:option name="xspec:opt"/>
    <p:add-attribute attribute-name="opt" attribute-value="{$xspec:opt}"/>
</p:declare-step>
