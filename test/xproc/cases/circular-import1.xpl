<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:s="x-urn:test:xproc:steplibrary"
    version="3.0">

    <p:import href="circular-import2.xpl"/>
    <p:declare-step type="s:step1">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:identity/>
    </p:declare-step>
</p:library>
