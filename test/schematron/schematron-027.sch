<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2">
    
    <sch:pattern>
        <sch:rule context="aff">
            <sch:assert test="@type" id="t01">aff must have a type attribute</sch:assert>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>