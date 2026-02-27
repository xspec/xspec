<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:s="x-urn:test:xproc:steplibrary"
    exclude-inline-prefixes="s" version="3.1">

    <p:option name="s:add-attr" select="false()" static="true"/>
    <p:declare-step type="s:add-attrs-maybe">
        <p:output port="result"/>
        <p:option name="local-add-attr" select="false()" static="true"/>
        <p:identity>
            <p:with-input port="source">
                <document/>
            </p:with-input>
        </p:identity>
        <p:add-attribute attribute-name="global" attribute-value="1" use-when="$s:add-attr"/>
        <p:add-attribute attribute-name="local" attribute-value="1" use-when="$local-add-attr"/>
    </p:declare-step>
</p:library>
