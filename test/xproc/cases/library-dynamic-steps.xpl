<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:ds="x-urn:test:dynamic-steps" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:mirror="x-urn:test:mirror" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.1">

    <p:declare-step type="ds:identity">
        <p:input port="source" content-types="any"/>
        <p:output port="xproc-result" content-types="any"/>
        <p:run>
            <p:with-input>
                <p:inline>
                    <p:declare-step version="3.1">
                        <p:input port="dynamic-step-source"/>
                        <p:output port="dynamic-step-result"/>
                        <p:identity/>
                    </p:declare-step>
                </p:inline>
            </p:with-input>
            <p:run-input port="dynamic-step-source"/>
            <p:output port="dynamic-step-result"/>
        </p:run>
    </p:declare-step>

    <p:declare-step type="ds:custom">
        <p:output port="xproc-result"/>
        <p:option name="opt"/>
        <p:run>
            <p:with-input>
                <p:inline>
                    <p:declare-step version="3.1">
                        <p:import href="library-mirror.xpl"/>
                        <p:output port="dynamic-step-result"/>
                        <p:option name="dynamic-step-option"/>
                        <mirror:option-value>
                            <p:with-option name="opt" select="$dynamic-step-option"/>
                        </mirror:option-value>
                    </p:declare-step>
                </p:inline>
            </p:with-input>
            <p:run-option name="dynamic-step-option" select="$opt"/>
            <p:output port="dynamic-step-result"/>
        </p:run>
    </p:declare-step>

</p:library>
