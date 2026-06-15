<?xml version="1.0" encoding="UTF-8"?>
<p:library xmlns:optinfo="x-urn:test:optinfo" xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">

    <p:declare-step type="optinfo:option-value">
        <!-- Note: For nodes, optinfo:option-value returns the option value wrapped in
        a document node. For details, see
        https://spec.xproc.org/3.1/xproc/#creating-documents-from-xdm-step-results -->
        <p:output port="xproc-result" sequence="true" content-types="any" primary="true"/>
        <p:output port="node-type" sequence="true" primary="false" pipe="@node-type"/>
        <p:output port="option-content-type" sequence="true" primary="false" pipe="@option-content-type"/>
        <p:output port="option-base-uri" sequence="true" primary="false" pipe="@option-base-uri"/>
        <p:option name="opt" select="'default'"/>
        <optinfo:option-node-types name="node-type">
            <p:with-option name="opt" select="$opt"/>
        </optinfo:option-node-types>
        <optinfo:option-property name="option-content-type" property-to-get="content-type">
            <p:with-option name="opt" select="$opt"/>
        </optinfo:option-property>
        <optinfo:option-property name="option-base-uri" property-to-get="base-uri">
            <p:with-option name="opt" select="$opt"/>
        </optinfo:option-property>
        <p:identity>
            <p:with-input select="$opt">
                <p:inline/>
            </p:with-input>
        </p:identity>
    </p:declare-step>

    <p:declare-step type="optinfo:option-node-types" name="multiple-node-types">
        <p:output port="xproc-result" sequence="true"/>
        <p:option name="opt" as="item()+" select="(
            parse-xml('&lt;document/&gt;'),
            parse-xml('&lt;document/&gt;')/*
            )"/>
        <p:identity>
            <p:with-input select="
                for $j in (1 to count($opt))
                return
                  optinfo:option-one-node-type(map{'opt': $opt[$j]})?xproc-result">
                <p:inline/>
            </p:with-input>
        </p:identity>
        <p:json-join/>
    </p:declare-step>

    <p:declare-step type="optinfo:option-one-node-type" name="one-node-type">
        <p:output port="xproc-result"/>
        <p:option name="opt" as="item()" select="parse-xml('&lt;document/&gt;')"/>
        <p:choose>
            <p:when test="not($opt instance of node())">
                <p:identity>
                    <p:with-input select="'Not a node'">
                        <p:inline/>
                    </p:with-input>
                </p:identity>    
            </p:when>
            <p:when test="$opt instance of document-node()">
                <p:identity>
                    <p:with-input select="'document node'">
                        <p:inline/>
                    </p:with-input>
                </p:identity>                
            </p:when>
            <p:when test="$opt instance of element()">
                <p:identity>
                    <p:with-input select="'element'">
                        <p:inline/>
                    </p:with-input>
                </p:identity>                
            </p:when>
            <p:when test="$opt instance of text()">
                <p:identity>
                    <p:with-input select="'text'">
                        <p:inline/>
                    </p:with-input>
                </p:identity>                
            </p:when>
            <p:when test="$opt instance of comment()">
                <p:identity>
                    <p:with-input select="'comment'">
                        <p:inline/>
                    </p:with-input>
                </p:identity>                
            </p:when>
            <p:when test="$opt instance of processing-instruction()">
                <p:identity>
                    <p:with-input select="'processing instruction'">
                        <p:inline/>
                    </p:with-input>
                </p:identity>                
            </p:when>
            <p:otherwise>
                <p:identity>
                    <p:with-input select="'other'">
                        <p:inline/>
                    </p:with-input>
                </p:identity>                                
            </p:otherwise>
        </p:choose>
    </p:declare-step>

    <p:declare-step type="optinfo:option-property">
        <p:output port="xproc-result" sequence="true" content-types="any"/>
        <p:option name="opt" select="'default'"/>
        <p:option name="property-to-get"/>
        <p:identity>
            <p:with-input select="$opt ! p:document-property(., $property-to-get)">
                <p:inline/>
            </p:with-input>
        </p:identity>
    </p:declare-step>

    <p:declare-step type="optinfo:option-named-name">
        <p:output port="xproc-result" sequence="true" content-types="any"/>
        <p:option name="name" select="'default'"/>
        <p:identity>
            <p:with-input select="$name">
                <p:inline/>
            </p:with-input>
        </p:identity>
    </p:declare-step>
</p:library>
