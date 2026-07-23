<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" version="3.0"
    xmlns:test-target="x-urn:tutorial:helper:ws-only-text:test-target" type="test-target:my-step">
    <p:documentation>
        This step just renames some elements. All the other nodes including whitespace-only
        text nodes are kept intact.
    </p:documentation>

    <p:input port="source"/>
    <p:output port="result"/>

    <!-- Rename <bar> to <baz> -->
    <p:rename match="bar" new-name="baz"/>

    <!-- Rename <foo> to <bar> -->
    <p:rename match="foo" new-name="bar"/>
</p:declare-step>
