<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:s="x-urn:test:xproc:steplibrary"
    type="s:bad-xproc-declaration" version="3.1">
    <p:input port="source" sequence="true">
        <p:inline/>
    </p:input>
    <p:output port="result"/>
    <!-- Missing required 'count' attribute -->
    <p:text-head/>
</p:declare-step>
