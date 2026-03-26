<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:mirror="x-urn:test:mirror" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">

    <p:declare-step type="mirror:identity">
        <p:input port="source" sequence="true" content-types="any"/>
        <p:output port="xproc-result" sequence="true" content-types="any"/>
        <p:identity/>
    </p:declare-step>

</p:library>
