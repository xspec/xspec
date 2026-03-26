<?xml version="1.0" encoding="UTF-8"?>
<xproc:library xmlns:x="x-urn:test:prefix-conflict" xmlns:p="x-urn:test:prefix-conflict"
    xmlns:xproc="http://www.w3.org/ns/xproc" version="3.0">

    <xproc:declare-step type="x:identity">
        <xproc:input port="source" sequence="true" content-types="any">
            <default/>
        </xproc:input>
        <xproc:output port="xproc-result" sequence="true" content-types="any"/>
        <xproc:identity/>
    </xproc:declare-step>

    <xproc:declare-step type="x:option-value">
        <xproc:output port="xproc-result" sequence="true" content-types="any"/>
        <xproc:option name="x:option-items" select="'default'"/>
        <xproc:identity>
            <xproc:with-input select="$x:option-items">
                <xproc:inline/>
            </xproc:with-input>
        </xproc:identity>
    </xproc:declare-step>

    <xproc:declare-step type="p:p-identity" name="pi">
        <xproc:input port="source" sequence="true" content-types="any">
            <default/>
        </xproc:input>
        <xproc:output port="xproc-result" sequence="true" content-types="any"/>
        <xproc:identity/>
    </xproc:declare-step>
    
    <xproc:declare-step type="p:p-option-value">
        <xproc:output port="xproc-result" sequence="true" content-types="any"/>
        <xproc:option name="p:option-items" select="'default'"/>
        <xproc:identity>
            <xproc:with-input select="$p:option-items">
                <xproc:inline/>
            </xproc:with-input>
        </xproc:identity>
    </xproc:declare-step>
</xproc:library>
