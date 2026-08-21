<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:s="x-urn:test:xproc:steplibrary" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.1">

    <p:declare-step type="s:load-text">
        <p:output port="xproc-result" content-types="text"/>
        <p:load href="text.123"/>
    </p:declare-step>

</p:library>
