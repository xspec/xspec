<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is a copy of tutorial/helper/document-nodes/test-helper-load.xpl
    just to simplify bats testing that occurs in an isolated temporary directory. -->
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:thd-step="http://www.jenitennison.com/xslt/xspec/helper/document-nodes/steps"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" type="thd-step:load" name="load" version="3.0">

    <!-- Wrapper around standard p:load step. Only custom steps can be accessed from XPath. -->
    <p:output port="result" sequence="true" content-types="any"/>
    <p:option name="href" required="true" as="xs:anyURI"/>
    <p:option name="parameters" as="map(xs:QName,item()*)?"/>
    <p:option name="content-type" as="xs:string?"/>
    <p:option name="document-properties" as="map(xs:QName, item()*)?"/>
    <p:load>
        <p:with-option name="href" select="$href"/>
        <p:with-option name="parameters" select="$parameters"/>
        <p:with-option name="content-type" select="$content-type"/>
        <p:with-option name="document-properties" select="$document-properties"/>
    </p:load>

</p:declare-step>
