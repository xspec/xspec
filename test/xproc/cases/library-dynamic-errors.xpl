<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:s="x-urn:test:xproc:steplibrary" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.1">

    <p:declare-step type="s:p-error">
        <p:option name="error-msg" select="()"/>
        <p:if test="exists($error-msg)">
            <p:error code="s:error-from-my-xproc-step" name="s-p-error">
                <p:with-input port="source" expand-text="true">
                    <s:document>{$error-msg}</s:document>
                </p:with-input>
            </p:error>
        </p:if>
    </p:declare-step>

    <p:declare-step type="s:p-error-UQName-code">
        <p:error name="s-p-error-UQName-code"
            code="Q{{x-urn:test:xproc:steplibrary}}error-from-my-xproc-step">
            <p:with-input port="source">
                <s:document>Something went wrong.</s:document>
            </p:with-input>
        </p:error>
    </p:declare-step>

    <p:declare-step type="s:p-error-or-document">
        <p:option name="error-msg" select="()"/>
        <p:output port="xproc-result"/>
        <p:if test="exists($error-msg)">
            <p:error code="error-from-my-xproc-step" name="s-p-error">
                <p:with-input port="source" expand-text="true">
                    <s:document>{$error-msg}</s:document>
                </p:with-input>
            </p:error>
        </p:if>
        <p:identity>
            <p:with-input>
                <no-errors/>
            </p:with-input>
        </p:identity>
    </p:declare-step>

    <p:declare-step type="s:input-port-cardinality-mismatch">
        <!-- This step has sequence=true, but it calls p:text-head, which doesn't. -->
        <p:input port="source" sequence="true" content-types="text"/>
        <p:output port="xproc-result" content-types="text"/>
        <p:text-head count="0" name="text-head"/>
    </p:declare-step>

</p:library>
