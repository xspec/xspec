<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:s="x-urn:test:xproc:steplibrary"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">

    <!-- For steps in this library, the argument list for calling the step might be wrong because
        XSpec doesn't know the value of @use-when. -->
    <p:option name="aux-port" as="xs:boolean" select="true()" static="true"/>
    <p:option name="include-step" as="xs:boolean" select="true()" static="true"/>

    <p:declare-step type="s:input-port-with-use-when" name="this">
        <p:input port="aux" sequence="true" use-when="$aux-port">
            <document-at-aux-port/>
        </p:input>
        <p:input port="source" primary="true"/>
        <p:output port="result"/>
        <p:variable name="aux-element" pipe="aux@this" select="/*/name()" use-when="$aux-port"/>
        <p:identity message="Found {$aux-element} element at aux input port" use-when="$aux-port"/>
        <p:identity>
            <p:with-input>
                <output aux-element="{$aux-element}"/>
            </p:with-input>
        </p:identity>
    </p:declare-step>

    <p:declare-step type="s:step-with-use-when" use-when="$include-step">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:identity/>
    </p:declare-step>
</p:library>
