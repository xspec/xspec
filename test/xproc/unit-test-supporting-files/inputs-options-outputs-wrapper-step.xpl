<?xml version="1.0" encoding="UTF-8"?>
<!-- Note: Do not change white space in the select attributes that define maps. -->
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="3.1">
    <p:import href="..."/>
    <p:output port="map-of-outputs" pipe="result@ports-map"/>
    <p:option name="map-of-inputs"/>
    <p:option name="map-of-options"/>
    <s:inputs-options-outputs xmlns:s="x-urn:test:xproc:inputs-options-outputs" name="test-target">
        <p:with-input port="in1" select="$map-of-inputs?in1">
            <p:inline/>
        </p:with-input>
        <p:with-input port="in2">
            <p:document href="path/to/data.json" xml:base="..."/>
            <p:document href="path/to/text.txt" xml:base="..." document-properties="..."/>
        </p:with-input>
        <p:with-input port="in3" select="$map-of-inputs?in3">
            <p:inline/>
        </p:with-input>
    </s:inputs-options-outputs>
    <p:count limit="1" name="COUNT_out1">
        <p:with-input pipe="out1@test-target"/>
    </p:count>
    <p:choose name="map_out1">
        <p:when test="number(.) eq 0">
            <p:identity>
                <p:with-input select="
                                map{{
                                    'out1': map{{
                                        'document': (),
                                        'document-properties': map{{ }}
                                    }}
                                }}">
                    <p:inline>
                        <any-context/>
                    </p:inline>
                </p:with-input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:identity>
                <p:with-input select="
                                map{{
                                    'out1': map{{
                                        'document': .,
                                        'document-properties': p:document-properties(.)
                                    }}
                                }}"
                    pipe="out1@test-target"/>
            </p:identity>
        </p:otherwise>
    </p:choose>
    <p:count limit="1" name="COUNT_out2">
        <p:with-input pipe="out2@test-target"/>
    </p:count>
    <p:choose name="map_out2">
        <p:when test="number(.) eq 0">
            <p:identity>
                <p:with-input select="
                                map{{
                                    'out2': map{{
                                        'document': (),
                                        'document-properties': map{{ }}
                                    }}
                                }}">
                    <p:inline>
                        <any-context/>
                    </p:inline>
                </p:with-input>
            </p:identity>
        </p:when>
        <p:otherwise>
            <p:identity>
                <p:with-input select="
                                map{{
                                    'out2': map{{
                                        'document': .,
                                        'document-properties': p:document-properties(.)
                                    }}
                                }}"
                    pipe="out2@test-target"/>
            </p:identity>
        </p:otherwise>
    </p:choose>
    <p:json-merge duplicates="combine" name="merged">
        <p:with-input port="source">
            <p:pipe step="map_out1"/>
            <p:pipe step="map_out2"/>
        </p:with-input>
    </p:json-merge>
    <p:identity name="ports-map">
        <p:with-input select="map{{'ports': .}}"/>
    </p:identity>
</p:declare-step>