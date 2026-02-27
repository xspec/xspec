<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:px="http://www.jenitennison.com/xslt/xspec/helper/load"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" type="px:load" name="load" version="3.0">

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
