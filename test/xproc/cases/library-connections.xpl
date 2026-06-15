<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:s="x-urn:test:xproc:steplibrary" xmlns:sopt="x-urn:test:xproc:steplibrary:options"
    xmlns:p="http://www.w3.org/ns/xproc" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">

    <p:declare-step type="s:no-input-no-option-one-output">
        <p:output port="xproc-result"/>
        <p:identity>
            <p:with-input port="source">
                <root/>
            </p:with-input>
        </p:identity>
    </p:declare-step>

    <p:declare-step type="s:one-input-no-option-one-output" name="one-input-no-option-one-output">
        <p:input port="source"/>
        <p:output port="xproc-result"/>
        <p:identity/>
    </p:declare-step>

    <p:declare-step type="s:one-input-no-option-no-output" name="one-input-no-option-no-output">
        <p:input port="source"/>
        <p:sink/>
    </p:declare-step>

    <p:declare-step type="s:two-inputs-no-option-one-output" name="two-inputs-no-option-one-output">
        <p:input port="in1" primary="true"/>
        <p:input port="in2" primary="false"/>
        <p:output port="xproc-result"/>
        <p:add-attribute attribute-name="xml:id">
            <p:with-option name="attribute-value" select="/*/@xml:id"
                pipe="in2@two-inputs-no-option-one-output"/>
        </p:add-attribute>
    </p:declare-step>

    <p:declare-step type="s:no-input-one-option-one-output">
        <p:output port="xproc-result"/>
        <p:option name="attrval"/>
        <p:identity>
            <p:with-input port="source">
                <root/>
            </p:with-input>
        </p:identity>
        <p:add-attribute attribute-name="attr" attribute-value="{$attrval}"/>
    </p:declare-step>

    <p:declare-step type="s:no-input-two-options-one-output">
        <p:output port="xproc-result"/>
        <p:option name="attrval1"/>
        <p:option name="sopt:attrval2"/>
        <p:identity>
            <p:with-input port="source">
                <root/>
            </p:with-input>
        </p:identity>
        <p:add-attribute attribute-name="attr1" attribute-value="{$attrval1}"/>
        <p:add-attribute attribute-name="attr2" attribute-value="{$sopt:attrval2}"/>
    </p:declare-step>

    <!-- Several variations on s:two-inputs-no-option-one-output are for testing inheritance in x:call -->
    <p:declare-step type="s:two-inputs-no-option-one-output-altcomp"
        name="two-inputs-no-option-one-output-altcomp">
        <!-- Same ports as s:two-inputs-no-option-one-output but different behavior -->
        <p:input port="in1" primary="true"/>
        <p:input port="in2" primary="false"/>
        <p:output port="xproc-result"/>
        <p:add-attribute attribute-name="altcomp">
            <p:with-option name="attribute-value" select="/*/@xml:id"
                pipe="in2@two-inputs-no-option-one-output-altcomp"/>
        </p:add-attribute>
    </p:declare-step>

    <p:declare-step type="s:two-inputs-no-option-one-output-altname"
        name="two-inputs-no-option-one-output-altname">
        <!-- Same as s:two-inputs-no-option-one-output but with capitalized input port names -->
        <p:input port="in1" primary="true"/>
        <p:input port="IN2" primary="false"/>
        <p:output port="xproc-result"/>
        <p:add-attribute attribute-name="xml:id">
            <p:with-option name="attribute-value" select="/*/@xml:id"
                pipe="IN2@two-inputs-no-option-one-output-altname"/>
        </p:add-attribute>
    </p:declare-step>

    <p:declare-step type="s:two-inputs-no-option-one-output-altpos"
        name="two-inputs-no-option-one-output-altpos">
        <!-- Same as s:two-inputs-no-option-one-output but switching the input port declaration order -->
        <p:input port="in2" primary="false"/>
        <p:input port="in1" primary="true"/>
        <p:output port="xproc-result"/>
        <p:add-attribute attribute-name="altpos">
            <p:with-option name="attribute-value" select="/*/@xml:id"
                pipe="in2@two-inputs-no-option-one-output-altpos"/>
        </p:add-attribute>
    </p:declare-step>

    <p:declare-step type="s:three-inputs-no-option-one-output"
        name="three-inputs-no-option-one-output">
        <!-- Same as s:two-inputs-no-option-one-output but with extra input port -->
        <p:input port="in1" primary="true"/>
        <p:input port="in2" primary="false"/>
        <p:input port="extra" primary="false"/>
        <p:output port="xproc-result"/>
        <p:add-attribute attribute-name="xml:id">
            <p:with-option name="attribute-value" select="/*/@xml:id"
                pipe="in2@three-inputs-no-option-one-output"/>
        </p:add-attribute>
        <p:add-attribute attribute-name="extra">
            <p:with-option name="attribute-value" select="/*/@xml:id"
                pipe="extra@three-inputs-no-option-one-output"/>
        </p:add-attribute>
    </p:declare-step>
</p:library>
