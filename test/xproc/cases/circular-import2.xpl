<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" xmlns:s="x-urn:test:xproc:steplibrary"
    version="3.0">

    <p:import href="circular-import1.xpl"/>
    <p:declare-step type="s:step2">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:declare-step type="s:step2-substep">
            <p:input port="source"/>
            <p:output port="result"/>
            <p:identity/>
        </p:declare-step>
        <p:identity/>
    </p:declare-step>
</p:library>
