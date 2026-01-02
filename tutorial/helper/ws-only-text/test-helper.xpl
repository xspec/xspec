<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:p="http://www.w3.org/ns/xproc" version="3.0"
    xmlns:test-helper="x-urn:tutorial:helper:ws-only-text:test-helper">
    
    <p:declare-step type="test-helper:remove-whitespace-only-text">
        <p:input port="source"/>
        <p:output port="result"/>
        <p:delete match="descendant::text()[normalize-space() => not()]"/>
    </p:declare-step>
    
</p:library>
